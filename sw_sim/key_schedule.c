/* this file simulates the key_schedule funtion */

#include <stdio.h>
#include <string.h>
#include "misc.h"

extern void key_schedule(unsigned char *CK, int *kk) ;

int main()
{
        unsigned char CK[8];
        int           kk[57];

        READ_DATA(CK,8);

        key_schedule(CK,kk);

        /*WRITE_DATA(&(kk[1]),56);*/ /* note: can not write this array once in here*/
        {
                int i ;
                for(i=0;i<56;i++)
                        WRITE_DATA(&kk[1+i],1);
        }
        return 0;
}
