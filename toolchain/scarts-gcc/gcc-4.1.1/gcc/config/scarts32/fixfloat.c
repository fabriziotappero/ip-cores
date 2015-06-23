#define INT_MIN (0x80000000)
#define INT_MAXp1_F 0x1p32f
#define INT_WIDTH 32

#define LLINT_MAXp1_F 0x1p64f

double __floatdidf (long long u);
float __floatdisf (long long u);
unsigned int __fixunssfsi (float a);
unsigned int __fixunsdfsi (double a);
long long __fixsfdi (float a);
long long __fixunssfdi (float a);
long long __fixdfdi (double a);
long long __fixunsdfdi (double a);

double __floatdidf (long long u)
{
  double d = (int)(u >> INT_WIDTH);
  d *= INT_MAXp1_F;
  d += (unsigned int) u;
  return d;
}

float __floatdisf (long long u)
{
  double d = (int)(u >> INT_WIDTH);
  d *= INT_MAXp1_F;
  d += (unsigned int) u;
  return (float) d;
}

unsigned int __fixunssfsi (float a)
{
  if (a >= (float) (unsigned int) INT_MIN)
    return (int) (a - (unsigned int) INT_MIN) + (unsigned int) INT_MIN;
  return (int) a;
}

unsigned int __fixunsdfsi (double a)
{
  if ( a >= (double) (unsigned int) INT_MIN )
    return (int) (a - (unsigned int) INT_MIN) + (unsigned int) INT_MIN;
  return (int) a;
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
  unsigned int hi = d / INT_MAXp1_F;
  unsigned long lo = d - (double) hi * INT_MAXp1_F;
  return ((unsigned long long) hi << INT_WIDTH) | lo;
}

long long __fixdfdi (double a)
{
  if (a < 0)
    return - __fixunsdfdi (-a);
  return __fixunsdfdi (a);
}

long long __fixunsdfdi (double a)
{
  unsigned int hi = a / INT_MAXp1_F;
  unsigned int lo = a - (double) hi * INT_MAXp1_F;
  return ((unsigned long long) hi << INT_WIDTH) | lo;
}
