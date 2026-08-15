function y = r(u, k)
% 验证输入合理性
if any(k < 0) || any(u <= 0)
    error('输入参数必须为正数');
end
threshold = 1000 / (6*u);
if k <= threshold
    y = 1.56e-3 * u .* (1 + 0.4*u) .* k;
else
    y = 0.2 * (1 + 0.4*u);
end
end