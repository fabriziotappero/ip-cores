/* File:    md6_test.c
** Author:  Ronald L. Rivest
** Address: Room 32G-692 Stata Center 
**          32 Vassar Street 
**          Cambridge, MA 02139
** Email:   rivest@mit.edu
** Date:    9/25/2008
**
** (The following license is known as "The MIT License")
** 
** Copyright (c) 2008 Ronald L. Rivest
** 
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is
** furnished to do so, subject to the following conditions:
** 
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
** 
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
** THE SOFTWARE.
**
** (end of license)
**
** This file illustrates the use of the MD6 hash function.
** The files defining the md6 hash function are:
**    md6.h
**    md6_compress.c
**    md6_mode.c
**
** The files defining the interface between MD6 and the NIST SHA-3
** API are:
**    md6_nist.h
**    md6_nist.c
** The NIST SHA-3 API is defined in:
**    http://www.csrc.nist.gov/groups/ST/hash/documents/SHA3-C-API.pdf
**
** See  http://groups.csail.mit.edu/cis/md6  for more information.
**
** Utility and test routines for working with md6:
**   md6_print_state       -- prints out "md6_state" data structure
**   md6_string            -- computes hash of a given input string
**   md6_file              -- computes hash of a given file
**   md6_test_1            -- simple test suite
**   md6_test_2            -- time trial
**   md6_test_3            -- writes out intermediate results to a file
**   main                  -- calls tests 1,2,3
*/

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "md6.h"

#define w  md6_w
#define c  md6_c
#define n  md6_n
#define b  md6_b
#define u  md6_u
#define v  md6_v
#define k  md6_k
#define q  md6_q

/* Useful macros: min and max */
#ifndef min
#define min(a,b) ((a)<(b)? (a) : (b))
#endif
#ifndef max
#define max(a,b) ((a)>(b)? (a) : (b))
#endif

 /* Print state.
*/

void md6_print_state(md6_state* st)
/*
** print out an md6_state in a nice way.
*/
{
  int i,j;
  printf("\nPrintout of md6_state:\n");
  printf(" initialized = %d\n",st->initialized);
  printf(" finalized =   %d\n",st->finalized);
  printf(" hashbitlen =    %d\n",st->hashbitlen);
  printf(" Key:\n");
  for (i=0;i<k;i++)
    printf("  %4d " PR_MD6_WORD "\n",i,(md6_word)(st->K[i]));
  printf(" L =                %d\n",st->L);
  printf(" r =                %d\n",st->r);
  printf(" Bits processed =   %lld\n",(uint64_t)st->bits_processed);
  printf(" Stack top =        %d\n",st->top);
  printf(" N:\n");
  for (j = 0;j<b;j++)
    { for (i = 1;i<=st->top;i++)
	printf("%4d %4d " PR_MD6_WORD,i,j,(md6_word)st->B[i][j]);
      printf("\n");
    }
  printf(" Bits on each level:\n");
  for (i=0;i<=st->top;i++)
    printf("  Level %2d: %2d\n",i,st->bits[i]);
  printf(" Hash Value:\n");
  for (i=0;i<c;i++)
    { 
      if (i%32 == 0) printf("  ");
      printf("%02x",st->hashval[i]);
      if (i%8==7) printf(" ");
      if (i%32==31) printf("\n");
    }
  printf(" Hex Hash Value:\n");
  printf("  %s\n",st->hexhashval);
  printf("End of md6_state printout.\n\n");
}


void md6_print_hash(md6_state *st)
/*
** print out the hash value stored in the md6 state
*/
{ 
  printf("%s",st->hexhashval);
}


void md6_string(unsigned char *M,
		int rep,
		unsigned char *key,
		int d) 
