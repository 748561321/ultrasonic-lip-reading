% 创建一个新的图形窗口，并设置布局为 4 行 6 列的表格
t_layout = tiledlayout(1, 2);
t_layout.TileSpacing = 'none'; % 设置子图间距为零
t_layout.Padding = 'none'; % 设置子图与图形窗口边缘的间隔为零
% 循环遍历表格的每个位置，并在每个位置插入一张图片

% 在下一个位置创建子图
nexttile;
% 图片路径
image_path = sprintf('C:/Users/city/Desktop/48/%d.jpg', 1);
% 读取图片
image_data = imread(image_path);
% 在子图中显示图片
fixed_size = [100, 150];
 resized_image = imresize(image_data, fixed_size);
 imshow( resized_image);
title("[ɑ:] ", 'FontSize', 32)

nexttile;
% 图片路径
image_path = sprintf('C:/Users/city/Desktop/48/%d.jpg', 37);
% 读取图片
image_data = imread(image_path);
% 在子图中显示图片
fixed_size = [100, 150];
 resized_image = imresize(image_data, fixed_size);
 imshow( resized_image);
title("[r] ", 'FontSize', 32)


figure(gcf); % 获取当前图形对象并显示