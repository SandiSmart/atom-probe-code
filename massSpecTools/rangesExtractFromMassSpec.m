function rangeTable = rangesExtractFromMassSpec(spec)
% pulls all ranges and additional information from a mass spectrum plot
% gets all plots connected to the mass spectrum
% 
% INPUT: spec, area plot that displays the mass spectrum (histogram of m/c frequencies) 
%        either in raw counts or normalised to bin width and total ion count
%
% OUTPUT: rangeTable, table with allocated ranges of the ions and additional information
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
    
    if type == "range"
        mcbegin(idx,:) = plots(pl).XData(1);
        mcend(idx,:) = plots(pl).XData(end);
        rangeName{idx,:} = ionConvertNameTable(plots(pl).UserData.ion.element);
        volume(idx,:) = 0;
        ion{idx,:} = plots(pl).UserData.ion;
        color(idx,:) = plots(pl).FaceColor;
        chargeState(idx,:) = plots(pl).UserData.chargeState;
        
        
        idx = idx +1;
    end
    
end

rangeName = categorical(rangeName);
rangeTable = table(rangeName,chargeState,mcbegin,mcend,volume,ion,color);
rangeTable = sortrows(rangeTable,'mcbegin','ascend');