#include "cpu_1664.h"
#include <stdio.h>

int main(nN argc, n1 **argv)
{
 
 if (argc>2)
 {
  struct cpu_1664 *cpu=cpu_1664_nova(0);
  FILE *fix=fopen(argv[1], "wb");
  nN contador_ante=0;
  
  nN i;
  for(i=2;i<(argc);i++)
  {
   struct lista *lista_enflue=lista_nova__ccadena(".inclui ");
   lista_ajunta__ccadena(lista_enflue, argv[i]);
   cpu_1664_asm_ajunta__cadena(cpu, lista_enflue->datos, lista_enflue->contador);
   lista_libri(lista_enflue);
   printf("[0x%.*llx] %s\n",16,cpu->lista_imaje_asm->contador-contador_ante,argv[i]);
   contador_ante=cpu->lista_imaje_asm->contador;
  }
  
  printf("[0x%.*llx] %s\n",16,cpu->lista_imaje_asm->contador,argv[1]);
  fwrite(cpu->lista_imaje_asm->datos, 1, cpu->lista_imaje_asm->contador, fix);
  fclose(fix);
  cpu_1664_libri(cpu);
  return 0;
 }
 else
 {
  printf("asm_1664 lista_enflue esflue\n");
  return 0;
 }
}