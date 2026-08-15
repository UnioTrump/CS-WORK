function X_new = generateAdaptivePoints(net, N, L, T)
    x = L * rand(N,1); t = T * rand(N,1);
    X = [x, t]';
    dlX = dlarray(X, 'CB');
    
    % 使用 dlfeval 调用 residual 计算
    res = abs(extractdata(dlfeval(@computeResidualWrapper, net, dlX)));

    [~, idx] = maxk(res, round(N/2));
    X_new = X(:, idx);

    % 补充均匀点
    X_rand = [L*rand(N-round(N/2),1), T*rand(N-round(N/2),1)]';
    X_new = [X_new, X_rand];
end

function res = computeResidualWrapper(net, dlX)
    res = computeResidual(net, dlX);
end
