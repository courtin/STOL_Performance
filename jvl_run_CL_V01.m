function [fileout] = jvl_run_CL_V01(config,alpha, CL, d_flap, CDp)
%--------------------------------------------------------------------
% Run JVL for performance calculations
%
%Assumes 4 independent flaps
%
%1 jet
%
%For landing, deflects all flaps together and powers all jets equally
%--------------------------------------------------------------------

% Delete old input command file if it exists
if (exist('jvlcom.in','file')~= 0)
    dos('rm jvlcom.*');
end

% Create strings for input/output file names and input commands
avlin   = ['LOAD ' config '.avl'];
massin  = ['MASS ' config '.mass'];
fileout = [config '_out' '.txt'];
Ain     = ['A A ' num2str(alpha)];
D1in    = ['D1 D1 ' num2str(d_flap)];
D2in    = ['D2 D2 ' num2str(d_flap)];
D3in    = ['D3 D3 ' num2str(d_flap)];
D4in    = ['D4 D4 ' num2str(d_flap)];
J1in    = ['J1 C ' num2str(CL)];

% Input commands
command{1,:}    = avlin;        % Read configuration input file
command{2,:}	= massin;       % Read mass distribution file
command{3,:}	= 'OPER';       % Compute operating-point run cases
command{4,:}    = Ain;          % Alpha
command{5,:}    = D1in;         % flap
command{6,:}    = D2in;         % flap
command{7,:}    = D3in;         % flap
command{8,:}    = D4in;         % flap
command{9,:}    = J1in;         % CJet
command{10,:}    = 'M';
command{11,:}    = 'CD';
command{12,:}    = num2str(CDp);
command{13,:}    = ' ';
command{14,:}    = 'O';          % Options
command{15,:}    = 'P';          % Print default output for...
command{16,:}    = 'T T F F';	% total, surf, strip, elem
command{17,:}   = ' ';          % Return
command{18,:}   = 'X';          % eXecute run case
command{19,:}   = 'W';          % Write forces to file
command{20,:}   = fileout;      % Enter forces output file
command{21,:}   = ' ';          % Return
command{22,:}   = 'Q';          % Quit JVL

% Write input command file (ASCII-delimited)
for i=1:length(command)
    dlmwrite('jvlcom.in',cell2mat(command(i)),'-append','delimiter','');
end

% Run JVL
unix('~/tools/Jvl/bin/jvl < jvlcom.in > screendump.txt');

% Delete input command files
unix('rm jvlcom.*');

return

% path1 = getenv('PATH');
% path1 = [path1 ':/usr/local/bin'];
% setenv('PATH', path1);
% !echo $PATH

% Add/modify .run input file for eigenmode calculation
%   (Zero Velocity.  Specify with run file or M menu)