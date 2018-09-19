function [obj,manCorrFig,xAVI,yAVI,definitelyGood,buttonClicked,zfI] = PreProcCorrectFrameManual(...
            corrFrame,obj,manCorrFig,xAVI,yAVI,definitelyGood,velThresh,zfI)
aviSR = obj.FrameRate;

obj.CurrentTime = (corrFrame-1)/aviSR;
uFrame = readFrame(obj);
imagesc(manCorrFig.Children,uFrame);
title(manCorrFig.Children,['Frame # ' num2str(corrFrame) ', click here, right to accept current'])
hold(manCorrFig.Children,'on')
plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+r')
if (xAVI(corrFrame)==0) && (yAVI(corrFrame)==0)
    plot(manCorrFig.Children,20,20,'^r')
end
hold(manCorrFig.Children,'off')
    
figure(manCorrFig);
[xclick,yclick,buttonClicked] = ginput(1);
switch buttonClicked
    case 1
        xAVI(corrFrame) = xclick;
        yAVI(corrFrame) = yclick;
        definitelyGood(corrFrame) = 1;
        imagesc(manCorrFig.Children,uFrame);
        hold(manCorrFig.Children,'on')
        plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+g')
        hold(manCorrFig.Children,'off')
    case 3
        hold(manCorrFig.Children,'on')
        plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+g')
        hold(manCorrFig.Children,'off')
        definitelyGood(corrFrame) = 1;
    case 2
        midBut = questdlg('What do you want?','What','Go back','Stop','Jump to frame','Stop');
        switch midBut
            case 'Jump to frame'
                corrFrame = str2double(input('Which frame do you want? >> ','s'));
                
                obj.CurrentTime = (corrFrame-1)/aviSR;
                uFrame = readFrame(obj);
                imagesc(manCorrFig.Children,uFrame);
                title(['Frame # ' num2str(corrFrame) ', click here, right to accept current'])
                hold(manCorrFig.Children,'on')
                plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+r')
                plot(manCorrFig.Children,[30 30+velThresh],[50 50],'r')
                if (xAVI(corrFrame)==0) && (yAVI(corrFrame)==0)
                    plot(manCorrFig.Children,20,20,'^r')
                end
                hold(manCorrFig.Children,'off')
                
                figure(manCorrFig);
                [xclick,yclick,~] = ginput(1);
                xAVI(corrFrame) = xclick;
                yAVI(corrFrame) = yclick;
                definitelyGood(corrFrame) = 1;
                imagesc(manCorrFig.Children,uFrame);
                hold(manCorrFig.Children,'on')
                plot(manCorrFig.Children,xAVI(corrFrame),yAVI(corrFrame),'+g')
                hold(manCorrFig.Children,'off')
            case 'Go back'
                zfI = zfI - 1;
            case 'Stop'
                zfI = -5;
        end
end

end   