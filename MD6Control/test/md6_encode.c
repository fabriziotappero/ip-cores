#include<stdlib.h>
#include<stdio.h>
#include<sys/stat.h>
#include<assert.h>
#include<endian.h>
#include"md6.h"
#include"encodeBits.h"


int main(int argc, char** argv) {
  struct stat buf;
  FILE *inFile;  
  long long bits;

  if(argc != 5) {
    printf("Wrong number of args\n");  
    exit(0);
  }

  inFile = fopen(argv[0],"rb");
  // Must determine intput bit length...
  assert(stat(argv[1],&buf) == 0);
  printf("File is %lld bytes\n",buf.st_size);


  printf("0: %s 1: %s\n",argv[0],argv[1]);
  md6_file(argv[1],argv[2],argv[3],argv[4],buf.st_size*8);   
}
