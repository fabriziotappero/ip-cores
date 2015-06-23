//---------------------------------------------------------------------------
#include <stdio.h>
#include <io.h>
#pragma hdrstop

//---------------------------------------------------------------------------


#pragma argsused
int main(int argc, char* argv[])
{
   FILE *fs,*fd;
   char line[200];
   int l = 0;

   if (argc != 3)
   {
      printf("Filtre de fichiers texte\n");
      printf("Syntaxe:\n");
      printf("FILTER File1 File2\n");
      printf("\tFile1 = Fichier source\n");
      printf("\tFile2 = Fichier destination\n");
      return 0;
   }

   fs = fopen(argv[1], "rt");
   if (fs == NULL)
   {
      printf("Impossible d'ouvrir %s\n", argv[1]);
      return 0;
   }

   fd = fopen(argv[2], "wt");
   if (fd == NULL)
   {
      printf("Impossible d'ouvrir %s\n", argv[2]);
      fclose(fs);
      return 0;
   }

   while(fgets(line, 200, fs) != NULL)
   {
      l++;
      if (l <= 1 || l > 6)fprintf(fd, "%s", line);
   }

   fclose(fs);
   fclose(fd);
}
//---------------------------------------------------------------------------
