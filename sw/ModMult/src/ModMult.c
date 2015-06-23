/*
 ============================================================================
 Name        : ModExp.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>

int main(void) {
	unsigned int base_width;
	mpz_t x, m, r, R, R2;
	gmp_randstate_t state;

	gmp_randinit_mt(state);
	mpz_init(x);
	mpz_init(m);
	mpz_init(r);
	mpz_init(R);
	mpz_init(R2);

	printf("-- input generator program\n");
	printf("--  generates test values for multiplier testbench\n");

	while (1){

		//read in base_width
		scanf("%d", &base_width);
		if (base_width == 0) break;

		//generate modulus (must be uneven)
		mpz_urandomb(m, state, base_width);
		mpz_setbit(m, 0); //uneven

		//generate x
		mpz_urandomb(x, state, base_width);

		//calculate R
		mpz_set_ui(R, 2);
		mpz_powm_ui(R, R, base_width, m); //R = 2^n mod m

		//calculate R2
		mpz_set_ui(R2, 2);
		mpz_powm(R2, R, R2, m); //R2 = R² mod m = 2^2n mod m

		//calculate result
		mpz_mul(r, x, R);
		mpz_powm_ui(r, r, 1, m);

		printf("-- x, y, m, result\n");
		gmp_printf("%Zx\n", x);
		gmp_printf("%Zx\n", R2);
		gmp_printf("%Zx\n", m);
		gmp_printf("%Zx\n", r);
	}

	mpz_clear(x);
	mpz_clear(R2);
	mpz_clear(m);
	mpz_clear(r);
	mpz_clear(R);
	gmp_randclear(state);

	return EXIT_SUCCESS;
}
