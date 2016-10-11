function [MDSL, session_ref] = MakeMouseSessionListSL(userstr)
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
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'C:\MasterData\InUse\Polaris_160831';
elseif strcmp(userstr,'SamLaptop')
    MDSL(i).Location = 'D:\Polaris_160831';
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
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_25_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:08:50.10 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Polaris\Polaris_160825';
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
end

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_29_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '06:45:09.41 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160829';
end

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_29_2016_2';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '06:55:54.23 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160829-2';
end

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '08_30_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '05:09:55.64 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160830';
end

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_01_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:42:31.11 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160901';
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
    MDSL(i).Location = 'H:\Polaris\Polaris_160902';
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
end
MDSL(i).Notes = [];

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


i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_07_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '02:31:01.58 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160907';
end
MDSL(i).Notes = [];

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

i = i+1;
MDSL(i).Animal = 'Polaris_DNMP';
MDSL(i).Date = '09_08_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '11:41:48.29 AM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Polaris\Polaris_160908';
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
end
MDSL(i).Notes = [];

%% Bellatrix DNMP
Bellatrix_DNMP.DNMP(1) = (i+1);

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_09_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'E:\SLIDE\Bellatrix\Bellatrix_160809';
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
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_22_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160822';
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
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160823';
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
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160824';
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
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160825';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_26_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160826';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_29_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160829';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_30_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160830';
end

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '08_31_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = ' ';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160831';
end
MDSL(i).Notes = [];

i = i+1;
MDSL(i).Animal = 'Bellatrix_DNMP';
MDSL(i).Date = '09_01_2016';
MDSL(i).Session = 1;
MDSL(i).Env = 'Continuous T Maze';
MDSL(i).Room = '201a - 2015';
MDSL(i).RecordStartTime = '04:42:31.11 PM';
if strcmp(userstr,'Sam')
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160901';
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
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160902';
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
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160907';
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
    MDSL(i).Location = 'H:\Bellatrix\Bellatrix_160910';
end
MDSL(i).Notes = [];

%% Europa


%% Compile session_ref

session_ref.Polaris_DNMP = Polaris_DNMP;
session_ref.Bellatrix_DNMP = Bellatrix_DNMP;
%%
MD=MDSL;
save MasterDirectory.mat MD;

cd(CurrDir);

loadMDSL;