function ParaTest_Adaptive_Single_Scale_Retinex()
currDir = pwd;
ResultFolder = 'Results';
Imagfolder ='Dataset';

ParaMax = 15;
ParaMin = 1;
ParaMid = (((ParaMax-ParaMin)/2)+ParaMin);

for tests = 1:5
    
    bestMin = Default_Adaptive_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMin);
    bestMid = Default_Adaptive_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMid);
    bestMax = Default_Adaptive_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder,ParaMax);

    hMin = nanmean(nanmean(bestMin));
    hMid = nanmean(nanmean(bestMid));
    hMax = nanmean(nanmean(bestMax));
    
    % pick highest
    % get para 1, para2, para3 
    
    if(hMin > hMid && hMin > hMax)
        % paraMin Stays the same
        ParaMax = ParaMid;
        ParaMid = (((ParaMax-ParaMin)/2)+ParaMin);
fprintf('Min is best: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',ParaMin,ParaMid,ParaMax);
    elseif(hMid > hMin && hMid > hMax)
        r = (ParaMax - ParaMin);
        fprintf('Mid is best: ParaMin=%d   ParaMid=%d   ParaMax=%d\n',ParaMin,ParaMid,ParaMax);
        ParaMax = ParaMid + (r/4);
        %Paramid stays the same
        ParaMin = ParaMid - (r/4);
    elseif(hMax > hMin && hMax > hMid)
        % paraMin staus the same
        fprintf('Max is best: ParaMin=%d  ParaMid=%d  ParaMax=%d\n',ParaMin,ParaMid,ParaMax);
        ParaMin = ParaMid;
        ParaMid = (((ParaMax-ParaMin)/2)+ParaMin);
    else
        fprintf('Something has gone wrong');
    end
end

fprintf('Double_Density_Dual_Tree: ParaMin=%d  ParaMid=%d  ParaMax=%d',ParaMin,ParaMid,ParaMax);
return