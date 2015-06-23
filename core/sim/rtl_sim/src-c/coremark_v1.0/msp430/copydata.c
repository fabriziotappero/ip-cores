#include <stdint.h>
#include <string.h>

extern char __datastart;
extern char __romdatastart;
extern char __romdatacopysize;
static void* const datastart=&__datastart;
static void* const romdatastart=&__romdatastart;
static uint16_t const romdatacopysize=(uint16_t)&__romdatacopysize;

__attribute__((constructor)) void __data_move() {
        if (datastart!=romdatastart) {
                memmove(datastart,romdatastart,romdatacopysize);
        }
}
