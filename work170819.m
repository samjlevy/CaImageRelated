base_path = 'F:\Bellatrix\Bellatrix_160831';

reg_paths = {'F:\Bellatrix\Bellatrix_160830';...
             'F:\Bellatrix\Bellatrix_160901';...
             'F:\Bellatrix\Bellatrix_160829all';...
             'F:\Bellatrix\Bellatrix_160902all';...
             'F:\Bellatrix\Bellatrix_160826';...
             'F:\Bellatrix\Bellatrix_160825';...
             'F:\Bellatrix\Bellatrix_160824';...
             'F:\Bellatrix\Bellatrix_160823';...
             'F:\Bellatrix\Bellatrix_160822all';...
             'E:\Bellatrix\Bellatrix_160906';...
             'E:\Bellatrix\Bellatrix_160907all';...
             'E:\Bellatrix\Bellatrix_160908';...
             'E:\Bellatrix\Bellatrix_160909';...
             'E:\Bellatrix\Bellatrix_160910'};
      
matchCells(base_path, reg_paths)

firstA = zeros(571,1);
for aa = 1:571
    try
    firstA(aa) = find(blocked(aa,:),1,'first');
    end
end
[~,I] = sort(firstA);
sortedBlocked = zeros(size(blocked));
for bb = 1:571
    sortedBlocked(bb,:) = blocked(I(bb),:);
end
sortedBlocked2 = [sortedBlocked(101:571,:); sortedBlocked(1:100,:)]; 


allfiles = {'F:\Bellatrix\Bellatrix_160822all';...
'F:\Bellatrix\Bellatrix_160823';...
'F:\Bellatrix\Bellatrix_160824';...
'F:\Bellatrix\Bellatrix_160825';...
'F:\Bellatrix\Bellatrix_160826';...
'F:\Bellatrix\Bellatrix_160829all';...
'F:\Bellatrix\Bellatrix_160830';...
'F:\Bellatrix\Bellatrix_160831';...
'F:\Bellatrix\Bellatrix_160901';...
'F:\Bellatrix\Bellatrix_160902all';...
'E:\Bellatrix\Bellatrix_160906';...
'E:\Bellatrix\Bellatrix_160907all';...
'E:\Bellatrix\Bellatrix_160908';...
'E:\Bellatrix\Bellatrix_160909';...
'E:\Bellatrix\Bellatrix_160910'};

allsessions = [fullReg.BaseSession; fullReg.RegSessions(:)];

for si = 1:length(allfiles)
    howsort(si) = find(cell2mat(cellfun(@(x) strcmpi(x,allfiles{si}),allsessions,'UniformOutput',false)));
end

regUse = [1 1 0 0 1 1 1 0 0 1 1 1 1 1]
