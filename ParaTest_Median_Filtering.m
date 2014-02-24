function ParaTest_Median_Filtering()
currDir = pwd;
ResultFolder = 'Results';
Imagfolder ='Dataset';

ParaMax = 30;
ParaMin = 2;
ParaMid = round(((ParaMax-ParaMin)/2)+ParaMin);

for tests = 1:5
    
    bestMin = Default_Median_Filtering(currDir,ResultFolder,Imagfolder,[ParaMin ParaMin ]);
    bestMid = Default_Median_Filtering(currDir,ResultFolder,Imagfolder,[ParaMid ParaMid]);
    bestMax = Default_Median_Filtering(currDir,ResultFolder,Imagfolder,[ParaMax ParaMax]);

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

fprintf('BEST RESULTS ARE: ParaMin=%d  ParaMid=%d  ParaMax=%d',ParaMin,ParaMid,ParaMax);
return