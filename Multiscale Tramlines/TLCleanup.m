function R = TLCleanup( TL, isolated, ring, minSize, spurLength )

% thin the original tram-line image to (by intention)
% one pixel wide lines (problems in that definition
% processed further below)
R = bwmorph( TL, 'thin', Inf );

if isolated
    % This section works, but is slow and unnecessary with the current settings I think
    % fill in entirely surrounded single pixels, repeat
    % until done (filling sometimes creates others 
    while 1
        R = TL | imerode( TL, [ 0 1 0; 1 0 1; 0 1 0 ] );
        R =  R | imerode( R,  [ 1 0 1; 0 0 0; 1 0 1 ] );
        if R == TL
            break;
        end
        TL = R;
    end
end

if ring
    % break any larger scale rings
    R = TLRingBreaker( R );
end

% thin again
R = bwmorph( R, 'thin', Inf );

% remove small objects
R = TLPruneSmall( R, minSize );

% Ditto - this section unnecessary with most settings, and slow
% % remove short side branches to leave clean, significant objects
R = TLRemoveShortSpur( R, spurLength );
