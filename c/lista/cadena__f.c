#include "lista.h"
#include <stdarg.h>

void cadena__f(void *scrive(char *, nN), char *cadena, ...)
{
 va_list va_lista;
 va_start(va_lista, cadena);
 nN limite_indise = nN_cuantia__ccadena(cadena);
 
 n8 cuantia_;
 #define carater_cuantia 32
 char carater[carater_cuantia];
 char *cadena_;
 n8 valua;
 nN alinia;
 n1 bool_esatia;
 char *comensa;
 nN i=0;
 while(i<limite_indise)
 {
  
  switch(cadena[i])
  {
   default:
    comensa=cadena+i;
    while((cadena[i]!='\\')&&(cadena[i]!='%')&&(i<limite_indise)) { i++; }
    scrive(comensa, (cadena+i)-comensa);
    break;
   
   case '\\':
    i++;
    
    switch(cadena[i])
    {
     default:
      comensa=cadena+i++;
      while((cadena[i]!='\\')&&(cadena[i]!='%')&&(i<limite_indise)) { i++; }
      scrive(comensa, (cadena+i)-comensa);    
      break;
     
     case 'n':
      i++;
      carater[0]=0x0a;
      scrive(carater, 1);    
      break;
    }
    break;
       
   case '%':
    i++;
    
    if(cadena[i]=='.')
    {
     i++;
     bool_esatia=1;
    }
    else
    {
     bool_esatia=0;
    }
    
    if(cadena[i]=='*')
    {
     i++;
     alinia=va_arg(va_lista, n4); //*__ nN depende de arci
    }
    else
    {
     alinia=0;
    }
    
    switch(cadena[i])
    {
     case 'x':
      i++;
      valua=va_arg(va_lista, n8);
      cuantia_=asciiexadesimal__n8((n1 *)(carater+(carater_cuantia-1)), valua);
      alinia=(alinia>cuantia_) ? alinia-cuantia_ : 0;
      
      if(bool_esatia!=0)
      {
       carater[0]='0';
      }
      else
      {
       carater[0]=' ';
      }
      
      for(; alinia>0; alinia--)
      {
       scrive(carater,1);
      }
      
      scrive(carater+carater_cuantia-cuantia_, cuantia_);
      break;
     
     case 'd':
      i++;
      valua=va_arg(va_lista, n8);
      cuantia_=asciidesimal__n8((n1 *)(carater+(carater_cuantia-1)), valua);
      alinia=(alinia>cuantia_) ? alinia-cuantia_ : 0;
      
      if(bool_esatia!=0)
      {
       carater[0]='0';
      }
      else
      {
       carater[0]=' ';
      }
      
      for(; alinia>0; alinia--)
      {
       scrive(carater,1);
      }
      
      scrive(carater+carater_cuantia-cuantia_, cuantia_);
      break;
     
     case 'c':
      i++;
      carater[1]=(n1)va_arg(va_lista, nN);
      alinia=(alinia>1) ? alinia-1 : 0;
      
      for(carater[0]=' '; alinia>0; alinia--)
      {
       scrive(carater,1);
      }
      
      scrive(carater+1, 1);
      break;
     
     case 's':
      i++;
      cadena_=va_arg(va_lista, char *);
      cuantia_=nN_cuantia__ccadena(cadena_);
      alinia=(alinia!=0) ? alinia : cuantia_;
      cuantia_=(alinia>cuantia_) ? cuantia_ : alinia;
      alinia=(alinia>cuantia_) ? alinia-cuantia_ : 0;
      
      for(carater[0]=' '; alinia>0; alinia--)
      {
       scrive(carater,1);
      }
      
      scrive(cadena_, cuantia_);
      break;
    }
    break;
  }
 }
 va_end(va_lista);
}