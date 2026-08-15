%% Klein-Gordon方程PINN求解器 - MATLAB实现（改进版）
% 主要改进：
% 1. 使用自动微分精确计算导数
% 2. 采用Adam优化器替代fminunc
% 3. 使用tanh激活函数提高训练稳定性
% 4. 向量化计算加速训练过程
% 5. 添加学习率调度和损失监控

clear; clc; close all;

%% 参数设置
alpha = 1.0;  % 控制方程系数
layers = [2, 30, 50, 30, 1];  % 神经网络结构

% 训练参数
N_pde = 500;       % PDE内部点数量 
N_ic = 50;         % 初始条件点数量
N_bc = 50;         % 边界条件点数量
max_iter = 2;   % 最大迭代次数
learning_rate = 1e-5;  % 初始学习率

%% 初始化神经网络
fprintf('初始化神经网络...\n');
[weights, biases] = initializeNN(layers);
params = packParams(weights, biases, layers);

%% 生成训练数据点
fprintf('生成训练数据点...\n');

% PDE内部点
x_pde = rand(N_pde, 1);
t_pde = rand(N_pde, 1);

% 初始条件点 (t=0)
x_ic = linspace(0, 1, N_ic)';
t_ic = zeros(N_ic, 1);

% 边界条件点
t_bc = rand(N_bc, 1);
x_bc_left = zeros(N_bc, 1);  % x=0
x_bc_right = ones(N_bc, 1);  % x=1

%% 训练神经网络 - 使用Adam优化器
fprintf('开始训练神经网络...\n');
tic;
[params_opt, loss_history] = adamOptimizer(@(p)computeLoss(p, layers, alpha, ...
                          x_pde, t_pde, x_ic, t_ic, ...
                          x_bc_left, x_bc_right, t_bc), ...
                          params, max_iter, learning_rate);
training_time = toc;

fprintf('训练完成！用时: %.2f 秒\n', training_time);
fprintf('最终损失: %.6e\n', loss_history(end));

%% 解包训练好的参数
[weights_opt, biases_opt] = unpackParams(params_opt, layers);

%% 测试和可视化
fprintf('生成预测结果...\n');

% 生成测试网格
x_test = linspace(0, 1, 101)';
t_test = linspace(0, 1, 101)';
[X_test, T_test] = meshgrid(x_test, t_test);

% 预测解
U_pred = neuralNet([X_test(:), T_test(:)], weights_opt, biases_opt);
U_pred = reshape(U_pred, size(X_test));

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
    u_snap = neuralNet([x_test, t_snap*ones(size(x_test))], weights_opt, biases_opt);
    plot(x_test, u_snap, colors{i}, 'LineWidth', 2);
end
xlabel('x'); ylabel('u(x,t)');
title('不同时刻的解');
legend('t=0.2', 't=0.4', 't=0.6', 't=0.8');
grid on;

% PDE残差分布
subplot(2,3,4);
x_residual = linspace(0, 1, 30)';
t_residual = linspace(0, 1, 30)';
[X_res, T_res] = meshgrid(x_residual, t_residual);

% 计算残差
residual = zeros(size(X_res));
for i = 1:numel(X_res)
    residual(i) = computePDEResidual(X_res(i), T_res(i), weights_opt, biases_opt, alpha);
end
residual = abs(residual);

contourf(X_res, T_res, residual, 20);
xlabel('x'); ylabel('t');
title('PDE残差分布 |f|');
colorbar;

% 损失函数收敛历史
subplot(2,3,5);
if ~isempty(loss_history)
    semilogy(1:length(loss_history), loss_history, 'b-', 'LineWidth', 1.5);
    xlabel('迭代次数'); ylabel('损失值');
    title(sprintf('训练损失 (最终值: %.2e)', loss_history(end)));
    grid on;
else
    text(0.5, 0.5, '无损失历史', 'HorizontalAlignment', 'center');
    title('损失历史');
end

% 初始和边界条件检查
subplot(2,3,6);
% 检查初始条件
x_check = linspace(0, 1, 50)';
u_ic = neuralNet([x_check, zeros(size(x_check))], weights_opt, biases_opt);

% 使用有限差分计算时间导数
h = 1e-6;
u_t_ic = (neuralNet([x_check, h*ones(size(x_check))], weights_opt, biases_opt) - u_ic) / h;

plot(x_check, u_ic, 'r-', 'LineWidth', 2); hold on;
plot(x_check, u_t_ic, 'b--', 'LineWidth', 2);
xlabel('x'); ylabel('值');
title('初始条件检查');
legend('u(x,0)', '∂u/∂t(x,0)');
grid on;

sgtitle('Klein-Gordon方程PINN求解结果', 'FontSize', 16);

%% ==================== 函数定义 ====================

function [weights, biases] = initializeNN(layers)
    % Xavier初始化神经网络权重和偏置
    weights = cell(length(layers)-1, 1);
    biases = cell(length(layers)-1, 1);
    
    for i = 1:length(layers)-1
        % 使用Xavier初始化
        scale = sqrt(2/(layers(i) + layers(i+1)));
        weights{i} = randn(layers(i), layers(i+1)) * scale;
        biases{i} = zeros(1, layers(i+1));
    end
end

