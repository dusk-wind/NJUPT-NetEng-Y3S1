% =========================================================================
% 课设终极版: 在完整Cityscapes数据集上训练U-Net模型 (纯训练脚本)
% =========================================================================
clear; clc; close all;

%% 1. 数据准备 (加载完整训练集)
% -------------------------------------------------------------------------
fprintf('>>> 步骤 1: 准备深度学习数据加载器 (完整数据集) <<<\n');

datasetDir = 'D:\AAAAA\erfnet_pytorch-master\dataset'; 
trainImageDir = fullfile(datasetDir, 'leftImg8bit', 'train');
valImageDir = fullfile(datasetDir, 'leftImg8bit', 'val'); % 验证集路径

imdsTrain = imageDatastore(trainImageDir, 'FileExtensions', '.png', 'IncludeSubfolders', true);
imdsVal = imageDatastore(valImageDir, 'FileExtensions', '.png', 'IncludeSubfolders', true);

fprintf('正在扫描训练和验证标签文件...\n');
trainLabelFiles = findLabelFiles(imdsTrain.Files, '_leftImg8bit', '_gtFine_labelTrainIds');
valLabelFiles = findLabelFiles(imdsVal.Files, '_leftImg8bit', '_gtFine_labelTrainIds');

classNames = [ "road", "sidewalk", "building", "wall", "fence", ...
               "pole", "traffic_light", "traffic_sign", "vegetation", "terrain", ...
               "sky", "person", "rider", "car", "truck", "bus", "train", ...
               "motorcycle", "bicycle" ];
labelIDs = (0:18)';

pxdsTrain = pixelLabelDatastore(trainLabelFiles, classNames, labelIDs);
pxdsVal = pixelLabelDatastore(valLabelFiles, classNames, labelIDs); % 创建验证集标签加载器

dsTrain = combine(imdsTrain, pxdsTrain);
dsVal = combine(imdsVal, pxdsVal); % 创建验证集数据对

%% 2. 构建U-Net网络
% -------------------------------------------------------------------------
fprintf('>>> 步骤 2: 构建U-Net网络架构 <<<\n');
imageSize = [256, 512, 3]; 
numClasses = numel(classNames);
lgraph = unetLayers(imageSize, numClasses, 'EncoderDepth', 4, 'NumFirstEncoderFilters', 32);

%% 3. 设置训练参数 (恢复使用验证集)
% -------------------------------------------------------------------------
fprintf('>>> 步骤 3: 配置训练参数 <<<\n');

dsTrain = transform(dsTrain, @(data) preprocessData(data, imageSize));
dsVal = transform(dsVal, @(data) preprocessData(data, imageSize)); % 同样预处理验证集

% --- 恢复使用 ValidationData，以监控训练过程 ---
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 30, ...
    'MiniBatchSize', 4, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ValidationData', dsVal, ... % <--- 重新启用验证集
    'ValidationFrequency', 500, ...
    'ExecutionEnvironment', 'auto');
% --- 结束 ---

%% 4. 训练网络并保存
% -------------------------------------------------------------------------
model_filename = 'unet_full_dataset_model_zzz.mat';
if exist(model_filename, 'file')
    fprintf('发现已训练好的U-Net模型 "%s"，无需重新训练。\n', model_filename);
    fprintf('如需重新训练，请手动删除此文件后再次运行。\n');
else
    fprintf('>>> 步骤 4: 开始训练U-Net网络 (完整数据集) <<<\n');
    fprintf('这将是一个非常漫长的过程，请确保有充足的时间和强大的GPU...\n');
    [net, info] = trainNetwork(dsTrain, lgraph, options);
    save(model_filename, 'net');
    fprintf('U-Net模型训练完成并已保存为 "%s"！\n', model_filename);
end

%% 辅助函数 (必须保存在脚本的末尾)
% =========================================================================
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
    data{1} = imresize(data{1}, imageSize(1:2));
    data{2} = imresize(data{2}, imageSize(1:2), 'nearest');
    dataOut = data;
end