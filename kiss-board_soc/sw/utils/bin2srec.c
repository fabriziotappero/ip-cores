#include <stdio.h>
#include <stdlib.h>
 
#define SMARK "S214"
#define SADDR 0x000000
#define INIT_ADDR 0x100100
#define SCHKSUM 0xff

int main(int argc, char **argv)
{

	FILE  *fd;
	int c, j;
	unsigned long addr = INIT_ADDR;
        unsigned char chksum;

	if(argc < 2) {
		fprintf(stderr,"no input file specified\n");
		exit(1);
	}
	if(argc > 2) {
		fprintf(stderr,"too many input files (more than one) specified\n");
		exit(1);
	}

	fd = fopen( argv[1], "r" );
	if (fd == NULL) {
		fprintf(stderr,"failed to open input file: %s\n",argv[1]);
		exit(1);
	}

	while (!feof(fd)) {
                j = 0;
                chksum = SCHKSUM;
                printf("%s%.6lx", SMARK, addr);
                while (j < 16) {
			c = fgetc(fd);
                        if (c == EOF) {
                                c = 0;
                        }
                        printf("%.2x", c);
                        chksum -= c;
                        j++;
                }

                chksum -= addr & 0xff;
                chksum -= (addr >> 8) & 0xff;
                chksum -= (addr >> 16) & 0xff;
                chksum -= 0x14;
                printf("%.2x\r\n", chksum);
                addr += 16;
        }
	return 0;
}	
