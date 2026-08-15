function [loss, gradients] = modelLoss(p, X_ic, u_ic, dudt_ic, X_bc, u_bc, X_f, alpha)
    % 初始条件损失
    x_ic = X_ic(1,:); t_ic = X_ic(2,:);
    u_pred_ic = predictPINN(X_ic, p);
    dudt_ic_pred = dlgradient(sum(u_pred_ic), t_ic);
    loss_ic = mse(u_pred_ic, u_ic) + mse(dudt_ic_pred, dudt_ic);

    % 边界条件损失
    u_pred_bc = predictPINN(X_bc, p);
    loss_bc = mse(u_pred_bc, u_bc);

    % PDE残差
    x_f = X_f(1,:); t_f = X_f(2,:);
    u_f = predictPINN(X_f, p);
    dudt = dlgradient(sum(u_f), t_f, 'EnableHigherDerivatives', true);
    d2udt2 = dlgradient(sum(dudt), t_f);
    dudx = dlgradient(sum(u_f), x_f, 'EnableHigherDerivatives', true);
    d2udx2 = dlgradient(sum(dudx), x_f);
    f = d2udt2 - alpha*d2udx2;
    rhs = 6*x_f.*t_f.*(x_f.^2 - t_f.^2) - 25*pi^2*x_f.*cos(5*pi*t_f);
    loss_pde = mse(f - rhs, 0);
    loss = loss_ic + loss_bc + loss_pde;
    gradients = dlgradient(loss, p);
end

function y = mse(a, b)
    y = mean((a - b).^2, 'all');
end