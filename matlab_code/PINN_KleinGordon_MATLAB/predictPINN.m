function u = predictPINN(X, parameters)
    a = X';
    numLayers = numel(fieldnames(parameters))/2;
    for i = 1:numLayers
        W = parameters.("W"+i);
        b = parameters.("b"+i);
        z = W * a + b;
        if i < numLayers
            a = tanh(z);
        else
            a = z;
        end
    end
    u = a';
end
