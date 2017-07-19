allX = [all_x_adj_cm{:}];
allY = [all_y_adj_cm{:}];

BigPSAbool = PoolPSA(all_PSAbool, sessionInds);

[~,~,~, pooled{1}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{1},'Bellatrix_160830DNMPsheet_BrainTime_Adjusted.xlsx'), 'stem_only', length(all_x_adj_cm{1,1}));
[~,~,~, pooled{2}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{2},'Bellatrix_160831DNMPsheet_BrainTime_Adjusted.xlsx'), 'stem_only', length(all_x_adj_cm{1,2}));
[~,~,~, pooled{3}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{3},'Bellatrix_160901DNMPsheet_BrainTime_Adjusted.xlsx'), 'stem_only', length(all_x_adj_cm{1,3}));
 
plotX.studyRight = []; plotX.studyLeft = []; 
plotX.testRight = []; plotX.testLeft = [];
plotY.studyRight = []; plotY.studyLeft = []; 
plotY.testRight = []; plotY.testLeft = [];
for pp = 1:3
    allInc.studyRight{1,pp} = pooled{1,pp}.include.forced & pooled{1,pp}.include.right;
    allInc.studyLeft{1,pp} = pooled{1,pp}.include.forced & pooled{1,pp}.include.left;
    allInc.testRight{1,pp} = pooled{1,pp}.include.free & pooled{1,pp}.include.right;
    allInc.testLeft{1,pp} = pooled{1,pp}.include.free & pooled{1,pp}.include.left;
end

allPooled.studyRight = [allInc.studyRight{:}];
allPooled.studyLeft = [allInc.studyLeft{:}];
allPooled.testRight = [allInc.testRight{:}];
allPooled.testLeft = [allInc.testLeft{:}];
 
plot(allX(allPooled.studyRight),allY(allPooled.studyRight),'.')
hold on
plot(

plotX.studyRight = [plotX.studyRight all_x_adj_cm{1,pp}(pooled{1,pp}.include.studyRight)];
    plotX.studyLeft = [plotX.studyLeft all_x_adj_cm{1,pp}(pooled{1,pp}.include.studyLeft)];
    plotX.testRight = [plotX.testRight all_x_adj_cm{1,pp}(pooled{1,pp}.include.testRight)];
    plotX.testLeft = [plotX.testLeft all_x_adj_cm{1,pp}(pooled{1,pp}.include.testLeft)];
    plotY.studyRight = [plotY.studyRight all_y_adj_cm{1,pp}(pooled{1,pp}.include.studyRight)];
    plotY.studyLeft = [plotY.studyLeft all_y_adj_cm{1,pp}(pooled{1,pp}.include.studyLeft)];
    plotY.testRight = [plotY.testRight all_y_adj_cm{1,pp}(pooled{1,pp}.include.testRight)];
    plotY.testLeft = [plotY.testLeft all_y_adj_cm{1,pp}(pooled{1,pp}.include.testLeft)];


 plotX.studyRight = [plotX.studyRight all_x_adj_cm{1,pp}(pooled{1,pp}.include.studyRight)];
    plotX.studyLeft = [plotX.studyLeft all_x_adj_cm{1,pp}(pooled{1,pp}.include.studyLeft)];
    plotX.testRight = [plotX.testRight all_x_adj_cm{1,pp}(pooled{1,pp}.include.testRight)];
    plotX.testLeft = [plotX.testLeft all_x_adj_cm{1,pp}(pooled{1,pp}.include.testLeft)];
    plotY.studyRight = [plotY.studyRight all_y_adj_cm{1,pp}(pooled{1,pp}.include.studyRight)];
    plotY.studyLeft = [plotY.studyLeft all_y_adj_cm{1,pp}(pooled{1,pp}.include.studyLeft)];
    plotY.testRight = [plotY.testRight all_y_adj_cm{1,pp}(pooled{1,pp}.include.testRight)];
    plotY.testLeft = [plotY.testLeft all_y_adj_cm{1,pp}(pooled{1,pp}.include.testLeft)];
    
    trimmedPSAbool.studyRight = 
    trimmedPSAbool.studyLeft = 
    trimmedPSAbool.testRight = 
    trimmedPSAbool.testLeft = 

 
 