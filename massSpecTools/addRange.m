%missing functionality: 
%check for range overlaps
%possible cases- total overlap: range dismissed
%partial overlap: range is clipped to the adjacent range
%
%integrate delete function, such that text is deleted with range.

function [h, txt] = addRange(spec,colorScheme)
%adds a range to a spectrum using graphical input
%output is the handle to the area plot and the corresponding text
% if mutiple isotopic combinations of the same ion are within the range,
% automatically the one with the higher abundance (peak height) will be taken

% set current axes
ax = spec.Parent;
axes(ax);

% user input
lim = ginput(2);
lim = lim(:,1);
lim = sort(lim);


isIn = (spec.XData > lim(1)) & (spec.XData < lim(2));
h = area(spec.XData(isIn),spec.YData(isIn));
h.FaceColor = [1 1 1];
h.UserData.plotType = "range";


%% search for ions in mass spectrum plot
plots = ax.Children;
isIon = false(length(plots),1);
for pl = 1:length(plots)
    try
        isIon(pl) = strcmp(plots(pl).UserData.plotType,"ion");
    end
end
ionPlots = plots(isIon);

% find ions in range (if there are any)
potentialIon = {};
potentialIonChargeState = [];
potentialIonPeakHeight = [];
if ~isempty(ionPlots)
    for pl = 1:length(ionPlots)
        isIn = (ionPlots(pl).XData > lim(1)) & (ionPlots(pl).XData < lim(2));
        if any(isIn)
            % if mutiple isotopic combinations of the ion are within the range, 
            % the most aundant one is automatically chosen
            isIn = (ionPlots(pl).YData == max(ionPlots(pl).YData(isIn))) & isIn; 
            
            potentialIon{end+1} = ionPlots(pl).UserData.ion{isIn};
            if isscalar(ionPlots(pl).UserData.chargeState)
                potentialIonChargeState(end+1) = ionPlots(pl).UserData.chargeState;
            else 
                potentialIonChargeState(end+1) = ionPlots(pl).UserData.chargeState(isIn);
            end
            potentialIonPeakHeight(end+1) = ionPlots(pl).YData(isIn);
        end
    end
    
end


%select which ion it is if necessary

    % manual input
if isempty(potentialIon) 
    txt = inputdlg('manually enter range name','ion selection');
    [ion, chargeState] = ionConvertName(txt{1});
    h.UserData.ion = ion;
    h.UserData.chargeState = chargeState;
    h.DisplayName = ionConvertName(h.UserData.ion,h.UserData.chargeState);
    h.FaceColor = colorScheme.color(colorScheme.ion == ionConvertName(h.UserData.ion.element),:);
    
    
    % clear choice
elseif length(potentialIon) == 1
    h.UserData.ion = potentialIon{1};
    h.UserData.chargeState = potentialIonChargeState(1);
    h.DisplayName = ionConvertName(h.UserData.ion,h.UserData.chargeState);
    h.FaceColor = colorScheme.color(colorScheme.ion == ionConvertName(h.UserData.ion.element),:);
    
       
else % selection
    numPotIon = length(potentialIon);
    for i = 1:numPotIon
        names{i} = [ionConvertName(potentialIon{i}, potentialIonChargeState(i)) '   ' num2str(potentialIonPeakHeight(i))];
    end
    % select the ion, defaulting to most abundant.
    [idx, isSelection] = listdlg('ListString',names,'PromptString','Select ion species','SelectionMode','single',...
        'InitialValue',find(potentialIonPeakHeight == max(potentialIonPeakHeight)));
    
    if ~isSelection
        delete(h);
        return
    end
    
    h.UserData.ion = potentialIon{idx};
    h.UserData.chargeState = potentialIonChargeState(idx);
    h.DisplayName = ionConvertName(h.UserData.ion,h.UserData.chargeState);
    h.FaceColor = colorScheme.color(colorScheme.ion == h.UserData.ion.element(1),:);%XXXXXfix
end

% define for all hit multiplicities
h.UserData.hitMultiplicities = [0 Inf];

% add text to denote range
txt = text(h.XData(1),max(h.YData)*1.4,ionConvertName(h.UserData.ion,h.UserData.chargeState,'LaTeX'),'clipping','on');
txt.UserData.plotType = "text";
txt.DisplayName = ionConvertName(h.UserData.ion,h.UserData.chargeState,'plain');

h.DeleteFcn = @(~,~) delete(txt);

