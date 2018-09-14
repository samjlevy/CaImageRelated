function [v0] = AdjustWithBackgroundImage(avi_filepath, obj, v0)

if isempty('v0') 
    if ~isempty(v0) 
        backgroundImage=v0; 
        backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
        makeChoice = questdlg('Found a background image; use or make a new one?','bkg',...
            'Use','Remake','Use');
            switch makeChoice
                case 'Use'
                    makebackground=0;
                    backgroundImage=v0;
                case 'Remake'
                    makebackground=1;
            end
        close backgroundFrame
    else
        makebackground=1;
    end
elseif ~exist('v0','var') || any(v0(:))==0 %need the any since declaring as global
    makebackground=1;
else
    makebackground=0;
    backgroundImage=v0;
end

if makebackground==1
bkgChoice = questdlg('Supply/Load background image or composite?', ...
	'Background Image', ...
	'Load','Frame #','Composite','Composite');
    switch bkgChoice
    case 'Load'    
        [backgroundImage,bkgpath]=uigetfile('Select background image');
        load(fullfile(bkgpath,backgroundImage))
    case 'Frame #'
        try
            h1 = implay(avi_filepath);
        catch
            avi_filepath = ls('*.avi');
            h1 = implay(avi_filepath);
        end
        bkgFrameNum = input('frame number of mouse-free background frame??? --->');
        obj.CurrentTime = (bkgFrameNum-1)/obj.FrameRate;
        backgroundImage = readFrame(obj);
        backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
        %compositeBkg = backgroundImage;
        %could break here to allow fixing a piece of this one
    case 'Composite'
        try
            h1 = implay(avi_filepath);
        catch
            avi_filepath = ls('*.avi');
            h1 = implay(avi_filepath);
        end    
        msgbox({'Find images: ' '   -frame 1: top half has no mouse' '   -frame 2: bottom half has no mouse'})
        %prompt = {'No mouse on top frame:','No mouse on bottom frame:'};
        %dlg_title = 'Clear frames';
        %num_lines = 1;
        %clearFrames = inputdlg(prompt,dlg_title,num_lines);
        
        topClearNum = input('Frame number with no mouse on top: ') %#ok<NOPRT>
        bottomClearNum = input('Frame number with no mouse on bottom: ') %#ok<NOPRT>
        
        obj.CurrentTime = (topClearNum-1)/obj.FrameRate;
        topClearFrame = readFrame(obj);
        obj.CurrentTime = (bottomClearNum-1)/obj.FrameRate;
        bottomClearFrame = readFrame(obj);
        Top=figure('name','Top'); imagesc(topClearFrame); %#ok<NASGU>
            title(['Top Clear Frame ' num2str(topClearNum)]) 
        Bot=figure('name','Bot'); imagesc(bottomClearFrame); %#ok<NASGU>
            title(['Bottom Clear Frame ' num2str(bottomClearNum)]) 
        compositeBkg=uint8(zeros(obj.Height,obj.Width,3));
        compositeBkg(1:(obj.Height/2),:,:)=topClearFrame(1:(obj.Height/2),:,:);
        compositeBkg((obj.Height/2+1):obj.Height,:,:)= ...
            bottomClearFrame((obj.Height/2+1):obj.Height,:,:);
        close Top; close Bot;
        %backgroundFrame=figure('name','backgroundFrame'); imagesc(compositeBkg); title('Composite Background Image')
        backgroundImage=compositeBkg;
    end
end

bkgNotFlipped=0;
while bkgNotFlipped==0
    backgroundFrame=figure('name','backgroundFrame'); imagesc(backgroundImage); title('Background Image')
    bkgNormal = questdlg('Is the background image right-side up?', 'Background Image', ...
                              'Yes','No','Yes');               
        switch bkgNormal
            case 'Yes'
                bkgNotFlipped=1;
            case 'No'
                backgroundImage=flipud(backgroundImage);
                imagesc(backgroundImage);
        end
end     

try %#ok<*TRYNC>
    close(h1);
end

compGood=0;
while compGood==0
    holdChoice = questdlg('Good or fix a piece?', 'Background Image', ...
                              'Good','Fix area','Good');               
    switch holdChoice
        case 'Good'
            try %#ok<*TRYNC>
                close(h1);
            end
            compGood=1;
        case 'Fix area'
            try %#ok<*TRYNC>
                close(h1);
            end
            figure(backgroundFrame); title('Select area to swap out')
            [swapRegion, SwapX, SwapY] = roipoly;
            hold on 
            plot([SwapX; SwapX(1)],[SwapY; SwapY(1)],'r','LineWidth',2)
            h1 = implay(avi_filepath);
            swapInNum = input('Frame number to swap in area from ---->')%#ok<NOPRT> 
            %might replace with 2 field dialog box
            obj.CurrentTime = (swapInNum-1)/obj.FrameRate;
            swapClearFrame = readFrame(obj);
            %[rows,cols]=ind2sub([obj.Height,obj.Width],find(swapRegion(:)));
            %backgroundImage(rows,cols,:)=swapClearFrame(rows,cols,:);
            swapSub = find(swapRegion);
            bg1 = backgroundImage(:,:,1);
            bg2 = backgroundImage(:,:,2);
            bg3 = backgroundImage(:,:,3);
            sc1 = swapClearFrame(:,:,1);
            sc2 = swapClearFrame(:,:,2);
            sc3 = swapClearFrame(:,:,3);
            for ssI = 1:length(swapSub)
                bg1(swapSub(ssI)) = sc1(swapSub(ssI));
                bg2(swapSub(ssI)) = sc2(swapSub(ssI));
                bg3(swapSub(ssI)) = sc3(swapSub(ssI));
            end
            backgroundImage(:,:,1) = bg1;
            backgroundImage(:,:,2) = bg2;
            backgroundImage(:,:,3) = bg3;
            figure(backgroundFrame);imagesc(backgroundImage)
            compGood=0;
    end
end
v0 = backgroundImage; %Comes out rightside up
close(backgroundFrame);

end