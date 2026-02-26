% =========================================================================
% 最终答辩王牌脚本 (v15.0 - 聚焦核心成果)
%
% 描述:
%   本脚本旨在用最直接的方式，展示最核心、最惊艳的分割成果。
%   核心流程：
%   1. 运行U-Net模型得到语义分割预测。
%   2. 对预测出的“植被”区域，采用高级“雕刻”后处理，创造自然细节。
%   3. 将“雕刻”后的植被与其他目标（车、建筑）合并。
%   4. 生成一个 1x2 的最终对比图：[原始图片] vs [最终精修结果]。
%   * 此版本已修正MATLAB版本兼容性问题。
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

%% 2. 加载模型与数据 (已修正以兼容旧版MATLAB)
% -------------------------------------------------------------------------
fprintf('正在加载模型和图片...\n');
% 加载模型
if ~exist(model_path, 'file'), error('模型文件 %s 未找到！', model_path); end
model_data = load(model_path);
all_variable_names = fieldnames(model_data);
if isempty(all_variable_names), error('模型文件 "%s" 为空！', model_path); end
first_variable_name = all_variable_names{1};
loaded_model = model_data.(first_variable_name);

% 加载图片
if ~isfile(original_image_path), error('原始图片未找到: %s', original_image_path); end
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

%% 4. 核心后处理：分离目标并对植被进行“雕刻”
% -------------------------------------------------------------------------
fprintf('--- 正在对预测结果进行精修后处理 ---\n');

% --- 步骤 1: 分离出车和建筑的蒙版 (无需处理) ---
model_building_mask = (predictedMask_final == building_id);
model_car_mask = (predictedMask_final == car_id);

% --- 步骤 2: 对植被进行“雕刻” ---
% a. 提取AI预测的植被蒙版
model_vegetation_mask = (predictedMask_final == vegetation_id);

% b. 利用原图的亮度和“超绿”特征创建“凿子”
I_resized = testImgResized;
I_gray = rgb2gray(I_resized);
I_green = double(I_resized(:,:,2)) - 0.5*(double(I_resized(:,:,1)) + double(I_resized(:,:,3)));

% c. 定义需要被挖掉的区域
light_mask = I_gray > 180;
sky_mask = I_green < 15;
transparent_mask = light_mask | sky_mask;

% d. 进行雕刻
mask_vegetation_carved = model_vegetation_mask;
mask_vegetation_carved(transparent_mask) = 0;

% e. 形态学清理
mask_vegetation_carved_cleaned = bwareaopen(mask_vegetation_carved, 50);
fprintf('“雕刻”后处理完成！\n\n');

% --- 步骤 3: 合并所有最终蒙版 ---
final_combined_mask = model_building_mask | model_car_mask | mask_vegetation_carved_cleaned;

%% 5. 生成最终成果图
% =========================================================================
fprintf('--- 正在生成最终成果对比图 ---\n');

% --- 将最终合并后的蒙版应用到原始图片上 ---
% 将蒙版放大回原始图像尺寸
mask_resized_final = imresize(final_combined_mask, [size(originalImg, 1), size(originalImg, 2)], 'nearest');
mask_rgb_final = repmat(mask_resized_final, 1, 1, 3);
final_result_image = zeros(size(originalImg), 'like', originalImg);
final_result_image(mask_rgb_final) = originalImg(mask_rgb_final);

% --- 创建 1x2 最终展示图窗 ---
figure('Name', '最终分割成果', 'Position', [100, 100, 1600, 600]);

% 左侧：原始图片
subplot(1, 2, 1);
imshow(originalImg);
title('原始图片', 'FontSize', 14);

% 右侧：最终精修分割结果
subplot(1, 2, 2);
imshow(final_result_image);
title('最终分割结果 (车、建筑、精修植被)', 'FontSize', 14, 'Color', 'r', 'FontWeight', 'bold');

fprintf('脚本执行完毕！\n');