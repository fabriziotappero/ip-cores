#ifndef __ATOI_H__
#define __ATOI_H__

static inline int power(int exp, int mul)
{
	int total = 1;

	while (exp > 0) {
		total *= mul;
		exp--;
	}
	return total;
}

static inline int ascii_to_int(char *str)
{
	int size = strlen(str);
	int iter = size - 1;
	int num = 0;

	for (int i = 0; i < size; i++)
		num += ((int)str[iter - i] - 48) * power(i, 10);
	return num;
}

#endif
