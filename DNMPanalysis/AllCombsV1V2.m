function vv = AllCombsV1V2(VA,VB)

VA = VA(:);
VB = VB(:);

VAall = repmat(VA,length(VB),1);
VBtemp = repmat(VB',length(VA),1);
VBall = VBtemp(:);

vv = [VAall VBall];

end