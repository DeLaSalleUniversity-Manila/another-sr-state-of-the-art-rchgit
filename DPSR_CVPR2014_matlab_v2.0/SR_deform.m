function [im_h_y] = SR_deform(lIm, nrow, ncol, Dic,para)
    norm_Dh = sqrt(sum(Dic.Dh.^2, 1));
    Dic.Dh = Dic.Dh./repmat(norm_Dh, size(Dic.Dh, 1), 1);
    norm_Dlow = sqrt(sum(Dic.Dlow.^2, 1));
    Dic.Dlow = Dic.Dlow./repmat(norm_Dlow, size(Dic.Dlow, 1), 1);
    norm_DHog = sqrt(sum(Dic.DHog.^2, 1));
    Dic.DHog = Dic.DHog./repmat(norm_DHog, size(Dic.DHog, 1), 1);

    lapfilter = -[0 1/4 0;1/4 -1 1/4;0 1/4 0];
    para.DL = generatecirclematall(lapfilter,zeros([para.hrpatchsize para.hrpatchsize] ));
    para.DL2 = para.DL*para.DL; 

    mIm = single(imresize(uint8(lIm),[nrow,ncol],'bicubic'));
    mImBP = backprojection(mIm,lIm,20);

    [nrowm, ncolm] = size(mIm);
    sstep = para.lrpatchsize-para.overlap;
    [X,Y] = meshgrid([3:sstep:nrowm-para.lrpatchsize-2,nrowm-para.lrpatchsize-2],[3:sstep:ncolm-para.lrpatchsize-2,ncolm-para.lrpatchsize-2]);
    gridx = X(:);
    gridy = Y(:);

    index = 1:length(gridx);
    
    PatchLowList = (zeros(size(Dic.Dlow,1),length(gridx)));
    MeanList = zeros(1,length(gridx));

    parfor n = index
        row = gridx(n);
        col = gridy(n);
        mPatch = mImBP(row:row+para.lrpatchsize-1, col:col+para.lrpatchsize-1);
        mMean = mean(mPatch(:));
        PatchLowList(:,n) = mPatch(:) - mMean; 
        MeanList(n) = mMean;
    end

    deformedPatches   = deformmatlab(single(PatchLowList(:,index)), Dic, para);

%     deformPatchesfull = zeros(size(Dic.Dlow,1),length(gridx)) ;
%     deformPatchesfull(:,index) = deformedPatches;
    hPatchacclist = zeros(size(Dic.Dh,1),length(gridx));
 	for n = index
        mPatch = PatchLowList(:,n);
        hPatch = deformedPatches(:,n);
        mPatch = reshape(mPatch,para.hrpatchsize, para.hrpatchsize);
        hPatch = reshape(hPatch,para.hrpatchsize, para.hrpatchsize);
    	alpha = mPatch(:)'*hPatch(:)/(hPatch(:)'*hPatch(:)+eps);
        hPatch = alpha*hPatch;
        hPatchacclist(:,n) = hPatch(:)+MeanList(n);
    end
    hIm = zeros(size(mIm));
    cntMat = zeros(size(mIm) );
    for n = index;
        row = gridx(n);
        col = gridy(n);
        hPatch = reshape(hPatchacclist(:,n),para.hrpatchsize,para.hrpatchsize);
        hIm(row:row+para.hrpatchsize-1, col:col+para.hrpatchsize-1) = hIm(row:row+para.hrpatchsize-1, col:col+para.hrpatchsize-1) + hPatch;
        cntMat(row:row+para.hrpatchsize-1,col:col+para.hrpatchsize-1) = cntMat(row:row+para.hrpatchsize-1,col:col+para.hrpatchsize-1) + 1;
    end
    idx = (cntMat < 1);
    hIm(idx) = mIm(idx);
    cntMat(idx) = 1;
    hIm = hIm./cntMat;
    fprintf('done..........\n');
    im_h_y = hIm;
end
