% 文件名: solve_complex_integral.m (已修正)
% 描述: 使用现代 integral2 函数和 arrayfun 高效求解一个复杂的四重积分问题
% MATLAB 版本: R2008b 及以上

% 1. 清理工作区和命令行窗口
clear;
clc;

% 2. 定义参数
inf_u = 40; % u 的积分上限
inf_v = 40; % v 的积分上限

% 3. 定义一个“包装”函数 (Wrapper Function)
%    由于 Tf_Integrand_modern 不是向量化的, 我们用 arrayfun 来包装它,
%    使其能够处理 integral2 传递过来的数组 U 和 V。
integrand_wrapper = @(u, v) arrayfun(@Tf_Integrand_modern, u, v);

% 4. 调用 integral2 进行外层积分
%    现在我们传递包装好的函数，并移除了无效的 'ArrayValued' 选项。
tic;
result = integral2(integrand_wrapper, 0, inf_u, 0, inf_v);
toc;

% 5. 显示结果
fprintf('Modern method result:\n');
fprintf('INT = \n    %.4f\n', result);


% =========================================================================
% 被积函数 (作为本地函数) - 此部分无需修改
% 这个函数计算在给定 (u,v) 点的值
% =========================================================================
function z = Tf_Integrand_modern(u, v)
    % 定义内部参数
    m = 1;
    n = 1;
    a = 1;
    b = 1;
    km = 2 * m * pi / a;
    kn = 2 * n * pi / b;

    % 定义内层积分的被积函数
    f_rel_integrand = @(x,y) (1-cos(km*x)).*(1-cos(kn*y)).*cos(u.*x+v.*y);
    f_img_integrand = @(x,y) (1-cos(km*x)).*(1-cos(kn*y)).*sin(u.*x+v.*y);

    % 使用 integral2 (代替 dblquad) 来计算内层积分
    tmp_rel = integral2(f_rel_integrand, 0, a, 0, b);
    tmp_img = integral2(f_img_integrand, 0, a, 0, b);

    % 计算最终值 z
    denominator = sqrt(u.^2 + v.^2);
    if denominator < 1e-9 
        z = 0;
    else
        z = (tmp_rel.^2 + tmp_img.^2) ./ denominator;
    end
end