%f.m
function y=f(V0)
if V0 <= 5e5
    y=4.0;
elseif V0 > 5e5 && V0 <= 1e6
    y=6.2;
elseif V0 > 1e6 && V0 <= 1e7
    y=8.0;
else
    error('V0超出预设范围');
end
end