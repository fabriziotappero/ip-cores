int main(int argc, char *argv[])
{
  int f = -1;
  int i, top;

  if (argc==2) top=atoi (argv[1]);
  else top = 1000000;

  for (i=0; i<top; i++)
    write (1, &f, 4);

  return 0;
}
