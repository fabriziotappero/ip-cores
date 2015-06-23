#include <tmki.h>
#include "mctrl.h"

/* mctrl.vhd c model:
 * Currently supports:
 * - mcfg2[12:9] sram banksz
 * - mcfg2[25:23] sdram banksz
 * - mcfg2[13] sram disable
 * - mcfg2[14] sdram enable
 */

static int fsramsize(mctrl_struct *c) {
  unsigned int i = c ->mcfg2;
  unsigned int sz = 0x2000;
  i = (i >> 9) & 0xf;
  sz = sz << i;
  return sz;
}

static int fsdramsize(mctrl_struct *c) {
  unsigned int i = c ->mcfg2;
  unsigned int sz = 0x400000;
  i = (i >> 23) & 0x7;
  sz = sz << i;
  if (c ->mcfg2 & (1 << 14))
    sz = 0;;
  return sz;
}

mctrl_struct *mctrl_create() {
  
  mctrl_struct *m;
  
  m = (mctrl_struct *) ti_alloc(sizeof(mctrl_struct));
  if (!m) { return 0; }
  
  m ->sram_sz = fsramsize(m);
  m ->sram_m = ti_alloc(m ->sram_sz);
  m ->rom_sz = 0x100000;
  m ->rom_m = ti_alloc(m ->rom_sz);
  
    ti_print_err("\
Create mctrl model (0x%x):\n\
init sramsize : %x\n\
init sdramsize: %x\n\
init romsize  : %x\n\n",
m,m ->sram_sz,m ->sdram_sz,m ->rom_sz);

  return m;
}

static unsigned int *decode(mctrl_struct *c,unsigned int addr) {

  int sramsize = fsramsize(c);
  int sdramsize = fsdramsize(c);
  addr &= ~0x3;

  if (addr >= 0x00000000 && addr < 0x40000000 ) {
    if (addr >= c->rom_sz) {
      return 0;
    }
    return (unsigned int *)&(c->sdram_m[addr]);
  }
  else if (addr >= 0x40000000 && addr < 0x60000000 ) {
    addr = addr - 0x40000000;
    if (c ->mcfg2 & (1 << 13)) {
      if (addr >= sdramsize) {
	return 0;
      }
      return (unsigned int *)&(c->sdram_m[addr]);
    } else {
      if (addr >= sramsize) {
	return 0;
      }
      return (unsigned int *)&(c->sram_m[addr]);
    }
  }
  else if (addr >= 0x60000000 && addr < 0x80000000 ) {
    addr = addr - 0x60000000;
    if (c ->mcfg2 & (1 << 13)) {
      return 0;
    }
    if (addr >= sdramsize) {
      return 0;
    }
    return (unsigned int *)&(c->sdram_m[addr]);
  }
  return 0;
}

int mctrl_pwrite(mctrl_struct *c,unsigned int addr,unsigned int data) {

  int sramsize,sdramsize;

  switch (addr) {
  case 0:
    c ->mcfg1 = data; break;
  case 4:
    c ->mcfg2 = data;
    sramsize = fsramsize(c);
    if (sramsize > c ->sram_sz) {
      c->sram_m = ti_realloc(c->sram_m,c ->sram_sz,sramsize);
    }
    c ->sram_sz = sramsize;
    if (c ->mcfg2 & (1 << 14)) {
      sdramsize = fsdramsize(c);
      if (sdramsize > c ->sdram_sz) {
	c->sdram_m = ti_realloc(c->sdram_m,c ->sdram_sz,sdramsize);
      }
      c ->sdram_sz = sdramsize;
    }
    break;
  case 8:
    c ->mcfg3 = data; break;
  }
}

int mctrl_pread(mctrl_struct *c,unsigned int addr,unsigned int *data) {

  switch (addr) {
  case 0:
    *data = c ->mcfg1;
    return 1;
  case 4:
    *data = c ->mcfg2;
    return 1;
  case 8:
    *data = c ->mcfg3;
    return 1;
  }
  return 0;
}

int mctrl_read(mctrl_struct *c,unsigned int addr,unsigned int *data) {

  unsigned int *a = decode(c, addr);
  *data = *(a);
  return 1;
}

int mctrl_write(mctrl_struct *c,unsigned int addr,unsigned int data) {

  unsigned int *a = decode(c, addr);
  *(a) = data;
  return 1;
}



