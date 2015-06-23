int main()
{
  int i = 0;
  int j = 13;
zkouska:
  i += 2;
  j -= i;
  i |= j;
  goto zkouska;
  return i*j;
}