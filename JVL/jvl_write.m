function [fileout] = jvl_write(airplane, filename, M)
%--------------------------------------------------------------------
% Write JVL with basic inputs
%
%--------------------------------------------------------------------

% Delete old input command file if it exists
if (exist(strcat(filename,'.avl'),'file')~= 0)
    dos(['rm ' strcat(filename,'.avl')]);
end

%Read params from airplane
IYsym = zero_default('IYsym', airplane.weights)
IZsym = zero_default('IZsym', airplane.weights)
Zsym = zero_default('Zsym', airplane.weights)

Xref = zero_default('Xref', airplane.weights)
Yref = zero_default('Yref', airplane.weights)
Zref = zero_default('Zref', airplane.weights)




%Create file
fid = fopen(strcat(filename, '.avl'),'w+');

fprintf(fid, '%s:Auto generated\n', filename);
fprintf(fid, '#Mach\n');
fprintf(fid, '%f\n', M);
fprintf(fid, '#IYsym\tIZsym\tZsym\n')
fprintf(fid, '%3.3f\t%3.3f\t%3.3f\n', IYsym, IZsym, Zsym)
fprintf(fid, '#Sref\tCref\tBref\n')
fprintf(fid, '%3.3f\t%3.3f\t%3.3f\n', airplane.geometry.Wing.Sref,...
                             airplane.geometry.Wing.c_ma,...
                             airplane.geometry.Wing.b)
fprintf(fid, '#IYsym\tIZsym\tZsym\n')
fprintf(fid, '%3.3f\t%3.3f\t%3.3f\n', Xref, Yref, Zref)
fprintf(fid, '#\n')
fprintf(fid, '#\n\n')
fprintf(fid, '#====================================================================')
fprintf(fid, 'SURFACE\nWing\n')
fprintf(fid, '#Nchordwise\tCspace\tNspanwise\tSspace\n')
fprintf(fid, '12\t1.0\t4\t1.0\n') %MAKE THESE CONTROL PARAMS VARIABLES
fprintf(fid, '#\n')
fprintf(fid, 'COMPONENT\n1\n')
fprintf(fid, '#\n')
fprintf(fid, 'YDUPLICATE\n0.0\n')
fprintf(fid, '#\n')
fprintf(fid, 'ANGLE\n%f\n', airplane.geometry.wing_incidence)
fprintf(fid, '\nJET\n#Jname\tJgain\tSgnDup\thjet\tNchordwise\tCspace')
fprintf(fid, 'Cjet\t1.0\t+1.0\t%3.2f\t12\t1.0\n', airplane.aero.h_jet/airplane.geometry.Wing.c_ma)


fclose(fid)

function writeSection(fid, AF, isNACA, ...
                        Xle, Yle, Zle, ...
                        chord, ainc, Nspan, Sspace...
                        isControl, controlParams)
                    
fprintf(fid, '#-------------------------------------------------------------\n')
fprintf(fid, 'SECTION\n')
fprintf(fid, '#Xle\tYle\tZle\tChord\tAinc\tNspanwise\tSspace\n')
fprintf(fid, '#%3.3f\t%3.3f\t%3.3f\t%3.3f\t%3.3f\t%3.3f\t%3.3f\n',...
                        Xle, Yle, Zle, chord, ainc, Nspan, Sspace)
if isNACA
    fprintf(fid, 'NACA\n%s\n\n', AF)
else
    fprint(fid,'IMPLEMENT NON-NACA AF\n')
end

fprintf(fid,'#Cname\tCgain\tXhinge\tHingeVec\tSgnDup\n')
if isControl
   fprintf(fid, 'CONTROL\n')
   fprintf(fid, '%s\t%2.2f\t%3.3f\t%2.2f %2.2f %2.2f\t%2.2f\n\n', ...
       controlParams.Cname, controlParams.Cgain, controlParams.Xhinge,...
       controlParams.HingeVec(1), controlParams.HingeVec(2), controlParams.HineVec(3),...
       controlParams.SgnDup)
end
fprintf(fid, 'CLAF\n1.0\n\n')
end
% % Create strings for input/output file names and input commands
% avlin   = ['LOAD ' config '.avl'];
% massin  = ['MASS ' config '.mass'];
% fileout = [config '_' num2str(i) '_' num2str(j) '_' num2str(k) '.txt'];
% switch alphaCLFlag
%     case 'alpha'
%         Ain     = ['A A ' num2str(alphaCL)];
%     case 'CL'
%         Ain     = ['A C ' num2str(alphaCL)];
% D1in    = ['D1 D1 ' num2str(flap)];
% J1in    = ['J1 J1 ' num2str(cjet)];
% 
% % Input commands
% command{1,:}    = avlin;        % Read configuration input file
% command{2,:}	= massin;       % Read mass distribution file
% command{3,:}	= 'OPER';       % Compute operating-point run cases
% command{4,:}    = Ain;          % Alpha
% command{5,:}    = D1in;         % flap
% command{6,:}    = J1in;         % CJet
% command{7,:}    = 'O';          % Options
% command{8,:}    = 'P';          % Print default output for...
% command{9,:}    = 'T T F F';	% total, surf, strip, elem
% command{10,:}   = ' ';          % Return
% command{11,:}   = 'X';          % eXecute run case
% command{12,:}   = 'W';          % Write forces to file
% command{13,:}   = fileout;      % Enter forces output file
% command{14,:}   = ' ';          % Return
% command{15,:}   = 'Q';          % Quit JVL
% 
% % Write input command file (ASCII-delimited)
% for i=1:length(command)
%     dlmwrite('jvlcom.in',cell2mat(command(i)),'-append','delimiter','');
% end
% 
% % Run JVL
% unix('~/tools/Jvl/bin/jvl < jvlcom.in');
% 
% % Delete input command files
% unix('rm jvlcom.*');
% 
% %return

% path1 = getenv('PATH');
% path1 = [path1 ':/usr/local/bin'];
% setenv('PATH', path1);
% !echo $PATH

% Add/modify .run input file for eigenmode calculation
%   (Zero Velocity.  Specify with run file or M menu)

end
function [param] = zero_default(param_name, struct)
    if isfield(struct, param_name)
        param = getfield(struct, param_name)
    else
        param = 0.0;
    end
end