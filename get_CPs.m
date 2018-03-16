%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   CPs Helper Function
%
%   This calculates the shaft power coefficient from a given delta_CJ. 
%
%   Based on the formulation from Drela "Powered Lift and Drag Calcs" and
%   Drela "Thin Airfoil Theory for 2D Blown Airfoils"
%   
%   INPUTS
%
%   delta_CJ    The effective jet blowing coefficient
%
%   h_c         The average jet height - to - wing chord ratio
%
%   eta_p       The fan efficiency
%
%   OUTPUTS 
% 
%   CPs         Shaft power coefficient (CPs = Ps/(.5*rho*V^3*S)) 

function CPs = get_CPs(delta_CJ, h_c, eta_p)
    z1 = delta_CJ/h_c+2;
    
    CPs = h_c*(z1^(3/2)-z1^(1/2))/eta_p;
end
