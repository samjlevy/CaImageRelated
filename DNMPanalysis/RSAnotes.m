xls_file = 'Bellatrix_160831DNMPsheet_Finalized.xlsx'
framesSample = 10;
numFrames = size(PSAbool,2)
numWindows = floor(numFrames/framesSample);

'stem_only'
'choice_bit'
'side_arm'
[start_stop_struct, include_struct, exclude_struct, pooled, correct, lapNumber]...
    = GetBlockDNMPbehavior( xls_file, 'on_maze', numFrames)
'lap_end' %maybe not, since lots of running back to choice area
'cage' %maybe not just cause?
'delay'


%put these all into 1 vector
%eliminate not on maze


corrsStuff = nan(numWindows,numWindows);
corrPs = nan(numWindows,numWindows);
for winI = 1:numWindows-1
    dataI = sum(PSAbool(:,(winI*10+1):((winI+1)*10)),2);
    for winJ = (numWindows-1):winI
        dataJ = sum(PSAbool(:,(winJ*10+1):((winJ+1)*10)),2);
        [corrsStuff(winI,winJ), corrPs(winI,winJ)] = corr(dataI,dataJ,'type','Spearman');
        %also save what kind of session was here (or if it goes across
        %boundaries, both etc.
    end
end