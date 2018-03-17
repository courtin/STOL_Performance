%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Estimates the far-field jet flow turning angle
%
%Three modes of operation:
%   1: a_i_inf = a_i    
%   2: a_i_inf = flap deflection angle
%   3: a_i_inf estimated via method from 
%   http://rspa.royalsocietypublishing.org/content/251/1266/407
%
%   1 doesn't account for any jet turning due to the flap; overly
%       pessimistic
%
%   2 doesn't account for any possible separation or jet curvature due to
%       the pressure field - overly optimistic
%
%   3 accounts for jet angle and jet bending but assumes small angles and
%   some handbook assumptions; questionably applicable to large flap
%   deflections
%
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a_i_inf = get_a_i_inf(airplane, config)

mode = airplane.sim.downwash_mode;
switch config
    case 'clean' %If clean, use normal downwash approximation in all modes
        a_i_inf = 2*airplane.current_state.CL/(pi*airplane.geometry.Wing.AR...
                *airplane.aero.Wing.e);
    case 'landing'
        if mode == 2  %If landing in mode, use the flap angle 
            a_i_inf = airplane.aero.delta_flap_land;
        elseif mode == 3  %If landing in mode 3, use the jet flap theory formulation
            tau = airplane.aero.delta_flap_land*pi/180;
            AR  = airplane.geometry.Wing.AR;
            t_c = airplane.geometry.Wing.t_c_avg;
            CJ  = airplane.current_state.CJ;
            dCLdt = 2*sqrt(pi*CJ)*sqrt(1+.151*sqrt(CJ )+.139);
            dCLda = 2*pi*(1+.151*sqrt(CJ) + .219*CJ);
            alfa = 10*pi/180;   %Assumes some constant alfa_flight near unblown stall
            CL2 = (1+t_c)*(tau*dCLdt+(alfa)*dCLda)-(t_c*(tau+alfa)*CJ);
            a_i_inf = (2/pi)*CL2/(AR+(2/pi)*dCLda-2);
            lambda = a_i_inf/(alfa + tau);
            a_i_inf = a_i_inf*180/pi;
        end
end
end