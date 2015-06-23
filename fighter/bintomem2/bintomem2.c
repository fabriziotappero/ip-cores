#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <io.h>


int main(int argc, const char*argv[])
{
	char*p;
	int c, a = argc>1?strtoul(argv[1], &p, 0):0;
	unsigned char mem[65536];
	int size = 0;
	_setmode(0, _O_BINARY);
	memset(mem, 0, sizeof(mem));
	while ((c = getchar()) != EOF) {
		mem[a] = c;
		++ a;
	}
	{
		int mod, blk, bit, b, mask, m, ad, ad1;
		printf("parameter\n");
		for (mod = 0; mod < 0x10; ++mod) {
			mask = 1 << (mod & 7);
			ad = !(mod >> 3);
			for (blk = 0; blk < 0x40; ++ blk) {
				printf("\tD_%01X_%02X = 256'h", mod, blk);
				b = 0;
				m = 8;
				ad1 = ad + 512 - 2;
				for (bit = 0; bit < 256; ++bit, ad += 2, ad1 -= 2) {
//					printf("\nmem[%04X] (%02X) & %02X = %02X\n", ad1, mem[ad1], mask, mem[ad1] & mask);
					if (mem[ad1] & mask) b |= m;
					m >>= 1;
					if (!m) { printf("%X", b); m = 8; b = 0; }
				}
				printf("%c\n", (blk == 0x3F && mod == 0x0F)?';':',');
			}
			printf("\n");
		}
	}
	{
		int mod, blk;
		for (mod = 0; mod < 0x10; ++mod) {
			printf("\tRAM16Kx1#(");
			for (blk = 0; blk < 0x40; ++ blk) {
				printf("D_%01X_%02X%c", mod, blk, (blk == 0x3F)?')':',');
			}
			printf("\n\t\tram%X(CLK1, AB1x, CSM[%i], READ, DO1[%i], DI1[%i], CLK2, AB2, CS2, DO2[%i]);\n",
				mod, (mod >> 3), mod & 7, mod & 7, mod);
		}
	}
	return 0;
}
