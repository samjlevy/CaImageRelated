function DNMPplaceFields3(session_struct)%, cmperbin
%session_struct in MD format
%MD = MakeMouseSessionListSL2('sam');
%session_struct = MD(1)

cd(session_struct.Location)

%{
if nargin==0
    userStr='sam';
    [MD,ref]=MakeMouseSessionListSL2(userStr);
    C = strsplit(cd,'\');
    D = strsplit(C{end},'_');
    strfind(string(MD(:).Animal),string(D{1}))
end
%}

RoomStr = '201a - 2015';
load 'Pos_align.mat'
%load('FinalOutput.mat','PSAbool')
xls_file = dir('*BrainTime_Adjusted.xlsx');
xls_file = xls_file.name;

[stem_frame_bounds, ~, stem_exclude, pooled] =...
    GetBlockDNMPbehavior( xls_file, 'stem_only', length(x_adj_cm));
[~, ~, maze_exclude, ~] =...
    GetBlockDNMPbehavior( xls_file, 'on_maze', length(x_adj_cm));

[split1, split2]= SplitForSelfComp(stem_frame_bounds, 'alternate');
save SessionHalvesEpochs.mat split1 split2

FindBindEdges(pooled, x_adj_cm, anchorBin)


cmperbin = 2;
minspeed = 2.25;
NumShuffles = 100;
regFlds = fieldnames(stem_exclude);
for cond = 1:length(regFlds)
    save_append = ['_' char(regFlds{cond}) '_' num2str(cmperbin) 'cm'];
    %save_append = ['_' char(regFlds{cond}) '_2p5cm'];
    
    PlacefieldsLinSL(session_struct,'exclude_frames',stem_exclude.(regFlds{cond}),...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles,'save_append',save_append,'bin_edges',binEdges);
            
    placeFile{cond} = ['Placefields' save_append '.mat'];
    
    PlacefieldStatsSL(session_struct,'placefields_file',placeFile{cond},'save_append',save_append);
    
    statsFile{cond} = ['PlaceStats' save_append '.mat'];
end            

testFiles = {'Placefields_forced_r_2p5cm.mat', 'Placefields_forced_l_2p5cm.mat', 'Placefields_free_r_2p5cm.mat', 'Placefields_free_l_2p5cm.mat'};

spFlds = fieldnames(split1);
for fld = 1:length(spFlds)
    [include1.(spFlds{fld}), exclude1.(spFlds{fld})] =...
        MakeIncExcVectors(split1.(spFlds{fld}), length(x_adj_cm));
    [include2.(spFlds{fld}), exclude2.(spFlds{fld})] =...
        MakeIncExcVectors(split2.(spFlds{fld}), length(x_adj_cm));
end

cmperbin = 2;
minspeed = 2.25;
NumShuffles = 100;

for cond = 1:length(spFlds)
    save_append = ['_' char(spFlds{cond}) '_' num2str(cmperbin) 'cmPT1'];
    
    PlacefieldsSL(session_struct,'exclude_frames',exclude1.(spFlds{cond}),...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles,'save_append',save_append);
            
    placeFile = ['Placefields' save_append '.mat'];
    
    PlacefieldStatsSL(session_struct,'placefields_file',placeFile,'save_append',save_append);
end

for cond = 1:length(spFlds)
    save_append = ['_' char(spFlds{cond}) '_' num2str(cmperbin) 'cmPT2'];
    
    PlacefieldsSL(session_struct,'exclude_frames',exclude2.(spFlds{cond}),...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles,'save_append',save_append);
            
    placeFile = ['Placefields' save_append '.mat'];
    
    PlacefieldStatsSL(session_struct,'placefields_file',placeFile,'save_append',save_append);
end


save_append = ['_' onmaze '_' num2str(cmperbin) 'cm'];
PlacefieldsSL(session_struct,'exclude_frames',maze_exclude.exclude,...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles,'save_append',save_append);
            
placeFile = ['Placefields' save_append '.mat'];
PlacefieldStatsSL(session_struct,'placefields_file',placeFile);
    






