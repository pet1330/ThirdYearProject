function R = DijkstraJoinSegments2( Image, TL )

% use some globals for efficient memory management
global DijkstraImage;
global DijkstraCost;
global DijkstraMin;
global DijkstraMax;
global DijkstraLen;
global DijkstraPreX;
global DijkstraPreY;
global DijkstraVessels;
global DijkstraComponents;
global DijkstraAngle;

[Rows,Cols] = size(Image);

% initialize working structures
DijkstraCost = zeros(Rows,Cols);
DijkstraMin = zeros(Rows,Cols);
DijkstraMax = zeros(Rows,Cols);
DijkstraLen = zeros(Rows,Cols);
DijkstraPreX = zeros(Rows,Cols);
DijkstraPreY = zeros(Rows,Cols);
DijkstraAvailable = zeros(Rows,Cols);
DijkstraAngle = zeros(Rows,Cols);

% copy global image
DijkstraImage = Image;

% generate component map
Components = bwlabel( TL );

[ eY eX ] = find( imfilter( double(TL), ones(3) ) < 3 & TL );

noEndPoints = size( eY, 1 );

% find the angle at the end of the vessel
AngleNibbleImage = TL;
for i=1:noEndPoints
    % store last point (initially, the first end point)
    lastX = eX(i);
    lastY = eY(i);
    
    % clear the start pixel
    AngleNibbleImage( lastY, lastX ) = 0;

    % trace back a number of pixels
    for j=1:5
        % Find next adjacent pixel (there should be only one, but the code
        % should work even if there are two...).
        [getY,getX] = find( AngleNibbleImage( lastY-1:lastY+1, lastX-1:lastX+1 ) );
        
        % If at last pixel end the search. This is signified by not finding
        % any pixels in the search radius.
        %if size(getY) == 0
        %Bashir
        if isempty(getY)
            break;
        else
            % Calculate X and Y offset into region, using position in the 3x3 neighbourhood of
            % the last point.
            X = getX(1) + lastX - 2;
            Y = getY(1) + lastY - 2;
            
            % clear the current pixel from the region
            AngleNibbleImage( Y, X ) = 0;
            
            % update the record of the last pixel
            lastX = X;
            lastY = Y;
        end
    end

    % calculate the angle
    DijkstraAngle( eY(i), eX(i) ) = atan2( eY(i)-lastY, eX(i)-lastX );
end


% to join end points only, generate a version of the TL image and component mask containing only
% end points. This forces the bridging algorithm to join up only end points
%DijkstraVessels = imfilter( TL, ones(3) ) < 3 & TL;
%Bashir
DijkstraVessels = imfilter( double(TL), ones(3) ) < 3 & TL;
DijkstraComponents = Components .* double(DijkstraVessels);

% control parameters
funnelAngle = pi/8;
angleAllowedBetween = pi/8;
lengthWeighting = 1e-3;
costThreshold = 0.03;
searchRadius=15;

for i=1:noEndPoints
    DijkstraBridgeGap2( eY(i), eX(i), searchRadius, funnelAngle, lengthWeighting, angleAllowedBetween, costThreshold );
end


%
% join to any point on segments (for resolving branches as opposed to bridging gaps)
%

% add all tramlines to the image, including original ones and bridging ones
DijkstraVessels = TL | DijkstraVessels;

% tidyup the tramline image
DijkstraVessels = bwmorph( DijkstraVessels, 'thin', Inf );

% regenerate components
Components = bwlabel( DijkstraVessels );
DijkstraComponents = Components;

% find end points
[ eY eX ] = find( imfilter( TL, ones(3) ) < 3 & TL );
noEndPoints = size( eY, 1 );

% control parameters
funnelAngle = pi/8;
angleAllowedBetween = pi;
lengthWeighting = 1e-3;
costThreshold = 0.03;
searchRadius = 5; % do short ones first
for i=1:noEndPoints
    DijkstraBridgeGap2( eY(i), eX(i), searchRadius, funnelAngle, lengthWeighting, angleAllowedBetween, costThreshold );
end

%
% Now repeat junction closing part with a larger search radius
%

% tidyup the tramline image
DijkstraVessels = bwmorph( DijkstraVessels, 'thin', Inf );

% regenerate components
Components = bwlabel( DijkstraVessels );
DijkstraComponents = Components;

% find end points
[ eY eX ] = find( imfilter( TL, ones(3) ) < 3 & TL );
noEndPoints = size( eY, 1 );

% control parameters
funnelAngle = pi/8;
angleAllowedBetween = pi;
lengthWeighting = 1e-3;
costThreshold = 0.03;
searchRadius = 15;
for i=1:noEndPoints
    DijkstraBridgeGap2( eY(i), eX(i), searchRadius, funnelAngle, lengthWeighting, angleAllowedBetween, costThreshold );
end

% return the resulting image
R = DijkstraVessels;

% clear the globals
clear global DijkstraImage;
clear global DijkstraCost;
clear global DijkstraMin;
clear global DijkstraMax;
clear global DijkstraLen;
clear global DijkstraPreX;
clear global DijkstraPreY;
clear global RetinalImage;
clear global DijkstraVessels;
clear global DijkstraComponents; 
 