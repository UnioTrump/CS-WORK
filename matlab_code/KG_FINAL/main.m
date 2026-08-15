% main.m
% Cahn-Hilliard 方程 PINN 主程序
clear; clc; close all;

%% 参数设置
L = 1.0;        % 空间长度
T = 0.1;        % 时间长度
numEpochs = 3000;
learnRate = 1e-3;

% 初始采样数量
Nf = 100; N0 = 100; Npbc = 100;

% 自适应采样参数
resampleEvery = 500;
resampleNum = 1000;

%% 生成初始训练数据
fprintf('生成初始训练数据...\n');
X_f = [L*rand(Nf,1), T*rand(Nf,1)]';
X0 = [L*rand(N0,1), zeros(N0,1)]';
u0_true = zeros(1, N0);

X_dt0 = X0;

X_left = [zeros(Npbc/2,1), T*rand(Npbc/2,1)]';
X_right = [L*ones(Npbc/2,1), T*rand(Npbc/2,1)]';

%% 构建网络
fprintf('构建物理增强残差网络...\n');
net = buildNetwork();

%% 训练准备
X_f_dl = dlarray(X_f, 'CB');
X0_dl = dlarray(X0, 'CB');
u0_true_dl = dlarray(u0_true, 'CB');
X_dt0_dl = dlarray(X_dt0, 'CB');  % 新增时间导数初值点
X_left_dl = dlarray(X_left, 'CB');
X_right_dl = dlarray(X_right, 'CB');

avgGrad = []; avgSqGrad = [];
loss_history = zeros(numEpochs,1);

%% 训练主循环
tic;
for epoch = 1:numEpochs
    [loss, grad] = dlfeval(@modelLoss, net, X_f_dl, X0_dl, u0_true_dl, X_dt0_dl,  X_left_dl, X_right_dl);
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

%% 可视化
plotResults(net, loss_history, L, T);