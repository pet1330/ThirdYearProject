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
clipLimit{2} = (((clipLimit{1}-clipLimit{3})/2)+clipLimit{3});

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
waitbarProgress = 0;
waitbarTotal = 1620;
waitbar(waitbarProgress/1620,'CLAHE Progress')
for tests = 1:5
    allResults = zeros(20,5,162);
    track = 0;
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
                        track = track+1;
                        waitbar(waitbarProgress/waitbarTotal)
                        waitbarProgress = waitbarProgress+1;
                        allResults(:,:,track) = Default_CLAHE(currDir,ResultFolder,Imagfolder,TilesInput,clipInput,NBinInput,RanInput,disInput);
                    end
                end
            end
        end
    end
    best = zeros(162,1);
    for i = 1:162
        best(i) = mean(allResults(:,5,i));
    end
    index = find(best == max(best(:)));
    track2 = 0;
    for TilesLoop = 1 : size(numTiles)
        for clipLoop = 1: size(clipLimit)
            for NBinLoop = 1:size(NBins)
                for ranLoop = 1:size(Range)
                    for disLoop = 1:size(Distribution)
                        track2 = track2+1;
                        waitbar(waitbarProgress/waitbarTotal)
                        waitbarProgress = waitbarProgress+1;
                        if(track2==index)
                            fprintf('Iteration: %d\n',tests);
                            switch TilesLoop
                                case 1
                                    numTiles{3} = numTiles{2};
                                    numTiles{2} = round(((numTiles{1}-numTiles{3})/2)+numTiles{3});
                                    fprintf('numTitle:  Maximum Selected as best: min=%d mid=%d max=%d\n',numTiles{3},numTiles{2},numTiles{1})
                                case 2
                                    r = (numTiles{1} - numTiles{3});
                                    numTiles{1} = numTiles{2} + round(r/4);
                                    numTiles{3} = numTiles{2} - round(r/4);
                                    fprintf('numTitle:  Middle Selected as best: min=%d mid=%d max=%d\n',numTiles{3},numTiles{2},numTiles{1})
                                case 3
                                    numTiles{1} = numTiles{2};
                                    numTiles{2} = round(((numTiles{1}-numTiles{3})/2)+numTiles{3});
                                    fprintf('numTitle:  Minimum Selected as best: min=%d mid=%d max=%d\n',numTiles{3},numTiles{2},numTiles{1})
                            end
                            
                            switch clipLoop
                                case 1
                                    clipLimit{3} = clipLimit{2};
                                    clipLimit{2} = (((clipLimit{1}-clipLimit{3})/2)+clipLimit{3});
                                    fprintf('clipLimit:  Maximum Selected as best: min=%f mid=%f max=%f\n',clipLimit{3},clipLimit{2},clipLimit{1})
                                case 2
                                    r = (clipLimit{1} - clipLimit{3});
                                    clipLimit{1} = clipLimit{2} + (r/4);
                                    clipLimit{3} = clipLimit{2} - (r/4);
                                    fprintf('clipLimit:  Middle Selected as best: min=%f mid=%f max=%f\n',clipLimit{3},clipLimit{2},clipLimit{1})
                                case 3
                                    clipLimit{1} = clipLimit{2};
                                    clipLimit{2} = (((clipLimit{1}-clipLimit{3})/2)+clipLimit{3});
                                    fprintf('clipLimit:  Minimum Selected as best: min=%f mid=%f max=%f\n',clipLimit{3},clipLimit{2},clipLimit{1})
                            end
                            
                            switch NBinLoop
                                case 1
                                    NBins{3} = NBins{2};
                                    NBins{2} = round(((NBins{1}-NBins{3})/2)+NBins{3});
                                    fprintf('NBins:  Maximum Selected as best: min=%d mid=%d max=%d\n',NBins{3},NBins{2},NBins{1})
                                case 2
                                    r = (NBins{1} - NBins{3});
                                    NBins{1} = NBins{2} + round(r/4);
                                    NBins{3} = NBins{2} - round(r/4);
                                    fprintf('NBins:  Middle Selected as best: min=%d mid=%d max=%d\n',NBins{3},NBins{2},NBins{1})
                                case 3
                                    NBins{1} = NBins{2};
                                    NBins{2} = round(((NBins{1}-NBins{3})/2)+NBins{3});
                                    fprintf('NBins:  Minimum Selected as best: min=%d mid=%d max=%d\n',NBins{3},NBins{2},NBins{1})
                            end
                            fprintf('Range: %s\n', Range{ranLoop});
                            fprintf('Distribution: %s\n', Distribution{disLoop});
                        end
                    end
                end
            end
        end
    end
    fprintf('Iteration %d completed\n',tests);
end
end