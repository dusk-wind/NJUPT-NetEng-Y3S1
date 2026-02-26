% --- MATLAB 案例五：遗传算法求解函数最值 ---

clear; clc; close all;

% 1. 定义目标函数 (二维 Styblinski-Tang 函数)
%    输入 x 是一个包含 x(1) 和 x(2) 的向量
fun = @(x) 0.5 * ( (x(1)^4 - 16*x(1)^2 + 5*x(1)) + ...
                   (x(2)^4 - 16*x(2)^2 + 5*x(2)) );

% 2. 设置遗传算法的参数
nvars = 2;             % 变量个数
lb = [-5, -5];         % 变量下界
ub = [5, 5];           % 变量上界

% 3. 设置优化选项
%    'PlotFcn', @gaplotbestf 可以在算法运行时动态绘制最优适应度值的变化曲线
options = optimoptions('ga', 'Display', 'iter', 'PlotFcn', @gaplotbestf);

% 4. 调用 ga 函数进行求解
%    rng(1) 确保每次运行结果可复现
rng(1); 
[x_sol, fval, exitflag, output] = ga(fun, nvars, [], [], [], [], lb, ub, [], options);

% 5. 显示优化结果
fprintf('\n--- 遗传算法优化结果 ---\n');
if exitflag > 0
    fprintf('优化成功！\n');
    fprintf('找到的最小值点 x_sol = [%.6f, %.6f]\n', x_sol(1), x_sol(2));
    fprintf('对应的函数最小值 fval = %.6f\n', fval);
    fprintf('迭代代数: %d\n', output.generations);
else
    fprintf('优化未收敛或达到最大迭代次数。\n');
end

% 6. 可视化目标函数的三维曲面和找到的最优解
figure('Name', 'Styblinski-Tang 函数及GA找到的最优解');
% 创建网格
[X1, X2] = meshgrid(linspace(-5, 5, 100));
% 计算每个点的函数值
Z = 0.5 * ( (X1.^4 - 16*X1.^2 + 5*X1) + (X2.^4 - 16*X2.^2 + 5*X2) );

% 绘制三维曲面
surf(X1, X2, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
hold on;
colormap('jet');
colorbar;

% 在曲面上标记找到的最优解
plot3(x_sol(1), x_sol(2), fval, 'rp', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
legend('Styblinski-Tang 函数曲面', 'GA 找到的全局最优解', 'Location', 'best');

title('遗传算法寻找全局最小值');
xlabel('x_1');
ylabel('x_2');
zlabel('f(x_1, x_2)');
grid on;
view(-30, 45); % 调整视角