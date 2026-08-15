function y = pai5(N)
% 蒙特卡洛的概率算法计算π值

x = rand(N,1);
y_points = rand(N,1); 

% 绘制所有点
scatter(x, y_points, '.');
hold on;

% 标记在圆内的点
inside = (x.^2 + y_points.^2) <= 1;
scatter(x(inside), y_points(inside), '.', 'r');

axis equal; % 使坐标轴比例相同
title(['蒙特卡洛方法估算π值: N = ', num2str(N)]);
legend('圆外点', '圆内点');

m = sum(inside);
y = 4 * m / N;
end