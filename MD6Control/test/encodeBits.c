#include<stdlib.h>
#include<stdio.h>
#include<sys/stat.h>
#include<assert.h>
#include<endian.h>
#include"encodeBits.h"
#include"md6.h"


const int requiredWordCount = 1<<20;



// reads the first bits bits out of the file 
void md6_file(char *filename, 
              char *outinput, 
              char *outresult,
              char *outsize,
               long long bits)

{
  FILE *inFile = fopen (filename, "rb");
  FILE *outInput = fopen (outinput, "wb"); 
  FILE *outResult = fopen (outresult, "wb");
  FILE *outSize = fopen (outsize, "wb"); 
  md6_state st;
  uint64_t bytes;
  long long bitCounter = bits;
  unsigned char data[1024];
  int err,i,j,wordCount=0;
  long long bitMin;

  md6_word key[md6_k];

  printf("Bits: %d\n", bits);

  for(i=0;i<md6_k;i++) {
    key[i]=0;
  }
  
  if (inFile == NULL) {
    printf ("%s can't be opened.\n", filename);
  }
  

  // Use this instead!
  //  md6_full_init(st,d,NULL,0,md6_default_L,md6_default_r)
  // It is legit to have fewer bytes in the key - should add this option to the HW.
  // Perhaps may want to make 512 a parameter to this function
  if (err=md6_full_init(&st,512,(char*)key,md6_k*8,md6_default_L,md6_default_r(512))) {
      printf("Error code: %d\n",err);
  }

  wordCount = 0;
  while ((bytes = fread (data, 1, md6_w/8, inFile)) != 0){
    char wordBuf[md6_w/8];
    int i;


    //Only swap if this word is full. otherwise, we'll screw up the
    //last byte
    for( i = 0; i < md6_w/8; i++) {
      /*  if((BYTE_ORDER == LITTLE_ENDIAN) && (bitCounter >= md6_w)) {
          wordBuf[i] = data[md6_w/8-i-1];
        }
        else{*/
          wordBuf[i] = data[i];
     }
	
    

    // md6_update border case uses wrong endianess
    // we may cross a bit boundary here.  In this case we want min of 
    // bitCounter/bytes*8
    bitMin = (bitCounter<bytes*8)?bitCounter:bytes*8;
    if ((err=md6_update(&st, wordBuf, bitMin))) {
      printf("Error code: %d\n",err);
    }
    wordCount++;
    bitCounter -= bitMin; 
    if((bytes != md6_w/8) || (bitCounter <= 0)) {
      break;
    }
  }
  // swap the last guy specially
  //XXX assert something about bitCounter here
  printf("bytes: %d, bits: %d, bitCounter: %d", bytes, bits, bitCounter);
  assert(bitCounter == 0);


  if ((err=md6_final(&st,NULL))) {
      printf("Error code: %d\n",err);
  } else {
    printf("\nCalled md6_final\n");
  }

  //Wind back
  rewind(inFile);
  
  for(i=0;i<md6_n;i++) {
    data[i]=0;
  }

  wordCount = 0;
  while ((bytes = fread (data, 1,md6_w/8, inFile))){
    char wordBuf[md6_w/8];        
    int i;
   
    // Bluespec is big endian
    // Really we should make the C code also big endian.
    // This has to do with zero padding in the controller.  
    // If we fail to feed the right values, we'll basically die.
    for( i = 0; i < md6_w/8; i++) {
      if(BYTE_ORDER == LITTLE_ENDIAN) {
        wordBuf[i] = data[md6_w/8-i-1];
      }
      else{
        wordBuf[i] = data[i];
      }
    }


    fprintf(outInput,PR_MD6_WORD "\n", *((md6_word*)wordBuf));       
    printf("Got %d bytes\n", bytes);
    wordCount+=bytes;
    if(bytes < (md6_w/8)) {
      break;
    }
    for(i=0;i<md6_n;i++) {
      data[i]=0;
    }
  }

  fprintf(outSize,"%x\n%x\n%x\n%x\n",bits,bits,bits,bits);

  for(; wordCount < requiredWordCount; wordCount++) {
    fprintf(outInput,PR_MD6_WORD "\n", 0);       
  }

  printf("Hashval: %s\n", st.hexhashval);
  for (j = 0;j<md6_c;j++) {
    char wordBuf[md6_w/8];
    int i;

    // Bluespec is big endian
    // XXX this code is not deployed
    for( i = 0; i < md6_w/8; i++) {
      if(BYTE_ORDER != BIG_ENDIAN) {
        wordBuf[i] = st.hashval[j*md6_w/8+(md6_w/8-i-1)];
      }
      else{
        wordBuf[i] = st.hashval[j*md6_w/8+i];
      }
    }

    fprintf(outResult,PR_MD6_WORD "\n",*((md6_word*)wordBuf));
  }

  fclose (inFile);
  fclose (outInput);
  fclose (outResult);
  fclose (outSize);
}


