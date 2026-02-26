% 文件名: compare_all_methods.m
% 描述: 最终对比脚本，重现并验证教科书关于三种积分方法
%       (自适应、网格法、插值法) 在速度与精度上的权衡。

clear;
clc;

% --- 全局参数 ---
inf_u = 40;
inf_v = 40;

% 用于存储结果的变量
results_table = cell(3, 3);

% =========================================================================
% 方法一: 自适应积分法 (基准) - 最精确
% =========================================================================
fprintf('--- 正在运行方法 1: 完全自适应积分法 (基准) ---\n');
tic;
integrand_wrapper = @(u, v) arrayfun(@Tf_Integrand_modern, u, v);
result_benchmark = integral2(integrand_wrapper, 0, inf_u, 0, inf_v);
time_benchmark = toc;
results_table(1, :) = {'自适应积分法 (基准)', result_benchmark, time_benchmark};
fprintf('完成。耗时: %.2f 秒。\n\n', time_benchmark);

% =========================================================================
% 方法二: 网格法 (nn=25) - 模拟书中对比
% =========================================================================
fprintf('--- 正在运行方法 2: 网格法 (25x25 网格) ---\n');
tic;
nn_grid = 25;
cell_area_grid = (inf_u / nn_grid) * (inf_v / nn_grid);
U_grid_centers = linspace(inf_u/(2*nn_grid), inf_u-inf_u/(2*nn_grid), nn_grid);
V_grid_centers = linspace(inf_v/(2*nn_grid), inf_v-inf_v/(2*nn_grid), nn_grid);
[U_grid, V_grid] = ndgrid(U_grid_centers, V_grid_centers);
Tf_grid_values = zeros(nn_grid^2, 1);
for k = 1:nn_grid^2
    Tf_grid_values(k) = Tf_Integrand_modern(U_grid(k), V_grid(k));
end
result_grid = sum(Tf_grid_values) * cell_area_grid;
time_grid = toc;
results_table(2, :) = {'网格法 (25x25)', result_grid, time_grid};
fprintf('完成。耗时: %.2f 秒。\n\n', time_grid);

% =========================================================================
% 方法三: 插值法 (粗15x15, 细50x50) - 模拟书中对比
% =========================================================================
fprintf('--- 正在运行方法 3: 插值法 (粗15x15, 细50x50) ---\n');
tic;
nn_interp = 15;
mm_interp = 50;

% 粗糙网格计算 (最耗时部分)
coarse_u = linspace(0, inf_u, nn_interp);
coarse_v = linspace(0, inf_v, nn_interp);
[U_coarse, V_coarse] = ndgrid(coarse_u, coarse_v);
Tf_coarse = zeros(nn_interp, nn_interp);
for k = 1:nn_interp^2
    Tf_coarse(k) = Tf_Integrand_modern(U_coarse(k), V_coarse(k));
end

% 插值和求和
F = griddedInterpolant(U_coarse, V_coarse, Tf_coarse, 'linear', 'none');
fine_u = linspace(0, inf_u, mm_interp);
fine_v = linspace(0, inf_v, mm_interp);
[UI_fine, VI_fine] = ndgrid(fine_u, fine_v);
Tf_fine_interp = F(UI_fine, VI_fine);
cell_area_fine = (inf_u / (mm_interp-1)) * (inf_v / (mm_interp-1));
result_interp = sum(Tf_fine_interp(:), 'omitnan') * cell_area_fine;
time_interp = toc;
results_table(3, :) = {'插值法 (15x15 -> 50x50)', result_interp, time_interp};
fprintf('完成。耗时: %.2f 秒。\n\n', time_interp);


% =========================================================================
% 最终结果展示与分析
% =========================================================================
fprintf('===============================================================\n');
fprintf('                最终结果对比\n');
fprintf('===============================================================\n');
fprintf('%-28s | %-12s | %-12s\n', '方法', '积分结果', '耗时 (秒)');
fprintf('---------------------------------------------------------------\n');
for i = 1:3
    fprintf('%-26s | %-12.4f | %-12.4f\n', results_table{i,1}, results_table{i,2}, results_table{i,3});
end
fprintf('===============================================================\n\n');



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