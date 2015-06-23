#include <assert.h>
#include <string.h>

#include "gost89.h"


// Substitution blocks from RFC 4357, item 11.2
gost_subst_block GOST28147_89_RFC = {
  {0x4,0xA,0x9,0x2,0xD,0x8,0x0,0xE,0x6,0xB,0x1,0xC,0x7,0xF,0x5,0x3},
  {0xE,0xB,0x4,0xC,0x6,0xD,0xF,0xA,0x2,0x3,0x8,0x1,0x0,0x7,0x5,0x9},
  {0x5,0x8,0x1,0xD,0xA,0x3,0x4,0x2,0xE,0xF,0xC,0x7,0x6,0x0,0x9,0xB},
  {0x7,0xD,0xA,0x1,0x0,0x8,0x9,0xF,0xE,0x4,0x6,0xC,0xB,0x2,0x5,0x3},
  {0x6,0xC,0x7,0x1,0x5,0xF,0xD,0x8,0x4,0xA,0x9,0xE,0x0,0x3,0xB,0x2},
  {0x4,0xB,0xA,0x0,0x7,0x2,0x1,0xD,0x3,0x6,0x8,0x5,0x9,0xC,0xF,0xE},
  {0xD,0xB,0x4,0x1,0x3,0xF,0x5,0x9,0x0,0xA,0xE,0x7,0x6,0x8,0x2,0xC},
  {0x1,0xF,0xD,0x0,0x5,0x7,0xA,0x4,0x9,0x2,0x3,0xE,0x6,0xB,0x8,0xC}
};


void gost_init(gost_ctx *c, const gost_subst_block* b) {
  int i;

  if (!b)
    b = &GOST28147_89_RFC;

  for (i = 0; i < 256; ++i) {
    c->k21[i] = (b->k2[i>>4]<<4 | b->k1 [i&15]);
    c->k43[i] = (b->k4[i>>4]<<4 | b->k3 [i&15])<<8;
    c->k65[i] = (b->k6[i>>4]<<4 | b->k5 [i&15])<<16;
    c->k87[i] = (b->k8[i>>4]<<4 | b->k7 [i&15])<<24;
  }
}

void gost_destroy(gost_ctx *c) {
  int i;

  for (i = 0; i < 8; ++i)
    c->k[i] = 0;
  for (i = 0; i < 256; ++i)
    c->k87[i] = c->k65[i] = c->k43[i] = c->k21[i] = 0;
}

void gost_set_key(gost_ctx *c, const uint8_t *k) {
  int i, j;
  for (i=0, j=0; i < 8; i+=1, j+=4)
    c->k[i] = (k[j]<<24) | (k[j+1]<<16) | (k[j+2]<<8) | k[j+3];
}

void gost_get_key(gost_ctx *c, uint8_t *k) {
  int i, j;

  for (i=0, j=0; i < 8; i+=1, j+=4) {
    k[j]   = (uint8_t) ((c->k[i]    ) &0xFF);
    k[j+1] = (uint8_t) ((c->k[i]>>8 ) &0xFF);
    k[j+2] = (uint8_t) ((c->k[i]>>16) &0xFF);
    k[j+3] = (uint8_t) ((c->k[i]>>24) &0xFF);
  } 
}

inline uint32_t f(gost_ctx *c, uint32_t x) {
  x = c->k87[x>>24 & 255] | c->k65[x>>16 & 255] |
      c->k43[x>> 8 & 255] | c->k21[x     & 255];
  return x<<11 | x>>(32-11);
}

