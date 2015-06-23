#ifndef __DEVOPS_H__
#define __DEVOPS_H__

#define NUM_DEVOPS 3

typedef struct
{
  const char   *name;
  int (*open)  (const char *name, int flags, int mode);
  int (*close) (int file);
  int (*write) (int file, char *ptr, int len);
  int (*read)  (int file, char *ptr, int len);
} devops_t;

#endif
