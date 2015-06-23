/////////////////////////////////////////////////////////////////////
////                                                             ////
////  fptpg.c                                                    ////
////  Floating Point Test Pattern Generator                      ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          russelmann@hotmail.com                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
////                    russelmann@hotmail.com                   ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY        ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT           ////
//// LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND   ////
//// FITNESS FOR A PARTICULAR PURPOSE.                           ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


#include "milieu.h"
#include "softfloat.h"

// Global vars ...
int	verb=0;
int	quiet=0;
int	pat=0;
int	large=0;
int	append=0;
int	rall=0;
int	fcmp=0;
char	*ofile=0;

// Prototypes ...
float32	get_fp();
int	arop(int , int );
float32 get_pat(int );
float32 get_pat0(int );
float32 get_pat1(int );
float32 get_pat2(int );


main(int argc, char **argv)
{
int	i;
int	count=25;
int	ar = 0;
int	seed = 12345678;

float_rounding_mode = float_round_nearest_even;	// Default Rounding Mode

if(argc<2) {
	printf("Usage:\n");
	printf("	-n <count>	Specifies the number of tests\n");
	printf("			vectors to generate. Default: 25.\n");
	printf("	-v		Verbose\n");
	printf("	-q		Quiet\n");
	printf("	-a		Append to output file name. Default: Overwrite\n");
	printf("	-l		Use large numbers\n");
	printf("	-p N		Use built in patterns. N=Patter Number:\n");
	printf("			0 = Min/Max Bit patters, normalized numbers only (Max 92416 Vectors)\n");
	printf("			1 = Min/Max Bit patters, including denormalized numbers (Max 92416 Vectors)\n");
	printf("			2 = Bit patterns test vectors (Max 15376 Vectors)\n");
	printf("	-o <filename>	Dump patterns to <filename>\n");
	printf("	-r N		Round Option. Where N is one of:\n");
	printf("			0 = float_round_nearest_eve (Default)\n");
	printf("			1 = float_round_down\n");
	printf("			2 = float_round_up\n");
	printf("			3 = float_round_to_zero\n");
	printf("	-m N		Generate Test patters for operation N.\n");
	printf("			Where N is a combination of:\n");
	printf("			 1 = Add operations\n");
	printf("			 2 = Subtract Operations\n");
	printf("			 4 = Multiply Operations\n");
	printf("			 8 = Divide operations\n");
	printf("			16 = Integer to Floating Point Conversion\n");
	printf("			32 = Floating Point to Integer Conversion\n");
	printf("			64 = Remainder Function\n");
	printf("	-s N		Use N as seed for rand() functions.\n");
	printf("	-R		Randomize rounding mode.\n");
	return(0);
   }

i=1;

while((argc-1)>=i)	{
	if(strcmp(argv[i],"-fcmp")==0)	fcmp=1;
	else
	if(strcmp(argv[i],"-v")==0)	verb=1;
	else
	if(strcmp(argv[i],"-q")==0)	quiet=1;
	else
	if(strcmp(argv[i],"-R")==0)	rall=1;
	else
	if(strcmp(argv[i],"-p")==0) {
		i++;
		pat = atoi(argv[i]) + 1;
		if(pat>3 | pat<0) {
			printf("ERROR: 'pattern' out of range (%0d), resetting to pattern 0.\n",pat);
			pat = 1;
		   }			
	   }
	else
	if(strcmp(argv[i],"-l")==0)	large=1;
	else
	if(strcmp(argv[i],"-ll")==0)	large=2;
	else
	if(strcmp(argv[i],"-a")==0)	append=1;
	else
	if(strcmp(argv[i],"-n")==0) {
		i++;
		count = atoi(argv[i]);
		if(count<0 | count>1000000) {
			printf("ERROR: 'count' out of range (%0d), resetting to default.\n",count);
			count=25;
		   }
	   }
	else
	if(strcmp(argv[i],"-o")==0) {
		i++;
		ofile = argv[i];
	   }
	else
	if(strcmp(argv[i],"-m")==0) {
		i++;
		ar = atoi(argv[i]);
	   }
	else
	if(strcmp(argv[i],"-r")==0) {
		i++;
		float_rounding_mode = atoi(argv[i]);
	   }
	else
	if(strcmp(argv[i],"-s")==0) {
		i++;
		seed = atoi(argv[i]);
	   }
	else
		printf("Unknown Option: %s\n\n",argv[i]);
	i++;	
   } 

srand( seed );

if(!quiet) {
	printf("\n Floating Point Test Vector Generation V1.7\n");
	printf("\t by  Rudolf Usselmann  rudi@asics.ws\n\n");

	switch(float_rounding_mode) {
		case 0:	printf("Rounding mode: float_round_nearest_even\n"); break;
		case 1:	printf("Rounding mode: float_round_down\n"); break;
		case 2:	printf("Rounding mode: float_round_up\n"); break;
		case 3:	printf("Rounding mode: float_round_to_zero\n"); break;
	
		default: printf("Rounding mode: Unknown (%0d)\n", float_rounding_mode ); break;
	   }
  }

if(count==25) {

	if( (ar & 0x10) | (ar & 0x20) )  {

		if(pat==1)	count = 304;
		else
		if(pat==2)	count = 304;
		else
		if(pat==3)	count = 124;

	} else {

		if(pat==1)	count = 92416;
		else
		if(pat==2)	count = 92416;
		else
		if(pat==3)	count = 15376;

	}

   }

if(ar)		arop(count,ar);
if(fcmp)	do_fcmp(count);

return(0);
}


