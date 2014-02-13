% TramlineToSegments2
% Vascular segmentation routine
% Processes a tram-line image, extracting individual line segments, and
% returning them in a "segments" structure - a cell array of point lists
% This version includes bridging across gaps and junctions

function SegList = TramlineToSegments2( TL, DonotConnect, splineAlg )
    if nargin < 3
        %Bashir
        splineAlg=1;
    end
    if nargin < 2
        DonotConnect = 0; % the default is to connect
    end
    SegList=[];
    minLength = 2; % minmimum length, in pixels, of a segment to be considered useful and therefore extracted
    
    sampleSpacing = 0.5; %1 separation of width samples along vessel
    sampleIncrement = 0.1;

    % first, remove any "junction points", so that the remaining image
    % contains only distinct segments

    %searchRadius = 8;
%Bashir

    searchRadius = 10;
    funnelAngle = pi/3;

    % structures for checking eight neighbours
    conn8X = [ -1  0 +1 -1 +1 -1  0 +1 ];
    conn8Y = [ -1 -1 -1  0  0 +1 +1 +1 ];

    % Generate count of set neighbors of each pixel
    %Neighbours = imfilter( TL, [ 1 1 1; 1 0 1; 1 1 1 ] );
%Bashir
 Neighbours = imfilter( TL*1, [ 1 1 1; 1 0 1; 1 1 1 ] );

    % first find the junctions
    Junctions = Neighbours >= 3 & TL;
    %figure; imshow(Junctions);

    % Generate image with junctions removed. All tracing is done on here.
    Elim = TL & ~ Junctions;
    %figure; imshow(TL);
    %figure; imshow(Elim);
    % find endpoints. These have only a single neighboring pixel in the Elim image
    %EndPoints = imfilter(Elim, ones(3)) < 3 & Elim;
%Bashir
EndPoints = imfilter(Elim*1, ones(3)) < 3 & Elim;

    % extract end-point list structure
    [endY,endX] = find( EndPoints );
    noEndPoints = size( endY, 1 );

%bashir    
 global Trace;
% if Trace
%     global GBImg;
%     figure; imshow(GBImg); hold on
%     for i=1:noEndPoints
%         plot(endX(i),endY(i),'r+');
%     end
%     figure; imshow(Elim); hold on
% end
    % build ep label array - used to get from an x,y location to the ep list structure
    epLabels = zeros( size(TL) );
    for i=1:noEndPoints
        epLabels( endY(i), endX(i) ) = i;
    end

    noSegs = 0;

    % store direction vector angles: initialize to value 4, indicating no angle available
    epTheta = ones( noEndPoints, 1 ) * 4;

    %Bashir
    s=size(TL);
% Calculate direction vectors at end points. These are estimated by 
% tracing back two pixels, where available, or one if not, or not at
% all if no neighbors.
for i=1:noEndPoints
    eY = endY(i);
    eX = endX(i);
    
    % temporarily clear the end-point
    Elim( eY, eX ) = 0;
    
    % find neighboring point
    for n=1:8
        %Bashir: if eX or eY close by 8 to rim then ignore that point and continue
        if eX < 9 || eY < 9 || eX > s(2)-9 || eY > s(1)-9
            continue
        end
        if Elim( eY+conn8Y(n), eX+conn8X(n) ) == 1
            neY = eY+conn8Y(n);
            neX = eX+conn8X(n);
            
            % temporarily clear neighbour
            Elim( eY+conn8Y(n), eX+conn8X(n) ) = 0;
            
            % find neighbour's neighbour
            for n2=1:8
                if Elim( neY+conn8Y(n2), neX+conn8X(n2) ) == 1
                    % set direction angle using diff between second neighbour and end point
                    epTheta(i) = atan2( -(conn8Y(n)+conn8Y(n2)), -(conn8X(n)+conn8X(n2)) );
                    
                    % finished search
                    break;
                end  
            end
            
            % reset the neighbour
            Elim( eY+conn8Y(n), eX+conn8X(n) ) = 1;
            
            % if there was not a second neighbor, assign direction from single neighbour
            % in this case the direction angle will not have been set yet
            if epTheta(i) == 4
                epTheta(i) = atan2( -conn8Y(n), -conn8X(n) );
            end
            
            % finished search
            break;
        end
    end
    
    % reset the end-point
    Elim( eY, eX ) = 1;
