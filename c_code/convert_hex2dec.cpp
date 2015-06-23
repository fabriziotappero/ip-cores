//
// EDAptability, SynEDA, Version 3.0.0, 2008\11\1
//

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <time.h>
FILE *dec;
FILE *hex;

int main(int argc, char *argv[])
{
	int c;
	int stat1 = 0;
	int stat2 = 0;
	int count = 0;
	int entries = 0;
	dec = fopen("a.dec","w");
	hex = fopen("a.hex","r");
	while (1)
	{
		c = getc(hex);
		if (c == -1)
		{
			break;
		}
		if (	(c == ' ')	|
			(c == '\t')	|
			(c == '\n')	|
			(c == '_')	|
			(c == ',')	|
			(c == ':')	|
			(c == 13)	|
			(c == 10)	)
		{
			stat1 = 0;
			stat2 = 0;
			count = 0;
		} else
		{
			if (stat1 == 0)
			{
				if (stat2 == 7)
				{
					stat1 = 1;
					stat2 = 0;
				} else
					stat2++;
			} else
			if (stat1 < 9)
			{
				printf("%c", c);
				stat2++;
				if (c < 58)
					count = count * 16 + (c - 48);
				else
					count = count * 16 + (c - 55);
				if (stat2 == 4)
				{
					printf(" %d\n", count);
					entries ++;
					stat2 = 0;
					stat1++;
					count = 0;
				}
			}
		}
	}
	fclose(hex);
	fprintf(dec, "%d\n", entries);
	hex = fopen("a.hex","r");
	while (1)
	{
		c = getc(hex);
		if (c == -1)
		{
			break;
		}
		if (	(c == ' ')	|
			(c == '\t')	|
			(c == '\n')	|
			(c == '_')	|
			(c == ',')	|
			(c == ':')	|
			(c == 13)	|
			(c == 10)	)
		{
			stat1 = 0;
			stat2 = 0;
			count = 0;
		} else
		{
			if (stat1 == 0)
			{
				if (stat2 == 7)
				{
					stat1 = 1;
					stat2 = 0;
				} else
					stat2++;
			} else
			if (stat1 < 9)
			{
				//printf("%c", c);
				stat2++;
				if (c < 58)
					count = count * 16 + (c - 48);
				else
					count = count * 16 + (c - 55);
				if (stat2 == 4)
				{
					fprintf(dec, "%d\n", count);
					stat2 = 0;
					stat1++;
					count = 0;
				}
			}
		}
	}
	fclose(hex);
	fclose(dec);
}

