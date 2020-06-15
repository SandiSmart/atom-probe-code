function [p, ax] = scatterPlotPosData(pos,species,sample,colorScheme,size,plotAxis)
%plots APT data in the usual style. Sample allows the specificaiton of a
%subset to plot. If sample <1, it is a fraction of the overall number of
%atoms, if >1, it is a fixed number. 'color' is provided as RGB vector
%'crop' crops data before plotting rather than just setting axes limits.
%Makes for more responsive plots and smaller fiels when saving a figure. If
%an axis is parsed, it will be plotted in that axis.

% alternatively to a colorScheme, also raw color values can be given.

% for single atom ions with no chargeState definition:
% uses ions when no atom range allocated (not 'decomposed'), atoms when allocated

% ax axis output is only important if a tiled plot is created

%sample needs to be scalar or vector with same length as species. Same for
%size

%if multiple species are given and no plotAxis, array of axes is plotted with synced axis
%movement. Otehrwise they all go into the same axis. plothandle (p) and
%axis (ax) output can therefore be scalar or aray


% find how many plots need to be done
if iscell(species)
    numPlots = length(species);
else
    numPlots = 1;
    species = {species}; % convert to cell array to be consistant with input of multiple species
end

% default size is 36, if size is not given
if ~exist('size','var')
    size = 15;
end


% check if the pos file is decomposed
isDecomposed = any(string(pos.Properties.VariableNames) == "atom");


%% set up the sample and size variables for multiple plots, if needed also color
if numPlots > 1
    if isscalar(sample); sample = repmat(sample,numPlots,1); end
    if isscalar(size); size = repmat(size,numPlots,1); end
    if ~istable(colorScheme)
        if size(colorScheme,1) == 1
            color = repmat(colorScheme,numPlots,1);
        end
    end
    
end

%% set up plot figure and axis
isTilePlot = false;

if exist('plotAxis','var'); isExistingAxis = true; % so that all plots go in existing axis 
else % plots in new axis/figure
    fig = figure();
    fig.Color = 'w';
    isExistingAxis = false;
    if numPlots > 1
        isTilePlot = true;% if multiple plots are made in a new figure, we use tiles
        tileLayoutHandle = tiledlayout(fig,'flow','TileSpacing','normal');
        fig.Name = 'atom maps';
        
    else
        fig.Name = [species{1} ' atom map'];
    end
end



%% loop through plots
for pl = 1:numPlots
    
    % finding the atoms in the pos file
    % element: 'Fe'
    % elemental isotope: '56Fe'
    % ion: 'Fe+' or 'Fe' if pos variable is not decomposed
    [ionTable, ionChargeState] = ionConvertName(species{pl});
    displayName = ionConvertName(ionTable, ionChargeState, 'LaTeX');
    
    % finds chemical elements
    if any(isnan(ionTable.isotope)) & isDecomposed & isnan(ionChargeState) & height(ionTable) == 1
        %use atoms
        speciesIdx = find(pos.atom == species{pl});
        color = colorScheme.color(colorScheme.ion == species{pl},:);
        
    % finds isotopes (only single atom basis)    
    elseif ~any(isnan(ionTable.isotope)) & isDecomposed & isnan(ionChargeState) 
        if height(ionTable) > 1
            error('plotting of ions based on isotopic information not currently supported');
        end
        speciesIdx = find(pos.atom == ionConvertName(ionTable.element) & pos.isotope == ionTable.isotope);
        color = colorScheme.color(colorScheme.ion == ionConvertName(ionTable.element),:);
        
    elseif ~any(isnan(ionTable.isotope)) & ~isnan(ionChargeState)
        error('plotting of ions based on isotopic information not currently supported');
    
    % finds specific ions with charge state
    elseif ~isnan(ionChargeState)
        speciesIdx = find(pos.ion == ionConvertName(ionTable.element) & pos.chargeState == ionChargeState);
        color = colorScheme.color(colorScheme.ion == ionConvertName(ionTable.element),:);
    % finds specific ions without chargestate
    else
        speciesIdx = find(pos.ion == ionConvertName(ionTable.element));
        if height(ionTable) == 1
            displayName = [displayName ' (ion)'];
        end
        color = colorScheme.color(colorScheme.ion == ionConvertName(ionTable.element),:);
    end
    
    
    
    
    
    numAtoms = length(speciesIdx);
    
    % checking if number of atoms/ions requested is greater than number
    % available
    if sample(pl) > numAtoms
        sample(pl) = numAtoms;
        warning(['number of requested ' species{pl}...
            ' atoms/ions greater than number of atoms in dataset. All atoms plotted']);
    elseif sample(pl) <= 1
        sample(pl) = round(numAtoms * sample(pl));
    end
    % calculating sample indices
    plotIndices = speciesIdx(randsample(numAtoms,sample(pl)));
    
    
    % set up axis for plotting if required
    if isExistingAxis
        ax(pl) = plotAxis;
        hold on
    else
        if isTilePlot
            ax(pl) = nexttile(tileLayoutHandle);
        else % new plot in new axis
            ax(pl) = axes(fig);
        end
    end
    
    %displayName = species{pl};
    

    
    % marker setup depending on marker size
    if size(pl) > 35
        edgeColor = [0 0 0];
        fillColor = color;
        markerStyle = 'o';
    else
        edgeColor = color;
        fillColor = color;
        markerStyle = '.';
    end
    
    % actual scatter plot
    p(pl) = scatter3(pos.x(plotIndices),pos.y(plotIndices),pos.z(plotIndices),...
        markerStyle,...
        'MarkerEdgeColor',edgeColor,...
        'MarkerFaceColor',fillColor,...
        'SizeData',size(pl),...
        'DisplayName',displayName,...
        'Parent',ax(pl));
    
    
    if ~isExistingAxis % condition new axes
        ax(pl).Box = 'on';
        ax(pl).BoxStyle = 'full';
        ax(pl).XColor = [1 0 0];
        ax(pl).YColor = [0 1 0];
        ax(pl).ZColor = [0 0 1];
        ax(pl).ZDir = 'reverse';
        if isTilePlot; title(ax(pl),displayName); end
        axis equal;
    end
    
end


%% link rotation between axes
if isTilePlot
    rotLink = linkprop(ax,{'CameraUpVector', 'CameraPosition',...
        'CameraTarget','XLim','YLim','ZLim'}); % links rotation
    setappdata(fig, 'StoreTheLink', rotLink);
end

rotate3d on;
ax = ax';
pl = pl';