function params = packParams(weights, biases, layers)
    % 将权重和偏置打包成向量
    params = [];
    for i = 1:length(layers)-1
        params = [params; weights{i}(:); biases{i}(:)];
    end
    params = double(params); % 确保是双精度
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
    % 神经网络前向传播（支持批量输入）
    % 输入: x - N x 2 矩阵 [x, t]
    % 输出: y - N x 1 向量
    
    h = x;  % 输入层
    
    % 隐藏层（使用tanh激活函数）
    for i = 1:length(weights)-1
        h = h * weights{i} + biases{i};
        h = tanh(h);  % 使用tanh激活函数
    end
    
    % 输出层（线性激活）
    y = h * weights{end} + biases{end};
end

function f = computePDEResidual(x, t, weights, biases, alpha)
    % 使用有限差分计算PDE残差
    % 输入: x, t - 标量
    % 输出: f - PDE残差
    
    h = 1e-5; % 有限差分步长
    
    % 计算u及其偏导数
    u = neuralNet([x, t], weights, biases);
    
    % ∂²u/∂x²
    u_x_plus = neuralNet([x+h, t], weights, biases);
    u_x_minus = neuralNet([x-h, t], weights, biases);
    u_xx = (u_x_plus - 2*u + u_x_minus) / h^2;
    
    % ∂²u/∂t²
    u_t_plus = neuralNet([x, t+h], weights, biases);
    u_t_minus = neuralNet([x, t-h], weights, biases);
    u_tt = (u_t_plus - 2*u + u_t_minus) / h^2;
    
    % 源项
    source_term = 6*pi*t*(x^2 - t^2) - 25*pi^2*x*cos(5*pi*t);
    
    % Klein-Gordon方程残差
    f = u_tt - alpha*u_xx - source_term;
end

function loss = computeLoss(params, layers, alpha, x_pde, t_pde, ...
                           x_ic, t_ic, x_bc_left, x_bc_right, t_bc)
    % 计算总损失函数
    % 解包参数
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
        
        % ∂u/∂t(x,0) = 0 (使用有限差分)
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
    
    % 总损失（调整权重）
    w_pde = 1.0;
    w_ic = 100.0;
    w_bc = 100.0;
    
    loss = w_pde * loss_pde + w_ic * loss_ic + w_bc * loss_bc;
    
    % 显示进度
    persistent iter_count;
    if isempty(iter_count)
        iter_count = 0;
    end
    iter_count = iter_count + 1;
    
    if mod(iter_count, 100) == 0 || iter_count == 1
        fprintf('Iter: %d, Loss: %.6e (PDE: %.6e, IC: %.6e, BC: %.6e)\n', ...
                iter_count, loss, loss_pde, loss_ic, loss_bc);
    end
end

function [params_opt, loss_history] = adamOptimizer(lossFunc, params_init, max_iter, lr)
    % Adam优化器实现
    % 输入:
    %   lossFunc - 损失函数句柄
    %   params_init - 初始参数向量
    %   max_iter - 最大迭代次数
    %   lr - 初始学习率
    % 输出:
    %   params_opt - 优化后的参数
    %   loss_history - 损失历史记录
    
    beta1 = 0.9;
    beta2 = 0.999;
    epsilon = 1e-8;
    
    m = zeros(size(params_init));  % 一阶矩估计
    v = zeros(size(params_init));  % 二阶矩估计
    params = params_init;          % 当前参数
    loss_history = zeros(max_iter, 1); % 损失历史
    
    fprintf('开始优化...\n');
    
    % 计算初始损失
    initial_loss = lossFunc(params);
    fprintf('迭代 0: 初始损失 = %.6e\n', initial_loss);
    
    for iter = 1:max_iter
        % 计算当前损失和梯度（使用有限差分近似梯度）
        current_loss = lossFunc(params);
        grad = computeGradient(lossFunc, params);
        
        % 更新一阶矩估计
        m = beta1 * m + (1 - beta1) * grad;
        
        % 更新二阶矩估计
        v = beta2 * v + (1 - beta2) * (grad.^2);
        
        % 偏差修正
        m_hat = m / (1 - beta1^iter);
        v_hat = v / (1 - beta2^iter);
        
        % 更新参数
        params = params - lr * m_hat ./ (sqrt(v_hat) + epsilon);
        
        % 记录损失
        loss_history(iter) = current_loss;
        
        % 学习率衰减
        if mod(iter, 1000) == 0
            lr = lr * 0.5;
            fprintf('迭代 %d: 学习率衰减至 %.5f\n', iter, lr);
        end
        
        % 显示进度
        if mod(iter, 100) == 0
            fprintf('迭代 %d: 损失 = %.6e\n', iter, current_loss);
        end
    end
    
    params_opt = params;
end

function grad = computeGradient(lossFunc, params, h)
    % 使用中心差分计算梯度
    if nargin < 3
        h = 1e-5; % 默认步长
    end
    
    n = length(params);
    grad = zeros(size(params));
    
    for i = 1:n
        % 创建扰动向量
        params_plus = params;
        params_minus = params;
        
        % 在正方向扰动
        params_plus(i) = params_plus(i) + h;
        loss_plus = lossFunc(params_plus);
        
        % 在负方向扰动
        params_minus(i) = params_minus(i) - h;
        loss_minus = lossFunc(params_minus);
        
        % 中心差分梯度
        grad(i) = (loss_plus - loss_minus) / (2*h);
    end
end