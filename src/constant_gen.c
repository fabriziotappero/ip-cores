#include <stdio.h>
#include <gmp.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define uint16 unsigned short int
#define uint32 unsigned int
#define uint64 unsigned long long int
#define WORD_SIZE 32


uint32 getMpzSize(mpz_t n)
{

   return (mpz_size(n)*2);

}

uint16 getlimb(mpz_t n, int i)
{
   uint32 aux=mpz_getlimbn(n,i/2);
   if(i%2 == 0)
     return (uint16) (aux&0xffff);
   return (uint16) (aux>>16);

}



int main()
{
     
    int i;
    
    mpz_t m,x,y,r,r_aux, n_cons, zero, recons;
  
    char *template;
   
    mpz_init_set_str(m,"8de7066f67be16fcacd05d319b6729cd85fe698c07cec504776146eb7a041d9e3cacbf0fcd86441981c0083eed1f8f1b18393f0b186e47ce1b7b4981417b491",16); //mpz_init_set_str(m,"c3217fff",16);
   
    mpz_init(r);
    mpz_init(r_aux);
    mpz_init(n_cons);
    mpz_init_set_ui(zero,0);
    
    //Calculo de la constante para salir de la representacion de montgomery
    mpz_ui_pow_ui(r,2,16*(getMpzSize(m)+1));
    mpz_mul(r_aux,r,r);
    mpz_mod(r_aux,r_aux,m);
    
    mpz_sub(n_cons,zero,m);
    mpz_invert(n_cons,n_cons,r);

   

    printf    ("n_c <= %x;\n\n", (uint32)mpz_getlimbn(n_cons,0)&0xffff);
    gmp_printf("r_c <= %Zx\n\n", r_aux);
   
    return 0;  
}
