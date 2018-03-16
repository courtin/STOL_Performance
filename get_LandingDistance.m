%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   LANDING PERFORMANCE CODE (VERSION 0.1) 
%   LANDING GROUND ROLL FOR VEHICLE WITH BRAKES AND THRUST REVERSERS 
%
%   ASSUMED CONSTANT THRUST VARIATION WITH SPEED, CL, CD, BRAKING 
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

function [S_m, V_grnd] = get_LandingDistance(airplane, segment_inputs, verbose)
    
    g                   = airplane.environment.gc;
    
    
    W                   = airplane.current_state.weight;
    Sref                = airplane.geometry.Wing.Sref;
    
    mu_brk              = airplane.propulsion.wheels.mu_brk;
    
    alt_lnd             = segment_inputs.h_i;
    spd_mrgn            = segment_inputs.spd_mrgn;
    
    CL_grnd             = airplane.aero.CL_ground_land;
    %CL_max              = airplane.aero.CL_max_land;
    CL_max              = airplane.current_state.CL; 
    [~,~, rho, a] = int_std_atm(alt_lnd, airplane.sim.flight_condition);
    
    %Calculate landing speed (TAS) + CL
    V_s1g   = sqrt(2.*W/(CL_max*rho*Sref));
    V_lnd   = V_s1g*spd_mrgn;
    M_lnd   = V_lnd/a;
    %CL_lnd  = 2*W/(rho*V_lnd^2*Sref);
    CL_lnd  = CL_max/spd_mrgn^2;
    [CD_lnd,~] = getDrag(airplane, alt_lnd, M_lnd, CL_lnd, 'landing');
    
    %Calculate wheels-down drag coefficient
    [CD_grnd,~] = getDrag(airplane, alt_lnd, M_lnd, CL_grnd, 'landing'); 
    
    
    %Reverse thrust
    T_W = 0;
    a = 0;
    
    %Calculate max thrust at touchdown
    if isfield(segment_inputs, 'thrust_reversers')
        if segment_inputs.thrust_reversers
            P_s_max             = airplane.propulsion.P_shaft_max;
            D_prop              = airplane.propulsion.D_prop;
            n_prop              = airplane.propulsion.n_prop;
            eta_rev             = airplane.propulsion.eta_p_rev;
    
    
            A_prop      = n_prop * pi * D_prop^2/4;
            
            T_lnd       = P_s_max*eta_rev/V_lnd;
    
            %Calculate static thrust
            T0 = P_s_max^(2/3)*(2*rho*A_prop)^(1/3)*eta_rev;

            %T = T0-aV^2
            a = (T0-T_lnd)/(V_lnd)^2;
        end
    end
    
    %V_grd - account for any wind present
    if isfield(segment_inputs, 'V_wind')
       V_grnd = V_lnd + V_wind;
    else
       V_grnd = V_lnd;
    end


    A                   = g * (T_W-mu_brk);
    B                   = (g/W)*(.5*rho.*Sref*(CD_grnd - mu_brk*CL_grnd) + a);
    S_m                 = 1./(2.*B).*log((1-B./A*V_grnd.^2));
    %Calculate power-off approach angle 
    tang = 1/(CL_lnd/CD_lnd);
    gamma_lnd = atand(tang);
    %Some unit conversions for reporting
    S_ft                = S_m/.3048;
    V_grnd_kts          = V_grnd*1.94384;
    V_lnd_kts           = V_lnd*1.94384;
    V_s1g_kts           = V_s1g*1.94384;
    
    if verbose
        fprintf(1, "\n---Landing Performance---\n")
        fprintf(1, "Landing ground roll:    %4.1f ft (%4.1f m)\n", S_ft, S_m)
        fprintf(1, "Touchdown airspeed:     %4.1f KTAS (%4.1f m/s)\n", V_lnd_kts, V_lnd)
        fprintf(1, "Touchdown ground speed: %4.1f KTS  (%4.1f m/s)\n", V_grnd_kts, V_grnd)
        fprintf(1, "Stall speed (landing):  %4.1f KTAS (%4.1f m/s)\n", V_s1g_kts, V_s1g)
        fprintf(1, "Touchdown CL            %4.2f\n", CL_lnd)
        fprintf(1, "Touchdown CD            %4.2f\n", CD_lnd)
        fprintf(1, "Touchdown L/D           %4.2f\n", CL_lnd/CD_lnd)
        fprintf(1, "Power-off approach path %2.1f deg\n", gamma_lnd) 
    end
end