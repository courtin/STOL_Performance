%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STOL AIRCRAFT SIMULATION V0.1
%
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
%  configuration                     2
%      .S                wing area, m
%      .b                span,      m
%      .mac              mean aerodynamic chord, m
%      .no_of_engines    
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
%  aerodynamics
%      .dCDp                wing pods drag coefficient
%      .dCDlg               landing gear drag coefficient
%      .dCDf                full flap drag coefficient increment
%      .polar               coefficients [A B D] in CD = A + B CL + D CL^2
%      .CLmax               maximum trimmed lift coefficient
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
% 
%       Created by Chris Courtin (courtin@mit.edu)
%
%       NOTES:
%       Changes:
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
%VEHICLE CONFIGURATION%
%%%%%%%%%%%%%%%%%%%%%%%
n = .52;
configuration.S                 = 1250*n^2*ftsq2msq;
configuration.b                 = 117.5*n*ft2m;
configuration.mac               = 12.4*n*ft2m;
configuration.AR                = 11;


%%%%%%%%%%%%%%%%%
%VEHICLE WEIGHTS%
%%%%%%%%%%%%%%%%%
weights.MTOW        = 23500    * lbf2N;
weights.payload     = 1500     * lbf2N;
weights.fuel        = 4300     * lbf2N;
weights.OEW         = 19200     * lbf2N;
weights.MLW         = weights.MTOW*.95;
weights.current     = weights.MTOW;

%%%%%%%%%%%%%%%%%%%
%POWER GENERATION SYSTEM%
%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%
%MISSION DEFINITION%
%%%%%%%%%%%%%%%%%%%%
mission.missionType = 'range';
mission.altTO       = 0         * ft2m;

mission.altLand     = 0         * ft2m;

mission.sizingPoint.alt         = 45000     * ft2m;
mission.sizingPoint.M           = 0.78;
mission.sizingPoint.CL          = .67;
mission.sizingPoint.condition   = 'std day';

mission.V_low_limit = 250.0     * kts2mps; 

mission.Range       = 3000.0    * nmi2m;
mission.missionFuel = 28000     * lbf2N;

%%%%%%%%%%%%%%%%%%%
%SYSTEM DEFINITION%
%%%%%%%%%%%%%%%%%%%

system.avionics     = 2         * 1000; %W
system.payload      = 5         * 1000; %W
system.eta_gen      = .75;
system.power        =   system.avionics + ...
                        system.payload;
                    

%%%%%%%%%%%%%%%%%%%%%%%%
%AERODYNAMIC DEFINITION%
%%%%%%%%%%%%%%%%%%%%%%%%
aero.dragInputType      = 'Aero Scaling';
%aero.dragPolarTabName   = 'polars';
aero.fWakef              = 0.07;

aero.Objective.e = .8866;
aero.Objective.CD_tot = .0359;
aero.Objective.CD_fuse = .0090;
aero.Objective.CDi         = .0124;
aero.Objective.M = .78;
aero.Objective.alt = 40000*ft2m;
aero.Objective.mac    = 12.4*ft2m;

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
sim.hmax                = 60000     * ft2m;
sim.dh                  = 1000      * ft2m;
sim.flight_condition    = 'std day';
sim.cinc                = 64;
sim.rinc                = 64;
sim.dinc                = 64;

sim.sizeTimeHistory =17;


%Combine Data Structures
airplane.configuration  = configuration;
airplane.weights        = weights;
airplane.Engine         = Engine;
airplane.aero           = aero;
airplane.environment    = environment;
airplane.system         = system;
airplane.mission        = mission;
airplane.sim            = sim;


