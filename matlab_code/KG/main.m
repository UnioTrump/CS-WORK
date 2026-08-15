% main.m - 主函数
clear; clc; close all

addpath('utils');
alpha = 1;
N_ic = 50; N_bc = 50; N_f = 2000;
maxEpochs = 2000; learnRate = 1e-3;

[X_ic, u_ic, dudt_ic] = sampleInitial(N_ic);
[X_bc, u_bc] = sampleBoundary(N_bc);
[X_f] = sampleCollocation(N_f);

parameters = initializeParameters(3, 20);

for epoch = 1:maxEpochs
    [loss, gradients] = dlfeval(@modelLoss, parameters, X_ic, u_ic, dudt_ic, X_bc, u_bc, X_f, alpha);
    parameters = sgdUpdate(parameters, gradients, learnRate);
    if mod(epoch, 100) == 0
        fprintf('Epoch %d: Loss = %.4e\n', epoch, loss);
    end
end

% 推理可视化
[xg, tg] = meshgrid(linspace(0,1,100), linspace(0,1,100));
X_test = dlarray([xg(:), tg(:)]');
u_pred = predictPINN(X_test, parameters);
u_pred = reshape(extractdata(u_pred), 100, 100);

figure;
surf(xg, tg, u_pred);
xlabel('x'); ylabel('t'); zlabel('u_{pred}'); title('PINN Predicted Solution');

% 误差图（基于真实解）
u_true = exactSolution(xg, tg);
err = abs(u_pred - u_true);
figure;
imagesc(linspace(0,1,100), linspace(0,1,100), err);
colorbar; title('Absolute Error Heatmap'); xlabel('x'); ylabel('t');

rel_err = norm(u_pred - u_true, 'fro') / norm(u_true, 'fro');
fprintf('Relative L2 Error: %.4e\n', rel_err);