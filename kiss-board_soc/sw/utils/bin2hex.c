#include <stdio.h>
#include <stdlib.h>

/* Number of bytes before line is broken
   For example if target flash is 8 bits wide,
   define BREAK as 1. If it is 16 bits wide,
   define it as 2 etc.
*/
#define BREAK 1
 
int main(int argc, char **argv)
{

	FILE  *fd;
	int c;
	int i = 0;

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

	while ((c = fgetc(fd)) != EOF) {
		printf("%.2x", (unsigned int) c);
		if (++i == BREAK) {
			printf("\n");
			i = 0;
		}
        }

	return 0;
}	
