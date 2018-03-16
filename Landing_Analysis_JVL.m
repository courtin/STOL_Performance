%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   LANDING ANALYSIS 
%   
%
%   Landing equations from:
%   http://www.dept.aoe.vt.edu/~lutze/AOE3104/takeoff&landing.pdf
%   
%   Static thrust model from:
%   http://www.dept.aoe.vt.edu/~lutze/AOE3104/thrustmodels.pdf
%   
%   OUTPUTS:
%
%   S           Landing ground roll (m)
%
%   V_grnd      Landing touchdown groundspeed (m/s)
%
%   INPUTS:
%   
%   airplane.   Data structure containing the landing aircraft, containing 
%               the following variables:
%
%           environment.
%                       gc              Gravitational acceleration [m/s^2]
%
%           propulsion.
%                       P_shaft_max     Maximum shaft power developed by
%                                       the engine [W] **
%                       D_prop          Propeller diameter [m] **
%
%                       n_prop          Number of propellers [-] **
%
%                       eta_p_rev       Propeller efficiency in reverse
%                                       thrust configuration [-]. **
%
%                       wheels.
%                               mu_brk  Braking coefficient of friction [-]
%
%           geometry.
%                   Wing.
%                       Sref            Wing reference area [m^2]
%             
%           aero.
%               CL_ground_land          Vehicle lift coefficient when all 
%                                       wheels are on the ground and the 
%                                       flaps are in the landing
%                                       configutation. [-]
%                                       
%               CL_max_land             Maximum lift coefficient in the
%                                       landing configuration [-]
%           current_state.
%                        weight         Landing weight of the aircraft [N]
%
%   segment_inputs.     Data structure that defines the landing
%                       environment, containing:
%                   
%                   h_i                 Landing altitude [m]
%
%                   spd_mrgn            Required touchdown margin above
%                                       stall speed, given as a
%                                       multiplier on stall speed. [-]
%                   V_wind              (OPTIONAL) The headwind (+) or
%                                       tailwind (-) present at landing.
%                                       If this field isn't present to wind
%                                       is assumed. [m/s]
%                   thrust_reversers    (OPTIONAL) Flag to specify the use
%                                       of thrust reversers.  If 0 or not set, no
%                                       reverse thrust is assumed. [0 or 1]
%
%   verbose             Flag to control whether the results summary is
%                       written [0 or 1] 
%
%   ** Variable only required if segment_inputs.thrust_reversers = 1
%
%   FUNCTIONAL DEPENDENCIES
%   int_std_atm     - atmospheric properties lookup
%   getDrag         - drag polar calculation
%
%   Created by: Chris Courtin (courtin@mit.edu)
%   Last updated: 10th March. 2018
%
%   NOTES:
%
%   All propellers are assumed to have the same diameter
%
%   Propellers are assumed to have a constant reverse thrust efficiency w/
%   speed. 
%
%
%    Changes:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clc;
clear all; 
V_01;
airplane = initialize_geometry(airplane);
airplane.aero.h_jet = airplane.geometry.Wing.c_ma;
segment_inputs.h_i = 0;
segment_inputs.spd_mrgn = 1.0;
CL = 4;
static_LA(CL,airplane, segment_inputs, 1);
%%
% N       = 1;
% CL      = linspace(1.5,5,N);
% gam_ref = zeros(N,1);
% V_ref   = zeros(N,1);
% S_roll  = zeros(N,1);
% 
% for i = 1:N
%     [gam_ref(i), V_ref(i), S_roll(i)] = static_LA(CL(i), airplane, segment_inputs, 1);
% end
% 
% plot(CL, gam_ref)
% hold on
% plot([CL(1), CL(N)], [0,0], 'k--')
% xlabel('C_L')
% ylabel('\gamma_{approach}')
% 
% figure()
% plot(CL, S_roll)
% xlabel('C_L')
% ylabel('Landing ground roll (m)')
% 
% figure()
% plot(CL, V_ref)
% xlabel('C_L')
% ylabel('Approach speed (m/s)')
% 



function [gam_ref, V_ref, S_lnd] = static_LA(CL, airplane, segment_inputs, verbose)
    fprintf(1, '---Approach Performance---\n')
    W                   = airplane.current_state.weight;
    Sref                = airplane.geometry.Wing.Sref;
    
    alt_lnd             = segment_inputs.h_i;

    [~,~, rho, a] = int_std_atm(alt_lnd, airplane.sim.flight_condition);

    %Calculate CL
    CLc = airplane.aero.CL_c_max_land;
    e   = airplane.aero.Wing.e;
    AR  = airplane.geometry.Wing.AR;

    
    gamma = 0;
    err = 1e6;
    err_threshold = 1e-3;
    count = 0;
    max_iter = 100;
    n = 1;
    if verbose
        fprintf(1, 'Iterating on approach angle...\n')
        fprintf(1, 'iter\tgam\terr\tVref\tCL\tCJ\tCX\tCDp\th_dot\tn\n')
    end
    while (abs(err) > err_threshold) && (count < max_iter)
        
        V_ref = sqrt(2*W*n*cosd(gamma)/(rho*Sref*CL));
        M_ref = V_ref/a;
        airplane.current_state.M = M_ref;
        [CX, CJ, DD] = jvl_forces(CL, airplane, segment_inputs, 0);
        sing = -CX*.5*rho*V_ref^2*Sref/W;
        hdot = V_ref*sing;
        gamma_n = asind(sing);
        
        

        err = gamma-gamma_n;
        if verbose
            fprintf(1, '%2.0f\t%2.1f\t%3.3f\t%3.2f\t%2.1f\t%2.1f\t%3.2f\t%3.2f\t%3.2f\t%3.1f\n', count,...
                gamma, err, V_ref,CL, CJ, CX, DD.CDp, hdot,n)
        end
        gamma = gamma_n;
        count = count+1;
        
        
        
    end
    gam_ref = gamma;
    if verbose
        fprintf(1, 'V_ref: %3.1f Gamma_ref: %3.1f\n\n', V_ref, gamma)
    end
    [CQ, CE] = get_CQ_CE(CJ, airplane.aero.h_jet/airplane.geometry.Wing.c_ma);
    eta_f = .8;
    P_shaft = .5*rho*V_ref^3*Sref*(CE-CQ)/eta_f;
    fprintf(1, 'Required shaft power: %4.1f kW', P_shaft/1000);
    
    airplane.current_state.CJ = CJ;
    airplane.current_state.CL = CL;
    [S_lnd, V_grnd] = get_LandingDistance(airplane, segment_inputs, verbose);
end