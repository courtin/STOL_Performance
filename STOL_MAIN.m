%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   STOL AIRCRAFT SIMULATION 
%   VERSION 0.1: PERFORMANCE BASED ON FIXED MISSION, SIMPLE ENGINE MODEL, AND
%   PARABOLIC DRAG BUILDUP
%   
%   OUTPUTS:
%
%   Graphical outputs as defined in plotMission
%   
%   Numerical outputs as given by runSingleMission.m
%
%   INPUTS:
%   
%   The mission profile is configurable and defined in
%   MISSION_DEFINITION.m, and input types are defined in that file.
%
%   All other inputs to the code are contained in STOL_INPUTS.m (or whatever
%   script of the same format is listed under inputs below).  Inputs are
%   commented in that file, which also links to other drag polar etc.
%   inputs as necessary.
%
%
%   GENERAL OPERATION:
%   The aircraft and mission input scripts create the appropriate data
%   structures required by the rest of the code.  They must be run first,
%   and create the airplane and Mission data structures.  
%
%   initialize_dragPolar reads in the drag data from the appropriate
%   location, and formats the correct parts of the airplane data structure.
%   
%   engine_initialize sizes the engine model for an appropriate
%   flight condition.  
%
%   runSingleMission performs the mission
%   integration for the specified aircraft and mission profile. 
%   
%   plotMission outputs various graphs.
%   
%   This version of the code only supports plotting of a single specified
%   mission.
%
%   Created by: Chris Courtin (courtin@mit.edu)
%   Last updated: 8th March. 2018
%  
%
%    Changes:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all;
clc;

%Aircraft Input Script
%STOL_INPUT
TEST_INPUT
%Mission Input Script
STOL_MISSION_DEFINITION

%Geometry init
airplane = initialize_geometry(airplane) 

%Drag Polar init
%airplane = initialize_dragPolar(airplane);

%Propulsion system Init


%Run mission
[mission_output, mission_history] = runSingleMission(airplane, Mission, 1);

%Plot results
plotMission
Only
%                                       required if
%                                       segment_inputs.thrust_reversers = 1