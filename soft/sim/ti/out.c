#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

void ti_print_err(const char *fmt, ...) {    
  va_list ap;
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
}
