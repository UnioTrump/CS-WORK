clear;clc;
%lab1_4
%生成A矩阵
A=magic(6);
disp("A")
disp(A);

%去除第二行第一列的元素，赋值给a21
a21=A(2,1);
disp("a21")
disp(a21);

%将A全部偶数行赋值给B
B=A(2:2:6,:);
disp("B")
disp(B);

%A的第一列和第三列互换
B = A(:,1);
C = A(:,3);
A(:,1) = C;
A(:,3) = B;
disp("A")
disp(A);

%删除第二列
A(:,2) = [];
disp("A")
disp(A);