function [reReg] = ReconstructCrossTaskReg(fullRegD,DNMPregD,FFregD)

load(fullfile(fullRegD,'fullReg.mat'))
load(fullfile(DNMPregD,'trialbytrial.mat'),'sortedSessionInds','allfiles')
DNMPssi = sortedSessionInds;
DNMPfiles = allfiles;
load(fullfile(FFregD,'trialbytrial.mat'),'sortedSessionInds','allfiles')
FFssi = sortedSessionInds;
FFfiles = allfiles;
reReg.FFfile = FFfiles;

regSessions = fullReg.RegSessions';
allSessions = [fullReg.BaseSession; regSessions(:)];
allSessPts = cellfun(@(x) strsplit(x,'\'),allSessions,'UniformOutput',false);
allSess = cellfun(@(x) x{end},allSessPts,'UniformOutput',false);
for asI = 1:length(allSess)
    if strcmpi(allSess{asI}(end-2:end),'all')
        allSess{asI} = allSess{asI}(1:end-3);
    end
end
reReg.allSess = allSess;

dnmpSessPts = cellfun(@(x) strsplit(x,'\'),DNMPfiles,'UniformOutput',false);
dnmpSess = cellfun(@(x) x{end},dnmpSessPts,'UniformOutput',false);
for asI = 1:length(dnmpSess)
    if strcmpi(dnmpSess{asI}(end-2:end),'all')
        dnmpSess{asI} = dnmpSess{asI}(1:end-3);
    end
end
reReg.dnmpSess = dnmpSess;

ffSessPts = cellfun(@(x) strsplit(x,'\'),FFfiles,'UniformOutput',false);
ffSess = cellfun(@(x) x{end},ffSessPts,'UniformOutput',false);
for asI = 1:length(ffSess)
    if strcmpi(ffSess{asI}(end-2:end),'all')
        ffSess{asI} = ffSess{asI}(1:end-3);
    end
end
reReg.ffSess = ffSess;

reReg.skipSess = false(1,length(allSess));
for sessI = 1:length(allSess)
    DNMPind = find(strcmpi(allSess{sessI},dnmpSess));
    FFind = find(strcmpi(allSess{sessI},ffSess));
    
    %Find which sessions go where
    if any(DNMPind)
        reReg.sessType(sessI) = 1;
        reReg.sessInd(sessI) = DNMPind; %Column in used cellSSI
    elseif any(FFind)
        reReg.sessType(sessI) = 2;
        reReg.sessInd(sessI) = FFind; %Column in used cellSSI
    else
        disp(['This session -- ' allSess{sessI} ' -- is missing?'])
        if strcmpi(input('Skip it? (y/n)>>','s'),'y')
            reReg.skipSess(sessI) = true;
        else
            keyboard
        end
    end
end

%Find cell assignments
reReg.sessionInds = zeros(size(fullReg.sessionInds,1),size(fullReg.sessionInds,2));
for sessI = 1:length(allSess)
    if reReg.skipSess(sessI) == false
        cellsHere = fullReg.sessionInds(:,sessI);
        numCells = length(cellsHere);
        for cellI = 1:numCells
            if cellsHere(cellI) > 0
                cellH = cellsHere(cellI);
                switch reReg.sessType(sessI)
                    case 1
                        targetCells = DNMPssi(:,reReg.sessInd(sessI));
                    case 2
                        targetCells = FFssi(:,reReg.sessInd(sessI));
                end
                cellJ = find(targetCells==cellH); %Row in target cellSSI
                reReg.sessionInds(cellI,sessI) = cellJ;
            end
        end
    end
end

end