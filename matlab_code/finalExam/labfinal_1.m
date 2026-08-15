clear;clc;
fun=@(x,y)x.*exp(y);
ymax=@(x)x;
I=integral2(fun,0,1,0,ymax);
disp(I)

syms x y;
f=x*exp(y);
P=int(int(f,y,0,x),x,0,1);
disp(P)
%% T2
% 数值解: 牛顿迭代法
f = @(x) [x(1)^2 + 3*x(2) + 1;
          x(2)^2 + 4*x(1) + 1];

J = @(x) [2*x(1),     3;
          4,      2*x(2)];

x = [0; 0];  % 初始点
tol = 1e-8;
max_iter = 100;

for k = 1:max_iter
    delta = -J(x) \ f(x);  % 求解线性方程组 J * delta = -f
    x = x + delta;
    if norm(delta) < tol
        break;
    end
end

disp('数值解为：');
disp(x);
%% T2符号解
clear;clc;
syms x y

eq1 = x^2 + 3*y + 1 == 0;
eq2 = y^2 + 4*x + 1 == 0;

[x,y] = solve([eq1, eq2], [x, y]);

disp('符号解为：');
disp(x);
disp(y);
%% T3 数值解微分方程
clear;clc;
% 将高阶ODE改写为一阶系统：
% 令 y1 = y, y2 = y'
% 得: y1' = y2, y2' = -2*x*y2^2

odefun = @(x, y) [y(2); -2*x*y(2)^2];

xspan = [0, 5];  % 积分区间
y0 = [1; -0.5];  % 初始条件: y(0)=1, y'(0)=-1/2

[xsol, ysol] = ode45(odefun, xspan, y0);

plot(xsol, ysol(:,1), 'LineWidth', 2);
xlabel('x'); ylabel('y(x)');
title('数值解 y(x)');
grid on;
%% T3符号解
clear;clc;
syms y(x)

Dy = diff(y, x);
D2y = diff(y, x, 2);

% 定义方程和初始条件
ode = D2y + 2*x*(Dy)^2 == 0;
cond1 = y(0) == 1;
cond2 = Dy(0) == -1/2;

% 解微分方程
ySol = dsolve(ode, [cond1, cond2]);

disp('符号解为：');
disp(ySol);

%% T4
% 目标函数
f = @(x) x(1)^2 + x(2)*x(3);

% 线性不等式约束 A*x <= b
A = [1 2 -1; 2 1 0];
b = [5; 3];

% 初始点
x0 = [1 1 1];

% 下界
lb = [0 0 0];

% 求解
x_opt = fmincon(f, x0, A, b, [], [], lb, []);

disp('最优解 x =');
disp(x_opt);
disp('最小值 f(x) =');
disp(f(x_opt));

%% T5
%方法1: fsurf
fsurf(@(x,y) x.^2 + y.^2, [-5 5 -5 5]);
title('fsurf: z = x^2 + y^2');
xlabel('x'); ylabel('y'); zlabel('z');

% 方法2: fimplicit3 (隐函数形式)
fimplicit3(@(x,y,z) x.^2 + y.^2 - z, [-5 5 -5 5 0 50]);
title('fimplicit3: x^2 + y^2 - z = 0');
xlabel('x'); ylabel('y'); zlabel('z');
%% T6
% 假设已有数据 X, Y (列向量)
% 使用5次多项式拟合
p = polyfit(X, Y, 5);        % 拟合多项式系数
Y_fit = polyval(p, X);       % 计算拟合值

% 绘图对比
plot(X, Y, 'o', X, Y_fit, '-');
legend('原始数据', '5次多项式拟合');
title('5次多项式拟合');
%% T6 指数模型
% 定义指数模型
ft = fittype('a*exp(b*x) + c', 'independent', 'x');

% 设置初始参数估计（重要！）
startPoints = [1, 0.1, 0];  % 根据数据调整初始值

% 执行拟合
[fitresult, gof] = fit(X, Y, ft, 'StartPoint', startPoints);

% 获取参数
a = fitresult.a;
b = fitresult.b;
c = fitresult.c;

% 绘图对比
plot(fitresult, X, Y);
legend('原始数据', '指数拟合');
title(sprintf('y = %.2f e^{%.2fx} + %.2f', a, b, c));
%% T7 参数方程法

theta = linspace(0, 2*pi, 100);
x = cos(theta);
y = sin(theta);
plot(x, y);
axis equal; title('参数方程法'); grid on;
%% T7 隐函数方法

fimplicit(@(x,y) x.^2 + y.^2 - 1, [-1.5 1.5 -1.5 1.5]);
axis equal; title('隐函数绘图法'); grid on;
