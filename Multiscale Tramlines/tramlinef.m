% tramlinef - create a tram-line filter
% The filter has two parallel lines, each of length len,
% set, separated by a distance of sep.
% The filter is just large enough to accomodate the lines.
% The lines have value 1, the surrounds 0

function C = tramlinef(len,sep,dir,noDirs)
    %9, 5, [0:11], 12
    %9, 0, [0:12], 12 

    % calculate radius of circle large enough to accomodate two
    % parallel lines of length len, at separation sep *2
    R=sqrt(sep*sep+len*len)*0.5;
   %original
    %Rsquared = R * R;
    R=ceil(R);
    %Bashir
    Rsquared = R * R;

    % Make filter large enough to accomodate such a circle
    C(R*2+1,R*2+1)=0;
    Q = noDirs/4;
    s1 = Q;

    switch dir
        case {0, 1, 2, 3}
            %disp('first quadrant')
            s2 = dir;
            cosine = s1 / sqrt( s1 * s1 + s2 * s2 );
            offset = 0.5 * sep / cosine;
            for xi=-R:R,
                yi=round(s2*xi/s1-offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,xi+R+1)=1;
%                     C(-yi+R+2,xi+R+1)=1;
                end;  
                yi=round(s2*xi/s1+offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,xi+R+1)=1;
%                     C(-yi+R+2,xi+R+1)=1;
                end;
            end;

        case {4, 5, 6}
            %disp('second quadrant')
            s2 = 2 * Q - dir;
            cosine = s1 / sqrt( s1 * s1 + s2 * s2 );
            offset = 0.5 * sep / cosine;
            for yi=-R:R,
                xi=round(s2*yi/s1-offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,xi+R+1)=1;
%                     C(-yi+R+2,xi+R+1)=1;
                    
                end;  
                xi=round(s2*yi/s1+offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,xi+R+1)=1;
%                     C(-yi+R+2,xi+R+1)=1;
                end;
            end;

        case {7, 8, 9}
            %disp('third quadrant')
            s2 = dir - 2 * Q;
            cosine = s1 / sqrt( s1 * s1 + s2 * s2 );
            offset = 0.5 * sep / cosine;
            for yi=-R:R,
                xi=round(s2*yi/s1-offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,-xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,-xi+R+1)=1;
%                     C(-yi+R+2,-xi+R+1)=1;
                end;  
                xi=round(s2*yi/s1+offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,-xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,-xi+R+1)=1;
%                     C(-yi+R+2,-xi+R+1)=1;
                end;
            end;

        otherwise %{10, 11}
            %disp('fourth quadrant')
            s2 = noDirs-dir;
            cosine = s1 / sqrt( s1 * s1 + s2 * s2 );
            offset = 0.5 * sep / cosine;
            for xi=-R:R,
                yi=round(s2*xi/s1-offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,-xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,-xi+R+1)=1;
%                     C(-yi+R+2,-xi+R+1)=1;
                end;  
                yi=round(s2*xi/s1+offset);
                if ( xi*xi + yi*yi < Rsquared )
                    C(-yi+R+1,-xi+R+1)=1;
                    %Bashir
%                     C(-yi+R,-xi+R+1)=1;
%                     C(-yi+R+2,-xi+R+1)=1;
                end;
            end;
    end