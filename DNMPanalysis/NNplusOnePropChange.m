function propChange = NNplusOnePropChange(vectorIn)
%organization is days along dim 2

propChange = diff(vectorIn,1,2);

end