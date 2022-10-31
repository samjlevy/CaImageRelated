function RestoreOriginalTBTstuff(sessionFolder)

% This function is to restore the original session organization so that we
% can rerun the fixing functions

cd(sessionFolder)

oFiles = dir('*Original*');

if ~isempty(oFiles)

    oLen = length('original');
    
    for fileI = 1:size(oFiles,1)
        % Delete the one with the main title
        fName = oFiles(fileI).name;
        oLoc = strfind(fName,'Original');
        mainName = fName(1:(oLoc-1));
        mainExt = fName((oLoc+oLen):end);
    
        % change the name of the original file to main
        baseName = [mainName mainExt];
        delete(baseName)
        movefile(fName,baseName)
    end

else
    disp(['no Original files in ' sessionFolder])
end