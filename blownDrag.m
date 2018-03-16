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
    
function [CX, Drag_Decomp] = blownDrag(airplane, alt, M, CL, CJ, config)
    %Variables
    AR = airplane.geometry.Wing.AR;
    e  = airplane.aero.Wing.e;
    h  = airplane.aero.h_jet;
    c   = airplane.geometry.Wing.c_ma;
    
    %Profile drag
    [CDp, DD] = getProfileDrag(airplane, alt, M, config);
    airplane.current_state.CL = CL;
    a_i_inf = get_a_i_inf(airplane, config);
    Drag_Decomp.CDp = CDp;
    
    [CQ, CE] = get_CQ_CE(CJ, h/c);
    CX = CL.^2/(pi*e*AR) - CJ*cosd(a_i_inf) + 2.*CQ + CDp;
    
end