/*
** Compute the md6 hash of a zero-terminated input byte string M
** repeated rep times.  Print this hash value out with a trailing space
** and carriage return.
** Input:
**   M      input array of length m bytes
**   rep    number of times to repeat M
**   key    input zero-terminated key string
**   d      desired output hash size, in bits 1 <= d <= (c*w/2) 
**          (c*w/2 = 512 bits)
*/
{
  md6_state st;
  uint64_t m;
  int i, keylen;
  int err;

  m = strlen((char *)M);
  keylen = (int)strlen((char *)key);

  /* check that input values are sensible */
  assert(( M != NULL ));
  assert(( (key == NULL) || ( (0<=keylen) && (keylen <= k*(w/8))) ) );
  assert(( (1 <= d) && (d <= c*w/2) ));

  /* printf("md6_string..."); */

  if ((err=md6_full_init(&st,d,key,keylen,md6_default_L,md6_default_r(d))))
      printf("Error code: %d\n",err);
  for (i=0;i<rep;i++)
    if ((err = md6_update(&st,M,8*(uint64_t)m)))
      printf("Error code: %d\n",err);
  if ((err = md6_final(&st,NULL)))
      printf("Error code: %d\n",err);
  md6_print_hash(&st);
  printf(" \"%s\"",M);
  if (rep>1) printf(" * %d",rep);
  printf("\n");
}


static void md6_file(char *filename)
/*
** compute and print out hash value for a file with given filename.
*/
{
  FILE *inFile = fopen (filename, "rb");
  md6_state st;
  uint64_t bytes;
  unsigned char data[1024];
  int err;

  if (inFile == NULL) {
    printf ("%s can't be opened.\n", filename);
    return;
  }

  if ((err=md6_init(&st,256)))
      printf("Error code: %d\n",err);
  while ((bytes = fread (data, 1, 1024, inFile)) != 0)
    if ((err=md6_update(&st, data, bytes*8)))
      printf("Error code: %d\n",err);
  if ((err=md6_final(&st,NULL)))
      printf("Error code: %d\n",err);
  md6_print_hash(&st);
  printf (" file: %s\n", filename);
  fclose (inFile);
}


void md6_test_1(void)
/*
** run a simple set of test values
*/
{ unsigned char *key;
  int d;

  printf("------------------------------------------------------------\n");
  printf("md6_test_1: start. [simple test suite]\n");
  printf(">> string * n means string repeated n times.\n\n");

  key = (unsigned char *)"";   /* yields all-zero key */
  d = min(256,c*w/2);
  printf(">> Key is all zeros.\n");
  printf(">> Hash Bit Length is %d bits.\n",d);
  md6_string((unsigned char *)"",1,key,d);        
  md6_string((unsigned char *)"a",1,key,d);
  md6_string((unsigned char *)"abc",1,key,d);
  md6_string((unsigned char *)"abcdefghijklmnopqrstuvwxyz",1,key,d);
  md6_string((unsigned char *)"1234567890",1000000,key,d);
  printf("\n");

  key = (unsigned char *)"abcd1234";
  d = min(256,c*w/2);
  printf(">> Key is '%s'.\n",key);
  printf(">> Hash Bit Length is %d bits.\n",d);
  md6_string((unsigned char *)"",1,key,d);
  md6_string((unsigned char *)"a",1,key,d);
  md6_string((unsigned char *)"abc",1,key,d);
  md6_string((unsigned char *)"abcdefghijklmnopqrstuvwxyz",1,key,d);
  md6_string((unsigned char *)"1234567890",1000000,key,d);
  printf("\n");

  key = (unsigned char *)"";   /* yields all-zero key */
  d = min(160,c*w/2);
  printf(">> Key is all zeros.\n");
  printf(">> Hash Bit Length is %d bits.\n",d);
  md6_string((unsigned char *)"",1,key,d);          
  md6_string((unsigned char *)"a",1,key,d);
  md6_string((unsigned char *)"abc",1,key,d);
  md6_string((unsigned char *)"abcdefghijklmnopqrstuvwxyz",1,key,d);
  md6_string((unsigned char *)"1234567890",1000000,key,d); 
  printf("\n");

  printf("md6_test_1: end.\n\n");
}


