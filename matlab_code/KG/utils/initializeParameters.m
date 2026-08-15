function parameters = initializeParameters(L, W)
    parameters.W1 = dlarray(initializeGlorot(W, 2));  % 第一层输入是2个变量 x, t
    parameters.b1 = dlarray(zeros(W,1));

    for i = 2:L-1
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