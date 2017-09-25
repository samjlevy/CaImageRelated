PlotStemHeatmaps(base_path,reg_paths)
base_path = 'F:\Bellatrix\Bellatrix_160831';
reg_paths = {'F:\Bellatrix\Bellatrix_160830';...
             'F:\Bellatrix\Bellatrix_160901'};

cmperbin = 1;

[allfiles, all_x_adj_cm, all_y_adj_cm, all_PSAbool, sortedSessionInds, all_useLogical, useActual]...
    = GetMegaStuff(base_path, reg_paths);

[allfiles, position, all_PSAbool, correctBounds, badLaps, sortedSessionInds, lapNumber]...
    = GetMegaStuff2(base_path, reg_paths, regUseType, regUseInput)

MultiSessPlacefieldsLin( allfiles, all_x_adj_cm, all_y_adj_cm, sortedSessionInds,...
    all_PSAbool, cmperbin, all_useLogical, useActual)

%170822
[allfiles, position, all_PSAbool, correctBounds, ~, sortedSessionInds, lapNumber]...
    = GetMegaStuff2(base_path, [], 'sessionType', 1);