/*
** rdtsc()
** returns CPU cycle counter using RDTSC intruction
** see http://en.wikipedia.org/wiki/RDTSC
** GNU Version -- see wikipedia for Microsoft Visual C++ version
** following routine is copied from Wikipedia page referenced above
* UNTESTED SO FAR... 
*/
#if 0
extern "C" {
  __inline__ uint64_t rdtsc() {
    uint32_t lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    /* we cannot use "=A" since this would use %rax on x86_64 */
    return (uint64_t)hi << 32 | lo;
  }
}
#endif



void md6_test_2(void)
/*
** run a simple time trial
*/
#define TEST_BLOCK_SIZE 100000                    /*     10**5 bytes*/
#define TEST_BLOCKS 1000                          /*     10**3 */
#define TEST_BYTES (TEST_BLOCKS*TEST_BLOCK_SIZE)  /*     10**9 bytes */
{ md6_state st;
  double endTime, startTime;
  unsigned char data[TEST_BLOCK_SIZE];
  unsigned long long int i;
  unsigned int dvals[] = {160,224,256,384,512};
  int ndvals = 5;
  int err;
  md6_word A[md6_max_r*c+n];    
  int j;
  int d;

  printf("------------------------------------------------------------\n");
  printf("md6_test_2: start. [time trial]\n");
  printf(">> Key is all zeros.\n");
  printf ("Processing %lld characters...\n", (long long)TEST_BYTES);

  /* initialize test data */
  for (i = 0; i < TEST_BLOCK_SIZE; i++)
    data[i] = (unsigned char)(i & 0xFF);

  for (j=0;j<ndvals;j++)
    { d = dvals[j];
      printf("\nd = %d (hash bit length)\n",d);
      /* start timer */
      startTime = ((double)clock())/CLOCKS_PER_SEC;

      /* Process data in TEST_BLOCK_SIZE byte blocks */
      err = md6_init(&st,d);
      if (err) printf("Error code: %d\n",err);
      for (i = TEST_BLOCKS; i > 0; i--)
	if ((err=md6_update (&st, data, 8*TEST_BLOCK_SIZE)))
	  printf("Error code %d\n",err);
      if ((err = md6_final(&st,NULL)))
	printf("Error code: %d\n",err);

      endTime = ((double)clock())/CLOCKS_PER_SEC;
      md6_print_hash(&st);printf (" is hash of test input.\n");
      printf
	("time to process test input: %.3f seconds.\n", (endTime-startTime));
      if (endTime>startTime)
	printf
	  ("md6 bytes per second: %f\n", TEST_BYTES/(endTime-startTime));
      printf("md6 time per compression function (512 bytes) = %g microseconds.\n",
	     (((endTime-startTime))*1.0e6 / (4.0*TEST_BYTES/(3.0*512.0))));
      /* there are 4/3 as many c.f. operations as bytes/512, due to tree */

      /* Now look at time just to do that many compression operations. */
      printf("Now computing time for just the compression function portions...\n");
      md6_init(&st,d);
      startTime = ((double)clock())/CLOCKS_PER_SEC;
      for (i=0;i<(long long)TEST_BYTES*4/(3*b*(w/8));i++)
	md6_main_compression_loop(A,md6_default_r(d));
      endTime = ((double)clock())/CLOCKS_PER_SEC;
      printf
	("time to process test input: %.3f seconds.\n", (endTime-startTime));
      if (endTime>startTime)
	printf("md6 bytes per second: %g\n", TEST_BYTES/(endTime-startTime));
      printf("md6 time per compression function (512 bytes) = %g microseconds.\n",
	     (((endTime-startTime))*1.0e6 / (4.0*TEST_BYTES/(3.0*512.0))));
    } /* end of loop on j for different d's */
  
  printf("md6_test_2: end.\n\n");
}

 /* testing and debugging */

/* Global variables used by compression_hook_1 */
FILE *outFile;
int  hook_print_intermediate_values;

