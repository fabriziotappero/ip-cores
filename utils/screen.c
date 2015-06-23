#include "SDL.h"
#include <stdio.h>

unsigned short myPixels[320*240];

int hex2num(char c)
{
	if (c>='0' && c<='9')
		return c-'0';
	if (c>='a' && c<='f')
		return c-'a'+10;
	if (c>='A' && c<='F')
		return c-'A'+10;
	printf("Bad hex:%c\n", c);
	return 0;
}

int main(int argc, char* argv[])
{
	FILE *f;
    SDL_Window *window;
	SDL_Renderer *ren;
	SDL_Texture *tex;
	unsigned short curReg=0;
	unsigned short curData=0;
	int curRecv=0;
	int curX=0;
	int curY=0;
	int curIdx=0;
	if (argc!=2)
	{
		printf("Usage: screen.out simulation.log\n");
        return 1;
	}
	f=fopen(argv[1],"r");
	if (!f)
	{
		printf("Couldn't open %s\n", argv[1]);
        return 1;
	}
	while (1)
	{
		char line[1024];
		char *start;
		if (!fgets(line, sizeof(line)-1, f))
		{
			break;
		}
		start=strchr(line, 'P');
		if (start && start[1]=='E' && start[2]==':')
		{
			int lcdWR=start[3]-'0';
			int lcdCS=start[4]-'0';
			int lcdReset=start[6]-'0';
			if (lcdCS==0 && lcdReset==1 && lcdWR==0)
			{
				int lcdRS=start[5]-'0';
				char *data=strchr(start, 'D');
				unsigned char d;
				if (data && data[1]==':')
				{
					d=(hex2num(data[2])<<4)|hex2num(data[3]);
				}
				if (lcdRS==0)
				{
					if (curRecv>=2)
						curRecv=0;
					curRecv++;
					curReg<<=8;
					curReg|=d;
				}
				else
				{
					curRecv++;
					curData<<=8;
					curData|=d;
					if (curRecv>=4 && !(curRecv&1))
					{
						if (curReg==0x22)
						{
							myPixels[curIdx%(320*240)]=curData;
							curIdx++;
						}
						else if (curReg==0x20)
						{
							curX=curData;
							curIdx=curY*240+curX;
						}
						else if (curReg==0x21)
						{
							curY=curData;
							curIdx=curY*240+curX;
						}
					}
				}
			}
		}
	}
    SDL_Init(SDL_INIT_VIDEO);
    window = SDL_CreateWindow("TFTLCD",SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,240,320,SDL_WINDOW_SHOWN);
    if (window == NULL)
	{
        printf("Could not create window: %s\n", SDL_GetError());
        return 1;
    }
	ren = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (ren == NULL)
	{
        printf("Could not create renderer: %s\n", SDL_GetError());
		return 1;
	}
	tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_RGB565, SDL_TEXTUREACCESS_STREAMING, 240, 320);
	if (tex == NULL)
	{
        printf("Could not create texture: %s\n", SDL_GetError());
		return 1;
	}
	SDL_UpdateTexture(tex, NULL, myPixels, 240*sizeof(myPixels[0]));
	SDL_RenderClear(ren);
	SDL_RenderCopy(ren, tex, NULL, NULL);
	SDL_RenderPresent(ren);
    SDL_Delay(10000);
	SDL_DestroyTexture(tex);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
