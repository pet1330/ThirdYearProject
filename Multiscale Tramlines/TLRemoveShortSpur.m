function R = TLRemoveShortSpur( TL, Length )

% do nothing on zero parameter
if Length == 0
    R = TL;
    return;
end

% Generate count of set neighbors of each pixel
Neighbours = imfilter( TL, [ 1 1 1; 1 0 1; 1 1 1 ] );

% first find the junctions
Junctions = Neighbours >= 3 & TL;

% Generate image with junctions removed
Elim = TL & ~ Junctions;

% Generate region map of segment image
Segments = bwlabel( Elim );
noSegments = max( Segments(:) );

% detect all junctions, including identifying contiguous "junction sets",
% as junction points are not always isolated. 
JunctionMap = bwlabel( Junctions );

% process each junction point in turn, and look for adjacent segments. Record
% the junction number against the segment number. If a segment has a second,
% different, number, then it has two adjacent junctions and is internal (marked
% by a -1. Otherwise it is internal.
R = TL;
[ juncY juncX ] = find( JunctionMap );
noJunctionPoints = size( juncY, 1 );
segmentNeighbor = zeros( 1, noSegments );

yOff = [ -1 -1 -1; 0 0 0; 1 1 1 ];
xOff = [ -1 0 1; -1 0 1; -1 0 1 ];

for i=1:noJunctionPoints
    % retrieve the number of the junction at this point
    juncNo = JunctionMap( juncY(i), juncX(i) );
    
    if juncX(i) > 445 & juncX(i) < 452 & juncY(i) > 375 & juncY(i) < 382 
        dummy=1;
    end
    
    % for each neighboring point
    for j=[ 1:4 6:9 ]
        % get the segment number there
        segNo = Segments( juncY(i)+yOff(j), juncX(i)+xOff(j) );
        
        % if there is an adjacent segment point there, process it
        if segNo > 0
            if segmentNeighbor(segNo) == 0
                segmentNeighbor(segNo) = juncNo;
            elseif segmentNeighbor(segNo) ~= -1 & segmentNeighbor(segNo) ~= juncNo
                segmentNeighbor(segNo) = -1;
            end
        end
    end
end

% now remove any end segments that are smaller than the threshold
for i=1:noSegments
    if i==651
        dummy=1;
    end
    if segmentNeighbor(i) ~= -1 
        segment = ( Segments == i );
        
        if sum( segment(:) ) <= Length
            R = R & ~ segment;
        end
    end
end
        
% thin the image to remove spurs left on the junction points after segments
% have been removed. A single iteration should suffice?
R = bwmorph( R, 'thin', 1 );