int arop(int count, int op) {
float32 f1, f2, f3, f4;
int	i;
int	fp;
char	*mode;
int	add=0;
int	sub=0;
int	mul=0;
int	div=0;
int	i2f=0;
int	f2i=0;
int	rem=0;
int	oper;
int	err;
int	err_count=0;
int	tmp;

if(!quiet) printf("\nGenerating %0d Arithmetic test vectors ...\n",count);

if(append)	mode = "a";
else		mode = "w";
if(ofile==0)	ofile = "ar.hex";

fp = fopen(ofile,mode);
if(fp == 0) {
	printf("ERROR: Could not create file '%s'.\n",ofile);
	return(-1);
   }

if(!quiet) {
	if(op & 0x01)	printf("Add OP\n");
	if(op & 0x02)	printf("Sub OP\n");
	if(op & 0x04)	printf("Mul OP\n");
	if(op & 0x08)	printf("Div OP\n");
	if(op & 0x10)	printf("int2float\n");
	if(op & 0x20)	printf("float2int\n");
	if(op & 0x40)	printf("Remainder\n");
   }

if(op & 0x01)	add=1;
if(op & 0x02)	sub=1;
if(op & 0x04)	mul=1;
if(op & 0x08)	div=1;
if(op & 0x10)	i2f=1;
if(op & 0x20)	f2i=1;
if(op & 0x40)	rem=1;

f1 = get_pat(0);	// Initialize pattern generator ...

for(i=0;i<count;i++) {

	err = 0;

	if(pat>0) {
		f1 = get_pat(1);
		f2 = get_pat(2);
	   } else {
		f1 = get_fp();
		f2 = get_fp();
	   }


	if(rall)	float_rounding_mode = (rand() % 4);


	oper = -1;
	while(oper == -1) {
	float_exception_flags = 0;			// Reset Exceptions

		if( (rand() % 8)==6 & rem) {
			oper = 0x40;
			f3 = float32_rem( f1, f2 );
			float_exception_flags = 0;	// Reset Exceptions
			f3 = float32_rem( f1, f2 );
		   }

		if( (rand() % 8)==5 & f2i) {
			oper = 0x20;
			f3 = float32_to_int32( f1 );
			float_exception_flags = 0;	// Reset Exceptions
			f3 = float32_to_int32( f1 );
			f2 = 0;
		   }

		if( (rand() % 8)==4 & i2f) {
			oper = 0x10;


			tmp = (int) f1;


			f3 = int32_to_float32( tmp );
			float_exception_flags = 0;	// Reset Exceptions
			f3 = int32_to_float32( tmp );
			f2 =0;
		   }


		if( (rand() % 8)==3 & div) {
			oper = 0x08;
			f3 = float32_div( f1, f2);
			float_exception_flags = 0;	// Reset Exceptions
			f3 = float32_div( f1, f2);

			//*( (float *) &f4 ) = *( (float *) &f1 ) / *( (float *) &f2 );
			//if( f4 != f3) {
			//	err = 1;
			//	printf("FP Div Error: %x - %x: System: %x Lib: %x\n",f1, f2, f4, f3);
			//   }
		   }

		if( (rand() % 8)==2 & mul) {
			oper = 0x04;
			f3 = float32_mul( f1, f2);
			float_exception_flags = 0;	// Reset Exceptions
			f3 = float32_mul( f1, f2);

			//*( (float *) &f4 ) = *( (float *) &f1 ) * *( (float *) &f2 );
			//if( f4 != f3) {
			//	err = 1;
			//	printf("FP Mul Error: %x - %x: System: %x Lib: %x\n",f1, f2, f4, f3);
			//   }
		   }

		if( (rand() % 8)==1 & sub) {
			oper = 0x02;
			f3 = float32_sub( f1, f2);
			float_exception_flags = 0;	// Reset Exceptions
			f3 = float32_sub( f1, f2);

			//*( (float *) &f4 ) = *( (float *) &f1 ) - *( (float *) &f2 );
			//if( f4 != f3) {
			//	err = 1;
			//	printf("FP Sub Error: %x - %x: System: %x Lib: %x\n",f1, f2, f4, f3);
			//   }
		   }

		if( (rand() % 8)==0 & add) {
			oper = 0x01;
			f3 = float32_add( f1, f2);
			float_exception_flags = 0;	// Reset Exceptions
			f3 = float32_add( f1, f2);

			//*( (float *) &f4 ) = *( (float *) &f1 ) + *( (float *) &f2 );
			//if( f4 != f3) {
			//	err = 1;
			//	printf("FP Add Error: %x - %x: System: %x Lib: %x\n",f1, f2, f4, f3);
			//   }
		   }

	   }

	if(err)		err_count++;

	if(!err) {

		//if(float_exception_flags != 0)
		//	printf("Exceptions: %x\n",float_exception_flags);
	
	
		if(verb)	printf("rmode: %01x, except: %02x, oper: %02x opa: %08x, opb: %08x res: %08x\n", float_rounding_mode, float_exception_flags, oper, f1, f2, f3);
		fprintf(fp,"%01x%02x%02x%08x%08x%08x\n", float_rounding_mode, float_exception_flags, oper, f1, f2, f3);
	   }
	else {
		printf("\t Vecor mismatch between library and system calculations. This Vector\n");
		printf("\t will not be placed in to vector file ...\n");
	}

   }


close(fp);

if(!quiet) {
	printf("Found %d errors\n",err_count);
	printf("Wrote %d vectors from total %d specified.\n", (count-err_count), count);
	
	printf("\n ... fptpg done.\n");
   }
return(0);
}



