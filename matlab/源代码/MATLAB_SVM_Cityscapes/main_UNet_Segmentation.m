% =========================================================================
% 课设终极版: 在完整Cityscapes数据集上训练U-Net模型 (最终修正版)
% =========================================================================
clear; clc; close all;

%% 1. 数据准备 (加载完整训练集和验证集)
% -------------------------------------------------------------------------
fprintf('>>> 步骤 1: 准备深度学习数据加载器 (完整数据集) <<<\n');

% 设置数据集的根目录
datasetDir = 'D:\AAAAA\erfnet_pytorch-master\dataset'; % <--- 请确认这是您的数据集根目录

% 训练数据路径
trainImageDir = fullfile(datasetDir, 'leftImg8bit', 'train');

% 验证数据路径
valImageDir = fullfile(datasetDir, 'leftImg8bit', 'val');

% 1a. 加载图像文件
imdsTrain = imageDatastore(trainImageDir, 'FileExtensions', '.png', 'IncludeSubfolders', true);
imdsVal = imageDatastore(valImageDir, 'FileExtensions', '.png', 'IncludeSubfolders', true);

% 1b. 手动查找并构建标签文件路径列表
fprintf('正在扫描训练标签文件...\n');
trainLabelFiles = findLabelFiles(imdsTrain.Files, '_leftImg8bit', '_gtFine_labelTrainIds');
fprintf('正在扫描验证标签文件...\n');
valLabelFiles = findLabelFiles(imdsVal.Files, '_leftImg8bit', '_gtFine_labelTrainIds');

% 1c. 定义类别
classNames = [ "road", "sidewalk", "building", "wall", "fence", ...
               "pole", "traffic_light", "traffic_sign", "vegetation", "terrain", ...
               "sky", "person", "rider", "car", "truck", "bus", "train", ...
               "motorcycle", "bicycle" ];
labelIDs = (0:18)';

% 1d. 创建 PixelLabelDatastore
pxdsTrain = pixelLabelDatastore(trainLabelFiles, classNames, labelIDs);
pxdsVal = pixelLabelDatastore(valLabelFiles, classNames, labelIDs);

% 1e. 配对数据
dsTrain = combine(imdsTrain, pxdsTrain);
dsVal = combine(imdsVal, pxdsVal);

%% 2. 构建U-Net网络
% -------------------------------------------------------------------------
fprintf('>>> 步骤 2: 构建U-Net网络架构 <<<\n');

% --- 核心修正：指定输入图像的通道数为 3 ---
imageSize = [256, 512, 3]; % <--- 修改点 1: 增加通道数
numClasses = numel(classNames);
% --- unetLayers 会自动根据 imageSize 的第三个元素来设置输入层 ---
lgraph = unetLayers(imageSize, numClasses, 'EncoderDepth', 4, 'NumFirstEncoderFilters', 32); % <--- 修改点 2: 函数调用保持不变，但其行为已改变

%% 3. 设置训练参数
% -------------------------------------------------------------------------
fprintf('>>> 步骤 3: 配置训练参数 <<<\n');

% 预处理数据 (注意：现在 preprocessData 中 imageSize 是3维的)
dsTrain = transform(dsTrain, @(data) preprocessData(data, imageSize));
dsVal = transform(dsVal, @(data) preprocessData(data, imageSize));

% 定义训练选项
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 30, ...
    'MiniBatchSize', 4, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ValidationData', dsVal, ...
    'ValidationFrequency', 500, ...
    'ExecutionEnvironment', 'auto');

%% 4. 训练网络
% -------------------------------------------------------------------------
model_filename = 'unet_full_dataset_model.mat';
if exist(model_filename, 'file')
    fprintf('发现已训练好的U-Net模型，正在加载...\n');
    load(model_filename, 'net');
else
    fprintf('>>> 步骤 4: 开始训练U-Net网络 (完整数据集) <<<\n');
    fprintf('这将是一个非常漫长的过程，请确保有充足的时间和强大的GPU...\n');
    [net, info] = trainNetwork(dsTrain, lgraph, options);
    save(model_filename, 'net');
    fprintf('U-Net模型训练完成并已保存！\n');
