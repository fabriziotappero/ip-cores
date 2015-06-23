#include <stdio.h>
#include <string.h>

main(int argc, char *argv[])
{
 FILE *f;
 char *fname = "key.lst";
 int c,i;
 char key[60][20];

 if (argc > 1) {
 fname = argv[1]; /*
 i = 1;
 printf("%3d ", argc);
 while (i < argc) { 
  printf ("-- %s ", argv[i]); 
  i++;
 }
 printf("\n"); */
 }

if(fname && (f = fopen(fname, "rt"))) {
  i = 0;
  while(fgets(key[i],sizeof(key[i]),f) != NULL) {
    c = strlen(key[i]);
    if(key[i][c-1] == '\n') key[i][c-1] = '\0';
    i++;
  }
  fclose (f);
} else {
  fclose (f);
}
/*
 if (fname && (f = fopen ( fname, "rt"))) {
	printf ("Success opening %s, ", fname);
 } else { 
	fclose (f);
 }

 i = 0;
 while(fgets(key[i],sizeof(key[i]),f) != NULL){
  c = strlen(key[i]);
  if(key[i][c-1] == '\n') key[i][c-1] = '\0';
  i++; 
 }
 printf("got %3d lines\n", i);
*/
 for (c = 0; c<i; c++) printf("%3d -- %s\n", c, key[c]);

 fclose (f);
}
