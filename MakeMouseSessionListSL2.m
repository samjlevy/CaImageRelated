function [MDSL, session_ref] = MakeMouseSessionListSL2(userstr)
% this function makes a list of the location of all sessions on disk
% session_ref: gives you the start and end indices of session types, and currently are:
%   'G31_2env', 'G30_alternation'

CurrDir = pwd;

global MasterDirectory
MasterDirectory = 'C:\MasterData';
cd(MasterDirectory);

%%Polaris DNMP
i = 1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_31_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '05:17:49.39 PM';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'G:\Polaris\Polaris_160831';
elseif strcmp(userstr,'SamLaptop')
    MDSL(i).Location = 'D:\Polaris_160831';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160831';
end

MDSL(i).Notes = [];
i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_09_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:41:29.97 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Polaris\Polaris_160809';
end
MDSL(i).Notes = [];

Polaris_DNMP.DNMP(1) = (i);

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_10_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:41:29.97 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Polaris\Polaris_160810';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_11_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '05:35:30.54 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Polaris\Polaris_160811';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_22_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '06:58:35.64 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Polaris\Polaris_160822';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160822';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_23_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:03:37.85 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'C:\MasterData\InUse\Polaris_160823';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160823';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_24_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:52:18.56 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Polaris\Polaris_160824';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160824';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_25_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:08:50.10 PM';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'G:\Polaris\Polaris_160825';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160825';
end

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_26_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '05:45:04.46 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Polaris\Polaris_160826';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160826';
end

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_29_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '06:45:09.41 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'M:\Polaris_160829';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Polaris\Polaris_160829all';
end
%{
i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_29_2016_2';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '06:55:54.23 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'M:\Polaris_160829-2';
end
%}
i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_30_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '05:09:55.64 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160830';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160830';
end

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_01_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:42:31.11 PM';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'G:\Polaris\Polaris_160901';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160901';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_02_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '05:40:47.86 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\Polaris\Polaris_160902';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Polaris\Polaris_160902';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_05_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:32:15.60 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160905';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Polaris\Polaris_160905';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_06_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:25:38.15 AM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160906';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Polaris\Polaris_160906all';
end
MDSL(i).Notes = [];
%{
i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_06_2016_2';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:36:35.43 AM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160906-2';
end
MDSL(i).Notes = [];
%}

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_07_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '02:31:01.58 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160907';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Polaris\Polaris_160907-2';
end
MDSL(i).Notes = [];

%{
i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_07_2016_2';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '03:02:38.37 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160907-2';
end
MDSL(i).Notes = [];
%}

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_08_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:41:48.29 AM';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'E:\Polaris\Polaris_160908';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Polaris\Polaris_160908';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_09_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:54:15.06 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160909';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Polaris\Polaris_160909';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_10_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '02:12:43.86 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160910';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Polaris\Polaris_160910';
end
MDSL(i).Notes = [];

%% Bellatrix DNMP
Bellatrix_DNMP.DNMP(1) = (i+1);

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_31_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160831';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160831';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_09_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Bellatrix\Bellatrix_160809';
    
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160831';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_10_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Bellatrix\Bellatrix_160810';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160831';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_11_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Bellatrix\Bellatrix_160811';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160831';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_12_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Bellatrix\Bellatrix_160812';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160831';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_22_2016 - 1';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160822';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160822';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_22_2016 - 2';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160822';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160822-2';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_22_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160822all';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Bellatrix_160822all';
end

MDSL(i).Notes = [];
i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_23_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160823';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Bellatrix_160823';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_24_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160824';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160824';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_25_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160825';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160825';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_26_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160826';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160826';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_29_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160829all';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160829all';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_29_2016 - 2';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160829';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160829_2';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_30_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160830';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160830';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_01_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:42:31.11 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160901';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160901';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_02_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'D:\Bellatrix\Bellatrix_160902all';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Bellatrix\Bellatrix_160902all';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_06_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\Bellatrix\Bellatrix_160906';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160906';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_07_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\Bellatrix\Bellatrix_160907all';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160907all';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_08_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\Bellatrix\Bellatrix_160908';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160908';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_09_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\Bellatrix\Bellatrix_160909';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160909';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_10_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\Bellatrix\Bellatrix_160910';
elseif strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160910';
end
MDSL(i).Notes = [];

%% Europa
Europa_DNMP.DNMP(1) = (i+1);

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_13_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:14:17.394000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Europa\Europa_161013';
elseif strcmp(userstr,'sam')
    MDSL(i).Location = 'H:\Europa\Europa_161013';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '09_28_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:40:11.052000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_160928all';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '09_29_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:03:14.154000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_160929all';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '09_30_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '111:44:51.228000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_160930';
end
MDSL(i).Notes = [];


