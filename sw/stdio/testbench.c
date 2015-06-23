#include "stdio.h"
#include <stdio.h>

int main()
{
    int c = 0;
    fflush(stdin);
    while((c=getchar())!='\n')
    {
        putchar(c);
        putchar('\n');
    }
    xil_printf("Finished\n");
    return 0;
}
