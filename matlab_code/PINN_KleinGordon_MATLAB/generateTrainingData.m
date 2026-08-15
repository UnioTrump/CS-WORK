function [X_ic, u_ic, dudt_ic, X_bc, u_bc, X_f] = generateTrainingData()
    N_ic = 100;
    N_bc = 100;
    N_f = 10000;

    x_ic = rand(N_ic,1);
    t_ic = zeros(N_ic,1);
    u_ic = zeros(N_ic,1);
    dudt_ic = zeros(N_ic,1);
    X_ic = dlarray([x_ic, t_ic]);

    x_bc = [zeros(N_bc/2,1); ones(N_bc/2,1)];
    t_bc = rand(N_bc,1);
    u_bc = zeros(N_bc,1);
    X_bc = dlarray([x_bc, t_bc]);

    x_f = rand(N_f,1);
    t_f = rand(N_f,1);
    X_f = dlarray([x_f, t_f]);
end
