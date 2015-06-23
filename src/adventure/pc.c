/* Use this to compile adv on a PC */
#include <stdio.h>
#include <stdint.h>


int puts(const char *string){
    while(*string){
        /* Implicit CR with every NL as usual */
        if(*string == '\n'){
            putchar('\r');
        }
        putchar(*string++);
    }
    return 0;
}

void po_num(uint32_t num){
    printf("%d", num);
}
