% =========================================================================
% Simple demo codes for image super-resolution via sparse representation
%
% Reference
%   J. Yang et al. Image super-resolution as sparse representation of raw
%   image patches. CVPR 2008.
%   J. Yang et al. Image super-resolution via sparse representation. IEEE 
%   Transactions on Image Processing, Vol 19, Issue 11, pp2861-2873, 2010
%
% Jianchao Yang
% ECE Department, University of Illinois at Urbana-Champaign
% For any questions, send email to jyang29@uiuc.edu
% =========================================================================

clear; clc;
imfiles = glob('C:\MATLAB_work\SotA_DATA\Testing',{'*.bmp','*.jpg','*.png'});
% load dictionary
load('Dictionary/D_1024_0.15_5.mat');
% set parameters
lambda = 0.2;                   % sparsity regularization
overlap = 4;                    % the more overlap the better (patch size 5x5)
up_scale = 2;                   % scaling factor, depending on the trained dictionary
maxIter = 20;                   % if 0, do not use backprojection
bb_psnr = zeros(numel(imfiles),1);
sp_psnr = zeros(numel(imfiles),1);
bb_ssim = zeros(numel(imfiles),1);
sp_ssim = zeros(numel(imfiles),1);
bb_fsim = zeros(numel(imfiles),1);
sp_fsim = zeros(numel(imfiles),1);

parfor i = 1:numel(imfiles)
% read test image
im_l = imread(imfiles{i});
im_l = imresize(im_l,1/2,'bicubic');
% change color space, work on illuminance only
im_l_ycbcr = rgb2ycbcr(im_l);
im_l_y = im_l_ycbcr(:, :, 1);
im_l_cb = im_l_ycbcr(:, :, 2);
im_l_cr = im_l_ycbcr(:, :, 3);

% image super-resolution based on sparse representation
[im_h_y] = ScSR(im_l_y, 2, Dh, Dl, lambda, overlap);
[im_h_y] = backprojection(im_h_y, im_l_y, maxIter);

% upscale the chrominance simply by "bicubic" 
[nrow, ncol] = size(im_h_y);
im_h_cb = imresize(im_l_cb, [nrow, ncol], 'bicubic');
im_h_cr = imresize(im_l_cr, [nrow, ncol], 'bicubic');

im_h_ycbcr = zeros([nrow, ncol, 3]);
im_h_ycbcr(:, :, 1) = im_h_y;
im_h_ycbcr(:, :, 2) = im_h_cb;
im_h_ycbcr(:, :, 3) = im_h_cr;
im_h = ycbcr2rgb(uint8(im_h_ycbcr));

% bicubic interpolation for reference
im_b = imresize(im_l, [nrow, ncol], 'bicubic');

% read ground truth image
im = imread(imfiles{i});

% compute PSNR for the illuminance channel
bb_rmse = compute_rmse(im, im_b);
sp_rmse = compute_rmse(im, im_h);

bb_psnr(i) = 20*log10(255/bb_rmse);
sp_psnr(i) = 20*log10(255/sp_rmse);

bb_ssim(i) = ssim(im_b,im);
sp_ssim(i) = ssim(im_h,im);

bb_fsim(i) = fsim(im_b,im);
sp_fsim(i) = fsim(im_h,im);

% show the images
% figure, imshow(im_h);
% title('Sparse Recovery');
% figure, imshow(im_b);
% title('Bicubic Interpolation');
end

for i = 1:numel(imfiles)
disp(['For ' imfiles{i} '\n']);
fprintf('PSNR for Bicubic Interpolation: %f dB\n', bb_psnr(i));
fprintf('PSNR for Sparse Representation Recovery: %f dB\n', sp_psnr(i));
fprintf('SSIM for Bicubic Interpolation: %f\n', bb_ssim(i));
fprintf('SSIM for Sparse Representation Recovery: %f\n', sp_ssim(i));
fprintf('FSIM for Bicubic Interpolation: %f\n', bb_fsim(i));
fprintf('FSIM for Sparse Representation Recovery: %f\n\n', sp_fsim(i));
end