inline void gost_encrypt_block(gost_ctx *c, const uint8_t *in, uint8_t *out) {
  register uint32_t n1, n2;
  n1 = (in[0]<<24) | (in[1]<<16) | (in[2]<<8) | in[3];
  n2 = (in[4]<<24) | (in[5]<<16) | (in[6]<<8) | in[7];

  n2 ^= f(c,n1+c->k[0]); n1 ^= f(c,n2+c->k[1]);
  n2 ^= f(c,n1+c->k[2]); n1 ^= f(c,n2+c->k[3]);
  n2 ^= f(c,n1+c->k[4]); n1 ^= f(c,n2+c->k[5]);
  n2 ^= f(c,n1+c->k[6]); n1 ^= f(c,n2+c->k[7]);
  
  n2 ^= f(c,n1+c->k[0]); n1 ^= f(c,n2+c->k[1]);
  n2 ^= f(c,n1+c->k[2]); n1 ^= f(c,n2+c->k[3]);
  n2 ^= f(c,n1+c->k[4]); n1 ^= f(c,n2+c->k[5]);
  n2 ^= f(c,n1+c->k[6]); n1 ^= f(c,n2+c->k[7]);
                               
  n2 ^= f(c,n1+c->k[0]); n1 ^= f(c,n2+c->k[1]);
  n2 ^= f(c,n1+c->k[2]); n1 ^= f(c,n2+c->k[3]);
  n2 ^= f(c,n1+c->k[4]); n1 ^= f(c,n2+c->k[5]);
  n2 ^= f(c,n1+c->k[6]); n1 ^= f(c,n2+c->k[7]);
                               
  n2 ^= f(c,n1+c->k[7]); n1 ^= f(c,n2+c->k[6]);
  n2 ^= f(c,n1+c->k[5]); n1 ^= f(c,n2+c->k[4]);
  n2 ^= f(c,n1+c->k[3]); n1 ^= f(c,n2+c->k[2]);
  n2 ^= f(c,n1+c->k[1]); n1 ^= f(c,n2+c->k[0]);

  out[0] = (uint8_t) (n2>>24);       out[1] = (uint8_t) ((n2>>16)&0xff);
  out[2] = (uint8_t) ((n2>>8)&0xff); out[3] = (uint8_t) (n2&0xff);
  out[4] = (uint8_t) (n1>>24);       out[5] = (uint8_t) ((n1>>16)&0xff);
  out[6] = (uint8_t) ((n1>>8)&0xff); out[7] = (uint8_t) (n1&0xff);
}

inline void gost_decrypt_block(gost_ctx *c, const uint8_t *in, uint8_t *out) {
  register uint32_t n1, n2;
  n1 = (in[0]<<24) | (in[1]<<16) | (in[2]<<8) | in[3];
  n2 = (in[4]<<24) | (in[5]<<16) | (in[6]<<8) | in[7];

  n2 ^= f(c,n1+c->k[0]); n1 ^= f(c,n2+c->k[1]);
  n2 ^= f(c,n1+c->k[2]); n1 ^= f(c,n2+c->k[3]);
  n2 ^= f(c,n1+c->k[4]); n1 ^= f(c,n2+c->k[5]);
  n2 ^= f(c,n1+c->k[6]); n1 ^= f(c,n2+c->k[7]);

  n2 ^= f(c,n1+c->k[7]); n1 ^= f(c,n2+c->k[6]);
  n2 ^= f(c,n1+c->k[5]); n1 ^= f(c,n2+c->k[4]);
  n2 ^= f(c,n1+c->k[3]); n1 ^= f(c,n2+c->k[2]);
  n2 ^= f(c,n1+c->k[1]); n1 ^= f(c,n2+c->k[0]);
  
  n2 ^= f(c,n1+c->k[7]); n1 ^= f(c,n2+c->k[6]);
  n2 ^= f(c,n1+c->k[5]); n1 ^= f(c,n2+c->k[4]);
  n2 ^= f(c,n1+c->k[3]); n1 ^= f(c,n2+c->k[2]);
  n2 ^= f(c,n1+c->k[1]); n1 ^= f(c,n2+c->k[0]);
  
  n2 ^= f(c,n1+c->k[7]); n1 ^= f(c,n2+c->k[6]);
  n2 ^= f(c,n1+c->k[5]); n1 ^= f(c,n2+c->k[4]);
  n2 ^= f(c,n1+c->k[3]); n1 ^= f(c,n2+c->k[2]);
  n2 ^= f(c,n1+c->k[1]); n1 ^= f(c,n2+c->k[0]);

  out[0] = (uint8_t) (n2>>24);       out[1] = (uint8_t) ((n2>>16)&0xff);
  out[2] = (uint8_t) ((n2>>8)&0xff); out[3] = (uint8_t) (n2&0xff);
  out[4] = (uint8_t) (n1>>24);       out[5] = (uint8_t) ((n1>>16)&0xff);
  out[6] = (uint8_t) ((n1>>8)&0xff); out[7] = (uint8_t) (n1&0xff);
}

void gost_ecb_encrypt(gost_ctx *ctx, const uint8_t *in, uint8_t *out, size_t blocks) {
  while (blocks--) {
    gost_encrypt_block(ctx, in, out);
    in  += 8;
    out += 8;
  }
}

