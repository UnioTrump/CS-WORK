%W.m
function y = W(u, V0)
[U, V0_grid] = meshgrid(u, V0);
T = 400 ./ U;
y = 0.85 * arrayfun(@(u_val, v0_val, t_val) V(u_val, v0_val, t_val), U, V0_grid, T);
end