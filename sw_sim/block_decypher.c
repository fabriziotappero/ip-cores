/* this file simulates the block_decypher function */

#include <stdio.h>
#include <string.h>
#include "misc.h"

extern void block_decypher(int *kk, unsigned char *ib, unsigned char *bd);

int main()
{
        int           kk[57];
        int           kkt[56];
        unsigned char ib[8];
        unsigned char bd[8];
        READ_DATA(kkt,56*8);
        memset(kk,0,sizeof kk);
        memcpy(kk+1,kkt,sizeof kkt);
        READ_DATA(ib,8*8);
        block_decypher(kk, ib, bd);
        WRITE_DATA(bd,8*8);
#ifdef DEBUG
        WRITE_DATA(kkt,56*8);
        WRITE_DATA(ib,8*8);
#endif

        return 0;
}
