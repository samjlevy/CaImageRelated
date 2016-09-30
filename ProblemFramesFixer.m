n_good_use = 2; %frame 2 was fine
Fuse = h5read('Obj_3 - motCorrMovie(1).h5','/Object',[1 1 n_good_use 1],[XDim YDim 1 1]);
n_bad_fix = 1; %frame 1 had junk on top
bad = h5read('Obj_3 - motCorrMovie(1).h5','/Object',[1 1 n_bad_fix 1],[XDim YDim 1 1]);
h5write(outfile,'/Object',uint16(Fuse),[1 1 k 1],[XDim YDim 1 1]);

for k=2:end_frame
                h5write(outfile,'/Object',uint16(Fuse),[1 1 k 1],[XDim YDim 1 1]);
            end