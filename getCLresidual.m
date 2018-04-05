function R = getCLresidual(CJ, CL_target, airplane, config)
    airplane.current_state.CJ = CJ;
    if CJ < 0
        CJ = 0;
    end
    [a_i_inf, CL] = get_a_i_inf(airplane, config);
    R = CL-CL_target;

end