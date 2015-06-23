#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include <unistd.h>

//-----------------------------------------------------------------
// main:
//-----------------------------------------------------------------
int main(int argc, char *argv[])
{
    int c;
    FILE *f;
    char filename[256];
    int help = 0;
    int offset = 0;

    filename[0] = 0;

    while ((c = getopt(argc, argv, "hf:o:")) != EOF)
    {
        switch (c)
        {
            case 'h':
                help = 1;
                break;
            case 'o':
                offset = strtoul(optarg, NULL, 0);
            case 'f':
                strcpy(filename, optarg);
                break;
        }
    }

    if (filename[0] == '\0' || help)
    {
        fprintf(stderr, "Options:\n");
        fprintf(stderr, " -f inputFile\n");
        fprintf(stderr, " -o offset\n");
        return help ? 0 : 1;
    }

    f = fopen(filename, "rb");
    if (f)
    {
        int i,w,s;
        unsigned int size;
        unsigned int words;
        unsigned char buf;
        unsigned char data;

        // Get size
        fseek(f, 0, SEEK_END);
        size = ftell(f);
        rewind(f);

        fseek(f, offset, SEEK_SET);

        for (i=0;i<size + 1;i+=4)
        {
            fread(&buf, 1, 1, f);
            data = buf;

            printf("%x\n", data);

            // Skip N bytes of
            fread(&buf, 1, 1, f);
            fread(&buf, 1, 1, f);
            fread(&buf, 1, 1, f);
        }

        fclose(f);
        return 0;
    }
    else
    {
        fprintf(stderr, "Could not open file %s\n", filename);
        return 1;
    }
}

