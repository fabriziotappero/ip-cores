#include "orgfx.h"

void orgfx_print_reg(unsigned int xOffset, unsigned int yOffset, unsigned int reg32)
{
	unsigned int bit, x, y;
	for(bit = 0; bit < 32; ++bit)
	{
		int color = 0xffffffff;
		if(reg32 & (1 << (31-bit)))
			color = 0xf800f800;

		for(y = 0; y < 10; ++y)
			for(x = 0; x < 10; x+=2)
                orgfx_set_pixel(x + xOffset, y + yOffset, color);

		xOffset += 12;
	}
}