void compression_hook_1(md6_word *C,
			const md6_word *Q,
			md6_word *K,
			int ell,
			int ii,
			int r,
			int L,
			int z,
			int p,
			int keylen,
			int d,
			md6_word *B
)
{ int i;
  // md6_word A[r*c+n];
  md6_word A[5000];

  md6_pack(A,Q,K,ell,ii,r,L,z,p,keylen,d,B);

  md6_main_compression_loop( A, md6_default_r(d));

  fprintf(outFile,"MD6 compression function computation ");
  fprintf(outFile,"(level %d, index %d):\n",ell,ii);
  fprintf(outFile,"Inputs (%d words):\n",n);
  for (i=0;i<r*c+n;i++)
    {
      if ((i<q))
	{ fprintf(outFile,"A[%4d] = " PR_MD6_WORD,i,A[i]);
	  fprintf(outFile," Q[%d]\n",i);
	}
      else if ((i>=q)&&(i<q+k))
	{ fprintf(outFile,"A[%4d] = " PR_MD6_WORD,i,A[i]);
	  fprintf(outFile," key K[%d]\n",i-q);
	}
      else if ((u>0)&&(i==q+k+u-1))
	{ fprintf(outFile,"A[%4d] = " PR_MD6_WORD,i,A[i]);
	  fprintf(outFile," nodeID U = (ell,i) = (%d,%d)\n",ell,ii);
	}
      else if ((v>0)&&(i==q+k+u+v-1))
	{ fprintf(outFile,"A[%4d] = " PR_MD6_WORD,i,A[i]);
	  fprintf(outFile," control word V = "
		          "(r,L,z,p,keylen,d) = "
		  "(%d,%d,%d,%d,%d,%d)\n",r,L,z,p,keylen,d);
	}
      else if ((i>=q+k+u+v)&&(i<n))
	{ fprintf(outFile,"A[%4d] = " PR_MD6_WORD,i,A[i]);
	  fprintf(outFile," data B[%2d] ",i-q-k-u-v);
	  if (ell == 1)
	    { if ( (i+(p/w))<n )
		fprintf(outFile,"input message word %4d",ii*b+(i-(q+k+u+v)));
	    }
	  else
	    if ( (i+(p/w))< n )
	      fprintf(outFile,
		      "chaining from (%d,%d)",
		      ell-1,
		      4*ii+(i-(q+k+u+v))/c);
	  fprintf(outFile,"\n");
	}
      else if ((i>=r*c+n-c))
	{ if ((i==r*c+n-c))
	    fprintf(outFile,"Output (%d words of chaining values):\n",c);
	  fprintf(outFile,"A[%4d] = " PR_MD6_WORD,i,A[i]);
	  fprintf(outFile," output chaining value C[%d]\n",i-(r*c+n-c));
	}
      else 
	{ if (i==n)
	    { if (hook_print_intermediate_values)
		fprintf(outFile,"Intermediate values:\n");
	      else
		fprintf(outFile,"Intermediate values A[%d..%d] omitted...\n",n,r*c+n-c-1);
	    }
	  if (hook_print_intermediate_values)
	    fprintf(outFile,"A[%4d] = " PR_MD6_WORD "\n",i,A[i]);
	}
    }
  fprintf(outFile,"\n");
}

/* Trace -- print out details of an md6 computation.
*/

void trace_md6 ( char* filename,
		 int print_intermediate_values,
		 char* M,
		 uint64_t m,
		 int d,
		 char* key,
		 int keylen,
		 int L,
		 int r
		 )
