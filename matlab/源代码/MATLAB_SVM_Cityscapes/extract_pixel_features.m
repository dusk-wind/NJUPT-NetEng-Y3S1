function features = extract_pixel_features(img)
    [h, w, ~] = size(img);
    numPixels = h * w;
    
    % 1. 颜色特征 (RGB, HSV, LAB)
    img_double = double(img);
    rgb = reshape(img_double, numPixels, 3) / 255;
    
    hsv = rgb2hsv(img);
    hsv = reshape(hsv, numPixels, 3);

    lab = rgb2lab(img);
    lab = reshape(lab, numPixels, 3);

    % 2. 位置特征 (归一化的x, y坐标)
    [X, Y] = meshgrid(1:w, 1:h);
    coords = [X(:)/w, Y(:)/h];
    
    % 3. 纹理特征 (5x5邻域标准差)
    gray_img = rgb2gray(img);
    texture_std = stdfilt(gray_img, ones(5));
    texture = double(texture_std(:)) / 255;
    
    % 组合所有特征
    features = [rgb, hsv, lab, coords, texture];
end