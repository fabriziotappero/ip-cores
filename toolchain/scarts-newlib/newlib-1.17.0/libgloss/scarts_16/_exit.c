int
_exit (int n)
{
  while (1)
    asm ("nop");
}
