%ice_mount.m
function y = ice_mount(u, V0)
% 生成网格计算
[U_grid, V0_grid] = meshgrid(u, V0);
S_vals = arrayfun(@(u_val, v0_val) S(u_val, v0_val), U_grid, V0_grid);
W_vals = W(u, V0);
y = S_vals ./ W_vals;
end