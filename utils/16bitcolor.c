#include <stdio.h>

unsigned short ToU16(unsigned long a)
{
  unsigned short out=(a>>8)&0xF800;
  out|=(a>>5)&0x07E0;
  out|=(a>>3)&0x001F;
  return out;
}

int main(int argc, char **argv)
{
	int c;
	if (argc!=2)
	{
		printf("Usage: 16bitcolor hexcolor\n");
		return 1;
	}
	sscanf(argv[1], "%x", &c);
	printf("0x%06x->0x%04x\n", c, ToU16(c));
	return 0;
}
