function TL = CleanupTramline(TL, Mask, outerL )

% clean up a bit 'fill'
SE = strel('disk', 3 );

%removes from segments that have fewer than P pixels
%TL = bwareaopen(TL, round(4*outerL));
%figure; imshow(TL);

TL = bwmorph( TL, 'thin', Inf ); % thin, to clean up odd pixels after spur removal
%figure; imshow(TL);

%removes from segments that have fewer than P pixels
TL = bwareaopen(TL, round(0.5*outerL));
%figure; imshow(TL);

TL = imclose( TL, SE ); % Performs morphological closing (dilation followed by erosion).
TL = bwmorph( TL, 'fill' ,Inf); %Fills isolated interior pixels (individual 0s that are surrounded by 1s)
TL = bwmorph( TL, 'thin', Inf ); % thin
%figure; imshow(TL);

%removes from segments that have fewer than P pixels
TL = bwareaopen(TL, outerL);
%figure; imshow(TL);

TL = TL & imerode(Mask,strel('disk', 10 ));

return