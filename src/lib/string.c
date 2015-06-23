/*
 * Copyright 2008-2010 B Labs Ltd.
 */

void *_memset(void *p, int c, int size);
void *_memcpy(void *d, void *s, int size);

void *memset(void *p, int c, int size)
{
	return _memset(p, c, size);
}

void *memcpy(void *d, void *s, int size)
{
	return _memcpy(d, s, size);
}


int strcmp(const char *s1, const char *s2)
{
	unsigned int i = 0;
	int d;

	while(1) {
		d = (unsigned char)s1[i] - (unsigned char)s2[i];
		if (d != 0 || s1[i] == '\0')
			return d;
		i++;
	}
}

/*
 * Copies string pointed by @from to string pointed by @to.
 *
 * If count is greater than the length of string in @from,
 * pads rest of the locations with null.
 */
char *strncpy(char *to, const char *from, int count)
{
	char *temp = to;

	while (count) {
		*temp = *from;

		/*
		 * Stop updating from if null
		 * terminator is reached.
		 */
		if (*from)
			from++;
		temp++;
		count--;
	}
	return to;
}
