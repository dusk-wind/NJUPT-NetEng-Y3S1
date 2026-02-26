% =========================================================================
% 标准答案精修脚本 (v21.1 - 最终精华版)
%
% 描述:
%   本脚本旨在用最直接的方式，展示对“标准答案”进行精修后的最终成果。
%   核心流程：
%   1. 将建筑、车辆、植被从标准答案中分离成三个图层。
%   2. 对建筑和植被图层进行靶向颜色剔除，修复天空空洞。
%   3. 合并所有图层，生成一个 1x2 的最终对比图：[原始图片] vs [精修结果]。
% =========================================================================
clear; clc; close all;

%% 1. 配置参数 (路径已硬编码)
% -------------------------------------------------------------------------
original_image_path = 'D:\matlab\MATLAB_SVM_Cityscapes\data\images\aachen_000099_000019_leftImg8bit.png';
label_image_path = 'D:\matlab\MATLAB_SVM_Cityscapes\data\labels\aachen_000099_000019_gtFine_labelTrainIds.png';

%% 2. 加载文件
% -------------------------------------------------------------------------
fprintf('正在加载原始图片和标准答案标签...\n');
if ~isfile(original_image_path), error('原始图片未找到: %s', original_image_path); end
if ~isfile(label_image_path), error('标签图片未找到: %s', label_image_path); end
originalImg = imread(original_image_path);
labelImg = imread(label_image_path);
if ~isequal(size(originalImg, [1, 2]), size(labelImg, [1, 2]))
    labelImg = imresize(labelImg, [size(originalImg, 1), size(originalImg, 2)], 'nearest');
end
fprintf('加载完成！\n\n');

%% 3. 分离图层并进行终极后处理
% -------------------------------------------------------------------------
fprintf('--- 正在对标准答案进行终极后处理 ---\n');

% --- 定义目标类别ID ---
building_id = 2;
vegetation_id = 8;
car_id = 13;

% --- 创建并抠出三个独立的原始图层 ---
building_mask = (labelImg == building_id);
vegetation_mask = (labelImg == vegetation_id);
car_mask = (labelImg == car_id);

segmented_building_layer_raw = apply_mask_to_image(originalImg, building_mask);
segmented_vegetation_layer_raw = apply_mask_to_image(originalImg, vegetation_mask);
segmented_car_layer = apply_mask_to_image(originalImg, car_mask);

% --- 对需要修复的图层进行靶向颜色剔除 ---
target_sky_color = [191, 212, 201];
color_threshold = 45;

segmented_building_layer_refined = refine_layer_by_color(segmented_building_layer_raw, target_sky_color, color_threshold);
segmented_vegetation_layer_refined = refine_layer_by_color(segmented_vegetation_layer_raw, target_sky_color, color_threshold);
fprintf('后处理完成。\n\n');

% --- 合并修复后的终极结果 ---
final_result = segmented_building_layer_refined + segmented_car_layer + segmented_vegetation_layer_refined;

%% 4. 生成并展示最终成果
% =========================================================================
fprintf('--- 正在生成最终成果对比图 ---\n');

% --- 创建 1x2 最终展示图窗 ---
figure('Name', 'z', 'Position', [100, 100, 1600, 600]);

% 左：原始图片
subplot(1, 2, 1);
imshow(originalImg);
title('1. 原始图片', 'FontSize', 14);

% 右：终极精修结果 (已修复所有空洞)
subplot(1, 2, 2);
imshow(final_result);
title('2. 图像分割结果', 'FontSize', 14);

fprintf('所有图像已生成！\n');

%% 辅助函数 (Local Functions)
% =========================================================================
function output_img = apply_mask_to_image(original, mask)
    % 辅助函数：根据二值蒙版从原图中抠图
    mask_rgb = repmat(mask, 1, 1, 3);
    output_img = zeros(size(original), 'like', original);
    output_img(mask_rgb) = original(mask_rgb);
end

function refined_layer = refine_layer_by_color(raw_layer, target_color, threshold)
    % 辅助函数：对单个图层进行靶向颜色剔除
    refined_layer = raw_layer;
    non_black_pixels_mask = any(raw_layer > 10, 3);
    [row_indices, col_indices] = find(non_black_pixels_mask);
    
    if ~isempty(row_indices)
        linear_indices = sub2ind(size(raw_layer), row_indices, col_indices);
        r_vals = raw_layer(linear_indices);
        g_vals = raw_layer(linear_indices + numel(raw_layer(:,:,1)));
        b_vals = raw_layer(linear_indices + 2*numel(raw_layer(:,:,1)));
        
        distances = sqrt( ...
            (double(r_vals) - target_color(1)).^2 + ...
            (double(g_vals) - target_color(2)).^2 + ...
            (double(b_vals) - target_color(3)).^2 );
            
        pixels_to_remove_indices = linear_indices(distances < threshold);
        
        if ~isempty(pixels_to_remove_indices)
            refined_layer(pixels_to_remove_indices) = 0;
            refined_layer(pixels_to_remove_indices + numel(raw_layer(:,:,1))) = 0;
            refined_layer(pixels_to_remove_indices + 2*numel(raw_layer(:,:,1))) = 0;
        end
    end
end