do_fcmp(int count) {
float32 f1, f2, f3, f4;
int	i;
int	fp;
char	*mode;
int	err;
int	err_count=0;
int	result;
int	eq, le, lt;

if(!quiet) printf("\nGenerating %0d Arithmetic test vectors ...\n",count);

if(append)	mode = "a";
else		mode = "w";
if(ofile==0)	ofile = "ar.hex";

fp = fopen(ofile,mode);
if(fp == 0) {
	printf("ERROR: Could not create file '%s'.\n",ofile);
	return(-1);
   }


for(i=0;i<count;i++) {

	float_exception_flags = 0;			// Reset Exceptions

	if(pat>0) {
		f1 = get_pat(1);
		f2 = get_pat(2);
	   } else {
		f1 = get_fp();
		f2 = get_fp();
	   }

	eq = float32_eq( f1, f2 );
	le = float32_le( f1, f2 );
	lt = float32_lt( f1, f2 );

	float_exception_flags = 0;			// Reset Exceptions

	eq = float32_eq( f1, f2 );
	le = float32_le( f1, f2 );
	lt = float32_lt( f1, f2 );

	eq = *( (float *) &f1 ) == *( (float *) &f2 );
	le = *( (float *) &f1 ) < *( (float *) &f2 );
	lt = *( (float *) &f1 ) > *( (float *) &f2 );


	if(eq)	result = 1;
	else
	if(le)	result = 2;
	else
	if(lt)	result = 4;
	else	result = 0;


	if(verb)	printf("except: %02x, opa: %08x, opb: %08x res: %01x\n",  float_exception_flags, f1, f2, result);
	fprintf(fp,"%02x%08x%08x%01x\n",  float_exception_flags, f1, f2, result);
	}

close(fp);

if(!quiet) {
	printf("Found %d errors\n",err_count);
	printf("Wrote %d vectors from total %d specified.\n", (count-err_count), count);
	
	printf("\n ... fptpg done.\n");

   }

return(0);

}



