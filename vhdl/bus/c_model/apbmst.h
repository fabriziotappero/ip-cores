#ifndef APBMST_H
#define APBMST_H

#define APBMST_MAXSLAVE  2


typedef int (* apb_write)();
typedef int (* apb_read)();

typedef struct _apb_slave {
  apb_write write;
  apb_read read;
  
  unsigned int start, end;
  void *c;
} apb_slave;

typedef struct _apbmst {
  apb_slave slaves[APBMST_MAXSLAVE]; 
} apbmst;

#endif
