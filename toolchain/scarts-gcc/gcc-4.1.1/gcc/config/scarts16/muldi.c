long long __muldi3(long long a, long long b)
{
  long long result = 0;

  while (a != 0)
    {
      if (a & 1)
	{
	  result += b;
	}
      a = (unsigned long long)a >> 1;
      b <<= 1;
    }

  return result;
}
