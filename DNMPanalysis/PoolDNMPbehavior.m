function new_include = PoolDNMPbehavior(include_bounds, include_struct)
%Pooltype needs to be LR or FoFr
%Future: generalize for stuff?
%s = fieldnames(stem_include);

ss = fieldnames(include_bounds);
%rightStuff = cell2mat(cellfun(@(x) contains(x,'_r'),ss,'UniformOutput',false));
%leftStuff = cell2mat(cellfun(@(x) contains(x,'_l'),ss,'UniformOutput',false));

if any(strcmpi(ss,'study_l'))
new_include.bounds.right = [include_bounds.study_r; include_bounds.test_r];
new_include.bounds.left = [include_bounds.study_l; include_bounds.test_l];

new_include.include.right = double(include_struct.study_r | include_struct.test_r);
new_include.exclude.right = double(new_include.include.right == 0);

new_include.include.left = double(include_struct.study_l | include_struct.test_l);
new_include.exclude.left = double(new_include.include.left == 0);

new_include.bounds.forced = [include_bounds.study_r; include_bounds.study_l];
new_include.bounds.free = [include_bounds.test_l; include_bounds.test_r];

new_include.include.forced = double(include_struct.study_r | include_struct.study_l);
new_include.exclude.forced = double(new_include.include.forced== 0);

new_include.include.free =  double(include_struct.test_r | include_struct.test_l);
new_include.exclude.free = double(new_include.include.free == 0);

elseif  any(strcmpi(ss,'post_study_l'))
    new_include.bounds.right = include_bounds.post_study_l;
    new_include.bounds.left = include_bounds.post_study_r;

    new_include.include.right = double(include_struct.post_study_l);
    new_include.exclude.right = double(new_include.include.right == 0);

    new_include.include.left = double(include_struct.post_study_r);
    new_include.exclude.left = double(new_include.include.left == 0);

    new_include.bounds.forced = [];
    new_include.bounds.free = [];

    new_include.include.forced = [];
    new_include.exclude.forced = [];

    new_include.include.free =  [];
    new_include.exclude.free = []; 
    
end

end