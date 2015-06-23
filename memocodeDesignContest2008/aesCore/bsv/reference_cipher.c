#include "aes_core.h"
#include <assert.h>
#include <stdio.h>




static AES_KEY  db_encrypt_key;

const unsigned char globalkey[] = {0xB0, 0x1D, 0xFA, 0xCE, 
				   0x0D, 0xEC, 0x0D, 0xED, 
				   0x0B, 0xA1, 0x1A, 0xDE, 
				   0x0E, 0xFF, 0xEC, 0x70};




void
encrypt(){
  FILE *outplain, *outcodeword;
  const int bound = 1 << 18;
  static unsigned char plaindata[16] = {0x0, 0x0, 0x0, 0x0, 
				        0x0, 0x0, 0x0, 0x0,
                                        0x0, 0x0, 0x0, 0x0, 
				        0x0, 0x0, 0x0, 0x0};
  unsigned char cryptdata[16];
  int i,j;

  assert(outplain = fopen("plain.hex","w"));
  assert(outcodeword = fopen("code.hex","w"));
  AES_set_encrypt_key(globalkey, 128, &db_encrypt_key);
  for (j=0; j<bound; j++) {
    PUTU32(plaindata+12, j);
    AES_encrypt(plaindata, cryptdata, &db_encrypt_key);
   
      fprintf(outplain,"%08x%08x%08x%08x\n", GETU32(plaindata + 0),GETU32(plaindata + 4),GETU32(plaindata + 8),GETU32(plaindata + 12));
      fprintf(outcodeword,"%08x%08x%08x%08x\n",GETU32(cryptdata + 0),GETU32(cryptdata + 4),GETU32(cryptdata + 8),GETU32(cryptdata + 12));
    
  }
  
}

#ifdef EXECUTABLE

int
main(){
  encrypt();
  return 0;
}

#endif
