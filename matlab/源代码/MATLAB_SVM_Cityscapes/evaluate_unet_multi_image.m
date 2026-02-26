% =========================================================================
% U-Net 模型单图深度分析脚本 (v5.0 - 最终交付版)
%
% 描述:
%   此脚本专注于对 Cityscapes 数据集中的单张指定图片进行完整的
%   评估和可视化。它会加载原始图、官方彩色标签图和用于计算的
%   ID标签图，然后将模型的预测结果与官方结果进行清晰的 2x2 对比。
% =========================================================================
clear; clc; close all;

%% 1. 配置参数 (请根据您的环境修改)
% -------------------------------------------------------------------------
% --- 1a. 模型与数据集路径 ---
model_path = 'unet_full_dataset_model.mat';
dataset_root_dir = 'D:\AAAAA\erfnet_pytorch-master\dataset';

% --- 1b. 指定要分析的图片 ---
image_base_name = 'frankfurt_000000_003357'; % <--- 您指定的图片

% --- 1c. 模型输入尺寸 ---
imageResizeFactor = [256, 512];

%% 2. 加载预训练的 U-Net 模型
% -------------------------------------------------------------------------
fprintf('正在从 %s 加载 U-Net 模型...\n', model_path);
if ~exist(model_path, 'file'), error('模型文件 %s 未找到！', model_path); end
model_data = load(model_path);
model_field_names = fieldnames(model_data);
loaded_model = model_data.(model_field_names{1});
fprintf('模型加载成功！\n\n');

%% 3. 加载指定的图片和标签
% -------------------------------------------------------------------------
fprintf('正在加载指定图片: %s\n', image_base_name);

% --- 3a. 构建三个核心文件的完整路径 ---
% 1. 原始图像 (用于输入模型)
original_image_path = fullfile(dataset_root_dir, 'leftImg8bit', 'val', 'frankfurt', [image_base_name, '_leftImg8bit.png']);
% 2. 官方彩色标签图 (用于可视化对比)
ground_truth_color_path = fullfile(dataset_root_dir, 'gtFine', 'val', 'frankfurt', [image_base_name, '_gtFine_color.png']);
% 3. ID 标签图 (用于计算准确率)
ground_truth_ids_path = fullfile(dataset_root_dir, 'gtFine', 'val', 'frankfurt', [image_base_name, '_gtFine_labelTrainIds.png']);

% --- 3b. 读取所有文件 ---
if ~isfile(original_image_path), error('原始图片未找到: %s', original_image_path); end
if ~isfile(ground_truth_color_path), error('官方彩色标签图未找到: %s', ground_truth_color_path); end
if ~isfile(ground_truth_ids_path), error('ID 标签图未找到: %s', ground_truth_ids_path); end

originalImg = imread(original_image_path);
groundTruthColor = imread(ground_truth_color_path);
groundTruthIds = imread(ground_truth_ids_path);

fprintf('所有相关文件加载成功！\n');

% --- 3c. 调整尺寸以匹配模型和可视化 ---
testImgResized = imresize(originalImg, imageResizeFactor);
groundTruthColorResized = imresize(groundTruthColor, imageResizeFactor, 'nearest'); % 'nearest' 保持颜色不失真
groundTruthIdsResized = imresize(groundTruthIds, imageResizeFactor, 'nearest');   % 'nearest' 保持ID值正确

%% 4. 使用 U-Net 模型进行预测
% -------------------------------------------------------------------------
fprintf('正在使用 U-Net 模型进行预测...\n');
tic;
pxdsResults = semanticseg(testImgResized, loaded_model);
% U-Net 输出类别从1开始，Cityscapes trainId 从0开始，故减1对齐
predictedMask_raw = uint8(pxdsResults) - 1; 
predictionTime = toc;
fprintf('分割完成！耗时: %.2f 秒\n', predictionTime);

%% 5. 后处理优化 (中值滤波)
% -------------------------------------------------------------------------
fprintf('正在对预测结果进行中值滤波优化...\n');
predictedMask_final = medfilt2(predictedMask_raw, [5 5]);

%% 6. 计算准确率
% -------------------------------------------------------------------------
% 确定有效像素区域 (忽略ID为255的像素)
validIdx = groundTruthIdsResized ~= 255;
totalValidPixels = sum(validIdx, 'all');

% 计算原始预测和优化后预测的准确率
acc_raw = sum(predictedMask_raw(validIdx) == groundTruthIdsResized(validIdx)) / totalValidPixels;
acc_final = sum(predictedMask_final(validIdx) == groundTruthIdsResized(validIdx)) / totalValidPixels;

fprintf('\n--- 模型评估结果 ---\n');
fprintf('  - 原始预测准确率 (有效像素): %.2f%%\n', acc_raw * 100);
fprintf('  - 中值滤波优化后准确率 (有效像素): %.2f%%\n', acc_final * 100);

%% 7. 可视化最终结果 (2x2 布局)
% -------------------------------------------------------------------------
fprintf('正在生成最终对比图像...\n');

% 获取用于显示模型预测结果的颜色图
cmap = cityscapes_trainid_colormap();

% 将模型的预测结果 (ID) 转换为彩色图像用于显示
% 注意：label2rgb需要1-based索引，而我们的ID是0-based，所以+1
predictedRGB_raw = label2rgb(predictedMask_raw + 1, cmap);
predictedRGB_final = label2rgb(predictedMask_final + 1, cmap);

% --- 创建并填充 2x2 图窗 ---
figure('Name', ['U-Net Final Analysis: ', image_base_name], 'Position', [50, 50, 1200, 900]);

% 1. 左上角: 原始测试图片
subplot(2, 2, 1);
imshow(testImgResized);
title('原始图片 (模型输入)');

% 2. 右上角: 官方彩色标准答案
subplot(2, 2, 2);
imshow(groundTruthColorResized);
title('官方标准答案 (彩色标签)');

% 3. 左下角: 模型的原始预测结果
subplot(2, 2, 3);
imshow(predictedRGB_raw);
title(sprintf('模型原始预测\nAccuracy: %.2f%%', acc_raw * 100));

% 4. 右下角: 经过中值滤波优化的结果
subplot(2, 2, 4);
imshow(predictedRGB_final);
title(sprintf('中值滤波优化后\nAccuracy: %.2f%%', acc_final * 100));

fprintf('分析完成！请查看弹出的图像窗口。\n');

%% 辅助函数
function cmap = cityscapes_trainid_colormap()
    % Cityscapes 19 个训练类的颜色图
    colors_uint8 = [
        128, 64, 128;   % road (ID 0)
        244, 35, 232;   % sidewalk
        70, 70, 70;     % building
        102, 102, 156;  % wall
        190, 153, 153;  % fence
        153, 153, 153;  % pole
        250, 170, 30;   % traffic_light
        220, 220, 0;    % traffic_sign
        107, 142, 35;   % vegetation
        152, 251, 152;  % terrain
        70, 130, 180;   % sky
        220, 20, 60;    % person
        255, 0, 0;      % rider
        0, 0, 142;      % car
        0, 0, 70;       % truck
        0, 60, 100;     % bus
        0, 80, 100;     % train
        0, 0, 230;      % motorcycle
        119, 11, 32     % bicycle (ID 18)
    ];
    cmap = double(colors_uint8) / 255.0;
end