void gost_ecb_decrypt(gost_ctx *ctx, const uint8_t *in, uint8_t *out, size_t blocks) {
  while (blocks--) {
    gost_decrypt_block(ctx, in, out);
    in  += 8;
    out += 8;
  }
}

void gost_cfb_encrypt(gost_ctx *ctx, const uint8_t *iv, const uint8_t *in, uint8_t *out, size_t blocks) {
  uint8_t cur_iv[8], gamma[8];
  memcpy((void*) &cur_iv[0], (const void*) &iv[0], 8);
  while (blocks--) {
    gost_encrypt_block(ctx, cur_iv, gamma);
    for (int i = 0; i < 8; ++i) {
      out[i] = in[i] ^ gamma[i];
      cur_iv[i] = out[i];
    }
    in  += 8;
    out += 8;
  }
}

void gost_cfb_decrypt(gost_ctx *ctx, const uint8_t *iv, const uint8_t *in, uint8_t *out, size_t blocks) {
  uint8_t cur_iv[8], gamma[8];
  memcpy((void*) &cur_iv[0], (const void*) &iv[0], 8);
  while (blocks--) {
    gost_encrypt_block(ctx, cur_iv, gamma);
    for (int i = 0; i < 8; ++i) {
      out[i] = in[i] ^ gamma[i];
      cur_iv[i] = in[i];
    }
    in  += 8;
    out += 8;
  }
}

inline void gost_mac_block(gost_ctx *c, const uint8_t *in, uint8_t *out) {
  register uint32_t n1, n2;
  n1 = (in[0]<<24) | (in[1]<<16) | (in[2]<<8) | in[3];
  n2 = (in[4]<<24) | (in[5]<<16) | (in[6]<<8) | in[7];

  n2 ^= f(c,n1+c->k[0]); n1 ^= f(c,n2+c->k[1]);
  n2 ^= f(c,n1+c->k[2]); n1 ^= f(c,n2+c->k[3]);
  n2 ^= f(c,n1+c->k[4]); n1 ^= f(c,n2+c->k[5]);
  n2 ^= f(c,n1+c->k[6]); n1 ^= f(c,n2+c->k[7]);
  
  n2 ^= f(c,n1+c->k[0]); n1 ^= f(c,n2+c->k[1]);
  n2 ^= f(c,n1+c->k[2]); n1 ^= f(c,n2+c->k[3]);
  n2 ^= f(c,n1+c->k[4]); n1 ^= f(c,n2+c->k[5]);
  n2 ^= f(c,n1+c->k[6]); n1 ^= f(c,n2+c->k[7]);

  out[0] = (uint8_t) (n2>>24);       out[1] = (uint8_t) ((n2>>16)&0xff);
  out[2] = (uint8_t) ((n2>>8)&0xff); out[3] = (uint8_t) (n2&0xff);
  out[4] = (uint8_t) (n1>>24);       out[5] = (uint8_t) ((n1>>16)&0xff);
  out[6] = (uint8_t) ((n1>>8)&0xff); out[7] = (uint8_t) (n1&0xff);
}

void gost_mac(gost_ctx *ctx, const uint8_t *data, size_t data_len, uint8_t *mac, const size_t mac_len) {
  assert(data_len >= 16);
  assert(mac_len <= 32);

  uint8_t out[8] = {0};

  while (data_len > 0) {
    uint8_t in[8] = {0};
    memcpy((void*) &in[0], (const void*) &data[0], data_len < 8 ? data_len : 8);

    for (int i = 0; i < 8; ++i)
      in[i] = in[i] ^ out[i];
    gost_mac_block(ctx, in, &out[0]);

    data_len -= 8;
    data += 8;
  }

  uint8_t nbytes = (mac_len>>3) + ((mac_len&7) > 0 ? 1 : 0);
  memset((void*) mac, 0, nbytes);


  uint32_t fmac = (out[0]<<24) | (out[1]<<16) | (out[2]<<8) | out[3];
  fmac <<= 32 - mac_len;
  out[0] = (uint8_t) (fmac>>24);       out[1] = (uint8_t) ((fmac>>16)&0xff);
  out[2] = (uint8_t) ((fmac>>8)&0xff); out[3] = (uint8_t) (fmac&0xff);

  for (int i = 0; i < nbytes; ++i)
    mac[i] = out[i];
}
