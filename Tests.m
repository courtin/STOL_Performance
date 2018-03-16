%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   STOL AIRCRAFT SIMULATION 
%   VERSION 0.1: PERFORMANCE BASED ON FIXED MISSION, SIMPLE ENGINE MODEL, AND
%   PARABOLIC DRAG BUILDUP
%   
%   Test for various individual code elements
%
%   Created by: Chris Courtin (courtin@mit.edu)
%   Last updated: 8th March. 2018
%  
%
%    Changes:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all;
clc;

%Test aircraft Input Script
TEST_INPUT

%Initialize test aircraft geometry
airplane = initialize_geometry(airplane);

%%%%%%%%%%%
%Drag Tests
%%%%%%%%%%%
CL  = zeros(25,10);
CD  = zeros(25,10);
L_D = zeros(25,10);
M   = zeros(10);
figure();
xlabel("C_D")
ylabel("C_L")
hold on


for j = 1:10
    for i = 1:25
        M(j) = .5*(j);
        CL(i,j) = .5*i;
        CD(i,j) = getDrag(airplane, 0, M(j), CL(i));
        L_D(i,j) = CL(i)/CD(i);
    end
    plot(CD(:,j), CL(:,j))
end    

figure()
plot(CL(:, 4), L_D(:,4));
xlabel("C_L");
ylabel("L/D");


%%%%%%%%%%%%%%%%%
%Landing distance
%%%%%%%%%%%%%%%%%

%Test landing scenario
landing_inputs.h_i          = 0.0;   %Sea level landing
landing_inputs.spd_mrgn     = 1.3;  %ASTM landing speed safety margin

get_LandingDistance(airplane, landing_inputs, 1)

%%%%%%%%%%%%%%%%%%%%%%%%%
%Landing takeoff distance
%%%%%%%%%%%%%%%%%%%%%%%%%

%Test landing scenario
takeoff_inputs.h_i          = 0.0;   %Sea level landing
takeoff_inputs.h_obstacle   = 50    *ft2m; %Obstacle clearance height
get_TakeoffDistance(airplane, takeoff_inputs, 1)
