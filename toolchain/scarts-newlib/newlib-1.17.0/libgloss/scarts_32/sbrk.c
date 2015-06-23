#include <sys/types.h>
#include <errno.h>
#include "modules.h"

/* _end is defined by the linker script. */
extern int _end;

caddr_t
sbrk (int incr)
{
  static caddr_t heap_end;
  caddr_t prev_heap_end;
  
  if (heap_end == 0)
    heap_end = (caddr_t) (&_end);

  prev_heap_end = heap_end;
  if (heap_end + incr > FPZ)
  {
    errno = ENOMEM;
    return (caddr_t) -1;
  }

  heap_end += incr;
  return prev_heap_end;
}
