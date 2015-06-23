/* Small utility that makes flash image. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "../mad-xess/fsyst.h"

unsigned int swap (unsigned int x) {
  return (x & 0xFF) << 24
    | (x & 0xFF00) << 8
    | (x & 0xFF0000) >> 8
    | (x & 0xFF000000) >> 24;
}

/* Copies data from fi to fo. Returns nonzero
   if error. */
int copy_into (FILE *fo, FILE *fi)
{
  char buf[8192];
  int bread;
  do
    {
      bread = fread (&buf, 1, sizeof(buf), fi);
      if (bread != fwrite (&buf, 1, bread, fo))
	return 1;
    } while (bread == sizeof(buf));
  return 0;
}

/* Writes file to fo and returns error.  */
int write_file (FILE *fo, struct file_struct *file)
{
  unsigned int u;
  int ok = 0;
  u = swap(file->length);
  printf("%08x:%08x\n", file->length, u);
  if (fwrite(&u, sizeof(unsigned long), 1, fo))
    ok = 1;
  u = swap(file->type);
  if (fwrite(&u, sizeof(unsigned long), 1, fo) && ok)
    return 0;
  fprintf (stderr, "Cannot write to file.\n");
  return 1;
}

int main(int argc, char *argv[])
{
  int i;
  FILE *fo;
  struct file_struct file;
  
  if (argc <= 1)
    {
      printf ("Usage: loader image_file.mfs [file.mp3 [...]]\n");
      return 1;
    }
  
  if ((fo = fopen (argv[1], "wb+")) == NULL)
    {
      fprintf (stderr, "Cannot open output file '%s'\n", argv[1]);
      return 2;
    }

  file.type = FT_ROOT;
  file.length = HEADER_SIZE;
  if (write_file (fo, &file))
    return 3;

  for (i = 2; i < argc; i++)
    {
      FILE *fi = fopen (argv[i], "rb");
      struct stat fi_stat;
      int align;
      if (!fi)
	{
	  fprintf (stderr, "Cannot open input file '%s'\n", argv[i]);
	  return 1;
	}
      stat (argv[i], &fi_stat);
      printf ("Track %i: %s (size %i)\n", i - 1, argv[i], (int)fi_stat.st_size);

      file.type = FT_TRACK_NO;
      file.length = HEADER_SIZE + sizeof (unsigned int);
      file.data[0] = swap(i - 1);
      if (write_file (fo, &file))
	return 3;
      if (!fwrite (&file.data[0], sizeof (unsigned int), 1, fo))
	{
	  fprintf (stderr, "Cannot write to file.\n");
	  return 3;
	}

      file.type = FT_TRACK_NAME;
      align = (4 - ((strlen (argv[i]) + 1) & 3)) & 3;
      file.length = HEADER_SIZE + strlen (argv[i]) + 1 + align;
      if (write_file (fo, &file))
	return 3;
      if (!fwrite (argv[i], strlen (argv[i]) + 1 + align, 1, fo))
	{
	  fprintf (stderr, "Cannot write to file.\n");
	  return 3;
	}

      file.type = FT_TRACK_DATA;
      align = (4 - (fi_stat.st_size & 3)) & 3;
      file.length = HEADER_SIZE + fi_stat.st_size + align;
      if (write_file (fo, &file))
	return 3;
      copy_into(fo, fi);
      fwrite (&align, 1, align, fo);
      fclose (fi);
    }
  file.type = FT_END;
  file.length = 0;
  if (write_file (fo, &file))
    return 3;
  printf ("Done.\n");
  fclose (fo);
  return 0;
}
