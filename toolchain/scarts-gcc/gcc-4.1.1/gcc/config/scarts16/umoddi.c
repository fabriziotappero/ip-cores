unsigned long long __umoddi3(unsigned long long a, unsigned long long b)
{
  long long t;

  if (b == 0)
    return a;
  if (a == 0)
    return a;

  t = b;
  while ((long long)b > 0)
    b <<= 1;

  while (b >= t)
    {
      if (b <= a)
	a -= b;
      b >>= 1;
    }

  return a;
}
