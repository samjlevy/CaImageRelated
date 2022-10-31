function [fixedBehavior,xHere,yHere] = LapSeqValidator(xHere,yHere,originalBehavior,minArmEntries)

fixedBehavior = originalBehavior;
nLaps = numel(fixedBehavior.ArmSequence);

for lapI = 1:nLaps
    seqH = fixedBehavior.ArmSequence{lapI};
    if numel(seqH) < minArmEntries
       lapBounds = [fixedBehavior.LapStart(lapI) fixedBehavior.LapStop(lapI)];
       
       doneEditing = false;
       while doneEditing == false
           aga = figure('Position',[244 185 560 420]);
           plot(xHere,yHere,'.k')
           hold on
           plot(xHere(lapBounds(1):lapBounds(2)),yHere(lapBounds(1):lapBounds(2)),'.m')
           plot(xHere(lapBounds(1)),yHere(lapBounds(1)),'.y')
           plot(xHere(lapBounds(2)),yHere(lapBounds(2)),'.c')
           title(['Lap ' num2str(lapI) ', reported sequence ' seqH])

           howEdit = input('How to edit? Relabel sequence (r), adjust start (s), adjust end (e), interpolate cluster of points (p), done editing (d): ','s');
           switch howEdit
               case {'d','D'}
                   doneEditing = true;
               case {'r','R'}
                   newSeq = input('What should the relabeled sequence be?','s')
                   fixedBehavior.ArmSequence{lapI} = newSeq;
                   seqH = newSeq;
               case {'S','s'}
                   doneStart = false;
                   while doneStart == false
                        startStep = input('How many frames forward or backward (-) adjust start bound (0 to stop)?')
                        lapBounds(1) = lapBounds(1) + startStep;

                        try
                           close(aga);
                       end
                       aga = figure('Position',[244 185 560 420]);
                       plot(xHere,yHere,'.k')
                       hold on
                       plot(xHere(lapBounds(1):lapBounds(2)),yHere(lapBounds(1):lapBounds(2)),'.m')
                       plot(xHere(lapBounds(1)),yHere(lapBounds(1)),'.y')
                       plot(xHere(lapBounds(2)),yHere(lapBounds(2)),'.c')
                       title(['Lap ' num2str(lapI) ', reported sequence ' seqH])

                        if startStep == 0
                            doneStart = true;
                        end
                   end

               case {'e','E'}
                   doneEnd = false;
                   while doneEnd == false
                       endStep = input('How many frames forward or backward (-) adjust end bound (0 to stop)?')
                       lapBounds(2) = lapBounds(2) + endStep;

                       try
                           close(aga);
                       end
                       aga = figure('Position',[244 185 560 420]);
                       plot(xHere,yHere,'.k')
                       hold on
                       plot(xHere(lapBounds(1):lapBounds(2)),yHere(lapBounds(1):lapBounds(2)),'.m')
                       plot(xHere(lapBounds(1):lapBounds(2)),yHere(lapBounds(1):lapBounds(2)),'r')
                       plot(xHere(lapBounds(1)),yHere(lapBounds(1)),'.y')
                       plot(xHere(lapBounds(2)),yHere(lapBounds(2)),'.c')
                       title(['Lap ' num2str(lapI) ', reported sequence ' seqH])
                       if endStep == 0
                           doneEnd = true;
                       end
                   end
               case {'p','P'}
                   for ii = 1:5
                       title(['5-pt bounding box, click pt ' num2str(ii) ' / 5'])
                       [xb(ii),yb(ii)] = ginput(1);
                       plot(xb,yb,'g')
                       plot(xb,yb,'*g')
                   end

                   [inn,onn] = inpolygon(xHere(lapBounds(1):lapBounds(2)),yHere(lapBounds(1):lapBounds(2)),xb,yb); inn = inn | onn;
                   if any(inn)
                       disp(['Found ' num2str(sum(inn)) ' pts in this bounding box'])
                       fixHow = input('fix them by interpolation (i) or other (o):','s')
                       switch fixHow
                           case 'i'
                               goodPts = find(inn == 0);
                               allX = xHere(lapBounds(1):lapBounds(2));
                               goodX = allX(goodPts);
                               badPts = find(inn == 1);
                               xFixed = interp1(goodPts,goodX,badPts);

                               allY = yHere(lapBounds(1):lapBounds(2));
                               goodY = allY(goodPts);
                               yFixed = interp1(goodPts,goodY,badPts);

                               aga = figure('Position',[244 185 560 420]);
                               plot(xHere,yHere,'.k')
                               hold on

                               allX(badPts) = xFixed;
                               allY(badPts) = yFixed;
                               plot(allX,allY,'.m')
                               plot(allX,allY,'r')

                               if strcmpi(input('Was this a good fix (y/n):','s'),'y')
                                   xHere(lapBounds(1):lapBounds(2)) = allX;
                                   yHere(lapBounds(1):lapBounds(2)) = allY;
                               else
                                   keyboard
                               end

                           case 'o'
                               keyboard
                       end
                   end

               case {'o','O'}
                   keyboard
                   
               otherwise
                   % Do nothing

           end

                   nanPts = isnan(xHere(lapBounds(1):lapBounds(2))) | isnan(yHere(lapBounds(1):lapBounds(2)));
                   if any(isnan(xHere(lapBounds(1):lapBounds(2)))) || any(isnan(yHere(lapBounds(1):lapBounds(2))))
                       leyboard
                   end


           try
               close(aga);
           end
       end

       fixedBehavior.LapStart(lapI) = lapBounds(1);
       fixedBehavior.LapStop(lapI) = lapBounds(2);



end





end

