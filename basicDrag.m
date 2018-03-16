%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   BASIC DRAG MODULE
%
%   This estimates drag from a simple wetted area calculation and component
%   buildup, and parabolic induced drag model. 
%
%   All drag coefficients are referenced based on the wing reference area
%   Sref
%
%   OUTPUTS:
%
%   Params      CD_total        Float giving the total drag on the aircraft
%                               at the specified flight condition; this     
%               Drag_Decomp     Structure containing any other relevant
%                               drag values calculated in the buildup of CD_total 
%                           .CDi        Induced drag coefficient
%                           .CDp        Total profile drag coefficient
%   INPUTS:
%   
%   airplane    High-level airplane data structure.  Must contain the
%               following sub-variables. 
%               .geometry
%                        .Wing
%                             .AR                Main wing aspect ratio 
%                             .Sref              Main wing reference area
%                             .Swet              Main wing wetted area
%               .aerodynamics
%                           .Wing
%                                .e              Main wing span efficiency
%             
%
%   alt         Operating altitude (m) 
%   M           Operating Mach number (-) 
%   CL          Operating lift coefficient (-)
%
%
    
function [CD_total, Drag_Decomp] = basicDrag(airplane, alt, M, CL, config)
    %Variables
    AR = airplane.geometry.Wing.AR;
    e  = airplane.aero.Wing.e;
    %Profile drag
    CDp = getProfileDrag(airplane, alt, M, config);
    
    %Induced drag
    CDi = 1/(pi*e*AR) * CL^2;
    CD_total = CDp + CDi;
    
    Drag_Decomp.CDi = CDi;
    Drag_Decomp.CDp = CDp;
end