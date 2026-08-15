function parameters = sgdUpdate(parameters, gradients, learnRate)
    names = fieldnames(parameters);
    for i = 1:numel(names)
        name = names{i};
        parameters.(name) = parameters.(name) - learnRate * gradients.(name);
    end
end
