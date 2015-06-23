#ifndef __GOST89_H
#define __GOST89_H

#include <stdint.h>
#include <stddef.h>


/* GOST substitution blocks */
typedef struct {
  uint8_t k1[16];
  uint8_t k2[16];
  uint8_t k3[16];
  uint8_t k4[16];
  uint8_t k5[16];
  uint8_t k6[16];
  uint8_t k7[16];
  uint8_t k8[16];
} gost_subst_block;

/* Cipher context */
typedef struct {
  uint32_t k[8];
  uint32_t k87[256], k65[256], k43[256], k21[256];
} gost_ctx;

/* Set S-blocks into context */
void gost_init(gost_ctx *c, const gost_subst_block* b);
/* Clean up context */
void gost_destroy(gost_ctx* c);
/* Set key into context */
void gost_set_key(gost_ctx *c, const uint8_t *k);
/* Get key from context */
void gost_get_key(gost_ctx *c, uint8_t *k);

/* Encrypt several full blocks in ECB mode */
void gost_ecb_encrypt(gost_ctx *ctx, const uint8_t *in, uint8_t *out, size_t blocks);
/* Decrypt several full blocks in ECB mode */
void gost_ecb_decrypt(gost_ctx *ctx, const uint8_t *in, uint8_t *out, size_t blocks);

/* Encrypt several full blocks in CFB mode */
void gost_cfb_encrypt(gost_ctx *ctx, const uint8_t *iv, const uint8_t *in, uint8_t *out, size_t blocks);
/* Decrypt several full blocks in CFB mode */
void gost_cfb_decrypt(gost_ctx *ctx, const uint8_t *iv, const uint8_t *in, uint8_t *out, size_t blocks);

/* Compute MAC of given length in bits from data */
void gost_mac(gost_ctx *ctx, const uint8_t *data, size_t data_len, uint8_t *mac, size_t mac_len);

#endif
