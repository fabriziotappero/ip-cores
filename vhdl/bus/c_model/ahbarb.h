#ifndef AHBARB_H
#define AHBARB_H

#define AHBARB_MAXMASTER 2
#define AHBARB_MAXSLAVE  2


typedef int (* ahb_write)();
typedef int (* ahb_read)();

typedef struct _ahb_slave {
  ahb_write write;
  ahb_read read;
  
  unsigned int start, end;
  void *c;
} ahb_slave;

typedef struct _ahbarb {
  ahb_slave slaves[AHBARB_MAXSLAVE]; 
} ahbarb;


#endif
