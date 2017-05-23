

onOff=diff(PSAbool,1,2); %zeros adjusts diff %zeros(size(PSAbool,1),1) 
ons=onOff==1;
offs=onOff==-1;
syncOn=sum(ons,1);
possibleSCE=find(syncOn>4);

theseCells=find(PSAbool(:,possibleSCE(1)+1))

newCheck=PSAbool(theseCells,:);
