% SIR 传染病模型
clear; clc;

% 时间范围和初始条件 [I0, S0, R0]
ts = 0:0.1:50;
x0 = [0.02, 0.98, 0];   % [感染者, 易感者, 康复者]

% 解微分方程
[t, x] = ode45(@SIR, ts, x0);

% 格式化输出
indices = [1:10, 11:5:46, 50:10:length(t)];
output_data = [t(indices), x(indices, :)];
fprintf('时间(t)\t感染者(i)\t易感者(s)\t康复者(r)\n');
fprintf('%.4f\t%.4f\t%.4f\t%.4f\n', output_data');

% 绘制时间序列
figure(1);
plot(t, x(:,1), 'r-', 'LineWidth', 2); hold on;  % 感染者 (红色)
plot(t, x(:,2), 'b-', 'LineWidth', 2);           % 易感者 (蓝色)
plot(t, x(:,3), 'g-', 'LineWidth', 2);           % 康复者 (绿色)
hold off;
grid on;
title('SIR模型: 人群比例随时间变化');
xlabel('时间 t (天)');
ylabel('人群比例');
legend('感染者 i(t)', '易感者 s(t)', '康复者 r(t)', 'Location', 'eastoutside');
set(gcf, 'Position', [100, 100, 800, 400]);

% s-i 平面
figure(2);
plot(x(:,2), x(:,1), 'LineWidth', 2);
grid on;
title('SIR模型相轨线 (s-i平面)');
xlabel('易感者比例 s');
ylabel('感染者比例 i');
annotation('textbox', [0.7, 0.8, 0.2, 0.1], 'String', ...
           ['\lambda = 1.0, \mu = 0.3', newline, 'R_0 = ', num2str(1/0.3, '%.2f')], ...
           'FitBoxToText', 'on', 'BackgroundColor', 'white');
set(gcf, 'Position', [100, 500, 500, 400]);