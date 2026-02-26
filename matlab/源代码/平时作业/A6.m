% --- MATLAB 案例六：基于傅里-叶变换的信号去噪 (完整修正版) ---

clear; clc; close all;

% 1. 生成原始信号
Fs = 1000;          % 采样频率 (Hz)
T = 1/Fs;           % 采样周期 (秒)
L = 1000;           % 信号长度 (样本数)
t = (0:L-1)*T;      % 时间向量 (秒)

f_signal = 50;      % 原始信号频率 (Hz)
x = 0.7*sin(2*pi*f_signal*t);  % 纯净的原始信号

% 2. 添加高斯白噪声
noise_level = 0.5;  % 噪声强度
noise = noise_level * randn(size(t)); % 生成噪声
x_noisy = x + noise;            % 带噪信号

% 3. 对带噪信号进行傅里叶变换
Y = fft(x_noisy);               % Y 是包含双边频谱的复数向量

% 4. 计算用于绘图的单边频谱
P2 = abs(Y/L);                  % 计算双边频谱的幅度
P1 = P2(1:L/2+1);               % 提取单边频谱
P1(2:end-1) = 2*P1(2:end-1);    % 调整幅度 (除直流和奈奎斯特频率外)
f = Fs*(0:(L/2))/L;             % 构建对应的频率向量

% 5. 设计理想低通滤波器并应用于双边频谱
cutoff_frequency = 100;      % 设置截止频率 (Hz)

% 在单边频率向量 f 中找到截止频率对应的索引
cutoff_index = find(f >= cutoff_frequency, 1);

% 创建一个与双边频谱 Y 同样大小的全零滤波器
H_double_sided = zeros(size(Y));

% 对正频率部分应用滤波器 (让低频通过)
H_double_sided(1:cutoff_index) = 1;

% 利用傅里叶变换的对称性，对负频率部分也应用滤波器
% FFT结果中，后半部分 (从 L-cutoff_index+2 开始) 对应负频率
H_double_sided(L - cutoff_index + 2 : end) = 1;

% 6. 在频域中进行滤波
%    将带噪信号的频谱 Y 与我们设计的滤波器 H_double_sided 进行点乘
Y_filtered = Y .* H_double_sided;

% 7. 将滤波后的频谱进行傅里叶反变换，得到去噪后的时域信号
x_filtered = ifft(Y_filtered);

% 8. 结果可视化
% --- 绘制时域信号对比图 ---
figure('Name', '信号去噪效果对比 (时域)');

subplot(3, 1, 1);
plot(t, x, 'b');
title('原始纯净信号');
xlabel('时间 (秒)');
ylabel('幅度');
grid on;

subplot(3, 1, 2);
plot(t, x_noisy, 'r');
title(['带噪信号 (噪声强度 = ', num2str(noise_level), ')']);
xlabel('时间 (秒)');
ylabel('幅度');
grid on;

subplot(3, 1, 3);
plot(t, real(x_filtered), 'g'); % 取实部，因为反变换可能引入极小的数值误差虚部
title(['去噪后的信号 (截止频率 = ', num2str(cutoff_frequency), ' Hz)']);
xlabel('时间 (秒)');
ylabel('幅度');
grid on;

% --- 绘制频域信号对比图 ---
figure('Name', '信号频谱分析');

% 绘制带噪信号的频谱
subplot(2, 1, 1);
plot(f, P1);
title('带噪信号的频谱');
xlabel('频率 (Hz)');
ylabel('幅度 |P1(f)|');
grid on;
xlim([0, Fs/2]); % 只显示到奈奎斯特频率

% 绘制滤波后信号的频谱
P2_filtered = abs(Y_filtered/L);
P1_filtered = P2_filtered(1:L/2+1);
P1_filtered(2:end-1) = 2*P1_filtered(2:end-1);
subplot(2, 1, 2);
plot(f, P1_filtered);
title('滤波后的信号频谱');
xlabel('频率 (Hz)');
ylabel('幅度 |P1(f)|');
grid on;
xlim([0, Fs/2]);