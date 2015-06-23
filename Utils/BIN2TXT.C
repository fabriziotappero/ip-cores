#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void main(int argc, char* argv[])
{
    FILE    *in, *out;
    int     i, j;
    char    ch;
    double  m;

    printf("Converts a binary output from AS65 into Xilinx-compatible Memory Intialization File\n");
    printf("\nThe number of arguments supplied: %d\n", argc);
    if(argc < 2) {
        printf("\n\tProgram requires the following two arguments: infile outfile.\n");
        printf("\tinfile : input binary mode file output of AS65 assembler\n");
        printf("\toutfile: filename of output file into ASCII Hex representation of input file is written\n\n");
    } else {
        for(i = 0; i < argc; i++) {
            printf("argv[%d] = %s\n", i, argv[i]);
        }

        if((in = fopen(argv[1], "rb")) == NULL) {
            fprintf(stderr, "Cannot open input file.\n");
        }

        if((out = fopen(argv[2], "wt")) == NULL) {
            fprintf(stderr, "Cannot open output file.\n");
        }

        i = 0;
        while(!feof(in)) {
           ch = fgetc(in);
           //printf("%02X ", ch);
           fprintf(out, "%02X\n", ch);
           i += 1;
        }

        m = log(i-1)/log(2.0);

        if((m - ((int) m)) != 0) {
            j = (1 << (((int) m) + 1));
        } else {
            j = (1 <<  ((int) m)     );
        }

        printf("\n\nm = %12.6g; i = %d; j = %d, ch = %d\n\n", m, i, j, ch);

        if(j > i) {
            for(; i < j; i++) {
                fprintf(out, "00\n");
            }
        }

        fclose(in);
        fclose(out);
    }
}