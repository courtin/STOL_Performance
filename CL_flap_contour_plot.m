%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create trade space contour plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clc;
clear all; 
V_02
airplane = initialize_geometry(airplane);
airplane.aero.h_jet = .25;
segment_inputs.h_i = 0;
segment_inputs.spd_mrgn = 1.2;

airplane.sim.downwash_mode = 3;
draw_contour(airplane, segment_inputs)

function draw_contour(airplane, segment_inputs)
N = 30;
M = 30;

CL          = linspace(1.5, 10, N);
delta_f     = linspace(10, 90, M);

gamma       = zeros(M,N);
V_ref       = zeros(M,N);
S_lnd       = zeros(M,N);
P_shaft     = zeros(M,N);

for m = 1:M
    for n = 1:N
        airplane.aero.delta_flap_land = delta_f(m);
        [gam, V, S, P_shaft] = static_LA(CL(n), airplane, segment_inputs, 0);
        if imag(gam) == 0
            gamma(m,n) = gam;
        else
            gamma(m,n) = 90;
        end
        
        if imag(gam) == 0
            P_shaft(m,n) = P_shaft/1000;
        else
            P_shaft(m,n) = 0.0;
        end
           
        
        V_ref(m,n) = V;
        S_lnd(m,n) = S;
    end
end
figure()
[C, h] = contour(CL, delta_f, gamma);
clabel(C,h)
xlabel('CL')
ylabel('\delta_{flap}')
title('Contours of \gamma_{FP}')

figure()
[C, h] = contour(CL, delta_f, P_shaft);
clabel(C,h)
xlabel('CL')
ylabel('\delta_{flap}')
title('Contours of \P_{shaft}')
end

