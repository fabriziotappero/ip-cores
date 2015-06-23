/*
 * =====================================================================================
 *
 *       Filename:  key_perm.c
 *
 *    Description:  this file tests the key_perm function
 *
 *        Version:  1.0
 *        Created:  07/05/2008 07:51:58 AM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  mengxipeng$gmai.com
 *        Company:  mengxipeng
 *
 * =====================================================================================
 */

#include <stdio.h>
#include <memory.h>

extern unsigned char key_perm[0x40]; /* defined in csa.c */

unsigned char i_key[8];
unsigned char o_key[8];

int main()
{
        int           i;
        int           j;
        int           k;
        unsigned char p;
        int           v;
        int           c;
        int           b;
        /* first read the input key */
        memset(i_key,0,sizeof i_key);
        for (i=63;i>=0;i--)
        {
             c=getchar();   
             printf("%c",c);
             if(c=='1')
             {
                     i_key[i/8]|=(1<<(i%8));
             }
        }
        printf("\n");

        /*  now do the key_perm operatioin */
        memset(o_key,0,sizeof o_key);
        /* 64 bit perm on kb */
        for (j = 0; j < 8; j++)
        {
        	for (k = 0; k < 8; k++)
        	{
                        b=key_perm[j*8+k]-1;
                        if((i_key[j] >> (7 - k)) & 1)
                        {                         
                                o_key[b/8] |= (1<<(7-(b%8)));
                        }
        	}
        }

        /*  output the o_key */
        for (i=63;i>=0;i--)
        {
                if(o_key[i/8]&(1<<(i%8)))
                        printf("1");
                else
                        printf("0");
        }
        printf("\n");

        return 0;
}
