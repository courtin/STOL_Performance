function a_i_inf = get_a_i_inf(airplane, config)
lambda = .5;
%From http://rspa.royalsocietypublishing.org/content/251/1266/407
%Assumes lambda = .5 is a reasonable value, and alfa << tau (flap
%deflection on landing
switch config
    case 'landing'
        a_i_inf = airplane.aero.beta_flap_land * lambda;
    case 'clean'
        a_i_inf = 2*airplane.current_state.CL/(pi*airplane.geometry.Wing.AR...
            *airplane.aero.Wing.e);
end
end