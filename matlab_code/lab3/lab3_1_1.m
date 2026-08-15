% Draw
clear; clc;

g = 0.1;
r = 2;
Q = @(t) (8 - g.*t).*(80 + r.*t) - 4*t - 640;

figure('Color', 'white');
fplot(Q, [0, 20], 'LineWidth', 2);
grid on;
hold on;

t_peak = 10;
Q_peak = Q(t_peak);
plot(t_peak, Q_peak, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

xlabel('时间 t');
ylabel('Q(t)');
title('函数 Q(t) = (8 - 0.1t)(80 + 2t) - 4t - 640', 'FontSize', 10);

legend('Q(t)曲线', sprintf('最大值点 (t=%.0f, Q=%.0f)', t_peak, Q_peak), ...
       'Location', 'SouthWest');
text(t_peak+0.5, Q_peak+1, sprintf('Q_{max} = %.0f', Q_peak), ...
     'FontSize', 10, 'Color', 'red');
xlim([0, 20]);
ylim([0, 25]);

plot([t_peak, t_peak], [0, Q_peak], 'k:', 'LineWidth', 0.5);

hold off;