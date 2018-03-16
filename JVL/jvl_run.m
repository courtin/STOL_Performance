function [fileout] = jvl_run(config,alphaCL, alphaCLFlag,flap,cjet,i,j,k)
%--------------------------------------------------------------------
% Run JVL with basic inputs
%
% Make sure xxx.avl and xxx.mass files in same folder
%
% Test case jvl_run('stolTO',0,'alpha',20,36.07,1,1,1)
%--------------------------------------------------------------------

% Delete old input command file if it exists
if (exist('jvlcom.in','file')~= 0)
    dos('rm jvlcom.*');
end

% Create strings for input/output file names and input commands
avlin   = ['LOAD ' config '.avl'];
massin  = ['MASS ' config '.mass'];
fileout = [config '_' num2str(i) '_' num2str(j) '_' num2str(k) '.txt'];
switch alphaCLFlag
    case 'alpha'
        Ain     = ['A A ' num2str(alphaCL)];
    case 'CL'
        Ain     = ['A C ' num2str(alphaCL)];
D1in    = ['D1 D1 ' num2str(flap)];
J1in    = ['J1 J1 ' num2str(cjet)];

% Input commands
command{1,:}    = avlin;        % Read configuration input file
command{2,:}	= massin;       % Read mass distribution file
command{3,:}	= 'OPER';       % Compute operating-point run cases
command{4,:}    = Ain;          % Alpha
command{5,:}    = D1in;         % flap
command{6,:}    = J1in;         % CJet
command{7,:}    = 'O';          % Options
command{8,:}    = 'P';          % Print default output for...
command{9,:}    = 'T T F F';	% total, surf, strip, elem
command{10,:}   = ' ';          % Return
command{11,:}   = 'X';          % eXecute run case
command{12,:}   = 'W';          % Write forces to file
command{13,:}   = fileout;      % Enter forces output file
command{14,:}   = ' ';          % Return
command{15,:}   = 'Q';          % Quit JVL

% Write input command file (ASCII-delimited)
for i=1:length(command)
    dlmwrite('jvlcom.in',cell2mat(command(i)),'-append','delimiter','');
end

% Run JVL
unix('~/tools/Jvl/bin/jvl < jvlcom.in');

% Delete input command files
unix('rm jvlcom.*');

return

% path1 = getenv('PATH');
% path1 = [path1 ':/usr/local/bin'];
% setenv('PATH', path1);
% !echo $PATH

% Add/modify .run input file for eigenmode calculation
%   (Zero Velocity.  Specify with run file or M menu)