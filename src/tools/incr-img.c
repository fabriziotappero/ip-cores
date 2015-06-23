#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  int  f1, f2, c1, c2;
  char err[50];
  unsigned char *buf1, *buf2;

  if (argc!=3)
    {
      sprintf(err, "Usage: %s hdnew.img hdref.img\n", argv[0]);
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

  buf1 = malloc(131072);
  if (!buf1)
    {
      sprintf(err, "Could not allocate 128kb of memory for the 1st buffer\n");
      write(2, &err, strlen(err));
      exit(1);
    }

  buf2 = malloc(131072);
  if (!buf2)
    {
      sprintf(err, "Could not allocate 128kb of memory for the 2nd buffer\n");
      write(2, &err, strlen(err));
      exit(1);
    }


    c1=read(f1, &buf1, 131072); // 128kb block
    c2=read(f2, &buf2, 131072);

    memcmp (buf1, buf2, 131072);

  return 0;
}