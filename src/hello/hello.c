/**
* hello.c -- 'Hello World' basic test.
*/

#include <stdio.h>

int main()
{
    printf("compile time: " __DATE__ " -- " __TIME__ "\n");
    printf("gcc version:  " __VERSION__ "\n");
    printf("\n\nHello World!\n\n\n");
}

