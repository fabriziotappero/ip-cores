#include "sospesifada.h"
#include <unistd.h>

void scrive_stdout(char *cadena, nN cuantia)
{
 write(1, cadena, cuantia);
}