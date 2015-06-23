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
	//int i = 0;
	
	if(argc < 2) {
		fprintf(stderr,"no input file specified\n");
		exit(1);
	}
	if(argc > 2) {
		fprintf(stderr,"too many input files (more than one) specified\n");
		exit(1);
	}

	{
		unsigned long int loop;
		unsigned long int count;

		fd = fopen( argv[1], "r" );

		for (loop=0;loop<4;loop++) {

			rewind(fd);
			
			if (fd == NULL) {
				fprintf(stderr,"failed to open input file: %s\n",argv[1]);
				exit(1);
			}
			count = 0;
			while ((c = fgetc(fd)) != EOF) {
				fputc(c,stdout);
				count++;
			}
			//while (count<131072) {
			while (count<262144) {
				fputc(0x00,stdout);
				count++;
			}

		}

		fclose(fd);

	}
	return 0;
}	
