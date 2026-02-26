% --- 初始化环境 ---
clc;
clear;
format long;

fprintf('=====================================================\n');
fprintf('    运行第 6.3 节: 通用 N 重积分计算 (直接解法脚本)\n');
fprintf('=====================================================\n\n');

%% --- 【例 6.3-1】: 四重积分 ---
fprintf('--- 正在求解【例 6.3-1】(四重积分) ---\n');

% 被积函数
fun1 = @(x1, x2, x3, x4) exp(x1.*x2.*x3.*x4);

% 从内到外逐层定义积分
% G3_1 是对 x4 积分的结果, 是 x1,x2,x3 的函数
G3_1 = @(x1, x2, x3) integral(@(x4) fun1(x1, x2, x3, x4), 0, x1.*x2 + x3 + 1);
% G2_1 是对 x3 积分的结果, 是 x1,x2 的函数
G2_1 = @(x1, x2) integral(@(x3) arrayfun(@(x3_s) G3_1(x1, x2, x3_s), x3), 0, x2);
% G1_1 是对 x2 积分的结果, 是 x1 的函数
G1_1 = @(x1) integral(@(x2) arrayfun(@(x2_s) G2_1(x1, x2_s), x2), 0, x1);

% 计算最外层积分
tic;
result1 = integral(@(x1) arrayfun(G1_1, x1), 0, 1);
time1 = toc;

fprintf('耗时: %.4f 秒\n', time1);
fprintf('计算结果: %f\n', result1);
fprintf('书中结果: 1.069397608859771\n\n');

%% --- 【例 6.3-2】: 三重积分 ---
fprintf('--- 正在求解【例 6.3-2】(三重积分) ---\n');

% 被积函数
fun2 = @(x1, x2, x3) x1.*x2.*x3;

% 从内到外逐层定义积分
% G2_2 是对 x3 积分的结果, 是 x1,x2 的函数
G2_2 = @(x1, x2) integral(@(x3) fun2(x1, x2, x3), x1.*x2, 2.*x1.*x2);
% G1_2 是对 x2 积分的结果, 是 x1 的函数
G1_2 = @(x1) integral(@(x2) arrayfun(@(x2_s) G2_2(x1, x2_s), x2), x1, 2.*x1);

% 计算最外层积分
tic;
result2 = integral(@(x1) arrayfun(G1_2, x1), 1, 2);
time2 = toc;

fprintf('耗时: %.4f 秒\n', time2);
fprintf('计算结果: %.4f\n', result2);
fprintf('书中结果: 179.2969\n\n');

%% --- 【例 6.3-3】: 四重积分 ---
fprintf('--- 正在求解【例 6.3-3】(四重积分) ---\n');

% 被积函数
fun3 = @(x1, x2, x3, x4) sqrt(x1.*x2).*log(x3) + sin(x4./x2);

% 从内到外逐层定义积分
G3_3 = @(x1, x2, x3) integral(@(x4) fun3(x1, x2, x3, x4), x1 + x1.*x3, x1 + 2.*x1.*x3);
G2_3 = @(x1, x2) integral(@(x3) arrayfun(@(x3_s) G3_3(x1, x2, x3_s), x3), x1.*x2, 2.*x1.*x2);
G1_3 = @(x1) integral(@(x2) arrayfun(@(x2_s) G2_3(x1, x2_s), x2), x1, 3.*x1);

% 计算最外层积分
tic;
result3 = integral(@(x1) arrayfun(G1_3, x1), 1, 2);
time3 = toc;

fprintf('耗时: %.4f 秒\n', time3);
fprintf('计算结果: %.4e\n', result3);
fprintf('书中结果: 1.5025e+003\n\n');
