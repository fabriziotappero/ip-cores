unsigned long long __udivdi3(unsigned long long a, unsigned long long b)
{
  long long result;
  long long t;

  if (b == 0)
    return a;
  if (a == 0)
    return a;

  t = b;
  while ((long long)b > 0)
    b <<= 1;

  result = 0;
  while (b >= t)
    {
      result <<= 1;
      if (b <= a)
	{
	  a -= b;
	  result += 1;
	}
      b >>= 1;
    }

  return result;
}
