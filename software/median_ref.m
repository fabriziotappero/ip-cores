% +----------------------------------------------------------------------------
% Universidade Federal da Bahia
% ------------------------------------------------------------------------------
% PROJECT: FPGA Median Filter
% ------------------------------------------------------------------------------
% FILE NAME            : median_ref.m
% AUTHOR               : João Carlos Bittencourt
% AUTHOR'S E-MAIL      : joaocarlos@ieee.org
% -----------------------------------------------------------------------------
% RELEASE HISTORY
% VERSION  DATE        AUTHOR        DESCRIPTION
% 1.0      2013-08-27  joao.nunes    initial version
% -----------------------------------------------------------------------------
% KEYWORDS: median, filter, image processing
% -----------------------------------------------------------------------------
% PURPOSE: Reference model for Median Filter.
% -----------------------------------------------------------------------------

% This is only a simple verification reference model based on default Median Filter

% Clear environment
clc
clear
% Set-up vectors
% I have set the vector to size 12 in order to perform a basic testbench.
% result = zeros(227,227);
img_ref = imread('images/image22.jpg');

img_ref = rgb2gray(img_ref);
[width, height] = size(img_ref);
% Add one column with zeros for pipelining verification purpose.
% The hardware assumes that, in the first round in a row, previous values are zeros.
img = zeros(width+1,width+1);
for i = 1 : height,
     img(i,2:width+1) = img_ref(i, 1:width);
end


% Default Median Algorithm
window_width = 3;
window_height = 3;
edgex = floor(window_width/2);
edgey = floor(window_height/2);
tic
for x = edgex : width - edgex,
    for y = edgey : height - edgey,
        temp = zeros(edgex,edgey);
        for fx = 1 : window_width,
            for fy = 1 : window_height,
                temp(fx,fy) = img(x + fx - edgex, y + fy - edgey);
            end       
        end
        temp = reshape(temp.',1,[]);
        srt = sort(temp); % remove comma to view step by step outputs
        result(x,y) = srt(5);
    end
end
toc
wtime = toc
fprintf ( 1, '  MY_PROGRAM took %f seconds to run.\n', wtime );

%result
imshow(mat2gray(result));
imwrite(mat2gray(result), 'images/image22_median.jpg', 'jpg');

