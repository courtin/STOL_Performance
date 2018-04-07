%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   STATIC LANDING ANALYSIS 
%   
%   Calculates steady flight approach angle, speed, and landing distance
%   for a specified CL, taking jet blowing into account. 
%
%   Landing equations from:
%   http://www.dept.aoe.vt.edu/~lutze/AOE3104/takeoff&landing.pdf
%   
%   Static thrust model from:
%   http://www.dept.aoe.vt.edu/~lutze/AOE3104/thrustmodels.pdf
%   
%   Jet blowing equations from Drela papers 
%
%   OUTPUTS:
%
%   gam_ref     Flight path angle, [deg], positive up
%
%   V_ref       Approach speed [m/s]
%
%   S_lnd       Landing ground roll [m] 
%
%   INPUTS:
%   
%   
%   FUNCTIONAL DEPENDENCIES
%   int_std_atm     - atmospheric properties lookup
%   getDrag         - drag polar calculation
%
%   Created by: Chris Courtin (courtin@mit.edu)
%   Last updated: 15th March. 2018
%
%   NOTES:
%
%   All propellers are assumed to have the same diameter
%
%
%
%    Changes:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gam_ref, V_ref, S_lnd, P_shaft] = static_LA(CL, airplane, segment_inputs, verbose)
    
    W                   = airplane.current_state.weight;
    Sref                = airplane.geometry.Wing.Sref;
    
    alt_lnd             = segment_inputs.h_i;

    [~,~, rho, a] = int_std_atm(alt_lnd, airplane.sim.flight_condition);

    %Calculate CL
    CLc = airplane.aero.CL_c_max_land;
    e   = airplane.aero.Wing.e;
    AR  = airplane.geometry.Wing.AR;
    %Check unblown lift
    airplane.current_state.CJ = 0.0001;
    [a_i_inf, CL_unblown] = get_a_i_inf(airplane, 'landing');
    if CL_unblown > CL
        CJ = 0;
        a_i_inf = CL/(pi*e*AR);
    else
        fun = @(CJ) getCLresidual(CJ, CL,airplane,'landing');
        CJ = fzero(fun, 1.5);
    end
    airplane.current_state.CJ = CJ;
    [a_i_inf, CL_unblown] = get_a_i_inf(airplane, 'landing');
    fprintf(1, 'a_i_inf\tCL\tCJ\n')
    fprintf(1, '%3.2f\t%3.2f\t%3.2f\n', a_i_inf*180/pi, CL, CJ)
    %Get a_i_inf and flap deflection angle
%     a_i_inf = CL/(pi*e*AR);
%     err = 1e6;
%     err_threshold = 1e-3;
%     count = 0;
%     max_iter = 100;
%     alfa = 10;  %Approach AoA
%     if verbose
%         fprintf(1, 'Interating on CL, CJ & downwash angle...\n')
%         fprintf(1, 'iter\ta_i_inf\terr\tCL\tCJ\tCLc\n')
%     end
%     while (abs(err) > err_threshold) && (count < max_iter)
%         CLc = a_i_inf*pi*AR/2;
%         if CL < CLc
%             CJ = 0;
%         else
%             CJ = (CL-CLc)/sin(a_i_inf);
%         end
%         airplane.current_state.CJ = CJ;
%         airplane.current_state.CL = CL;
%         [a_i_new, CL] = get_a_i_inf(airplane, 'landing');
%         err = a_i_new - a_i_inf;
%         
%         a_i_inf_deg = a_i_inf*180/pi;
%         if verbose
%             fprintf(1, '%2.0f\t%2.1f\t%3.3f\t%3.2f\t%3.2f\t%3.2f\n', count,...
%                 a_i_inf, err, CL, CJ, CLc)
%         end
%         a_i_inf = a_i_new;
%         count = count + 1;
%         
%     end
    
    %Get approach angle
    gamma = 0;
    err = 1e6;
    err_threshold = 1e-3;
    count = 0;
    max_iter = 100;
    n = 1;
    if verbose
        fprintf(1, 'Interating on approach angle...\n')
        fprintf(1, 'iter\tgam\terr\tVref\tCL\tCJ\tCX\tCDp\th_dot\tn\n')
    end
    while (abs(err) > err_threshold) && (count < max_iter)
        
        
       
        V_ref = sqrt(2*W*n*cosd(gamma)/(rho*Sref*CL));
        M_ref = V_ref/a;
        [CX, DD] = blownDrag(airplane,  alt_lnd, M_ref, CL, CJ, 'landing');
        
        sing = -CX*.5*rho*V_ref^2*Sref/W;
        hdot = V_ref*sing;
        gamma_n = asind(sing);
        
        

        err = gamma-gamma_n;
        if verbose
            fprintf(1, '%2.0f\t%2.1f\t%3.3f\t%3.2f\t%2.1f\t%2.1f\t%3.2f\t%3.2f\t%3.2f\t%3.1f\n', count,...
                gamma, err, V_ref,CL, CJ, CX, DD.CDp, hdot,n)
        end
        gamma = gamma_n;
        count = count+1;
        
        if gamma_n > 89 %Hack to deal with the case where we've basically become a helicopter
            gamma = 90
            err = 0
        end
        
        
        
    end
    gam_ref = gamma;
    if verbose
        fprintf(1, 'V_ref: %3.1f Gamma_ref: %3.1f\n\n', V_ref, gamma)
    end
    [CQ, CE] = get_CQ_CE(CJ, airplane.aero.h_jet/airplane.geometry.Wing.c_ma);
    eta_f = .8;
    P_shaft = .5*rho*V_ref^3*Sref*(CE-CQ)/eta_f;
    if verbose
        fprintf(1, 'Required shaft power: %4.1f kW', P_shaft/1000);
    end
    %Get landing ground roll
    airplane.current_state.CJ = CJ;
    airplane.current_state.CL = CL;
    
    [S_lnd, V_grnd] = get_LandingDistance(airplane, segment_inputs, verbose);
end