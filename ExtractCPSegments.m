function [TL] = ExtractCPSegments(Imgf, Mask)
RONH = size(Imgf,1)*9.85/100;
MaxVW = ceil(RONH*22.86/100);

TramThresh=0.00999; %0.15; %4*0.0125;  %  0.001
outerW=ceil(MaxVW/2);
innerW=0;
outerL=ceil(MaxVW);
innerL=outerL;

%Get tramline results
% Tramline - high level routine to perform tramline detection of blood vessels,
% returning a tram-line image.

% Tramline filter with given widths and length
TLOResponse = TramlineSingle( Imgf, outerW, outerL, innerW, innerL );
%figure; imshow(TLOResponse);

%this approch give the best results when the threshold equal 0.0045
TL = (TLOResponse > TramThresh) & Mask;

clear TLOResponse

% clean up a bit, remove a border region
% remove small spurs, thin: to clean up odd pixels after spur removal
TL = CleanupTramline(TL, Mask, floor(outerL*2/4));
% figure; imshow(TL);

return