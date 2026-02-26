% --- MATLAB 案例三：函数插值与拟合对比 ---

clear; clc; close all;

% 1. 生成原始数据
%    从 sin(x) 函数上采样10个点
x_sample = linspace(0, 2*pi, 10);
%    加入一些随机噪声来模拟真实测量数据
noise_level = 0.15;
y_sample = sin(x_sample) + noise_level * randn(size(x_sample));

% 2. 定义用于绘图的更密集的 x 坐标
x_dense = linspace(0, 2*pi, 200);

% --- 方法一：样条插值 ---
% 使用 interp1 函数，'spline' 方法
y_interp = interp1(x_sample, y_sample, x_dense, 'spline');

% --- 方法二：多项式拟合 ---
% 使用 polyfit 寻找一个3阶多项式来拟合数据
degree = 3; % 定义多项式阶数
p_coeffs = polyfit(x_sample, y_sample, degree);
% 使用 polyval 计算拟合曲线在密集点上的值
y_fit = polyval(p_coeffs, x_dense);

% 4. 可视化对比结果
figure('Name', '插值与拟合的效果对比');
hold on;

% 绘制带噪声的原始采样点
plot(x_sample, y_sample, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'DisplayName', '带噪声的采样点');

% 绘制真实的 sin(x) 函数曲线作为参考
plot(x_dense, sin(x_dense), 'g--', 'LineWidth', 2, 'DisplayName', '真实函数 sin(x)');

% 绘制样条插值曲线
plot(x_dense, y_interp, 'r-', 'LineWidth', 2, 'DisplayName', '样条插值曲线');

% 绘制多项式拟合曲线
plot(x_dense, y_fit, 'b-.', 'LineWidth', 2, 'DisplayName', [num2str(degree), '阶多项式拟合曲线']);

% 设置图形属性
title('插值 (Interpolation) vs 拟合 (Fitting)');
xlabel('x');
ylabel('y');
legend('Location', 'best');
grid on;
ylim([-1.5, 1.5]); % 设置 y 轴范围，使视图更集中
hold off;