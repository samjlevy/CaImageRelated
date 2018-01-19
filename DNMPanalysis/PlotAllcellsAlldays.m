%Plot all cell outlines
cd('D:\SLIDE\Processed Data\Europa')
aa = dir;

aaa = cellfun(@(x) strfind(x,'Europa'),{aa.name},'UniformOutput',false);
aa(find(cellfun(@isempty,aaa))) = [];

for ii = 1:length(aa) 
    load(fullfile(cd,aa(ii).name,'FinalOutput.mat'),'NeuronImage')
    [ All_ICmask ] = create_AllICmask( NeuronImage );
    figure; 
    imagesc(All_ICmask); title(['Outlines for ' aa(ii).name])
end