%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialize_JVL_polar runs a sweep of JVL parameters to create a lookup
%table used by JVL_drag. 
%
%   Three polars are created, for the takeoff, landing, and cruise flap
%   settings
%
%   INPUTS: 
%   
%   airplane.
%           aero.
%                config     Name of jvl file (must be in same folder 
%                           as this script)
%                alfa_max   Maximum AOA for sweep [deg]
%                alfa_min   Minimum AOA for sweep [deg]
%
%                dCJ_max    Max dCJ for sweep [-]
%                dCJ_min    Min dCJ for sweep [-]
%
%                flaps_land Landing flap setting [deg]
%                flaps_TO   Takeoff flap setting [deg]
%
%                VTAS_max   Maximum airspeed 
%                VTAS_min   Minimum airspeed 
%                                   
%
%   OUTPUTS:
%
%   airplane.
%
%   NOTES:
%
%   Created March 14th, 2018 by Chris Courtin (courtin@mit.edu)
    
function [airplane] = initialize_JVL_polar(airplane)
    
    A = 20;
    alfas = linspace(airplane.aero.alfa_min, airplane.aero.alfa_max, A);
    
    C = 20;
    dCJs  = linspace(airplane.aero.dCJ_min, airplane.aero.dCJ_max, C);
    
    V = 20;
    VTASs = linspace(airplane.aero.VTAS_min, airplane.aero.VTAS_max, V);
    
    %Quantities to calculate
    CLcir = zeros(A,C,V);
    CLjet = zeros(A,C,V);
    CLtot = zeros(A,C,V);
    CXtot = zeros(A,C,V);
    CDind = zeros(A,C,V);
    CDjet = zeros(A,C,V);
    
    
    
    
    
end