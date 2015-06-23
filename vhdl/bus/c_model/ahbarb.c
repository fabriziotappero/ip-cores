#include <tmki.h>
#include "ahbarb.h"

ahbarb *ahbarb_create() {
  ahbarb *m;
  
  m = (ahbarb *) ti_alloc(sizeof(ahbarb));
  if (!m) { return 0; }
  
    ti_print_err("\
Create ahbarb model (0x%x):\n\
Max slaves : %i\n\n",
m,AHBARB_MAXSLAVE);
    
  return m;
}

ahbarb *ahbarb_add(ahbarb *m,ahb_write w,ahb_read r, unsigned int start, unsigned int end) {
  int i;
  for (i = 0;i < AHBARB_MAXSLAVE;i++) {
    if (m ->slaves[i].start == 0 && 
	m ->slaves[i].end == 0) {
      m ->slaves[i].start = start;
      m ->slaves[i].end = end;
      m ->slaves[i].read = r;
      m ->slaves[i].write = w;
    }
  }
}

int ahbarb_read(ahbarb *m,unsigned int addr, unsigned int *data) {
  int i;
  for (i = 0;i < AHBARB_MAXSLAVE;i++) {
    if (m ->slaves[i].start <= addr && 
	m ->slaves[i].end > addr) {
      return m ->slaves[i].read(addr,data);
    }
  }
  return 0;
}

int ahbarb_write(ahbarb *m,unsigned int addr, unsigned int data) {
  int i;
  for (i = 0;i < AHBARB_MAXSLAVE;i++) {
    if (m ->slaves[i].start <= addr && 
	m ->slaves[i].end > addr) {
      return m ->slaves[i].write(addr,data);
    }
  }
  return 0;
}
