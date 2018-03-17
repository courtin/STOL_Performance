function [gam_ref, V_ref, S_lnd] = static_LA_JVL(CL, airplane, segment_inputs, verbose)
    fprintf(1, '---Approach Performance---\n')
    W                   = airplane.current_state.weight;
    Sref                = airplane.geometry.Wing.Sref;
    
    alt_lnd             = segment_inputs.h_i;

    [~,~, rho, a] = int_std_atm(alt_lnd, airplane.sim.flight_condition);

    %Calculate CL
    CLc = airplane.aero.CL_c_max_land;
    e   = airplane.aero.Wing.e;
    AR  = airplane.geometry.Wing.AR;

    
    gamma = 0;
    err = 1e6;
    err_threshold = 1e-3;
    count = 0;
    max_iter = 100;
    n = 1;
    if verbose
        fprintf(1, 'Iterating on approach angle...\n')
        fprintf(1, 'iter\tgam\terr\tVref\tCL\tCJ\tCX\tCDp\th_dot\tn\n')
    end
    while (abs(err) > err_threshold) && (count < max_iter)
        
        V_ref = sqrt(2*W*n*cosd(gamma)/(rho*Sref*CL));
        M_ref = V_ref/a;
        airplane.current_state.M = M_ref;
        [CX, CJ, DD] = jvl_forces(CL, airplane, segment_inputs, 0);
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
        
        
        
    end
    gam_ref = gamma;
    if verbose
        fprintf(1, 'V_ref: %3.1f Gamma_ref: %3.1f\n\n', V_ref, gamma)
    end
    [CQ, CE] = get_CQ_CE(CJ, airplane.aero.h_jet/airplane.geometry.Wing.c_ma);
    eta_f = .8;
    P_shaft = .5*rho*V_ref^3*Sref*(CE-CQ)/eta_f;
    fprintf(1, 'Required shaft power: %4.1f kW', P_shaft/1000);
    
    airplane.current_state.CJ = 0;
    airplane.current_state.CL = CL;
    [S_lnd, V_grnd] = get_LandingDistance(airplane, segment_inputs, verbose);
end