//#include <stdio.h>
static unsigned r0, r1, r2, r3, r5, r15;
int main()
{
	r0 = 0;
	r1 = 0;
	r2 = 4;
	r3 = 3;
	while (1)
	{
		r0++;
		r15 = r3 | r2;
		if (r15 < 10)
		{
		//////////////////////////////
		r15 = r3 ^ r2;
		if (r15 <= 10)
		{
		//////////////////////////////
		r15 = r2 << 1;
		if (r15 >= 1)
		{
			//printf("cont %h\n", r15);
			r1++;
		}
		}
		}
		if (r0 != r1)
			break;
	}
}
