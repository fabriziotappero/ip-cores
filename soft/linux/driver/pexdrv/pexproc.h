
#ifndef __PEXPROC_H__
#define __PEXPROC_H__

int pex_proc_info(char *buf,
                  char **start,
                  off_t off,
                  int count,
                  int *eof,
                  void *data );
void pex_register_proc(char *name, void *fptr, void *data);
void pex_remove_proc(char *name);

#endif