float32 get_fp() {
float32 f1;
int	i1, i2, e;

	if(large>0)	i2 = rand();
	else		i2 = 0;

	if(large>1)	i1 = rand() | (i2<<16);
	else		i1 = rand() | (i2<<10);

	i1 = i1 & 0x007fffff;

	e = rand();
	e = e & 0x0ff;
	
	f1 = (e << 23) + i1;
	
	if( rand() & 0x01)	f1 = f1 | 0x80000000;

	return(f1);
}

static int p0, p1;

//	0x00800000	Minimum Posetive Number
//	0x7f7fffff	Maximum Posetive Number


float32 pat0[] = {	0x00800000, 0x00800001, 0x00800002, 0x00800004,
			0x00800008, 0x00880000, 0x00900000, 0x00a00000,
			0x00c00000, 0x00880001, 0x00900001, 0x00a00001,
			0x00c00001, 0x00880002, 0x00900002, 0x00a00002,
			0x00c00002, 0x00880004, 0x00900004, 0x00a00004,
			0x00c00004, 0x00800003, 0x00800007, 0x0080000f,
			0x00f80000, 0x00f00000, 0x00e00000, 0x00f80001,
			0x00f00001, 0x00e00001, 0x00f80003, 0x00f00003,
			0x00e00003, 0x00c00003, 0x00f80007, 0x00f00007,
			0x00e00007, 0x00c00007, 0x00ffffff, 0x00fffffe,
			0x00fffffd, 0x00fffffb, 0x00fffff7, 0x00f7ffff,
			0x00efffff, 0x00dfffff, 0x00bfffff, 0x00f7fffe,
			0x00effffe, 0x00dffffe, 0x00bffffe, 0x00f7fffd,
			0x00effffd, 0x00dffffd, 0x00bffffd, 0x00f7fffb,
			0x00effffb, 0x00dffffb, 0x00bffffb, 0x00fffffc,
			0x00fffff8, 0x00fffff0, 0x0087ffff, 0x008fffff,
			0x009fffff, 0x0087fffe, 0x008ffffe, 0x009ffffe,
			0x0087fffc, 0x008ffffc, 0x009ffffc, 0x00bffffc,
			0x0087fff8, 0x008ffff8, 0x009ffff8, 0x00bffff8,
			0x7f000000, 0x7f000001, 0x7f000002, 0x7f000004,
			0x7f000008, 0x7f080000, 0x7f100000, 0x7f200000,
			0x7f400000, 0x7f080001, 0x7f100001, 0x7f200001,
			0x7f400001, 0x7f080002, 0x7f100002, 0x7f200002,
			0x7f400002, 0x7f080004, 0x7f100004, 0x7f200004,
			0x7f400004, 0x7f000003, 0x7f000007, 0x7f00000f,
			0x7f780000, 0x7f700000, 0x7f600000, 0x7f780001,
			0x7f700001, 0x7f600001, 0x7f780003, 0x7f700003,
			0x7f600003, 0x7f400003, 0x7f780007, 0x7f700007,
			0x7f600007, 0x7f400007, 0x7f7fffff, 0x7f7ffffe,
			0x7f7ffffd, 0x7f7ffffb, 0x7f7ffff7, 0x7f77ffff,
			0x7f6fffff, 0x7f5fffff, 0x7f3fffff, 0x7f77fffe,
			0x7f6ffffe, 0x7f5ffffe, 0x7f3ffffe, 0x7f77fffd,
			0x7f6ffffd, 0x7f5ffffd, 0x7f3ffffd, 0x7f77fffb,
			0x7f6ffffb, 0x7f5ffffb, 0x7f3ffffb, 0x7f7ffffc,
			0x7f7ffff8, 0x7f7ffff0, 0x7f07ffff, 0x7f0fffff,
			0x7f1fffff, 0x7f07fffe, 0x7f0ffffe, 0x7f1ffffe,
			0x7f07fffc, 0x7f0ffffc, 0x7f1ffffc, 0x7f3ffffc,
			0x7f07fff8, 0x7f0ffff8, 0x7f1ffff8, 0x7f3ffff8,
			0x80800000, 0x80800001, 0x80800002, 0x80800004,
			0x80800008, 0x80880000, 0x80900000, 0x80a00000,
			0x80c00000, 0x80880001, 0x80900001, 0x80a00001,
			0x80c00001, 0x80880002, 0x80900002, 0x80a00002,
			0x80c00002, 0x80880004, 0x80900004, 0x80a00004,
			0x80c00004, 0x80800003, 0x80800007, 0x8080000f,
			0x80f80000, 0x80f00000, 0x80e00000, 0x80f80001,
			0x80f00001, 0x80e00001, 0x80f80003, 0x80f00003,
			0x80e00003, 0x80c00003, 0x80f80007, 0x80f00007,
			0x80e00007, 0x80c00007, 0x80ffffff, 0x80fffffe,
			0x80fffffd, 0x80fffffb, 0x80fffff7, 0x80f7ffff,
			0x80efffff, 0x80dfffff, 0x80bfffff, 0x80f7fffe,
			0x80effffe, 0x80dffffe, 0x80bffffe, 0x80f7fffd,
			0x80effffd, 0x80dffffd, 0x80bffffd, 0x80f7fffb,
			0x80effffb, 0x80dffffb, 0x80bffffb, 0x80fffffc,
			0x80fffff8, 0x80fffff0, 0x8087ffff, 0x808fffff,
			0x809fffff, 0x8087fffe, 0x808ffffe, 0x809ffffe,
			0x8087fffc, 0x808ffffc, 0x809ffffc, 0x80bffffc,
			0x8087fff8, 0x808ffff8, 0x809ffff8, 0x80bffff8,
			0xff000000, 0xff000001, 0xff000002, 0xff000004,
			0xff000008, 0xff080000, 0xff100000, 0xff200000,
			0xff400000, 0xff080001, 0xff100001, 0xff200001,
			0xff400001, 0xff080002, 0xff100002, 0xff200002,
			0xff400002, 0xff080004, 0xff100004, 0xff200004,
			0xff400004, 0xff000003, 0xff000007, 0xff00000f,
			0xff780000, 0xff700000, 0xff600000, 0xff780001,
			0xff700001, 0xff600001, 0xff780003, 0xff700003,
			0xff600003, 0xff400003, 0xff780007, 0xff700007,
			0xff600007, 0xff400007, 0xff7fffff, 0xff7ffffe,
			0xff7ffffd, 0xff7ffffb, 0xff7ffff7, 0xff77ffff,
			0xff6fffff, 0xff5fffff, 0xff3fffff, 0xff77fffe,
			0xff6ffffe, 0xff5ffffe, 0xff3ffffe, 0xff77fffd,
			0xff6ffffd, 0xff5ffffd, 0xff3ffffd, 0xff77fffb,
			0xff6ffffb, 0xff5ffffb, 0xff3ffffb, 0xff7ffffc,
			0xff7ffff8, 0xff7ffff0, 0xff07ffff, 0xff0fffff,
			0xff1fffff, 0xff07fffe, 0xff0ffffe, 0xff1ffffe,
			0xff07fffc, 0xff0ffffc, 0xff1ffffc, 0xff3ffffc,
			0xff07fff8, 0xff0ffff8, 0xff1ffff8, 0xff3ffff8
			};


