%传染病模型 SIS模型
%绘制di/dt-i曲线图
%λ=0.1, σ=1.5
clear; clc;

k=0.1;a=1.5;
f = @(x) -k*x.*(x - (1 - 1/a));
x1 = 0;
x2 = 1 - 1/1.5;

fplot(f, [0, 0.4], 'LineWidth', 2);
ylim([-0.0005, 0.003]);
hold on;

plot([0, 0.4], [0, 0], 'k:', 'LineWidth', 1.5);

plot(x1, f(x1), 'ro', 'MarkerFaceColor', 'r');
plot(x2, f(x2), 'ro', 'MarkerFaceColor', 'r');
text(x1, -0.0001, 'i=0', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
text(x2, -0.0001, sprintf('i=%.4f', x2), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');

title('SIS模型的di/dt~i曲线');
xlabel('感染比例 i');
ylabel('变化率 di/dt');
grid on;
legend('di/dt = -λi(i-(1-1/σ))', '参考线 (di/dt=0)', '平衡点', ...
       'Location', 'northeast');
box on;
hold off;
