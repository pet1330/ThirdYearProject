% TLPruneSmall - removes small segments. As this uses connected components,
% it is inefficient (having to loop over all regions, of which there may be
% many). It is therefore recommended to run TLPruneShort, which is faster
% but may miss some entities, before running this one.

function R = TLPruneSmall( TL, minSize )

% first, "prune short" by morphological end-point removal - this is faster than object removal,
% and gets rid of most of the unwanted objects.

TL = TLPruneShort( TL, floor( (minSize-1) / 2 ) );

R = TL;

% do nothing on zero threshold
if minSize == 0
    return;
end

% find endpoints and junction points. These provide sparse seed points for virtually
% all objects, barring only well-formed loops, and those are extremely unlikely to
% be below the threshold.
seeds = bwmorph( imfilter(TL, ones(3)) ~= 3 & TL, 'thin', Inf );
[ObjY ObjX] = find( seeds );
noObjects = size(ObjY,1);

R = TL;

for i=1:noObjects
    % skip if this object has already been processed
    if TL( ObjY(i), ObjX(i) ) == 0
        continue;
    end
    
%if i == 328
if i == 196
    dummy=1;
end

    % first, traverse the object counting the number of pixels
    
    % get start pixel
    y = ObjY(i);
    x = ObjX(i);

    % put it on the stack
    stackY(1) = y;
    stackX(1) = x;
    len = 1;

    % remember and clear it
    remY(1) = y;
    remX(1) = x;
    TL( y, x ) = 0;
    count = 1;
    
    while ( len > 0 )
        % if the object is over-sized, we can stop counting - its not going to
        % be removed anyway.
        if count >= minSize
            break
        end
        
        % check neighbourhood of next pixel from stack
        y = stackY(len);
        x = stackX(len);
        
        % clear pixel on TL image, remember position, and count size
        
        % decrement stack
        len = len-1;
        
        % stack any neighbors, clear from TL image, remember positions: eight cases here
        if TL( y-1, x-1 ) == 1
            len = len+1;
            stackY(len) = y-1;
            stackX(len) = x-1;
            
            TL( y-1, x-1 ) = 0;
            count = count+1;
            remY(count) = y-1;
            remX(count) = x-1;
        end
        
        if TL( y-1, x ) == 1
            len = len+1;
            stackY(len) = y-1;
            stackX(len) = x;
            
            TL( y-1, x ) = 0;
            count = count+1;
            remY(count) = y-1;
            remX(count) = x;
        end
        
        if TL( y-1, x+1 ) == 1
            len = len+1;
            stackY(len) = y-1;
            stackX(len) = x+1;
            
            TL( y-1, x+1 ) = 0;
            count = count+1;
            remY(count) = y-1;
            remX(count) = x+1;
        end
        
        if TL( y, x-1 ) == 1
            len = len+1;
            stackY(len) = y;
            stackX(len) = x-1;
            
            TL( y, x-1 ) = 0;
            count = count+1;
            remY(count) = y;
            remX(count) = x-1;
        end
        
        if TL( y, x+1 ) == 1
            len = len+1;
            stackY(len) = y;
            stackX(len) = x+1;
            
            TL( y, x+1 ) = 0;
            count = count+1;
            remY(count) = y;
            remX(count) = x+1;
        end
        
        if TL( y+1, x-1 ) == 1
            len = len+1;
            stackY(len) = y+1;
            stackX(len) = x-1;
            
            TL( y+1, x-1 ) = 0;
            count = count+1;
            remY(count) = y+1;
            remX(count) = x-1;
        end
        
        if TL( y+1, x ) == 1
            len = len+1;
            stackY(len) = y+1;
            stackX(len) = x;
            
            TL( y+1, x ) = 0;
            count = count+1;
            remY(count) = y+1;
            remX(count) = x;
        end
        
        if TL( y+1, x+1 ) == 1
            len = len+1;
            stackY(len) = y+1;
            stackX(len) = x+1;
            
            TL( y+1, x+1 ) = 0;
            count = count+1;
            remY(count) = y+1;
            remX(count) = x+1;
        end
    end
    
    % If the object is undersized, remove it from the result image
    if count < minSize
         R( remY(1:count), remX(1:count) ) = 0;
    else
        for j=1:count
            TL( remY(1:count), remX(1:count) ) = 1;
        end
    end
end