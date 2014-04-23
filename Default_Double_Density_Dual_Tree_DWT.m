function resultanalysis = Default_Double_Density_Dual_Tree_DWT(currDir,ResultFolder,Imagfolder,para)

%Enhancement algorithm
Enhancementalg = 'Default_Double_Density_Dual_Tree';

%PathName = fullfile(currDir, Imagfolder,directory,datatype);
files = dir(fullfile(currDir,Imagfolder,'images', '*.tif'));
range = size(files,1);

resultanalysis= zeros(range,5);

for r = 1:range
    
    % Display image number and file
    %fprintf( 'Processing Image %d: %s\n', r, files(r).name );
    fprintf('#');
    [~,name,~] = fileparts( files(r).name );
    
    %---------------------------------------------------------------
    %load image file
    Img = imread(fullfile(currDir,Imagfolder,'images', files(r).name ));
    Img = Img(:,:,2);
    Img = imcrop(Img,[25 40 511 511]);
    %figure; imshow(Img); hold on
    
    %Mask: 21_training_mask
    Mask = imread(fullfile(currDir,Imagfolder, 'mask', [name(1:2) '_training_mask.gif']));
    Mask = imcrop(Mask,[25 40 511 511]);
    %%
    %load ground truth file
    GroundFile = fullfile(currDir,Imagfolder,'1st_manual', [name(1:2) '_manual1.gif']);
    GTimage = imread(GroundFile);
    GTimage = imcrop(GTimage,[25 40 511 511]);
    %Logical ground truth
    GTL= GTimage & 1;
    
    %%
    %peter experiment here
    %Enhance image
    Enh = mmnorm(double_S2D(double(Img),para));
    
    %extract center points
    TL = ExtractCPSegments(Enh, Mask);
    toPrint = figure;
    subplot(1,4,1);imshow(Img),title('Original');
    subplot(1,4,2); imshow(Enh),title('Enhanced');
    subplot(1,4,3); imshow(TL), title('TL');
    subplot(1,4,4); imshow(Mask), title('Mask');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    print -djpeg100 myfile.jpg
    close(toPrint);

    PixelStats = EvaluateAlongSegmentsGroundTruth( TL, GTL, Mask);
    resultanalysis(r,1:5) = PixelStats;
    
end
fprintf('\n');
% save results on ResultFolder
ResultFile = fullfile( currDir,ResultFolder, [Enhancementalg '_PixelStats'] );
save(ResultFile,'resultanalysis');

% to calculate performance over all of the images
%mean(resultanalysis)
return