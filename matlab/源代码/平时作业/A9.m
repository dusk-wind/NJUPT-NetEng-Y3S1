% --- MATLAB 案例九：单摆模型的解析解与数值解对比 (修正版) ---

clear; clc; close all;

% 1. 定义模型参数
g = 9.81; % 重力加速度 (m/s^2)
L = 1.0;  % 摆长 (m)
omega0_sq = g/L; % 角频率的平方 (omega_0^2)

% 2. 初始条件
%    我们将对比小角度和大角度两种情况
theta0_small_deg = 10; % 初始角度 (小角度: 10度)
theta0_large_deg = 60; % 初始角度 (大角度: 60度)
theta0_small_rad = deg2rad(theta0_small_deg); % 转换为弧度
theta0_large_rad = deg2rad(theta0_large_deg); % 转换为弧度
dtheta0 = 0;                  % 初始角速度 (从静止释放)

% 3. 求解时间范围
t_span = [0, 10]; % 求解 0 到 10 秒
t_eval = linspace(t_span(1), t_span(2), 500); % 定义输出时间点

% --- 求解线性化模型的解析解 ---
syms t
% 小角度情况
theta_analytical_small_rad = theta0_small_rad * cos(sqrt(omega0_sq) * t);
% 大角度情况 (使用线性模型，但代入大角度初始值)
theta_analytical_large_rad = theta0_large_rad * cos(sqrt(omega0_sq) * t);

% 将符号表达式转换为可计算的数值
theta_analytical_small_deg_vals = double(subs(theta_analytical_small_rad, t, t_eval)) * (180/pi);
theta_analytical_large_deg_vals = double(subs(theta_analytical_large_rad, t, t_eval)) * (180/pi);


% --- 求解非线性模型的数值解 ---
% 定义一阶ODE组
ode_nonlinear_fun = @(t, y) [y(2); -omega0_sq * sin(y(1))];

% 求解小角度情况
[T_small, Y_small] = ode45(ode_nonlinear_fun, t_eval, [theta0_small_rad, dtheta0]);
theta_numerical_small_deg = Y_small(:, 1) * (180/pi); % 提取角度并转为度

% 求解大角度情况
[T_large, Y_large] = ode45(ode_nonlinear_fun, t_eval, [theta0_large_rad, dtheta0]);
theta_numerical_large_deg = Y_large(:, 1) * (180/pi); % 提取角度并转为度

% --- 4. 可视化对比 ---
figure('Name', '单摆模型的解析解与数值解对比', 'Position', [100, 100, 1200, 500]);

% --- 小角度对比图 ---
subplot(1, 2, 1);
hold on;
plot(t_eval, theta_analytical_small_deg_vals, 'r-', 'LineWidth', 2, 'DisplayName', '解析解 (线性模型)');
plot(T_small, theta_numerical_small_deg, 'b--', 'LineWidth', 2, 'DisplayName', '数值解 (非线性模型)');
title(['小角度初始条件 (\theta_0 = ', num2str(theta0_small_deg), '^\circ)']);
xlabel('时间 (s)');
ylabel('摆角 (\circ)');
legend('show', 'Location', 'southwest');
grid on;

% --- 大角度对比图 ---
subplot(1, 2, 2);
hold on;
plot(t_eval, theta_analytical_large_deg_vals, 'r-', 'LineWidth', 2, 'DisplayName', '解析解 (线性模型)');
plot(T_large, theta_numerical_large_deg, 'b--', 'LineWidth', 2, 'DisplayName', '数值解 (非线性模型)');
title(['大角度初始条件 (\theta_0 = ', num2str(theta0_large_deg), '^\circ)']);
xlabel('时间 (s)');
ylabel('摆角 (\circ)');
legend('show', 'Location', 'southwest');
grid on;