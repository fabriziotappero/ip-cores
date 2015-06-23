#ifndef __LIB_MATH_H__
#define __LIB_MATH_H__

/* Take the power */
static inline int pow(int val, int exp)
{
	int res = 1;

	for (int i = 0; i < exp; i++)
		res *= val;
	return res;
}

static inline int min(int x, int y)
{
	return x < y ? x : y;
}

static inline int max(int x, int y)
{
	return x > y ? x : y;
}

/* Tests if ranges a-b intersect with range c-d */
static inline int set_intersection(unsigned long a, unsigned long b,
				   unsigned long c, unsigned long d)
{
	/*
	 * Below is the complement set (') of the intersection
	 * of 2 ranges, much simpler ;-)
	 */
	if (b <= c || a >= d)
		return 0;

	/* The rest is always intersecting */
	return 1;
}

#endif /* __LIB_MATH_H__ */
