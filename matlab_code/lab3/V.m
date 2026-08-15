function y = V(u, V0, t)
total_melt = 0;
% 完整天数部分
for k = 1:fix(t)
    total_melt = total_melt + r(u, k);
end
% 剩余小数天数（按比例计算）
if fix(t) < t
    partial_day = t - fix(t);
    melt_partial = r(u, fix(t)+1) * partial_day;
    total_melt = total_melt + melt_partial;
end
% 计算最终体积
r_initial = (3*V0/(4*pi))^(1/3);
r_current = r_initial - total_melt;
y = (4*pi/3) * r_current^3;
end