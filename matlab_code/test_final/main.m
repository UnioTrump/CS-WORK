% main.m
% Cahn-Hilliard 方程 PINN 主程序
clear; clc; close all;

%% 参数设置
L = 1.0;        % 空间长度
T = 0.1;        % 时间长度
numEpochs = 3000;
learnRate = 5e-4;

% 初始采样数量
Nf = 2000; N0 = 500; Npbc = 500;

% 自适应采样参数
resampleEvery = 500;
resampleNum = 1000;

%% 生成初始训练数据
fprintf('生成初始训练数据...\n');
X_f = [L*rand(Nf,1), T*rand(Nf,1)]';
X0 = [L*rand(N0,1), zeros(N0,1)]';        % IC1: u(x,0)
X0_t = [L*rand(N0,1), zeros(N0,1)]';      % IC2: ∂u/∂t(x,0)
u0_true = zeros(1, N0);

X_left = [zeros(Npbc/2,1), T*rand(Npbc/2,1)]';
X_right = [L*ones(Npbc/2,1), T*rand(Npbc/2,1)]';

%% 构建网络
fprintf('构建物理增强残差网络...\n');
net = buildNetwork();

%% 训练准备
X_f_dl = dlarray(X_f, 'CB');
X0_dl = dlarray(X0, 'CB');
u0_true_dl = dlarray(u0_true, 'CB');
X0_t_dl = dlarray(X0_t, 'CB');
X_left_dl = dlarray(X_left, 'CB');
X_right_dl = dlarray(X_right, 'CB');

avgGrad = []; avgSqGrad = [];
loss_history = zeros(numEpochs,1);

%% 训练主循环
tic;
for epoch = 1:numEpochs
    [loss, grad] = dlfeval(@modelLoss, net, X_f_dl, X0_dl, u0_true_dl, X0_t_dl, X_left_dl, X_right_dl);
    [net, avgGrad, avgSqGrad] = adamupdate(net, grad, avgGrad, avgSqGrad, epoch, learnRate);
    loss_history(epoch) = extractdata(loss);

    if mod(epoch,100)==0
        fprintf("Epoch %d, Loss = %.3e\n", epoch, loss);
    end

    if mod(epoch,resampleEvery)==0
        X_f = generateAdaptivePoints(net, resampleNum, L, T);
        X_f_dl = dlarray(X_f, 'CB');
    end
end
toc;

%% ====================== 可视化部分 ======================
fprintf('开始可视化训练结果...\n');

%% 1. 损失曲线图
figure('Name', '训练损失', 'Position', [100, 100, 1000, 400]);

% 原始损失曲线
subplot(1,2,1);
semilogy(loss_history, 'LineWidth', 2);
title('训练损失曲线');
xlabel('迭代次数');
ylabel('损失值 (log scale)');
grid on;

% 平滑处理后的损失曲线
subplot(1,2,2);
window_size = 50;
smoothed_loss = movmean(loss_history, window_size);
semilogy(smoothed_loss, 'LineWidth', 2, 'Color', [0.85, 0.33, 0.10]);
title(sprintf('平滑处理后的损失曲线 (窗口大小=%d)', window_size));
xlabel('迭代次数');
ylabel('损失值 (log scale)');
grid on;

%% 2. 预测结果曲面图
fprintf('生成预测曲面图...\n');
nx = 100; nt = 50;
x_test = linspace(0, L, nx);
t_test = linspace(0, T, nt);
[X, T_mesh] = meshgrid(x_test, t_test);
X_test = [X(:)'; T_mesh(:)'];

% 网络预测
X_dl = dlarray(X_test, 'CB');
u_pred = extractdata(forward(net, X_dl));
u_pred = reshape(u_pred, nt, nx);

% 创建曲面图
figure('Name', '预测解', 'Position', [100, 100, 800, 600]);
surf(x_test, t_test, u_pred, 'EdgeColor', 'none');
title('PINN 预测解');
xlabel('空间 x'); ylabel('时间 t'); zlabel('u(x,t)');
colormap jet; colorbar;
view([45, 30]);
shading interp;
light; lighting gouraud;
material dull;

%% 3. 时间切片对比图
fprintf('生成时间切片图...\n');
figure('Name', '时间切片', 'Position', [100, 100, 1200, 400]);

% 选择几个时间点
time_points = [0.01, 0.05, T]; % T/10, T/2, T

for i = 1:length(time_points)
    t_val = time_points(i);
    [~, idx] = min(abs(t_test - t_val));
    t_val = t_test(idx); % 使用实际最接近的时间点
    
    % 获取该时间点的预测值
    u_slice = u_pred(idx, :);
    
    subplot(1, length(time_points), i);
    plot(x_test, u_slice, 'LineWidth', 2);
    title(sprintf('时间 t = %.3f', t_val));
    xlabel('空间 x'); ylabel('u(x)');
    grid on;
    ylim([min(u_pred(:)), max(u_pred(:))]);
end

%% 4. 残差分布云图
fprintf('计算残差分布...\n');
residuals = zeros(nt, nx);
batch_size = 1000; % 分批处理避免内存问题

for i = 1:ceil(numel(X)/batch_size)
    % 计算批次索引
    start_idx = (i-1)*batch_size + 1;
    end_idx = min(i*batch_size, numel(X));
    
    % 提取当前批次数据
    batch = X_test(:, start_idx:end_idx);
    batch_dl = dlarray(batch, 'CB');
    
    % 计算残差
    res_batch = dlfeval(@computeResidual, net, batch_dl);
    
    % 存储结果
    [row, col] = ind2sub([nt, nx], start_idx:end_idx);
    for j = 1:numel(res_batch)
        if col(j) <= nx && row(j) <= nt % 确保索引有效
            residuals(row(j), col(j)) = extractdata(res_batch(j));
        end
    end
end

% 创建残差云图
figure('Name', '残差分布', 'Position', [100, 100, 800, 600]);
contourf(x_test, t_test, log10(abs(residuals) + 1e-10), 50, 'LineColor', 'none');
title('PDE 残差分布 (log10 scale)');
xlabel('空间 x'); ylabel('时间 t');
colormap(flipud(hot)); 
colorbar('Location', 'eastoutside');
caxis([-6, 2]); % 调整色标范围

%% 5. 边界条件检查图
fprintf('检查边界条件...\n');
figure('Name', '边界条件', 'Position', [100, 100, 1200, 400]);

% 空间边界误差
t_boundary = linspace(0, T, 100); % 使用更密集的时间点
x_left = zeros(size(t_boundary));
x_right = L * ones(size(t_boundary));

% 左边界预测
X_left_test = [x_left; t_boundary];
u_left_pred = extractdata(forward(net, dlarray(X_left_test, 'CB')));

% 右边界预测
X_right_test = [x_right; t_boundary];
u_right_pred = extractdata(forward(net, dlarray(X_right_test, 'CB')));

% 左边界
subplot(1,2,1);
plot(t_boundary, u_left_pred, 'LineWidth', 2);
title('左边界预测 (x=0)');
xlabel('时间 t'); ylabel('u(0,t)');
grid on;

% 右边界
subplot(1,2,2);
plot(t_boundary, u_right_pred, 'LineWidth', 2);
title('右边界预测 (x=L)');
xlabel('时间 t'); ylabel('u(L,t)');
grid on;

fprintf('可视化完成!\n');