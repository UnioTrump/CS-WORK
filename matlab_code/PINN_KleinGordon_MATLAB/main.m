clear; clc;

addpath("utils");

alpha = 1;
numLayers = 3;
numNeurons = 20;
parameters = initializeParameters(numLayers, numNeurons);
learnRate = 1e-3;
numEpochs = 300;

[X_ic, u_ic, dudt_ic, X_bc, u_bc, X_f] = generateTrainingData();

lossHistory = zeros(numEpochs,1);

for epoch = 1:numEpochs
    [loss, gradients] = dlfeval(@modelLoss, parameters, X_ic, u_ic, dudt_ic, X_bc, u_bc, X_f, alpha);
    parameters = sgdUpdate(parameters, gradients, learnRate);
    lossHistory(epoch) = extractdata(loss);
    if mod(epoch,100)==0
        fprintf("Epoch %d: Loss = %.4e\n", epoch, lossHistory(epoch));
    end
end

% 测试与可视化
[xTest, tTest] = meshgrid(linspace(0,1,100), linspace(0,1,100));
XTest = dlarray([xTest(:), tTest(:)]);

uPred = extractdata(predictPINN(XTest, parameters));
uTrue = exactSolution(XTest(:,1), XTest(:,2));

% 调试信息：检查数据类型和维度
fprintf("uPred class: %s, size: [%s]\n", class(uPred), num2str(size(uPred)));
fprintf("uTrue class: %s, size: [%s]\n", class(uTrue), num2str(size(uTrue)));

% 多重保险的数据类型转换
if isa(uPred, 'dlarray')
    uPred = extractdata(uPred);
end
if isa(uTrue, 'dlarray')
    uTrue = extractdata(uTrue);
end

% 确保为列向量且为double类型
uPred = double(uPred(:));
uTrue = double(uTrue(:));

% 再次检查
fprintf("After conversion - uPred class: %s, uTrue class: %s\n", class(uPred), class(uTrue));

% 使用更安全的范数计算方法
try
    relError = norm(uTrue - uPred, 2) / norm(uTrue, 2);
catch ME
    fprintf("Error with norm function: %s\n", ME.message);
    % 手动计算L2范数
    relError = sqrt(sum((uTrue - uPred).^2)) / sqrt(sum(uTrue.^2));
    fprintf("Using manual L2 norm calculation\n");
end

fprintf("Relative L2 Error: %.4e\n", relError);

uPredGrid = reshape(uPred, size(xTest));
uTrueGrid = reshape(uTrue, size(xTest));
errorGrid = abs(uPredGrid - uTrueGrid);

figure;
surf(xTest, tTest, errorGrid, 'EdgeColor', 'none');
xlabel("x"); ylabel("t"); zlabel("|u_{pred} - u_{true}|");
title("Prediction Error Surface");
colorbar;
saveas(gcf, "error_surface.png");