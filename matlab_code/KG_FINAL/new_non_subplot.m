%% Klein-Gordon方程PINN求解器 - MATLAB实现（优化版）
% 主要改进：
% 1. 修复训练参数设置
% 2. 优化梯度计算效率
% 3. 改进学习率调度策略
% 4. 分离图像显示
% 5. 增强数值稳定性

clear; clc; close all;

%% 参数设置
alpha = 1.0;  % 控制方程系数
layers = [2, 30, 50, 30, 1];  % 神经网络结构

% 训练参数
N_pde = 500;       % PDE内部点数量
N_ic = 50;         % 初始条件点数量
N_bc = 50;         % 边界条件点数量
max_iter = 5;   % 增加迭代次数
learning_rate = 1e-3;  % 提高初始学习率

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

%% 分别绘制结果图
fprintf('生成结果图像...\n');

% 图1: 3D表面图
figure('Position', [100, 100, 800, 600]);
surf(X_test, T_test, U_pred);
xlabel('x', 'FontSize', 12); 
ylabel('t', 'FontSize', 12); 
zlabel('u(x,t)', 'FontSize', 12);
title('PINN预测解 u(x,t)', 'FontSize', 14);
colorbar; 
shading interp;
view(45, 30);
grid on;

% 图2: 等高线图
figure('Position', [200, 100, 800, 600]);
contourf(X_test, T_test, U_pred, 20);
xlabel('x', 'FontSize', 12); 
ylabel('t', 'FontSize', 12);
title('等高线图', 'FontSize', 14);
colorbar;
axis equal;
grid on;

% 图3: 不同时刻的解
figure('Position', [300, 100, 800, 600]);
t_snapshots = [0.2, 0.4, 0.6, 0.8];
colors = {'r-', 'g-', 'b-', 'k-'};
hold on;
for i = 1:length(t_snapshots)
    t_snap = t_snapshots(i);
    u_snap = neuralNet([x_test, t_snap*ones(size(x_test))], weights_opt, biases_opt);
    plot(x_test, u_snap, colors{i}, 'LineWidth', 2);
end
xlabel('x', 'FontSize', 12); 
ylabel('u(x,t)', 'FontSize', 12);
title('不同时刻的解', 'FontSize', 14);
legend('t=0.2', 't=0.4', 't=0.6', 't=0.8', 'Location', 'best');
grid on;
set(gca, 'FontSize', 10);

% 图4: PDE残差分布
figure('Position', [400, 100, 800, 600]);
x_residual = linspace(0, 1, 30)';
t_residual = linspace(0, 1, 30)';
[X_res, T_res] = meshgrid(x_residual, t_residual);

% 向量化计算残差
residual = zeros(size(X_res));
for i = 1:numel(X_res)
    residual(i) = computePDEResidual(X_res(i), T_res(i), weights_opt, biases_opt, alpha);
end
residual = abs(residual);

contourf(X_res, T_res, residual, 20);
xlabel('x', 'FontSize', 12); 
ylabel('t', 'FontSize', 12);
title('PDE残差分布 |f|', 'FontSize', 14);
colorbar;
grid on;

% 图5: 损失函数收敛历史
figure('Position', [500, 100, 800, 600]);
if ~isempty(loss_history) && length(loss_history) > 1
    semilogy(1:length(loss_history), loss_history, 'b-', 'LineWidth', 1.5);
    xlabel('迭代次数', 'FontSize', 12); 
    ylabel('损失值', 'FontSize', 12);
    title(sprintf('训练损失收敛历史 (最终值: %.2e)', loss_history(end)), 'FontSize', 14);
    grid on;
    set(gca, 'FontSize', 10);
else
    text(0.5, 0.5, '训练损失数据不足', 'HorizontalAlignment', 'center', 'FontSize', 12);
    title('损失历史', 'FontSize', 14);
end

% 图6: 初始和边界条件检查
figure('Position', [600, 100, 800, 600]);
% 检查初始条件
x_check = linspace(0, 1, 50)';
u_ic = neuralNet([x_check, zeros(size(x_check))], weights_opt, biases_opt);

