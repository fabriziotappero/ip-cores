#include <stdio.h>
#include <string.h>

main(int argc, char *argv[])
{
 FILE *f;
 char *fname = "fm.txt";
 int c,i;
 char dmout[5000][20];

 if (argc > 1) {
 fname = argv[1];
 }

if(fname && (f = fopen(fname, "rt"))) {
  i = 0;
  while(fgets(dmout[i],sizeof(dmout[i]),f) != NULL) {
    c = strlen(dmout[i]);
    if(dmout[i][c-1] == '\n') dmout[i][c-1] = '\0';
    i++;
  }
  fclose (f);
} else {
  fclose (f);
}

 for (c = 0; c < i; c++) { 
	 printf("#%d\n", c); /* time */
	 printf("%s\n", dmout[c]);
	 printf("b%d %%\n", c%2); /* clock */
 }

 fclose (f);
}
