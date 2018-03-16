function [fileout] = jvl_run_CL(config,alpha, CL, d_flap, CDp)
%--------------------------------------------------------------------
% Run JVL for performance calculations
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
J1in    = ['J1 C ' num2str(CL)];

% Input commands
command{1,:}    = avlin;        % Read configuration input file
command{2,:}	= massin;       % Read mass distribution file
command{3,:}	= 'OPER';       % Compute operating-point run cases
command{4,:}    = Ain;          % Alpha
command{5,:}    = D1in;         % flap
command{6,:}    = J1in;         % CJet
command{7,:}    = 'M';
command{8,:}    = 'CD';
command{9,:}    = num2str(CDp);
command{10,:}    = ' ';
command{11,:}    = 'O';          % Options
command{12,:}    = 'P';          % Print default output for...
command{13,:}    = 'T T F F';	% total, surf, strip, elem
command{14,:}   = ' ';          % Return
command{15,:}   = 'X';          % eXecute run case
command{16,:}   = 'W';          % Write forces to file
command{17,:}   = fileout;      % Enter forces output file
command{18,:}   = ' ';          % Return
command{19,:}   = 'Q';          % Quit JVL

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