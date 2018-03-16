% Evaluate a flight segment for a given distance 
%
% Fuel consumption and powertrain performance is calculated in terms of power
% balance equations, taking BLI into account.  Currently the BLI calculations
% assume that only a specified fraction of the fuselage boundary layer is
% ingested.
%
% Usage: segment = 
%            cruise_segment(airplane, segment_inputs)
%
% Inputs:   airplane                    airplane data structure
%           segment_inputs              data structure containing inputs, 
%                                       may vary by type of segment
%               .flight_condition       Determines what drives the vehicle
%                                       speed
%                   'speed'             Fixed EAS
%                   'CL'                Fixed CL/AoA
%                   'Mach'              Fixed Mach number
%
%               .segment_type           Determines the type of segment
%                   'climb'             Max rate climb for a given
%                                       throttle setting
%                   'cruise-climb'      Cruise-climb, maintaining constant
%                                       CL 
%                   'level cruise'      Cruise at a constant altitude and
%                                       airspeed
%                   'descent'           Descent at constant angle 
%
%                   'fixed'             Returns a fuel burn based on a
%                                       fixed weight fraction
%                   'loiter'          Loiter for a specified time or fuel
%                                       (NOT IMPLEMENTED)
%                   'takeoff'          Takeoff distance/time
%                                      
%                   'landing'          Landing distance/time
%                                      
%               .CL                     Vehicle CL, required if
%                                       flight_condition = 'CL'
%               .Veas                   Target equivalent airspeed,
%                                       required if flight_condition =
%                                       'speed'
%               .M_flight               Target Mach number, required if
%                                       flight_condition = 'Mach'
%               .h_i                    Initial altitude
%               .h_f                    Final altitude, required if
%                                       different from h_i
%               .constraint             Sets end condition for cruise
%                                       segments
%                   'fixed fuel'        Computes range for a given fuel
%                                       volume
%                   'fixed range'       Computes fuel required for a given
%                                       range
%               
%               .range_f                Target range, required if
%                                       constraint = 'fixed range'
%               .range_i                Initial range, required if
%                                       constraint = 'fixed range'
%               .Wfuel                  Fuel weight , required if
%                                       constraint = 'fixed fuel'
%               .f_mission              Mission fuel weight fraction,
%                                       W_final/WMTO, required if
%                                       segment_type = 'fixed'
%               .throttle               Segment throttle setting
% 
%          
% Outputs:  segment            a structure containing the following fields:
%           total_fuel         fuel burned in segment, kg
%           total_energy       stored energy used in segment, J
%           total_time         time of segment, sec
%           total_distance     horizontal distance covered, m
%           time_history       a matrix with the step-by-step 
%                      values from the start to the end of the loiter.
%                      The fields are:
%
%              [fuel  energy time  distance  h  roc  VEAS  VTAS Mach CL P_req P_avail SFC fuel_flow W] 
%              |  1     1      1      1   1    1      1    1   1   1       1    1      1     1      1|
%              |fuel  energy time  distance  h  roc  VEAS  VTAS Mach CL P_req P_avail SFC fuel_flow W|
%              |  2     2      2      2   2    2      2    2   2   2       2    2      2     2      2|
%              |  :     :      :      :   :    :      :    :   :   :       :    :      :     :      :|
%              |  :     :      :      :   :    :      :    :   :   :       :    :      :     :      :|
%              |  :     :      :      :   :    :      :    :   :   :       :    :      :     :      :|
%              |fuel  energy time  distance  h  roc  VEAS  VTAS Mach CL P_req P_avail SFC fuel_flow W       |
%              [  m    m      m       m      m   m    m      m    m   m   m       m    m      m     m]
%                                                          
%                kg    J      s       m      m  m/s  m/s    m/s   -   -   W       W   kg/s   kg     N
%           
function segment = flight_segment(airplane, segment_inputs)
%Number of steps
cinc = segment_inputs.cinc;

%Extract current weight,wing area, and other variables
W               = airplane.weights.current;
g               = airplane.environment.gc;
S               = airplane.configuration.S;
no_of_engines   = airplane.Engine.Geo.nENG;

rho0            = airplane.environment.rho0;

fBLIf            = airplane.Engine.K.fBLIf;
fWakef           = airplane.aero.fWakef;

%Extract data from segment_inputs
segment_type        = segment_inputs.segment_type;
flight_condition    = segment_inputs.flight_condition;
%throttle            = segment_inputs.throttle;



