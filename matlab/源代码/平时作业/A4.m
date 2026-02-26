% --- MATLAB 案例四：求解非线性方程组 ---

clear; clc; close all;

% 1. 定义非线性方程组
%    输入 x 是一个包含两个元素的向量, x(1) 代表 x1, x(2) 代表 x2
%    输出 F 也是一个包含两个元素的向量, F(1) 代表 f1, F(2) 代表 f2
fun = @(x) [
    exp(-exp(-(x(1) + x(2)))) - x(2) * (1 + x(1)^2);
    x(1) * cos(x(2)) + x(2) * sin(x(1)) - 0.5
];

% 2. 设置求解的初始猜测点
x0 = [0.5, 0.5];

% 3. 设置求解器选项 (可选)
%    'Display', 'off' 表示不显示详细的迭代过程
options = optimoptions('fsolve', 'Display', 'off');

% 4. 调用 fsolve 函数进行求解
%    x_sol 是找到的解
%    fval 是在解 x_sol 处的函数值 F(x_sol)，理论上应接近 [0, 0]
[x_sol, fval, exitflag, output] = fsolve(fun, x0, options);

% 5. 检查求解结果并显示
fprintf('--- 非线性方程组求解结果 ---\n');
if exitflag > 0
    fprintf('成功找到解！\n');
    fprintf('初始猜测点 x0 = [%.4f, %.4f]\n', x0(1), x0(2));
    fprintf('方程组的解 x_sol = [%.6f, %.6f]\n', x_sol(1), x_sol(2));
    fprintf('在解处的函数值 fval = [%.3e, %.3e]\n', fval(1), fval(2));
    fprintf('残差的范数 ||fval|| = %.3e\n', norm(fval));
    fprintf('迭代次数: %d\n', output.iterations);
else
    fprintf('求解失败或未收敛。\n');
end

% 6. 可视化方程组和解
figure('Name', '非线性方程组及其解的可视化');
hold on;

% 使用 fimplicit 绘制两个方程各自的曲线 (即它们等于0时的轨迹)
fimplicit(@(x1,x2) exp(-exp(-(x1+x2))) - x2.*(1+x1.^2), [-2, 2, -2, 2], 'b-', 'LineWidth', 1.5, 'DisplayName', 'f_1(x_1,x_2) = 0');
fimplicit(@(x1,x2) x1.*cos(x2) + x2.*sin(x1) - 0.5, [-2, 2, -2, 2], 'r--', 'LineWidth', 1.5, 'DisplayName', 'f_2(x_1,x_2) = 0');

% 标记初始点和找到的解
plot(x0(1), x0(2), 'gp', 'MarkerSize', 12, 'MarkerFaceColor', 'g', 'DisplayName', '初始点 x0');
if exitflag > 0
    plot(x_sol(1), x_sol(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'DisplayName', '数值解 x_{sol}');
end

% 设置图形属性
title('非线性方程组的解');
xlabel('x_1');
ylabel('x_2');
legend('show', 'Location', 'northwest');
grid on;
axis equal;
hold off;