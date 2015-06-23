#include<stdlib.h>
#include<stdio.h>
#include"md6.h"


#define COMPRESS_ROUNDS 178
#define HASH_LENGTH md6_c
#define PLAIN_LENGTH md6_b 
#define CONTROL_LENGTH md6_u
#define IDENTIFIER_LENGTH md6_v
#define KEY_LENGTH md6_k
#define Q_LENGTH md6_q

void writePlaintextValue(md6_word value, long long index);
void writeControlValue(md6_word value, long long index);
void writeUniqueValue(md6_word value, long long index);
void writeKeyValue(md6_word value, long long index);
void writeQValue(md6_word value, long long index);
void executeDecode();
md6_word readHash(long long index);
void testSanityCheck(long long md6_w_val, long long md6_n_val, long long md6_c_val, 
                     long long md6_b_val, long long md6_v_val, long long md6_u_val,
                     long long md6_k_val, long long md6_q_val, long long md6_r_val,
                     long long md6_t0, long long md6_t1, long long md6_t2,
                     long long md6_t3, long long md6_t4);


md6_word plaintextArray[PLAIN_LENGTH+CONTROL_LENGTH+IDENTIFIER_LENGTH+KEY_LENGTH+Q_LENGTH];
md6_word hashArray[HASH_LENGTH];

void writePlaintextValue(md6_word value, long long index) {
  printf("Writing[%d]: %llx\n", CONTROL_LENGTH+IDENTIFIER_LENGTH+KEY_LENGTH+Q_LENGTH+(md6_b-index-1), value);
  plaintextArray[CONTROL_LENGTH+IDENTIFIER_LENGTH+KEY_LENGTH+Q_LENGTH+(md6_b-index-1)] = value;
}

void writeControlValue(md6_word value, long long index)  {
  plaintextArray[index+IDENTIFIER_LENGTH+KEY_LENGTH+Q_LENGTH] = value;
}

void writeUniqueValue(md6_word value, long long index) {
  plaintextArray[index+KEY_LENGTH+Q_LENGTH] = value;
}

void writeKeyValue(md6_word value, long long index) {
  plaintextArray[index+Q_LENGTH] = value;
}

void writeQValue(md6_word value, long long index) {
  plaintextArray[index] = value;
}


void executeDecode() {
  md6_word plaintextArrayRev[PLAIN_LENGTH+CONTROL_LENGTH+IDENTIFIER_LENGTH+KEY_LENGTH+Q_LENGTH];
  int i;

  printf("Calling executeDecode() Size - %d\n", md6_w);

  // It so happens that md6_compress expect the array in reverse order for some reason...  

  //for(i = 0; i  < md6_n; i++){
  //  plaintextArrayRev[md6_n - i - 1] = plaintextArray[i];
  //}

  int result = md6_compress( hashArray,
		             plaintextArray,
		             COMPRESS_ROUNDS,
		             NULL
			   );
  if(result != MD6_SUCCESS) {  
    printf("MD6 failed: %d, dying!\n", result);
    exit(0);
  }
}

md6_word readHash(long long index) {
  printf("index is : %d\n", index);
  return hashArray[md6_c-index-1];
}

void testSanityCheck(long long md6_w_val, long long md6_n_val, long long md6_c_val, 
                     long long md6_b_val, long long md6_v_val, long long md6_u_val,
                     long long md6_k_val, long long md6_q_val, long long md6_r_val,
                     long long md6_t0, long long md6_t1, long long md6_t2,
                     long long md6_t3, long long md6_t4){

  if(md6_w_val != md6_w) {
    printf("md6_w does not match: %d, %d!\n", md6_w_val, md6_w);
    exit(0);
  }

  if(md6_n_val != md6_n) {
    printf("md6_h does not match!\n");
    exit(0);
  }

  if(md6_c_val != md6_c) {
    printf("md6_c does not match!\n");
    exit(0);
  }

  if(md6_b_val != md6_b) {
    printf("md6_b does not match!\n");
    exit(0);
  }

  if(md6_v_val != md6_v) {
    printf("md6_v does not match!\n");
    exit(0);
  }

  if(md6_u_val != md6_u) {
    printf("md6_u does not match!\n");
    exit(0);
  }

  if(md6_k_val != md6_k) {
    printf("md6_k does not match!\n");
    exit(0);
  }

  if(md6_q_val != md6_q) {
    printf("md6_q does not match!\n");
    exit(0);
  }

  if(md6_r_val != 178) {
    printf("md6_r does not match!\n");
    exit(0);
  }

  if(md6_t0 == t0) {
    printf("md6_t0 does not match!\n");
    exit(0);
  }

  if(md6_t1 == t1) {
    printf("md6_t1 does not match!\n");
    exit(0);
  }

  if(md6_t2 == t2) {
    printf("md6_t2 does not match!\n");
    exit(0);
  }

  if(md6_t3 == t3) {
    printf("md6_t3 does not match!\n");
    exit(0);
  }

  if(md6_t4 == t4) {
    printf("md6_t4 does not match!\n");
    exit(0);
  }
}



