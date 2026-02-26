% =========================================================================
% 课设任务拓展: 使用随机森林 (Random Forest) 进行语义分割 (修正版)
% =========================================================================
clear; clc; close all;
rng(1); % 设置随机种子以保证结果可复现

%% 1. 配置参数
% -------------------------------------------------------------------------
imgPath = 'data/images/';
labelPath = 'data/labels/';
model_filename = 'random_forest_model_99_images.mat'; % 随机森林模型的新文件名

params.imageResizeFactor = 0.25; 
params.numPixelsPerImage = 500;  

%% 2. 检查并加载/训练模型
% -------------------------------------------------------------------------
if exist(model_filename, 'file')
    fprintf('发现已训练好的随机森林模型文件: %s\n正在加载模型...\n', model_filename);
    load(model_filename, 'rfModel');
    fprintf('模型加载成功！\n');
else
    fprintf('未发现已训练好的模型，开始新的随机森林训练流程...\n');
    
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

    % 2c. 训练随机森林模型 (使用正确的 fitcensemble 函数)
    fprintf('\n开始训练随机森林模型... (这可能需要很长时间)\n');
    tic;
    % --- 核心修正：使用 fitcensemble 函数 ---
    % 'Method', 'Bag': 指定使用 Bagging 集成方法，这是随机森林的核心
    % 'NumLearningCycles', 100: 指定集成中包含100棵决策树
    % 'Learners', 'Tree': 指定基础学习器是决策树
    rfModel = fitcensemble(allTrainFeatures, allTrainLabels, ...
        'Method', 'Bag', ...
        'NumLearningCycles', 100, ...
        'Learners', 'Tree');
    
    trainingTime = toc;
    fprintf('随机森林模型训练完成！耗时: %.2f 秒 (约 %.1f 分钟)\n', trainingTime, trainingTime/60);

    % 2d. 保存新模型
    fprintf('正在将训练好的模型保存到文件: %s\n', model_filename);
    save(model_filename, 'rfModel'); % 注意变量名是 rfModel
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
predictedLabels = predict(rfModel, testFeatures); % 使用 rfModel 进行预测
predictionTime = toc;
fprintf('分割完成！耗时: %.2f 秒\n', predictionTime);

predictedMask_raw = reshape(predictedLabels, size(testImgResized, 1), size(testImgResized, 2));

%% 4. 后处理优化 (中值滤波)
% -------------------------------------------------------------------------
fprintf('正在对预测结果进行中值滤波优化...\n');
predictedMask_final = medfilt2(predictedMask_raw, [5 5]);
fprintf('后处理完成。\n');

%% 5. 评估与可视化
% -------------------------------------------------------------------------
fprintf('\n--- 随机森林模型评估结果 ---\n');
totalPixels = numel(testLabel_GT_Resized);

acc_raw = sum(predictedMask_raw(:) == testLabel_GT_Resized(:)) / totalPixels;
fprintf('  - 原始预测准确率: %.2f%%\n', acc_raw * 100);

acc_final = sum(predictedMask_final(:) == testLabel_GT_Resized(:)) / totalPixels;
fprintf('  - 中值滤波优化后准确率: %.2f%%\n', acc_final * 100);

cmap = cityscapes_colormap();
predictedRGB_raw = label2rgb(predictedMask_raw, cmap, 'k');
predictedRGB_final = label2rgb(predictedMask_final, cmap, 'k');
groundTruthRGB = label2rgb(testLabel_GT_Resized, cmap, 'k');

figure('Name', 'Random Forest Segmentation Results', 'Position', [50, 50, 1600, 450]);
subplot(1, 4, 1);
imshow(testImgResized);
title(sprintf('测试图片: %s (Resized)', strrep(testImageName, '_', '\_')));

subplot(1, 4, 2);
imshow(groundTruthRGB);
title('标准答案 (Ground Truth)');

subplot(1, 4, 3);
imshow(predictedRGB_raw);
title(sprintf('随机森林-原始预测\nAccuracy: %.2f%%', acc_raw * 100));

subplot(1, 4, 4);
imshow(predictedRGB_final);
title(sprintf('中值滤波优化后\nAccuracy: %.2f%%', acc_final * 100));