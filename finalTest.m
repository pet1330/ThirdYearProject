function finalTest
currDir = pwd;
ResultFolder = 'Results';
imageResultFolder = 'imageResults';
Imagfolder ='Dataset';

%PathName = fullfile(currDir, Imagfolder,directory,datatype);
files = dir( fullfile(currDir,Imagfolder,'images', '*.tif') );
range = size(files,1);

resultanalysis= zeros(range,5);
fid = fopen('COMBO.perms');
tline = fgetl(fid);
%Loops entire file line by line
while ischar(tline)
    fprintf('\n%s: ',tline);
    for r = 1:range
        
        % Display image number and file
        fprintf('%d|',r);
        [~,name,~] = fileparts( files(r).name );
        
        %---------------------------------------------------------------
        %load image file
        Img = imread( fullfile(currDir,Imagfolder,'images', files(r).name ) );
        Img = Img(:,:,2);
        Img = imcrop(Img,[25 40 511 511]);
        %figure; imshow(Img); hold on
        
        %Mask: 21_training_mask
        Mask = imread(fullfile(currDir,Imagfolder, 'mask', [name(1:2) '_training_mask.gif']));
        Mask = imcrop(Mask,[25 40 511 511]);
        %%
        %load ground truth file
        GroundFile = fullfile( currDir,Imagfolder,'1st_manual', [name(1:2) '_manual1.gif'] );
        GTimage = imread(GroundFile);
        GTimage = imcrop(GTimage,[25 40 511 511]);
        %Logical ground truth
        GTL= GTimage & 1;
        
        for charLineCharacter = 1:length(tline);
            switch tline(charLineCharacter)
                case '0'
                    fprintf('a');
                   %This is the nothing case
                case '1'
                    fprintf('b');
                    Enh = adaptive_single_scale_retinex(Img,15);
                case '2'
                    fprintf('c');
                case '3'
                    fprintf('d');
                case '4'
                    fprintf('e');
                case '5'
                    fprintf('f');
                otherwise
                    disp('ERROR')
            end
        end
        
        %%
        %extract center points
        originalTL = ExtractCPSegments(Img, Mask);
        TL = ExtractCPSegments(Enh, Mask);
        
        toPrint = figure;
        subplot(2,3,1);imshow(Img),title('Original');
        subplot(2,3,2); imshow(Enh),title('Enhanced');
        subplot(2,3,3); imshow(Mask),title('Mask');
        subplot(2,3,4); imshow(originalTL), title('Non-Enhanced TL');
        subplot(2,3,5); imshow(TL), title('Enhanced TL');
        subplot(2,3,6); imshow(imabsdiff(originalTL,TL)), title('Difference');
        
        set(gcf,'units','normalized','outerposition',[0 0 1 1]);
        ResultImage = fullfile(currDir,ResultFolder,imageResultFolder,sprintf('%s - %d.jpg',tline,r));
        print('-djpeg100', ResultImage);
        close(toPrint);
        
        PixelStats = EvaluateAlongSegmentsGroundTruth( TL, GTL, Mask);
        resultanalysis(r,1:5) = PixelStats;
        
    end
    % save results on ResultFolder
    ResultFile = fullfile( currDir,ResultFolder,tline);
    save(ResultFile,'resultanalysis');
    tline = fgetl(fid);
end
fclose(fid);
return