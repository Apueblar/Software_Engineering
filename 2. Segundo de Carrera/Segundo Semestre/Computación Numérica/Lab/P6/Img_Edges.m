%% Detect Image Edges
clear
close all
clc

% Read the images
% img = imread('Qatar1.jpg');
img = imread('agora.jpg');
% imshow(img)
% Ir = img(:,:,1);
% figure
% imshow(Ir) % Red
% Ig = img(:,:,2);
% figure
% imshow(Ig) % Green
% Ib = img(:,:,3);
% figure
% imshow(Ib) % Blue

I = double(rgb2gray(img)); % Mean -> Numerical Matrix
% figure
% imshow(I)

% Derivatives
hx = 1; % pixels
hy = 1; % pixels
df_dx = (I(2:end,:) - I(1:end-1,:)) / hx;
df_dx_end = (I(end,:) - I(end - 1,:)) / hx; % Last Row
df_dx = [df_dx; df_dx_end];

df_dy = (I(:,2:end) - I(:,1:end-1)) / hx;
df_dy_end = (I(:,end) - I(:,end-1)) / hy; % Last Col
df_dy = [df_dy df_dy_end];

% To remove the last col instead of adding the last
% df_dx(:,end)= []; df_dy(end,:) = [];

grad_I = sqrt(df_dx.^2 + df_dy.^2); % edges of I
figure, imshow(uint8(grad_I))
figure, imshow(uint8(df_dx))
figure, imshow(uint8(df_dy))







