%--------------------------------------------------------------------
% Setup JVL parameter sweeps
%
% Make sure xxx.avl and xxx.mass files in same folder
%
% Single flap across span assumed in this version
%--------------------------------------------------------------------

% clear
close all
set(0,'DefaultAxesFontSize',18);
set(0,'DefaultTextFontSize',24);
set(0,'DefaultAxesFontName','Arial');
set(0,'DefaultTextFontName','Arial');
set(0,'DefaultLineLineWidth',3);
set(0,'DefaultAxesFontWeight','Bold');
% set(0, 'DefaultFigurePosition', [2641 -29 960 984])
% set(0, 'DefaultFigurePosition', [2641 -29 1920 984])

% load ('constants.mat')

% Parameters for evaluation
config  = 'stolTO';
% alpha   = [0 2 4 6 8 10]; % angle of attack sweep range [deg]
% flap    = [0 20 40]; % flap angle sweep range [deg]
% cjet    = [0.34 8.86 20.86 36.07]; % Delta CJ sweep range [-]
alpha   = [0 1 2 3 4 5 6 7 8 9 10]; % angle of attack sweep range [deg]
flap    = [0 10 20 30 40 50]; % flap angle sweep range [deg]
cjet    = [0 5 10 15 20 25 30 35 40 45 50]; % Delta CJ sweep range [-]
alphal  = length(alpha);
flapl   = length(flap);
cjetl   = length(cjet);
CJtot   = zeros(alphal,flapl,cjetl);
CXtot   = zeros(alphal,flapl,cjetl);
CYtot   = zeros(alphal,flapl,cjetl);
CZtot   = zeros(alphal,flapl,cjetl);
CLtot   = zeros(alphal,flapl,cjetl);
CDtot   = zeros(alphal,flapl,cjetl);
CLcir   = zeros(alphal,flapl,cjetl);
CLjet   = zeros(alphal,flapl,cjetl);
CDind   = zeros(alphal,flapl,cjetl);
CDjet   = zeros(alphal,flapl,cjetl);
CDvis   = zeros(alphal,flapl,cjetl);

% Sweep parameters
for i = 1:alphal
    for j = 1:flapl
        for k = 1:cjetl
            
            [fileout] = jvl_run(config,alpha(i),flap(j),cjet(k),i,j,k); % run JVL
            
            fileID = fopen(fileout,'r'); % open output file
            
            for line = 1:12 % extract data at top of output file
                tline = fgetl(fileID);
                if line == 2
                    CJtot(i,j,k) = str2double(tline);
                elseif line == 3
                    CXtot(i,j,k) = str2double(tline);
                elseif line == 4
                    CYtot(i,j,k) = str2double(tline);
                elseif line == 5
                    CZtot(i,j,k) = str2double(tline);
                elseif line == 6
                    CLtot(i,j,k) = str2double(tline);
                elseif line == 7
                    CDtot(i,j,k) = str2double(tline);
                elseif line == 8
                    CLcir(i,j,k) = str2double(tline);
                elseif line == 9
                    CLjet(i,j,k) = str2double(tline);
                elseif line == 10
                    CDind(i,j,k) = str2double(tline);
                elseif line == 11
                    CDjet(i,j,k) = str2double(tline);
                elseif line == 12
                    CDvis(i,j,k) = str2double(tline);
                end
            end
            
            fclose(fileID); % close output file
            
        end
    end
end