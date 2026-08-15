function [X, u, dudt] = sampleInitial(N)
    x = linspace(0,1,N)';
    t = zeros(N,1);
    u = zeros(N,1);
    dudt = zeros(N,1);
    X = dlarray([x, t]');
    u = dlarray(u');
    dudt = dlarray(dudt');
end