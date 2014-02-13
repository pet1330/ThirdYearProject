% GetOutsideThreshold returns a threshold that can be used to
% segment out the exterior of the retina

function Theta = GetOutsideThreshold( I )

minSD = 0.002;

% get mean and sd of intensities in the upper left corner (bound to be outside retina)
mu = mean2( I(3:20,3:20) );
sd = std2( I(3:20,3:20) );

if sd < minSD
    sd = minSD;
end

Theta = mu + 4.0 * sd;

% choke off at a high threshold - something probably went
% wrong if its above here...
if Theta > 0.2
    Theta = 0.2;
end

%Bashir
[x,y]=hist(I);
z=sum(x,2);
[C,d] = max(z);
Theta=y(d);