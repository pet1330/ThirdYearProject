function finalTest
currDir = pwd;
ResultFolder = 'Results';
imageResultFolder = 'imageResults';
Imagfolder ='Dataset';
position = 3;
%PathName = fullfile(currDir, Imagfolder,directory,datatype);
files = dir( fullfile(currDir,Imagfolder,'images', '*.tif') );
range = size(files,1);
fid = fopen(fullfile(currDir,'Combinations','Comp8 Combinations', '')');
tline = fgetl(fid);
%Loops entire file line by line
while ischar(tline)
    fprintf('\n%s: ',tline);
    for r = 1:range
        
        % Display image number and file
        fprintf('%d|',r);
        [~,name,~] = fileparts( files(r).name );
        
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
        % Reset Enh to Img
        Enh = Img;
        %loop through enhancements
        for charLineCharacter = 1:length(tline);
            switch tline(charLineCharacter)
                case '0'
                    %This is the nothing case in order to evaluate the
                    %effect of no enhancement taking palce
                case '1'
                    % Adaptive Single Scale Retinex
                    Enh = mmnorm(adaptive_single_scale_retinex(Enh,15));
                case '2'
                    % Contrast Limiting Adaptive Histogram Equalisation
                    Enh = adapthisteq(Enh,'NumTiles',[3 3],'ClipLimit',0.01,'NBins',131,'Range','full','Distribution','rayleigh');
                case '3'
                    % Double Density Dual Tree
                    Enh = mmnorm(double_S2D(double(Img),2));
                case '4'
                    % Multiscale Retinex
                    Enh = multi_scale_retinex(Img,158,1);
                case '5'
                    % Median Filtering
                    Enh = medfilt2(Img, [2 2]);
                otherwise
                    disp('ERROR')
            end
        end
        
        %%
        %extract center points
        originalTL = ExtractCPSegments(Img, Mask);
        TL = ExtractCPSegments(Enh, Mask);
        
        toPrint = figure;
        set(toPrint, 'Visible', 'off');
        subplot(2,3,1);imshow(Img),title('Original');
        subplot(2,3,2); imshow(Enh),title('Enhanced');
        subplot(2,3,3); imshow(Mask),title('Mask');
        subplot(2,3,4); imshow(originalTL), title('Non-Enhanced TL');
        subplot(2,3,5); imshow(TL), title('Enhanced TL');
        subplot(2,3,6); imshow(imabsdiff(originalTL,TL)), title('Difference');
        ResultImage = fullfile(currDir,ResultFolder,imageResultFolder,sprintf('%s - %d.jpg',tline,r));
        saveas(toPrint,ResultImage,'jpg');
        close(toPrint);
        
        PixelStats = EvaluateAlongSegmentsGroundTruthFinal( TL, GTL, Mask);
        C = ConvertToAlphabet(position);
        letter = sprintf('%s',C{:});
        start = ((((r-1)*10)+2));
        finish = (((r-1)*10)+11);
        
        xlswrite(fullfile(currDir,ResultFolder,'FinalResults.xlsx'),tline,sprintf('%s%d:%s%d',letter,start-1,letter,start-1));
        xlswrite(fullfile(currDir,ResultFolder,'FinalResults.xlsx'),PixelStats,sprintf('%s%d:%s%d',letter,start,letter,finish));
    end
    tline = fgetl(fid);
    position = position+1;
end
fclose(fid);
return