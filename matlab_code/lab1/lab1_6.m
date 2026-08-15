clear;clc;
%lab1_6
%输入A矩阵，这里采用随机生成的方法，将数值控制在[0,10]内
A = fix(rand(4,4)*10);
disp("A");
disp(A);

%将第二行的所有元素扩大2倍
A(3,:) = 2*A(2,:) + 3;
disp("A_After");
disp(A);