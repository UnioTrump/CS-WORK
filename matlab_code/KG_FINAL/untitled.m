%% Klein-Gordon方程PINN求解器 - MATLAB实现
% 实验目的：求解一维Klein-Gordon方程 K-G方程形式如下：
% ∂²u/∂t² - α∂²u/∂x² = 6πτ(x²-τ²) - 25π²xcos(5πτ)
% 初始条件：u(x,0) = 0, ∂u/∂t(x,0) = 0, x ∈ [0,1]
% 边界条件：u(0,t) = u(1,t) = 0, t ∈ [0,1]

clear; clc; close all;

%% 参数设置
alpha = 1.0;  % 控制方程中，系数α=1
layers = [2, 30, 30, 30, 1];  % 神经网络结构：减少网络复杂度

% 训练参数
N_pde = 500;       % PDE内部点数量 (进一步减少)
N_ic = 50;         % 初始条件点数量
N_bc = 50;         % 边界条件点数量
max_iter = 3000;   % 最大迭代次数

%% 初始化神经网络
fprintf('初始化神经网络...\n');
[weights, biases] = initializeNN(layers);
params = packParams(weights, biases, layers);

%% 生成训练数据点
fprintf('生成训练数据点...\n');

% PDE内部点（随机采样）
x_pde = rand(N_pde, 1);
t_pde = rand(N_pde, 1);

% 初始条件点 (t=0)
x_ic = linspace(0, 1, N_ic)';
t_ic = zeros(N_ic, 1);

% 边界条件点
t_bc = rand(N_bc, 1);
x_bc_left = zeros(N_bc, 1);  % x=0
x_bc_right = ones(N_bc, 1);  % x=1

%% 训练神经网络
fprintf('开始训练神经网络...\n');
options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', ...
                      'MaxIterations', max_iter, ...
                      'Display', 'iter', ...
                      'SpecifyObjectiveGradient', false, ...
                      'StepTolerance', 1e-8, ...
                      'OptimalityTolerance', 1e-8);

% 定义损失函数
lossFun = @(p) computeLoss(p, layers, alpha, ...
                          x_pde, t_pde, x_ic, t_ic, ...
                          x_bc_left, x_bc_right, t_bc);

% 开始优化
tic;
[params_opt, fval, exitflag, output] = fminunc(lossFun, params, options);
training_time = toc;

fprintf('训练完成！用时: %.2f 秒\n', training_time);
fprintf('最终损失: %.6e\n', fval);

%% 测试和可视化
fprintf('生成预测结果...\n');
[weights_opt, biases_opt] = unpackParams(params_opt, layers);

% 生成测试网格
x_test = linspace(0, 1, 101)';
t_test = linspace(0, 1, 101)';
[X_test, T_test] = meshgrid(x_test, t_test);

% 预测
U_pred = zeros(size(X_test));
for i = 1:length(t_test)
    for j = 1:length(x_test)
        input = [X_test(i,j), T_test(i,j)];
        U_pred(i,j) = neuralNet(input, weights_opt, biases_opt);
    end
end

%% 绘制结果
figure('Position', [100, 100, 1200, 800]);

% 3D表面图
subplot(2,3,1);
surf(X_test, T_test, U_pred);
xlabel('x'); ylabel('t'); zlabel('u(x,t)');
title('PINN预测解 u(x,t)');
colorbar; shading interp;

% 等高线图
subplot(2,3,2);
contourf(X_test, T_test, U_pred, 20);
xlabel('x'); ylabel('t');
title('等高线图');
colorbar;

% 不同时刻的解
subplot(2,3,3);
t_snapshots = [0.2, 0.4, 0.6, 0.8];
colors = {'r-', 'g-', 'b-', 'k-'};
hold on;
for i = 1:length(t_snapshots)
    t_snap = t_snapshots(i);
    u_snap = zeros(size(x_test));
    for j = 1:length(x_test)
        input = [x_test(j), t_snap];
        u_snap(j) = neuralNet(input, weights_opt, biases_opt);
    end
    plot(x_test, u_snap, colors{i}, 'LineWidth', 2);
