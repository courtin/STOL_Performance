%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   GEOMETRY INITIALIZATION 
%
%   This module initializes the geometry of the vehicle, and calculates
%   dependent wetted areas, chord lengths, etc.  This geometry is stored
%   for use in subsequent drag/structure predictions. 
%
%
%   This method uses the wing parameterization from TASOPT
%   (http://web.mit.edu/drela/Public/N+3/Final_Report_App.pdf), but without
%   the provision for a planform break (i.e. for a single taper/swept wing). 
%
%   Simple wetted area estimate from 
%   http://adl.stanford.edu/sandbox/groups/aa241x/wiki/e054d/attachments/31ca0/performanceanddrag.pdf
%
%
%   
%
%   OUTPUTS:
%
%   Params      airplane                  High-level data structure.  The
%                                         followin variables are added by 
%                                         this function. 
%                       .Wing
%                           .Swet              Main wing wetted area
%                           .b                 Main wing total span
%                           .co                Wing root chord
%                           .ct                Wing tip chord
%                           .c_ma              Wing mean aero. chord
%                       .Htail
%                           ...same parameters as wing
%                       .Vtail
%                           ...same parameters as wing
%
%
%   INPUTS:
%   
%   airplane    High-level airplane data structure.  Must contain the
%               following sub-variables. 
%               .geometry
%                        .Wing
%                             .AR                Main wing aspect ratio 
%                             .Sref              Main wing reference area
%                             .lambda            Taper ratio
%                             .eta_0             Root chord offset (should
%                                                be 0 for high wing)
%                             .t_c_avg           Avg. thickness to chord
%                                                ratio
%                       .Htail
%                             .AR                Htail aspect ratio 
%                             .S                 Reference area
%                             .lambda            Taper ratio
%                             .eta_0             Root chord offset (should
%                                                be 0 for high wing)
%                             .t_c_avg           Avg. thickness to chord
%                                                ratio
%                        .Vtail
%                             .AR                Htail aspect ratio 
%                             .S                 Reference area
%                             .lambda            Taper ratio
%                             .eta_0             Root chord offset (should
%                                                be 0 for high wing)
%                             .t_c_avg           Avg. thickness to chord
%                                                ratio
%                             
%
%   Created by: Chris Courtin (courtin@mit.edu)
%   Last updated: 9th March. 2018
%
%   NOTES:
%
%   Changes:


function airplane = initialize_geometry(airplane)
    % Main wing
    [airplane.geometry.Wing.b, ...
        airplane.geometry.Wing.co,...
        airplane.geometry.Wing.c_ma,...
        airplane.geometry.Wing.ct,...
        airplane.geometry.Wing.Swet] = wing_geom(...
        airplane.geometry.Wing.AR,...
        airplane.geometry.Wing.Sref,...
        airplane.geometry.Wing.lambda,...
        airplane.geometry.Wing.t_c_avg,...
        airplane.geometry.Wing.eta_0);
    % Htail
    [airplane.geometry.Htail.b, ...
        airplane.geometry.Htail.co,...
        airplane.geometry.Htail.c_ma,...
        airplane.geometry.Htail.ct,...
        airplane.geometry.Htail.Swet] = wing_geom(...
        airplane.geometry.Htail.AR,...
        airplane.geometry.Htail.S,...
        airplane.geometry.Htail.lambda,...
        airplane.geometry.Htail.t_c_avg,...
        airplane.geometry.Htail.eta_0);
    % Vtail
    [airplane.geometry.Vtail.b, ...
        airplane.geometry.Vtail.co,...
        airplane.geometry.Vtail.c_ma,...
        airplane.geometry.Vtail.ct,...
        airplane.geometry.Vtail.Swet] = wing_geom(...
        airplane.geometry.Vtail.AR,...
        airplane.geometry.Vtail.S,...
        airplane.geometry.Vtail.lambda,...
        airplane.geometry.Vtail.t_c_avg,...
        airplane.geometry.Vtail.eta_0);

    
end

function [b, co, c_ma, ct, Swet] = wing_geom(AR, S, lambda, t_c, eta_0)
    b       = sqrt(AR*S);
    Kc      = eta_0 + .5*(1+lambda)*(1-eta_0);
    co      = S/(b*Kc);
    Kcc     = eta_0 + (1./3.)*(lambda^2 + lambda + 1)*(1-eta_0);
    c_ma    = Kcc/Kc*co;
    ct      = co*lambda;
    Swet    = S*2.*(1+.2*t_c);
end