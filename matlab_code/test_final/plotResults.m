function plotResults(net, loss_history, L, T)
    figure;
    subplot(1,2,1);
    plot(loss_history); title('Loss History'); xlabel('Epoch'); ylabel('Loss');

    subplot(1,2,2);
    x = linspace(0,L,100); t = T/2;
    X_test = [x; t*ones(size(x))];
    u_pred = extractdata(forward(net, dlarray(X_test, 'CB')));
    plot(x, u_pred); title(sprintf('u(x, t=%.2f)', t)); xlabel('x'); ylabel('u');
end
