/****************************************************************************************** 
*   syntax: bin2mem  < filename1.bin
*   author: Rene van Leuken
*   modified: Tamar Kranenburg
*   February, 2008: header string provided, so ModelSim can recognize the file's format
*                   (= Veriloh hex) when 'Importing' into memory ... (Huib)
*   September, 2008: prevent reversing byte order
*
*******************************************************************************************/

#include <stdio.h>

main()
{
    unsigned char c0, c1, c2, c3;

    FILE *fp0, *fp1, *fp2, *fp3;
    fp0=fopen("rom0.mem", "wb");
    fp1=fopen("rom1.mem", "wb");
    fp2=fopen("rom2.mem", "wb");
    fp3=fopen("rom3.mem", "wb");

    fprintf(fp0, "// memory data file (do not edit the following line - required for mem load use)\n");
    fprintf(fp1, "// memory data file (do not edit the following line - required for mem load use)\n");
    fprintf(fp2, "// memory data file (do not edit the following line - required for mem load use)\n");
    fprintf(fp3, "// memory data file (do not edit the following line - required for mem load use)\n");
    fprintf(fp0, "// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1\n");
    fprintf(fp1, "// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1\n");
    fprintf(fp2, "// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1\n");
    fprintf(fp3, "// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1\n");
    fprintf(fp0, "@00000000\n");
    fprintf(fp1, "@00000000\n");
    fprintf(fp2, "@00000000\n");
    fprintf(fp3, "@00000000\n");

    while (!feof(stdin)) {
        c0 = getchar() & 0x0ff;
        c1 = getchar() & 0x0ff;
        c2 = getchar() & 0x0ff;
        c3 = getchar() & 0x0ff;
        fprintf (fp0, "%.2x\n", c3);
        fprintf (fp1, "%.2x\n", c2);
        fprintf (fp2, "%.2x\n", c1);
        fprintf (fp3, "%.2x\n", c0);
    }

    fprintf(fp0, "\n");
    fprintf(fp1, "\n");
    fprintf(fp2, "\n");
    fprintf(fp3, "\n");

    return 0;
}
