%lab2_2
function [y,k]=pai3(epsi)
% 公式法
k1=0;n=1;s1=1/2;f=1;
an=1/2;sn=an;
while sn>epsi
    f=-f;
    n=n+2;
    an=an./4;
    sn=an./n;s1=s1+f.*sn;
    k1=k1+1;
end
k2=0;n=1;s2=1/3;f=1;
an=1/3;sn=an;
while sn>epsi
    f=-f;
    n=n+2;
    an=an./9;
    sn=an./n;
    s2=s2+f*an;
    k2=k2+1;
end
y=4*(s1+s2);
k=k1+k2;
end