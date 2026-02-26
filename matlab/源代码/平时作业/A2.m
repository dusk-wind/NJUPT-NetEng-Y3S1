% --- MATLAB 案例二：蒙特卡洛法求圆周率 π ---

clear; clc; close all; % 清理工作区和图形

% 1. 设置模拟参数
N = 5000; % 投掷的总点数，可以尝试增加该值以提高精度

% 2. 生成随机点
%    rand(N, 1) 生成 N 行 1 列的 [0, 1] 之间的随机数
%    2 * rand(N, 1) - 1 将其范围映射到 [-1, 1]
x = 2 * rand(N, 1) - 1;
y = 2 * rand(N, 1) - 1;

% 3. 判断点是否在圆内
%    计算每个点到原点距离的平方 (避免使用 sqrt, 提高效率)
dist_sq = x.^2 + y.^2;

%    使用逻辑索引找到在圆内和圆外的点
inside_mask = dist_sq <= 1;
outside_mask = ~inside_mask; % ~ 表示逻辑“非”

%    统计圆内点的数量
N_circle = sum(inside_mask);

% 4. 估算 pi 值
pi_estimate = 4 * N_circle / N;

% 5. 在命令窗口显示结果
fprintf('--- 蒙特卡洛模拟求 π ---\n');
fprintf('总投点数 N = %d\n', N);
fprintf('落入圆内点数 N_circle = %d\n', N_circle);
fprintf('估算的 π 值 ≈ %.6f\n', pi_estimate);
fprintf('MATLAB 内置的 π 值 = %.6f\n', pi);
fprintf('误差 = %.6f\n', abs(pi_estimate - pi));

% 6. 可视化模拟过程
figure('Name', '蒙特卡洛法求 π 模拟过程');
% 绘制圆外的点 (蓝色)
plot(x(outside_mask), y(outside_mask), 'b.', 'MarkerSize', 5);
hold on;
% 绘制圆内的点 (红色)
plot(x(inside_mask), y(inside_mask), 'r.', 'MarkerSize', 5);

% 绘制正方形和圆形边界
rectangle('Position', [-1, -1, 2, 2], 'EdgeColor', 'k', 'LineWidth', 1.5);
theta = linspace(0, 2*pi, 200);
plot(cos(theta), sin(theta), 'g-', 'LineWidth', 2);

% 设置图形属性
axis equal; % 使 x 和 y 轴比例相同，确保圆形不失真
grid on;
title(['蒙特卡洛模拟 (N = ', num2str(N), '),  \pi \approx ', num2str(pi_estimate)]);
xlabel('x 坐标');
ylabel('y 坐标');
legend('圆外点', '圆内点', '边界');
hold off;