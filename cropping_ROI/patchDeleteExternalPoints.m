function fv = patchDeleteExternalPoints(fv,pos,numRims)
% deletes all points of a patch object that are outside the dataset. This
% is done by deleting all points that have no atomic position that is
% closer to them than no other vertex.
% numRims is the number of edge loops to be deleted on top of the unused verts.


% calculate which vertices are inside the dataset
vertCoords = fv.vertices;
atomCoords = [pos.x, pos.y, pos.z];
closest = dsearchn(vertCoords,atomCoords);
isIn = ismember(1:length(vertCoords),closest);


% remove unused vertices
fv = removeVerticesPatch(fv,fv.vertices(~isIn,:));

% remove boundary vertices for n boundary rings
if exist('numRims','var')
    for i=1:numRims
        bnd = computeBoundary(fv);
        fv = removeVerticesPatch(fv,fv.vertices(bnd,:));
    end
end