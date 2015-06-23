#ifndef __TOP_IF_H__
#define __TOP_IF_H__

//--------------------------------------------------------------------
// Defines
//--------------------------------------------------------------------
#define            TOP_RES_FAULT            -1
#define            TOP_RES_OK                0
#define            TOP_RES_MAX_CYCLES        1
#define            TOP_RES_BREAKPOINT        2

//--------------------------------------------------------------------
// Prototypes
//--------------------------------------------------------------------
int                top_init(void);
int                top_load(unsigned int addr, unsigned char val);
void               top_done(void);
int 			   top_run(unsigned int pc, int cycles, int intr_after_cycles);
int                top_setbreakpoint(int bp, unsigned int pc);

#endif
