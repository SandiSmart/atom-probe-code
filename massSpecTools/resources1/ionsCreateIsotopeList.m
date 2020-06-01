function [ions, abundance, weight] = ionsCreateIsotopeList(ion, isotopeTable)
% takes an ion type, e.g.'Cr2 O3' and gives all isotopic combinations,
% based on the supplied isotopeTable


%% interpret ion name into a table [element count]
ionTable = convertIonName(ion);

% calculate individual element count
atoms = removecats(ionTable.element); % also removes potential unused atom categories
element = categorical(categories(atoms));
count = countcats(atoms);
atomList = table(element,count);

%% create individual isotopic abundances
numElements = height(atomList);

% create seperate isotope combination lists for each element
for el = 1:numElements
    isos = isotopeTable(isotopeTable.element == atomList.element(el),:);
    %isoList{el} = isos.isotope(nreplacek(height(isos),atomList.count(el)));
    isoList{el} = isos.isotope(unique(sort(permn(1:height(isos),atomList.count(el)),2),'rows'));
    idx{el} = 1:length(isoList{el}(:,1)); %used later for indexing into ion List
end
% get combinations of elemental ion combinations
grid = cell(1,numel(idx));
[grid{:}] = ndgrid(idx{:});
combos = reshape(cat(numElements+1,grid{:}), [], numElements);
numCombos = length(combos(:,1));

% calculate relative abundances and weights
for c = 1:numCombos
    weight(c) = 0;
    abundance(c) = 1;
    ions{c} = table("",[0],'VariableNames',{'element','isotope'});
    nucCount = 0;
    for el = 1:numElements
        isos = isoList{el}(combos(c,el),:);
        for iso = 1:length(isos)
            nucCount = nucCount + 1;
            weight(c) = weight(c) + isotopeTable.weight((isotopeTable.element == atomList.element(el)) & (isotopeTable.isotope == isos(iso)));
            abundance(c) = abundance(c) * isotopeTable.abundance((isotopeTable.element == atomList.element(el)) & (isotopeTable.isotope == isos(iso))) /100;
            warning('off');
            ions{c}.element(nucCount) = char(atomList.element(el));
            ions{c}.isotope(nucCount) = isos(iso);
        end
    end
    ions{c}.element = categorical(ions{c}.element);
    ions{c}.isotope = ions{c}.isotope;
end

abundance = abundance/sum(abundance); % normalize. Abundances wont sum up exactly to 1