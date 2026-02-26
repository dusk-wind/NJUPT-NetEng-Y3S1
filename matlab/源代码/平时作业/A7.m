% --- MATLAB 案例七：基于PCA的图像压缩 ---

clear; clc; close all;

% 1. 读取并预处理图像
%    MATLAB 自带了一张名为 'peppers.png' 的标准测试图像
try
    img_rgb = imread('peppers.png');
catch
    error('无法找到图像文件 "peppers.png"。请确保图像文件在MATLAB路径中。');
end

img_gray = rgb2gray(img_rgb);    % 转换为灰度图像
X = im2double(img_gray);         % 转换为 double 类型，数值范围 [0, 1]

% 2. 执行 PCA
%    pca 函数会自动处理数据中心化
[coeff, score, latent] = pca(X);

% 3. 设置不同的压缩率 (保留的主成分数量 k)
k_values = [10, 50, 100]; % 选择保留 10, 50, 100 个主成分

% 4. 可视化结果
figure('Name', '基于PCA的图像压缩与重建', 'Position', [100, 100, 1200, 400]);

% 显示原始图像
subplot(1, length(k_values) + 1, 1);
imshow(X);
[rows, cols] = size(X);
title(['原始图像 (', num2str(rows), 'x', num2str(cols), ')']);

% 循环处理不同的 k 值
for i = 1:length(k_values)
    k = k_values(i);
    
    % --- 压缩与重建 ---
    % 压缩: 只保留前 k 个主成分的得分
    compressed_score = score(:, 1:k);
    
    % 重建: 将压缩后的得分通过前 k 个主成分系数反向投影
    %        pca 函数返回的 coeff 已经是转置好的，可以直接乘
    %        pca 函数内部已经处理了均值，所以重建时它会自动加回去
    X_reconstructed = compressed_score * coeff(:, 1:k)';
    
    % pca 函数在计算时减去了均值，重建时需要加回来
    % (新版本的 pca 内部处理得很好，但为了兼容性，手动加均值更稳妥)
    % 注：新版 MATLAB 的 pca 重建公式是 score * coeff' + repmat(mean(X), size(X,1), 1)
    % 为了简单起见，我们直接用 score 和 coeff 来重建
    X_reconstructed = X_reconstructed + repmat(mean(X, 1), rows, 1);
    
    % --- 计算压缩率 ---
    % 原始数据存储量: rows * cols
    % 压缩后数据存储量: rows*k (score) + k*cols (coeff) + cols (mean)
    original_storage = rows * cols;
    compressed_storage = rows * k + k * cols + cols;
    compression_ratio = original_storage / compressed_storage;

    % 显示重建图像
    subplot(1, length(k_values) + 1, i + 1);
    imshow(X_reconstructed);
    title(['k = ', num2str(k), ' (压缩率 ≈ ', num2str(round(compression_ratio)), ':1)']);
end