// test bitových operací - problem with NOT_OP (pBlazeIDE)

/* link the C libarary */

//#pragma library c

void main()
{
  volatile char c = 1;
  c = !c;
  c = 0;
  c = !c;
  c = c && c;
  c = c || c;
  c = 29;
  c = c % 13;
}
