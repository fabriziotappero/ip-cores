/*
 * =====================================================================================
 *
 *       Filename:  group_decrypt.c
 *
 *    Description:  test group decryp module
 *
 *        Version:  1.0
 *        Created:  04/25/2009 11:56:00 AM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  mengxipeng@gmail.com        
 *
 * =====================================================================================
 */

#include <stdio.h>
#include <string.h>
#include "misc.h"
#include "csa.h"

void key_schedule(unsigned char *CK, int *kk) ;
void stream_cypher(int init, unsigned char *CK, unsigned char *sb, unsigned char *cb) ;
void block_decypher(int *kk, unsigned char *ib, unsigned char *bd) ;

int main()
{
        unsigned char ck[8];
        int kk[57];
        unsigned char encrypted[184];
        unsigned char decrypted[184];
        READ_DATA(ck,8);
        key_schedule(ck,kk);
        READ_DATA(encrypted,184);
        {
                int i,j,offset=0,N;
                unsigned char stream[8];
                unsigned char ib[8];
                unsigned char block[8];
                int residue;

                N = (184 - offset) / 8;
                residue = (184 - offset) % 8;
                
                /*  1st 8 bytes of initialisation */
                stream_cypher(1, ck, &encrypted[offset], ib);


                for(j=1; j<(N+1); j++) {
                        block_decypher(kk, ib, block);
                        DEBUG_OUTPUT_ARR(block,8);

                        if (j != N) {
                                stream_cypher(0, ck, NULL, stream);

                                /*  xor sb x stream */
                                for(i=0; i<8; i++)
                                        ib[i] = encrypted[offset+8*j+i] ^ stream[i];
                        }
                        else {
                                /*  last block - sb[N+1] = IV(initialisation vetor)(=0) */
                                for(i=0; i<8; i++)  ib[i] = 0;
                        }

                        /*  xor ib x block */
                        for(i=0; i<8; i++)
                                decrypted[offset+8*(j-1)+i] = ib[i] ^ block[i];
                        DEBUG_OUTPUT_ARR(&decrypted[offset+8*(j-1)+0],8);
                } /* for(j=1; j<(N+1); j++) */

                if (residue) {
                        stream_cypher(0, ck, NULL, stream);
                        for (i=0;i<residue;i++)
                                decrypted[184-residue+i] = encrypted[184-residue+i] ^ stream[i];
                }
        }
        WRITE_DATA(decrypted,184);
        return 0;
}

