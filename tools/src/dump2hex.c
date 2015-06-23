// Convert a dump file (passed on the stdin) into a hex
// file to be used to initialize the memory harness.

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define OFFSET 2

int main() {

  // Buffers
  char line[200];
  char* right;

  // Parse the standard input
  while(!feof(stdin)) {

    // Read one line
    fgets(line, 200, stdin);
    right = strchr(line, ':');
    if(right!=NULL) {
      printf("%c%c%c%c%c%c%c%c",
        right[OFFSET], right[OFFSET+1], right[OFFSET+3], right[OFFSET+4],
        right[OFFSET+6], right[OFFSET+7], right[OFFSET+9], right[OFFSET+10] );

      // Read another line
      fgets(line, 200, stdin);
      right = strchr(line, ':');
      if(right!=NULL)
        printf("%c%c%c%c%c%c%c%c\n",
          right[OFFSET], right[OFFSET+1], right[OFFSET+3], right[OFFSET+4],
          right[OFFSET+6], right[OFFSET+7], right[OFFSET+9], right[OFFSET+10] );
      else
        printf("01000000\n");
    }
  }
}

