unsigned long long __divdi3(unsigned long long a, unsigned long long b)
{
  long long result;
  long long t;
  int sign;

  if (b == 0)
    return a;
  if (a == 0)
    return a;

  sign = (a ^ b) >> 48;

  if (a < 0)
    a = -a;
  if (b < 0)
    b = -b;

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

  if (sign < 0)
    result = -result;

  return result;
}
