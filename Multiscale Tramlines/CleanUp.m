% cleanup the image by removing small objects, short spurs, holes, etc.

function TL = CleanUp( image, minSize1, minSize2, spurLength, isolated, ring, bridge )

% cleanup the image by removing small objects, short spurs, holes, etc.
TL = TLCleanup( image, isolated, ring, minSize1, 0 );
%figure; imshow(TL);

if bridge
    % bridge gaps using Dijkstra algorithm
    TL = DijkstraJoinSegments2( image, TL );
end

% secondary cleanup
TL = TLCleanup( TL, 0, 0, minSize2, spurLength );
