#include <stdio.h>
#include <err.h>
#include <stdlib.h>

void
bindump(char *infile, char *outfile, int line_length, int size)
{
	FILE *in, *out;
	int c;
	int i, j;
	char patterns[256][9];

	for (i = 0; i < 256; i++) {
		for (j = 0; j < 8; j++) {
			patterns[i][j] = ((i>>(7-j))&1)+'0';
		}
		patterns[i][8] = '\0';
	}

	if (line_length % 8 != 0)
		errx(1, "Line length %d is not a multiple of 8\n", line_length);
	line_length /= 8;

	if ((in = fopen(infile, "r")) == NULL)
		err(1, "could not open %s for reading", infile);
	if ((out = fopen(outfile, "w")) == NULL)
		err(1, "could not open %s for writing", outfile);
	i = 0;
	while (1) {
		c = fgetc(in);
		if (feof(in)) break;
		if (ferror(in))
			err(1, "error reading from %s", infile);

		if (fputs(patterns[c], out) == EOF)
			err(1, "error writing to %s", outfile);

		if ((++i) % line_length == 0) {
			if (fputc('\n', out) == EOF)
				err(1, "error writing to %s", outfile);
		}
	}

	if (i % line_length != 0) {
		if (fputc('\n', out) == EOF)
			err(1, "error writing to %s", outfile);
		warn("file length not multiple of line length (%d bits)", line_length*8);
	}

	if (size != 0) {
		int remaining = size-i/line_length;
		if (remaining < 0)
			errx(1, "too long file, length is %d\n", i/line_length);
		if (remaining > 0) {
			for (i = 0; i < remaining; i++) {
				for (j = 0; j < line_length; j++)
					fputs("00000000", out);
				fputc('\n', out);
			}
		}
	}

	fclose(in);
	fclose(out);
}

int
main(int argc, char **argv)
{
	int size;

	if (argc < 4) {
		fprintf(stderr,
			"usage: %s INFILE OUTFILE LINE-LENGTH [SIZE]\n"
			"Writes each bit from INFILE as ASCII '1' or '0' in OUTFILE,\n"
			"with a newline after every LINE-LENGTH bits.\n",
			argv[0]);
		return 1;
	}

	size = (argc == 4) ? 0 : atoi(argv[4]);
	bindump(argv[1], argv[2], atoi(argv[3]), size);
}
