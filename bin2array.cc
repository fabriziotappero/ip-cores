#include <stdio.h>
#include <assert.h>

int main(int argc, char * argv[])
{
   assert(argc == 2);

FILE * in = fopen(argv[1], "rb");
   assert(in);

unsigned char buffer[8];

   for (;;)
      {
        int len = fread(buffer, 1, 8, in);
        if (len <= 0)   break;
        printf("    ");
        for (int i = 0; i < len; i++)   printf("0x%2.2X, ", buffer[i]);
        printf("\n");
      }
}
