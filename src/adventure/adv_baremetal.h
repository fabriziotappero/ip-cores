
#ifndef ADV_BAREMETAL_H_INCLUDED
#define ADV_BAREMETAL_H_INCLUDED

#include <stdint.h>

/* fake array-based file */
typedef struct s_file {
    uint32_t line_ptr;
    uint32_t open;
} MFILE;


/* fake malloc */
void *alloc_mem(uint32_t num, uint32_t size);
/* fake exit */
void exit(uint32_t n);
/* fake file open for adventure.txt */
MFILE * mopen(const char * filename, const char * mode);
/* fake gets, adapted for use with string array */
void mgets (char *str, int size, MFILE *stream);
/* Initialize all the fake file data structures */
void startup(void);
/* Ask user if (s)he wants to use the auto-walk */
void prompt_use_walkthrough(void);
/* Replacement for fDATETIME with no random element (or time) */
void fDATIME(long *X, long *Y);
/* get user command from stdio or from walkthrough file */
char *get_command(char *str);

#endif