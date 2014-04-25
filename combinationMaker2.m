function combinationMaker2
c = zeros(46656,6);
fileID = fopen('COMBOFINAL','w');
h = waitbar(0,'Generating Permitations');
for a = 0:46655
    b = num2str(dec2base(a, 6));
    v(7-length(b):6) = b(1:length(b));
    d = str2double(unique(v,'stable'));
    c(a+1,(7-length(d):6)) = d(1:length(d));
    waitbar(a/46655);
end
c = unique(c,'stable');

for filep = 1:1631
    if(filep~=1631)
        fprintf(fileID,'%d\n',c(filep,1));
    else
        fprintf(fileID,'%d',c(filep,1));
    end
end
fprintf(fileID,'\b');
fclose(fileID);
close(h);
end