int	pat0_cnt = 304;


float32 pat1[] = {	0x6c800000, 0x3a000001, 0x69800002, 0x79800004,
			0x37000008, 0x59080000, 0x7d900000, 0x23200000,
			0x59c00000, 0x23880001, 0x5e900001, 0x45a00001,
			0x1f400001, 0x63080002, 0x29100002, 0x15200002,
			0x43c00002, 0x5d880004, 0x29900004, 0x54200004,
			0x09400004, 0x28800003, 0x7f800007, 0x0880000f,
			0x3cf80000, 0x4af00000, 0x58e00000, 0x61780001,
			0x20700001, 0x0fe00001, 0x15780003, 0x73700003,
			0x52e00003, 0x7b400003, 0x10780007, 0x7c700007,
			0x30e00007, 0x3dc00007, 0x5f7fffff, 0x45fffffe,
			0x407ffffd, 0x18fffffb, 0x48fffff7, 0x60f7ffff,
			0x27efffff, 0x145fffff, 0x3e3fffff, 0x5277fffe,
			0x3ceffffe, 0x73dffffe, 0x233ffffe, 0x67f7fffd,
			0x33effffd, 0x4e5ffffd, 0x243ffffd, 0x4f77fffb,
			0x6feffffb, 0x31dffffb, 0x673ffffb, 0x207ffffc,
			0x07fffff8, 0x3dfffff0, 0x6187ffff, 0x7f8fffff,
			0x7f1fffff, 0x1887fffe, 0x170ffffe, 0x011ffffe,
			0x3a87fffc, 0x280ffffc, 0x0a9ffffc, 0x753ffffc,
			0x4187fff8, 0x7b8ffff8, 0x2c1ffff8, 0x40bffff8,
			0x00000000, 0x00000001, 0x00000002, 0x00000004,
			0x00000008, 0x00080000, 0x00100000, 0x00200000,
			0x00400000, 0x00080001, 0x00100001, 0x00200001,
			0x00400001, 0x00080002, 0x00100002, 0x00200002,
			0x00400002, 0x00080004, 0x00100004, 0x00200004,
			0x00400004, 0x00000003, 0x00000007, 0x0000000f,
			0x00780000, 0x00700000, 0x00600000, 0x00780001,
			0x00700001, 0x00600001, 0x00780003, 0x00700003,
			0x00600003, 0x00400003, 0x00780007, 0x00700007,
			0x00600007, 0x00400007, 0x007fffff, 0x007ffffe,
			0x007ffffd, 0x007ffffb, 0x007ffff7, 0x0077ffff,
			0x006fffff, 0x005fffff, 0x003fffff, 0x0077fffe,
			0x006ffffe, 0x005ffffe, 0x003ffffe, 0x0077fffd,
			0x006ffffd, 0x005ffffd, 0x003ffffd, 0x0077fffb,
			0x006ffffb, 0x005ffffb, 0x003ffffb, 0x007ffffc,
			0x007ffff8, 0x007ffff0, 0x0007ffff, 0x000fffff,
			0x001fffff, 0x0007fffe, 0x000ffffe, 0x001ffffe,
			0x0007fffc, 0x000ffffc, 0x001ffffc, 0x003ffffc,
			0x0007fff8, 0x000ffff8, 0x001ffff8, 0x003ffff8,
			0xc7800000, 0xc3800001, 0x84000002, 0xf6800004,
			0x90000008, 0xca880000, 0xee900000, 0xc8200000,
			0xb0c00000, 0xd3080001, 0xa7100001, 0x84a00001,
			0xb6400001, 0xbc880002, 0xee100002, 0xc7a00002,
			0xbec00002, 0xe4880004, 0x90100004, 0xfea00004,
			0x82c00004, 0x9d000003, 0x9b800007, 0xef00000f,
			0xe3780000, 0xadf00000, 0x83e00000, 0xe7f80001,
			0xf9700001, 0xbae00001, 0x81f80003, 0xbef00003,
			0xb8600003, 0x88400003, 0xf7f80007, 0xcbf00007,
			0xa3600007, 0xf2400007, 0x9dffffff, 0xfefffffe,
			0xa27ffffd, 0x8ffffffb, 0xc07ffff7, 0xc3f7ffff,
			0x806fffff, 0xdcdfffff, 0xda3fffff, 0xd3f7fffe,
			0x916ffffe, 0xde5ffffe, 0xd2bffffe, 0x9df7fffd,
			0x97effffd, 0x9cdffffd, 0xa43ffffd, 0xf377fffb,
			0xe0effffb, 0xe9dffffb, 0xb43ffffb, 0x9c7ffffc,
			0xaafffff8, 0xcafffff0, 0xa887ffff, 0xf98fffff,
			0xda1fffff, 0xff87fffe, 0xff0ffffe, 0xe19ffffe,
			0x8287fffc, 0x808ffffc, 0xab1ffffc, 0xddbffffc,
			0xd387fff8, 0xe40ffff8, 0x8d1ffff8, 0xefbffff8,
			0x80000000, 0x80000001, 0x80000002, 0x80000004,
			0x80000008, 0x80080000, 0x80100000, 0x80200000,
			0x80400000, 0x80080001, 0x80100001, 0x80200001,
			0x80400001, 0x80080002, 0x80100002, 0x80200002,
			0x80400002, 0x80080004, 0x80100004, 0x80200004,
			0x80400004, 0x80000003, 0x80000007, 0x8000000f,
			0x80780000, 0x80700000, 0x80600000, 0x80780001,
			0x80700001, 0x80600001, 0x80780003, 0x80700003,
			0x80600003, 0x80400003, 0x80780007, 0x80700007,
			0x80600007, 0x80400007, 0x807fffff, 0x807ffffe,
			0x807ffffd, 0x807ffffb, 0x807ffff7, 0x8077ffff,
			0x806fffff, 0x805fffff, 0x803fffff, 0x8077fffe,
			0x806ffffe, 0x805ffffe, 0x803ffffe, 0x8077fffd,
			0x806ffffd, 0x805ffffd, 0x803ffffd, 0x8077fffb,
			0x806ffffb, 0x805ffffb, 0x803ffffb, 0x807ffffc,
			0x807ffff8, 0x807ffff0, 0x8007ffff, 0x800fffff,
			0x801fffff, 0x8007fffe, 0x800ffffe, 0x801ffffe,
			0x8007fffc, 0x800ffffc, 0x801ffffc, 0x803ffffc,
			0x8007fff8, 0x800ffff8, 0x801ffff8, 0x803ffff8,
			};


