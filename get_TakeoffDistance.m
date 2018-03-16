%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TAKEOFF PERFORMANCE CODE (VERSION 0.1) 
%   TAKEOFF GROUND ROLL AND OBSTACLE CLEARANCE CLIMB
%
%   ASSUMED CONSTANT THRUST VARIATION WITH SPEED
%
%   Takeoff equations from:
%   http://www.dept.aoe.vt.edu/~lutze/AOE3104/takeoff&landing.pdf
%   
%   Static thrust model from:
%   http://www.dept.aoe.vt.edu/~lutze/AOE3104/thrustmodels.pdf
%
%   Assumes V_R (rotation speed) = V2 (takeoff safety speed crossing 50ft obstacle) 
%   = 1.2 VS1 (stall speed in landing configuration) 
%
%   From ASTM standards
%   (https://compass.astm.org/EDIT/html_annot.cgi?F3179). This is a slight
%   oversimplification since the requirement on V_R is 1.1 VS1; this
%   adds conservatism to the ground roll calculation. 
%
%   OUTPUTS:
%
%   S_gr           Takeoff ground roll (m)
%
%   
%
%   V_2             Takeoff true airspeed (m/s)
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
%                                       the engine at takeoff [W] 
%                       D_prop          Propeller diameter [m] 
%
%                       n_prop          Number of propellers [-] 
%
%                       eta_p_TO        Propeller efficiency in takeoff
%                                       configuration [-]. 
%
%                       wheels.
%                               mu_roll Rolling coefficient of friction [-]
%
%           geometry.
%                   Wing.
%                       Sref            Wing reference area [m^2]
%             
%           aero.
%               CL_ground_takeoff       Vehicle lift coefficient when all 
%                                       wheels are on the ground and the 
%                                       flaps are in the takeoff
%                                       configutation. [-]
%                                       
%               CL_max_takeoff          Maximum lift coefficient in the
%                                       takeoff configuration [-]
%           current_state.
%                        weight         Takeoff weight of the aircraft [N]
%
%   segment_inputs.     Data structure that defines the landing
%                       environment, containing:
%                   
%                   h_i                 Takeoff altitude [m]
%
%                   V_wind              (OPTIONAL) The headwind (+) or
%                                       tailwind (-) present at takeoff.
%                                       If this field isn't present no wind
%                                       is assumed. [m/s]
%                   powered_wheels     (OPTIONAL) Flag to specify the use
%                                       of powered wheels.  If 0 or not set, no
%                                       wheel power is assumed. [0 or 1]
%
%   verbose             Flag to control whether the results summary is
%                       written [0 or 1] 
%
%   ** Variable only required if segment_inputs.powered_wheels = 1
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
%   Propellers are assumed to have a constant thrust efficiency w/
%   speed. 
%
%
%    Changes:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [S, V_2] = get_TakeoffDistance(airplane, segment_inputs, verbose)

   g                    = airplane.environment.gc;
    
    
    W                   = airplane.current_state.weight;
    Sref                = airplane.geometry.Wing.Sref;
    
    mu_roll             = airplane.propulsion.wheels.mu_roll;
    alt_TO              = segment_inputs.h_i;
    
    CL_grnd             = airplane.aero.CL_ground_takeoff;
    CL_max              = airplane.aero.CL_max_takeoff;
    
    [~,~, rho, a] = int_std_atm(alt_TO, airplane.sim.flight_condition);

    %Calculate rotation and takeoff speed (TAS) + CL
    V_s1g   = sqrt(2.*W/(CL_max*rho*Sref));
    V_R     = V_s1g*1.1;    %Hard-coded margins from ASTM
    M_R     = V_R/a;
    V_2     = V_s1g*1.2;    %Hard-coded margins from ASTM; takeoff safety speed
    M_2     = V_2/a;
    CL_2    = 2*W/(rho*V_2^2*Sref);
    [CD_2,~] = getDrag(airplane, alt_TO, M_2, CL_2);
    
    %Calculate wheels-down drag coefficient
    [CD_grnd,~] = getDrag(airplane, alt_TO, M_2/2., CL_grnd); %Use Re half-way through ground roll
    
    
    %Thrust calculations
    P_s_max             = airplane.propulsion.P_shaft_max;
    D_prop              = airplane.propulsion.D_prop;
    n_prop              = airplane.propulsion.n_prop;
    eta_TO              = airplane.propulsion.eta_p_TO;


    A_prop      = n_prop * pi * D_prop^2/4;

    T_TO        = P_s_max*eta_TO/V_2;
    
    %Calculate static thrust
    T0 = P_s_max^(2/3)*(2*rho*A_prop)^(1/3)*eta_TO;

    %T = T0-aV^2
    a = (T0-T_TO)/(V_2)^2;
    
    %V_grd - account for any wind present
    if isfield(segment_inputs, 'V_wind')
       V_grnd = V_2 + V_wind;
    else
       V_grnd = V_2;
    end
    
    T_W  = T0/W;
    
    %Climb angle
    sing = (T_TO-CD_2*.5*rho*V_2^2*Sref)/(W);
    gamma_climb = asind(sing);

    %Ground roll
    A                   = g * (T_W-mu_roll);
    B                   = (g/W)*(.5*rho.*Sref*(CD_grnd - mu_roll*CL_grnd) + a);

    S_m                 = 1./(2.*B).*log((A./(A-B*V_grnd.^2)));
    S_ft                = S_m/.3048;
    V_2_kts             = V_2*1.94384;
    Vs1g_kts            = V_s1g*1.94384;
    
    %Obstacle clearance distance
    S_air               = segment_inputs.h_obstacle/tand(gamma_climb);
    S_runway            = S_air + S_m;
    S_runway_ft         = S_runway/.3048;
    if verbose
        fprintf(1, "\n---Takeoff Performance---\n")
        fprintf(1, "Takeoff ground roll:            %4.1f ft (%4.1f m)\n", S_ft, S_m)
        fprintf(1, "Takeoff distance (50 ft obs.)   %4.1f ft (%4.1f m)\n", S_runway_ft, S_runway)
        fprintf(1, "V2:                     %4.1f KTAS (%4.1f m/s)\n", V_2_kts, V_2)
        fprintf(1, "Stall speed (takeoff):  %4.1f KTAS (%4.1f m/s)\n", Vs1g_kts, V_s1g)
        fprintf(1, "Takeoff CL              %4.2f\n", CL_2)
        fprintf(1, "Takeoff CD              %4.2f\n", CD_2)
        fprintf(1, "Takeoff L/D             %4.2f\n", CL_2/CD_2)
        fprintf(1, "Static T/W              %3.2f\n", T0/W)
        fprintf(1, "Static Thrust           %4.0f lbf (%4.0f N)\n", T0*.225, T0)
        fprintf(1, "Climb angle             %2.1f deg\n", gamma_climb) 
    end
end