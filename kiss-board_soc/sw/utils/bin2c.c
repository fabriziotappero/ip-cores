#include <stdio.h>

int main(void)
{

	int c, i = 0;

	printf("#ifdef HAVE_CONFIG_H\n");
	printf("# include \"config.h\"\n");
	printf("#endif\n\n");
	printf("#ifdef EMBED\n");

	printf("unsigned char flash_data[] = {\n");

	while((c = getchar()) != EOF) {
		printf("0x%.2x, ", c);
		if(!(i % 32))
			printf("\n");
		i++;
	}

	printf(" };\n");
	printf("#endif\n");
	return(0);
}
