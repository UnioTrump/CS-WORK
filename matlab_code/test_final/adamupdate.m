function [net, avgGrad, avgSqGrad] = adamupdate(net, grad, avgGrad, avgSqGrad, iter, learnRate)
    beta1 = 0.9; beta2 = 0.999; eps = 1e-8;
    if isempty(avgGrad); avgGrad = dlupdate(@zerosLike, grad); end
    if isempty(avgSqGrad); avgSqGrad = dlupdate(@zerosLike, grad); end

    avgGrad = dlupdate(@(g, ag) beta1*ag + (1-beta1)*g, grad, avgGrad);
    avgSqGrad = dlupdate(@(g, ag2) beta2*ag2 + (1-beta2)*(g.^2), grad, avgSqGrad);

    avgGradCorr = dlupdate(@(ag) ag/(1-beta1^iter), avgGrad);
    avgSqGradCorr = dlupdate(@(ag2) ag2/(1-beta2^iter), avgSqGrad);

    net = dlupdate(@(w, g, vg) w - learnRate * g ./ (sqrt(vg) + eps), net, avgGradCorr, avgSqGradCorr);
end

function z = zerosLike(x)
    z = zeros(size(x), 'like', x);
end
