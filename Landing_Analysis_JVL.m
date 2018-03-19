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
segment_inputs.h_i = 0;
airplane.aero.delta_flap_land = 80;
segment_inputs.spd_mrgn = 1.0;
CL = 6.5;
static_LA_JVL(CL,airplane, segment_inputs, 1);
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



