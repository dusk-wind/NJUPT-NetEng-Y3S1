function A10
% --- MATLAB 案例十：边值问题（BVP）求解 - 悬链线问题 (最终完美运行版) ---

% 清理工作区和图形
clear; clc; close all;

% --- 求解场景一：较紧的链条 ---
a1 = 2; % 设定参数 a (a 越大，链条越紧，下垂越少)
fprintf('--- 场景一：求解 a = %.1f 的情况 ---\n', a1);

% 1. 定义一个与参数 a 相关的 ODE 函数句柄
odefun1 = @(x, y) catenary_ode(x, y, a1);

% 2. 创建初始猜测
%    对于 y(x) 的初始猜测，使用连接端点的直线
%    对于 y'(x) 的初始猜测，使用直线的斜率
x_init = linspace(0, 2, 10);

% *** 关键修正 ***
%    确保函数的每一行都返回与输入 x 相同大小的向量
yinit_fun = @(x) [
    1 + 0.5 * x;             % y(x)的猜测, 结果是 1xN 向量
    0.5 * ones(size(x))      % y'(x)的猜测, 结果是 1xN 向量
];

solinit = bvpinit(x_init, yinit_fun);

% 3. 调用 bvp4c 求解器
sol1 = bvp4c(odefun1, @catenary_bc, solinit);

% --- 求解场景二：较松的链条 ---
a2 = 0.8; % 设定一个较小的 a (a 越小，链条越松，下垂越多)
fprintf('--- 场景二：求解 a = %.1f 的情况 ---\n', a2);
odefun2 = @(x, y) catenary_ode(x, y, a2);
sol2 = bvp4c(odefun2, @catenary_bc, solinit); % 可以复用相同的初始猜测

% --- 4. 提取并可视化结果 ---
x_plot = linspace(0, 2, 100);
y_plot1 = deval(sol1, x_plot); % 提取场景一的解
y_plot2 = deval(sol2, x_plot); % 提取场景二的解

figure('Name', '悬链线 BVP 求解结果');
hold on;
box on;

% 绘制两个场景的解
plot(x_plot, y_plot1(1,:), 'b-', 'LineWidth', 2.5, 'DisplayName', ['悬链线 (a = ', num2str(a1), ')']);
plot(x_plot, y_plot2(1,:), 'g-', 'LineWidth', 2.5, 'DisplayName', ['悬链线 (a = ', num2str(a2), ')']);

% 绘制固定端点和初始猜测
plot([0, 2], [1, 2], 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', '固定端点');
y_guess_plot = yinit_fun(x_plot);
plot(x_plot, y_guess_plot(1,:), 'k--', 'DisplayName', '初始猜测');

title('不同参数下的悬链线形状');
xlabel('水平位置 x');
ylabel('垂直高度 y');
legend('show', 'Location', 'best');
grid on;
axis equal; % 保持 x, y 轴比例一致

hold off;

end % --- 主函数 A10 结束 ---


% --- 以下是局部函数定义 ---

% 定义微分方程组
% y(1)=y, y(2)=y'
% 参数 a 现在作为额外参数传入
function dydx = catenary_ode(x, y, a)
    dydx = [
        y(2);                      % y1' = y2
        sqrt(1 + y(2)^2) / a       % y2' = sqrt(1+y2^2)/a
    ];
end

% 定义边界条件
% ya 是左边界的值 [y(0), y'(0)]
% yb 是右边界的值 [y(2), y'(2)]
% 这个函数不再需要处理参数 a
function res = catenary_bc(ya, yb)
    res = [
        ya(1) - 1;   % 左边界条件: y(0) - 1 = 0
        yb(1) - 2    % 右边界条件: y(2) - 2 = 0
    ];
end