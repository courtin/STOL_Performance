%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create trade space contour plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clc;
clear all; 
V_01
airplane = initialize_geometry(airplane);
segment_inputs.h_i = 0;
segment_inputs.spd_mrgn = 1.0;

draw_contour_JVL(airplane, segment_inputs)

function draw_contour_JVL(airplane, segment_inputs)
N = 4;
M = 4;

CL          = linspace(1.5, 6, N);
delta_f     = linspace(10, 40, M);

gamma       = zeros(M,N);
V_ref       = zeros(M,N);
S_lnd       = zeros(M,N);

for m = 1:M
    for n = 1:N
        airplane.aero.delta_flap_land = delta_f(m);
        [gam, V, S] = static_LA_JVL(CL(n), airplane, segment_inputs, 0);
        if imag(gam) == 0
            gamma(m,n) = gam;
        else
            gamma(m,n) = 90;
        end
           
        V_ref(m,n) = V;
        S_lnd(m,n) = S;
    end
end
figure()
[C, h] = contour(CL, delta_f, gamma);
clabel(C,h)
end

