%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   STOLSIM V0.1
%
%   MISSION INPUT SCRIPT
%   
%   OUTPUTS:
%
%   Mission     The mission data structure defines the flight profile to
%               be simulated in runMission.  For each element there are
%               several required inputs as well as a number of optional
%               ones that change based on the type of mission segment.
%               Inputs marked Required are needed for all segment types.
%               Inputs marked Required-nf are needed for all segment types
%               except 'fixed'.
%
%       .segment_type   (Required) Each mission segment is defined by it's
%                       type. The allowable segment types are:
%           
%           'fixed'     For the fixed segment type, fuel burn is calculated
%                       based on a given fuel fraction.
%           'climb'     Calculates fuel burn/energy useage and vehicle flight profile for
%                       a climb segment.  Rate of climb is calculated based
%                       on excess power at a specified flight condition.
%           'descent'   Calculates fuel burn and vehicle flight profile for
%                       a descending flight segment.  
%           'level cruise' 
%                       Calculates fuel burn and vehicle flight profile for
%                       a constant altitude cruise segment.
%           'cruise-climb'
%                       Calculates fuel burn and vehicle flight profile for
%                       a cruise-climb flight segment.
%           'takeoff'
%                       Calculates required takeoff distance, time, and
%                       fuel/energy usage.
%           'landing'   
%                       Calculates required landing distance, time, and
%                       fuel/energy usage.
%       
%       .cinc           (Required).  Number of subsegments the mission
%                       segment is broken up into for integration.  For 
%                       'fixed' segment types this must be 1.
%              
%       .flight_condition   
%                       (Required-nf) The flight_condition parameter sets
%                       the parameter that constrains the level flight
%                       condition.  The allowable options are:
%           'speed'     The segment occurs are a fixed equivalent airspeed,
%                       Mach and CL are adjusted accordingly.
%           'Mach'      The segment occurs at a constant Mach number. Veas
%                       and CL are adjusted accordingly.
%           'CL'        The segment occurs at a specified CL.  Veas and
%                       Mach are adjusted accordingly.
%       .Veas           Specifies the desired speed, for 'speed'
%                       flight_condition
%       .CL             Specifies the desired CL, for 'CL' flight_condition
%       .Mach           Specifies the desired Mach number, for 'Mach'
%                       flight_condition
%       .h_i            %Specifies starting altitude of the segment.  If
%                       not specified, it is assumed to be the starting
%                       altitude of the previous segment
%       .h_f            %Specifies final altitude of the segment.  Required
%                       for 'descent' and 'climb' segments.  h_f can also
%                       be specified as the altitude where a given Mach and Veas
%                       limit are equivelemnt using the fn_findAltitude
%                       function (see below)
%
%       .throttle       (NOT IMPLEMENTED).  Currently climb and descent
%                       segments assume a specified TT4_climb and TT4_idle.
%       
%       .time           Length of time for various time-based segments
%       (Currently implemented - loiter.  Future implementations - cruise')
%       .range_f        Final end point of the flight segement. Required
%                       for 'cruise-climb' and 'level cruise' flight segments
%                       The starting range of any flight segment is assumed
%                       to be the end of the previous segment.
%       .profile        This option is used for 'descent' segments to
%                       determine how the profile is calculated.
%           'idle_throttle'
%                       In this case the vehicle descent profile is
%                       calculated using the power produced by the engine
%                       at a specified idle TT4 temperature (in the input
%                       file) as well as the flight condition constraint.
%
%           'fixed_angle'
%                       In this case the vehicle descent profile is fixed
%                       to a specified angle,  and the engine power is 
%                       adjusted to maintain the specified flight path as
%                       well as the speed set by the flight_condition
%                       constraint.
%       .flight_path_angle
%                       In this case where 'fixed_angle' is specified for
%                       the descent, a flight path angle must also be
%                       specified.
%
%
%   
%   INPUTS:
%   
%   The mission profile is configured in this file. The input script must
%   be run previously so the airplane data structe exists (if using
%   fn_findAltitude). 
%
%   Created by: Chris Courtin (courtin.@mit.edu)
%   Last updated: 8th March 2018
%
%   NOTES:
%   All units must be in SI units in the Mission data structure.  All unit
%   conversion should be done in this file 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Unit conversions
kts2ms  = 0.514444; %Convert kts to m/s
ft2m    = 0.3048;   %Convert ft  to m
nmi2m   = 1852.0;   %Convert nmi to m
deg2rad = pi/180;
lbf2N = 4.44822;
ADJ =1
i = 1
%TAKEOFF
Mission(i).segment_type = 'takeoff';
Mission(i).f_mission    = .9995;
Mission(i).cinc         = 1;
i = i+1
%CLIMB TO CRUISE ALTITUDE
Mission(i).segment_type     = 'climb';
Mission(i).flight_condition = 'CL';
Mission(i).CL               = .5;
Mission(i).h_i              = 10000 * ft2m;
Mission(i).h_f              = 45000 * ft2m;
Mission(i).cinc             = 24/ADJ;
i = i+1

%CRUISE 
Mission(i).segment_type     = 'level cruise';
Mission(i).flight_condition = 'Mach';
Mission(i).M_flight         = .78;
Mission(i).h_i              = 45000 * ft2m;
%Mission(i).range_f          = (1550) * nmi2m;
Mission(i).Wfuel          = (4500-789) * lbf2N;
Mission(i).constraint       = 'fixed fuel';
Mission(i).cinc             = 36/ADJ;
i = i+1

%DESCENT 
Mission(i).segment_type     = 'descent';
Mission(i).flight_condition = 'Mach';
Mission(i).M_flight         = .78;
Mission(i).profile          = 'fixed_angle';
Mission(i).flight_path_angle= -2.0 * deg2rad;
Mission(i).h_f              = fn_findAltitude([.78,280*kts2ms], 'Mach_EAS', 1000, airplane);
Mission(i).cinc             = 24/ADJ;

%LAND
Mission(i).segment_type     = 'descent';
Mission(i).flight_condition = 'speed';
Mission(i).Veas             = 280*kts2ms;
Mission(i).profile          = 'fixed_angle';
Mission(i).flight_path_angle= -3 * deg2rad;
Mission(i).h_f              = 10000 * ft2m;
Mission(i).cinc             = 24/ADJ;
