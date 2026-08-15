function [loss, gradients] = modelLoss(parameters, X_ic, u_ic, dudt_ic, X_bc, u_bc, X_f, alpha)

    % 初始条件：t=0，预测 u 和 ∂u/∂t
    u_pred_ic = predictPINN(X_ic, parameters);
    dudt_pred_ic = dlgradient(sum(u_pred_ic), X_ic(:,2));
    
    % 边界条件：x=0,1，预测 u
    u_pred_bc = predictPINN(X_bc, parameters);
    
    % 内部点：物理约束残差（PDE）
    u_pred_f = predictPINN(X_f, parameters);
    S = sum(u_pred_f);

    du_dt = dlgradient(S, X_f(:,2), 'EnableHigherDerivatives', true);
    d2u_dt2 = dlgradient(sum(du_dt), X_f(:,2));

    du_dx = dlgradient(S, X_f(:,1), 'EnableHigherDerivatives', true);
    d2u_dx2 = dlgradient(sum(du_dx), X_f(:,1));

    % 源项
    f = 6*X_f(:,2).*(X_f(:,1).^2 - X_f(:,2).^2) - 25*pi^2*X_f(:,1).*cos(5*pi*X_f(:,2));
    
    % 损失项
    loss_ic = mse(u_pred_ic, u_ic, 'DataFormat', 'CB') + mse(dudt_pred_ic, dudt_ic, 'DataFormat', 'CB');
    loss_bc = mse(u_pred_bc, u_bc, 'DataFormat', 'CB');
    loss_f = mse(d2u_dt2 - alpha^2 * d2u_dx2, f, 'DataFormat', 'CB');
    
    % 总损失
    loss = loss_ic + loss_bc + loss_f;
    
    % 梯度
    gradients = dlgradient(loss, parameters);
end
