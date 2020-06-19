function colorScheme = colorSchemeCreate(ionTable)
% colorSchemeCreate creates a table with RGB color codes for each ion; 
% the colors are generated in a way, that no two colors are perceived as similar
%
% INPUT: 
% ionTable:     table with variable ion (ionTable.ion)
%               example: ionTable = table(categorical({'Fe'; 'C'; 'H'; 'N'}));
%                        ionTable.Properties.VariableNames{1} = 'ion';
%
% OUTPUT:
% colorScheme:  table with ion field and corresponding color field

%% determine values for Saturation (S) and Value (V) of the HSV color code
S = 1.0;                % Saturation, value between 0 and 1 [1 means 100 %]
V = 1.0;                % Value, value between 0 and 1 [1 means 100 %]

%% generate evenly spaced values for H
ls = table(linspace(0, 0.8, height(ionTable)));     % value of 0 is equivalent to value of 1, therefore upper limit is set to 0.8
ls.Properties.VariableNames{1} = 'Hue';

%% generate colorScheme table
colorScheme = table('Size',[height(ionTable) 2],'VariableTypes',{'categorical','double'});
colorScheme.Properties.VariableNames{1} = 'ion';
colorScheme.Properties.VariableNames{2} = 'color';

%% fill colorScheme table with HSV values
for i = 1:height(ionTable);
    colorScheme.ion(i) = ionTable.ion(i);
    colorScheme.color(i,1) = ls.Hue(1,i);
    colorScheme.color(i,2) = S;
    colorScheme.color(i,3) = V;
end

%% create colorScheme table with RGB values
 cst = table(colorScheme.color);
 HSV = table2array(cst);           % insert HSV values in array
 
 % convert HSV color code to RGB color code
 RGB = hsv2rgb(HSV);               
 
 colorScheme.color = RGB;
end
