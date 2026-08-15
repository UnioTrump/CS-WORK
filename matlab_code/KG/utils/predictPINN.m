function u = predictPINN(X, parameters)
    a = X;
    L = numel(fieldnames(parameters)) / 2;
    for i = 1:L-1
        a = tanh(parameters.("W"+i)*a + parameters.("b"+i));
    end
    u = parameters.("W"+L)*a + parameters.("b"+L);
end