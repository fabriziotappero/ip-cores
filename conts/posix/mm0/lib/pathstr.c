/*
 * Functions to manipulate path strings.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <string.h>
#include <alloca.h>

/* Reverses a string by allocating on stack. Not super-efficient but easy. */
char *strreverse(char *str)
{
	int length = strlen(str);
	char *tmp = alloca(length);

	strcpy(tmp, str);

	for (int i = 0; i < length; i++)
		str[i] = tmp[length - 1 - i];

	return str;
}

/*
 * Splits the string str according to the given seperator, returns the
 * first component, and modifies the str so that it points at the next
 * available component (or a leading separator which can be filtered
 * out on a subsequent call to this function).
 */
char *splitpath(char **str, char sep)
{
	char *cursor = *str;
	char *end;

	/* Move forward until no seperator */
	while (*cursor == sep) {
		*cursor = '\0';
		cursor++;	/* Move to first char of component */
	}

	end = cursor;
	while (*end != sep && *end != '\0')
		end++;		/* Move until end of component */

	if (*end == sep) {	/* if ended with separator */
		*end = '\0';	/* finish component by null */
		if (*(end + 1) != '\0')	/* if more components after, */
			*str = end + 1;	/* assign beginning to str */
		else
			*str = end; /* else str is also depleted, give null */
	} else /* if end was null, that means the end for str, too. */
		*str = end;

	return cursor;
}

/* Same as split path, but splits components from the end. Slow. */
char *splitpath_end(char **path, char sep)
{
	char *component;

	/* Reverse the string */
	strreverse(*path);

	/* Pick one from the start */
	component = splitpath(path, sep);

	/* Reverse the rest back to original. */
	strreverse(*path);

	/* Reverse component back to original */
	strreverse(component);

	return component;
}

/* Splitpath test program. Tests all 3 functions.
int main()
{
	char str1[256] = "/a/b/c/d/////e/f";
	char *str2 = malloc(strlen(str1) + 1);
	char *comp;

	strcpy(str2, str1);

	comp = splitpath_end(&str2, '/');
	while (*comp) {
		printf("%s and %s\n", comp, str2);
		comp = splitpath_end(&str2, '/');
	}
}
*/

