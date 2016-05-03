backgroundInd = [];
objectsMarked = numel(annotation.frame(1).targetIndividual);
for j=1:objectsMarked
    if strcmp(char(annotation.frame(1).targetIndividual(j).id), 'background') == 1
        backgroundInd = [backgroundInd, j];
    end
end
maxSample = min(300,numel(backgroundInd));

sampledWindows = randsample(backgroundInd, maxSample);
