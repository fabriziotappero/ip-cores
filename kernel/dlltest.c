// dlltest.c
// Compile this program with "make dlltest".  
// Then ftp dlltest.axf to /flash/bin/dlltest.
// Then from a telnet prompt type "dlltest".
#include "dll.h"

int a, b=7;

int main(int argc, char *argv[])
{
   int i=40;
   printf("Hello from dlltest! a=%d b=%d\n", a, b);
   if(argc > 1)
      printf("arg=%s\n", argv[1]);
   printf("Enter a number\n");
   scanf("%d", &i);
   printf("i=%d\n", i);
   return 0;
}
