% =========================================================================
% 课设任务: 基于SVM和高级特征的Cityscapes图像语义分割
% -- 最终版: 聚焦于最大化像素准确率 --
% =========================================================================
clear; clc; close all;
rng(1); % 设置随机种子以保证结果可复现

%% 1. 配置参数
% -------------------------------------------------------------------------
imgPath = 'data/images/';
labelPath = 'data/labels/';
model_filename = 'svm_model_99_images_standard.mat'; % 为标准模型起一个清晰的名字

params.imageResizeFactor = 0.25; 
params.numPixelsPerImage = 500;  
params.kernelFunction = 'rbf';   

%% 2. 检查并加载/训练模型 (标准训练，无代价敏感)
% -------------------------------------------------------------------------
if exist(model_filename, 'file')
    fprintf('发现已训练好的标准模型文件: %s\n正在加载模型...\n', model_filename);
    load(model_filename, 'svmModel');
    fprintf('模型加载成功！\n');
else
    fprintf('未发现已训练好的模型，开始新的标准训练流程...\n');
    
    % 2a. 自动化生成训练文件名列表
    fprintf('正在准备训练文件列表...\n');
    numTrainingImages = 99;
    trainingImages = cell(numTrainingImages, 1);
    trainingLabels = cell(numTrainingImages, 1);
    instance_prefix = 'aachen';
    sequence_id = '000019';
    for i = 0:(numTrainingImages - 1)
        image_id = sprintf('%06d', i); 
        trainingImages{i+1} = sprintf('%s_%s_%s_leftImg8bit.png', instance_prefix, image_id, sequence_id);
        trainingLabels{i+1} = sprintf('%s_%s_%s_gtFine_labelIds.png', instance_prefix, image_id, sequence_id);
    end

    % 2b. 提取特征
    allTrainFeatures = [];
    allTrainLabels = [];
    fprintf('开始从 %d 张训练图片中提取特征...\n', numTrainingImages);
    for i = 1:length(trainingImages)
        imgPathFull = fullfile(imgPath, trainingImages{i});
        labelPathFull = fullfile(labelPath, trainingLabels{i});
        if ~exist(imgPathFull, 'file') || ~exist(labelPathFull, 'file')
            warning('文件 %s 或对应的标签不存在，已跳过。', trainingImages{i});
            continue;
        end
        img = imread(imgPathFull);
        label = imread(labelPathFull);
        imgResized = imresize(img, params.imageResizeFactor);
        labelResized = imresize(label, params.imageResizeFactor, 'nearest');
        features = extract_pixel_features(imgResized);
        labels = labelResized(:);
        sampleIndices = randperm(size(features, 1), min(size(features, 1), params.numPixelsPerImage));
        allTrainFeatures = [allTrainFeatures; features(sampleIndices, :)];
        allTrainLabels = [allTrainLabels; labels(sampleIndices, :)];
        fprintf('  - 处理完训练图片 %d/%d\n', i, length(trainingImages));
    end

    % 2c. 训练标准SVM模型 (无Cost参数)
    fprintf('\n开始训练标准的多分类SVM模型... (这可能需要很长时间)\n');
    tic;
    svmTemplate = templateSVM('KernelFunction', params.kernelFunction, 'Standardize', true);
    % --- 使用标准的fitcecoc，不加'Cost'参数 ---
    svmModel = fitcecoc(allTrainFeatures, allTrainLabels, 'Learners', svmTemplate);
    trainingTime = toc;
    fprintf('模型训练完成！耗时: %.2f 秒 (约 %.1f 分钟)\n', trainingTime, trainingTime/60);

    % 2d. 保存模型
    fprintf('正在将训练好的模型保存到文件: %s\n', model_filename);
    save(model_filename, 'svmModel');
    fprintf('模型保存成功！\n');
end

%% 3. 在测试图片上进行预测
% -------------------------------------------------------------------------
testImageName = 'aachen_000099_000019_leftImg8bit.png';
testLabelName = 'aachen_000099_000019_gtFine_labelIds.png';

fprintf('\n在测试图片 %s 上进行分割...\n', testImageName);
testImg = imread(fullfile(imgPath, testImageName));
testLabel_GT = imread(fullfile(labelPath, testLabelName));

% 强制统一原始尺寸
[h_orig, w_orig, ~] = size(testImg);
testLabel_GT = imresize(testLabel_GT, [h_orig, w_orig], 'nearest');

testImgResized = imresize(testImg, params.imageResizeFactor);
testLabel_GT_Resized = imresize(testLabel_GT, params.imageResizeFactor, 'nearest');

testFeatures = extract_pixel_features(testImgResized);

tic;
predictedLabels = predict(svmModel, testFeatures);
predictionTime = toc;
fprintf('分割完成！耗时: %.2f 秒\n', predictionTime);

predictedMask_raw = reshape(predictedLabels, size(testImgResized, 1), size(testImgResized, 2));

%% 4. 后处理优化 (聚焦于最佳方案: 中值滤波)
% -------------------------------------------------------------------------
fprintf('正在对预测结果进行中值滤波优化...\n');
predictedMask_final = medfilt2(predictedMask_raw, [5 5]);
fprintf('后处理完成。\n');

%% 5. 评估与可视化
% -------------------------------------------------------------------------
fprintf('\n--- 最终评估结果 ---\n');
totalPixels = numel(testLabel_GT_Resized);

% 评估原始结果
acc_raw = sum(predictedMask_raw(:) == testLabel_GT_Resized(:)) / totalPixels;
fprintf('  - 原始预测准确率: %.2f%%\n', acc_raw * 100);

% 评估优化后的结果
acc_final = sum(predictedMask_final(:) == testLabel_GT_Resized(:)) / totalPixels;
fprintf('  - 中值滤波优化后准确率: %.2f%%\n', acc_final * 100);

% 可视化
cmap = cityscapes_colormap();
predictedRGB_raw = label2rgb(predictedMask_raw, cmap, 'k');
predictedRGB_final = label2rgb(predictedMask_final, cmap, 'k');
groundTruthRGB = label2rgb(testLabel_GT_Resized, cmap, 'k');

figure('Name', 'SVM High Accuracy Results', 'Position', [50, 50, 1600, 450]);
subplot(1, 4, 1);
imshow(testImgResized);
title(sprintf('测试图片: %s (Resized)', strrep(testImageName, '_', '\_')));

subplot(1, 4, 2);
imshow(groundTruthRGB);
title('标准答案 (Ground Truth)');

subplot(1, 4, 3);
imshow(predictedRGB_raw);
title(sprintf('标准模型-原始预测\nAccuracy: %.2f%%', acc_raw * 100));

subplot(1, 4, 4);
imshow(predictedRGB_final);
title(sprintf('中值滤波优化后\nAccuracy: %.2f%%', acc_final * 100));