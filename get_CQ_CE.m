%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   get_CQ_CE
%
%   Calculated CQ and CE from CJ  and h/c
%
%   Assumes low speed flow (no density effects) 
%
%   OUTPUTS:
%
%       CQ        
%       CE            
%   INPUTS:
%   
%       CJ
%       h_c
%
    
function [CQ, CE] = get_CQ_CE(CJ, h_c)
   Vj_Vinf = sqrt(CJ./h_c);
   CE = h_c.*Vj_Vinf.^3;
   CQ = h_c.*Vj_Vinf;
end