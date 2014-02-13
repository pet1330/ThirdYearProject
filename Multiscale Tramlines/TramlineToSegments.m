% TramlineToSegments
% Vascular segmentation routine
% Processes a tram-line image, extracting individual line segments, and
% returning them in a "segments" structure - a cell array of point lists

function SegList = TramlineToSegments( TL, spacing, minPixels )

% first, remove any "junction points", so that the remaining image
% contains only distinct segments

% Generate count of set neighbors of each pixel
Neighbours = imfilter( TL, [ 1 1 1; 1 0 1; 1 1 1 ] );

% first find the junctions
Junctions = Neighbours >= 3 & TL;

% Generate image with junctions removed
Elim = TL & ~ Junctions;

% find endpoints. These have only a single neighboring pixel in the image
[endY,endX] = find( filter2(ones(3), double(Elim)) == 2 & Elim );
noEndPoints = size( endY, 1 );
noSegs = 0;

% Process segments in turn
for i=1:noEndPoints
    % if endpoint has already been removed, skip (which happens if
    % we've already processed this segment from the other end)
    if Elim( endY(i), endX(i) ) == 0 
        continue;
    end
    
    % store last point (initially, the first end point)
    lastX = endX(i);
    lastY = endY(i);
    
    % clear the start pixel
    Elim( lastY, lastX ) = 0;
    
    % copy first end point into samples array
    sampleX(1) = lastX;
    sampleY(1) = lastY;            
    noSamples=1;

    % find subsequent pixels
    while 1
        % Find next adjacent pixel (there should be only one, but the code
        % should work even if there are two...).
        [getY,getX] = find( Elim( lastY-1:lastY+1, lastX-1:lastX+1 ) );
        
        % If at last pixel end the search. This is signified by not finding
        % any pixels in the search radius.
        if size(getY) == 0
            break;
        else
            % Calculate X and Y offset into region, using position in the 3x3 neighbourhood of
            % the last point.
            X = getX(1) + lastX - 2;
            Y = getY(1) + lastY - 2;
            
            % clear the current pixel from the region
            Elim( Y, X ) = 0;
            
            % update the record of the last pixel
            lastX = X;
            lastY = Y;

            % add the pixel to the sampled line
            noSamples = noSamples+1;
            sampleX(noSamples) = X;
            sampleY(noSamples) = Y;            
        end
    end
    
    % now resample the line at desired spacing, and add to the found segments
    if noSamples > minPixels
       [nextLineX, nextLineY ] = ResampleLine( sampleX, sampleY, spacing, 0.5, 0);
       nextLine = [nextLineX; nextLineY ];
       noSegs = noSegs+1;
       SegList{noSegs} = nextLine;
   end
   clear sampleX;
   clear sampleY;
end
