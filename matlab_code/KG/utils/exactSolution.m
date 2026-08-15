function u = exactSolution(x, t)
    u = x .* (1 - x) .* cos(5 * pi * t);
end
