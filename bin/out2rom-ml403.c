int main()
{
  char buf[2];
  char buf2[2] = { 0xff, 0xff };
  while (read(0, &buf, 2)==2)
    {
      write(1, &buf2, 2);
      write(1, &buf[1], 1);
      write(1, &buf[0], 1);
    }
  return 0;
}

