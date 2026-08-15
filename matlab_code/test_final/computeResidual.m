function res = computeResidual(net, X)
    x = X(1,:); t = X(2,:);
    u = forward(net, X);
    
    % 计算二阶导数
    du_t = dlgradient(sum(u,'all'), t, 'EnableHigherDerivatives', true);
    d2u_t = dlgradient(sum(du_t,'all'), t, 'EnableHigherDerivatives', true);
    d2u_x = dlgradient(sum(dlgradient(sum(u,'all'), x, 'EnableHigherDerivatives', true)), x);
    
    alpha = 1; % 根据实际方程设置系数
    res = d2u_t - alpha*d2u_x - 6*x.*t.*(x.^2 - t.^2) + 25*pi^2*x.*cos(5*pi*t);
end