i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_01_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:58:31.354000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161001';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_02_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '03:26:49.049000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161002';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_03_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:27:37.142000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161003';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_04_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:56:14.343000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161004';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_05_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '02:01:48.959000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161005';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_06_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:29:26.639000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161006';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_07_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:35:03.819000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161007';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_10_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:18:01.866000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'F:\Europa_161010';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_11_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '12:03:16.874000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161011';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_12_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:19:41.906000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Europa\Europa_161012';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_14_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:19:41.906000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Europa\Europa_161014';
elseif strcmp(userstr,'sam')
    MDSL(i).Location = 'H:\Europa\Europa_161014';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_15_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '03:58:50.803000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Europa\Europa_161015';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_16_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:50:42.500000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161016';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_17_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:05:07.842000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161017';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_18_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161018all';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_19_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '05:27:52.039000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161019';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_20_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:49:35.085000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161020';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_21_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:56:45.069000 AM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161021';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Europa_DNMP';
MDSL(i).Date = '10_22_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:39:40.531000 PM';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'G:\Europa\Europa_161022';
end
MDSL(i).Notes = [];
%% Calisto
i = i+1;
MDSL(i).Animal = 'Calisto_DNMP';
MDSL(i).Date = '10_27_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:39:40.531000 PM';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'I:\Calisto\Calisto_161027';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Calisto_DNMP';
MDSL(i).Date = '10_28_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:39:40.531000 PM';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'I:\Calisto\Calisto_161028';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Calisto_DNMP';
MDSL(i).Date = '11_02_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '01:39:40.531000 PM';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'I:\Calisto\Calisto_161102';
end
MDSL(i).Notes = [];

%% G50_open
G50_open(1) = (i+1);

i = i+1;
MDSL(i).Animal = 'G50_open';
MDSL(i).Date = '08_28_2017';
MDSL(i).Session = 1;
MDSL(i).Env = 'Mega open field';
MDSL(i).Room = '721b';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Europa\Europa_161013';
elseif strcmp(userstr,'sam')
    MDSL(i).Location = 'F:\G50really';
end
MDSL(i).Notes = [];

BOOG05_open(1) = (i+1);

i = i+1;
MDSL(i).Animal = 'BOOG05_open';
MDSL(i).Date = '08_27_2017';
MDSL(i).Session = 1;
MDSL(i).Env = 'Mega open field';
MDSL(i).Room = '721b';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Europa\Europa_161013';
elseif strcmp(userstr,'sam')
    MDSL(i).Location = 'D:\Boog05_170827\G50ofs';
end
MDSL(i).Notes = [];

ACM1(1) = (i+1);

i = i+1;
MDSL(i).Animal = 'ACM1';
MDSL(i).Date = '08_28_2017';
MDSL(i).Session = 1;
MDSL(i).Env = 'Mega open field';
MDSL(i).Room = '721b';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'mouseimage')
    MDSL(i).Location = 'I:\Europa\Europa_161013';
elseif strcmp(userstr,'sam')
    MDSL(i).Location = 'C:\Users\Sam\Desktop\CM_Miniscope\ACM1';
end
MDSL(i).Notes = [];

Styx(1) = (i+1);

i = i+1;
MDSL(i).Animal = 'Styx';
MDSL(i).Date = '03_14_2018';
MDSL(i).Session = 1;
MDSL(i).Env = 'Plus1';
MDSL(i).Room = '719h';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'E:\DoublePlus\Styx\Styx180314';
%elseif strcmp(userstr,'sam')
%    MDSL(i).Location = 'C:\Users\Sam\Desktop\CM_Miniscope\ACM1';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Marble07';
MDSL(i).Date = '06_28_2018';
MDSL(i).Session = 1;
MDSL(i).Env = 'Plus1';
MDSL(i).Room = '719h';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'E:\DoublePlus\Marble07\180628-2';
%elseif strcmp(userstr,'sam')
%    MDSL(i).Location = 'C:\Users\Sam\Desktop\CM_Miniscope\ACM1';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'December';
MDSL(i).Date = '12_10_2019';
MDSL(i).Session = 1;
MDSL(i).Env = 'Plus1';
MDSL(i).Room = '719h';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'E:\DoublePlus\December\December_191210';
%elseif strcmp(userstr,'sam')
%    MDSL(i).Location = 'C:\Users\Sam\Desktop\CM_Miniscope\ACM1';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Marble11';
MDSL(i).Date = '07_06_2018';
MDSL(i).Session = 1;
MDSL(i).Env = 'Plus1';
MDSL(i).Room = '719h';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'H:\DoublePlus\Marble11\Marble11_180706-2';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'testAnimal';
MDSL(i).Date = '11_13_2020';
MDSL(i).Session = 1;
MDSL(i).Env = 'Plus1';
MDSL(i).Room = '719h';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'G:\SpacedAlternation\610959\201113';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Kerberos';
MDSL(i).Date = '04_22_2018';
MDSL(i).Session = 1;
MDSL(i).Env = 'Plus1';
MDSL(i).Room = '719h';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'sam')
    MDSL(i).Location = 'E:\DoublePlus\Kerberos\Kerberos180422';
end
MDSL(i).Notes = [];
%% Compile session_ref

session_ref.Polaris_DNMP = Polaris_DNMP;
session_ref.Bellatrix_DNMP = Bellatrix_DNMP;
session_ref.Europa_DNMP= Europa_DNMP;
%%
MD=MDSL;
save MasterDirectory.mat MD;

cd(CurrDir);
try
loadMDSL;
catch 
    load(fullfile('C:\MasterData','MasterDirectory.mat'));
end