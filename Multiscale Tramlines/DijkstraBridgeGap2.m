% Function to try to connect up capillaries, using Dijkstra's shortest
% cost algorithm to connect together key points.
function R = DijkstraBridgeGap2( y1, x1, SearchRadius, funnelAngle, lengthWeighting, angleAllowedBetween, costThreshold )

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

[H,W] = size( DijkstraImage );

% Get boundary of active area, defined by radius but curtailed
% at image edges.
minx=max([x1-SearchRadius,2]);
maxx=min([x1+SearchRadius,W-1]);
miny=max([y1-SearchRadius, 2]);
maxy=min([y1+SearchRadius H-1]);

% set initial costs to the threshold. This means that the points do not yet have
% a valid path.
DijkstraCost(miny:maxy,minx:maxx)=costThreshold;

% but set the start point to cost zero, and set its trivial path max and min intensity, and length
DijkstraCost(y1,x1)=0;
DijkstraMin(y1,x1) = DijkstraImage(y1,x1);
DijkstraMax(y1,x1) = DijkstraImage(y1,x1);
DijkstraLen(y1,x1) = 0;

% divide search radius into components. A full-image component may have several
% separate segments in the search radius (e.g. a large network of connected vessels),
% but we treat these as separate within the radius to allow long-range self-connection,
% but not accidental short-range self-connection (e.g. by running along the vessel
% parallel to the identified self).
inRadiusComponents = bwlabel( DijkstraVessels( miny:maxy, minx:maxx ) );
thisLocalComponent = inRadiusComponents( y1-miny+1, x1-minx+1 );

% recover the identity of this component. Used to prevent self-connections
thisComponent = DijkstraComponents( y1, x1 );

% set initial availability map to all pixels that are not part of the starting
% component (prevents self connection) and whose contrast to the starting pixel
% does not exceed the naive bound (cuts down the search space)
%DijkstraAvailable( miny:maxy, minx:maxx ) = ( DijkstraComponents( miny:maxy, minx:maxx ) ~= thisComponent ) & ...
%                 abs( DijkstraImage( miny:maxy, minx:maxx ) - DijkstraImage( y1, x1 ) ) < costThreshold;
DijkstraAvailable( miny:maxy, minx:maxx ) = ( inRadiusComponents ~= thisLocalComponent ) & ...
                 abs( DijkstraImage( miny:maxy, minx:maxx ) - DijkstraImage( y1, x1 ) ) < costThreshold;
             
             
% also remove from consideration pixels outside the angular wedge projected from the line segment direction
DijkstraAvailable( miny:maxy, minx:maxx ) = DijkstraAvailable( miny:maxy, minx:maxx ) & ...
WedgeMask( maxx-minx+1, maxy-miny+1, funnelAngle, DijkstraAngle( y1, x1 ), x1-minx+1, y1-miny+1 );
             
% check that at least one available pixel is on another component (on a component suffices
% in the logic, since the availability map already excludes this component). If not, bail
% out immediately with failure.

% otherComps = DijkstraComponents( miny:maxy, minx:maxx ) .* DijkstraAvailable( miny:maxy, minx:maxx );
otherComps = inRadiusComponents .* DijkstraAvailable( miny:maxy, minx:maxx );
if max( otherComps(:) ) == 0 
    R = 0;
    return;
end

% surround starting point with an unavailable square at maximum radius, to prevent run-off
DijkstraAvailable( miny-1:miny-1, minx-1:maxx+1 ) = 0;
DijkstraAvailable( maxy+1:maxy+1, minx-1:maxx+1 ) = 0;
DijkstraAvailable( miny-1:maxy+1, minx-1:minx-1 ) = 0;
DijkstraAvailable( miny-1:maxy+1, maxx+1:maxx+1 ) = 0;

% initialize starting point to available, so that it is picked up in first iteration
DijkstraAvailable( y1, x1 ) = 1;

% temporarily clear the entry at start point, to simplify algorithm below. This prevents the
% first iteration from stopping as its on a component
DijkstraComponents( y1, x1 ) = 0;

% initialize search at start pixel
x = x1;
y = y1;

