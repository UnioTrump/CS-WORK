%lab2_3
function [y,k]=pai4(epsi)
% 几何法

k=0;error=0.5;
c=1/2;
L=3*sqrt(3)/2;
while error>epsi
    c=sqrt((1+c)./2);
    L=L/c;
    error = pi-L;
    k=k+1;
end
y = L;
k = k;
end