%Read in required variables for the different types of flight segments
switch segment_type
    case 'takeoff'
        alt_to   = segment_inputs.h_i
    case 'climb'
     
        %Read in relevant climb parameters
        %Evenly space altitude between desired initial and final altitude
        alt_i    = segment_inputs.h_i;
        alt_f    = segment_inputs.h_f;
        

        alt = linspace(alt_i, alt_f, cinc+1);
        
    case 'cruise-climb'
        %Initially start with constant altitude, will be recalcualted later
        alt_i    = segment_inputs.h_i;
        alt     = ones(1, cinc+1).*alt_i;
        
        switch segment_inputs.constraint
            case 'fixed range'
                range_i = segment_inputs.distance_i;
                range_f = segment_inputs.range_f;
                range = range_f-range_i;
            case 'fixed fuel'
                m_fuel = segment_inputs.Wfuel/airplane.environment.gc;
        end

    case 'level cruise'
        alt_c   = segment_inputs.h_i;
        alt     = ones(1, cinc+1).*alt_c;
                
        switch segment_inputs.constraint
            case 'fixed range'
                range_i = segment_inputs.distance_i;
                range_f = segment_inputs.range_f;
                range = range_f-range_i;
            case 'fixed fuel'
                m_fuel = segment_inputs.Wfuel/airplane.environment.gc;
        end
        
    case 'descent'
        if isempty(segment_inputs.h_i)
            alt_i = segment_inputs.h_last;
            alt_f = segment_inputs.h_f;
        else
            alt_i = segment_inputs.h_i;
            alt_f = segment_inputs.h_f;
        end
        alt = linspace(alt_i, alt_f, cinc+1);
    
    case 'loiter'
        %If specified, use h_i. Otherwise use final altitude of previous
        %segment
        if isfield(segment_inputs, 'h_i')
            alt_i = segment_inputs.h_i;
        else
            alt_i = segment_inputs.h_last;
        end
        
        alt = ones(1, cinc+1).*alt_i;
        loiter_time = segment_inputs.time;
end



%Determine aux. power requirements
Paux = airplane.system.power/airplane.system.eta_gen;

%Initialize time history
time_history = zeros(cinc, airplane.sim.sizeTimeHistory);

%Initialize segment variables
segment_time        = segment_inputs.time_i;
segment_energy      = segment_inputs.energy_i;
segment_fuel        = segment_inputs.fuel_i;
segment_distance    = segment_inputs.distance_i;

%Assume always using forward integration, different k0 and kfac values for
%backward
k0      = 0;
kfac    = 1;
%If weight fraction is fixed, use that
if strcmp(segment_type,'fixed fraction')
    W_final = W*segment_inputs.f_mission;
    segment_fuel = W-W_final;
    time_history(1, 2) = segment_fuel;
    time_history(1, 14) = W_final;
elseif strcmp(segment_type,'fixed weight')
    W_final = W - segment_inputs.delta_Wfuel;
    segment_fuel = W-W_final;
    time_history(1, 2) = segment_fuel;
    time_history(1, 14) = W_final;
elseif strcmp(segment_type, 'takeoff')
    %%CALL TO HERE%%
