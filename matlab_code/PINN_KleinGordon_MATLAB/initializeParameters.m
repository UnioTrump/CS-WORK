function parameters = initializeParameters(numLayers, numNeurons)
    parameters = struct;
    inputSize = 2;
    outputSize = 1;

    layerSizes = [inputSize, repmat(numNeurons,1,numLayers-1), outputSize];

    for i = 1:numLayers
        W = randn(layerSizes(i+1), layerSizes(i));
        b = randn(layerSizes(i+1),1);
        parameters.("W"+i) = dlarray(W);
        parameters.("b"+i) = dlarray(b);
    end
end
