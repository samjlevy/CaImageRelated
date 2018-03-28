function xaxTBT = XafterXtbt(trialbytrial,   )
%This makes a new trialbytrial in which study trials, rather than by the
%direction forced, are sorted by the direction of the test trial which they
%follow. This is to investigate if the mouse expects to alternate from the
%previous trial, which may explain some of the trial-to-trial variability
%being seen.

numSess = length(unique(trialbytrial(1).SessID));

testConds = [find(strcmpi({trialbytrial(:).name},'test_l')) 
             find(strcmpi({trialbytrial(:).name},'test_r'))];

studyConds = [find(strcmpi({trialbytrial(:).name},'study_l')) 
             find(strcmpi({trialbytrial(:).name},'study_r'))];         
         
xaxTBT(testConds) = trialbytrial(testConds);

for tcI = 1:2
    for sessI = 1:numSess
        testLaps = ...
            trialbytrial(testConds(tcI)).lapNumber(trialbytrial(testConds(tcI)).SessID==sessI);
        
        studyLaps1all = trialbytrial(studyConds(1)).lapNumber(trialbytrial(studyConds(1)).SessID==sessI);
        studyLaps2all = trialbytrial(studyConds(2)).lapNumber(trialbytrial(studyConds(2)).SessID==sessI);
        
        studyLaps1use = studyLaps1all(studyLaps1all==testLaps+1);
        studyLaps2use = studyLaps2all(studyLaps2all==testLaps+1);
        
        indsFill = 
        
        xaxTBT(studyConds(tcI).trialsX{ }
        xaxTBT(studyConds(tcI).trialsY{ }
        xaxTBT(studyConds(tcI).trialsPSAbool{ }
        xaxTBT(studyConds(tcI).sessID( ,1)