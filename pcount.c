#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

typedef unsigned long count_t;

count_t pcount_decode(unsigned n, count_t b) {
  count_t y = b;
  unsigned k;
  for (k = 1; k < n; k++)
    if ((y & ((1<<k)-1)) < k)
      y = y ^ (1<<k);
  return y;
}

count_t pcount_encode(unsigned n, count_t y) {
  count_t b = y;
  unsigned k;
  for (k = n-1; k > 0; k--)
    if ((b & ((1<<k)-1)) < k)
      b = b ^ (1<<k);
  return b;
}

int main() {
  char s[256], *c;
  count_t b, y, z;
  for (;;) {
    if (!fgets(s, sizeof(s), stdin))
      break;
    for (c = s + strlen(s) - 1; isspace(*c); c--)
      *c = '\0';

    b = strtoul(s, NULL, 2);
    y = pcount_decode(strlen(s), b);
    z = pcount_encode(strlen(s), y);
    printf("%08lx -> %08lx -> %08lx\n", b, y, z);
  }
  return 0;
}
