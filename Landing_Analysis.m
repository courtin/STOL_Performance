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
V_02;
airplane = initialize_geometry(airplane);
airplane.aero.h_jet = .25;
segment_inputs.h_i = 0;
segment_inputs.spd_mrgn = 1.0;

airplane.sim.downwash_mode = 3;
aero.CL_c_max_land       = 3;

d_flaps = [10:10:60];
D = length(d_flaps);

CL = [1:.2:10];
C = length(CL);
% figure()
% hold on
% V_02;
% airplane = initialize_geometry(airplane);
% Pgam0 = zeros(1,D);
% CLgam0 = zeros(1,D);
% Pgamn5 = zeros(1,D);
% CLgamn5 = zeros(1,D);
% for d = 1:D
%     P_shaft = zeros(1,C);
%     gammas  = zeros(1,C);
%     
%     airplane.aero.delta_flap_land = d_flaps(d);
%     for c = 1:C
%         [gammas(c), V_ref, S_lnd, P_shaft(c)] = static_LA(CL(c),airplane, segment_inputs, 1);
%     end
%     
%     %Pgam0(d) = interp1(gammas, P_shaft, 0);
%     %CLgam0(d) = interp1(gammas, CL, 0);
%     %Pgamn5(d) = interp1(gammas, P_shaft, -5);
%     %CLgamn5(d) = interp1(gammas, CL, -5);
%     
%     plot(CL, P_shaft./1000)
% end
% plot(CLgam0, Pgam0./1000, '-k')
% plot(CLgamn5, Pgamn5./1000, '-k')
% xlabel('CL')
% ylabel('P_{shaft}')

figure()
hold on
V_02;
airplane = initialize_geometry(airplane);
Pgam0 = zeros(1,D);
CLgam0 = zeros(1,D);
Pgamn5 = zeros(1,D);
CLgamn5 = zeros(1,D);
for d = 1:D
    P_shaft = zeros(1,C);
    gammas  = zeros(1,C);
    
    airplane.aero.delta_flap_land = d_flaps(d);
    for c = 1:C
        [gammas(c), V_ref, S_lnd, P_shaft(c)] = static_LA(CL(c),airplane, segment_inputs, 1);
    end
    
    %Pgam0(d) = interp1(gammas, P_shaft, 0);
    %CLgam0(d) = interp1(gammas, CL, 0);
    %Pgamn5(d) = interp1(gammas, P_shaft, -5);
    %CLgamn5(d) = interp1(gammas, CL, -5);
    
    plot(CL, gammas)
end

xlabel('CL')
ylabel('\gamma')

