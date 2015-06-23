%uncomment if using Octave
%pkg load image 

a=imread('shapes2.bmp');
%a=imread('car.jpg');
%a=imread('radio.jpg');
a=imread('berlu.png');
a = rgb2gray(a);
a=a';
b=a(:);
 
currentFile = sprintf('inputdata');
FID = fopen(currentFile, 'w');

 for i=1:1:length(b)
     fwrite(FID,b(i),'uint8');
     fwrite(FID,0,'uint8');
     fwrite(FID,0,'uint8');
     fwrite(FID,0,'uint8');
 end

fclose(FID);
    