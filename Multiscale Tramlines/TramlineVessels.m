% TramlineVessels - high level routine to perform tram-line detection of blood vessels,
% returning a tram-line image.

function TL = TramlineVessels( Image )

% control parameters for the tram-line algorithm. These give a good sens/spec trade-off
Inner=0;     % inner tram width 0 implies single line
Outer=5;     % outer tram width
Length=9;    % tram length
%Thresh=0.0001;  % response threshold [0.000-0.002]
Its=20;      % Its*2 - small segment removal

Image1 = TLPreprocess( Image );
figure; imshow(Image1);

% Tramline filter with given widths and length
TLResponse = TramlineSingle( Image1, Outer, Length, Inner, Length );
figure; imshow(TLResponse);

% Threshold the tramline response, and remove outside retina and boundary of retina

Threshold= GetOutsideThreshold(Image1);
Thresh= GetOutsideThreshold(TLResponse);
Threshold= 0.44;
%Thresh= 0.000;
%{
Threshold=[0.4:0.005:0.48];
for j=1:length(Threshold)
    Thresh=[-0.005:0.001:0.005];
    for i=1:length(Thresh)
%} 
TL = ( TLResponse > Thresh ) & imerode(Image1 < Threshold, strel('disk',6) );
%figure; imshow(TL);

%{
t=strcat('Thresh = ',num2str(Thresh(i)),'  , Threshold = ',num2str(Threshold(j)));
title(t);
    end
end
%}

% cleanup the image by removing small objects, short spurs, holes, etc.
TL = TLCleanup( TL, 1,1,Its,1 );
figure; imshow(TL);


