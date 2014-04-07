function ParaTest_Double_Density_Dual_Tree_Real_DWT()
currDir = pwd;
ResultFolder = 'Results';
Imagfolder ='Dataset';

ParaMax = 40;
ParaMin = 0;
ParaMid = (((ParaMax-ParaMin)/2)+ParaMin);

for tests = 1:5
    allResults(:,:,1) = Default_Double_Density_Dual_Tree_Real_DWT(currDir,ResultFolder,Imagfolder,ParaMin);
    allResults(:,:,2) = Default_Double_Density_Dual_Tree_Real_DWT(currDir,ResultFolder,Imagfolder,ParaMid);
    allResults(:,:,3) = Default_Double_Density_Dual_Tree_Real_DWT(currDir,ResultFolder,Imagfolder,ParaMax);
    
    best = zeros(3,1);
    for i = 1:3
        best(i) = mean(allResults(:,5,i));
    end
    disp(best)
    index = find(best == max(best(:)));
    
    switch index(1)
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
fprintf('Double_Density_Dual_Tree: ParaMin=%d  ParaMid=%d  ParaMax=%d',ParaMin,ParaMid,ParaMax);
return