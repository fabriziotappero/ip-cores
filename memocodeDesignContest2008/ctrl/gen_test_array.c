/*
Copyright (c) 2008 MIT

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Author: Kermin Fleming
*/
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include "aes_core.h"
#include "recordio.h"



const unsigned char globalkey[] = {0xB0, 0x1D, 0xFA, 0xCE, 
                                   0x0D, 0xEC, 0x0D, 0xED, 
                                   0x0B, 0xA1, 0x1A, 0xDE, 
                                   0x0E, 0xFF, 0xEC, 0x70};

int main() {
  long long start, stop;
  int i;
  FILE *sorted, *unsorted;
  assert(sorted = fopen("sorted.hex","w"));
  assert(unsorted = fopen("unsorted.hex","w"));

  printf("Initializing database\n");
  initializedb(globalkey);  


  printf("Sorting starts\n");
  //showdb();
  for(i = 0; i < MAXRECORD; i+=1) {
    fprintf(unsorted,"%08x%08x%08x%08x\n", db[i].f1,  db[i].f2, db[i].f3,  db[i].f4  );     
  }

  sortrecord();
  //  showdb();
  for(i = 0; i < MAXRECORD; i+=1) {
    fprintf(sorted,"%08x%08x%08x%08x\n",db[i].f1,  db[i].f2, db[i].f3,  db[i].f4 );     
  }
   
  
  printf("Verifying results .. (correct = 1): ");
  printf("%x\n", verifydb());
  
  return 0;
}

 
