#include <tmki.h>
#include "apbmst.h"

apbmst *apbmst_create() {
  apbmst *m;
  
  m = (apbmst *) ti_alloc(sizeof(apbmst));
  if (!m) { return 0; }
  
    ti_print_err("\
Create apbmst model (0x%x):\n\
Max peripherals : %i\n\n",
m,APBMST_MAXSLAVE);
    
  return m;
}

void apbmst_add(apbmst *m,apb_write w,apb_read r, unsigned int start, unsigned int end) {
  int i;
  for (i = 0;i < APBMST_MAXSLAVE;i++) {
    if (m ->slaves[i].start == 0 && 
	m ->slaves[i].end == 0) {
      m ->slaves[i].start = start;
      m ->slaves[i].end = end;
      m ->slaves[i].read = r;
      m ->slaves[i].write = w;
    }
  }
}

int apbmst_read(apbmst *m,unsigned int addr, unsigned int *data) {
  int i;
  for (i = 0;i < APBMST_MAXSLAVE;i++) {
    if (m ->slaves[i].start <= addr && 
	m ->slaves[i].end > addr) {
      return m ->slaves[i].read(addr,data);
    }
  }
  return 0;
}

int apbmst_write(apbmst *m,unsigned int addr, unsigned int data) {
  int i;
  for (i = 0;i < APBMST_MAXSLAVE;i++) {
    if (m ->slaves[i].start <= addr && 
	m ->slaves[i].end > addr) {
      return m ->slaves[i].write(addr,data);
    }
  }
  return 0;
}