% Perform Dijkstra's algorithm
while 1

  % find minimum cost point
  minCost = min( min( DijkstraCost(miny:maxy,minx:maxx) + (1-DijkstraAvailable(miny:maxy,minx:maxx))*1e10 ) );
  
  % Check if algorithm has terminated without finding a valid route - i.e. all remaining tenative costs are
  % above threshold.
  if minCost >= costThreshold
    % fix up component map  
    DijkstraComponents( y1, x1 ) = thisComponent;
    
    % return indicator of failure
    R = 0;
    return;
  end

  % locate minimum cost point (break ties arbitrarily)
  [ my mx ] = find( DijkstraCost(miny:maxy,minx:maxx) + (1-DijkstraAvailable(miny:maxy,minx:maxx))*1e10 == minCost );
  x = minx-1+mx(1);
  y = miny-1+my(1);
  
  % Mark this point as unavailable, to prevent returning to it
  DijkstraAvailable(y,x) = 0;
  
  % check if algorithm has found a target point (i.e. a point on another component).
  % If so, it has finished successfully. break this loop to move to route recovery section
  if DijkstraComponents( y, x ) > 0 
    break;
  end
    
  % Update neighbours' tentative distances and predecessors. Only available points adjacent
  % to the current point need to be updated.

  % recover max, min and length at current point
  M = DijkstraMax( y, x );
  m = DijkstraMin( y, x );
  L = DijkstraLen( y, x );
  
  newL = L+1;
  
  % The eight neighboring point update sections work as follows. We consider the effect of routing
  % the new point from the current point. We work out the path max and min intensity levels by
  % comparing the new point intensity with the max and min so far on those paths. The new length
  % would be the current point length plus one. The cost is determined from these factors. The
  % cost function is designed so that the difference between min and max intensity on the curve
  % is the primary factor, with the length acting as a tie-breaker in the event of equal range
  % (hence the length is multiplied by a small amount and added to the range). If the
  % cost is lower than the existing cost, the record is updated at the new point.
  % No update is attempted if the point is unavailable, which may occur because: a) its a point on
  % the starting component; b) its a point that has already been visited and whose best path is
  % therefore already known; c) its a point on the outer search radius; d) its a point whose intensity
  % difference from the start point naively guarantees that it can't be part of a valid path.
  
  if DijkstraAvailable( y-1, x-1 ) == 1
      % Update (y-1,x-1)
      newM = max( [ M DijkstraImage(y-1,x-1) ] );
      newm = min( [ m DijkstraImage(y-1,x-1) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y-1,x-1)
          DijkstraCost(y-1,x-1) = cost;
          DijkstraMax(y-1,x-1) = newM;
          DijkstraMin(y-1,x-1) = newm;
          DijkstraLen(y-1,x-1) = L;
          DijkstraPreX(y-1,x-1)=1;
          DijkstraPreY(y-1,x-1)=1;
      end
  end
  
  if DijkstraAvailable( y, x-1 ) == 1
      % Update (y,x-1)
      newM = max( [ M DijkstraImage(y,x-1) ] );
      newm = min( [ m DijkstraImage(y,x-1) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y,x-1)
          DijkstraCost(y,x-1) = cost;
          DijkstraMax(y,x-1) = newM;
          DijkstraMin(y,x-1) = newm;
          DijkstraLen(y,x-1) = L;
          DijkstraPreX(y,x-1)=1;
          DijkstraPreY(y,x-1)=0;
      end
  end
  
  if DijkstraAvailable( y+1, x-1 ) == 1
      % Update (y+1,x-1)
      newM = max( [ M DijkstraImage(y+1,x-1) ] );
      newm = min( [ m DijkstraImage(y+1,x-1) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y+1,x-1)
          DijkstraCost(y+1,x-1) = cost;
          DijkstraMax(y+1,x-1) = newM;
          DijkstraMin(y+1,x-1) = newm;
          DijkstraLen(y+1,x-1) = L;
          DijkstraPreX(y+1,x-1)=1;
          DijkstraPreY(y+1,x-1)=-1;
      end
  end
  
  if DijkstraAvailable( y-1, x ) == 1
      % Update (y-1,x)
      newM = max( [ M DijkstraImage(y-1,x) ] );
      newm = min( [ m DijkstraImage(y-1,x) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y-1,x)
          DijkstraCost(y-1,x) = cost;
          DijkstraMax(y-1,x) = newM;
          DijkstraMin(y-1,x) = newm;
          DijkstraLen(y-1,x) = L;
          DijkstraPreX(y-1,x)=0;
          DijkstraPreY(y-1,x)=1;
      end
  end
  
  if DijkstraAvailable( y+1, x ) == 1
      % Update (y+1,x)
      newM = max( [ M DijkstraImage(y+1,x) ] );
      newm = min( [ m DijkstraImage(y+1,x) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y+1,x) & cost < costThreshold
          DijkstraCost(y+1,x) = cost;
          DijkstraMax(y+1,x) = newM;
          DijkstraMin(y+1,x) = newm;
          DijkstraLen(y+1,x) = L;
          DijkstraPreX(y+1,x)=0;
          DijkstraPreY(y+1,x)=-1;
      end
  end
  
  if DijkstraAvailable( y-1, x+1 ) == 1
      % Update (y-1,x+1)
      newM = max( [ M DijkstraImage(y-1,x+1) ] );
      newm = min( [ m DijkstraImage(y-1,x+1) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y-1,x+1)
          DijkstraCost(y-1,x+1) = cost;
          DijkstraMax(y-1,x+1) = newM;
          DijkstraMin(y-1,x+1) = newm;
          DijkstraLen(y-1,x+1) = L;
          DijkstraPreX(y-1,x+1)=-1;
          DijkstraPreY(y-1,x+1)=1;
      end
  end
  
  if DijkstraAvailable( y, x+1 ) == 1
      % Update (y,x+1)
      newM = max( [ M DijkstraImage(y,x+1) ] );
      newm = min( [ m DijkstraImage(y,x+1) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y,x+1)
          DijkstraCost(y,x+1) = cost;
          DijkstraMax(y,x+1) = newM;
          DijkstraMin(y,x+1) = newm;
          DijkstraLen(y,x+1) = L;
          DijkstraPreX(y,x+1)=-1;
          DijkstraPreY(y,x+1)=0;
      end
  end
  
  if DijkstraAvailable( y+1, x+1 ) == 1
      % Update (y+1,x+1)
      newM = max( [ M DijkstraImage(y+1,x+1) ] );
      newm = min( [ m DijkstraImage(y+1,x+1) ] );
      cost = ( newM - newm ) + lengthWeighting * newL;
      if cost < DijkstraCost(y+1,x+1)
          DijkstraCost(y+1,x+1) = cost;
          DijkstraMax(y+1,x+1) = newM;
          DijkstraMin(y+1,x+1) = newm;
          DijkstraLen(y+1,x+1) = L;
          DijkstraPreX(y+1,x+1)=-1;
          DijkstraPreY(y+1,x+1)=-1;
      end
  end
  
end

% reset temporarily altered component label at start point
DijkstraComponents( y1, x1 ) = thisComponent;

% route recovery section. Follow predecessor route from target point to source point,
% setting the pixels as you go.

% bail out if no valid routes were found
if DijkstraPreX(y,x) == 0 & DijkstraPreY(y,x) == 0 
  R=0;
  return;
end

%
% Refuse connection if angle at this point is incompatible with the angle
% at the starting point. This is assuming pre-processing so that only
% end points are present, of course. 
% The angle used is the angle between the line joining the two segments,
% and the segment angles themselves
%
lineAngle = atan2( y-y1, x-x1 );
if AngleBetween( DijkstraAngle( y1, x1 ), lineAngle ) > angleAllowedBetween | ...
   AngleBetween( DijkstraAngle( y, x )+pi, lineAngle ) > angleAllowedBetween 
    R=0;
    return;
end

% relabel found component to same as the current one. This prevents
% joining up from both ends of one component to another (as the second
% one is barred as a self-join
component = bwselect( DijkstraComponents, x, y );
DijkstraComponents( find(component) ) = thisComponent;

% move back to point before the terminating one
% note its necessary to pre-compute xinc,yinc to
% avoid partial update confusion
xinc = DijkstraPreX(y,x);
yinc = DijkstraPreY(y,x);
x = x+xinc;
y = y+yinc;

% now move back to the start, adding the pixels on the route to the
% current segment

its=0;
while x ~= x1 | y ~= y1 
  DijkstraVessels(y,x) = 1;
  DijkstraComponents(y,x) = thisComponent;
  xinc = DijkstraPreX(y,x);
  yinc = DijkstraPreY(y,x);
  x = x+xinc;
  y = y+yinc;
  its = its+1;
  if its > 10000
      disp( 'Internal error in DijkstraBridgeGap: seem to be stuck in a routing loop...' );
      R=0;
  end
end
R=1;
