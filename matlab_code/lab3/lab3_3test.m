clear;clc;
% test
u_test = [25, 30, 35];
V0_test = [6e6, 8e6, 2e6];
result = ice_mount(u_test, V0_test);
disp(result);