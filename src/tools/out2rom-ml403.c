#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  char buf1[2];
  char buf2[2];
  int  f1, f2, c1, c2;
  char err[50];

  if (argc!=3)
    {
      sprintf(err, "Usage: %s hd.img bios.img\n", argv[0]);
      write(2, &err, strlen(err));
      exit(1);
    }

  f1 = open (argv[1], O_RDONLY);
  if (f1<0)
    {
      sprintf(err, "Could not open file %s\n", argv[1]);
      write(2, &err, strlen(err));
      exit(1);
    }

  f2 = open (argv[2], O_RDONLY);
  if (f2<0)
    {
      sprintf(err, "Could not open file %s\n", argv[2]);
      write(2, &err, strlen(err));
      exit(1);
    }

  while (1)
  {
    c1=read(f1, &buf1, 2);
    c2=read(f2, &buf2, 2);

    if (c1<2 && c2<2) break;
    else
      {
        if (c1<2) { buf1[0] =  0xff; buf1[1] = 0xff; }
        if (c2<2) { buf2[0] =  0xff; buf2[1] = 0xff; }
      }

    write (1, &buf1[1], 1);
    write (1, &buf1[0], 1);
    write (1, &buf2[1], 1);
    write (1, &buf2[0], 1);
  }

  close(f1);
  close(f2);

  return 0;
}

