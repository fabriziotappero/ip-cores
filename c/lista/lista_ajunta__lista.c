#include "lista.h"

void lista_ajunta__lista(struct lista *esta,struct lista *nova)
{
 lista_ajunta__datos(esta,nova->datos,nova->contador);
}