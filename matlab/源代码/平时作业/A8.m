% --- MATLAB 案例八：洛伦兹（Lorenz）吸引子 ---

clear; clc; close all;

% 1. 定义洛伦兹方程组的参数 (经典混沌参数)
sigma = 10;
rho = 28;
beta = 8/3;

% 2. 定义微分方程组函数
%    该函数接收时间 t 和状态向量 Y = [x; y; z]
%    返回导数向量 dYdt = [dx/dt; dy/dt; dz/dt]
lorenz_eq = @(t, Y) [
    sigma * (Y(2) - Y(1));
    Y(1) * (rho - Y(3)) - Y(2);
    Y(1) * Y(2) - beta * Y(3)
];

% 3. 设置初始条件和求解时间
Y0 = [1.0, 1.0, 1.0];   % 初始状态 [x0, y0, z0]
tspan = [0, 100];      % 求解时间从 0 到 100

% 4. 调用 ode45 求解器
%    options 用于设置求解精度，可以不设置使用默认值
options = odeset('RelTol', 1e-6, 'AbsTol', [1e-6 1e-6 1e-6]);
[T, Y] = ode45(lorenz_eq, tspan, Y0, options);

% 5. 可视化结果
figure('Name', '洛伦兹吸引子', 'Color', 'k'); % 使用黑色背景以突出轨迹
ax = axes('Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w', 'GridColor', 'w');
hold on;

% 绘制三维轨迹
% Y(:,1) 是 x(t), Y(:,2) 是 y(t), Y(:,3) 是 z(t)
plot3(Y(:,1), Y(:,2), Y(:,3), 'c', 'LineWidth', 0.5);

% 标记起点
plot3(Y0(1), Y0(2), Y0(3), 'yo', 'MarkerSize', 10, 'MarkerFaceColor', 'y');

% 设置图形属性
title('洛伦兹吸引子', 'Color', 'w', 'FontSize', 14);
xlabel('x(t)', 'Color', 'w');
ylabel('y(t)', 'Color', 'w');
zlabel('z(t)', 'Color', 'w');
grid on;
view(35, 25); % 设置一个较好的观察视角
axis tight;
hold off;

% 为了展示对初始条件的敏感性 (可选，但非常推荐)
figure('Name', '蝴蝶效应：初始条件的敏感性');
hold on;
Y0_perturbed = [1.0, 1.0, 1.00001]; % 对 z 施加一个极小的扰动
[T2, Y2] = ode45(lorenz_eq, tspan, Y0_perturbed, options);
plot3(Y(:,1), Y(:,2), Y(:,3), 'c-', 'DisplayName', '初始轨迹');
plot3(Y2(:,1), Y2(:,2), Y2(:,3), 'm-', 'DisplayName', '扰动后的轨迹');
title('初始条件的敏感性（蝴蝶效应）');
xlabel('x(t)'); ylabel('y(t)'); zlabel('z(t)');
legend;
view(35, 25);
grid on;