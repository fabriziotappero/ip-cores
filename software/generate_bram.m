% +----------------------------------------------------------------------------
% Universidade Federal da Bahia
% ------------------------------------------------------------------------------
% PROJECT: FPGA Median Filter
% ------------------------------------------------------------------------------
% FILE NAME            : generate_bram.m
% AUTHOR               : João Carlos Bittencourt
% AUTHOR'S E-MAIL      : joaocarlos@ieee.org
% -----------------------------------------------------------------------------
% RELEASE HISTORY
% VERSION  DATE        AUTHOR        DESCRIPTION
% 1.0      2013-09-02  laue.rami     initial version
% -----------------------------------------------------------------------------
% KEYWORDS: median, filter, image processing
% -----------------------------------------------------------------------------
% PURPOSE: Convert an image into a 3 block memory to be used in RTL.
% -----------------------------------------------------------------------------

clear
%read image
a = imread('images/image55.jpg');
%essa parte eh para deixar a imagem certinha 224x224
tmp = size(a);
lin = tmp(1,1);
col = tmp(1,2);
for i=1:lin-1
    for j=1:col-1
       a_mod(i,j) = a(i,j); 
    end
end
%obtain image size
size_image = size(a_mod);
%create colum zeros
zero_coluna = zeros(size_image(1), 1);
%junta coluna de zeros na esquerda
left_edge = [zero_coluna a_mod];
%junta coluna de zeros na direita
both_edge = [left_edge zero_coluna];
%obtain image size
size_image = size(both_edge);
%create line zeros
zero_linha = zeros(1, size_image(2));
%junta linha de zero na parte de cima
up_edge = [zero_linha ; both_edge];
%junta linha de zero na parte de baixo
edge_image = [up_edge ; zero_linha];
%guarda o numero de linhas e o numero de colunas
temp = size(edge_image);
num_linhas = temp(1,1);
num_colunas = temp(1,2);
%abre arquivo para salvar a memoria 
fileID_a = fopen('memA_hex.txt','w');
fileID_b = fopen('memB_hex.txt','w');
fileID_c = fopen('memC_hex.txt','w');
%transposta da imagem
new_image = edge_image.';
%converte para hexadecimal
image_hex = dec2hex(new_image);
%obtain o tamanho da imagem
aux = size(image_hex);
%obtain numero de pixels
num_pixels = aux(1,1);

image_conv = reshape(edge_image.',320,[]);
for i = 1 : size(image_conv)
    image_hex(i) = dec2hex(image_conv(i));
end

for i = 1 : size(image_conv)
    image_conv(i) = hex2dec(image_hex(i));
end
image = vec2mat(image_conv.',320);

imshow(image);

count = 1; 

acc = num_linhas*3;
loops = num_pixels/acc;

for m=1:loops

    %para a memoria A - grava
    for ma=1:(num_linhas/4)
       for na=1:4
          fprintf(fileID_a,'%s',image_hex(count,:));
          count=count+1;
       end
       fprintf(fileID_a,'\n');
    end
    
    %para a memoria B - grava
    for ma=1:(num_linhas/4)
       for na=1:4
          fprintf(fileID_b,'%s',image_hex(count,:));
          count=count+1;
       end
       fprintf(fileID_b,'\n');
    end

    %para a memoria C - grava
    for ma=1:(num_linhas/4)
       for na=1:4
          fprintf(fileID_c,'%s',image_hex(count,:));
          count=count+1;
       end
       fprintf(fileID_c,'\n');
    end
end

fclose(fileID_a);
fclose(fileID_b);
fclose(fileID_c);

