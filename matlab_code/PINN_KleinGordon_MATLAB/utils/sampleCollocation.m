function X = sampleCollocation(N)
    x = rand(N,1);
    t = rand(N,1);
    X = dlarray([x, t]');
end