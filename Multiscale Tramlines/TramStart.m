function TramStart()

    ImagDir='/home/peter/Dropbox/Lincoln/Year 3/Final Year Project/Project/Experiment/Dataset/images';
    ImgName='21_training.tif';
    %ImgName='section1.bmp';

    tramlineFileName = fullfile(ImagDir, ImgName(:,:,2));
    image = eyeread( tramlineFileName );    
    %figure; imshow(Image);
    
    %TL = TramlineVessels(image);
    % Inner=0;     % inner tram width 0 implies single line
    % Outer=5;     % outer tram width
    % Length=9;    % tram length
    % Thresh=0.0;  % response threshold
    % Its=20;      % Its*2 - small segment removal
    outerW = 15;
    innerW = 0;
    outerL = 15;
    innerL = 15;
    thresh = 0.0001;
    preProcess = 1;
    
    for s=9:2:19
        outerW = s;
        innerW = 0;
        outerL = s;
        innerL = s;
        thresh = 0.0001;
        preProcess = 1;

        TL = Tramline( image, outerW, innerW, outerL, innerL, thresh, preProcess );
        minSize1 =5;
        minSize2 =7;
        spurLength =21;
        isolated =3;
        ring =5;
        bridge =0;
        TLUp = CleanUp( TL, minSize1, minSize2, spurLength, isolated, ring,bridge );
        %figure; imshow(TLUp);
        %{
        ImgName='VesselPoints';
        trimFileName = fullfile(ImagDir, ImgName);
        imwrite( TLUp, trimFileName, 'bmp' );
        %}
        Img1=TLUp .* image;
        [i,j,v]=find(Img1);

        z{s}=[j i v];
        figure; imshow(image);
        hold on
        plot(z{s}(:,1),z{s}(:,2),'*b');
        t=strcat('outerw = ',num2str(s),'  , length = ',num2str(s),'  , clength = ', num2str(s));
        title(t);
        
    end
    pause(0.1);