else
    %Otherwise, integrate the flight segment
    for kk = 1:cinc
        fprintf('.');
        k = k0 + kfac*kk; %Integration direction (assumed always forward)

        %Get atmospheric parameters
        [~, ~, sigma, a] = getIntStdAtmo(alt(k), airplane.sim.flight_condition);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Set flight path angle
        %Cruise-climb or descent are only segment that calculate explicitly using
        %flight path angle.
        %Climb segments calculate flight path angle based on available
        %power
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        gamma_FP = 0;
        cosg = 1;
        sing = 0;        
        
        switch segment_type
            case 'cruise-climb'
                if k > 1
                    switch segment_inputs.constraint
                        case 'fixed range'
                            %Calculate flight path angle
                            gamma_FP = atan((alt(k)-alt(k-1))/(range/cinc));
                            gamma_FP*180/pi;
                            cosg = cos(gamma_FP);
                            sing = sin(gamma_FP);
                        case 'fixed fuel'
                            %Calculate flight path angle
                            gamma_FP = atan((alt(k)-alt(k-1))/((time_history(k,3)-time_history(k-1,3))/cinc));
                            gamma_FP*180/pi;
                            cosg = cos(gamma_FP);
                            sing = sin(gamma_FP);
                    end
                end
            case 'descent'
                switch segment_inputs.profile
                    case 'idle_throttle'
                        gamma_FP = 0;
                        cosg = 1;
                        sing = 0;
                    case 'fixed_angle'
                        gamma_FP = segment_inputs.flight_path_angle;
                        cosg = cos(gamma_FP);
                        sing = sin(gamma_FP);
                end
        end

        %%%%%%%%%%%%%%%%%
        %Set speed and CL
        %%%%%%%%%%%%%%%%%
        %Determine flight condition
        switch flight_condition

            case 'speed'
              %Take given Veas input, compute CL  
              Veas = segment_inputs.Veas;
              Vtas = Veas/sqrt(sigma);
              CL = (W*cosg/S)/(0.5*rho0*Veas^2);
              M_flight = Vtas/a;

            case 'Mach'
              %Take given Mach input, compute CL
              M_flight = segment_inputs.M_flight;
              Vtas = a * M_flight;
              Veas = Vtas * sqrt(sigma);
              CL = (W*cosg/S)/(0.5*rho0*Veas^2);

            case 'CL'
              %Take given CL, computer Veas
              CL = segment_inputs.CL;
              Veas = sqrt(W*cosg/S/(0.5*rho0*CL));
              Vtas = Veas/sqrt(sigma);
              M_flight = Vtas/a;

        end


        %%%%%%%%%%%%%%%%%%
        %Get Power and SFC
        %%%%%%%%%%%%%%%%%%
        %Determine initial CD
        [CD_tot, CDp_fuse] = getDrag(airplane, alt(k), M_flight, CL);
        
        %Calculate dynamic pressure
        q_bar = .5*rho0*Veas^2;
%          if strcmp(segment_type, 'cruise-climb')
%                CD_tot = CL/17.5;
%         end
        %Calculate required and available power
        D = CD_tot*q_bar*S+ W*sing;
     
        
        %Incorporate any BLI effects of fuselage mounted engines
        PT = D*Vtas - fBLIf*fWakef*CDp_fuse*q_bar*S*Vtas;
%          if strcmp(segment_type, 'cruise-climb')
%                P_loating_LD(k) = PT
%         end
         %Get Max Engine performance
         [PT_max_per_engine, PSFC_max, T04_max] = getpropulsor_performance(airplane.Engine,...
             alt(k), M_flight,'T04spec', airplane.Engine.Tt4_max_climb, '', '','');
          
         PT_max = PT_max_per_engine*no_of_engines;

        switch segment_type
            case 'climb'
                    %Find fuel burn rate by determining the sfc for the altitude and power
                    %setting, and multiplying by max power, which is limited by 'throttle'
                    %input to fn_getPropulsion
