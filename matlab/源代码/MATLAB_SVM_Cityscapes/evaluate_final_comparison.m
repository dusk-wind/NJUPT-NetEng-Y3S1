% =========================================================================
% 最终模型对比脚本 (evaluate_final_comparison.m)
% -------------------------------------------------------------------------
% 作用：加载所有已训练好的模型 (SVM, RF, GBDT, UNet)，
%       并在同一张测试图片上进行评估，生成最终的对比图。
% =========================================================================
clear; clc; close all;

%% 1. 配置
% -------------------------------------------------------------------------
% 模型文件名
model_files.SVM = 'svm_model_99_images_standard.mat';
model_files.RandomForest = 'random_forest_model_99_images.mat';
model_files.GBDT = 'gbdt_model_99_images.mat';
model_files.UNet = 'unet_full_dataset_model.mat';

% 测试图片
dataset_root_dir = 'D:\AAAAA\erfnet_pytorch-master\dataset';
testImageName_short = 'aachen_000099_000019';

% 预处理参数
unet_input_size = [256, 512, 3];
traditional_resize_factor = 0.25;

%% 2. 加载所有模型
% -------------------------------------------------------------------------
fprintf('>>> 正在加载所有预训练模型...\n');
models.SVM = load(model_files.SVM);
models.RandomForest = load(model_files.RandomForest);
models.GBDT = load(model_files.GBDT);
models.UNet = load(model_files.UNet);
fprintf('所有模型加载成功！\n');

%% 3. 准备测试数据
% -------------------------------------------------------------------------
fprintf('>>> 正在准备测试数据...\n');
% 传统方法数据
testImg_path_trad = fullfile('data/images', [testImageName_short, '_leftImg8bit.png']);
testLabel_path_trad = fullfile('data/labels', [testImageName_short, '_gtFine_labelIds.png']);
testImg_trad = imread(testImg_path_trad);
testLabel_trad = imread(testLabel_path_trad);
[h,w,~] = size(testImg_trad);
testLabel_trad = imresize(testLabel_trad, [h,w], 'nearest');
testImgResized_trad = imresize(testImg_trad, traditional_resize_factor);
testLabelResized_trad = imresize(testLabel_trad, traditional_resize_factor, 'nearest');
testFeatures = extract_pixel_features(testImgResized_trad);

% U-Net 数据
testImg_path_unet = fullfile(dataset_root_dir, 'leftImg8bit', 'train', 'aachen', [testImageName_short, '_leftImg8bit.png']);
testLabel_path_unet = fullfile(dataset_root_dir, 'gtFine', 'train', 'aachen', [testImageName_short, '_gtFine_labelTrainIds.png']);
testImg_unet = imread(testImg_path_unet);
testLabel_unet = imread(testLabel_path_unet);
testImgResized_unet = imresize(testImg_unet, unet_input_size(1:2));
testLabelResized_unet = imresize(testLabel_unet, traditional_resize_factor, 'nearest');

%% 4. 逐个模型进行预测和评估
% -------------------------------------------------------------------------
results = struct();
model_names = fieldnames(models);
for i = 1:numel(model_names)
    model_name = model_names{i};
    fprintf('\n--- 正在评估 %s 模型 ---\n', model_name);
    
    model_obj = models.(model_name).(cell2mat(fieldnames(models.(model_name))));
    
    tic;
    if strcmp(model_name, 'UNet')
        pxdsResults = semanticseg(testImgResized_unet, model_obj);
        predictedMask_raw = uint8(pxdsResults) - 1;
        predictedMask_raw = imresize(predictedMask_raw, size(testLabelResized_trad), 'nearest');
    else
        predictedLabels = predict(model_obj, testFeatures);
        predictedMask_raw = reshape(predictedLabels, size(testLabelResized_trad));
    end
    results.(model_name).predictionTime = toc;
    
    results.(model_name).finalMask = medfilt2(predictedMask_raw, [5 5]);
    
    if strcmp(model_name, 'UNet')
        validIdx = testLabelResized_unet ~= 255;
        results.(model_name).accuracy = sum(results.(model_name).finalMask(validIdx) == testLabelResized_unet(validIdx)) / sum(validIdx,'all');
    else
        results.(model_name).accuracy = sum(results.(model_name).finalMask(:) == testLabelResized_trad(:)) / numel(testLabelResized_trad);
    end
    
    fprintf('%s 模型最终准确率: %.2f%%\n', model_name, results.(model_name).accuracy * 100);
end

%% 5. 生成最终的所有模型对比图
% -------------------------------------------------------------------------
figure('Name', 'Final Model Comparison', 'Position', [50, 50, 2400, 400]);

% 显示原图和GT
subplot(1, 6, 1); imshow(testImgResized_trad); title('测试图片 (Resized)');
cmap_trad = cityscapes_colormap();
groundTruthRGB_trad = label2rgb(testLabelResized_trad, cmap_trad, 'k');
subplot(1, 6, 2); imshow(groundTruthRGB_trad); title('标准答案 (labelIds)');

% 显示各个模型结果
cmap_unet = cityscapes_trainid_colormap();
subplot(1, 6, 3); 
predictedRGB_svm = label2rgb(results.SVM.finalMask, cmap_trad, 'k');
imshow(predictedRGB_svm); title(sprintf('SVM\nAccuracy: %.2f%%', results.SVM.accuracy * 100));

subplot(1, 6, 4); 
predictedRGB_rf = label2rgb(results.RandomForest.finalMask, cmap_trad, 'k');
imshow(predictedRGB_rf); title(sprintf('Random Forest\nAccuracy: %.2f%%', results.RandomForest.accuracy * 100));

subplot(1, 6, 5); 
predictedRGB_gbdt = label2rgb(results.GBDT.finalMask, cmap_trad, 'k');
imshow(predictedRGB_gbdt); title(sprintf('GBDT\nAccuracy: %.2f%%', results.GBDT.accuracy * 100));

subplot(1, 6, 6); 
predictedRGB_unet = label2rgb(results.UNet.finalMask, cmap_unet, 'k');
imshow(predictedRGB_unet); title(sprintf('U-Net\nAccuracy: %.2f%%', results.UNet.accuracy * 100));