function MD = MakeFakeMD(animalName, pathsList)

for mdi = 1:length(pathsList)
    MD(mdi,1).Animal = animalName;
    MD(mdi,1).Session = 1;
    MD(mdi,1).Location = pathsList{mdi};
    
    dateStr = strsplit(pathsList{mdi},'_');
    dateStr = dateStr{2};
    dateStr = dateStr(1:6);
    
    yr = dateStr(1:2);
    mo = dateStr(3:4);
    dy = dateStr(5:6);
    
    MD(mdi,1).Date = [mo '_' dy '_20' yr];
end
    
end