%                 [PT_max, PSFC_max] = getpropulsor_performance_DUMMY(airplane.Engine,alt(k), M_flight,  ...
%             'T04spec', airplane.Engine.Tt4_max_climb, 1, 1, 1);
                %Get Required Engine Performance
                [PT_out_per_engine, PSFC, T04_spec] = getpropulsor_performance(airplane.Engine,...
                    alt(k), M_flight,'Fspec', (PT/Vtas)/no_of_engines, '', '','');
                PSFC = PSFC_max;
                
                fuel_burn_rate = PSFC .* PT_max/3600;  %N/sec
                T04 = T04_max;
                %Power available is max available flow power, less shaft power required to run aux. systems
                %Rate of climb is difference between available and required
                %power, over aircraft weight.
                roc = (PT_max - Paux - PT)/W;
                gamma_FP = asin(roc/Vtas);
                %Time step is set by time required to climb through a given
                %altitude delta
                time_step = abs(alt(k+kfac)-alt(k))/abs(roc);
                
            case 'cruise-climb'
                %Get Required Engine Performance
                [PT_out_per_engine, PSFC, T04] = getpropulsor_performance(airplane.Engine,...
                    alt(k), M_flight,'Fspec', (PT/Vtas)/no_of_engines, '', '','');
                
                fuel_burn_rate = PSFC .* PT/3600;  %N/sec
                roc = Vtas*sin(gamma_FP);
                
                
                switch segment_inputs.constraint
                    case 'fixed range'
                        time_step = (range/cinc)/Vtas;
                    case 'fixed fuel'
                        time_step = (m_fuel*airplane.environment.gc/cinc)/fuel_burn_rate;
                end
                
            case 'level cruise'
                %Get Required Engine Performance
                [PT_out_per_engine, PSFC, T04] = getpropulsor_performance(airplane.Engine,...
                    alt(k), M_flight,'Fspec', (PT/Vtas)/no_of_engines, '', '','');
                %Fuel burn rate, assuming level flight with aux systems running
                fuel_burn_rate = PSFC .* PT/3600;% N/sec

                roc = 0;

                %Determine time step either by fuel burn or distance traveled
                switch segment_inputs.constraint
                    case 'fixed range'
                        time_step = (range/cinc)/Vtas;
                    case 'fixed fuel'
                        time_step = (m_fuel*airplane.environment.gc/cinc)/fuel_burn_rate;
                end
                
            case 'descent'
                switch segment_inputs.profile
                    case 'idle_throttle'
                        [PT_out_per_engine, PSFC, T04] = getpropulsor_performance(airplane.Engine,...
                            alt(k), M_flight,'T04spec', airplane.Engine.Tt4_idle, '', '','');

                        PT = PT_out_per_engine*no_of_engines;
                        %IGNORE ANY ENGINE POWER - ASSUMING GLIDING FLIGHT
                        %(NEED TO FIX)
                        %PT = 0;
                        tang = -(CD_tot-(PT/(.5*Veas^3*rho0*S)))/CL;
                        gamma_FP = atan(tang);
                        roc = Vtas*sin(atan(tang));
                        %roc_FPM = roc/.00508;
                        time_step = abs(alt(k+kfac)-alt(k))/abs(roc);
                        fuel_burn_rate = PSFC .* PT/3600;
                        
                    case 'fixed_angle'
                        %Get Required Engine Performance
                        [PT_out_per_engine, PSFC, T04] = getpropulsor_performance(airplane.Engine,...
                            alt(k), M_flight,'Fspec', (PT/Vtas)/no_of_engines, '', '','');
                        %Fuel burn rate, assuming level flight with aux systems running
                        fuel_burn_rate = PSFC .* PT/3600;% N/sec

                        roc = Vtas*sing;
                        time_step = abs(alt(k+kfac)-alt(k))/abs(roc);
                    
                end
                
            case 'loiter'
                %Get Required Engine Performance
                [PT_out_per_engine, PSFC, T04] = getpropulsor_performance(airplane.Engine,...
                    alt(k), M_flight,'Fspec', (PT/Vtas)/no_of_engines, '', '','');
                %Fuel burn rate, assuming level flight with aux systems running
                fuel_burn_rate = PSFC .* PT/3600;% N/sec

                roc = 0;
                
                %Determine time step
                time_step = loiter_time/cinc;
                
        end

        %Integrate forward, assuming constant climb, fuel burn, airspeed over
        %the interval
        segment_time        = segment_time + time_step;
        segment_fuel        = segment_fuel + fuel_burn_rate*time_step;
        segment_distance    = segment_distance + time_step*Vtas; 

        %Update vehicle weight
        W = W - kfac*fuel_burn_rate*time_step;
        
        %Set next altitude for cruise climb case
        if strcmp(segment_type,'cruise-climb')
            %Calculate flight path angle
            if strcmp(flight_condition,'speed')
              
                alt(k+1) = fn_findAltitude(2*W/(Vtas^2*S*CL), 'density', alt(k), airplane);
            else
                gam_sh = airplane.environment.gamma;
                alt(k+1) = fn_findAltitude(2*W/(gam_sh*M_flight^2*S*CL), 'pressure', alt(k), airplane);
            end
        end

        %If reverse integration was implemented, fcurrent, tcurrent, rcurrent
        %would get updated here
        %fcurrent = fcurrent + kfac*fuel_burn_rate*time_step...

        time_history(k, :) = [segment_time ...
                                segment_fuel ...
                                segment_distance ...
                                alt(k) ...
                                roc ...
                                Veas ...
                                Vtas ...
                                M_flight ...
                                CL ...
                                PT ...
                                PT_max ...
                                PSFC ...
                                fuel_burn_rate ...
                                W ...
                                gamma_FP...
                                CD_tot...
                                T04];
    end
end
segment.total_fuel      = segment_fuel;
segment.total_time      = segment_time;
segment.total_distance  = segment_distance;
segment.time_history    = time_history;
                            


  









































end