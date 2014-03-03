function ParaTest_Multi_Scale_Retinex()
currDir = pwd;
ResultFolder = 'Results';
Imagfolder ='Dataset';

ParaMax1 = 500;
ParaMin1 = 2;
ParaMid1 = round(((ParaMax1-ParaMin1)/2)+ParaMin1);
ParaMax2 = 1;
ParaMin2 = 0;
for tests = 1:50
    allResults(:,:,1) = Default_Multi_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMin1,ParaMin2);
    allResults(:,:,2) = Default_Multi_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMid1,ParaMin2);
    allResults(:,:,3) = Default_Multi_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMax1,ParaMin2);
    allResults(:,:,4) = Default_Multi_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMin1,ParaMax2);
    allResults(:,:,5) = Default_Multi_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMid1,ParaMax2);
    allResults(:,:,6) = Default_Multi_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMax1,ParaMax2);
    
    best = zeros(6);
    for i = 1:6
        best(i) = nanmean(nanmean(allResults(:,:,i)));
    end
    disp(best)
    index = find(best == max(best(:)));
    
    switch index
        case 1
            % paraMin Stays the same
            ParaMax1 = ParaMid1;
            ParaMid1 = round(((ParaMax1-ParaMin1)/2)+ParaMin1);
            fprintf('ParaMin1 on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin1,ParaMid1,ParaMax1);
            fprintf('ParaMin2 on iteration %d: ParaMin=%d\n',tests,ParaMin2);
            
        case 2
            r = (ParaMax1 - ParaMin1);
            ParaMax1 = ParaMid1 + (r/4);
            %Paramid stays the same
            ParaMin1 = ParaMid1 - (r/4);
            fprintf('ParaMid1 on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin1,ParaMid1,ParaMax1);
            fprintf('ParaMin2 on iteration %d: ParaMin=%d\n',tests,ParaMin2);
            
        case 3
            % paraMax staus the same
            ParaMin1 = ParaMid1;
            ParaMid1 = round(((ParaMax1-ParaMin1)/2)+ParaMin1);
            fprintf('ParaMax1 on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin1,ParaMid1,ParaMax1);
            fprintf('ParaMin2 on iteration %d: ParaMin=%d\n',tests,ParaMin2);
            
        case 4
            % paraMin Stays the same
            ParaMax1 = ParaMid1;
            ParaMid1 = round(((ParaMax1-ParaMin1)/2)+ParaMin1);
            fprintf('ParaMin1 on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin1,ParaMid1,ParaMax1);
            fprintf('ParaMax2 on iteration %d: ParaMax=%d\n',tests,ParaMax2);
            
        case 5
            r = (ParaMax1 - ParaMin1);
            ParaMax1 = ParaMid1 + (r/4);
            %Paramid stays the same
            ParaMin1 = ParaMid1 - (r/4);
            fprintf('ParaMid1 on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin1,ParaMid1,ParaMax1);
            fprintf('ParaMax2 on iteration %d: ParaMax=%d\n',tests,ParaMax2);
            
        case 6
            % paraMax staus the same
            ParaMin1 = ParaMid1;
            ParaMid1 = round(((ParaMax1-ParaMin1)/2)+ParaMin1);
            fprintf('ParaMax1 on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin1,ParaMid1,ParaMax1);
            fprintf('ParaMax2 on iteration %d: ParaMax=%d\n',tests,ParaMax2);
            
    end
end

fprintf('Best Para1: ParaMin=%d  ParaMid=%d  ParaMax=%d\n',ParaMin1,ParaMid1,ParaMax1);
if(index<4)
    fprintf('Para2 on iteration %d: ParaMin=%d\n',tests,ParaMin2);
else
    fprintf('Para2 on iteration %d: ParaMax=%d\n',tests,ParaMax2);
end
return