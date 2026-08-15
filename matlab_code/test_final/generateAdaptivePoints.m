function X_new = generateAdaptivePoints(net, N, L, T)
    x = L * rand(N,1); t = T * rand(N,1);
    X = [x, t]';
    X_dl = dlarray(X, 'CB');
    
    % 使用 dlfeval 确保在正确上下文中计算残差
    res = dlfeval(@computeResidual, net, X_dl);
    res = abs(extractdata(res));
    
    [~, idx] = maxk(res, round(N/2));
    X_new = X(:, idx);
    
    % 补充均匀点
    X_rand = [L*rand(N-round(N/2),1), T*rand(N-round(N/2),1)]';
    X_new = [X_new, X_rand];
end