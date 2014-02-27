function combinationMaker

fileID = fopen('COMBO.txt','w');
v = [0,1,2,3,4,5,6,7,8,9];
p = perms(v);
[s,~] = size(p);
parfor elm = 1:s
fprintf(fileID,'%d%d%d%d%d%d%d%d%d%d\n',p(elm,:));
end
fclose(fileID);
disp(s);
end