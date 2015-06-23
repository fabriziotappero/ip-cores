/*
 * romlib.c -- the ROM library
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "start.h"


/**************************************************************/


/*
 * This is only for debugging.
 * Place a breakpoint at the very beginning of this routine
 * and call it wherever you want to break execution.
 */
void debugBreak(void) {
}


/**************************************************************/


/*
 * Count the length of a string (without terminating null character).
 */
int strlen(const char *s) {
  const char *p;

  p = s;
  while (*p != '\0') {
    p++;
  }
  return p - s;
}


/*
 * Compare two strings.
 * Return a number < 0, = 0, or > 0 iff the first string is less
 * than, equal to, or greater than the second one, respectively.
 */
int strcmp(const char *s, const char *t) {
  while (*s == *t) {
    if (*s == '\0') {
      return 0;
    }
    s++;
    t++;
  }
  return *s - *t;
}


/*
 * Copy string t to string s (includes terminating null character).
 */
char *strcpy(char *s, const char *t) {
  char *p;

  p = s;
  while ((*p = *t) != '\0') {
    p++;
    t++;
  }
  return s;
}


/*
 * Append string t to string s.
 */
char *strcat(char *s, const char *t) {
  char *p;

  p = s;
  while (*p != '\0') {
    p++;
  }
  while ((*p = *t) != '\0') {
    p++;
    t++;
  }
  return s;
}


/*
 * Locate character c in string s.
 */
char *strchr(const char *s, char c) {
  while (*s != c) {
    if (*s == '\0') {
      return NULL;
    }
    s++;
  }
  return (char *) s;
}


/*
 * Extract the next token from the string s, delimited
 * by any character from the delimiter string t.
 */
char *strtok(char *s, const char *t) {
  static char *p;
  char *q;

  if (s != NULL) {
    p = s;
  } else {
    p++;
  }
  while (*p != '\0' && strchr(t, *p) != NULL) {
    p++;
  }
  if (*p == '\0') {
    return NULL;
  }
  q = p++;
  while (*p != '\0' && strchr(t, *p) == NULL) {
    p++;
  }
  if (*p != '\0') {
    *p = '\0';
  } else {
    p--;
  }
  return q;
}


/**************************************************************/


/*
 * Determine if a character is 'white space'.
 */
static Bool isspace(char c) {
  Bool res;

  switch (c) {
    case ' ':
    case '\f':
    case '\n':
    case '\r':
    case '\t':
    case '\v':
      res = true;
      break;
    default:
      res = false;
      break;
  }
  return res;
}


/*
 * Check for valid digit, and convert to value.
 */
static Bool checkDigit(char c, int base, int *value) {
  if (c >= '0' && c <= '9') {
    *value = c - '0';
  } else
  if (c >= 'A' && c <= 'Z') {
    *value = c - 'A' + 10;
  } else
  if (c >= 'a' && c <= 'z') {
    *value = c - 'a' + 10;
  } else {
    return false;
  }
  return *value < base;
}


/*
 * Convert initial part of string to unsigned long integer.
 */
unsigned long strtoul(const char *s, char **endp, int base) {
  unsigned long res;
  int sign;
  int digit;

  res = 0;
  while (isspace(*s)) {
    s++;
  }
  if (*s == '+') {
    sign = 1;
    s++;
  } else
  if (*s == '-') {
    sign = -1;
    s++;
  } else {
    sign = 1;
  }
  if (base == 0 || base == 16) {
    if (*s == '0' &&
        (*(s + 1) == 'x' || *(s + 1) == 'X')) {
      /* base is 16 */
      s += 2;
      base = 16;
    } else {
      /* base is 0 or 16, but number does not start with "0x" */
      if (base == 0) {
        if (*s == '0') {
          s++;
          base = 8;
        } else {
          base = 10;
        }
      } else {
        /* take base as is */
      }
    }
  } else {
    /* take base as is */
  }
  while (checkDigit(*s, base, &digit)) {
    res *= base;
    res += digit;
    s++;
  }
  if (endp != NULL) {
    *endp = (char *) s;
  }
  return sign * res;
}


/**************************************************************/


/*
 * Exchange two array items of a given size.
 */
static void xchg(char *p, char *q, int size) {
  char t;

  while (size--) {
    t = *p;
    *p++ = *q;
    *q++ = t;
  }
}