% 使用有限差分计算时间导数
h = 1e-6;
u_t_ic = (neuralNet([x_check, h*ones(size(x_check))], weights_opt, biases_opt) - u_ic) / h;

plot(x_check, u_ic, 'r-', 'LineWidth', 2); hold on;
plot(x_check, u_t_ic, 'b--', 'LineWidth', 2);
xlabel('x', 'FontSize', 12); 
ylabel('值', 'FontSize', 12);
title('初始条件检查', 'FontSize', 14);
legend('u(x,0)', '∂u/∂t(x,0)', 'Location', 'best');
grid on;
set(gca, 'FontSize', 10);

fprintf('所有结果图已生成完成！\n');

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
    
    % PDE损失 - 向量化计算
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
    
    % 添加正则化项防止过拟合
    l2_reg = 0;
    for i = 1:length(weights)
        l2_reg = l2_reg + sum(weights{i}(:).^2);
    end
    loss = loss + 1e-6 * l2_reg;
    
    % 显示进度
    persistent iter_count;
    if isempty(iter_count)
        iter_count = 0;
    end
    iter_count = iter_count + 1;
    
    if mod(iter_count, 500) == 0 || iter_count == 1
        fprintf('Iter: %d, Loss: %.6e (PDE: %.6e, IC: %.6e, BC: %.6e)\n', ...
                iter_count, loss, loss_pde, loss_ic, loss_bc);
    end
end

function [params_opt, loss_history] = adamOptimizer(lossFunc, params_init, max_iter, lr)
    % Adam优化器实现 - 优化版
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
        % 计算当前损失和梯度
        current_loss = lossFunc(params);
        grad = computeGradientOptimized(lossFunc, params);
        
        % 检查梯度是否有效
        if any(~isfinite(grad))
            fprintf('警告: 梯度包含NaN或Inf值，跳过此次更新\n');
            continue;
        end
        
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
        
        % 自适应学习率调度
        if iter > 100 && mod(iter, 1000) == 0
            % 检查收敛情况
            recent_losses = loss_history(max(1, iter-100):iter);
            if std(recent_losses) / mean(recent_losses) < 0.01
                lr = lr * 0.8;
                fprintf('迭代 %d: 学习率调整至 %.5f\n', iter, lr);
            end
        end
        
        % 显示进度
        if mod(iter, 500) == 0
            fprintf('迭代 %d: 损失 = %.6e, 学习率 = %.5f\n', iter, current_loss, lr);
        end
        
        % 早停检查
        if iter > 500 && current_loss < 1e-6
            fprintf('达到收敛条件，提前停止训练\n');
            loss_history = loss_history(1:iter);
            break;
        end
    end
    
    params_opt = params;
end

function grad = computeGradientOptimized(lossFunc, params)
    % 优化的梯度计算，使用自适应步长
    h_base = 1e-5;
    n = length(params);
    grad = zeros(size(params));
    
    % 并行计算梯度（如果支持）
    parfor i = 1:n
        % 自适应步长
        param_scale = abs(params(i));
        h = h_base * max(1, param_scale);
        
        % 创建扰动向量
        params_plus = params;
        params_minus = params;
        
        % 扰动
        params_plus(i) = params_plus(i) + h;
        params_minus(i) = params_minus(i) - h;
        
        % 计算损失
        try
            loss_plus = lossFunc(params_plus);
            loss_minus = lossFunc(params_minus);
            
            % 中心差分梯度
            grad(i) = (loss_plus - loss_minus) / (2*h);
        catch
            % 如果计算失败，使用前向差分
            loss_current = lossFunc(params);
            loss_plus = lossFunc(params_plus);
            grad(i) = (loss_plus - loss_current) / h;
        end
    end
    
    % 梯度裁剪防止梯度爆炸
    grad_norm = norm(grad);
    if grad_norm > 10
        grad = grad * (10 / grad_norm);
    end
end