function [CJet, CJtot, CXtot, CYtot, CZtot, CLtot, CDtot,CLcir, CLjet, CDind, ...
    CDjet, CDvis] = readJVL(fileout)
fileID = fopen(fileout,'r'); % open output file
            
                tline = fgetl(fileID);
                line = 0;
                for line = 1:50
                    if line == 20
                        l  = split(tline);
                        CJtot = str2double(l(4));
                        CQtot = str2double(l(7));
                    elseif line == 22
                        l  = split(tline);
                        CXtot = str2double(l(4));
                    elseif line == 23
                        l  = split(tline);
                        CYtot = str2double(l(4));
                    elseif line == 24
                        l  = split(tline);
                        CZtot = str2double(l(4));
                    elseif line == 26
                        l  = split(tline);
                        CLtot = str2double(l(4));
                    elseif line == 27
                        l  = split(tline);
                        CDtot = str2double(l(4));
                    elseif line == 29
                        l  = split(tline);
                        CLcir = str2double(l(4));
                    elseif line == 30
                        l  = split(tline);
                        CLjet = str2double(l(4));
                    elseif line == 32
                        l  = split(tline);
                        CDind = str2double(l(4));
                    elseif line == 33
                        l  = split(tline);
                        CDjet = str2double(l(4));
                    elseif line == 34
                        l  = split(tline);
                        CDvis = str2double(l(4));
                    elseif line == 39
                        l = split(tline);
                        CJet = str2double(l(4));
                    end
                   
                    tline = fgetl(fileID);

            end
            
            fclose(fileID); % close output file
end