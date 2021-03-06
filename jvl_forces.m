function [CXtot, CJet, Drag_Decomp] = jvl_forces(CL, airplane, segment_inputs, verbose)
    config = airplane.sim.jvl_input_file;
    [CDp, Drag_Decomp] = getProfileDrag(airplane, segment_inputs.h_i, airplane.current_state.M, 'landing');
    Drag_Decomp.CDp = CDp;
    switch config
        case 'h_wing'
            filename = jvl_run_CL(config, 10, CL, airplane.aero.delta_flap_land, CDp);
        case 'V01_mod'
            filename = jvl_run_CL_V01(config, 12, CL, airplane.aero.delta_flap_land, CDp);
    end
    [CJet, CJtot, CXtot, CYtot, CZtot, CLtot, CDtot,CLcir, CLjet, CDind, ...
    CDjet, CDvis] = readJVL(filename);
    CXtot = CXtot*-1;   %Flip sign due to JVL definition 
end