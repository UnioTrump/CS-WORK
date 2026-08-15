function [X, u] = sampleBoundary(N)
    x = [zeros(N/2,1); ones(N/2,1)];
    t = rand(N,1);
    u = zeros(N,1);
    X = dlarray([x, t]');
    u = dlarray(u');
end