/*
 * This is a recursive version of quicksort.
 */
static void sort(char *l, char *r, int size,
                 int (*cmp)(const void *, const void *)) {
  char *i;
  char *j;
  char *x;

  i = l;
  j = r;
  x = l + (((r - l) / size) / 2) * size;
  do {
    while (cmp(i, x) < 0) {
      i += size;
    }
    while (cmp(x, j) < 0) {
      j -= size;
    }
    if (i <= j) {
      /* exchange array elements i and j */
      /* attention: update x if it is one of these */
      if (x == i) {
        x = j;
      } else
      if (x == j) {
        x = i;
      }
      xchg(i, j, size);
      i += size;
      j -= size;
    }
  } while (i <= j);
  if (l < j) {
    sort(l, j, size, cmp);
  }
  if (i < r) {
    sort(i, r, size, cmp);
  }
}


/*
 * External interface for the quicksort algorithm.
 */
void qsort(void *base, int n, int size,
           int (*cmp)(const void *, const void*)) {
  sort((char *) base, (char *) base + (n - 1) * size, size, cmp);
}


/**************************************************************/


/*
 * Input a character from the console.
 */
char getchar(void) {
  return cin();
}


/*
 * Output a character on the console.
 * Replace LF by CR/LF.
 */
void putchar(char c) {
  if (c == '\n') {
    cout('\r');
  }
  cout(c);
}


/*
 * Output a string on the console.
 * Replace LF by CR/LF.
 */
void puts(const char *s) {
  while (*s != '\0') {
    putchar(*s);
    s++;
  }
}


/**************************************************************/


/*
 * Count the number of characters needed to represent
 * a given number in base 10.
 */
static int countPrintn(long n) {
  long a;
  int res;

  res = 0;
  if (n < 0) {
    res++;
    n = -n;
  }
  a = n / 10;
  if (a != 0) {
    res += countPrintn(a);
  }
  return res + 1;
}


/*
 * Output a number in base 10.
 */
static void *printn(void *(*emit)(void *, char), void *arg,
                    int *nchar, long n) {
  long a;

  if (n < 0) {
    arg = emit(arg, '-');
    (*nchar)++;
    n = -n;
  }
  a = n / 10;
  if (a != 0) {
    arg = printn(emit, arg, nchar, a);
  }
  arg = emit(arg, n % 10 + '0');
  (*nchar)++;
  return arg;
}


/*
 * Count the number of characters needed to represent
 * a given number in a given base.
 */
static int countPrintu(unsigned long n, unsigned long b) {
  unsigned long a;
  int res;

  res = 0;
  a = n / b;
  if (a != 0) {
    res += countPrintu(a, b);
  }
  return res + 1;
}


/*
 * Output a number in a given base.
 */
static void *printu(void *(*emit)(void *, char), void *arg,
                    int *nchar, unsigned long n, unsigned long b,
                    Bool upperCase) {
  unsigned long a;

  a = n / b;
  if (a != 0) {
    arg = printu(emit, arg, nchar, a, b, upperCase);
  }
  if (upperCase) {
    arg = emit(arg, "0123456789ABCDEF"[n % b]);
    (*nchar)++;
  } else {
    arg = emit(arg, "0123456789abcdef"[n % b]);
    (*nchar)++;
  }
  return arg;
}


/*
 * Output a number of filler characters.
 */
static void *fill(void *(*emit)(void *, char), void *arg,
                  int *nchar, int numFillers, char filler) {
  while (numFillers-- > 0) {
    arg = emit(arg, filler);
    (*nchar)++;
  }
  return arg;
}


/*
 * This function does the real work of formatted printing.
 */
