function parameters = initializeParameters(L, W)
    for i = 1:L
        parameters.("W"+i) = dlarray(initializeGlorot(W,W));
        parameters.("b"+i) = dlarray(zeros(W,1));
    end
    parameters.("W"+L) = dlarray(initializeGlorot(1,W));
    parameters.("b"+L) = dlarray(zeros(1,1));
end

function W = initializeGlorot(out, in)
    limit = sqrt(6 / (in + out));
    W = (2*rand(out, in) - 1) * limit;
end