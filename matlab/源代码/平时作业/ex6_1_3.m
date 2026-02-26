% 文件名: solve_triple_integral.m
% 描述: 使用现代 integral3 函数计算三重积分
% MATLAB 版本: R2016a 及以上

% 1. 清理工作区和命令行窗口
clear;
clc;

% 2. 定义被积函数 f(x, y, z)
%    注意：使用点运算符 (.*) 是一个好习惯，以确保函数可以处理向量输入。
fun = @(x, y, z) x .* y .* z;

% 3. 定义积分区域的边界
% 外层积分 (关于 x)
xmin = 1;
xmax = 2;

% 中层积分 (关于 y)，边界是 x 的函数
ymin = @(x) x;
ymax = @(x) x.^2;

% 内层积分 (关于 z)，边界是 x 和 y 的函数
zmin = @(x, y) x .* y;
zmax = @(x, y) 2 .* x .* y;

% 4. 调用 integral3 函数进行计算
%    参数顺序为：被积函数, x下限, x上限, y下限, y上限, z下限, z上限
tic; % 开始计时
result = integral3(fun, xmin, xmax, ymin, ymax, zmin, zmax);
toc; % 结束计时

% 5. 显示结果
disp('使用 integral3 函数计算的结果为:');
fprintf('%.4f\n', result);