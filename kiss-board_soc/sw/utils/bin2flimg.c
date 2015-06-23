#include <stdio.h>
#include <stdlib.h>
 
int main(int argc, char **argv)
{

	FILE  *fd;
	int c, j, width;
	unsigned long word;

	if(argc < 3) {
		fprintf(stderr,"no input file specified\n");
		exit(1);
	}
	if(argc > 3) {
		fprintf(stderr,"too many input files (more than one) specified\n");
		exit(1);
	}
	
	width = atoi(argv[1]);

	fd = fopen( argv[2], "r" );
	if (fd == NULL) {
		fprintf(stderr,"failed to open input file: %s\n",argv[1]);
		exit(1);
	}

	while (!feof(fd)) {
                j = 0;
		word = 0;
                while (j < width) {
			c = fgetc(fd);
                        if (c == EOF) {
                                c = 0;
                        }
			word = (word << 8) + c;
                        j++;
                }
		if(width == 1)	
			printf("%.2lx\n", word);
		else if(width == 2)
			printf("%.4lx\n", word);
		else
			printf("%.8lx\n", word);
        }
	return 0;
}	
