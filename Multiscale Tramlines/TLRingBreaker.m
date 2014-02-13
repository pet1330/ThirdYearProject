% TLRingBreaker process the TL image by breaking
% any cycles (rings) that may exist, without bifurcating
% the object containing the ring. This is achieved by
% removing an arbitrary pixel from the ring.

function R = TLRingBreaker( TL )

R = TL;

% fill holes in the image. This will only change the
% image if there are holes; i.e. background areas not
% reachable by flood fill from the border

Holes = imfill( R, 'holes' ) & ~ R;

% if no holes, finished
if Holes == 0
    return;
end

% find the pixels in the image adjacent to the holes.
% this is the set of rings, plus possibly some non-ring
% areas that got included as they are inside a ring
Rings = R & imdilate( Holes, ones(3) );

% identify the true rings. These form a hole if filled
% individually.

% identify separate objects by connected components
[ConComps noComps] = bwlabel( Rings );

for i=1:noComps
    % extract individual potential ring, and corresponding hole
    Ring = ( ConComps == i );
    Hole = imfill( Ring, 'holes' ) & ~Ring;

    while sum(Hole(:)) ~= 0
        % process genuine ring
        
        % find pixels of the ring adjacent to pixels
        % of the object not part of the ring. 
        % these ones should not be removed, as that might
        % split the object.
        RingAdjacents = Ring & imdilate( imdilate( Ring, ones(3) ) & R & ~Ring, ones(3) );
        
        % arbitrarily remove a pixel of the remainder of the ring.
        % this doesn't necessarily finish the job, as we may have a 
        % double-ring, such as a figure-of-eight pattern, and only one
        % of the rings may be broken. Hence we recalculate the hole, and
        % its ring, and repeat until there is no longer a hole
        [y,x] = find( Ring & ~ RingAdjacents );
        
        % if all ring members are adjacent, remove any one arbitrarily
        if isempty( y )
           [y,x] = find( Ring );
        end 
        
        R(y(1),x(1))=0;
        Ring(y(1),x(1))=0;
        
        Hole = imfill( Ring, 'holes' ) & ~Ring;
        if sum(Hole(:)) ~= 0
            Ring = Ring & imdilate(Hole,ones(3));
        end
    end
end
 