end

%% 5. 在单张测试图片上进行评估
% -------------------------------------------------------------------------
fprintf('>>> 步骤 5: 在单张测试图片上进行评估 <<<\n');

testImageName_short = 'aachen_000099_000019';
testImageFile = fullfile(datasetDir, 'leftImg8bit', 'train', 'aachen', [testImageName_short, '_leftImg8bit.png']);
testLabelFile = fullfile(datasetDir, 'gtFine', 'train', 'aachen', [testImageName_short, '_gtFine_labelTrainIds.png']);

testImage = imread(testImageFile);
testLabel = imread(testLabelFile);
ignoreId = 255;
testLabel(testLabel==ignoreId) = 19; 

% U-Net的输入尺寸现在是3维的
testImageResized = imresize(testImage, imageSize(1:2));
pxdsResults = semanticseg(testImageResized, net);

predictedMask = uint8(grp2idx(pxdsResults)) - 1;

finalSize = size(imresize(testImage, 0.25));
finalSize = finalSize(1:2);

predictedMaskFinal = imresize(predictedMask, finalSize, 'nearest');
testLabelFinal = imresize(testLabel, finalSize, 'nearest');

validIdx = testLabelFinal ~= 19;
pixelAccuracy = sum(predictedMaskFinal(validIdx) == testLabelFinal(validIdx)) / sum(validIdx, 'all');
fprintf('U-Net模型在测试图上的有效像素准确率: %.2f%%\n', pixelAccuracy*100);

cmap = cityscapes_trainid_colormap(); 
predictedRGB = label2rgb(predictedMaskFinal, cmap, 'k');

figure('Name', 'U-Net Final Result on Full Dataset');
imshowpair(imresize(testImage, 0.25), predictedRGB, 'montage');
title(sprintf('左: 原图 | 右: U-Net (完整数据训练) 预测结果 (Acc: %.2f%%)', pixelAccuracy*100));


%% 辅助函数
function labelFiles = findLabelFiles(imageFiles, imgSuffix, labelSuffix)
    numFiles = numel(imageFiles);
    labelFiles = cell(numFiles, 1);
    for i = 1:numFiles
        current_image_file = imageFiles{i};
        [image_path, image_basename, ~] = fileparts(current_image_file);
        common_basename = strrep(image_basename, imgSuffix, '');
        label_basename = [common_basename, labelSuffix];
        label_path = strrep(image_path, 'leftImg8bit', 'gtFine');
        labelFiles{i} = fullfile(label_path, [label_basename, '.png']);
    end
end

function dataOut = preprocessData(data, imageSize)
    % imageSize 现在可能是 [H, W, 3]
    data{1} = imresize(data{1}, imageSize(1:2)); % 图像缩放到 [H, W]
    data{2} = imresize(data{2}, imageSize(1:2), 'nearest'); % 标签也缩放到 [H, W]
    dataOut = data;
end

function cmap = cityscapes_trainid_colormap()
    colors_uint8 = [
        128, 64, 128;  % 0 road
        244, 35, 232;  % 1 sidewalk
        70, 70, 70;    % 2 building
        102, 102, 156; % 3 wall
        190, 153, 153; % 4 fence
        153, 153, 153; % 5 pole
        250, 170, 30;  % 6 traffic light
        220, 220, 0;   % 7 traffic sign
        107, 142, 35;  % 8 vegetation
        152, 251, 152; % 9 terrain
        70, 130, 180;  % 10 sky
        220, 20, 60;   % 11 person
        255, 0, 0;     % 12 rider
        0, 0, 142;     % 13 car
        0, 0, 70;      % 14 truck
        0, 60, 100;    % 15 bus
        0, 80, 100;    % 16 train
        0, 0, 230;     % 17 motorcycle
        119, 11, 32    % 18 bicycle
    ];
    cmap = double(colors_uint8) / 255.0;
end