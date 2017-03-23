function JustFToffsetBatch ( MD, SessionsToRun, inputsToFToffset ) 
%Runs Sam's FToffset script on a bunch of sessions

for session = 1:length(SessionsToRun)
    cd(MD(SessionsToRun(session)).Location)
    [ ~, ~, ~ ] = JustFToffset( );
end

end
