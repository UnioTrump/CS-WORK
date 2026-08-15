% buildNetwork.m
function net = buildNetwork()
layers = [
    featureInputLayer(2, "Name", "input")
    fullyConnectedLayer(64, "Name", "fc1")
    tanhLayer("Name", "tanh1")
    additionLayer(2, "Name", "add")
    fullyConnectedLayer(64, "Name", "fc2")
    tanhLayer("Name", "tanh2")
    fullyConnectedLayer(1, "Name", "output")
];

lgraph = layerGraph(layers);
lgraph = connectLayers(lgraph, "tanh1", "add/in2");

net = dlnetwork(lgraph);
end