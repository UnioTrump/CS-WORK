# Cahn-Hilliard PINN Solver (MATLAB)

**Equation:**
$$
\frac{\partial^2 u}{\partial t^2} - \alpha \frac{\partial^2 u}{\partial x^2} = 6xt(x^2 - t^2) - 25\pi^2 x\cos(5\pi t),\quad \alpha = 1
$$

- 初始条件: $u(x,0)=0$, $\partial u/\partial t(x,0)=0$
- 边界条件: $u(0,t)=u(1,t)=0$

## 特点
- 残差网络结构 + 注意力可扩展
- 高误差区域自适应采样
- 多图形可视化支持

## 运行
```matlab
main
```
