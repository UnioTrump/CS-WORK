% 传染病模型 SI模型
%i~t曲线图
clear; clc;

syms x(t) k x0
eqn = diff(x,t) == k*x*(1-x);  
cond = x(0) == x0;
x_sol = dsolve(eqn, cond);

% 参数设置
x0_val = 0.15;
k_val = 0.2;
tt = 0:0.1:30;

x_func = matlabFunction(subs(x_sol, {k, x0}, {k_val, x0_val}));
disp(x_func)
xx = x_func(tt);

plot(tt, xx, 'LineWidth', 2);
axis([0 31 0 1.1]);
grid on;

title('SI模型的感染比例随时间变化曲线');
xlabel('时间 t （天）'); 
ylabel('感染比例 i');
legend(sprintf('i_0=%.2f, \\lambda=%.1f', x0_val, k_val), 'Location', 'southeast');

hold on;
plot(0, x0_val, 'ro', 'MarkerFaceColor', 'r');
text(1, x0_val+0.05, sprintf('i_0=%.2f', x0_val), 'Color', 'r');
hold off;