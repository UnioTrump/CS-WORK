% SIR.m
function dx = SIR(~, x)
    % SIR传染病模型
    % input:
    %   x(1) = I (感染者比例)
    %   x(2) = S (易感者比例)
    %   x(3) = R (康复者比例)

    % Args:
    lambda = 1.0;  % 感染率 (λ)
    mu = 0.3;      % 康复率 (μ)
    
    % ODE:
    dI = lambda * x(2) * x(1) - mu * x(1);  % dI/dt
    dS = -lambda * x(2) * x(1);             % dS/dt
    dR = mu * x(1);                         % dR/dt
    
    % return
    dx = [dI; dS; dR];
end