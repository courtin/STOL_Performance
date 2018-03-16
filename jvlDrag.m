%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   JVL DRAG MODULE
%
%   This estimates drag from a simple wetted area calculation and component
%   buildup, with induced drag provided by JVL. 
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
%               .aero
%                           .Wing
%                                .e              Main wing span efficiency
%                          config           Name of jvl file (must be in same folder 
%                                           as this script)
%             
%   
%   alt         Operating altitude (m) 
%   M           Operating Mach number (-) 
%   CL          Operating lift coefficient (-)
%   CJ          Operating jet blowing coefficient (-) 
%
    
function [CD_total, Drag_Decomp] = jvlDrag(airplane, alt, M, CL, CJ,flap_setting)
    %Variables
    AR = airplane.geometry.Wing.AR;
    e  = airplane.aero.Wing.e;
    %Profile drag
    CDp = getProfileDrag(airplane, alt, M);
    
    %Call JVL
    [fileout] = jvl_run(airplane.aero.config,CL, 'CL',flap_setting,CJ,1,1,1);
    [CJtot, CXtot, CYtot, CZtot, CLtot, CDtot,CLcir, CLjet, CDind, ...
    CDjet, CDvis] = readJVL(fileout);
    Drag_Decomp.CJtot = CJtot;
    Drag_Decomp.CXtot = CXtot;
    Drag_Decomp.CYtot = CYtot;
    Drag_Decomp.CZtot = CZtot;
    Drag_Decomp.CLtot = CLtot;
    Drag_Decomp.CDtot = CDtot;
    Drag_Decomp.CLcir = CLcir;
    Drag_Decomp.CLjet = CLjet;
    Drag_Decomp.CDind = CDind;
    Drag_Decomp.CDjet = CDjet;
    Drag_Decomp.CDvis = CDvis;
    
    %Induced drag
    CDi = 1/(pi*e*AR) * CL^2;
    CD_total = CDp + CDi;
    
    Drag_Decomp.CDi = CDi;
    Drag_Decomp.CDp = CDp;
end