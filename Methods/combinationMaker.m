function combinationMaker
v = [0 1 2 3 4 5];
fileID = fopen('combo.perms','w');
while(~isempty(v))
    p = perms(v);
    [s,z] = size(p);
    for elm = 1:s
        switch(z)
            case 1
                fprintf(fileID,'%d\n',p(elm,:));
            case 2
                fprintf(fileID,'%d%d\n',p(elm,:));
            case 3
                fprintf(fileID,'%d%d%d\n',p(elm,:));
            case 4
                fprintf(fileID,'%d%d%d%d\n',p(elm,:));
            case 5
                fprintf(fileID,'%d%d%d%d%d\n',p(elm,:));
            case 6
                fprintf(fileID,'%d%d%d%d%d%d\n',p(elm,:));
        end
    end
    disp(s);
    v = v(1:length(v)-1);
end
fclose(fileID);
end