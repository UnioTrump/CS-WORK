% 传染病模型 SIS模型
% i-t曲线
% λ=0.2, σ=3
clear; clc;

syms x(t) k m x0
eqn = diff(x,t) == -k*x*(x - (1-1/m));
cond = x(0) == x0;
x_sol = dsolve(eqn, cond);

% 第一组参数 (i0=0.2)
k_val = 0.2; m_val = 3; x0_val = 0.2;
tt = 0:0.1:40;

func1 = matlabFunction(subs(x_sol, {k, m, x0}, {k_val, m_val, x0_val}));
disp(func1)
xx1 = func1(tt);

% 第二组参数 (i0=0.9)
x0_val2 = 0.9;
func2 = matlabFunction(subs(x_sol, {k, m, x0}, {k_val, m_val, x0_val2}));
xx2 = func2(tt);

equilibrium = 1 - 1/m_val;

figure;
plot(tt, xx1, 'b', 'LineWidth', 1.5); hold on;
plot(tt, xx2, 'r:', 'LineWidth', 1.5);
plot([0, 40], [equilibrium, equilibrium], '-.k', 'LineWidth', 1.5);
hold off;

axis([0 40 0 1]);
grid on;
title('SIS模型的感染比例随时间变化曲线 (\lambda=0.2, \sigma=3)');
xlabel('时间 t (天)'); 
ylabel('感染比例 i');
legend(['i(0)=', num2str(x0_val)], ...
       ['1-1/\sigma=', num2str(equilibrium, '%.4f')], ...
       ['i(0)=', num2str(x0_val2)], ...
       'Location', 'east');

annotation('textbox', [0.7, 0.15, 0.1, 0.05], 'String', ...
           ['平衡点: i^*=1-1/\sigma=', num2str(equilibrium, '%.4f')], ...
           'FitBoxToText', 'on', 'BackgroundColor', 'white');