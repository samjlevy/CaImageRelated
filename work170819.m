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
regUse = [1;1;0;0;1;1;1;0;0;1;1;1;1;1]

cellsUse = [ 14 18 36 37 38 44 47 51 54 55 68 72 80 87 88 90 91 92 96 104 119];


base_path = 'G:\Polaris\Polaris_160831'
reg_paths = {'G:\Polaris\Polaris_160830';...
             'G:\Polaris\Polaris_160901';...
             'E:\Polaris\Polaris_160829all';...
             'G:\Polaris\Polaris_160902';...
             'E:\Polaris\Polaris_160906all';...
             'E:\Polaris\Polaris_160907';...
             'E:\Polaris\Polaris_160907-2';...
             'E:\Polaris\Polaris_160908';...
             'E:\Polaris\Polaris_160909';...
             'E:\Polaris\Polaris_160910';...
             'G:\Polaris\Polaris_160825';...
             'G:\Polaris\Polaris_160824';...
             'G:\Polaris\Polaris_160823'};
         
base_path = 'D:\Europa\Europa_161013'
reg_paths = {'D:\Europa\Europa_161012';...
             'D:\Europa\Europa_161014';...
             'D:\Europa\Europa_161011';...
             'D:\Europa\Europa_161015';...
             'D:\Europa\Europa_161016';...
             'D:\Europa\Europa_161017';...
             'D:\Europa\Europa_161018actual';...
             'D:\Europa\Europa_161019';...
             'D:\Europa\Europa_161020';...
             'D:\Europa\Europa_161021-2';...
             'D:\Europa\Europa_161022';...
             'I:\Europa_161010';...
             'I:\Europa_161007';...
             'I:\Europa_161006';...
             'I:\Europa_161005';...
             'I:\Europa_161004';...
             'I:\Europa_161003';...
             'I:\Europa_161002';...
             'I:\Europa_161001';...
             'I:\Europa_160930';...
             'I:\Europa_160929all';...
             'I:\Europa_160928all'};
             