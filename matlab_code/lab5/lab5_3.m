clear; clc;

% 完整旅游人数数据 (1997-2015)
p = [791.7, 856, 929.1, 1007.6, 1124.7, 1255, 1234.1, 1402.9, 1516.5, 1605, ...
     1845.5, 2060, 2250.3, 2587.3, 2708.7, 2971.2, 3259.2, 3575.1, 3921.7]; % 1997-2015年数据
p = p / 1000; % 归一化处理

n = length(p); % 数据长度
m = 3; % 输入层节点数（3年数据）
td = 0; % 预测未来年数（0表示预测下一年）

% 构建训练数据集 (3年输入 → 1年输出)
pn = [];
t = [];
for i = 1:(n - m - td)
    % 输入：连续m年的数据
    pn = [pn; p(i:i+m-1)];
    % 输出：第m+td+1年的数据 (修正：添加+1)
    t = [t; p(i+m+td)];
end
pn = pn'; % 转置为每列一个样本
t = t';   % 目标也转置保持一致

% 创建BP神经网络
net = feedforwardnet([10, 8], 'trainlm'); % 两层隐藏层（10和8个神经元）
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'tansig';
net.layers{3}.transferFcn = 'purelin';

% 配置网络参数
net.divideParam.trainRatio = 0.7; % 训练集比例
net.divideParam.valRatio = 0.2;   % 验证集比例
net.divideParam.testRatio = 0.1;    % 测试集比例
net.trainParam.show = 20;         % 显示频率
net.trainParam.lr = 1e-4;         % 学习率
net.trainParam.epochs = 1000;     % 最大训练轮数
net.trainParam.goal = 1e-5;       % 目标误差
net.trainParam.max_fail = 10;     % 验证失败最大次数

% 训练网络
[net, tr] = train(net, pn, t);

% 使用网络进行预测（历史数据）
A = net(pn); % 训练数据的预测值

% 计算历史预测误差
% 修正：预测对应的年份应该是2000-2015（因为用1997-1999预测2000，用1998-2000预测2001...）
actual_years = 2000:2015; % 对应预测年份
actual_values = t * 1000; % 实际值（反归一化）
predicted_values = A * 1000; % 预测值（反归一化）

% 确保向量维度一致
if size(predicted_values,1) > size(predicted_values,2)
    predicted_values = predicted_values';
end
if size(actual_values,1) > size(actual_values,2)
    actual_values = actual_values';
end

errors = actual_values - predicted_values;
MSE = mean(errors.^2); % 均方误差
RMSE = sqrt(MSE); % 均方根误差
MAPE = mean(abs(errors./actual_values)) * 100; % 平均绝对百分比误差

% 绘图 - 历史预测结果
figure('Position', [100, 100, 900, 500]);
plot(actual_years, actual_values, 'b-o', 'LineWidth', 2, 'MarkerSize', 8, ...
     'MarkerFaceColor', 'b', 'DisplayName', '实际值');
hold on;
plot(actual_years, predicted_values, 'r--s', 'LineWidth', 2, 'MarkerSize', 8, ...
     'MarkerFaceColor', 'r', 'DisplayName', '预测值');

% 添加误差线
for i = 1:length(actual_years)
    line([actual_years(i), actual_years(i)], ...
         [actual_values(i), predicted_values(i)], ...
         'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.5);
end

grid on;
xlabel('年份', 'FontSize', 12);
ylabel('旅游人数 (万人)', 'FontSize', 12);
title('BP神经网络旅游人数预测 (2000-2015)', 'FontSize', 14);
legend('Location', 'northwest');
set(gca, 'FontSize', 11, 'XTick', 2000:2:2016);

% 添加误差标注（调整位置避免重叠）
text(actual_years, max(actual_values, predicted_values) + 100, ...
     num2str(round(errors')), 'FontSize', 9, 'HorizontalAlignment', 'center');

% 预测未来年份
future_years = 2016:2020; % 预测未来5年
future_predictions = zeros(1, length(future_years));

% 使用最后3年数据预测下一年
current_data = p(end-2:end)'; % 2013-2015年数据
for i = 1:length(future_years)
    future_predictions(i) = net(current_data); % 预测
    % 更新输入数据：移除最旧的，添加最新预测的
    current_data = [current_data(2:3); future_predictions(i)];
end

% 显示预测结果
fprintf('\n=== 模型性能评估 ===\n');
fprintf('历史数据预测误差:\n');
fprintf('MSE (均方误差): %.4f\n', MSE);
fprintf('RMSE (均方根误差): %.4f\n', RMSE);
fprintf('MAPE (平均绝对百分比误差): %.2f%%\n', MAPE);

fprintf('\n=== 未来5年预测结果 ===\n');
fprintf('年份\t预测值(万人)\n');
for i = 1:length(future_years)
    fprintf('%d\t%.2f\n', future_years(i), future_predictions(i)*1000);
end

% 绘制未来预测
figure('Position', [100, 100, 800, 400]);
bar(future_years, future_predictions*1000, 'FaceColor', [0.5 0.7 1]);
xlabel('年份', 'FontSize', 12);
ylabel('预测旅游人数 (万人)', 'FontSize', 12);
title('未来旅游人数预测 (2016-2020)', 'FontSize', 14);
grid on;
set(gca, 'FontSize', 11);

% 添加数值标签
for i = 1:length(future_years)
    text(future_years(i), future_predictions(i)*1000 + 50, ...
         sprintf('%.1f', future_predictions(i)*1000), ...
         'HorizontalAlignment', 'center', 'FontSize', 10);
end