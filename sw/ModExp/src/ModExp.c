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
	unsigned int base_width, exp_width;
	mpz_t m, g0, g1, e0, e1, R, R2, result, tmp, gt0, gt1, gt01;
	gmp_randstate_t state;

	gmp_randinit_default(state);
	mpz_init(m);
	mpz_init(g0);
	mpz_init(g1);
	mpz_init(e0);
	mpz_init(e1);
	mpz_init(R);
	mpz_init(R2);
	mpz_init(result);
	mpz_init(tmp);
	mpz_init(gt0);
	mpz_init(gt1);
	mpz_init(gt01);

	printf("-- input generator program\n");
	printf("--  generates test values per bit input pair\n");

	while (1){

		//read in base_width
		scanf("%d", &base_width);
		if (base_width == 0) break;
		scanf("%d", &exp_width);

		//generate modulus (must be uneven)
		mpz_urandomb(m, state, base_width);
		mpz_setbit(m, 0); //uneven

		//generate g0
		mpz_urandomb(g0, state, base_width);

		//generate g1
		mpz_urandomb(g1, state, base_width);

		//generate e0
		mpz_urandomb(e0, state, exp_width);

		//generate e1
		mpz_urandomb(e1, state, exp_width);

		//calculate R
		mpz_set_ui(R, 2);
		mpz_powm_ui(R, R, base_width, m); //R = 2^n mod m

		//calculate R2
		mpz_set_ui(R2, 2);
		mpz_powm(R2, R, R2, m); //R2 = R² mod m = 2^2n mod m

		//calc precompute values
		mpz_mul(gt0, g0, R);
		mpz_powm_ui(gt0, gt0, 1, m);
		mpz_mul(gt1, g1, R);
		mpz_powm_ui(gt1, gt1, 1, m);
		mpz_mul(gt01, g0, g1);
		mpz_mul(gt01, gt01, R);
		mpz_powm_ui(gt01, gt01, 1, m);

		//calculate result
		mpz_powm(result, g0, e0, m);
		mpz_powm(tmp, g1, e1, m);
		mpz_mul(result, result, tmp);
		mpz_powm_ui(result, result, 1, m);

		printf("-- base_width, exp_width, g0, g1, e0, e1, m, R^2, result\n");
		printf("%d\n", base_width);
		printf("%d\n", exp_width);
		gmp_printf("%Zx\n", g0);
		gmp_printf("%Zx\n", g1);
		gmp_printf("%Zx\n", e0);
		gmp_printf("%Zx\n", e1);
		gmp_printf("%Zx\n", m);
		gmp_printf("%Zx\n", R2);
		gmp_printf("%Zx\n", R);
		gmp_printf("%Zx\n", gt0);
		gmp_printf("%Zx\n", gt1);
		gmp_printf("%Zx\n", gt01);
		gmp_printf("%Zx\n", result);
	}

	mpz_clear(g0);
	mpz_clear(g1);
	mpz_clear(e0);
	mpz_clear(e1);
	mpz_clear(m);
	mpz_clear(result);
	mpz_clear(tmp);
	mpz_clear(R);
	mpz_clear(R2);
	mpz_clear(gt0);
	mpz_clear(gt1);
	mpz_clear(gt01);

	return EXIT_SUCCESS;
}
