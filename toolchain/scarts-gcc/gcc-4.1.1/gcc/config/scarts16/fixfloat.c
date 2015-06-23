#define LINT_MIN (0x80000000)
#define LINT_MAXp1_F 0x1p32f
#define LINT_WIDTH 32

#define LLINT_MAXp1_F 0x1p64f

double __floatdidf (long long u);
float __floatdisf (long long u);
unsigned long __fixunssfsi (float a);
unsigned long __fixunsdfsi (double a);
long long __fixsfdi (float a);
long long __fixunssfdi (float a);
long long __fixdfdi (double a);
long long __fixunsdfdi (double a);

double __floatdidf (long long u)
{
  double d = (long)(u >> LINT_WIDTH);
  d *= LINT_MAXp1_F;
  d += (unsigned long) u;
  return d;
}

float __floatdisf (long long u)
{
  double d = (long)(u >> LINT_WIDTH);
  d *= LINT_MAXp1_F;
  d += (unsigned long) u;
  return (float) d;
}

unsigned long __fixunssfsi (float a)
{
  if (a >= (float) (unsigned long) LINT_MIN)
    return (long) (a - (unsigned long) LINT_MIN) + (unsigned long) LINT_MIN;
  return (long) a;
}

unsigned long __fixunsdfsi (double a)
{
  if ( a >= (double) (unsigned long) LINT_MIN )
    return (long) (a - (unsigned long) LINT_MIN) + (unsigned long) LINT_MIN;
  return (long) a;
}

long long __fixsfdi (float a)
{
  if (a < 0)
    return - __fixunssfdi (-a);
  return __fixunssfdi (a);
}

long long __fixunssfdi (float a)
{
  double d = a;
  unsigned long hi = d / LINT_MAXp1_F;
  unsigned long lo = d - (double) hi * LINT_MAXp1_F;
  return ((unsigned long long) hi << LINT_WIDTH) | lo;
}

long long __fixdfdi (double a)
{
  if (a < 0)
    return - __fixunsdfdi (-a);
  return __fixunsdfdi (a);
}

long long __fixunsdfdi (double a)
{
  unsigned long hi = a / LINT_MAXp1_F;
  unsigned long lo = a - (double) hi * LINT_MAXp1_F;
  return ((unsigned long long) hi << LINT_WIDTH) | lo;
}
