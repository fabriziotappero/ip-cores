#include <stdio.h>
#include "gradient.h"

int main(int argc, char **argv)
{
	int i=0;
	while (i<32)
	{
		unsigned char r=header_data_cmap[header_data[i]][0];
		unsigned char g=header_data_cmap[header_data[i]][1];
		unsigned char b=header_data_cmap[header_data[i]][2];
		printf("@db $%04x;", ((r&0xF8)<<8)|((g&0xFC)<<5)|(b>>3));
		if ((i&3)==3)
			printf("\n");
		else
			printf(" ");
		i++;
	}
	return 0;
}

