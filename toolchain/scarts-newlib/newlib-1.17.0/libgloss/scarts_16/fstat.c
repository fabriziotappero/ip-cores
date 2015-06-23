#include <sys/stat.h>

int
fstat (int file, struct stat *st)
{
  st->st_mode = S_IFCHR;
  return 0;
}
