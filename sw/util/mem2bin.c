/****************************************************************************************** 
*   mem2bin: converts a mem file to a binary file
*   syntax: mem2bin < filename_in.mem
*   author: Tamar Kranenburg
*   September, 2008
*******************************************************************************************/

#include <stdio.h>

main(int argc, char *argv[])
{
    unsigned char ch;
    unsigned char c1 = 255;
    unsigned char c2 = 255;

    FILE *fp;
    fp=fopen("out.bin", "wb");

    while (!feof(stdin))
    {
        ch = getchar() & 0x0ff;
        if(ch >= 48 && ch <= 57)
        {
            /* ASCII digits */
            ch -= 48;
        }
        else if(ch >= 65 && ch <= 70)
        {
            /* Upper case A to F */
            ch -= 55;
        }
        else if(ch >= 97 && ch <= 102)
        {
            /* Lower case a to f */
            ch -= 87;
        }
        else if(ch == 47 || ch == 64)
        {
            /* Comment line (/) or base address line (@) */
            while(getchar() != 10)
            {
                continue;
            }
            continue;
        }
        else
        {
            continue;
        }
        
        if(c1 == 255)
        {
            c1 = ch;
            continue;
        }
        else if(c2 == 255)
        {
            c2 = ch;
        }
        else
        {
            continue;
        }

        fputc(c1*16+c2, fp);
        c1 = 255;
        c2 = 255;
    }
    return 0;
}
