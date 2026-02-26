% =========================================================================
% 通用模型评估脚本 (evaluate_all_models.m) - 2x2 布局最终版
% =========================================================================
clear; clc; close all;

%% 1. 配置参数 (在这里选择要评估的模型)
% -------------------------------------------------------------------------
% --- 1a. 选择模型类型 ---
% 可选项: 'SVM', 'RandomForest', 'GBDT', 'UNet'
model_type = 'UNet'; % <--- 修改这里来切换模型！

% --- 1b. 模型文件路径 ---
model_paths.SVM = 'svm_model_99_images_standard.mat';
model_paths.RandomForest = 'random_forest_model_99_images.mat';
model_paths.GBDT = 'gbdt_model_99_images.mat';
model_paths.UNet = 'unet_full_dataset_model.mat';

% --- 1c. 数据与评估配置 ---
dataset_root_dir = 'D:\AAAAA\erfnet_pytorch-master\dataset';
testImageName = 'aachen_000099_000019_leftImg8bit.png';

if strcmpi(model_type, 'UNet')
    is_unet = true;
    testLabelName = 'aachen_000099_000019_gtFine_labelTrainIds.png';
    imageResizeFactor = [256, 512];
else
    is_unet = false;
    testLabelName = 'aachen_000099_000019_gtFine_labelIds.png';
    imageResizeFactor = 0.25;
end

%% 2. 动态加载预训练模型
% -------------------------------------------------------------------------
model_path = model_paths.(model_type);
fprintf('正在从 %s 加载 %s 模型...\n', model_path, model_type);
if ~exist(model_path, 'file'), error('模型文件未找到！请检查路径或文件名。'); end
model_data = load(model_path);
model_field_names = fieldnames(model_data);
loaded_model = model_data.(model_field_names{1});
fprintf('模型加载成功！\n');

%% 3. 加载并预处理测试数据
% -------------------------------------------------------------------------
if is_unet
    testImg_path = fullfile(dataset_root_dir, 'leftImg8bit', 'train', 'aachen', testImageName);
    testLabel_path = fullfile(dataset_root_dir, 'gtFine', 'train', 'aachen', testLabelName);
else
    testImg_path = fullfile('data/images', testImageName);
    testLabel_path = fullfile('data/labels', testLabelName);
end

fprintf('正在加载测试图片: %s\n', testImageName);
testImg = imread(testImg_path);
testLabel_GT = imread(testLabel_path);
[h_orig, w_orig, ~] = size(testImg);
testLabel_GT = imresize(testLabel_GT, [h_orig, w_orig], 'nearest');

testImgResized = imresize(testImg, imageResizeFactor);
testLabel_GT_Resized = imresize(testLabel_GT, imageResizeFactor, 'nearest');

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

%% 5. 后处理优化 (聚焦于最佳方案: 中值滤波)
% -------------------------------------------------------------------------
fprintf('正在对预测结果进行中值滤波优化...\n');
predictedMask_final = medfilt2(predictedMask_raw, [5 5]);
fprintf('后处理完成。\n');

%% 6. 评估与可视化 (修改为2x2布局)
% -------------------------------------------------------------------------
fprintf('\n--- %s 模型评估结果 ---\n', model_type);

if is_unet
    cmap = cityscapes_trainid_colormap();
    ignoreId = 255;
    tempIgnoreId = 19;
    testLabel_GT_Resized(testLabel_GT_Resized == ignoreId) = tempIgnoreId;
    validIdx = testLabel_GT_Resized ~= tempIgnoreId;
else
    cmap = cityscapes_colormap();
    validIdx = true(size(testLabel_GT_Resized));
end

totalValidPixels = sum(validIdx, 'all');

acc_raw = sum(predictedMask_raw(validIdx) == testLabel_GT_Resized(validIdx)) / totalValidPixels;
fprintf('  - 原始预测准确率 (有效像素): %.2f%%\n', acc_raw * 100);

acc_final = sum(predictedMask_final(validIdx) == testLabel_GT_Resized(validIdx)) / totalValidPixels;
fprintf('  - 中值滤波优化后准确率 (有效像素): %.2f%%\n', acc_final * 100);

groundTruthRGB = label2rgb(testLabel_GT_Resized, cmap, 'k');
predictedRGB_raw = label2rgb(predictedMask_raw, cmap, 'k');
predictedRGB_final = label2rgb(predictedMask_final, cmap, 'k');

% --- 核心修改：调整Figure尺寸和subplot布局 ---
figure('Name', [model_type, ' Model Final Evaluation'], 'Position', [50, 50, 1200, 900]); % 调整窗口尺寸为更方形

% 第一行
subplot(2, 2, 1); % 2行2列的第1个位置
imshow(testImgResized);
title('测试图片 (Resized)');

subplot(2, 2, 2); % 2行2列的第2个位置
imshow(groundTruthRGB);
title('标准答案 (Ground Truth)');

% 第二行
subplot(2, 2, 3); % 2行2列的第3个位置
imshow(predictedRGB_raw);
title(sprintf('%s-原始预测\nAccuracy: %.2f%%', model_type, acc_raw * 100));

subplot(2, 2, 4); % 2行2列的第4个位置
imshow(predictedRGB_final);
title(sprintf('中值滤波优化后\nAccuracy: %.2f%%', acc_final * 100));
% --- 修改结束 ---

%% 辅助函数
% ... (辅助函数保持不变) ...
function cmap = cityscapes_colormap()
    colors_uint8 = [ 0,0,0; 0,0,0; 0,0,0; 0,0,0; 0,0,0; 111,74,0; 81,0,81; 128,64,128; 244,35,232; 250,170,160; 230,150,140; 70,70,70; 102,102,156; 190,153,153; 180,165,180; 150,100,100; 150,120,90; 153,153,153; 153,153,153; 250,170,30; 220,220,0; 107,142,35; 152,251,152; 70,130,180; 220,20,60; 255,0,0; 0,0,142; 0,0,70; 0,60,100; 0,0,90; 0,0,110; 0,80,100; 0,0,230; 119,11,32 ];
    cmap = double(colors_uint8) / 255.0;
end

function cmap = cityscapes_trainid_colormap()
    colors_uint8 = [ 128,64,128; 244,35,232; 70,70,70; 102,102,156; 190,153,153; 153,153,153; 250,170,30; 220,220,0; 107,142,35; 152,251,152; 70,130,180; 220,20,60; 255,0,0; 0,0,142; 0,0,70; 0,60,100; 0,80,100; 0,0,230; 119,11,32 ];
    cmap = double(colors_uint8) / 255.0;
end