function [CJtot, CXtot, CYtot, CZtot, CLtot, CDtot,CLcir, CLjet, CDind, ...
    CDjet, CDvis] = readJVL(fileout)
fileID = fopen(fileout,'r'); % open output file
            
            for line = 1:12 % extract data at top of output file
                tline = fgetl(fileID);
                if line == 2
                    CJtot = str2double(tline);
                elseif line == 3
                    CXtot = str2double(tline);
                elseif line == 4
                    CYtot = str2double(tline);
                elseif line == 5
                    CZtot = str2double(tline);
                elseif line == 6
                    CLtot = str2double(tline);
                elseif line == 7
                    CDtot = str2double(tline);
                elseif line == 8
                    CLcir = str2double(tline);
                elseif line == 9
                    CLjet = str2double(tline);
                elseif line == 10
                    CDind = str2double(tline);
                elseif line == 11
                    CDjet = str2double(tline);
                elseif line == 12
                    CDvis = str2double(tline);
                end
            end
            
            fclose(fileID); % close output file
end