int	pat1_cnt = 304;
int	pat2_cnt = 124;

float32 pat2[] = {	0x00000000,
			0x00000001,
			0x00000002,
			0x00000004,
			0x00000008,
			0x00000010,
			0x00000020,
			0x00000040,
			0x00000080,
			0x00000100,
			0x00000200,
			0x00000400,
			0x00000800,
			0x00001000,
			0x00002000,
			0x00004000,
			0x00008000,
			0x00010000,
			0x00020000,
			0x00040000,
			0x00080000,
			0x00100000,
			0x00200000,
			0x00400000,
			0x00800000,
			0x01000000,
			0x02000000,
			0x04000000,
			0x08000000,
			0x10000000,
			0x20000000,
			0x40000000,
			0x80000000,
			0xC0000000,
			0xE0000000,
			0xF0000000,
			0xF8000000,
			0xFC000000,
			0xFE000000,
			0xFF000000,
			0xFF800000,
			0xFFC00000,
			0xFFE00000,
			0xFFF00000,
			0xFFF80000,
			0xFFFC0000,
			0xFFFE0000,
			0xFFFF0000,
			0xFFFF8000,
			0xFFFFC000,
			0xFFFFE000,
			0xFFFFF000,
			0xFFFFF800,
			0xFFFFFC00,
			0xFFFFFE00,
			0xFFFFFF00,
			0xFFFFFF80,
			0xFFFFFFC0,
			0xFFFFFFE0,
			0xFFFFFFF0,
			0xFFFFFFF8,
			0xFFFFFFFC,
			0xFFFFFFFE,
			0xFFFFFFFF,
			0xFFFFFFFD,
			0xFFFFFFFB,
			0xFFFFFFF7,
			0xFFFFFFEF,
			0xFFFFFFDF,
			0xFFFFFFBF,
			0xFFFFFF7F,
			0xFFFFFEFF,
			0xFFFFFDFF,
			0xFFFFFBFF,
			0xFFFFF7FF,
			0xFFFFEFFF,
			0xFFFFDFFF,
			0xFFFFBFFF,
			0xFFFF7FFF,
			0xFFFEFFFF,
			0xFFFDFFFF,
			0xFFFBFFFF,
			0xFFF7FFFF,
			0xFFEFFFFF,
			0xFFDFFFFF,
			0xFFBFFFFF,
			0xFF7FFFFF,
			0xFEFFFFFF,
			0xFDFFFFFF,
			0xFBFFFFFF,
			0xF7FFFFFF,
			0xEFFFFFFF,
			0xDFFFFFFF,
			0xBFFFFFFF,
			0x7FFFFFFF,
			0x3FFFFFFF,
			0x1FFFFFFF,
			0x0FFFFFFF,
			0x07FFFFFF,
			0x03FFFFFF,
			0x01FFFFFF,
			0x00FFFFFF,
			0x007FFFFF,
			0x003FFFFF,
			0x001FFFFF,
			0x000FFFFF,
			0x0007FFFF,
			0x0003FFFF,
			0x0001FFFF,
			0x0000FFFF,
			0x00007FFF,
			0x00003FFF,
			0x00001FFF,
			0x00000FFF,
			0x000007FF,
			0x000003FF,
			0x000001FF,
			0x000000FF,
			0x0000007F,
			0x0000003F,
			0x0000001F,
			0x0000000F,
			0x00000007,
			0x00000003
};


