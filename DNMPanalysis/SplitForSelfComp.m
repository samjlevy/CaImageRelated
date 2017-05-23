function [split1, split2]= SplitForSelfComp(frame_bounds_struct, splitmode)
%Takes as input the frame boundaries struct from GetBlock... and splits it
%in 2 for same-condition comparisons

if nargin==1
    splitmode='alternate';
end

s = fieldnames(frame_bounds_struct);

for thisField = 1:length(s)
   work = frame_bounds_struct.(s{thisField});
   nEntries = size(work,1);
   
   switch splitmode
       case 'alternate'
           splitInds1 = 1:2:nEntries;
           splitInds2 = 2:2:nEntries;
       case 'rand'
           entries = 1:nEntries;
           entries = entries(randperm(nEntries));
           splitInds1 = entries(1:2:nEntries);
           splitInds2 = entries(2:2:nEntries);
       case 'half'
           splitInds1 = 1:floor(nEntries/2);
           splitInds2 = floor(nEntries/2)+1:nEntries;
           if abs(length(splitInds1) - length(splitInds2)) > 1
               disp('something wrong splitting by half')
           end
   end
   
   split1.(s{thisField}) = work(splitInds1,:);
   split2.(s{thisField}) = work(splitInds2,:);
   
end
    
end