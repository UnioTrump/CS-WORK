function y=q(u,V0,t)
V_t = V(u, V0, t);
if V_t <= 0
    error('冰山体积不能为负！')
end
y=7.2*u.*(u+6).*(log10(V_t)-1);
end