end
clear TL Junctions Neighbours EndPoints;

%------------------------------------------------------------------------
if ~DonotConnect % connect

    % fill in cost matrix for matching end-points. This is based on the distance of each end-point
    % from the direction vector projected from the other end point. Matches are disallowed if
    % the end-points are separated by more than the search radius, or either end-point is outside
    % the "direction funnel" projected from the other one
    % cost matrix is symmetric, which halves the cost
    costMatrix = ones(noEndPoints) * Inf;
    for i=1:noEndPoints
        for j=1:i-1
            dist = norm( [endY(j)-endY(i), endX(j)-endX(i)] );
            if  dist < searchRadius
                % treat the case of no direction vector at one end as maximum acceptable angle
                if epTheta(i) == 4 
                    angle1 = funnelAngle;
                else
                    angle1 = AngleBetween( atan2( endY(j)-endY(i), endX(j)-endX(i) ), epTheta(i) );
                end

                if epTheta(j) == 4 
                    angle2 = funnelAngle;
                else
                    angle2 = AngleBetween( atan2( endY(i)-endY(j), endX(i)-endX(j) ), epTheta(j) );
                end

                if  angle1 <= funnelAngle && angle2 <= funnelAngle
                    costMatrix(i,j) = dist * ( sin( angle1 ) + sin( angle2 ) );
                    costMatrix(j,i) = costMatrix(i,j);
                end
            end
        end
    end

    % Now assign bridging pairs, trying to minimize the bridging cost
    % iteratively update assignment, assigning each to its lowest cost available partner
    bridge = zeros( 1, noEndPoints );
    update = 1;
    while update == 1
        update = 0;
        for i=1:noEndPoints
            % reassign i'th
            for j=1:noEndPoints
                cost = costMatrix(i,j);
                if ~isinf(cost)
                    if ( bridge(i) == 0 || cost < costMatrix(i,bridge(i)) ) && ( bridge(j) == 0 || cost < costMatrix(j,bridge(j)) )  
                        bridge(i) = j;
                        bridge(j) = i;
                        update = 1;
                    end
                end
            end
        end
    end
else
    bridge = zeros( 1, noEndPoints );
