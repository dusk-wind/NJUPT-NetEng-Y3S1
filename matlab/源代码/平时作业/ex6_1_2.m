% 文件名: ex6_1_2.m
% 描述: 使用符号计算求解二重积分

% 清理工作区和命令行窗口
clear;
clc;

% 1. 定义符号变量
syms x y

% 2. 定义被积函数
f = x*y;

% 3. 执行积分
% 首先对 y 积分，积分限是 sin(x) 到 cos(x)
inner_integral = int(f, y, sin(x), cos(x));

% 然后对 x 积分，积分限是 1 到 2
final_answer_symbolic = int(inner_integral, x, 1, 2);

% 4. 显示结果
% 显示精确的符号结果
disp('符号计算的精确结果为:');
disp(final_answer_symbolic);

% 使用 vpa 函数计算高精度数值结果
disp('高精度数值结果为:');
disp(vpa(final_answer_symbolic, 20));