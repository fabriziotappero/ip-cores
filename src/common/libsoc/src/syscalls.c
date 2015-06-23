/*
  syscalls.c -- Hardware-dependent functions for CodeSourcery libraries.

  These are just stubs meant to keep the compiler happy. Once I find out how
  to exclude newlib stuff from the compilation, thses functions will be
  removed.
*/

#include <sys/stat.h>


int close(int file){ 
    return -1; 
}

int fstat(int file, struct stat *st){
    st->st_mode = S_IFCHR;
    return 0;
}

int isatty(int file){ 
    return 1; 
}

int lseek(int file, int ptr, int dir){ 
    return 0; 
}

int open(const char *name, int flags, int mode){
    return -1; 
}

int read(int file, char *ptr, int len){
    /* use gets() to read from console */
    return 0;
}

char *heap_end = 0;

/* Stub -- broken -- do not use */
caddr_t sbrk(int incr){
    //extern char heap_low; /* Defined by the linker */
    //extern char heap_top; /* Defined by the linker */
    char *prev_heap_end;

    if (heap_end == 0){
        heap_end = (char *)0x00010000; //&heap_low;
    }
    prev_heap_end = heap_end;

    if ((unsigned)(heap_end + incr) > 0x00020000 /*&heap_top */){
        /* Heap and stack collision */
        return (caddr_t)0;
    }

    heap_end += incr;
    return (caddr_t) prev_heap_end;
}

int write(int file, char *ptr, int len){
    puts(ptr);
}