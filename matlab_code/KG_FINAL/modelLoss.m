function [loss, grad] = modelLoss(net, X_f, X0, u0, X_dt0, X_l, X_r)
    % 网络前向计算
    u_f = forward(net, X_f);      % PDE内点预测
    u0_pred = forward(net, X0);   % 初始条件预测
    ul = forward(net, X_l);       % 左边界预测
    ur = forward(net, X_r);       % 右边界预测

    % PDE残差
    eq_res = computeResidual(net, X_f);
    loss_pde = mean(eq_res.^2);

    % 初始条件 u(x,0) = 0
    loss_ic = mean((u0_pred - u0).^2);

    % 边界条件 u(0,t)=0 和 u(L,t)=0
    loss_bc = mean(ul.^2) + mean(ur.^2);

    % 时间导数初值条件 du/dt(x,0) = 0
    N0 = size(X_dt0,2);
    du_dt_vals = zeros(1,N0,'like',u0_pred);
    for i = 1:N0
        Xi = dlarray(X_dt0(:,i), 'CB');
        u_pred_i = forward(net, Xi);
        du_dt_vals(i) = dlgradient(u_pred_i, Xi(2));  % 对t求导
    end
    loss_du_dt = mean(du_dt_vals.^2);

    % 总损失，调整权重根据实验调
    loss = loss_pde + 10*loss_ic + 10*loss_bc + 10*loss_du_dt;

    % 计算梯度
    grad = dlgradient(loss, net.Learnables);
end
