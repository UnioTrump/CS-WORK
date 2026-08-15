%lab3_2_1
clear; clc;
g = 0.1;
r = 1.5:0.1:3;

t = -2 * (20*g - 2*r + 1) ./ (g * r);

results = [r; t; round(10*t)/10]';
disp('    r        t      t_rounded');
disp(results);

plot(r, t, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
grid on;
xlabel('r'); 
ylabel('t');
title(['t vs r (g = ', num2str(g), ')']);
axis([min(r) max(r) min(t)-1 max(t)+1]);