#include <stdio.h>
#include "zfont2.h"

unsigned char data[128][10];

void calculateKeyboard(char *output, char *line1, int s)
{
		int x=0;
		int g=0;
		int h=s/2;
		int sections=1;
		char *sep=strchr(line1,'|');
		while (sep)
		{
			sections+=2;
			sep=strchr(sep+1,'|');
		}
		g=120-sections*h+h;
		while (*line1)
		{
			int w=0;
			sep=line1;
			if (*sep=='|')
				w=data['|'][0];
			else
			{
				while (*sep!='|' && *sep!='\0')
				{
					w+=data[*sep][0];
					sep++;
				}
			}
			while (x+w/2<g)
			{
				x+=data[32][0];
				*(output++)=' ';
			}
			if (*line1=='|')
			{
				x+=data[*line1][0];
				*(output++)=*(line1++);
			}
			else
			{
				while (*line1!='|' && *line1!='\0')
				{
					x+=data[*line1][0];
					*(output++)=*(line1++);
				}
			}
			g+=s;
		}
		*(output++)=0;

}

void fontCreate()
{
	int waiting=0;
	int i=32;
	int x;
	memset(data, 0, sizeof(data));
	for (x=0; x<width; x++)
	{
		if (header_data[10*width+x])
		{
			int k;
			for (k=1; k<10; k++)
			{
				data[i][k]=data[i][k]<<1;
				data[i][k]|=header_data[k*width+x];
			}
			data[i][0]++;
			waiting=0;
		}
		else if (!waiting)
		{
			int y=0;
			for (y=1; y<10; y++)
			{
				data[i][y]<<=8-data[i][0];
			}
			data[i][0]++;
			printf("%d(%c):\n", i, i);
			printf("Adv: %d\n", data[i][0]);
			for (y=0; y<9; y++)
			{
				printf("%d%d%d%d%d%d%d%d\n",
						(data[i][y+1]&128)==0?0:1,
						(data[i][y+1]&64)==0?0:1,
						(data[i][y+1]&32)==0?0:1,
						(data[i][y+1]&16)==0?0:1,
						(data[i][y+1]&8)==0?0:1,
						(data[i][y+1]&4)==0?0:1,
						(data[i][y+1]&2)==0?0:1,
						(data[i][y+1]&1)==0?0:1);
			}
			i++;
			waiting=1;	
		}
	}

	char outputBuffer[1024];
	int s=240/20;
	printf("Strings for BIOS for making the keyboard:\n");
	calculateKeyboard(outputBuffer, "q|w|e|r|t|y|u|i|o|p", s);
	printf("@print \"%s\n\";\n", outputBuffer);
	calculateKeyboard(outputBuffer, "a|s|d|f|g|h|j|k|l", s);
	printf("@print \"%s\n\";\n", outputBuffer);
	calculateKeyboard(outputBuffer, "z|x|c|v|b|n|m|,", s);
	printf("@print \"%s\n\";\n", outputBuffer);
	calculateKeyboard(outputBuffer, "Q|W|E|R|T|Y|U|I|O|P", s);
	printf("@print \"%s\n\";\n", outputBuffer);
	calculateKeyboard(outputBuffer, "A|S|D|F|G|H|J|K|L", s);
	printf("@print \"%s\n\";\n", outputBuffer);
	calculateKeyboard(outputBuffer, "Z|X|C|V|B|N|M|,", s);
	printf("@print \"%s\n\";\n", outputBuffer);
	s=40;
	calculateKeyboard(outputBuffer, "Delete|Space|Enter", s);
	printf("@print \"%s\n\";\n", outputBuffer);
}

int main()
{
	fontCreate();
	FILE *f=fopen("zfont.dat", "w");
	fwrite(data, sizeof(data), 1, f);
	fclose(f);
	return 0;
}
