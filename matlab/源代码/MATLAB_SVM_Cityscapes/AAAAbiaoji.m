clear; clc; close all;

%% 1. 配置参数
% -------------------------------------------------------------------------156/76/28
model_path = 'unet_full_dataset_model1.mat';
original_image_path = 'D:\matlab\MATLAB_SVM_Cityscapes\data\images\aachen_000058_000019_leftImg8bit.png';
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

%% 4. 核心后处理：双重净化（天空探测 + 形态学清理）
% -------------------------------------------------------------------------
fprintf('--- 正在进行双重净化后处理 ---\n');

% --- 步骤 1: 分离出三个独立的蒙版 ---
model_building_mask = (predictedMask_final == building_id);
model_car_mask = (predictedMask_final == car_id);
model_vegetation_mask_raw = (predictedMask_final == vegetation_id);

% --- 步骤 2: 对“植被蒙版”进行天空探测与剔除 ---
I_resized = testImgResized;
I_gray = rgb2gray(I_resized);
blue_channel = I_resized(:,:,3);
sky_detector_mask = I_gray > 170 & blue_channel > 140;
mask_vegetation_after_sky_removal = model_vegetation_mask_raw;
pixels_to_remove = sky_detector_mask & model_vegetation_mask_raw;
mask_vegetation_after_sky_removal(pixels_to_remove) = 0;
fprintf('已使用天空探测器剔除大部分天空。\n');

% --- 步骤 3: (新增强) 对植被蒙版进行形态学终极清理 ---
% 使用一个小的结构元素，作为“筛子”
se = strel('disk', 2); 
% 执行开操作 (imopen)，去除所有残留的小孔洞和噪点
mask_vegetation_final_cleaned = imopen(mask_vegetation_after_sky_removal, se);
fprintf('已使用形态学开操作，完成最终清理。\n\n');

% --- 步骤 4: 合并所有最终蒙版 ---
final_combined_mask = model_building_mask | model_car_mask | mask_vegetation_final_cleaned;

%% 5. 生成最终成果图 (无Alpha融合)
% =========================================================================
fprintf('--- 正在生成最终成果对比图 ---\n');

% --- 将最终合并后的蒙版应用到原始图片上 ---
mask_resized_final = imresize(final_combined_mask, [size(originalImg, 1), size(originalImg, 2)], 'nearest');
mask_rgb_final = repmat(mask_resized_final, 1, 1, 3);
final_result_image = zeros(size(originalImg), 'like', originalImg);
final_result_image(mask_rgb_final) = originalImg(mask_rgb_final);

% --- 创建 1x2 最终展示图窗 ---
figure('Name', '终极纯净分割成果', 'Position', [100, 100, 1600, 600]);

% 左侧：原始图片
subplot(1, 2, 1);
imshow(originalImg);

% 右侧：最终纯净分割结果
subplot(1, 2, 2);
imshow(final_result_image);

fprintf('脚本执行完毕！\n');