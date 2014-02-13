% TLPruneShort removes short vessel segments. Vessels are nibbled
% away from end-points, then any with parts remaining are restored.
% This does not necessarily remove pathalogical objects with no end-points,
% i.e. loops
% TLPruneSmall can handle those, however...

function X = TLPruneShort( I, Its )

% do nothing on zero iterations
if Its == 0
    X = I;
    return;
end

% remove end points a number of times
X = I;
for i=1:Its
    X = imfilter(uint8(X),ones(3))>2 & X;
end

% restore original objects overlapping with
% remaining ones
[ x y ] = find( X );
X = bwselect( I, y, x );
