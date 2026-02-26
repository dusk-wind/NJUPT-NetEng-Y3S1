% =========================================================================
% 最终答辩王牌脚本 (v25.0 - 单类别终极纯净版)
%
% 描述:
%   本脚本旨在以最清晰、最纯净的方式，单独展示对每一个目标类别的
%   分割成果，不进行任何边缘羽化。
%   核心亮点：对“植被”类别应用了最先进的“双重净化”后处理算法。
%   最终生成一个 2x2 的对比图。
% =========================================================================
clear; clc; close all;

%% 1. 配置参数
% -------------------------------------------------------------------------
model_path = 'unet_full_dataset_model1.mat';
original_image_path = 'D:\matlab\MATLAB_SVM_Cityscapes\data\images\aachen_000099_000019_leftImg8bit.png';
imageResizeFactor = [256, 512];

% --- 定义目标ID ---
building_id = 2;
vegetation_id = 8;
car_id = 13;

%% 2. 加载模型与数据
% -------------------------------------------------------------------------
fprintf('正在加载模型和图片...\n');
model_data = load(model_path);
all_variable_names = fieldnames(model_data);
loaded_model = model_data.(all_variable_names{1});
originalImg = imread(original_image_path);
fprintf('加载完成！\n\n');

%% 3. AI模型预测
% -------------------------------------------------------------------------
fprintf('正在使用U-Net模型进行预测...\n');
testImgResized = imresize(originalImg, imageResizeFactor);
pxdsResults = semanticseg(testImgResized, loaded_model);
predictedMask_raw = uint8(pxdsResults) - 1;
predictedMask_final = medfilt2(predictedMask_raw, [5 5]);
fprintf('预测完成！\n\n');

%% 4. 核心后处理：对每个类别进行独立的、最恰当的精修
% -------------------------------------------------------------------------
fprintf('--- 正在对每个类别进行独立的精修后处理 ---\n');

% --- 步骤 4a: 精修“建筑” (简单的形态学清理) ---
mask_building_raw = (predictedMask_final == building_id);
se_building = strel('disk', 2);
mask_building_cleaned = imopen(mask_building_raw, se_building);
fprintf('建筑部分精修完成。\n');

% --- 步骤 4b: 精修“车辆” (简单的形态学清理) ---
mask_car_raw = (predictedMask_final == car_id);
se_car = strel('disk', 2);
mask_car_cleaned = imopen(mask_car_raw, se_car);
fprintf('车辆部分精修完成。\n');

% --- 步骤 4c: (核心) 对“植被”进行双重净化 ---
% i. 提取原始植被蒙版
mask_vegetation_raw = (predictedMask_final == vegetation_id);
% ii. 天空探测器剔除
I_resized = testImgResized;
I_gray = rgb2gray(I_resized);
blue_channel = I_resized(:,:,3);
sky_detector_mask = I_gray > 170 & blue_channel > 140;
mask_vegetation_after_sky_removal = mask_vegetation_raw;
pixels_to_remove = sky_detector_mask & mask_vegetation_raw;
mask_vegetation_after_sky_removal(pixels_to_remove) = 0;
% iii. 形态学终极清理
se_veg = strel('disk', 2); 
mask_vegetation_final_cleaned = imopen(mask_vegetation_after_sky_removal, se_veg);
fprintf('植被部分已完成双重净化。\n\n');

%% 5. 将蒙版应用到原始图片上 (无Alpha融合)
% =========================================================================
fprintf('--- 正在将最终蒙版应用到原始图片 ---\n');

final_building_image = apply_mask_to_image(originalImg, mask_building_cleaned);
final_car_image = apply_mask_to_image(originalImg, mask_car_cleaned);
final_vegetation_image = apply_mask_to_image(originalImg, mask_vegetation_final_cleaned);
fprintf('已生成所有类别的最终图像。\n\n');

%% 6. 生成最终的 2x2 成果展示图
% =========================================================================
fprintf('--- 正在生成最终的 2x2 成果展示图 ---\n');
figure('Name', '单类别终极纯净分割成果', 'Position', [50, 50, 1600, 1000]);

% --- 左上：原始图片 ---
subplot(2, 2, 1);
imshow(originalImg);
title('原始图片', 'FontSize', 14);

% --- 右上：仅显示精修后的建筑 ---
subplot(2, 2, 2);
imshow(final_building_image);
title('仅分离: 精修建筑', 'FontSize', 14);

% --- 左下：仅显示精修后的车辆 ---
subplot(2, 2, 3);
imshow(final_car_image);
title('仅分离: 精修车辆', 'FontSize', 14);

% --- 右下：仅显示精修后的植被 ---
subplot(2, 2, 4);
imshow(final_vegetation_image);
title('仅分离: 精修植被 (双重净化)', 'FontSize', 14, 'Color', 'r', 'FontWeight', 'bold');

fprintf('脚本执行完毕！请查看最终的成果展示图。\n');

%% 辅助函数 (Local Functions)
% =========================================================================
function output_image = apply_mask_to_image(original_image, binary_mask)
    % 辅助函数，用于将二值蒙版应用到原始图片
    mask_resized = imresize(binary_mask, [size(original_image, 1), size(original_image, 2)], 'nearest');
    mask_rgb = repmat(mask_resized, 1, 1, 3);
    output_image = zeros(size(original_image), 'like', original_image);
    output_image(mask_rgb) = original_image(mask_rgb);
end