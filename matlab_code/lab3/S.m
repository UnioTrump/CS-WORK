function y = S(u, V0)
T = 400 / u;
y = ceil(T) * f(V0);

% 计算完整天数
for t = 1:fix(T)
    y = y + q(u, V0, t);
end

% 处理剩余部分天数（按比例计算）
if fix(T) < T
    t_last = fix(T) + 1;
    partial_day = T - fix(T);  % 小数部分
    y = y + q(u, V0, t_last) * partial_day;
end
end