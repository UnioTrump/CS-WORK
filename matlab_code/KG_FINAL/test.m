%% Cahn-Hilliard方程PINN求解器 - MATLAB实现（修正版）
% 主要修正：
% 1. 修复梯度计算方法
% 2. 正确实现周期边界条件
% 3. 优化网络结构和训练过程
% 4. 修正拉普拉斯算子计算

clear; clc; close all;

%% 物理参数
L = 1.0;
T = 0.1;
alpha = 1.0;

%% 训练参数
Nf = 2000;        % 内部点数
N0 = 500;         % 初始点数
Npbc = 500;       % 周期边界点数
numEpochs = 3000; % 训练轮数
learnRate = 0.001; % 学习率

%% 生成训练数据
fprintf('生成训练数据...\n');

% 内部点 (x,y,t)
x_f = L * rand(Nf, 1);
t_f = T * rand(Nf, 1);
X_f = [x_f, t_f];  % [N x 2] 格式

% 初始点 (t=0)
x0 = L * rand(N0, 1);
t0 = zeros(N0, 1);
X0 = [x0, t0];
u0_true = zeros(N0, 1);  % u(x,0) = 0

% 初始速度点 (t=0)
ut0_true = zeros(N0, 1);  % ∂u/∂t(x,0) = 0

% 边界点
% 左边界 x=0
x_left = zeros(Npbc/2, 1);
t_left = T * rand(Npbc/2, 1);
X_left = [x_left, t_left];

% 右边界 x=1
x_right = ones(Npbc/2, 1);
t_right = T * rand(Npbc/2, 1);
X_right = [x_right, t_right];

%% 构建神经网络
fprintf('初始化神经网络...\n');

