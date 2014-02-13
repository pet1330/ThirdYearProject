% M-file to locate optic nerve
function b = eyeread(fName)

% read image
a = imread(fName);

if size(a,3) == 3
    % extract green component, change to double and reset range
    %b = double(a(:,:,2))/255;
    b = double(a)/255;
elseif size(a,3) == 1
    if max(max(a)) > 1   
        b = double(a) / 255;  
    else
        b = double(a);
    end
end

