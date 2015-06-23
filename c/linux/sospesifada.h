#include "tipodef.h"
#define _GNU_SOURCE
#include "sys/types.h"
#include "sys/stat.h"
#include "sys/mman.h"
#include <fcntl.h>
#include <unistd.h>

void * memoria_nova (nN);
void * memoria_crese (n1 *, nN);
void memoria_libri (n1 *);
void memoria_copia (n1 *,n1 *,nN);
void memoria_move (n1 *,n1 *,nN);

void scrive_stdout(char *, nN);
char consola_leje_carater();
