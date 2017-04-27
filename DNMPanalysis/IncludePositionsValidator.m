function IncludePositionsValidator(pos_file, include_struct, actuallyExclude)
%flag actually exclude if incldue_struct is really exclude

%if nargin==4; if actuallyExclude==1; %shit, this could take a while.. end; end
load(pos_file, 'x_adj_cm', 'y_adj_cm')
        
s = fieldnames(include_struct);
for field = 1:length(s)
    eval(['thisInclude = include_struct.' s{field} ';'])
    figure(field);
    plot(x_adj_cm, y_adj_cm, '.k')
    hold on
    plot(x_adj_cm(thisInclude),y_adj_cm(thisInclude),'.r')
    title(['Include frames for ' s{field}])
end

%{ 
%untested
anybad = input('Are there frames that are bad? 0/1')
if == 1
    for aa = 1:size(frame_bounds,1)
        theseFrames = frame_bounds(aa,1):frame_bounds(aa,2);
        lapAssignments = [lapAssignments; [theseFrames',
        ones(length(theseFrames),1)*aa] ];
    end

    whichfigure = input('which figure?')
    figure(whichfigure);
    title('click near bad positions')
    [xbad,ybad] = ginput(y)
    [ idx ] = findclosest2D ( x_adj_cm(lapAssignments(:,1)), y_adj_cm(lapAssignments(:,1)), xbad, ybad);
    hold on 
    plot(x_adj_cm(lapAssignments(idx,1)),
    y_adj_cm(lapAssignments(idx,1)),'*m')
    badLap = lapAssignments(ixd,2)
end
%}

end
    