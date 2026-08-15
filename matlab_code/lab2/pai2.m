%lab2_1_2
function [z,k] = pai2(epsi)
% 仍然是迭代法
k=2;n=5;l=1;error=1;
s=1-1/3+1/5;
while error>epsi
    z=s-l*(n-2)./(4*k*n);
    l=-l;
    n=n+2;
    s=s+l/n;
    error=abs(4*z-pi);
    %disp(error)
    k=k+1;
end
z = 4*z;
end