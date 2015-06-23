#ifndef __GDB_H__
#define __GDB_H__

//-----------------------------------------------------------------
// Prototypes:
//-----------------------------------------------------------------
void          gdb_main(void);
unsigned int* gdb_exception(unsigned int *registers, unsigned int reason);

#endif