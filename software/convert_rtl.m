% +----------------------------------------------------------------------------
% Universidade Federal da Bahia
% ------------------------------------------------------------------------------
% PROJECT: FPGA Median Filter
% ------------------------------------------------------------------------------
% FILE NAME            : convert_rtl.m
% AUTHOR               : João Carlos Bittencourt
% AUTHOR'S E-MAIL      : joaocarlos@ieee.org
% -----------------------------------------------------------------------------
% RELEASE HISTORY
% VERSION  DATE        AUTHOR        DESCRIPTION
% 1.0      2013-08-27  joao.nunes    initial version
% 2.0	   2013-09-03  laue.rami     fix problem with vec2mat fucntion usage
% -----------------------------------------------------------------------------
% KEYWORDS: median, filter, image processing
% -----------------------------------------------------------------------------
% PURPOSE: Convert a RTL memory in an image matrix
% -----------------------------------------------------------------------------

clc 
clear 

id = fopen('image.hex','r');

for i=1:102400 % vector width
   image_rtl(i,1) = fscanf(id, '%c', 1);
   image_rtl(i,2) = fscanf(id, '%c', 1);
   lixo(1) = fscanf(id, '%c', 1);
end


% for i=1:51984
%     image(i) = hex2dec(image_rtl(i,:));
% end
var = hex2dec(image_rtl);

count=1;
for i=1:320 % height
    for j=1:320 % width
       foto(i,j)= var(count);
       count=count+1;
    end
end
foto = foto;
% image = vec2mat(image,228);
a = mat2gray(foto);
imshow(mat2gray(foto));
imwrite(a, 'image_transform.jpg', 'jpeg');

fclose(id);