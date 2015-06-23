#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

/* errno handling in a reentrant way *TODO?* */
int *__errno(void)
{
  return &errno;
}
