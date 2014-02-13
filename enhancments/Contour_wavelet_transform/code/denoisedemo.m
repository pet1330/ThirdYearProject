function [output] = denoisedemo(option, im)
% DENOISEDEMO   Denoise demo
% Compare the denoise performance of wavelet and contourlet transforms
% Note: Noise standard deviation estimation of PDFB (function pdfb_nest)
% can take a while...

% Parameters
pfilt = '9-7';
dfilt = 'pkva';
nlevs = [0, 0, 4, 4, 5];    % Number of levels for DFB at each pyramidal level
th = 3;                     % lead to 3*sigma threshold denoising
rho = 3;                    % noise level

% Test image: the usual suspect...

im = im(:,:,2);
% X Y Width Height
%im = imcrop(im,[25 40 511 511]);
% DEBUG find size of image
%disp(size(im));
im = double(im) / 256;

% Generate noisy image.
sig = std(im(:));
sigma = sig / rho;
%nim = im + sigma * randn(size(im));


%%%%% Wavelet denoising %%%%%
% Wavelet transform using PDFB with zero number of level for DFB
y = pdfbdec(im, pfilt, dfilt, zeros(length(nlevs), 1));
[c, s] = pdfb2vec(y);

% Threshold (typically 3*sigma)
wth = th * sigma;
c = c .* (abs(c) > wth);

% Reconstruction
y = vec2pdfb(c, s);
wim = pdfbrec(y, pfilt, dfilt);


%%%%% Contourlet Denoising %%%%%
% Contourlet transform
y = pdfbdec(im, pfilt, dfilt, nlevs);
[c, s] = pdfb2vec(y);

% Threshold
% Require to estimate the noise standard deviation in the PDFB domain first
% since PDFB is not an orthogonal transform
nvar = pdfb_nest(size(im,1), size(im, 2), pfilt, dfilt, nlevs);

cth = th * sigma * sqrt(nvar);
% cth = (4/3) * th * sigma * sqrt(nvar);
% Slightly different thresholds for the finest scale
fs = s(end, 1);
fssize = sum(prod(s(s(:, 1) == fs, 3:4), 2));
cth(end-fssize+1:end) = (4/3) * cth(end-fssize+1:end);

c = c .* (abs(c) > cth);

% Reconstruction
y = vec2pdfb(c, s);
cim = pdfbrec(y, pfilt, dfilt);

if strcmp(option, 'contourlet')
    output = cim;
else
    if strcmp(option,'wavelet')
        output = wim;
    else
        output = im;
    end
    colormap('gray');
end