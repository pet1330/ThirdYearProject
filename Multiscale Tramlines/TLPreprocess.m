function Result = TLPreprocess( Image,diskSize, mask )

if nargin < 2
    diskSize=15;
end

 %------------------------------------------
    % Just an idea
    %Normalize an image based on its mean and sigma
%     meanimg = mean2(Image(find(mask)));
%     sigmaimg = std2(Image(find(mask))); 
%     Image = mmnorm((Image-meanimg)/ sigmaimg, mask); 
    %------------------------------------------

%-----------------------------------------------
%Other Idea
%Unsharp contrast enhancement filter
%H = fspecial('unsharp');
%Image = imfilter(Image,H,'replicate'); %   figure; imshow(Image);
% Image=  adapthisteq( Image); %   figure; imshow(Image);
%2-D adaptive noise-removal filtering
%Image = wiener2(Image);   %figure; imshow(Image);
%Adjust image intensity values or colormap
%stretchlim: Find limits to contrast stretch image
%Image=  imadjust( Image, stretchlim(Image) ); %   figure; imshow(Image);


%-----------------------------------------------
    
%erode any blood vessels (dilate command since removing dark)
Result = imdilate( Image, strel( 'disk', diskSize ) );
%figure; imshow(Result);

%dilate to help isolate light artefacts
Result = imerode( Result, strel( 'disk', 15 ) );

%apply a smoothing filter
Result = imfilter( Result, fspecial( 'disk', 7 ) );
%figure; imshow(Result);

    
%"tophat" - difference original image from smoothed, de-vesseled image
Result = double(Image)-double(Result);

%2-D adaptive noise-removal filtering
%Result = wiener2(Result);   %figure; imshow(Result);
 
%stretch histogram
%Result =  hist_stretch(Result); %    figure; imshow(Result); 
    
    
%Morphological open cleans up the vessels and removes some speckle white patches
%Result = imopen( Result, strel( 'disk', 3 ) );
%figure; imshow(Result);

%------------------------------------------
    % Just an idea
    %Normalize an image based on its mean and sigma
    %meanimg = mean2(Result(find(mask)));
    %sigmaimg = std2(Result(find(mask))); 
    %Result = (Result-meanimg)/ sigmaimg; %  figure; imshow(mmnorm(Result)); title('Result')
    %------------------------------------------
    
%Normalise the image
Result = mmnorm(Result, mask);
return