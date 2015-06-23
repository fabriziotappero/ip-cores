/*
 *! \file msimtest.c
 *  \brief Archivo de cabecera de mismtest. Este programa tiene por proposito verificar que los resultados arrojados por la ejecuci&oacute;n del testbench sean validos. Este programa est&aacute; muy mal escrito. Por favor no lo tome como referencia de ninguna manera, esta HORRIBLEMENTE escrito!.
 *
 *  Created by julian on 21/03/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "msimtest.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>


altrom_reg innuendo[RESULT_LINES];

FILE * fprom, *fpdec, *fpmul, *fpresults;



#define LB	'{'
#define RB	'}'
#define CM	','






ssize_t getline(char ** lptr, size_t n, FILE * stream){

	int cnt;
	char *pc;
	
	if (feof(stream))
		return -1;
	
	
	
	//clear buffer	
	for (cnt=0,pc=lptr[0]; cnt<(int)n; cnt++)
		*((char*)(pc+cnt))=0;
	
	cnt=0;
	
	//till end of line
	do {
		//check if buffer size is appropiate
		if (cnt>=(int)n){ 
			pc=(char*)realloc(lptr[0],cnt+1);
			
			lptr[0]=pc;
		}
		
		//read one byte should not be any problem
		if (!fread(pc+cnt, 1, 1, stream))
			return -1;
		
		if (pc[cnt]==0x0a || pc[cnt]==0x0 || feof(stream)) 
			return cnt+1;
		
		cnt++;
		
	} while (1);	
}
#define ONEPAD(x,s) x |= (1<<(s-1))&x?(((long long int)-1)<<s):0 
void onespadding(int s){
	
	
	int index0,index1;
	for (index0=0; index0<ROM_LINES; index0++)
		for (index1=0; index1<15; index1++) 
			ONEPAD(innuendo[index0].rom[index1],s);
	
}


#define SEARCHTOKEN(pc,t) while(*(pc++)!=t)
void vph(void*v,void*r,char e){
	
	//find {
	char ** pv=(char**)v;
	char * c=pv[0];
	long long int * Pv=r;
	
	//SEARCHTOKEN(c,s);
	*Pv=0;
	do{
		if (isxdigit(*c)){
			*Pv<<=4;
			(*Pv)+=((*c)>=0x30 && (*c)<0x40)?(*c)-0x30:(islower(*c)?(*c)-82:(*c)-55);
		}
		
	}SEARCHTOKEN(c,e);
	
	pv[0]=c;

}
void vpi(void*v,void*r,char e){
	
	char ** pv=(char**)v;
	char * c=pv[0];
	long long int * Pv=r;
	
	//SEARCHTOKEN(c,s);
	*Pv=0;
	do{
		if (isdigit(*c)){
			*Pv*=10;
			(*Pv)+=*c-0x30;
		}
		
	}SEARCHTOKEN(c,e);
	pv[0]=c;
}
#undef SEARCHTOKEN

#define ROM_DELAY 0
#define DEC_DELAY 1
#define MUL_DELAY 2
#define CROSS_DELAY 3
#define DOTP_DELAY 4

//parsing method model
vvp pmodelrom[] =	{vpi,vph,vpi,vph,vph,vph,vph,vph,vph,vph,vph,vph,vph,vph,vph,0x0};
vvp pmodeldec[] =	{vpi,vph,vph,vph,vph,vph,vph,vph,vph,vph,vph,vph,vph,0x0};
vvp pmodelmult[]=	{vpi,vph,vph,vph,vph,vph,vph,0x0};
vvp pmodelresult[]=	{vpi,vph,vph,vph,vph,vph,0x0};

void * pmodel[]={pmodelrom,pmodeldec,pmodelmult,pmodelresult};	

char edrom[]=	{RB,RB,RB,CM,CM,RB,CM,CM,RB,CM,CM,RB,CM,CM,RB};
char eddec[]=	{RB,CM,RB,CM,RB,CM,RB,CM,RB,CM,RB,CM,RB};
char edmult[]=	{RB,RB,RB,RB,RB,RB,RB};
char edresult[]=	{RB,CM,CM,RB,RB,RB};

char *enddelimiter[]= {edrom,eddec,edmult,edresult};


//slots
int psmodel[]={ROM_SLOTS,DEC_SLOTS,MUL_SLOTS,RESULT_SLOTS,0x0};
//lines
int plmodel[]={ROM_LINES, DEC_LINES, MULT_LINES, RESULT_LINES, 0x0};

//delay model
int dmodel[]={0,20,60,60,80,0x0};


typedef struct parce{
	vvp ** pfunc;
	int * smodel;
	int * lmodel;
	FILE * fp[4];
}xparser;

typedef xparser* pxparser; 

pxparser xp;

void quickgetfile(int i){
	
	unsigned char padthai;

	long int * slot[]={&innuendo[0].rom[0],&innuendo[0].dec[0],&innuendo[0].mul[0],&innuendo[0].res[0]};
	
	long long int * xslot=slot[i];
	vvp * pfunc	= (vvp*)pmodel[i];

	int smodel	= psmodel[i];
	int lmodel	= plmodel[i];
	FILE * fp	= xp->fp[i];
		
	
	int index=0,index1,nread;
	char * b[1];
	char * c;
	
	
	long int * pv;
	*b=0x0;
	do{		
		
		/*
		This function reads an entire line from stream, storing the text (including the newline and a terminating null character) in a buffer and storing the buffer address in *lineptr.		
		Before calling getline, you should place in *lineptr the address of a buffer *n bytes long, allocated with malloc. If this buffer is long enough to hold the line, getline stores the line in this buffer. 
		Otherwise, getline makes the buffer bigger using realloc, storing the new buffer address back in *lineptr and the increased size back in *n. See Unconstrained Allocation.
		If you set *lineptr to a null pointer, and *n to zero, before the call, then getline allocates the initial buffer for you by calling malloc.
		In either case, when getline returns, *lineptr is a char * which points to the text of the line.
		When getline is successful, it returns the number of characters read (including the newline, but not including the terminating null). This value enables you to distinguish null characters that are part of the line from the null character inserted as a terminator.
		This function is a GNU extension, but it is the recommended way to read lines from a stream. The alternative standard functions are unreliable.
		If an error occurs or end of file is reached without any bytes read, getline returns -1.
		*/	
		
		do {
			if (*b)
				free(*b);
			*b=(char*)malloc(1);
			if (!b)
				exit(EXIT_FAILURE);
			nread=getline(b,1,fp);
			if (nread==-1)
				exit(EXIT_FAILURE);
			c=b[0];
			
		} while (*c=='#');
		
		for (index1=0;pfunc[index1];index1++){		
			pfunc[index1](&c,&(xslot[index1]),enddelimiter[i][index1]);
			if (i==1 || i==3) {
				padthai=(i==1)?18:32;
				ONEPAD(xslot[index1],padthai);
			}
			
		}
		xslot+=(sizeof(altrom_reg)/8);	
		
				
		
		index++;
		
	}while (index<plmodel[i]);
	fclose(fp);
	return;
	
}
void vdisp(void){
	
	int index0,index1,op;
	long long int ms[6];
	for (index0=0; index0<1535; index0++) {
		op=innuendo[index0].rom[2];
		for (index1=0; index1<6; index1++) {
			ms[index1]=innuendo[index0+1].dec[1+2*index1]*innuendo[index0+1].dec[2+2*index1];
			ms[index1]>>=4;
			
		
			fprintf(stdout, "T: %d I: %d\n",index1,innuendo[index0+3].mul[0]); 
			fprintf(stdout,"C: %llx S: %llx\n",ms[index1],(innuendo[index0+3].mul[index1+1]<<32)>>32);
		}
		
	}


	
}

int main (int argc, char ** argv){
	
	int index,openingerror;
	
	int size=sizeof(long int);
	
	xp=(pxparser)malloc(sizeof(xparser));
	
	//Open files
	for (index=1,openingerror=0;index>0 && index<5;){
		if (!openingerror) {
			xp->fp[index-1]=fopen(argv[index],"r");
			if (!(xp->fp[index-1])) {
				openingerror=1;
				index--;
			}
			else 
				index++;

		}
		else 
			fclose(xp->fp[--index]);
		
	}

	if (openingerror){
		fprintf(stdout,"error: no se encontro(aron) el(los) archivo(s) con la informacion\n");
		return -1;
	}
	
	memset(innuendo,0,sizeof(altrom_reg)*RESULT_LINES);
	
	
	
	
	quickgetfile(0);
	quickgetfile(1);
	quickgetfile(2);
	quickgetfile(3);
	vdisp();
	onespadding(18);
	
	return 1;
}






		