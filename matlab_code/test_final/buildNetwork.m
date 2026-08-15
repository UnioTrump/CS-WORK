function net = buildNetwork()
layers = [
    featureInputLayer(2, "Name", "input")
    fullyConnectedLayer(64, "Name", "fc1")
    tanhLayer("Name", "tanh1")
    fullyConnectedLayer(64, "Name", "fc2")
    tanhLayer("Name", "tanh2")
    fullyConnectedLayer(1, "Name", "output")
];

% 直接创建层图 - 移除不必要的连接
lgraph = layerGraph(layers);
net = dlnetwork(lgraph);
end