end
xlabel('x'); ylabel('u(x,t)');
title('不同时刻的解');
legend('t=0.2', 't=0.4', 't=0.6', 't=0.8');
grid on;

% PDE残差分布
subplot(2,3,4);
x_residual = linspace(0, 1, 50)';
t_residual = linspace(0, 1, 50)';
[X_res, T_res] = meshgrid(x_residual, t_residual);
residual = zeros(size(X_res));

for i = 1:size(X_res, 1)
    for j = 1:size(X_res, 2)
        residual(i,j) = computePDEResidual(X_res(i,j), T_res(i,j), ...
                                          weights_opt, biases_opt, alpha);
    end
end

contourf(X_res, T_res, abs(residual), 20);
xlabel('x'); ylabel('t');
title('PDE残差分布 |f|');
colorbar;

% 损失函数收敛历史
subplot(2,3,5);
if exitflag > 0
    plot(1:output.iterations, ones(output.iterations,1)*fval, 'b-', 'LineWidth', 2);
    xlabel('迭代次数'); ylabel('损失值');
    title(sprintf('训练损失 (最终值: %.2e)', fval));
    grid on; set(gca, 'YScale', 'log');
else
    text(0.5, 0.5, '训练未收敛', 'HorizontalAlignment', 'center');
    title('训练状态');
end

% 初始和边界条件检查
subplot(2,3,6);
% 检查初始条件
x_check = linspace(0, 1, 50)';
u_ic_pred = zeros(size(x_check));
ut_ic_pred = zeros(size(x_check));

for i = 1:length(x_check)
    input = [x_check(i), 0];
    u_ic_pred(i) = neuralNet(input, weights_opt, biases_opt);
    
    % 计算∂u/∂t在t=0处的值
    h = 1e-6;
    input_plus = [x_check(i), h];
    u_plus = neuralNet(input_plus, weights_opt, biases_opt);
    ut_ic_pred(i) = (u_plus - u_ic_pred(i)) / h;
end

plot(x_check, u_ic_pred, 'r-', 'LineWidth', 2); hold on;
plot(x_check, ut_ic_pred, 'b--', 'LineWidth', 2);
xlabel('x'); ylabel('值');
title('初始条件检查');
legend('u(x,0)', '∂u/∂t(x,0)');
grid on;

sgtitle('Klein-Gordon方程PINN求解结果', 'FontSize', 16);

%% 函数定义

function [weights, biases] = initializeNN(layers)
    % 初始化神经网络权重和偏置 - 改进的初始化方法
    weights = cell(length(layers)-1, 1);
    biases = cell(length(layers)-1, 1);
    
    for i = 1:length(layers)-1
        % 使用更小的初始化范围
        weights{i} = (rand(layers(i), layers(i+1)) - 0.5) * 0.1;
        biases{i} = zeros(1, layers(i+1));
    end
end

function params = packParams(weights, biases, layers)
    % 将权重和偏置打包成向量
    params = [];
    for i = 1:length(layers)-1
        params = [params; weights{i}(:); biases{i}(:)];
    end
end

function [weights, biases] = unpackParams(params, layers)
    % 从向量中解包权重和偏置
    weights = cell(length(layers)-1, 1);
    biases = cell(length(layers)-1, 1);
    
    idx = 1;
    for i = 1:length(layers)-1
        % 权重
        w_size = layers(i) * layers(i+1);
        weights{i} = reshape(params(idx:idx+w_size-1), layers(i), layers(i+1));
        idx = idx + w_size;
        
        % 偏置
        b_size = layers(i+1);
        biases{i} = reshape(params(idx:idx+b_size-1), 1, layers(i+1));
        idx = idx + b_size;
    end
end

