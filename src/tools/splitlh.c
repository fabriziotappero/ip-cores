#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
  int fd, count, out0, out1;
  char word[2];

  if (argc != 4) fprintf(stderr, "Syntax: %s infile evenfile oddfile\n", 
                         argv[0]);
 
  fd=open(argv[1], O_RDONLY);
  if(fd < 0) 
    {
      fprintf(stderr, "Error opening file\n");
      return 1;
    }

  out0 = open (argv[2], O_WRONLY|O_CREAT|O_TRUNC, 
               S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
  if(out0 < 0) 
    {
      fprintf(stderr, "Error creating even file\n");
      return 2;
    }

  out1 = open (argv[3], O_WRONLY|O_CREAT|O_TRUNC, 
               S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
  if(out1 < 0) 
    {
      fprintf(stderr, "Error creating odd file\n");
      return 3;
    }

  do {
    count = read(fd, word, 2);
    if (count > 0) write(out0, &word[0], 1);
    if (count > 1) write(out1, &word[1], 1);
  } while (count > 0);

  close (fd);
  close (out0);
  close (out1);
 
  return 0;
}
