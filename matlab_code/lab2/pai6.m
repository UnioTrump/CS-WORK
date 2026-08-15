function y=pai6(N)
% 积分法计算pi的值

%定义函数
f=@(x)(4./(1+x.^2));
a=0;    %积分上限
b=1;    %积分下限
h=(b-a)/N;   %做微元

x=linspace(a,b,N-1);
y=f(x);
plot(x, y);
y=h*(sum(y)-0.5*(y(1)+y(end)));
end