% =========================================================================
% 通用模型评估脚本 (v2.2 - 最终纯净无标题版)
%
% 描述:
%   此版本移除了所有生成图像的内置标题，以生成最纯净的图片素材，
%   方便在报告中进行排版和添加图注。
% =========================================================================
clear; clc; close all;

%% 1. 配置参数 (在这里选择要评估的模型)
% -------------------------------------------------------------------------
% --- 1a. 选择模型类型 ---
% 可选项: 'SVM', 'RandomForest', 'GBDT', 'UNet'
model_type = 'RandomForest'; % <--- 修改这里来切换模型！

% --- 1b. 模型文件路径 ---
model_paths.SVM = 'svm_model_99_images_standard.mat';
model_paths.RandomForest = 'random_forest_model_99_images.mat';
model_paths.GBDT = 'gbdt_model_99_images.mat';
model_paths.UNet = 'unet_full_dataset_model.mat'; % 确认文件名

% --- 1c. 数据与评估配置 ---
testImageName = 'aachen_000099_000019_leftImg8bit.png';

if strcmpi(model_type, 'UNet')
    is_unet = true;
    imageResizeFactor = [256, 512];
    testImg_path = 'D:\matlab\MATLAB_SVM_Cityscapes\data\images\aachen_000099_000019_leftImg8bit.png';
else
    is_unet = false;
    imageResizeFactor = 0.25;
    testImg_path = fullfile('data/images', testImageName);
end

% --- 1d. 定义目标ID ---
if is_unet
    building_id = 2; vegetation_id = 8; car_id = 13;
else
    % Cityscapes labelId: building=11, vegetation=21, car=26
    building_id = 11; vegetation_id = 21; car_id = 26;
end

%% 2. 动态加载预训练模型
% -------------------------------------------------------------------------
model_path = model_paths.(model_type);
fprintf('正在从 %s 加载 %s 模型...\n', model_path, model_type);
if ~exist(model_path, 'file'), error('模型文件未找到！请检查路径或文件名。'); end
model_data = load(model_path);
all_variable_names = fieldnames(model_data);
loaded_model = model_data.(all_variable_names{1});
fprintf('模型加载成功！\n');

%% 3. 加载并预处理测试数据
% -------------------------------------------------------------------------
fprintf('正在加载测试图片: %s\n', testImageName);
originalImg = imread(testImg_path);
testImgResized = imresize(originalImg, imageResizeFactor);
fprintf('加载完成！\n');

%% 4. 根据模型类型进行预测
% -------------------------------------------------------------------------
fprintf('正在使用 %s 模型进行预测...\n', model_type);
tic;
if is_unet
    pxdsResults = semanticseg(testImgResized, loaded_model);
    predictedMask_raw = uint8(pxdsResults) - 1;
else
    testFeatures = extract_pixel_features(testImgResized);
    predictedLabels = predict(loaded_model, testFeatures);
    predictedMask_raw = reshape(predictedLabels, size(testImgResized, 1), size(testImgResized, 2));
end
predictionTime = toc;
fprintf('分割完成！耗时: %.2f 秒\n', predictionTime);

%% 5. 后处理优化 (中值滤波)
% -------------------------------------------------------------------------
fprintf('正在对预测结果进行中值滤波优化...\n');
predictedMask_final = medfilt2(predictedMask_raw, [5 5]);
fprintf('后处理完成。\n');

%% 6. 核心修改：生成最终的“图像分割”成果
% =========================================================================
fprintf('\n--- 正在生成最终的图像分割成果 ---\n');

% --- 步骤 6a: 从预测结果中分离蒙版 ---
model_building_mask = (predictedMask_final == building_id);
model_car_mask = (predictedMask_final == car_id);
model_vegetation_mask_raw = (predictedMask_final == vegetation_id);

% --- 步骤 6b: (仅对U-Net) 对植被进行精修 ---
if is_unet
    fprintf('正在对U-Net的植被结果进行精修...\n');
    I_resized = testImgResized;
    I_gray = rgb2gray(I_resized);
    blue_channel = I_resized(:,:,3);
    sky_detector_mask = I_gray > 170 & blue_channel > 140;
    
    mask_vegetation_refined = model_vegetation_mask_raw;
    pixels_to_remove = sky_detector_mask & model_vegetation_mask_raw;
    mask_vegetation_refined(pixels_to_remove) = 0;
    mask_vegetation_final_cleaned = bwareaopen(mask_vegetation_refined, 30);
    
    final_combined_mask = model_building_mask | model_car_mask | mask_vegetation_final_cleaned;
else
    final_combined_mask = model_building_mask | model_car_mask | model_vegetation_mask_raw;
end

% --- 步骤 6c: 将最终蒙版应用到原图上 ---
final_result_image = apply_mask_to_image(originalImg, final_combined_mask, imageResizeFactor);

% --- 步骤 6d: 生成最终的 1x2 对比图 (无标题) ---
figure('Name', [model_type, ' - 最终图像分割结果'], 'Position', [100, 100, 1600, 600]);

% --- 核心修正：移除了所有 title 命令 ---
subplot(1, 2, 1);
imshow(originalImg);

subplot(1, 2, 2);
imshow(final_result_image);

fprintf('脚本执行完毕！\n');


%% 辅助函数 (Local Functions)
% =========================================================================
function features = extract_pixel_features(img)
    [h, w, ~] = size(img);
    numPixels = h * w;
    img_double = double(img);
    rgb = reshape(img_double, numPixels, 3) / 255.0;
    hsv = rgb2hsv(img);
    hsv = reshape(hsv, numPixels, 3);
    lab = rgb2lab(img);
    lab = reshape(lab, numPixels, 3);
    [X, Y] = meshgrid(1:w, 1:h);
    coords = [X(:)/w, Y(:)/h];
    gray_img = rgb2gray(img);
    texture_std = stdfilt(gray_img, ones(5));
    texture = double(texture_std(:)) / 255.0;
    features = [rgb, hsv, lab, coords, texture];
end

function output_img = apply_mask_to_image(original_image, binary_mask, resizeFactor)
    original_resized = imresize(original_image, resizeFactor);
    mask_resized = imresize(binary_mask, resizeFactor, 'nearest');
    mask_rgb = repmat(mask_resized, 1, 1, 3);
    output_img = zeros(size(original_resized), 'like', original_resized);
    output_img(mask_rgb) = original_resized(mask_rgb);
end