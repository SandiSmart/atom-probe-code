% function worked properly, however after changing the function name
% of "convertIonName" to the correct name "ionConvertNameTable" (line 33),
% function does not work as long as ionConvertNameTable is not updated

function ionTable = ionsExtractFromMassSpec(spec)
% pulls all ions and corresponding information from a mass spectrum plot
% gets all plots connected to the mass spectrum
%
% INPUT: spec, area plot that displays the mass spectrum (histogram of m/c frequencies) 
%        either in raw counts or normalised to bin width and total ion count
%
% OUTPUT: ionTable, table with allocated ions and additional information
%         (charge state, corresponding color code)
%

plots = spec.Parent.Children;

idx = 1;


for pl = 1:length(plots)
    
    % find all the ones that are ranges
    try
        type = plots(pl).UserData.plotType;
    catch
        type = "unknown";
    end
    
    if type == "ion"
        ion{idx,:} = plots(pl).UserData.ion{1}.element; % do not extract isotope information
        chargeState(idx,:) = plots(pl).UserData.chargeState(1);
        ionName{idx,:} = ionConvertNameTable(plots(pl).UserData.ion{1}.element);
        color(idx,:) = plots(pl).Color;
        
        idx = idx + 1;
        
    end
    
end

ionName = categorical(ionName);
ionTable = table(ionName,chargeState,ion,color);
