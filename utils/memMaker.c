/*
 *  memMaker.c
 *  memoryMaker
 *
 *  Created by julian on 23/02/11.
 *  GPL LICENSED
 *  The goal of this peace of code is to create a memory initialization file of random fixed point numbers
 *  in order to simulate RtEngine.
 *  Usage is 
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <string.h>

#ifdef __MINGW32__
#define random() ((((long int)rand())<<17)|rand())
#define srandom srand
#endif


char australia[]="DEPTH = %03d;\nWIDTH = %02d;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT\nBEGIN\n\n\0";
char canada[]="END;\n\0";
struct {
	int depth;
	int width;
	int dec;
	
	char *initialheader;
	char *end;
	int R;
	
	int offset;
	int addressoffset;
	
	
}memparam={0,0,0,australia,canada,0,1,0};	

//mpx memparam={0,0,australia};

void optParser(int argc, char ** argv){
	
	char a=0;
	int e=0,d=0,t=0,s=0,i=0;
	/*memparam.initialheader=australia;
	memparam.width=0;
	memparam.depth=0;*/
	while ((a=getopt(argc,argv,"a:o:t:e:d:Rr"))!=-1){
		switch(a){
			case 'a':
				memparam.addressoffset=atoi(optarg);
				break;
			case 'o':
				memparam.offset=atoi(optarg);
				break;
			case 'R': //Raiz Cuadrada
				memparam.R=1;
				break;
			case 'r': //random
				memparam.R=2;
				break;
			case 't':
				if (t){
					fprintf (stdout, "error:Doble parametro t...\n");
					exit(-1);
				}
				t++;
				memparam.depth=atoi(optarg);
				break;
			case 'e':
				if (e){
					fprintf (stdout, "error:Doble parametro e...\n");
					exit(-1);
				}
				e++;
				memparam.width+=atoi(optarg);
				break;
			case 'd':
				if (d){
					fprintf (stdout,"error:Doble parametro d...\n");
					exit(-1);
				}
				d++;
				memparam.dec=atoi(optarg);
				memparam.width+=memparam.dec;
				
				break;
			case '?':
				fprintf(stdout,"error: WTF! %c !?\n",optopt);
				exit(-1);
				break;
		}
	}
	if (!e || !d || !t){
		fprintf(stdout,"uso: memMaker -t numeroDePosicionesDeMemoria -e numeroDeBitsParaLaRepresentacionEntera -d numeroDeBitsParaLaRepresentacionDecimal\n");
		exit(-1);
	}
	if ((e+d)>31){
		fprintf(stdout,"enteros + decimales no puede ser mayor a 31 bits!\n");
		exit(-1);
	}
}

int hexreq(long int x){
	return ((int)(log2(x)/4))+1;
}
int f0inv(float x){ 
	int I;
	float fI;
	fI=(1/x);
	//fprintf (stdout," %f %f ", x, fI);
	fI*=pow(2,memparam.dec);
	I=fI;
	I&=0x3ffff;
	return I;
}

int f1sqrt(float x){
	int S;
	float fS;
	fS=(sqrt(x)*pow(2,memparam.dec));
	S=fS;
	S&=0x3ffff;
	return S;
}

int f2random(float x){
	int mask=pow(2,memparam.width+1)-1;
	return random()&mask; 
}
typedef int (*ff2i)(float);
void generatenums(void){
	
	int index;
	unsigned long int factor;
	float ffactor,epsilon;
	char buff[1024],sign;
	ff2i xf[]={f0inv,f1sqrt,f2random};
	int depthpfw=hexreq(memparam.depth);
	int widthpfw=((int)(memparam.width/4))+(memparam.width%4?1:0);
	srandom(time(0));
	epsilon=1/(float)memparam.depth;
	
	fprintf(stdout,"-- epsilon: %f\n",epsilon);
	for(index=memparam.addressoffset;index<memparam.depth+memparam.addressoffset;index++){
		factor=xf[memparam.R](memparam.offset*(1+(index-memparam.addressoffset)*epsilon));
		sign=memparam.R==2?((factor&(1<<memparam.width))?'-':'+'):'+';
		ffactor=(factor&(1<<memparam.width))?(factor^(int)(pow(2,memparam.width+1)-1))+1:factor;
		ffactor/=pow(2,memparam.dec);
		memset(buff,0,1024);
		sprintf(buff,"%c0%dx : %c0%dx; -- FIXED => %x . %x (%d . %d) FLOAT %c%f\n",
				'%',
				depthpfw,
				'%',
				widthpfw,
				factor>>memparam.dec,
				factor&(int)(pow(2,memparam.dec)-1),
				factor>>memparam.dec,
				factor&(int)(pow(2,memparam.dec)-1),
				sign,
				ffactor);
		fprintf(stdout,buff,index,factor);
	}

}		
void printmem(void){
	fprintf (stdout,memparam.initialheader,memparam.depth,memparam.width+1);
	generatenums();
	fprintf (stdout,memparam.end);

}

int main (int argc, char **argv){
	
	fprintf (stdout,"--RAND MAX: 0x%x\n", RAND_MAX);
#ifdef __MINGW32__
	fprintf (stdout,"--MINGW32 VERSION\n");
#else 
	fprintf (stdout,"--UNIX BASED VERSION\n");
#endif
	
	optParser(argc,argv);
	printmem();		
}	
