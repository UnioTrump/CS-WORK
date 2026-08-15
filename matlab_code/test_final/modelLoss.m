function [loss, grad] = modelLoss(net, X_f, X0, u0, X0_t, X_l, X_r)
    % PDE残差
    eq_res = computeResidual(net, X_f);
    loss_pde = mean(eq_res.^2);
    
    % 初始条件1: u(x,0)=0
    u0_pred = forward(net, X0);
    loss_ic1 = mean((u0_pred - u0).^2);
    
    % 初始条件2: ∂u/∂t(x,0)=0
    u_t0 = dlgradient(sum(forward(net, X0_t), 'all'), X0_t(2,:), 'EnableHigherDerivatives', true);
    loss_ic2 = mean(u_t0.^2);
    
    % 边界条件: u(0,t)=0, u(1,t)=0
    ul = forward(net, X_l);
    ur = forward(net, X_r);
    loss_bc = mean(ul.^2) + mean(ur.^2);  % 修正边界条件
    
    % 组合损失
    loss = loss_pde + 10*loss_ic1 + 10*loss_ic2 + 10*loss_bc;
    grad = dlgradient(loss, net.Learnables);
end