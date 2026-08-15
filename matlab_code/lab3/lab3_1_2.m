clear; clc;
% 定义符号变量
syms t g r  
% 构造表达式
Q = (8 - g*t)*(80 + r*t) - 4*t - 640;
% 求导数
dQ = diff(Q, t);
t_sol = solve(dQ, t);
% 带入参数值求临界点
r_val = 2;
g_val = 0.1;
t_num = double(subs(t_sol, [g, r], [g_val, r_val]));
% 计算最大值
Q_num = double(subs(Q, [t, g, r], [t_num, g_val, r_val]));

disp(['临界点 t = ', num2str(t_num)]);
disp(['最大 Q 值 = ', num2str(Q_num)]);