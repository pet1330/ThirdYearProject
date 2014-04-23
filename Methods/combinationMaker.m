function combinationMaker
v = [0 1 2 3 4 5];
p = perms(v);
hist(p);
[s,~] = size(p);
fileNum=1;
fileID = fopen(sprintf('combo/COMBO%d',fileNum),'w');
for elm = 1:s
    fprintf(fileID,'%d%d%d%d%d%d%d%d%d%d\n',p(elm,:));
    if(mod(elm,60480)==0)
        fclose(fileID);
        fileNum = fileNum+1;
        fileID = fopen(sprintf('combo/COMBO%d',fileNum),'w');
    end
end
fclose(fileID);
disp(s);
end