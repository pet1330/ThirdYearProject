function ParaTest_CLAHE()
currDir = pwd;
ResultFolder = 'Results';
Imagfolder ='Dataset';

numTiles = cell(3);
numTiles{1} =  30;
numTiles{3} = 2;
numTiles{2} = round(((numTiles{1}-numTiles{3})/2)+numTiles{3});

clipLimit = cell(3);
clipLimit{1} =  0.99;
clipLimit{3} = 0.01;
clipLimit{2} = round(((clipLimit{1}-clipLimit{3})/2)+clipLimit{3});

NBins = cell(3);
NBins{1} =  256;
NBins{3} = 6;
NBins{2} = round(((NBins{1}-NBins{3})/2)+NBins{3});

Range = cell(2);
Range{1} =  'original';
Range{2} = 'full';

Distribution = cell(3);
Distribution{1} =  'uniform';
Distribution{2} = 'rayleigh';
Distribution{3} = 'exponential';

for tests = 1:5
    allResults = zeros(20,5,162);
    track = 1;
    for TilesLoop = 1 : size(numTiles)
        TilesInput = numTiles{TilesLoop};
        for clipLoop = 1: size(clipLimit)
            clipInput = clipLimit{clipLoop};
            for NBinLoop = 1:size(NBins)
                NBinInput = NBins{NBinLoop};
                for ranLoop = 1:size(Range)
                    RanInput = Range{ranLoop};
                    for disLoop = 1:size(Distribution)
                        disInput = Distribution{disLoop};
                        allResults(:,:,track) = Default_CLAHE(currDir,ResultFolder,Imagfolder,TilesInput,clipInput,NBinInput,RanInput,disInput);
                        track = track+1;
                    end
                end
            end
        end
    end
    
    for i = 1:6
        best = zeros(6);
        best(i) = nanmean(nanmean(allResults(:,:,i)));
    end
    
    index = find(best == max(best(:)));
    Tobreak=0;
    for TilesLoop = 1 : size(numTiles)
        for clipLoop = 1: size(clipLimit)
            for NBinLoop = 1:size(NBins)
                for ranLoop = 1:size(Range)
                    for disLoop = 1:size(Distribution)
                        if(track==index)
                            fprintf('Iteration: %d\n',tests);
                            switch TilesLoop
                                case 1
                                    numTiles{3} = numTiles{2};
                                    numTiles{2} = round(((numTiles{1}-numTiles{3})/2)+numTiles{3});
                                    fprintf('numTitle:\nMinimum Selected as best: min=%d mid=%d max=%d',tests,numTiles{3},numTiles{2},numTiles{1})
                                case 2
                                    r = (numTiles{1} - numTiles{3});
                                    numTiles{1} = numTiles{2} + round(r/4);
                                    numTiles{3} = numTiles{2} - round(r/4);
                                    fprintf('numTitle:\nMiddle Selected as best: min=%d mid=%d max=%d',tests,numTiles{3},numTiles{2},numTiles{1})
                                case 3
                                    numTiles{1} = numTiles{2};
                                    numTiles{2} = round(((numTiles{1}-numTiles{2})/2)+numTiles{3});
                                    fprintf('numTitle:\nMaximum Selected as best: min=%d mid=%d max=%d',tests,numTiles{3},numTiles{2},numTiles{1})
                            end
                            
                            switch clipLoop
                                case 1
                                    clipLimit{3} = clipLimit{2};
                                    clipLimit{2} = round(((clipLimit{1}-clipLimit{3})/2)+clipLimit{3});
                                    fprintf('clipLimit:\nMinimum Selected as best: min=%d mid=%d max=%d',tests,clipLimit{3},clipLimit{2},clipLimit{1})
                                case 2
                                    r = (clipLimit{1} - clipLimit{3});
                                    clipLimit{1} = clipLimit{2} + round(r/4);
                                    clipLimit{3} = clipLimit{2} - round(r/4);
                                    fprintf('clipLimit:\nMiddle Selected as best: min=%d mid=%d max=%d',tests,clipLimit{3},clipLimit{2},clipLimit{1})
                                case 3
                                    clipLimit{1} = clipLimit{2};
                                    clipLimit{2} = round(((clipLimit{1}-clipLimit{2})/2)+clipLimit{3});
                                    fprintf('clipLimit:\nMaximum Selected as best: min=%d mid=%d max=%d',tests,clipLimit{3},clipLimit{2},clipLimit{1})
                            end
                            
                            switch NBinLoop
                                case 1
                                    NBins{3} = NBins{2};
                                    NBins{2} = round(((NBins{1}-NBins{3})/2)+NBins{3});
                                    fprintf('NBins:\nMinimum Selected as best: min=%d mid=%d max=%d',tests,NBins{3},NBins{2},NBins{1})
                                case 2
                                    r = (NBins{1} - NBins{3});
                                    NBins{1} = NBins{2} + round(r/4);
                                    NBins{3} = NBins{2} - round(r/4);
                                    fprintf('NBins:\nMiddle Selected as best: min=%d mid=%d max=%d',tests,NBins{3},NBins{2},NBins{1})
                                case 3
                                    NBins{1} = NBins{2};
                                    NBins{2} = round(((NBins{1}-NBins{2})/2)+NBins{3});
                                    fprintf('NBins:\nMaximum Selected as best: min=%d mid=%d max=%d',tests,NBins{3},NBins{2},NBins{1})
                            end
                            
                            Tobreak=1;
                            break;
                        end
                        track = track+1;
                    end
                end
                if Tobreak==1
                    break;end
            end
            if Tobreak==1
                break;end
        end
        if Tobreak==1
            break;end
    end
    if Tobreak==1
        break;end
end
return