function [include, exclude] = MakeIncExcVectors(frameBounds, sessionLength)

include = zeros(1, sessionLength);
for aa = 1:size(frameBounds)
    include(frameBounds(aa,1):frameBounds(aa,2)) = 1;
end
include = double(include);
exclude = double(include==0);

end