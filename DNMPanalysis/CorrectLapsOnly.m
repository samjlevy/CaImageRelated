     
 CorrectLapsOnly(bounds, correct, lapNum)
 
    ss = fieldnames(bounds);
    for block = 1:4
        correctBounds(thisFile).(ss{block}) =...
            [bounds.(ss{block})(correct.(ss{block}),1)...
            bounds.(ss{block})(correct.(ss{block}),2)];
        
        lapNumber(thisFile).(ss{block}).all = lapNum.(ss{block});
        
        lapNumber(thisFile).(ss{block}).correct =...
            lapNum.(ss{block})(correct.(ss{block}));
        
        badLaps(thisFile).(ss{block}) =...
            [bounds.(ss{block})(correct.(ss{block})==0,1)...
            bounds.(ss{block})(correct.(ss{block})==0,2)];
        
        lapNumber(thisFile).(ss{block}).wrong=...
            lapNum.(ss{block})(correct.(ss{block})==0);
    end