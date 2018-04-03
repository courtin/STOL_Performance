%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file defines the aircraft who's performance is to be analyzed.  The
% aircraft is represented by an "airplane" data structure which
% contains all the parameters that describe the airplane.  This
% data structure contains several substructures with the parameters
% describing those subsystems.  The fields of the airplane data
% structure are described below:
%
%  airplane                   top level data structure
%      .configuration         geometry and number of engines
%      .weights               major airframe weights
%      .powertrain            power generation system parameters
%      .systems               payload and avionics w
%      .aerodynamics          drag polars
%      .environment           atmospheric conditions of flight
%      .mission               flight profile and other mission constraints
%      .sim                   Simulation control variables
%      .current_state         Current vehicle state
%
%  The fields of the substructures are described below
%
%  geometry.
%       Wing.
%           Sref                wing area  [m^2]
%           AR                  aspect ratio
%           t_c_avg             average thickness/chord ratio
%           lambda              taper ratio
%           x_c_m               chordwise maximum thickness point
%           eta_0               non-dimensional wing root offset from
%                               centerline
%       Htail.
%             S                 tail area [m^2]
%               ...             all other variables the same as wing
%
%       Vtail.
%               ...             same variables as Htail
%
%       Fuse.
%           Swet                Fuselage wetted area [m^2]
%           fr                      "    fineness ratio
%           l                       "    length [m]
%
%  weights               
%      .MTOW             maximum takeoff weight, N
%      .MLW              maximum landing weight, N
%      .payload          maximum payload weight  N
%      .fuel             maximum fuel capacity,  N
%      .OEW              operating empty weight, N
%      .current          current gross weight,   N
%
%  Engine
%      .Pmax             maximum power, kW
%      .eta_p            propeller efficiency
%      .PSFC             power-specific fuel consumption
%
%  mission
%      .missionType         Type of mission calculation
%           'range'         - calculate fuel/energy required for a given range
%           'fuel'          - calculate range for a given fuel
%                           volume/energy capacity
%      .Range               Mission  , m (ignored if missionType = fuel
%      .missionFuel         mission fuel capacity,  N (ignored if missionType
%           = range)
%    
%  systems
%      .avionics            air vehicle systems power, W
%      .payload             payload power, W
%      .power               sum of payload and avionics power, W
%      .eta_gen             generator efficiency
%
%  aero
%       .Wing
%           .e              span efficiency of main wing
%           .CL_max_land    max lift coefficient, landing configuration
%           .CL_ground_land lift coefficient with wheels on ground, landing config
%           .CL_max_takeoff max lift coefficient, takeoff configuration
%           .CL_ground_takeoff ground roll lift coefficient, takeoff config
%
%  environment           
%      .rho0                sea level, std day density, kg/cu m
%      .p0                  "    "     "   "  pressure, Pa  
%      .T0                  "    "     "   "  temperature, K
%      .dT                  temperature increment from std conditions, K
%      .dens_alt            map of density ratio to density altitude, m
%      .gc                  acceleration due to gravity
%
%  sim
%       .hmax               Max altitude for atmosphere model
%       .dh                 Altitude delta for atmosphere model (0:dh:hmax)
%       .flight_condition   Temperature offsets of the atmosphere model
%                               -'std day'
%                               -'hot day'
%                               -'cold day'
%       .cinc               Number of climb integration steps per section
%       .rinc               Number of cruise integration steps per section
%       .dinc               Number of descent integration steps per section

% create the airplane data structure and initialize the common
% parameters.

%Useful unit conversion factors
ftsq2msq    = 0.0929;
ft2m        = 0.3048;
lbf2N       = 4.44822;
fpm2mps     = 0.00508;
kts2mps     = 0.51444;
nmi2m       = 1852.0;
in2m        = 0.0254;
%%%%%%%%%%%%%%%%%%%%%%%
%VEHICLE GEOMETRY     %
%%%%%%%%%%%%%%%%%%%%%%%
geometry.Wing.Sref              =  290.7   *ftsq2msq;
geometry.Wing.AR                = 5.34;
geometry.Wing.t_c_avg           = .12;
geometry.Wing.lambda            = .6;
geometry.Wing.x_c_m             = .5;   
geometry.Wing.eta_0             = 0;    %high wing

geometry.Wing.f_flap_span         = .6;
geometry.Wing.f_flap_chord        = .3;

geometry.Wing.f_spoil_span         = .5;
geometry.Wing.f_spoil_chord        = .2;

geometry.Htail.S                 = 16.4;   %square feet
geometry.Htail.AR                = 3.98;
geometry.Htail.t_c_avg           = .10;
geometry.Htail.lambda            = 1;
geometry.Htail.x_c_m             = .3;   %should be good for most low-speed AF
geometry.Htail.eta_0             = 0;    %assume no fuse. carry-thru

geometry.Vtail.S                 = 16.4;
geometry.Vtail.AR                = 3.98;
geometry.Vtail.t_c_avg           = .10;
geometry.Vtail.lambda            = .8;
geometry.Vtail.x_c_m             = .3;   %should be good for most low-speed AF
geometry.Vtail.eta_0             = 0;    %assume no fuse. carry-thru

geometry.Fuse.Swet               = 207.17  * ftsq2msq;
geometry.Fuse.fr                 = 1.87; %Fineness ratio
geometry.Fuse.l                  = 25   * ft2m;     


%%%%%%%%%%%%%%%%%
%VEHICLE WEIGHTS%
%%%%%%%%%%%%%%%%%
weights.MTOW        = 3882.34     * lbf2N;
weights.payload     = 4*203     * lbf2N;
weights.MLW         = weights.MTOW;

%%%%%%%%%%%%%%%
%CURRENT STATE%
%%%%%%%%%%%%%%%

current_state.weight = weights.MTOW;

%%%%%%%%%%%%%%%%%%%
%PROPULSION SYSTEM%
%%%%%%%%%%%%%%%%%%%
propulsion.P_shaft_max  = 89.4e3;        %W
propulsion.eta_p_TO     = .85;
propulsion.eta_p_rev    = 0;
propulsion.n_prop       = 8;
propulsion.D_prop       = 0.5107*2;          %m  

propulsion.wheels.mu_brk    = .5;
propulsion.wheels.mu_roll   = .02;

%%%%%%%%%%%%%%%%%%%%
%MISSION DEFINITION%
%%%%%%%%%%%%%%%%%%%%
mission.missionType = 'range';
mission.altTO       = 0         * ft2m;

mission.altLand     = 0         * ft2m;

mission.V_low_limit = 120     * kts2mps; 

mission.Range       = 100.0    * nmi2m;
mission.missionFuel = 20     * lbf2N;

%%%%%%%%%%%%%%%%%%%
%SYSTEM DEFINITION%
%%%%%%%%%%%%%%%%%%%

system.avionics     = 1         * 1000; %W
system.payload      = 0         * 1000; %W
system.eta_gen      = .75;
system.power        =   system.avionics + ...
                        system.payload;
                    

%%%%%%%%%%%%%%%%%%%%%%%%
%AERODYNAMIC DEFINITION%
%%%%%%%%%%%%%%%%%%%%%%%%
aero.Wing.e              = .85;
aero.CL_max_land         = 2;
aero.CL_ground_land      = .3;    %Vehicle CL with wheels on ground, landing configuration
aero.CL_max_takeoff      = 4.167;
aero.CL_ground_takeoff   = .2;    %Vehicle CL with wheels on ground, takeoff configuration
aero.CL_c_max_land       = 3.5;
aero.delta_flap_land      = 60;
aero.delta_spoil_land     = 0;
aero.h_jet               = 6*ft2m;
aero.alfa_approach = 12;
%%%%%%%%%%%%%%%%%%%%%%%%
%ENVIRONMENT DEFINITION%
%%%%%%%%%%%%%%%%%%%%%%%%
environment.rho0 = 1.225;
environment.p0 = 101325;
environment.T0 = 288.15;
environment.gc = 9.80665; 
environment.dt = 0;
environment.gamma  = 1.4;

%%%%%%%%%%%%%%%%%%%%%%%
%SIMULATION DEFINITION%
%%%%%%%%%%%%%%%%%%%%%%%
sim.hmax                = 2000     * ft2m;
sim.dh                  = 12.35      * ft2m;
sim.flight_condition    = 'std day';
sim.cinc                = 64;
sim.rinc                = 64;
sim.dinc                = 64;
sim.downwash_mode            = 3;
sim.jvl_input_file      = 'h_wing';

sim.sizeTimeHistory =17;


%Combine Data Structures
airplane.geometry       = geometry;
airplane.weights        = weights;
airplane.propulsion     = propulsion;
airplane.aero           = aero;
airplane.environment    = environment;
airplane.system         = system;
airplane.mission        = mission;
airplane.sim            = sim;
airplane.current_state  = current_state;

