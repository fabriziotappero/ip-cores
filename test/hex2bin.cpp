// Author(s)  : Ke Xu
// Email	    : eexuke@yahoo.com
// Description: Convert text file to binary (.yuv) file
// Copyright (C) 2008 Ke Xu

#include <stdio.h>
int main ()
{
	int buffer;
	int i;
	FILE * inFile;
	FILE * outFile;
	inFile  = fopen ("C:/xxx/xxx/nova_display.log","r");
	outFile = fopen ("C:/xxx/xxx/nova300.yuv", "w+b");
	
	//1	  frame:9504 x 32bit
	//300 frame:9504 x 300 x 32 bit = 2851200 x 32bit
	for (i = 0; i < 2851200; i++)
	{
		fscanf  (inFile,"%x",&buffer);
		fwrite  (&buffer,4,1,outFile);
	}
	fclose (inFile);
	fclose (outFile);
  return 0;
}

