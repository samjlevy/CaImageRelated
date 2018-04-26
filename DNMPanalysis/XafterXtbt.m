function [xaxTBT, lapsIncLog] = XafterXtbt(trialbytrial)
%This makes a new trialbytrial in which study trials, rather than by the
%direction forced, are sorted by the direction of the test trial which they
%follow. This is to investigate if the mouse expects to alternate from the
%previous trial, which may explain some of the trial-to-trial variability
%being seen.
%Also returns lapsIncLog, which tells which laps were used out of each cond

numSess = length(unique(trialbytrial(1).sessID));

testConds = [find(strcmpi({trialbytrial(:).name},'test_l')) 
             find(strcmpi({trialbytrial(:).name},'test_r'))];

newCondLabels = {'study_following_l', 'study_following_r'};         
         
studyConds = [find(strcmpi({trialbytrial(:).name},'study_l')) 
             find(strcmpi({trialbytrial(:).name},'study_r'))];         
         
xaxTBT(testConds) = trialbytrial(testConds);

condsToFill = 1:length(xaxTBT);
condsToFill = condsToFill(sum(condsToFill == testConds,1)==0);
lapsIncLog = cell(4,1);
for tcI = 1:2
    for sessI = 1:numSess
        %Get laps for 1 test direction
        originalLapsLogical = trialbytrial(testConds(tcI)).sessID==sessI;
        testLapsLogical = xaxTBT(testConds(tcI)).sessID==sessI;
        testLaps = xaxTBT(testConds(tcI)).lapNumber(testLapsLogical);
        
        %this could be a loop through length(studyConds)
        %Get study laps this session
        studyLaps1 = trialbytrial(studyConds(1)).sessID==sessI;
        studyLaps2 = trialbytrial(studyConds(2)).sessID==sessI;
        
        %ID those that directly follow the intended test session
        studyLaps1use = sum(trialbytrial(studyConds(1)).lapNumber.*studyLaps1 == (testLaps+1)',2) == 1;
        studyLaps2use = sum(trialbytrial(studyConds(2)).lapNumber.*studyLaps2 == (testLaps+1)',2) == 1;
        lapnums1 = trialbytrial(studyConds(1)).lapNumber(studyLaps1use);
        lapnums2 = trialbytrial(studyConds(2)).lapNumber(studyLaps2use);
        
        lapsIncLog{studyConds(1)} = [lapsIncLog{studyConds(1)}, studyLaps1use];
        lapsIncLog{studyConds(2)} = [lapsIncLog{studyConds(2)}, studyLaps2use];
        
        %Exclude test laps that don't have a following study lap
        [lapsFound, sortOrder] = sort([lapnums1; lapnums2]);
        missingTest = sum((testLaps+1 == lapsFound'),2)==0;
        lapsIncLog{testConds(tcI)} = [lapsIncLog{testConds(tcI)}, originalLapsLogical];
        lapsIncLog{testConds(tcI)}(originalLapsLogical,end) = (missingTest==0);
        testDelete = testLapsLogical; 
        testDelete(testLapsLogical) = missingTest;
        
        xaxTBT(testConds(tcI)).lapNumber(testDelete) = [];
        xaxTBT(testConds(tcI)).sessID(testDelete) = [];
        xaxTBT(testConds(tcI)).trialPSAbool(testDelete) = [];
        xaxTBT(testConds(tcI)).trialsX(testDelete) = [];
        xaxTBT(testConds(tcI)).trialsY(testDelete) = [];

        %Make new study following X cond
        pileTrialsX = [trialbytrial(studyConds(1)).trialsX(studyLaps1use); trialbytrial(studyConds(2)).trialsX(studyLaps2use)];
        pileTrialsY = [trialbytrial(studyConds(1)).trialsY(studyLaps1use); trialbytrial(studyConds(2)).trialsY(studyLaps2use)];
        pileTrialPSAbool = [trialbytrial(studyConds(1)).trialPSAbool(studyLaps1use); trialbytrial(studyConds(2)).trialPSAbool(studyLaps2use)];
        pileSessID = [trialbytrial(studyConds(1)).sessID(studyLaps1use); trialbytrial(studyConds(2)).sessID(studyLaps2use)];
        %pileLapNums = [trialbytrial(studyConds(1)).lapNumber(studyLaps1use); trialbytrial(studyConds(2)).lapNumber(studyLaps2use)];
            
        %{
        %Validation
        bb = pileTrialsX(sortOrder)
        [cell2mat(cellfun(@length,pileTrialsX,'UniformOutput',false)), [lapnums1; lapnums2]]
        cc = [cell2mat(cellfun(@length,bb,'UniformOutput',false)), lapsFound]
        dd = [cell2mat(cellfun(@length,pileTrialsX,'UniformOutput',false)), [lapnums1; lapnums2]]
        [cc dd(sortOrder,:)]
        %}
        %Fill in new stuff
        iStart = length(xaxTBT(condsToFill(tcI)).trialsX);
        indsFill = (iStart+1):(iStart+length(lapsFound));
        xaxTBT(condsToFill(tcI)).trialsX(indsFill,1) = pileTrialsX(sortOrder);
        xaxTBT(condsToFill(tcI)).trialsY(indsFill,1) = pileTrialsY(sortOrder);
        xaxTBT(condsToFill(tcI)).trialPSAbool(indsFill,1) = pileTrialPSAbool(sortOrder);
        xaxTBT(condsToFill(tcI)).sessID(indsFill,1) = pileSessID(sortOrder);
        xaxTBT(condsToFill(tcI)).lapNumber(indsFill,1) = lapsFound;
        xaxTBT(condsToFill(tcI)).name = newCondLabels{tcI};
    end
end

end