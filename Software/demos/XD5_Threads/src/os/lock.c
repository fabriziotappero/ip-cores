#include <stdlib.h> /* only for NULL */
#include "lock.h"

void Lock(volatile int *lock, int *load_count, int *store_count)
{
	int l_tries = 0;
	int s_tries = 0;

	asm volatile(
		".set noreorder\n\t"
		"addiu	$8, $0, 1\n\t"
		"addu	%[l_tries], $0, $0\n\t"
		"addu	%[s_tries], $0, $0\n\t"
		"1:\n\t"
		"ll	$9, %[lock]\n\t"
		"bne	$9, $0, 1b\n\t"
		"addiu	%[l_tries], %[l_tries], 1\n\t"
		"sc	$8, %[lock]\n\t"
		"beq	$8, $0, 1b\n\t"
		"addiu	%[s_tries], %[s_tries], 1\n\t"
		".set reorder\n\t"
		: [l_tries] "=&r"(l_tries), [s_tries] "=&r"(s_tries), 
		[lock] "+m"(*lock)
		: 
		: "$8", "$9", "memory"
	);

	if (load_count != NULL) {
		*load_count = l_tries;
	}
	if (store_count != NULL) {
		*store_count = s_tries;
	}
}

void LockAlmost(volatile int *lock, int *load_count, int *store_count)
{
	int l_tries = 0;
	int s_tries = 0;

	asm volatile(
		".set noreorder\n\t"
		"addiu	$8, $0, 1\n\t"
		"addu	%[l_tries], $0, $0\n\t"
		"addu	%[s_tries], $0, $0\n\t"
		"1:\n\t"
		"ll	$9, %[lock]\n\t"
		"bne	$9, $0, 1b\n\t"
		"addiu	%[l_tries], %[l_tries], 1\n\t"
		
		"nop\n\t"
		"nop\n\t"

		"sc	$8, %[lock]\n\t"
		"addiu	%[s_tries], %[s_tries], 1\n\t"
		".set reorder\n\t"
		: [l_tries] "=&r"(l_tries), [s_tries] "=&r"(s_tries),
		[lock] "+m"(*lock)
		:
		: "$8", "$9", "memory"
	);

	if (load_count != NULL) {
		*load_count = l_tries;
	}
	if (store_count != NULL) {
		*store_count = s_tries;
	}
}


void LockNull(volatile int *lock, int *load_count, int *store_count)
{
	if (load_count != NULL) {
		*load_count = 1;
	}
	if (store_count != NULL) {
		*store_count = 1;
	}
}

void Unlock(volatile int *lock)
{
	*lock = 0;
}

