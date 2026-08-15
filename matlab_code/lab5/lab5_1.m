% 灰色预测模型 - 旅游人数预测
clear;
clc;

% 原始数据 (1997-2010)
A = [791.69 855.97 929.09 1007.57 1124.75 1254.97 1234.11 1402.88 1516.47 1605.02 1845.50 2060.00 2250.33 2587.35];
years_actual = 1997:2010;

% 灰色GM(1,1)建模
B = cumsum(A);       % 累加生成序列
n = length(A);
C = zeros(1, n-1);   % 紧邻均值生成序列
for i = 1:(n-1)
    C(i) = (B(i) + B(i+1)) / 2;
end

D = A(2:end)';       % 去掉第一个原始数据
E = [-C; ones(1, n-1)];
c = (E * E') \ (E * D); % 使用左除求解更稳定
a = c(1);
b = c(2);

% 预测设置 (1997-2015)
total_years = n + 5;  % 14年实际数据 + 5年预测
F = zeros(1, total_years); % 累加预测值
G = zeros(1, total_years); % 还原预测值

% 累加预测
F(1) = A(1);
for i = 2:total_years
    F(i) = (A(1) - b/a) * exp(-a*(i-1)) + b/a;
end

% 还原预测
G(1) = A(1);
for i = 2:total_years
    G(i) = F(i) - F(i-1);
end

% 年份设置
years_forecast = 1997:2015;

% 显示参数
fprintf('灰色GM(1,1)模型参数:\n');
fprintf('发展系数 a = %.6f\n', a);
fprintf('灰色作用量 b = %.6f\n', b);

% 绘图 - 使用曲线图表示
figure;
set(gcf, 'Position', [100, 100, 800, 500]); % 设置图形大小

% 绘制实际数据曲线 (1997-2010)
plot(years_actual, A, 'b-', 'LineWidth', 2, 'DisplayName', '实际值');
hold on;

% 绘制预测曲线 (1997-2015)
plot(years_forecast, G, 'r-', 'LineWidth', 2, 'DisplayName', '预测值');

% 标记预测起始点
plot(2010, G(14), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(2011, G(15), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', '预测点');

% 添加2010年垂直线
xline(2010, 'k--', 'LineWidth', 1.5, 'DisplayName', '预测起始点');

grid on;
legend('Location', 'northwest', 'FontSize', 10);
xlabel('年份', 'FontSize', 12);
ylabel('旅游人数 (万人)', 'FontSize', 12);
title('灰色GM(1,1)模型旅游人数预测', 'FontSize', 14);
set(gca, 'FontSize', 10);

% 误差分析
error_abs = abs(A - G(1:n));     % 绝对误差
error_rel = error_abs ./ A * 100; % 相对误差(%)

% 后验差检验
S1 = std(A);        % 原始数据标准差
S2 = std(error_abs); % 残差标准差
C = S2 / S1;         % 后验差比值

fprintf('\n模型精度检验:\n');
fprintf('后验差比值 C = %.4f\n', C);

% 显示误差
fprintf('\n年度预测误差分析:\n');
fprintf('年份\t实际值\t预测值\t绝对误差\t相对误差(%%)');
for i = 1:n
    fprintf('\n%d\t%.2f\t%.2f\t%.2f\t\t%.2f', ...
            years_actual(i), A(i), G(i), error_abs(i), error_rel(i));
end

% 显示预测结果
fprintf('\n\n未来5年预测结果:');
fprintf('\n年份\t预测值');
for i = n+1:total_years
    fprintf('\n%d\t%.2f', years_forecast(i), G(i));
end
fprintf('\n');