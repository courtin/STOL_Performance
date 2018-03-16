%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Integrate aircraft performance over a single 
%mission. 
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mission_outputs, mission_history] = runSingleMission(airplane, Mission, PRINT_OUT)
    
M = numel(Mission);
mission_outputs = zeros(M, 3);
%3 is the length of the segment vector output by flight_segment not
%including the mission history 

%Configure time history array - sum of total number of all mission
%segment subsegments.  
H = 0;
for i = 1:M
    H = H + Mission(i).cinc;
end

mission_history = zeros(H, airplane.sim.sizeTimeHistory);
%14 is the dimension of the time_history vector output at each segment

fprintf(1, '\n--Start of Mission Integration--\n');

h_i = 1;
h_i_last = 1;
for i = 1:M
    fprintf(1, '\nSegment ID = %i, %s\n', i, Mission(i).segment_type);
    fprintf(1, 'Starting segment simulation.');
    segment_cinc = Mission(i).cinc;
    Wstart = airplane.weights.current;
    
    if i == 1
        Mission(i).fuel_i       = 0;
        Mission(i).time_i       = 0;
        Mission(i).distance_i   = 0;
        Mission(i).h_last       = 0;
    else
        Mission(i).fuel_i            = mission_outputs(i-1,1);
        Mission(i).time_i            = mission_outputs(i-1,2);
        Mission(i).distance_i        = mission_outputs(i-1,3);
        Mission(i).h_last            = mission_history(h_i_last+Mission(i-1).cinc-1, 4);
    end
 

    segment = flight_segment(airplane, Mission(i));

    mission_outputs(i,1) = segment.total_fuel;
    mission_outputs(i,2) = segment.total_time;
    mission_outputs(i,3) = segment.total_distance;

    mission_history(h_i:h_i+segment_cinc-1,:) = segment.time_history;
    
    airplane.weights.current = mission_history(h_i+segment_cinc-1, 14);
    
    h_i_last = h_i;
    h_i = h_i + segment_cinc;
    
    
    fprintf(1, 'done.   f_segment = %3.3f\n', airplane.weights.current/airplane.weights.MTOW);
end
nmi2m = 1852;
lbf2N = 4.4482;
if PRINT_OUT
    fprintf(1, '--Results of Mission Simulation--\n')
    fprintf(1, 'Total Range: %4.1f nmi\n', mission_outputs(M,3)/nmi2m)
    fprintf(1, 'Total Fuel Burned: %4.1f lbf\n', mission_outputs(M,1)/lbf2N)
    fprintf(1, 'Total Fuel Carried: %4.1f lbf\n', mission_outputs(M,1)/lbf2N*1.2)
    fprintf(1, 'Total Mission Time: %3.2f hrs\n', mission_outputs(M,2)/3600)
end



end