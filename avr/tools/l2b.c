#include <stdio.h>

int
main(int argc, char **argv)
{
	FILE *in, *out;
	int a;

	if (argc < 3)
		errx(1, "Usage: prog infile outfile");

	if ((in = fopen(argv[1], "r")) == NULL)
		err(1, "fopen(r)");
	if ((out = fopen(argv[2], "w")) == NULL)
		err(1, "fopen(w)");

	while (fread(&a, sizeof(a), 1, in) == 1) {
		a = htonl(a);
		fwrite(&a, sizeof(a), 1, out);
	}

	fclose(in);
	fclose(out);
	
	return 0;
}
