% 蒙特卡洛积分
N = 2e6;   %采样点数
x1 = 3 * rand(N,1);
x2 = 2*3*rand(N,1);    % 先生成大范围，后筛选
x3 = 2*(3*6)*rand(N,1);

% 真实条件筛选
mask = (x2 >= x1 & x2 <= 2*x1 & ...
        x3 >= x1.*x2 & x3 <= 2*x1.*x2);

x1v = x1(mask);
x2v = x2(mask);
x3v = x3(mask);

f = x1v .* x2v .* x3v;

% 蒙特卡洛体积（区域体积需要估计）
V_box = 3 * (6) * (36);   % 外包立方体体积

tic
I2 = mean(f) * V_box * (length(x1v)/N);
t2 = toc;

fprintf("蒙特卡洛积分结果: %.6f\n", I2);
fprintf("计算时间: %.6f 秒\n", t2);