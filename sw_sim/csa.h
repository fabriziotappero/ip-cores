#ifndef CSA_H
#define CSA_H

struct key {
	int odd_kk[57], even_kk[57];
	unsigned char odd_ck[8], even_ck[8];
};

void set_cws(unsigned char *cws, struct key *key);

void decrypt(struct key *key, unsigned char *encrypted, unsigned char *decrypted);

#endif
