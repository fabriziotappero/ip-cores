// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#include "utilities.h"

void * memset(void * s, int c, int n)
{
	char * temp = s;
	for(int i = 0; i < n; ++i)
		temp[i] = c;
	return s;
}

