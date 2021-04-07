numbers = [1 1 1 1 1 0 0 0 0 0;...
           0 0 0 1 1 1 0 0 0 0];
numbers = numbers';
numbers = [numbers; sum(numbers,1)/size(numbers,1)];

white(1,1,1:3) = 1;

patchColors = repmat(white,size(numbers,1),size(numbers,2),1);
            
figHand = PlotNumberOverPatch(flipud(numbers),flipud(patchColors));
figHand.Position = [50 50 116 625];

numbers2 = sum(numbers(1:end-1,:),2) ==2;
numbers2 = [numbers2; sum(numbers2,1)/size(numbers2,1)];
green(1,1,1:3) = [0 1 0];
patchColors2 = repmat(white,size(numbers2,1),size(numbers2,2),1);
patchColors2(4,1,:) = green;
patchColors2(5,1,:) = green;
figHand = PlotNumberOverPatch(flipud(numbers2),flipud(patchColors2));
figHand.Position = [50 50 116 625];