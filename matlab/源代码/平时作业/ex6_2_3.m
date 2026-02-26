% 文件名: solve_rbf_integral.m
% 描述: 使用 RBF 神经网络逼近法求解复杂积分，并与基准方法对比。
%
% 需要工具箱: Deep Learning Toolbox (用于 newrb 函数)

clear;
clc;

% --- 全局参数 ---
inf_u = 40;
inf_v = 40;
nn = 30;    % 粗糙网格/查询网格的划分数 (对应书中的 nn)
nn_train = 20; % 用于训练网络的更稀疏的采样点数 (对应书中的 nn/1.5)
spread = 3 * inf_u / nn; % RBF 网络的扩展系数, 参照书本设定

fprintf('--- 方法: RBF 神经网络逼近法 ---\n');
fprintf('训练样本点数: %d x %d = %d\n', nn_train, nn_train, nn_train^2);
fprintf('查询/积分点数: %d x %d = %d\n', nn, nn, nn^2);
tic;

% 1. 生成用于训练网络的稀疏采样点 (Training Grid)
train_u = linspace(0, inf_u, nn_train);
train_v = linspace(0, inf_v, nn_train);
[U_train, V_train] = ndgrid(train_u, train_v);

% 格式化为网络输入
input = [U_train(:)'; V_train(:)'];

% 2. 计算这些稀疏采样点上的真实函数值 (最耗时的一步)
fprintf('正在计算 %d 个训练样本的真实函数值...\n', nn_train^2);
output = zeros(1, nn_train^2);
for k = 1:nn_train^2
    output(k) = Tf_Integrand_modern(input(1,k), input(2,k));
end
fprintf('训练样本计算完成。\n');

% 3. 训练 RBF 神经网络
% newrb(输入, 输出, 均方误差目标, 扩展系数)
fprintf('正在训练 RBF 神经网络...\n');
net = newrb(input, output, 1e-5, spread);
fprintf('网络训练完成。\n');

% 4. 生成用于积分的密集查询点 (Query Grid)
query_u = linspace(0, inf_u, nn);
query_v = linspace(0, inf_v, nn);
[U_query, V_query] = ndgrid(query_u, query_v);

% 5. 使用训练好的网络，快速预测密集查询点上的函数值
fprintf('正在使用网络进行预测...\n');
% 使用现代语法 net(...) 代替旧的 sim(net, ...)
Tf_net = net([U_query(:)'; V_query(:)']); 
Tf_net = reshape(Tf_net, nn, nn);

% 6. 计算最终积分 (修正后的正确方法)
% 积分 ≈ (所有查询点上的预测值之和) * (单个查询网格的面积)
cell_area = (inf_u / (nn-1)) * (inf_v / (nn-1));
result_rbf = sum(Tf_net(:)) * cell_area;
time_rbf = toc;

% =========================================================================
%                         结果展示与对比
% =========================================================================
fprintf('\n--- 正在运行基准方法以供对比 ---\n');
tic;
integrand_wrapper = @(u, v) arrayfun(@Tf_Integrand_modern, u, v);
result_benchmark = integral2(integrand_wrapper, 0, inf_u, 0, inf_v);
time_benchmark = toc;

fprintf('\n===============================================================\n');
fprintf('                   RBF 方法 vs 基准方法\n');
fprintf('===============================================================\n');
fprintf('%-28s | %-12s | %-12s\n', '方法', '积分结果', '耗时 (秒)');
fprintf('---------------------------------------------------------------\n');
fprintf('%-26s | %-12.4f | %-12.4f\n', 'RBF 神经网络法', result_rbf, time_rbf);
fprintf('%-26s | %-12.4f | %-12.4f\n', '自适应积分法 (基准)', result_benchmark, time_benchmark);
fprintf('===============================================================\n\n');



% =========================================================================
% 本地函数: 计算被积函数 (与之前版本相同)
% =========================================================================
function z = Tf_Integrand_modern(u, v)
    m = 1; n = 1; a = 1; b = 1;
    km = 2*m*pi/a; kn = 2*n*pi/b;
    f_rel_integrand = @(x,y) (1-cos(km*x)).*(1-cos(kn*y)).*cos(u.*x+v.*y);
    f_img_integrand = @(x,y) (1-cos(km*x)).*(1-cos(kn*y)).*sin(u.*x+v.*y);
    tmp_rel = integral2(f_rel_integrand, 0, a, 0, b);
    tmp_img = integral2(f_img_integrand, 0, a, 0, b);
    denominator = sqrt(u.^2 + v.^2);
    if denominator < 1e-9, z = 0;
    else, z = (tmp_rel.^2 + tmp_img.^2) ./ denominator; end
end