% =========================================================================
% 报告图片生成脚本 A (v1.4) - 传统模型语义分割对比 (带准确率标注)
%
% 描述:
%   此版本在生成2x2对比图的基础上，为每个模型的结果图添加了
%   其最终像素准确率作为标题，实现了量化指标与视觉效果的结合。
% =========================================================================
clear; clc; close all;

%% 1. 配置参数
% -------------------------------------------------------------------------
model_paths.SVM = 'svm_model_99_images_standard.mat';
model_paths.RandomForest = 'random_forest_model_99_images.mat';
model_paths.GBDT = 'gbdt_model_99_images.mat';
testImageName = 'aachen_000099_000019_leftImg8bit.png';
testLabelName = 'aachen_000099_000019_gtFine_labelIds.png';
testImg_path = fullfile('data', 'images', testImageName);
testLabel_path = fullfile('data', 'labels', testLabelName);
imageResizeFactor = 0.25;

%% 2. 加载数据
% -------------------------------------------------------------------------
fprintf('正在加载测试数据...\n');
if ~isfile(testImg_path), error('测试图片 %s 未找到！', testImg_path); end
if ~isfile(testLabel_path), error('标签图片 %s 未找到！', testLabel_path); end

originalImg = imread(testImg_path);
testLabel_GT = imread(testLabel_path);

testImgResized = imresize(originalImg, imageResizeFactor);
testLabel_GT_Resized = imresize(testLabel_GT, imageResizeFactor, 'nearest');

cmap = cityscapes_colormap();
fprintf('加载完成！\n\n');

%% 3. 循环预测、评估并存储结果
% -------------------------------------------------------------------------
results = struct();
accuracies = struct();
traditional_models = {'SVM', 'RandomForest', 'GBDT'};

fprintf('正在为传统模型提取特征...\n');
testFeatures = extract_pixel_features(testImgResized);
fprintf('特征提取完成。\n\n');

for i = 1:length(traditional_models)
    model_type = traditional_models{i};
    fprintf('--- 正在处理模型: %s ---\n', model_type);
    
    model_path = model_paths.(model_type);
    model_data = load(model_path);
    all_variable_names = fieldnames(model_data);
    first_variable_name = all_variable_names{1};
    loaded_model = model_data.(first_variable_name);
    
    % 预测与后处理
    predictedLabels = predict(loaded_model, testFeatures);
    predictedMask_raw = reshape(predictedLabels, size(testImgResized, 1), size(testImgResized, 2));
    predictedMask_final = medfilt2(predictedMask_raw, [5 5]);
    
    % --- 新增：计算最终准确率 ---
    validIdx = true(size(testLabel_GT_Resized)); % 传统模型默认所有像素都有效
    totalValidPixels = numel(testLabel_GT_Resized);
    acc_final = sum(predictedMask_final(validIdx) == testLabel_GT_Resized(validIdx)) / totalValidPixels;
    accuracies.(model_type) = acc_final * 100; % 存储为百分比
    fprintf('  - %s 最终准确率: %.2f%%\n', model_type, accuracies.(model_type));
    
    % 存储可视化结果
    results.(model_type) = label2rgb(predictedMask_final, cmap, 'k');
end
fprintf('\n所有传统模型处理完成。\n');

%% 4. 生成 2x2 传统模型成果对比图 (带标题)
% =========================================================================
fprintf('--- 正在生成 2x2 传统模型成果对比图 ---\n');
figure('Name', '传统模型语义分割成果对比', 'Position', [50, 50, 1600, 1200]);

% --- 第一行 ---
% 左上角: 原始图片
subplot(2, 2, 1);
imshow(testImgResized);
title('原始图片', 'FontSize', 14);

% 右上角: SVM 预测结果
subplot(2, 2, 2);
imshow(results.SVM);
title(sprintf('SVM 预测结果\n准确率: %.2f%%', accuracies.SVM), 'FontSize', 14);

% --- 第二行 ---
% 左下角: 随机森林 预测结果
subplot(2, 2, 3);
imshow(results.RandomForest);
title(sprintf('随机森林 预测结果\n准确率: %.2f%%', accuracies.RandomForest), 'FontSize', 14);

% 右下角: 梯度提升决策树 预测结果
subplot(2, 2, 4);
imshow(results.GBDT);
title(sprintf('GBDT 预测结果\n准确率: %.2f%%', accuracies.GBDT), 'FontSize', 14);

fprintf('对比图已生成！\n');

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

function cmap = cityscapes_colormap()
    % Cityscapes 34-class colormap
    colors_uint8 = [ 0,0,0; 0,0,0; 0,0,0; 0,0,0; 0,0,0; 111,74,0; 81,0,81; 128,64,128; 244,35,232; 250,170,160; 230,150,140; 70,70,70; 102,102,156; 190,153,153; 180,165,180; 150,100,100; 150,120,90; 153,153,153; 153,153,153; 250,170,30; 220,220,0; 107,142,35; 152,251,152; 70,130,180; 220,20,60; 255,0,0; 0,0,142; 0,0,70; 0,60,100; 0,0,90; 0,0,110; 0,80,100; 0,0,230; 119,11,32 ];
    cmap = double(colors_uint8) / 255.0;
end