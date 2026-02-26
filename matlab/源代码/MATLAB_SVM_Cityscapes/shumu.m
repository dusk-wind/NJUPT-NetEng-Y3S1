% =========================================================================
% 终极挑战脚本 (v23.0 - 应对全新复杂图像)
%
% 描述:
%   本脚本将我们最先进的“AI预测 + HSV精修 + Alpha融合”技术，
%   应用到一张全新的、具有复杂背景和内部空隙的树木图片上，
%   以验证该混合智能系统的真实泛化能力。
% =========================================================================
clear; clc; close all;

%% 1. 配置参数
% -------------------------------------------------------------------------
model_path = 'unet_full_dataset_model.mat';
% --- !!! 关键步骤: 请将您的新图片保存在电脑上，并修改下面的路径 !!! ---
original_image_path = "D:\matlab\MATLAB_SVM_Cityscapes\data\image.png"; % <--- 修改这里！
imageResizeFactor = [256, 512];

%% 2. 加载模型与新图片
% -------------------------------------------------------------------------
fprintf('正在加载模型和新图片...\n');
model_data = load(model_path);
all_variable_names = fieldnames(model_data);
loaded_model = model_data.(all_variable_names{1});
if ~isfile(original_image_path), error('新图片未找到，请检查路径！\n路径: %s', original_image_path); end
originalImg = imread(original_image_path);
fprintf('加载完成！\n\n');

%% 3. AI模型预测
% -------------------------------------------------------------------------
fprintf('正在使用U-Net模型进行预测...\n');
testImgResized = imresize(originalImg, imageResizeFactor);
pxdsResults = semanticseg(testImgResized, loaded_model);
predictedMask_raw = uint8(pxdsResults) - 1;
predictedMask_final = medfilt2(predictedMask_raw, [5 5]);
fprintf('AI预测完成！\n\n');

%% 4. 核心后处理：基于HSV空间的智能“雕刻”
% -------------------------------------------------------------------------
fprintf('--- 正在对预测结果进行HSV空间精修后处理 ---\n');

% --- 提取AI预测的植被蒙版 ---
vegetation_id = 8; % Cityscapes trainId for vegetation
model_vegetation_mask = (predictedMask_final == vegetation_id);

% --- 将图片转换为HSV颜色空间进行分析 ---
I_resized_hsv = rgb2hsv(testImgResized);
Saturation = I_resized_hsv(:,:,2); % 饱和度
Value = I_resized_hsv(:,:,3);      % 亮度

% --- 定义需要被挖掉的“非植被”区域的特征 ---
% 这里的阈值是经验值，可能需要微调
% 背景墙体/窗户通常饱和度较低，或亮度较高
background_mask_low_saturation = Saturation < 0.3;
background_mask_high_value = Value > 0.8;
% 卷帘门等灰色区域亮度适中，但饱和度极低
background_mask_very_low_saturation = Saturation < 0.15 & Value < 0.8;
transparent_mask = background_mask_low_saturation | background_mask_high_value | background_mask_very_low_saturation;

% --- 进行雕刻：只在AI预测的植被区域内部，挖掉满足背景特征的像素 ---
mask_vegetation_carved = model_vegetation_mask;
mask_vegetation_carved(transparent_mask & model_vegetation_mask) = 0;

% --- 形态学清理 ---
mask_vegetation_carved_cleaned = bwareaopen(mask_vegetation_carved, 50);
fprintf('HSV“雕刻”后处理完成！\n\n');

%% 5. 艺术升华：Alpha融合
% -------------------------------------------------------------------------
fprintf('--- 正在进行Alpha融合处理 ---\n');
final_result_image = create_final_image_with_alpha(originalImg, mask_vegetation_carved_cleaned);
fprintf('Alpha融合完成！\n\n');

%% 6. 生成最终成果图
% =========================================================================
fprintf('--- 正在生成最终成果对比图 ---\n');
figure('Name', '全新图像分割挑战成果', 'Position', [100, 100, 1600, 600]);

% 左侧：原始图片
subplot(1, 2, 1);
imshow(originalImg);
title('原始图片', 'FontSize', 14);

% 右侧：最终精修分割结果
subplot(1, 2, 2);
imshow(final_result_image);
title('最终分割结果 (AI + HSV精修 + Alpha融合)', 'FontSize', 14, 'Color', 'r', 'FontWeight', 'bold');

fprintf('脚本执行完毕！\n');


%% 辅助函数 (Local Functions)
function output_image = create_final_image_with_alpha(original_image, binary_mask)
    mask_resized = imresize(binary_mask, [size(original_image, 1), size(original_image, 2)], 'nearest');
    sigma = 2; % 羽化宽度可以调小一点，让边缘更清晰
    alpha_mask = imgaussfilt(double(mask_resized), sigma);
    alpha_mask = mat2gray(alpha_mask);
    alpha_mask_rgb = repmat(alpha_mask, 1, 1, 3);
    output_image = uint8(double(original_image) .* alpha_mask_rgb);
end