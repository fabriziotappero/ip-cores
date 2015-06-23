#include "cpu_1664.h"
#include <stdio.h>

#define scrive (P)scrive_stdout

int main(int argc, char **argv)
{
 
 if (argc>1)
 {
  char fix_imaje_model[]="1664.imaje";
  char fix_jornal_cadena[]="1664.jornal";
  nM memoria_cuantia=0;
  struct lista *lista_enflue;
  struct cpu_1664 *cpu = cpu_1664_nova(1024*1024*2);
  char *cadena_fix_esflue=fix_imaje_model;
  char *cadena_fix_enflue;
  nN contador_ante=0;
  nN a=1;
  nN i;
  nN bool_debug=0;
  nN bool_parolos=0;
  nN bool_core=0;
  cpu->opera_lista[cpu_1664_opera_imita]=cpu_1664_opera__imita;
  cpu->imita_argc=argc;
  cpu->imita_argv=argv;
  FILE *fix_esflue;
  FILE *fix_enflue;
  n1 *fix_enflue_datos;
  n8 fix_enflue_datos_cuantia;
  nN filo_cuantia=3;
  
  while(a<argc)
  {
   
   switch(argv[a][0])
   {
    default:
     a++;
     break;
    
    case '+': //parametre arg imita
     a++; 
     break;
     
    case '-':
     
     switch(argv[a][1])
     {
      case 'v':
       a++;
       bool_parolos=1;
       break;
      
      case 'f':
       a++;
       lista_enflue=lista_nova__ccadena(".inclui ");
       lista_ajunta__ccadena(lista_enflue, argv[a]);
       cpu_1664_asm_ajunta__cadena(cpu, lista_enflue->datos, lista_enflue->contador);
       lista_libri(lista_enflue);
       if(bool_parolos) cadena__f(scrive, "[0x%.*x] %s\n",sizeof(cpu_1664_sinia_t)*2, (n8)(cpu->lista_imaje_asm->contador-contador_ante), argv[a]);
       contador_ante=cpu->lista_imaje_asm->contador;     
       a++;
       break;
      
      case 'I':
       a++;
       lista_ajunta__P(cpu->lista_inclui_curso, lista_nova__ccadena(argv[a++]));
       break;
                  
      case 'm':
       a++;
       memoria_cuantia=nN__desimal_cadena((n1 *)argv[a], nN_cuantia__ccadena(argv[a]));
       lista_crese(cpu->lista_imaje, memoria_cuantia);
       a++;
       break;
       
      case 'd':
       bool_debug=1;
       bool_core=1;
       a++;
       break;
       
      case 'B':
       a++;
       cadena_fix_enflue=argv[a];
       fix_enflue=fopen(cadena_fix_enflue, "r");
       fseek(fix_enflue, 0, SEEK_END);
       fix_enflue_datos_cuantia=ftell(fix_enflue);
       rewind(fix_enflue);
       fix_enflue_datos=(n1*)memoria_nova(fix_enflue_datos_cuantia);
       fread(fix_enflue_datos, 1, fix_enflue_datos_cuantia, fix_enflue);
       if(bool_parolos) cadena__f(scrive, "imaje [0x%x] << %s [0x%x]",(n8)cpu->lista_imaje->contador, cadena_fix_enflue, fix_enflue_datos_cuantia); fflush(0);
       cpu_1664_imaje_ajunta__datos(cpu, fix_enflue_datos, fix_enflue_datos_cuantia);
       if(bool_parolos) cadena__f(scrive,"\n");
       memoria_libri(fix_enflue_datos);
       fclose(fix_enflue);
       a++;
       break;
      
      case 'b':
       a++;
       cadena_fix_esflue=argv[a];
       if(bool_parolos) cadena__f(scrive, "imaje > %s",cadena_fix_esflue); fflush(0);
       fix_esflue=fopen(cadena_fix_esflue, "w");
       cadena__f(scrive, " [0x%x]\n", (n8)cpu->lista_imaje_asm->contador);
       fwrite(cpu->lista_imaje_asm->datos, 1, cpu->lista_imaje_asm->contador, fix_esflue);
       fclose(fix_esflue);
       a++;
       break;
      
      case 'e':
       bool_core=1;
       a++;
       break;
       
      case 'L':
       a++;
       filo_cuantia=nN__desimal_cadena((n1 *)argv[a], nN_cuantia__ccadena(argv[a]));
       a++;
       break;
     }
     break;
     
   }
  }
  if(cpu->asm_eror!=0)
  {
   cadena__f(scrive,"aborte: eror asm\n");
   return 1;
  }
  
  if(!bool_core) _exit(0);
  
  cpu_1664_imaje_ajunta__lista(cpu, cpu->lista_imaje_asm);
    
  if(!bool_debug)
  {
   cpu_1664__pasi(cpu, (n8)-1);
  }

  struct lista *lista_jornal_opera=lista_nova(0);
  struct lista *lista_jornal_desloca=lista_nova(0);
  struct lista *lista_jornal_mapa=lista_nova(0);
  
  cpu_1664_sinia_t *sinia_ante;
  cpu_1664_sinia_t sinia_ante_usor[1<<cpu_1664_bitio_r];
  cpu_1664_sinia_t sinia_ante_vantaje[1<<cpu_1664_bitio_r];
  cpu_1664_opera_t parola;
  cpu_1664_sinia_t sIP_egali=(cpu_1664_sinia_t)-1;
  
  nN pasi_cuantia=1;
  
  for(i=0;i<1<<cpu_1664_bitio_r;i++)
  {
   sinia_ante_usor[i]=0;
   sinia_ante_vantaje[i]=0;
  }
  n1 bool_sicle_fini=0;
  n1 bool_pausa=0;
  n1 bool_bp=0;
  n1 bool_depende;
  n1 bool_eseta;
    
  while(bool_sicle_fini==0)
  {
   bool_eseta=0;//cpu->sinia[cpu_1664_sinia_IP]==0;
   bool_pausa=(cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP], (1<<cpu_1664_umm_usor_mapa_permete_esecuta), sizeof(cpu_1664_opera_t), 0)==(cpu_1664_opera_t)(-1));
   
   n1 opera_depende=(cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP], (1<<cpu_1664_umm_usor_mapa_permete_esecuta), 1, 0)>>5)&0x07;
   
   bool_depende=opera_depende==7||cpu->depende[opera_depende]!=0;
   bool_bp=bool_depende&&((cpu_1664_opera_t)(cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP], (1<<cpu_1664_umm_usor_mapa_permete_esecuta), sizeof(cpu_1664_opera_t), 0))&0xff1f)==(cpu_1664_opera_t)(cpu_1664_opera_rev|(cpu_1664_opera_rev_bp<<8));
   
   if(cpu->vantaje==1)
   {
    sinia_ante=sinia_ante_vantaje;
   }
   else
   {
    sinia_ante=sinia_ante_usor;
   }
   
   if ((bool_eseta&&(cpu->contador_sicle!=0))||bool_sicle_fini||bool_pausa||bool_bp)
   {
    pasi_cuantia=1;
   }
   
   if ((sIP_egali!=(cpu_1664_sinia_t)-1)&&(cpu->sinia[cpu_1664_sinia_IP]==sIP_egali))
   {
    sIP_egali=(cpu_1664_sinia_t)-1;
    pasi_cuantia=1;
   }
   
   if(pasi_cuantia<=1)
   {
    //consola_leje_carater();
   fflush(stdout);cadena_ANSI__atribuida(scrive,40);
   fflush(stdout);cadena_ANSI_limpa(scrive);
   fflush(stdout);cadena_ANSI_cursor_orijin(scrive);
   nN j;
   nN s;
   for(s=0; s<(1<<(cpu_1664_bitio_r-2));s++)
   {
    
    for(j=0;j<(1<<2);j++)
    {
     nN indise=(s<<2)+j;
     
     if(indise==cpu_1664_sinia_IP)
     {
      fflush(stdout);cadena_ANSI__3atribuida(scrive,1,40,32);
     }
     else if(sinia_ante[indise]!=cpu->sinia[indise])
     {
      fflush(stdout);cadena_ANSI__3atribuida(scrive,1,40,36);
     }
     else
     {
      fflush(stdout);cadena_ANSI__3atribuida(scrive,2,40,37);
     }
     sinia_ante[indise]=cpu->sinia[indise];
     cadena__f(scrive, "%.*x ",sizeof(cpu_1664_sinia_t)*2,(n8)cpu->sinia[indise]);
    }
    scrive_stdout("\n",1);
   }
   fflush(stdout);cadena_ANSI__atribuida(scrive,11);
   j=-1;
   parola=cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP]+(2*(j+1)), (1<<cpu_1664_umm_usor_mapa_permete_esecuta), sizeof(cpu_1664_opera_t), 0);
   cadena__f(scrive, "sicle %.*x usor %.*x limite %.*x\n",sizeof(cpu_1664_sinia_t)*2,cpu->contador_sicle,sizeof(cpu_1664_sinia_t)*2,cpu->contador_sicle_usor,sizeof(cpu_1664_sinia_t)*2,(n8)cpu->contador_sicle_usor_limite);
   fflush(stdout);cadena_ANSI__2atribuida(scrive,1,36);
   
   if(cpu->depende[cpu_1664_depende_bitio_depende_influe]!=0)
   {
    cadena__f(scrive, "(esflue) "); 
   }
   else
   {
    cadena__f(scrive, "(inoria) "); 
   }
   
   cadena__f(scrive, "depende : ");
   cadena__f(scrive, "%c",('0')&0xff*(cpu->depende[0]!=0));
   cadena__f(scrive, "%c",('1')&0xff*(cpu->depende[1]!=0));
   cadena__f(scrive, "%c",('2')&0xff*(cpu->depende[2]!=0));
   cadena__f(scrive, "%c",('3')&0xff*(cpu->depende[3]!=0));
   cadena__f(scrive, "%c",('4')&0xff*(cpu->depende[4]!=0));
   cadena__f(scrive, "%c",('5')&0xff*(cpu->depende[5]!=0));
   cadena__f(scrive, "%c",('6')&0xff*(cpu->depende[6]!=0));
   cadena__f(scrive, "\n");
    
   fflush(stdout);cadena_ANSI__3atribuida(scrive,1,40,37);
   fflush(stdout);cadena_ANSI__cursor_desende(scrive,filo_cuantia-1);
   for(j=0;j<filo_cuantia;j++)
   {
    fflush(stdout);cadena_ANSI__cursor_sinistra(scrive,100);
    cpu_1664_sinia_t mapa=0;
    cpu_1664_sinia_t desloca=0;
    cpu_1664_opera_t parola=0;
    {
     //*** x86
     //mapa=((cpu_1664_sinia_t *)(lista_jornal_mapa->datos))[(lista_jornal_mapa->contador/sizeof(cpu_1664_sinia_t))-j-1];
     desloca=((cpu_1664_sinia_t *)(lista_jornal_desloca->datos))[(lista_jornal_desloca->contador/sizeof(cpu_1664_sinia_t))-j-1];
     parola=((cpu_1664_opera_t *)(lista_jornal_opera->datos))[(lista_jornal_opera->contador/sizeof(cpu_1664_opera_t))-j-1];
    }
    cadena__f(scrive, "%.*x : ",4,(n8)mapa);
    cadena__f(scrive, "%.*x %.*x ",sizeof(cpu_1664_sinia_t)*2,(n8)desloca,4,(n8)parola);
    
    struct lista *lista_dev=cpu_1664_dev_dev(cpu, cpu->sinia[cpu_1664_sinia_IP], parola);
 
    struct lista *_lista_dev_dev_depende=((struct lista **)(((struct lista **)(lista_dev->datos))[1]->datos))[0];
    struct lista *_lista_dev_dev_opera=((struct lista **)(((struct lista **)(lista_dev->datos))[1]->datos))[1];
 
    struct lista *_lista_dev_parametre=((struct lista **)(((struct lista **)(lista_dev->datos))[2]->datos))[0];
    printf("%s ",_lista_dev_dev_depende->datos);
    printf("%s ",_lista_dev_dev_opera->datos);
    printf("%s ",_lista_dev_parametre->datos);
    fflush(stdout);cadena_ANSI__cursor_asende(scrive, 1);
   }
    fflush(stdout);cadena_ANSI__cursor_desende(scrive,filo_cuantia+1); fflush(stdout);cadena_ANSI__cursor_sinistra(scrive,100);
   
   for(j=0;j<filo_cuantia;j++)
   {
    
    if(j==0)
    {
     fflush(stdout);cadena_ANSI__3atribuida(scrive,40,1,36);
    }
    else
    {
     fflush(stdout);cadena_ANSI__3atribuida(scrive,2,40,37);
    }
    parola=cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP]+(2*(j+0-0)), (1<<cpu_1664_umm_usor_mapa_permete_esecuta), sizeof(cpu_1664_opera_t), 0);
    cadena__f(scrive, "%.*x : ",4,cpu->umm_memoria[0]*!cpu->vantaje);
    cadena__f(scrive, "%.*x %.*x ",sizeof(cpu_1664_sinia_t)*2,cpu->sinia[cpu_1664_sinia_IP]+(2*(j+0-0)),4,parola);
    
    struct lista *lista_dev=cpu_1664_dev_dev(cpu, cpu->sinia[cpu_1664_sinia_IP], parola);
 
    struct lista *_lista_dev_dev_depende=((struct lista **)(((struct lista **)(lista_dev->datos))[1]->datos))[0];
    struct lista *_lista_dev_dev_opera=((struct lista **)(((struct lista **)(lista_dev->datos))[1]->datos))[1];
 
    struct lista *_lista_dev_parametre=((struct lista **)(((struct lista **)(lista_dev->datos))[2]->datos))[0];
    struct lista *_lista_dev_informa=((struct lista **)(((struct lista **)(lista_dev->datos))[2]->datos))[1];
    printf("%s ",_lista_dev_dev_depende->datos);
    printf("%s ",_lista_dev_dev_opera->datos);
    printf("%s ",_lista_dev_parametre->datos);
    if(j==0)
    {
     if(pasi_cuantia<=1)printf("; %s",_lista_dev_informa->datos);
    }
    if(pasi_cuantia<=1)printf("\n");
    cpu_1664_dev_dev_libri(lista_dev);
   }
   }
   #define limite_jornal 1000000
   if((lista_jornal_opera->contador/sizeof(cpu_1664_opera_t))<limite_jornal)
   {
    lista_ajunta__cpu_1664_parola_t(lista_jornal_opera, cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP], (1<<cpu_1664_umm_usor_mapa_permete_esecuta), sizeof(cpu_1664_opera_t), 0));
    lista_ajunta__cpu_1664_sinia_t(lista_jornal_desloca, cpu->sinia[cpu_1664_sinia_IP]);
    lista_ajunta__cpu_1664_sinia_t(lista_jornal_mapa, cpu->umm_memoria[0]*!cpu->vantaje);
   }
   if (--pasi_cuantia>0)
   {
    cpu_1664__pasi(cpu, 1);
    continue;
   }
   else
   {
    pasi_cuantia=1;
   }
   n1 c=consola_leje_carater();
   switch (c)
   {
    case 'n':
    default:
     cpu_1664__pasi(cpu, 1);
     break;
    
    case 'm':
     sIP_egali=cpu->sinia[cpu_1664_sinia_IP]+sizeof(cpu_1664_opera_t);
     cpu_1664__pasi(cpu, 1);
     pasi_cuantia=-1;
     break;
    
    case 'N':
     cpu->sinia[cpu_1664_sinia_IP]+=sizeof(cpu_1664_opera_t);
     break;
    
    case 'c':
     cpu_1664__pasi(cpu, 1);
     pasi_cuantia=-1;
     break;
    
    case 'q':
     bool_sicle_fini=1;
     fflush(stdout);cadena_ANSI__atribuida(scrive,0);
     break;
        
    case ':':
     fflush(stdout);cadena_ANSI__3atribuida(scrive,40,1,36);
     cadena__f(scrive, "comanda : ");fflush(0);
     
     switch(consola_leje_carater())
     {
      case 'd':
       cadena__f(scrive, "imaje > %s",cadena_fix_esflue); fflush(0);
       fix_esflue=fopen(cadena_fix_esflue, "w");
       cadena__f(scrive, " [0x%x]\n", cpu->lista_imaje_asm->contador);
       fwrite(cpu->lista_imaje_asm->datos, 1, cpu->lista_imaje_asm->contador, fix_esflue);
       fclose(fix_esflue);
       consola_leje_carater(); //pausa
       break;
      
      case 'j':
       cadena__f(scrive, "jornal > %s",fix_jornal_cadena); fflush(0);
       fix_esflue=fopen(fix_jornal_cadena, "w");
       cadena__f(scrive, " [0x%x]\n", cpu->lista_imaje_asm->contador);
       fwrite(cpu->lista_imaje_asm->datos, 1, cpu->lista_imaje_asm->contador, fix_esflue);
       fclose(fix_esflue);
       consola_leje_carater(); //pausa
       break;
     }
     
     break;
   }
   
  }
  cadena__f(scrive, "> [%.*x] %.*x\n",6,cpu->sinia[cpu_1664_sinia_IP],sizeof(cpu_1664_opera_t)*2,cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP], (1<<cpu_1664_umm_usor_mapa_permete_esecuta), sizeof(cpu_1664_opera_t), 0));
  
  lista_libri(lista_jornal_opera);
  lista_libri(lista_jornal_desloca);
  lista_libri(lista_jornal_mapa);
  cpu_1664_libri(cpu);
  return 0;
 }
 else
 {
  cadena__f(scrive, " <-v> parolas\n <-d> desdefetador\n <-e> imita\n <-I inclui_curso>\n <-f fonte.1664>\n <-B binario_enflue>\n <-b binario_esflue>\n <-m memoria_cuantia>\n <-L filo_cuantia>\n");
  return 0;
 }
 
}
