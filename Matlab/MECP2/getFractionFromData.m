function [fraction1, fraction2, fraction3, after_all] = getFractionFromData(data, celltype, Slope, Blank, shadingData)
%[fraction1, fraction2, fraction3, after_all] = getFractionFromData(data, celltype)
%   retruns fractions and post bg subtraction dye conc in nM
%%
dyes = [608,669,552];
chs = [2,4,5];
%shadingFactor = shadingData(chs);
%%
val_all = data.Values;
bg_all = data.BG;
types = data.Cell_Type;
after_all = zeros(size(val_all,1),3);
%%
for c_index = 1:3
    c = chs(c_index);
    current = val_all(:,c);%./shadingFactor(c_index);
    bg = bg_all(:,c);%./shadingFactor(c_index);
    dye = dyes(c_index);
    current = (current - Blank(dye)) ./ Slope(dye);
    current = current .* 1000;
    bg  = (bg - Blank(dye)) ./ Slope(dye);
    bg  = bg .* 1000 ;
    after_all(:,c_index) = current-bg;
end
%%
sum1 = after_all(:,2) + after_all(:,3);
fraction = after_all(:,2) ./ sum1;
fraction(fraction<0) = 0;
fraction(fraction> 10) = 10;
if celltype > 0 && celltype <= 4
    fraction1 = fraction(types==celltype);
else
    fraction1 = fraction;
end
%% 
sum1 = after_all(:,1) + after_all(:,2) + after_all(:,3);
fraction = (after_all(:,3) + after_all(:,2)) ./ sum1;
fraction(fraction<0) = 0;
fraction(fraction> 10) = 10;
if celltype > 0 && celltype <= 4
    fraction2 = fraction(types==celltype);
else
    fraction2 = fraction;
end
%%
sum1 = after_all(:,1) + after_all(:,2) + after_all(:,3);
fraction = after_all(:,2) ./ sum1;
fraction(fraction<0) = 0;
fraction(fraction> 10) = 10;
if celltype > 0 && celltype <= 4
    fraction3 = fraction(types==celltype);
else
    fraction3 = fraction;
end
%%
if celltype > 0 && celltype <= 4
    after_all = after_all(types==celltype,:);
end
end

