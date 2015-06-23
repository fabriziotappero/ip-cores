/**
 @file  soc.c
 @brief Supporting functions that do not warrant their own file.
*/

#include <stdint.h>
#include "soc.h"

/* Prototypes for external functions */
extern void putchar(int c);
extern int getchar(void);


/*-- Non-standard utility functions ------------------------------------------*/

/** Return time elapsed since the last HW reset in clock cycles */
unsigned ctime(void){
    unsigned cycles;
    
    cycles = *((volatile unsigned *)0x20000100);
    return cycles;
}


/*-- Libc replacement functions ----------------------------------------------*/

/** Write string to console; replacement for standard puts. 
    Uses no buffering. */
int puts(const char *string){
    while(*string){
        /* Implicit CR with every NL if requested */
        if(IMPLICIT_CR_WITH_NL & (*string == '\n')){
            putchar('\r');
        }
        putchar(*string++);
    }
    /* A newline character is appended to the output. */
    if(IMPLICIT_CR_WITH_NL & (*string == '\n')){
        putchar('\r');
    }
    putchar('\n');
    
    return 0; /* on success return anything non-negative */
}

/** Read string from console, blocking; replacement for standard puts. 
    Uses no buffering. */
char *gets (char *str){
    uint32_t i=0;
    char c;

    while(1){
        c = getchar();
        
        if(c=='\0'){
            break;
        }
        else if(c=='\n' || c=='\r'){
            break;
        }
        else{
            str[i++] = c;
        }
    }
    str[i] = '\0';
    return str;
} 
