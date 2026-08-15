%lab3_2_2
clear; clc;
r = 2;
g = 0.06:0.01:0.15;
t = -2*(20*g - 2*r + 1) ./ (g * r);

result = [g; t; round(10*t)/10]';
disp('    g        t      t_rounded');
disp(result);

% 绘图
plot(g, t, 'b-o', 'LineWidth', 1.5);
grid on;
xlabel('g'); ylabel('t');
title('Relationship: t = -2(20g - 2r + 1)/(g r) (r=2)');
axis([0.06 0.15 0 30]);