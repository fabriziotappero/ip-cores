/^VCD/{ next; }
{
  a=strtonum("0x" $1);
  b=strtonum("0x" $3);
  c=strtonum("0x" $5);
  if (c != a + b)
    print $0;
}
