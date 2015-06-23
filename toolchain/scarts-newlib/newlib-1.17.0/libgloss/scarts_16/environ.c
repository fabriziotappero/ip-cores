#include <sys/types.h>

char *__env[1] = {0};
char **environ = __env;
