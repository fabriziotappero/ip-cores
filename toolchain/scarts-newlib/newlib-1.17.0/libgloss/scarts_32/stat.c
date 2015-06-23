#include <sys/stat.h>

int
stat (const char *file, struct stat *st)
{
  st->st_mode = S_IFCHR;
  return 0;
}
