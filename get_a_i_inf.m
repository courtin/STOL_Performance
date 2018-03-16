function a_i_inf = get_a_i_inf(airplane, config)
%From http://rspa.royalsocietypublishing.org/content/251/1266/407
%Assumes lambda = .5 is a reasonable value, and alfa << tau (flap
%deflection on landing
switch config
    case 'landing'
        %a_i_inf = airplane.aero.beta_flap_land * lambda;
        tau = airplane.aero.delta_flap_land*pi/180;
        AR  = airplane.geometry.Wing.AR;
        t_c = airplane.geometry.Wing.t_c_avg;
        CJ  = airplane.current_state.CJ;
        %CL  = airplane.current_state.CL;
        dCLdt = 2*sqrt(pi*CJ)*sqrt(1+.151*sqrt(CJ )+.139);
        dCLda = 2*pi*(1+.151*sqrt(CJ) + .219*CJ);
        alfa = 10*pi/180;
        CL2 = (1+t_c)*(tau*dCLdt+(alfa)*dCLda)-(t_c*(tau+alfa)*CJ);
        a_i_inf = (2/pi)*CL2/(AR+(2/pi)*dCLda-2);
        lambda = a_i_inf/(alfa + tau);
        a_i_inf = a_i_inf*180/pi;
        
    case 'clean'
        a_i_inf = 2*airplane.current_state.CL/(pi*airplane.geometry.Wing.AR...
            *airplane.aero.Wing.e);
end
end