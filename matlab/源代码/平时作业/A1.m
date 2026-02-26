% --- MATLAB 案例一：二维高斯函数的数值积分 ---

% 1. 定义被积函数
%    使用匿名函数定义 f(x,y) = exp(-(x^2+y^2))
%    注意使用点运算符 (.*, .^)，以确保函数能够处理向量输入
fun = @(x,y) exp(-x.^2 - y.^2);

% 2. 定义积分区域
%    对于圆形区域 x^2+y^2 <= 1:
%    x 的范围是 [-1, 1]
%    y 的范围是 [-sqrt(1-x^2), sqrt(1-x^2)]
xmin = -1;
xmax = 1;
ymin = @(x) -sqrt(1 - x.^2); % y 的下限是 x 的函数
ymax = @(x) sqrt(1 - x.^2);  % y 的上限是 x 的函数

% 3. 调用 integral2 函数进行数值计算
%    函数会自适应地选择步长以达到预设的精度
I = integral2(fun, xmin, xmax, ymin, ymax);

% 4. 在命令窗口显示计算结果
fprintf('二维高斯函数在单位圆内的数值积分结果 I = %.6f\n', I);

% 5. 可视化被积函数和积分区域
figure('Name', '二维高斯函数及积分区域'); % 创建一个新图形窗口并命名

% 创建用于绘图的网格
[X, Y] = meshgrid(-1.5:0.1:1.5, -1.5:0.1:1.5);
Z = exp(-X.^2 - Y.^2);

% 绘制三维曲面
surf(X, Y, Z);
colormap('winter'); % 设置颜色映射
colorbar;           % 显示颜色条
title('函数 f(x,y) = exp(-x^2-y^2) 的三维曲面');
xlabel('x轴');
ylabel('y轴');
zlabel('f(x,y)');
hold on; % 保持当前图形，以便在其上添加新元素

% 在 xy 平面上绘制红色的圆形积分区域边界
theta = linspace(0, 2*pi, 100); % 0到2*pi的100个角度
x_circle = cos(theta);
y_circle = sin(theta);
z_circle = zeros(size(theta)); % 高度为0，表示在xy平面上
plot3(x_circle, y_circle, z_circle, 'r-', 'LineWidth', 2.5);

legend('函数曲面', '积分区域边界 D');
axis equal; % 使坐标轴比例相等，圆形看起来更圆
grid on;
hold off; % 结束在当前图形上绘图