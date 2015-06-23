#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "icons.h"

#define MIN(a,b) ((a)<(b)?(a):(b))

int main(int argc, char **argv)
{
	char *data=malloc(sizeof(header_data));
	char *p=data;
	FILE *f;
	int i=0;
	while (i<320)
	{
		*(p++)=0;
		*(p++)=(45.0f*sinf((3.14f/2.0f)*(160.0f-fabsf(160.0f-i))/160.0f));
		i++;
	}
	i=0;
	while (i<128)
	{
		unsigned char r=header_data_cmap[i][0];
		unsigned char g=header_data_cmap[i][1];
		unsigned char b=header_data_cmap[i][2];
		*(p++)=(r&0xF8)|(g>>5);
		*(p++)=((g<<3)&0xE0)|(b>>3);
		i++;
	}
	i=0;
	while (i<sizeof(header_data))
	{
		char c=header_data[i];
		int n=i+1;
		int count=1;
		while (n<sizeof(header_data) && header_data[n]==c)
		{
			count++;
			n++;
		}
		i+=count;
		if (count==1)
		{
			*(p++)=c;
		}
		else if (count==2)
		{
			*(p++)=c;
			*(p++)=c;
		}
		else
		{
			while (count)
			{
				*(p++)=c|0x80;
				*(p++)=MIN(255,count);
				count-=MIN(255,count);
			}
		}
	}
	printf("Before: %d After: %d Percent: %.1f%%\n", (int)(sizeof(header_data)+sizeof(header_data_cmap)), (int)(p-data), 100.0f*(p-data)/(float)(sizeof(header_data)+sizeof(header_data_cmap)));
	f=fopen("icons.dat", "w");
	fwrite(data, p-data, 1, f);
	fclose(f);
	free(data);
	return 0;
}