end
%-------------------------------------------------------------------------
% Process segments in turn
for i=1:noEndPoints
    % if endpoint has already been removed, skip (which happens if
    % we've already processed this segment from the other end)
    if Elim( endY(i), endX(i) ) == 0 
        continue;
    end
    
    % don't process internal (bridged) end points - they have been incorporated into some
    % longer segment
    if bridge( epLabels( endY(i), endX(i) ) ) ~= 0
        continue;
    end
    
    % If above checks are passed, process the segment
    
    % store first pixel
    pX = endX(i);
    pY = endY(i);
    
    % initialize segment length to zero
    noSamples=0;
    
    % find subsequent pixels
    while 1
        noSamples = noSamples+1;
        
        % clear the current pixel
        Elim( pY, pX ) = 0;
% if pX == 205 & pY == 455
%     dummy=1;
% end
        % copy current pixel into samples array
        sampleX(noSamples) = pX;
        sampleY(noSamples) = pY;
        
        % if a bridge point, do the bridging. This rather laborsome code bridges across
        % pixels.
        ep = epLabels(pY,pX);
        if ep ~= 0 && bridge(ep) ~= 0
            bep = bridge(ep);
            xdiff = abs(endX(bep)-pX);
            ydiff = abs(endY(bep)-pY);
            if xdiff > ydiff
                if endX(bep) > pX
                    for j=1:endX(bep)-pX
                        noSamples = noSamples+1;
                        sampleX(noSamples) = pX+j;
                        sampleY(noSamples) = round( pY + (endY(bep)-pY)*j/(endX(bep)-pX) );
                    end
                else
                    for j=1:pX-endX(bep)
                        noSamples = noSamples+1;
                        sampleX(noSamples) = pX-j;
                        sampleY(noSamples) = round( pY + (endY(bep)-pY)*j/(pX-endX(bep)) );
                    end
                end
            else
                if endY(bep) > pY
                    for j=1:endY(bep)-pY
                        noSamples = noSamples+1;
                        sampleY(noSamples) = pY+j;
                        sampleX(noSamples) = round( pX + (endX(bep)-pX)*j/(endY(bep)-pY) );
                    end
                else
                    for j=1:pY-endY(bep)
                        noSamples = noSamples+1;
                        sampleY(noSamples) = pY-j;
                        sampleX(noSamples) = round( pX + (endX(bep)-pX)*j/(pY-endY(bep)) );
                    end
                end
            end
            
            % if we did just bridge, set the next pixel ready for continued following
            pY = endY(bep);
            pX = endX(bep);
            found = 1;
            
            % clear the bridging indicator for the bridged-to segment, to prevent bouncing back and forth
            bridge(bep) = 0;
        else
            % did not bridge - find next adjacent pixel
            found=0;
            for n=1:8
                %Bashir: if eX or eY close by 8 to rim then ignore that point and continue
                if pX < 9 || pY < 9 || pX > s(2)-9 || pY > s(1)-9
                    continue
                end
                if Elim( pY+conn8Y(n), pX+conn8X(n) ) == 1
                    pY = pY+conn8Y(n);
                    pX = pX+conn8X(n);
                    found=1;
                    break;
                end
            end
            
        end
        
        % If at last pixel end the search. This is signified by not finding
        % any pixels in the search radius.
        if found == 0
            break;
        end
    end
    
    % now resample the line at desired spacing, and add to the found segments
    % ResampleLine get error for segment length of 1 pixcel 
    if noSamples >= minLength
        [nextLineX, nextLineY ] = ResampleLine( sampleX, sampleY, sampleSpacing, sampleIncrement, splineAlg);
        nextLine = [nextLineX' nextLineY' ];
        noSegs = noSegs+1;
        SegList{noSegs} = nextLine;
    end
    clear sampleX;
    clear sampleY;
end
if Trace
    global GBImg;
    figure; imshow(GBImg); hold on
    for s= 1:size(SegList,2)
        plot(SegList{s}(:,1),SegList{s}(:,2),'+g')
    end
end
% There could possibly be segments left, if there are any complete self-contained rings - these don't have
% end-points
% If so, we can process them by detecting any remaining point, and running the segment detector around
[ ringY ringX ] = find( Elim );
while size( ringY ) > 0
    pX = ringX(1);
    pY = ringY(1);
    
    noSamples = 0;
    
    while 1
        noSamples = noSamples+1;
        
        % clear the current pixel
        Elim( pY, pX ) = 0;
        
        % copy current pixel into samples array
        sampleX(noSamples) = pX;
        sampleY(noSamples) = pY;
        
        % Find next adjacent pixel (there should be only one, but the code
        % should work even if there are two...).
        found=0;
        for n=1:8
            %Bashir: if eX or eY close by 8 to rim then ignore that point and continue
            if pX < 9 || pY < 9 || pX > s(2)-9 || pY > s(1)-9
                continue
            end
            if Elim( pY+conn8Y(n), pX+conn8X(n) ) == 1
                pY = pY+conn8Y(n);
                pX = pX+conn8X(n);
                found=1;
                break;
            end
        end
        
        % If at last pixel end the search. This is signified by not finding
        % any pixels in the search radius.
        if found == 0
            break;
        end
    end
    
    % now resample the line at desired spacing, and add to the found segments
    if noSamples >= minLength
        [nextLineX, nextLineY ] = ResampleLine( sampleX, sampleY, sampleSpacing, sampleIncrement, splineAlg );
        nextLine = [nextLineX' nextLineY' ];
        noSegs = noSegs+1;
        SegList{noSegs} = nextLine;
    end
    clear sampleX;
    clear sampleY;
    
    [ ringY ringX ] = find( Elim );
end