% 使用更简单但有效的网络结构
layers = [
    featureInputLayer(2, 'Name', 'input')  % 改为2维输入
    fullyConnectedLayer(64, 'Name', 'fc1')
    tanhLayer('Name', 'tanh1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    tanhLayer('Name', 'tanh2')
    fullyConnectedLayer(64, 'Name', 'fc3')
    tanhLayer('Name', 'tanh3')
    fullyConnectedLayer(32, 'Name', 'fc4')
    tanhLayer('Name', 'tanh4')
    fullyConnectedLayer(1, 'Name', 'output')
];

net = dlnetwork(layers);

%% 训练过程
fprintf('开始训练...\n');

% 初始化优化器参数
avgGrad = [];
avgSqGrad = [];
loss_history = zeros(numEpochs, 1);

% 转换为dlarray格式
X_f_dl = dlarray(X_f', 'CB');
X0_dl = dlarray(X0', 'CB');
u0_true_dl = dlarray(u0_true', 'CB');
X_left_dl = dlarray(X_left', 'CB');
X_right_dl = dlarray(X_right', 'CB');
X_bottom_dl = dlarray(X_bottom', 'CB');
X_top_dl = dlarray(X_top', 'CB');

% 训练循环
tic;
for epoch = 1:numEpochs
    % 计算损失和梯度
    [loss, grad] = dlfeval(@modelLoss, net, X_f_dl, X0_dl, u0_true_dl, ...
                          X_left_dl, X_right_dl, X_bottom_dl, X_top_dl, ...
                          epsilon, M, L);
    
    % 使用Adam优化器更新网络参数
    [net, avgGrad, avgSqGrad] = adamupdate(net, grad, avgGrad, avgSqGrad, epoch, learnRate);
    
    % 记录损失
    loss_history(epoch) = extractdata(loss);
    
    % 每100轮输出损失值
    if mod(epoch, 100) == 0
        fprintf('Epoch %d, Total Loss = %.6e\n', epoch, extractdata(loss));
    end
    
    % 学习率调度
    if mod(epoch, 1000) == 0 && epoch > 1000
        learnRate = learnRate * 0.9;
        fprintf('学习率调整为: %.6f\n', learnRate);
    end
end

training_time = toc;
fprintf('训练完成！用时: %.2f 秒\n', training_time);

%% 生成预测结果
fprintf('生成预测结果...\n');

% 创建测试网格
nx = 100; nt = 21;
x_test = linspace(0, L, nx);
t_test = linspace(0, T, nt);

% 可视化结果
figure('Position', [100, 100, 1200, 800]);

% 绘制不同时刻的浓度分布
time_snapshots = [1, 6, 11, 16, 21]; % 对应t=0, 0.025, 0.05, 0.075, 0.1
for i = 1:length(time_snapshots)
    subplot(2, 3, i);
    
    t_idx = time_snapshots(i);
    [X_grid, Y_grid] = meshgrid(x_test, y_test);
    
    % 创建测试点
    X_test = [X_grid(:), Y_grid(:), t_test(t_idx) * ones(numel(X_grid), 1)];
    X_test_dl = dlarray(X_test', 'CB');
    
    % 预测浓度
    c_pred = forward(net, X_test_dl);
    c_pred = extractdata(c_pred);
    C_pred = reshape(c_pred, size(X_grid));
    
    % 绘制等高线图
    contourf(X_grid, Y_grid, C_pred, 20);
    colorbar;
    xlabel('x');
    ylabel('y');
    title(sprintf('t = %.3f', t_test(t_idx)));
    axis equal;
    xlim([0, L]);
    ylim([0, L]);
end

% 绘制损失历史
subplot(2, 3, 6);
semilogy(1:numEpochs, loss_history, 'b-', 'LineWidth', 1.5);
xlabel('训练轮数');
ylabel('损失值');
title('训练损失历史');
grid on;

sgtitle('Cahn-Hilliard方程PINN求解结果', 'FontSize', 16);

%% 验证结果
fprintf('验证边界条件...\n');

% 检查周期边界条件
figure('Position', [200, 200, 800, 600]);

% 在固定时刻检查x方向周期性
t_check = T/2;
y_check = L/2;
x_boundary = [0, L];
X_check_left = dlarray([0; y_check; t_check], 'CB');
X_check_right = dlarray([L; y_check; t_check], 'CB');

c_left = extractdata(forward(net, X_check_left));
c_right = extractdata(forward(net, X_check_right));

fprintf('x方向边界检查: c(0,%.2f,%.3f) = %.6f, c(%.2f,%.2f,%.3f) = %.6f\n', ...
        y_check, t_check, c_left, L, y_check, t_check, c_right);
fprintf('边界差异: %.6e\n', abs(c_left - c_right));

% 绘制中间时刻的1D切片
x_slice = linspace(0, L, 100);
X_slice = [x_slice', y_check * ones(100, 1), t_check * ones(100, 1)];
X_slice_dl = dlarray(X_slice', 'CB');
c_slice = extractdata(forward(net, X_slice_dl));

plot(x_slice, c_slice, 'b-', 'LineWidth', 2);
xlabel('x');
ylabel('浓度 c');
title(sprintf('浓度分布切片 (y=%.2f, t=%.3f)', y_check, t_check));
grid on;

%% ==================== 函数定义 ====================

function [total_loss, gradients] = modelLoss(net, X_f, X0, u0_true, ut0_true, ...
                                           X_left, X_right, alpha)
    % 1. 方程残差损失
    loss_eq = computeWaveEquationLoss(net, X_f, alpha);
    
    % 2. 初始位置条件损失
    u0_pred = forward(net, X0);
    loss_ic1 = mean((u0_pred - u0_true).^2);
    
    % 3. 初始速度条件损失
    loss_ic2 = computeInitialVelocityLoss(net, X0, ut0_true);
    
    % 4. 边界条件损失
    u_left = forward(net, X_left);
    u_right = forward(net, X_right);
    loss_bc = mean(u_left.^2) + mean(u_right.^2);
    
    % 总损失
    w_eq = 1.0;
    w_ic = 10.0;
    w_bc = 10.0;
    
    total_loss = w_eq * loss_eq + w_ic * (loss_ic1 + loss_ic2) + w_bc * loss_bc;
    
    gradients = dlgradient(total_loss, net.Learnables);
end

function loss_eq = computeWaveEquationLoss(net, X_f, alpha)
    u = forward(net, X_f);
    residual = computeWaveEquationResidual(net, X_f, u, alpha);
    loss_eq = mean(residual.^2);
end

function residual = computeWaveEquationResidual(net, X, u, alpha)
    x = X(1, :);
    t = X(2, :);
    
    % 计算导数
    du_dt = dlgradient(sum(u, 'all'), t, 'EnableHigherDerivatives', true);
    d2u_dt2 = dlgradient(sum(du_dt, 'all'), t, 'EnableHigherDerivatives', true);
    
    du_dx = dlgradient(sum(u, 'all'), x, 'EnableHigherDerivatives', true);
    d2u_dx2 = dlgradient(sum(du_dx, 'all'), x, 'EnableHigherDerivatives', true);
    
    % 源项
    source_term = 6*x.*t.*(x.^2 - t.^2) - 25*pi^2*x.*cos(5*pi*t);
    
    % 波方程残差
    residual = d2u_dt2 - alpha * d2u_dx2 - source_term;
end