#ifdef imita
#include "cpu_1664.h"
#include <time.h>
#include <stdio.h>

void cpu_1664_opera__imita(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=2;
 
 n8 c;
 nN desloca;
 nN indise;
 struct lista *fix_nom;
 n1 *datos;
 struct timespec *reg;

 switch (bait)
 {
  case cpu_1664_imita_argc:
   cpu->sinia[0]=cpu->imita_argc;
   break;
  
  case cpu_1664_imita_argv:
   cpu_1664_umm(cpu, cpu->sinia[0], (1<<cpu_1664_umm_usor_mapa_permete_scrive), 1, 0);
   desloca=cpu->sinia[0];
   indise=cpu->sinia[1];
   
   if (indise<cpu->imita_argc)
   {
    
    nN i=0; 
    do
    {
      
     cpu_1664_umm(cpu, desloca++, (1<<cpu_1664_umm_usor_mapa_permete_scrive), 1, cpu->imita_argv[indise][i]);
    } while(cpu->imita_argv[indise][i++]!=0); //inclui zero final
   }
   
   break;
  
  case cpu_1664_imita_open:
   fix_nom=lista_nova(128);
   
   indise=0;
   do
   {
    c=cpu_1664_umm(cpu, cpu->sinia[0]+indise++, (1<<cpu_1664_umm_usor_mapa_permete_leje), sizeof(n1), 0);
    lista_ajunta__dato(fix_nom, c);
   } while(c!=0);
      
   cpu->sinia[0]=open((const char *)fix_nom->datos, O_RDWR);
   lista_libri(fix_nom);
   break;
  
  case cpu_1664_imita_close: 
     
   close(cpu->sinia[0]);
   break;
   
  case cpu_1664_imita_read:
      
   datos=memoria_nova(cpu->sinia[2]);
   read(cpu->sinia[0],datos,cpu->sinia[2]);
   
   indise=0;
   while(indise<cpu->sinia[1])
   {
    cpu_1664_umm(cpu, cpu->sinia[1]+indise, (1<<cpu_1664_umm_usor_mapa_permete_scrive), 1, datos[indise]);
    indise++;
   }
   
   memoria_libri(datos);
   break;
   
  case cpu_1664_imita_write:
   indise=0;
   
   datos=memoria_nova(cpu->sinia[2]);
   indise=0;
   
   while(indise<cpu->sinia[2])
   {
    datos[indise]=cpu_1664_umm(cpu, cpu->sinia[1]+indise, (1<<cpu_1664_umm_usor_mapa_permete_leje), 1, 0);
    indise++;
   }
   
   write(cpu->sinia[0],datos,cpu->sinia[2]);
   memoria_libri(datos);
   break;
  
  case cpu_1664_imita_ftruncate:
   cpu->sinia[0]=ftruncate(cpu->sinia[0],cpu->sinia[1]);
   break;
  
  case cpu_1664_imita_lseek:
   cpu->sinia[0]=lseek(cpu->sinia[0],cpu->sinia[1],cpu->sinia[2]);
   break;
  
  case cpu_1664_imita_time:
   cpu->sinia[0]=time(0);
   break;
  
  case cpu_1664_imita_nanosleep:
   reg=(struct timespec *)memoria_nova(sizeof(struct timespec));
   
   if(cpu->sinia[0]>=1000000000)
   {
    reg->tv_sec=cpu->sinia[0]/1000000000;
    reg->tv_nsec=0;
   }
   else
   {
    reg->tv_nsec=cpu->sinia[0];
   }
   
   cpu->sinia[0]=nanosleep(reg, 0);
   memoria_libri((n1 *)reg);
   break;
  
  case cpu_1664_imita_exit:
   _exit(cpu->sinia[0]);
   break;
  
  default:
   break;
 };
}
#endif
