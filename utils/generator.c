#include <stdio.h>
#include <string.h>
#include <stdint.h>

#include <openssl/rand.h>

#include "gost89.h"

gost_subst_block gost_sbox = {
  {0x4,0xA,0x9,0x2,0xD,0x8,0x0,0xE,0x6,0xB,0x1,0xC,0x7,0xF,0x5,0x3},
  {0xE,0xB,0x4,0xC,0x6,0xD,0xF,0xA,0x2,0x3,0x8,0x1,0x0,0x7,0x5,0x9},
  {0x5,0x8,0x1,0xD,0xA,0x3,0x4,0x2,0xE,0xF,0xC,0x7,0x6,0x0,0x9,0xB},
  {0x7,0xD,0xA,0x1,0x0,0x8,0x9,0xF,0xE,0x4,0x6,0xC,0xB,0x2,0x5,0x3},
  {0x6,0xC,0x7,0x1,0x5,0xF,0xD,0x8,0x4,0xA,0x9,0xE,0x0,0x3,0xB,0x2},
  {0x4,0xB,0xA,0x0,0x7,0x2,0x1,0xD,0x3,0x6,0x8,0x5,0x9,0xC,0xF,0xE},
  {0xD,0xB,0x4,0x1,0x3,0xF,0x5,0x9,0x0,0xA,0xE,0x7,0x6,0x8,0x2,0xC},
  {0x1,0xF,0xD,0x0,0x5,0x7,0xA,0x4,0x9,0x2,0x3,0xE,0x6,0xB,0x8,0xC}
};

uint8_t gost_key[] = {
  0x04, 0x75, 0xF6, 0xE0, 0x50, 0x38, 0xFB, 0xFA,
  0xD2, 0xC7, 0xC3, 0x90, 0xED, 0xB3, 0xCA, 0x3D,
  0x15, 0x47, 0x12, 0x42, 0x91, 0xAE, 0x1E, 0x8A,
  0x2F, 0x79, 0xCD, 0x9E, 0xD2, 0xBC, 0xEF, 0xBD
};

void print8bytes(const uint8_t* data) {
  for (int i = 0; i < 8; ++i)
    printf("%02x", data[i]);
}

void printNblocks(const uint8_t* data, size_t blocks) {
  while (blocks--) {
    print8bytes(&data[0]);
    printf(" ");
    data += 8;
  }
}

int main(int argc, char **argv) {
  int i;

  printf("SBox: 512'h ");
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k1[i]<<4) | gost_sbox.k1[i+1]);
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k2[i]<<4) | gost_sbox.k2[i+1]);
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k3[i]<<4) | gost_sbox.k3[i+1]);
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k4[i]<<4) | gost_sbox.k4[i+1]);
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k5[i]<<4) | gost_sbox.k5[i+1]);
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k6[i]<<4) | gost_sbox.k6[i+1]);
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k7[i]<<4) | gost_sbox.k7[i+1]);
  for(i = 0; i < 16; i+=2) printf("%02x", (gost_sbox.k8[i]<<4) | gost_sbox.k8[i+1]);
  printf("\n\n");

  printf("Key: 256'h ");
  for (i = 0; i < 32; ++i)
    printf("%02x", gost_key[i]);
  printf("\n\n");

  gost_ctx ctx;
  gost_init(&ctx, &gost_sbox);
  gost_set_key(&ctx, &gost_key[0]);

  uint8_t gamma[8];
  RAND_bytes(gamma, sizeof(gamma));

  uint8_t in[24];
  RAND_bytes(in, sizeof(in));
  uint8_t out1[sizeof(in)];
  uint8_t out2[sizeof(in)];

  /* ECB mode */
  printf("ECB mode:\n");
  printNblocks(&in[0], sizeof(in)/8); printf("\n");
  gost_ecb_encrypt(&ctx, &in[0], &out1[0], sizeof(in)/8);
  printNblocks(&out1[0], sizeof(in)/8); printf("\n");
  gost_ecb_decrypt(&ctx, &out1[0], &out2[0], sizeof(in)/8);
  printNblocks(&out2[0], sizeof(in)/8); printf("\n");
  if (memcmp((const void*) &in[0], (const void*) &out2[0], sizeof(in)))
    printf("error!\n");
  printf("\n");

  /* CFB mode */
  printf("CFB mode (gamma: "); print8bytes(&gamma[0]); printf("):\n");
  printNblocks(&in[0], sizeof(in)/8); printf("\n");
  gost_cfb_encrypt(&ctx, &gamma[0], &in[0], &out1[0], sizeof(in)/8);
  printNblocks(&out1[0], sizeof(in)/8); printf("\n");
  gost_cfb_decrypt(&ctx, &gamma[0], &out1[0], &out2[0], sizeof(in)/8);
  printNblocks(&out2[0], sizeof(in)/8); printf("\n");
  if (memcmp((const void*) &in[0], (const void*) &out2[0], sizeof(in)))
    printf("error!\n");
  printf("\n");

  /* MAC mode */
  printf("MAC mode (length: 32bit): \n");
  printNblocks(&in[0], sizeof(in)/8); printf("\n");
  memset((void*) &out1[0], 0, 8);
  gost_mac(&ctx, &in[0], sizeof(in), &out1[0], 32);
  print8bytes(&out1[0]); printf("\n\n");

  return 0;
}
