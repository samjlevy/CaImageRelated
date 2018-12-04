dayCentBoth = []; dayCentOne = []; 
for mouseI = 1:4 
    aa = splittersBOTH{mouseI}*cellRealDays{mouseI}; 
    bb = splittersOne{mouseI}*cellRealDays{mouseI};
    
    mean(aa(aa>0))
    mean(bb(bb>0))
    
    dayCentBoth = [dayCentBoth; aa];
    dayCentOne = [dayCentOne; bb];
end

mean(dayCentBoth(dayCentBoth>0))
mean(dayCentOne(dayCentOne>0))
[p,h]=ranksum(dayCentBoth(dayCentBoth>0),dayCentOne(dayCentOne>0))


dayCentBoth = []; dayCentOne = []; 
for mouseI = 1:4 
    aa = splittersBOTH{mouseI}*([1:length(cellRealDays{mouseI})]'); 
    bb = splittersOne{mouseI}*([1:length(cellRealDays{mouseI})]');
    
    mean(aa(aa>0))
    mean(bb(bb>0))
    
    dayCentBoth = [dayCentBoth; aa];
    dayCentOne = [dayCentOne; bb];
end

mean(dayCentBoth(dayCentBoth>0))
mean(dayCentOne(dayCentOne>0))
[p,h]=ranksum(dayCentBoth(dayCentBoth>0),dayCentOne(dayCentOne>0))


%for mouseI = 1:4; [~, splitterDayBiasOne(mouseI,:)] = LogicalTraitCenterofMass(ones(size(dayUse{mouseI})), splittersOne{mouseI}); end
for mouseI = 1:4; [~, splitterDayBiasOne(mouseI,:)] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersOne{mouseI}); end
numOne = 0; for mouseI = 1:4; numOne = numOne + sum(sum(splittersOne{mouseI},2)>0); end
sdbo = sum(splitterDayBiasOne,1);
[sdbo(1) sdbo(3)]/numOne

%for mouseI = 1:4; [~, splitterDayBiasBoth(mouseI,:)] = LogicalTraitCenterofMass(ones(size(dayUse{mouseI})), splittersBOTH{mouseI}); end
for mouseI = 1:4; [~, splitterDayBiasBoth(mouseI,:)] = LogicalTraitCenterofMass(dayUse{mouseI}, splittersBOTH{mouseI}); end
numBoth = 0; for mouseI = 1:4; numBoth = numBoth + sum(sum(splittersBOTH{mouseI},2)>0); end
sdbb = sum(splitterDayBiasBoth,1);
[sdbb(1) sdbb(3)]/numBoth