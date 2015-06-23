filename='lena512';
filenamet=strcat(filename,'.txt');

I = imread(filename,'bmp');
fid = fopen(filenamet,'w+');
[X,Y,Z] = size(I);
fprintf(fid, '%d\n',X);  % lines
fprintf(fid, '%d\n',Y);	 % pixels in line
for x = 1:X
   for y = 1:Y
      if I(x,y) < 16 
         fprintf(fid, '0%x', double(I(x,y)));
      else
      	fprintf(fid, '%x', double(I(x,y)));
   	end;     
   end;
   fprintf(fid,'\n');
end;
fclose(fid);