float32 get_pat(int mode) {

if(mode==0) {
	p0 = 0;
	p1 = 0;
	return(0);
   }
else
if(pat==1)	return(get_pat0(mode));
else
if(pat==2)	return(get_pat1(mode));
else
if(pat==3)	return(get_pat2(mode));

else return(0);

}



float32 get_pat0(int mode) {
float32	x;

if(mode==1) {
	if(p0==pat0_cnt)		p0 = 0;
	x = pat0[p0];
	p0++;
	return(x);
   }

if(mode==2) {
	x = pat0[p1];
	if(p0==(pat0_cnt) )		p1++;
	if(p1==pat0_cnt)		p1 = 0;
	return(x);
   }

return(0);
}



float32 get_pat1(int mode) {
float32	x;

if(mode==1) {
	if(p0==pat1_cnt)		p0 = 0;
	x = pat1[p0];
	p0++;
	return(x);
   }

if(mode==2) {
	x = pat1[p1];
	if(p0==(pat1_cnt) )		p1++;
	if(p1==pat1_cnt)		p1 = 0;
	return(x);
   }

return(0);
}


float32 get_pat2(int mode) {
float32	x;

if(mode==1) {
	if(p0==pat2_cnt)		p0 = 0;
	x = pat2[p0];
	p0++;
	return(x);
   }

if(mode==2) {
	x = pat2[p1];
	if(p0==(pat2_cnt) )		p1++;
	if(p1==pat2_cnt)		p1 = 0;
	return(x);
   }

return(0);
}