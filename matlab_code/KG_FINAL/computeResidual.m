function res = computeResidual(net, X)
    x = X(1,:);
    t = X(2,:);
    N = size(X, 2);

    res = zeros(1, N, 'like', X);

    for i = 1:N
        Xi = dlarray(X(:,i), 'CB');

        u = forward(net, Xi);

        % 先对 t 求一阶导
        du_dt = dlgradient(u, Xi(2), 'EnableHigherDerivatives', true);

        % 再对 t 求二阶导
        d2u_dt2 = dlgradient(du_dt, Xi(2));

        % 对 x 求一阶导
        du_dx = dlgradient(u, Xi(1), 'EnableHigherDerivatives', true);

        % 对 x 求二阶导
        d2u_dx2 = dlgradient(du_dx, Xi(1));

        % 计算残差
        res(i) = d2u_dt2 - d2u_dx2 - 6*x(i)*t(i)*(x(i)^2 - t(i)^2) + 25*pi^2*x(i)*cos(5*pi*t(i));
    end
end
