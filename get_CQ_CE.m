%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   CQ, CE Helper function
%
%   Calculated CQ and CE from CJ  and h/c
%
%   Based on the formulation from Drela "Powered Lift and Drag Calcs" and
%   Drela "Thin Airfoil Theory for 2D Blown Airfoils"
%
%   Assumes low speed flow (no density effects) 
%
%   OUTPUTS:
%
%       CQ  Jet mass flow coefficient      
%       CE  Jet energy flow coefficient
%
%   INPUTS:
%   
%       CJ Jet momentum flow coefficient
%       h_c Jet thickness/chord ratio
%
    
function [CQ, CE] = get_CQ_CE(CJ, h_c)
   Vj_Vinf = sqrt(CJ./(2*h_c));
   CE = h_c.*Vj_Vinf.^3;
   CQ = h_c.*Vj_Vinf;
end