% TramlineSingle - tram-line filter the picture
% Tram-line filters at a set number of angles are run,
% and the highest response is returned.

function C = TramlineSingle(a,width1,length1,width2,length2)
%5, 9, 0, 9
its = 16;
k=1;
j=0;
for j=-2:2:2
    width=width1+j;
    
    % Calculate the response at the first angle
    % calculate response at subsequent angles
    for i=1:its,
      f = tramlinef(length1,width,i-1,its); %outside a vessel
      f2 = tramlinef( length2, width2,i-1,its ); %inside a vessel
     
      top2 = sum(sum(f2));
      
      %Bashir: the minimum responce of outside a vessel - the maximum responce inside a vessel
       %stackC(:,:,i) = ordfilt2(a,1,f) - ordfilt2(a,top2,f2);
      %Andrew code
      stackC(:,:,i) = ordfilt2(a,3,f) - ordfilt2(a,top2-2,f2);
     
%       cwd = pwd;
%       cd(tempdir);
%       %pack
%       cd(cwd)
    end

    % find maximum across the responses at different angles, and
    % return that.
    CC(:,:,k) = max(stackC,[],3);%  figure; imshow(CC(:,:,k));
    k=k+1;
end
C = max(CC,[],3);%  figure; imshow(C);
%C = mean(CC,3);%  figure; imshow(C);
%C = min(CC,[],3);%  figure; imshow(C);
%C = median(CC,3);%  figure; imshow(C);
clear stackC CC a;