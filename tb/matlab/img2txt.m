filename='test';
filenamet=strcat(filename,'.txt');

I = imread(filename,'bmp');

IYUV=rgb2ycbcr(I);

fid = fopen(filenamet,'w+');
[X,Y,Z] = size(I);
fprintf(fid, '%d\n',Z);  % number of image components
fprintf(fid, '%d\n',X);  % lines
fprintf(fid, '%d\n',Y);	 % pixels in line
for x = 1:X
   for y = 1:Y
     for z = 1:Z
       R = int16(I(x,y,1));
       G = int16(I(x,y,2));
       B = int16(I(x,y,3));
       % Y
       if z == 1
         sample = (0.299*R)+(0.587*G)+(0.114*B);
       % Cb
       elseif z == 2
         sample = (-0.1687*R)-(0.3313*G)+(0.5*B)+128;
       % Cr
       elseif z == 3
         sample = (0.5*R)-(0.4187*G)-(0.0813*B)+128;
       end      
       if sample > 255
         sample = 255;
       elseif sample < 0
         sample = 0;
       end
       ID(x,y,z) = sample;
       
       %sample = IYUV(x,y,z);
       sample = I(x,y,z);
       
       if sample < 16
         fprintf(fid, '0%x', double(sample));
       else
      	 fprintf(fid, '%x', double(sample));
       end;
   	end;     
   end;
   fprintf(fid,'\n');
end;
fclose(fid);
