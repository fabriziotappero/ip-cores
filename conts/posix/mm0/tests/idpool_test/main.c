


#include "bit.h"
#include "idpool.h"
#include <stdio.h>

#define CTOTAL	3

int main(int argc, char *argv[])
{
	struct id_pool *pool = id_pool_new_init(64);
	int id_array[64];
	int first;


	if ((first = ids_new_contiguous(pool, 64)) < 0)
		printf("%d contig ids not allocated.\n", 64);
	else
		printf("%d contig ids allocated starting from %d\n", 64, first);

	if (ids_del_contiguous(pool, 5, 60) == 0)
		printf("%d contig ids freed with success.\n", 64);
	else
		printf("%d-%d contig ids could not be freed\n", 1, 65);
	return 0;
}
/*
int main(int argc, char *argv[])
{
	struct id_pool *pool = id_pool_new_init(64);
	int id_array[64];
	int first;


	for (int i = 0; i < 64; i++) {
		id_array[i] = id_new(pool);
		printf("Allocated id: %d\n", id_array[i]);
	}
	if ((first = ids_new_contiguous(pool, CTOTAL)) < 0)
		printf("%d contig ids not allocated as expected.\n", CTOTAL);

	printf("Now freeing id_array[30 - 32]\n");
	ids_del_contiguous(pool, id_array[30], 3);
	ids_del_contiguous(pool, id_array[35], 9);
	if ((first = ids_new_contiguous(pool, CTOTAL + 3)) < 0)
		printf("%d contig ids not allocated.\n", CTOTAL + 3);
	else
		printf("%d contig ids allocated starting from %d\n", CTOTAL + 3, first);

	if ((first = ids_new_contiguous(pool, CTOTAL)) < 0)
		printf("Error: %d contig ids not allocated.\n", CTOTAL);
	else
		printf("%d contig ids allocated as expected starting from %d\n", CTOTAL, first);

	return 0;
}
*/
