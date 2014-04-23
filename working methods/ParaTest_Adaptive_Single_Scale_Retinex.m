function ParaTest_Adaptive_Single_Scale_Retinex()
currDir = pwd;
ResultFolder = 'Results';
Imagfolder ='Dataset';

ParaMax = 15;
ParaMin = 1;
ParaMid = (((ParaMax-ParaMin)/2)+ParaMin);

for tests = 1:5
    allResults(:,:,1) = Default_Adaptive_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMin);
    allResults(:,:,2) = Default_Adaptive_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMid);
    allResults(:,:,3) = Default_Adaptive_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMax);
    
    best = zeros(3,1);
    for i = 1:3
        best(i) = mean(allResults(:,5,i));
    end
    disp(best)
    index = find(best == max(best(:)));
    
    switch index(index)
        case 1
            % paraMin Stays the same
            ParaMax = ParaMid;
            ParaMid = round(((ParaMax-ParaMin)/2)+ParaMin);
            fprintf('ParaMin on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin,ParaMid,ParaMax);
        case 2
            r = (ParaMax - ParaMin);
            ParaMax = ParaMid + (r/4);
            %Paramid stays the same
            ParaMin = ParaMid - (r/4);
            fprintf('ParaMid on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin,ParaMid,ParaMax);
        case 3
            % paraMax staus the same
            ParaMin = ParaMid;
            ParaMid = round(((ParaMax-ParaMin)/2)+ParaMin);
            fprintf('ParaMax on iteration %d: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',tests,ParaMin,ParaMid,ParaMax);
    end
end
fprintf('Adaptive_Single_Scale_Retinex: ParaMin=%d  ParaMid=%d  ParaMax=%d',ParaMin,ParaMid,ParaMax);
return