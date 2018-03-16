%Landing
N2lbf = .2248;
CD = 1.831;
CL = 7.224;
CJ = 36.22;
CE = 115.7;
CQ = 2.835;

P  = 268.3;
T  = 4143; %N
V  = 34.07*.5144;
W  = 9812; %N
S_ref_ftsq = 77.61;
S_ref  = S_ref_ftsq*.3048^2;
rho = 1.225;

h = .3163; %m
c = 2.339; %m
eta = .9;
CPs = get_CPs(CJ, h/c, eta);
P_req = CPs*.5*rho*V^3*S_ref;

P_req_2 = .5*rho*V^3*S_ref*(CE-CQ)/eta;
D = .5*rho*V^2*S_ref;

sing = (T-D)/W;
gamma = asind(sing);

fprintf(1, 'Approach angle (positive up): %3.1f\n', gamma)
fprintf(1, 'Wing loading: %4.2f lbs/ft^2\n', W*N2lbf/S_ref_ftsq)
fprintf(1, 'T/W: %3.2f\n', T/W)
fprintf(1, 'L/D: %3.2f\n', CL/CD)

