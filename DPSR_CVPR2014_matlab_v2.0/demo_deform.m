%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Single Image Super-resolution using Deformable Patches
% IEEE Conference on Computer Vision and Pattern Recognition, 2014. CVPR '14.
% Author: Yu Zhu, Yanning Zhang and Alan Yuille. {zhuyu1986@mail.nwpu.edu.cn, ynzhang@nwpu.edu.cn, yuille@stat.ucla.edu}
% Coded by Yu Zhu
% Version Date: Aug, 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function demo_deform()
    close all;
    clear;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    addpath('~/Lib/vlfeat-0.9.16/toolbox/');
    vl_setup();
    mex MaxHeapsort.cpp
    %matlabpool('open','local',8);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	para.upscale = 3;
    para.hrpatchsize = 7;
    para.overlap = 6;
    para.nSmp = 30000;
    para.prunvar = 10;
    para.lrpatchsize = para.hrpatchsize;
	para.mu = 0.1;
    para.HogNum = 128;
    para.elementused = 9;
    para.iternum = 10;
    para.rootpath = './';
    para.datapath = [para.rootpath 'Train/'];
    para.inputimagename = './Groundtruth/zebra.bmp';
    para.dictname ='D_random_spn30000_ps7_s3_var10';
    para.dictpath = ['./Dictionary/' para.dictname, '.mat'];
    %%%%%%%%%%%%%%%%%Patches Selection%%%%%%%%%%%%%%%%%%%%%
    if ~exist(para.dictpath,'file')
        [PatchesExtracted] = rnd_smp_patch_deform(para);
        fprintf('Data pruning done\n');
        [Dic] = TrainDlDhdic_random_ml(PatchesExtracted, para);
        save(para.dictpath, 'Dic');
    end
    %%%%%%%%%%%%%%%%%Testing%%%%%%%%%%%%%%%%%%%%%%
    im_o = imread(para.inputimagename);
    [nrow, ncol,dummy] = size(im_o);
    nrow = floor((nrow )/para.upscale)*para.upscale ;
    ncol = floor((ncol )/para.upscale)*para.upscale ;
    im_o=im_o(1:nrow,1:ncol,:);

    im_l = imresize(im_o,1/para.upscale,'bicubic');

    % change color space, work on illuminance only
    im_l_ycbcr = rgb2ycbcr(im_l);
    im_l_y = im_l_ycbcr(:, :, 1);
    im_l_cb = im_l_ycbcr(:, :, 2);
    im_l_cr = im_l_ycbcr(:, :, 3);

  	load(para.dictpath);
    [im_h_y] = SR_deform(im_l_y, nrow, ncol, Dic, para);
    %%%%%%%%%%%%%%%Post Processing%%%%%%%%%%%%%%%%%%%%%
    if para.overlap~=0
		im_h_y = uint8(im_h_y);
		[N, dummy] = Compute_NLM_Matrix( im_h_y , 3);
		NTN = N'*N*0.05;
		im_f = sparse(double((im_h_y(:))));
		for j = 1 : 30
		    im_f = im_f - NTN*im_f;
		end
		im_h_y = reshape(full(im_f), nrow, ncol);
		[im_h_y] = backprojection(im_h_y, im_l_y, 20);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % upscale the chrominance simply by "bicubic"
    im_h_cb = imresize(im_l_cb, [nrow, ncol], 'bicubic');
    im_h_cr = imresize(im_l_cr, [nrow, ncol], 'bicubic');

    im_h_ycbcr = zeros([nrow, ncol, 3]);
    im_h_ycbcr(:, :, 1) = im_h_y;
    im_h_ycbcr(:, :, 2) = im_h_cb;
    im_h_ycbcr(:, :, 3) = im_h_cr;
    im_h = ycbcr2rgb(uint8(im_h_ycbcr));

    % bicubic interpolation for reference
    im_b = imresize(im_l, [nrow, ncol], 'bicubic');

    % compute PSNR for the illuminance channel
   	deformpsnr = compute_psnr(im_o,im_h,'Deform');
	bicubicpsnr = compute_psnr(im_o,im_b,'Bicubic');
    figure;imshow(im_b); 
    figure;imshow(uint8(im_h));
    imwrite(uint8(im_h),'./res/res.bmp');
end
