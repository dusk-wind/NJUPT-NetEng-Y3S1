% 1. 清理工作区和命令行窗口
clear;
clc;

% 2. 定义内层积分的被积函数
%    This is the function inside the parentheses: e^(-x^2) / (y^2 + x^2)
%    It is a function of both x and y.
inner_integrand = @(x, y) exp(-x.^2) ./ (y.^2 + x.^2);

% 3. 定义一个函数 G(y) 来计算内层积分
%    For any given scalar value of y, this function integrates inner_integrand
%    with respect to x from -1 to 1.
G = @(y) integral(@(x) inner_integrand(x, y), -1, 1);

% 4. 定义外层积分的完整被积函数
%    The full function is: 2*y*e^(-y^2) * (G(y))^2
%    The outer 'integral' function requires its input function to be vectorized.
%    Since our function G(y) involves an integral, it is not naturally
%    vectorized. We use arrayfun to evaluate G for each element of y
%    passed by the outer integral command.
outer_integrand = @(y) 2.*y.*exp(-y.^2) .* arrayfun(G, y).^2;

% 5. 定义外层积分的区间
ymin = 0.2;
ymax = 1;

% 6. 计算最终的外层积分
tic; % Start timer
result = integral(outer_integrand, ymin, ymax);
toc; % Stop timer

% 7. 显示结果
disp('使用 modern integral 函数计算的结果为:');
fprintf('%.4f\n', result);