#ifndef MEMCTRL_H
#define MEMCTRL_H

typedef struct _mctrl {
  char *rom_m;
  unsigned int rom_sz;
  char *sram_m;
  unsigned int sram_sz;
  char *sdram_m;
  unsigned int sdram_sz;
  
  unsigned int mcfg1;
  unsigned int mcfg2;
  unsigned int mcfg3;
} mctrl_struct;


/* in mctrl.c */
mctrl_struct *mctrl_create();
int mctrl_read(mctrl_struct *c,unsigned int addr,unsigned int *data);
int mctrl_write(mctrl_struct *c,unsigned int addr,unsigned int data);
int mctrl_pwrite(mctrl_struct *c,unsigned int addr,unsigned int data);
int mctrl_pread(mctrl_struct *c,unsigned int addr,unsigned int *data);



#endif

