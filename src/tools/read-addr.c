#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

int main (int argc, char *argv[])
{
  int fd, n;
  char buf[4096];
  char *p, *q;
  char s1[6], s2[6];

  if (argc != 2) fprintf(stderr, "Syntax: %s tracefile\n",
                         argv[0]);

  fd=open(argv[1], O_RDONLY);
  if(fd < 0)
    {
      fprintf(stderr, "Error opening file\n");
      return 1;
    }

  strcpy (s1, "");
  strcpy (s2, "");

  while (1)
    {
      n=read(fd, &buf, 4096);
      if (n<11) break;

      p=buf;
      q=&buf[n-11];
      while (1)
        {
          if (p = strstr(p, "[0x"))
            {
              // String found
              if (p > q) break;
              p+=6;
              strncpy (s2, p, 5);
              if (strcmp (s1, s2))
                {
                  // They are different
                  printf ("%s\n", s2);
                  strcpy (s1, s2);
                }
            }
          else break;
        }

      if (p > q) lseek(fd, (off_t) -10, SEEK_CUR);
      if (buf[n-1]=='[') lseek(fd, (off_t) -1, SEEK_CUR);
      else if (buf[n-2]=='[' && buf[n-1]=='0')
        lseek(fd, (off_t) -2, SEEK_CUR);
    }

  return 0;
}