function [performance, miscoded] = decoderResults2(decoded, actual, sessPairs, realDays)
%Looks only at column 1, which is every trial; column 2 had extra randomly
%picked trials. 
numPairs = size(sessPairs,1);
daysApart = diff(realDays(sessPairs),1, 2);

miscoded = []; performance = [];
%For each decoding round/session pair
for spI = 1:numPairs
    decodedI = [];
    %check how well we decoded each laps
    %index this along with how many days apart the session was
    decodedI = decoded{spI}(:,1);
    actualI = actual{spI}(:,1);

    doneRight = decodedI == actualI;
    
    miscoded{spI} = find(doneRight==0);
    performance(spI,1) = sum(doneRight)/length(doneRight);
end
    
    
    
end