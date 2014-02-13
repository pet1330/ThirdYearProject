s2 = double(imread('tooth1.jpg'));
s1 = s2(:,:,3);
figure(1)
imagesc(s1)
colormap(gray)
axis image
title('Original Digital Dental X-Ray Image')
figure(2)
T = 10;
de1 = double_S2D(s1,T);
imagesc(de1)
colormap(gray)
axis image
title('Double-Density Method')
figure(3)
re1 = doubleden_R2D(s1,T);
imagesc(re1)
colormap(gray)
axis image
title('Double-Density Dual-Tree Real Method')
figure(4)
ce1 = doubledual_C2D(s1,T);
imagesc(ce1)
colormap(gray)
axis image
title('Double-Density Dual-Tree Complex Method')
figure(5)
s = s1(:,2,1);
de = de1(:,2,1);
re = re1(:,2,1);
ce = ce1(:,2,1);
subplot(4,1,1), plot(s)
axis([0 512 0 200])
title('Noisy Signal')
subplot(4,1,2), plot(de)
axis([0 512 0 200])
title('Denoised by Double-Density Method')
subplot(4,1,3), plot(re)
title('Denoised by Double-Density Dual-Tree Real Method')
axis([0 512 0 200])
subplot(4,1,4), plot(ce)
axis([0 512 0 200])
title('Denoised by Double-Density Dual-Tree Complex Method')