/*
** print to file intermediate results of a hash function computation,
** for each compression function call
**   M, m, d, L, r, key, keylen -- as usual
**   (but assumes K is 0-terminated)
**   filename = output file name
**   print_intermediate_values = 1 to print non-I/O values of A
**                             = 0 to only print I/O values of A
*/
{
  md6_state st;
  time_t now;
  int i;
  int j;

  /* save switch regarding the printing of intermediate values 
  ** for compression_hook_1 to use later.
  */
  hook_print_intermediate_values = print_intermediate_values;

  /* check that input values are sensible */
  assert(( M != NULL ));
  assert(( (key == NULL) || ( (0<=keylen) && (keylen <= k*8) ) ));
  assert(( (1 <= d) && (d <= c*w/2) ));

  outFile = fopen (filename, "w");
  if (outFile == NULL) 
    { printf( "%s can't be opened.\n", filename );
      printf( "trace_md6: aborted.\n" );
      return;
    }

  fprintf(outFile,"Trace of md6 computation.\n");
  time(&now);
  fprintf(outFile,"%s",ctime(&now));
  fprintf(outFile,"Filename: %s\n\n",filename);
  fprintf(outFile,"d = %6d (digest length in bits)\n",d);
  fprintf(outFile,"L = %6d (number of parallel passes)\n",L);
  fprintf(outFile,"r = %6d (number of rounds)\n",r);
  fprintf(outFile,"K = '%s' (key)\n",key);
  fprintf(outFile,"k = %6d (key length in bytes)\n",keylen);
  fprintf(outFile,"M = (hex) ");
  for (i=0;i<18;i++) fprintf(outFile,"%02x ",M[i]);  
  fprintf(outFile,"...\n");
  fprintf(outFile,"    (input message repeats with period 7)\n");
  fprintf(outFile,"m = %6lld (message length in bits)\n",m);
  fprintf(outFile,"    %6lld (message length in (full or partial) bytes)\n",(m+7)/8);
  fprintf(outFile,"\n");

  md6_full_init(&st,d,key,keylen,L,r);
  compression_hook = compression_hook_1;   /* must be done *after* init */
  md6_update(&st,M,(uint64_t)m);
  md6_final(&st,NULL);       

  fprintf(outFile,"Final hash value = \n");
  for (i=0; i<d; i+=64)
    { 
      fprintf(outFile,"          ");
      for (j=0;j<min(64,d-i);j+=8)
	fprintf(outFile,"%02x",st.hashval[(i+j)/8]);
      fprintf(outFile,"\n");
    }
  fprintf(outFile,"End of trace of md6 computation.\n");
  fclose(outFile);
}

/* md6_test_3 -- trace various computations.
*/

void md6_test_3()
{
  unsigned char M[10000];
  int d;
  int L;
  int r;
  unsigned char *key;
  int keylen;
  int i;
  char *filename;

  filename = "md6_test_3.txt";
  printf( "------------------------------------------------------------\n" );
  printf( "md6_test_3.\n" );
  printf( "Starting trace of md6 computation.\n" );
  printf( "Output will be written to file %s \n", filename );
  /* M = "11 22 33 44 55 66 77 11..." (hex, 10000 chars) */
  for (i=0;i<10000;i++) M[i] = 0x11 + (char)((i % 7)*(0x11));

  d = 256;
  L = md6_default_L;
  r = md6_default_r(d);
  key = (unsigned char *)"abcd1234";
  keylen = (int)strlen((char *)key);

  trace_md6("one_block.txt",            
	    1,                   /* print non-I/O A values */
	    M,500*8,d,"",0,L,r
	    );  
  trace_md6("two_block.txt",            
	    1,                   /* print non-I/O A values */
	    M,1000*8,d,"",0,L,r
	    );  
  trace_md6("six_block.txt",            
	    0,                   /* don't print non-I/O A values */
	    M,6*512*8-24,d,"",0,L,r
	    );  
  printf("End of trace of md6 computation.\n\n");

  printf("md6_test_3: end.\n");
}

void md6_test_4()
{
  printf( "------------------------------------------------------------\n" );
  printf( "md6_test_4.\n" );
  printf( "size of md6_state is %d bytes.\n\n",sizeof(md6_state));

}


int main (int argc, char *argv[])
{
  printf("\nMD6 test routines.\n");
  printf("Word size w = %d\n\n",w);

  md6_test_3();  /* print out intermediate results for various hashes */
  md6_test_1();  /* simple test suite */
  md6_test_2();  /* timing test       */
  md6_test_2();  /* do timing test again...    */
  md6_test_4();
  return 0;
}

/* end of md6_test.c */
