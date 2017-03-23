% Pass 2 at comparing by block types, RSA, etc. 

%list of sessions that only have one tracking and can be run now:
filesToRun = [20 28 29 30 31 34 35 37 39 40 41]; 

for session = 1:length(SessionsToRun)
    cd(MD(SessionsToRun(session)).Location)
    [ ~, ~, ~ ] = JustFToffset;
    xlsFiles = dir('*DNMPsheet.xlsx');
    ParsedFramesToBrainFrames ( xlsFiles.name )
end

for 
columnLabel = {'Start on maze (start of Forced', 'Lift barrier (start of free choice)',...
               'Leave maze', 'Start in homecage', 'Leave homecage',...
               'Forced Trial Type (L/R)', 'Free Trial Choice (L/R)',...
               'Enter Delay', 'Forced Choice', 'Free Choice',...  
               'Forced Reward', 'Free Reward'};
           
[ framesLabelIndex ] = ConditionalExcellParseout( txt, columnLabel);
blocks = frames(:,1);
forced_start = frames(:,2);
free_start = frames(:,3);
leave_maze = frames(:,4);
cage_start = frames(:,5);
cage_leave = frames(2:end,6);
delay_start = bonusFrames(:,2);
delay_end = free_start;
forced_end = delay_start;
free_end = leave_maze;

Need:
      forced stem l/r
      forced to reward l/r
      forced to delay l/r
      delay following l/r
      free stem l/r
      free arm l/r
      cage following l/r
      correct/wrong 1/0 vector
      
Selectivity for forced/free
Selectivity for l/r