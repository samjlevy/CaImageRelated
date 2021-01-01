foldersRun = {'F:\DoublePlus\Kerberos\Kerberos_180418';...
    'F:\DoublePlus\Kerberos\Kerberos_180419';...
    'F:\DoublePlus\Kerberos\Kerberos_180420';...
    'F:\DoublePlus\Kerberos\Kerberos_180421';...
    'F:\DoublePlus\Kerberos\Kerberos_180422';...
    'F:\DoublePlus\Kerberos\Kerberos_180423';...
    'F:\DoublePlus\Kerberos\Kerberos_180424';...
    'F:\DoublePlus\Kerberos\Kerberos_180425';...
    'F:\DoublePlus\Kerberos\Kerberos_180426'};

for ffI = 1:length(foldersRun)
cd(foldersRun{ffI})
aa = imread('ICmovie_min_proj.tif');
figure; imagesc_gray(aa);
colorbar off
warnId = 'MATLAB:polyshape:repairedBySimplify';
warning('off',warnId)
hold on
load('FinalOutput.mat','NeuronImage')
for rrI = 1:length(NeuronImage)
    outlineA = bwboundaries(NeuronImage{rrI});
    polyA = polyshape(outlineA{1}(:,1),outlineA{1}(:,2));
    
    vv = [polyA.Vertices(:,2); polyA.Vertices(1,2)]; 
    vv = [vv, [polyA.Vertices(:,1); polyA.Vertices(1,1)]]; 
    plot(vv(:,1),vv(:,2),'LineWidth',1)
    %patch(overlap.Vertices(:,2),overlap.Vertices(:,1),'m','EdgeColor','none','FaceAlpha',0.3)
end
warning('on',warnId)
title(['Session ' num2str(ffI)])
axis off
end