static int doPrintf(void *(*emit)(void *, char), void *arg,
                    const char *fmt, va_list ap) {
  int nchar;
  char c;
  int n;
  long ln;
  unsigned int u;
  unsigned long lu;
  char *s;
  Bool negFlag;
  char filler;
  int width, count;

  nchar = 0;
  while (1) {
    while ((c = *fmt++) != '%') {
      if (c == '\0') {
        return nchar;
      }
      arg = emit(arg, c);
      nchar++;
    }
    c = *fmt++;
    if (c == '-') {
      negFlag = true;
      c = *fmt++;
    } else {
      negFlag = false;
    }
    if (c == '0') {
      filler = '0';
      c = *fmt++;
    } else {
      filler = ' ';
    }
    width = 0;
    while (c >= '0' && c <= '9') {
      width *= 10;
      width += c - '0';
      c = *fmt++;
    }
    if (c == 'd') {
      n = va_arg(ap, int);
      count = countPrintn(n);
      if (width > 0 && !negFlag) {
        arg = fill(emit, arg, &nchar, width - count, filler);
      }
      arg = printn(emit, arg, &nchar, n);
      if (width > 0 && negFlag) {
        arg = fill(emit, arg, &nchar, width - count, filler);
      }
    } else
    if (c == 'u' || c == 'o' || c == 'x' || c == 'X') {
      u = va_arg(ap, int);
      count = countPrintu(u,
                c == 'o' ? 8 : ((c == 'x' || c == 'X') ? 16 : 10));
      if (width > 0 && !negFlag) {
        arg = fill(emit, arg, &nchar, width - count, filler);
      }
      arg = printu(emit, arg, &nchar, u,
                   c == 'o' ? 8 : ((c == 'x' || c == 'X') ? 16 : 10),
                   c == 'X');
      if (width > 0 && negFlag) {
        arg = fill(emit, arg, &nchar, width - count, filler);
      }
    } else
    if (c == 'l') {
      c = *fmt++;
      if (c == 'd') {
        ln = va_arg(ap, long);
        count = countPrintn(ln);
        if (width > 0 && !negFlag) {
          arg = fill(emit, arg, &nchar, width - count, filler);
        }
        arg = printn(emit, arg, &nchar, ln);
        if (width > 0 && negFlag) {
          arg = fill(emit, arg, &nchar, width - count, filler);
        }
      } else
      if (c == 'u' || c == 'o' || c == 'x' || c == 'X') {
        lu = va_arg(ap, long);
        count = countPrintu(lu,
                  c == 'o' ? 8 : ((c == 'x' || c == 'X') ? 16 : 10));
        if (width > 0 && !negFlag) {
          arg = fill(emit, arg, &nchar, width - count, filler);
        }
        arg = printu(emit, arg, &nchar, lu,
                     c == 'o' ? 8 : ((c == 'x' || c == 'X') ? 16 : 10),
                     c == 'X');
        if (width > 0 && negFlag) {
          arg = fill(emit, arg, &nchar, width - count, filler);
        }
      } else {
        arg = emit(arg, 'l');
        nchar++;
        arg = emit(arg, c);
        nchar++;
      }
    } else
    if (c == 's') {
      s = va_arg(ap, char *);
      count = strlen(s);
      if (width > 0 && !negFlag) {
        arg = fill(emit, arg, &nchar, width - count, filler);
      }
      while ((c = *s++) != '\0') {
        arg = emit(arg, c);
        nchar++;
      }
      if (width > 0 && negFlag) {
        arg = fill(emit, arg, &nchar, width - count, filler);
      }
    } else
    if (c == 'c') {
      c = va_arg(ap, char);
      arg = emit(arg, c);
      nchar++;
    } else {
      arg = emit(arg, c);
      nchar++;
    }
  }
  /* never reached */
  return 0;
}


/*
 * Emit a character to the console.
 */
static void *emitToConsole(void *dummy, char c) {
  putchar(c);
  return dummy;
}


/*
 * Formatted output with a variable argument list.
 */
int vprintf(const char *fmt, va_list ap) {
  int n;

  n = doPrintf(emitToConsole, NULL, fmt, ap);
  return n;
}


/*
 * Formatted output.
 */
int printf(const char *fmt, ...) {
  int n;
  va_list ap;

  va_start(ap, fmt);
  n = vprintf(fmt, ap);
  va_end(ap);
  return n;
}


/*
 * Emit a character to a buffer.
 */
static void *emitToBuffer(void *bufptr, char c) {
  *(char *)bufptr = c;
  return (char *) bufptr + 1;
}


/*
 * Formatted output into a buffer with a variable argument list.
 */
int vsprintf(char *s, const char *fmt, va_list ap) {
  int n;

  n = doPrintf(emitToBuffer, s, fmt, ap);
  s[n] = '\0';
  return n;
}


/*
 * Formatted output into a buffer.
 */
int sprintf(char *s, const char *fmt, ...) {
  int n;
  va_list ap;

  va_start(ap, fmt);
  n = vsprintf(s, fmt, ap);
  va_end(ap);
  return n;
}
