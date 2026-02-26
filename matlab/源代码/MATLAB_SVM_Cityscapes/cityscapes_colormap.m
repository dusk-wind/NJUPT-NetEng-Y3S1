function cmap = cityscapes_colormap()
%CITYSCAPES_COLORMAP Cityscapes 官方颜色映射表
%   cmap = CITYSCAPES_COLORMAP() 返回一个 N x 3 的矩阵，其中包含了
%   Cityscapes 数据集中每个类别ID对应的RGB颜色。
%   颜色值已经被归一化到 [0, 1] 范围内，可供 label2rgb 或 colormap 函数使用。
%   第 n 行对应的是 类别ID n-1 的颜色。

    % Cityscapes 类别颜色定义 (RGB: 0-255)
    % 索引从1开始，对应ID从0开始 (例如 cmap(8,:) 对应 ID 7 'road')
    colors_uint8 = [
        0, 0, 0;          % ID 0: unlabeled
        0, 0, 0;          % ID 1: ego vehicle
        0, 0, 0;          % ID 2: rectification border
        0, 0, 0;          % ID 3: out of roi
        0, 0, 0;          % ID 4: static
        111, 74, 0;       % ID 5: dynamic
        81, 0, 81;        % ID 6: ground
        128, 64, 128;     % ID 7: road
        244, 35, 232;     % ID 8: sidewalk
        250, 170, 160;    % ID 9: parking
        230, 150, 140;    % ID 10: rail track
        70, 70, 70;       % ID 11: building
        102, 102, 156;    % ID 12: wall
        190, 153, 153;    % ID 13: fence
        180, 165, 180;    % ID 14: guard rail
        150, 100, 100;    % ID 15: bridge
        150, 120, 90;     % ID 16: tunnel
        153, 153, 153;    % ID 17: pole
        153, 153, 153;    % ID 18: polegroup
        250, 170, 30;     % ID 19: traffic light
        220, 220, 0;      % ID 20: traffic sign
        107, 142, 35;     % ID 21: vegetation
        152, 251, 152;    % ID 22: terrain
        70, 130, 180;     % ID 23: sky
        220, 20, 60;      % ID 24: person
        255, 0, 0;        % ID 25: rider
        0, 0, 142;        % ID 26: car
        0, 0, 70;         % ID 27: truck
        0, 60, 100;       % ID 28: bus
        0, 0, 90;         % ID 29: caravan
        0, 0, 110;        % ID 30: trailer
        0, 80, 100;       % ID 31: train
        0, 0, 230;        % ID 32: motorcycle
        119, 11, 32;      % ID 33: bicycle
        -1, -1, -1        % ID -1 license plate (这是一个特殊值，我们用-1占位)
    ];

    % 将0-255范围的颜色值归一化到0-1范围
    cmap = double(colors_uint8) / 255.0;
    
    % 处理特殊值-1
    cmap(cmap<0) = 0;
end