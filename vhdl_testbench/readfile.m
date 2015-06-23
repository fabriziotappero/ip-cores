 
currentFile = sprintf('outputdata');
FID = fopen(currentFile);

    c=fread(FID);
fclose(FID);

c=reshape(c,4,length(c)/4);
c=c(1,:);
c=c';
c=reshape(c,640,480);
c=c';

currentFile = sprintf('inputdata');
FID = fopen(currentFile);

    d=fread(FID);
fclose(FID);

d=reshape(d,4,length(d)/4);
d=d(1,:);
d=d';
d=reshape(d,640,480);
d=d';

imshow(uint8(c))
figure
imshow(uint8(d))

	