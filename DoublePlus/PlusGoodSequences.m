function goodSequences = PlusGoodSequences(sessType,locInds)

starts = [find(strcmpi(locInds(:,2),'north')) find(strcmpi(locInds(:,2),'south'))];
mids = [find(strcmpi(locInds(:,2),'center')) find(strcmpi(locInds(:,2),'center'))];
switch sessType
    case 'turn'
        ends = [find(strcmpi(locInds(:,2),'west')) find(strcmpi(locInds(:,2),'east'))];
    case 'place'
        ends = [find(strcmpi(locInds(:,2),'east')) find(strcmpi(locInds(:,2),'east'))];
end

goodSequences = [starts; mids; ends];

end