function y = neuralNet(x, weights, biases)
    % 神经网络前向传播 - 改进激活函数
    h = x(:)';  % 确保是行向量
    
    for i = 1:length(weights)-1
        h = h * weights{i} + biases{i};
        % 使用sigmoid激活函数，更稳定
        h = 1./(1 + exp(-h));
    end
    
    % 输出层（线性激活）
    y = h * weights{end} + biases{end};
end

function f = computePDEResidual(x, t, weights, biases, alpha)
    % 计算PDE残差 - 改进数值导数计算
    h = 1e-5;  % 调整步长
    
    % 计算u及其偏导数
    u = neuralNet([x, t], weights, biases);
    
    % ∂u/∂x - 使用中心差分
    u_x_plus = neuralNet([x+h, t], weights, biases);
    u_x_minus = neuralNet([x-h, t], weights, biases);
    
    % ∂²u/∂x²
    u_xx = (u_x_plus - 2*u + u_x_minus) / (h^2);
    
    % ∂u/∂t
    u_t_plus = neuralNet([x, t+h], weights, biases);
    u_t_minus = neuralNet([x, t-h], weights, biases);
    
    % ∂²u/∂t²
    u_tt = (u_t_plus - 2*u + u_t_minus) / (h^2);
    
    % 源项：6πτ(x²-τ²) - 25π²xcos(5πτ)，其中τ=t
    source_term = 6*pi*t*(x^2 - t^2) - 25*pi^2*x*cos(5*pi*t);
    
    % Klein-Gordon方程残差
    f = u_tt - alpha*u_xx - source_term;
end

function loss = computeLoss(params, layers, alpha, x_pde, t_pde, ...
                           x_ic, t_ic, x_bc_left, x_bc_right, t_bc)
    % 计算总损失函数
    persistent iter_count;
    if isempty(iter_count)
        iter_count = 0;
    end
    iter_count = iter_count + 1;
    
    [weights, biases] = unpackParams(params, layers);
    
    % PDE损失
    loss_pde = 0;
    for i = 1:length(x_pde)
        f = computePDEResidual(x_pde(i), t_pde(i), weights, biases, alpha);
        loss_pde = loss_pde + f^2;
    end
    loss_pde = loss_pde / length(x_pde);
    
    % 初始条件损失
    loss_ic = 0;
    for i = 1:length(x_ic)
        % u(x,0) = 0
        u_ic = neuralNet([x_ic(i), t_ic(i)], weights, biases);
        loss_ic = loss_ic + u_ic^2;
        
        % ∂u/∂t(x,0) = 0
        h = 1e-6;
        u_t_ic = (neuralNet([x_ic(i), h], weights, biases) - u_ic) / h;
        loss_ic = loss_ic + u_t_ic^2;
    end
    loss_ic = loss_ic / length(x_ic);
    
    % 边界条件损失
    loss_bc = 0;
    for i = 1:length(t_bc)
        % u(0,t) = 0
        u_left = neuralNet([x_bc_left(i), t_bc(i)], weights, biases);
        loss_bc = loss_bc + u_left^2;
        
        % u(1,t) = 0
        u_right = neuralNet([x_bc_right(i), t_bc(i)], weights, biases);
        loss_bc = loss_bc + u_right^2;
    end
    loss_bc = loss_bc / length(t_bc);
    
    % 总损失（改进权重平衡）
    w_pde = 1.0;     % PDE损失权重
    w_ic = 100.0;    % 初始条件损失权重 (增加权重)
    w_bc = 100.0;    % 边界条件损失权重 (增加权重)
    
    loss = w_pde * loss_pde + w_ic * loss_ic + w_bc * loss_bc;
    
    % 显示训练进度
    if mod(iter_count, 100) == 0 || iter_count == 1
        fprintf('Iter: %d, Loss: %.6e (PDE: %.6e, IC: %.6e, BC: %.6e)\n', ...
                iter_count, loss, loss_pde, loss_ic, loss_bc);
    end
end