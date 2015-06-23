#include <stdio.h>

unsigned char data[512*1024]={0};

#define CALLBACK_BASE 0x1E58B
#define INIT_CALLBACK CALLBACK_BASE+0
#define PRINT_CALLBACK CALLBACK_BASE+5
#define PRINTCHAR_CALLBACK CALLBACK_BASE+10
#define PRINTNUM_CALLBACK CALLBACK_BASE+15
#define READ_CALLBACK CALLBACK_BASE+20

char* roms[4]={
	"Zork1.z3",
	"hhgg.z3",
	"curses.z3",
	"Planetfa.z3"
};

int main()
{
	FILE *f;
	int i;
	for (i=0; i<4; i++)
	{
		f=fopen(roms[i], "rb");
		fread(&data[0x20000*i], 1, 0x20000, f);
		fclose(f);
		if (i==0)
		{
			f=fopen("icons.dat", "rb");
			fread(&data[0x20000*i+0x16800], 1, 30*1024, f);
			fclose(f);
		}
		f=fopen("zfont.dat", "rb");
		fread(&data[0x20000*i+0x1E000], 1, 0x500, f);
		fclose(f);
		f=fopen("encoding.txt", "rb");
		fread(&data[0x20000*i+0x1E500], 1, 0x80, f);
		fclose(f);
		data[0x20000*i+0x1E57F]=i;
		f=fopen("bios.z3", "rb");
		fseek(f, 0x1E580, SEEK_SET);
		fread(&data[0x20000*i+0x1E580], 1, 0x20000-0x1E580, f);
		fclose(f);
	}

	f=fopen("rom.z3","wb");
	fwrite(data, 1, sizeof(data), f);
	fclose(f);

	printf("Done\n");
}
