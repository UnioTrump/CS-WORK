%lab2_1
function [s,k] = pai1(epsi)
%%这是利用迭代加速法计算
k = 0;n = 1;l = 1;
xn = 1;s = 1;error = 1;
while error > epsi
    l=-l;
    n=n+2;
    xn = 1/n;
    s=s+l*xn;
    error = abs(4*s-pi);
    %disp(error)
    k=k+1;
end
s=4*s;
end
