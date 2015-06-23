/******************************************************************
 *                                                                * 
 *    Author: Liwei                                               * 
 *                                                                * 
 *    This file is part of the "ClaiRISC" project,                *
 *    The folder in CVS is named as "lwrisc"                      * 
 *    Downloaded from:                                            * 
 *    http://www.opencores.org/pdownloads.cgi/list/lwrisc         * 
 *                                                                * 
 *    If you encountered any problem, please contact me via       * 
 *    Email:mcupro@opencores.org  or mcupro@163.com               * 
 *                                                                * 
 ******************************************************************/


#include "stdlib.h"
#include "stdio.h"
#include "string.h"
void add_ins(char *ins);
int func1(int in)
{
const int table[]={1,2,4,8,16,32,64,128,256,512,1024,2048};
int i =0;
if (in>=2048)return -1;
for(;;i++)
if ((in>table[i])&&(in<table[i+1])){
return i+1;
}
}


int getbit(unsigned int data,unsigned int index)
{
    unsigned int temp=1<<index ;
    if(data&temp)
    return 1 ;
    else 
    return 0 ;
}

char temp[100];
char*ins12tostr(unsigned int ins)
{
    unsigned int i ;
    for(i=0;i<100;++i)temp[i]=0 ;
    for(i=0;i<=11;++i)
    temp[i]=getbit(ins,11-i)+'0' ;
    return temp ;
}
/*static volatile       unsigned char	WB_ADDR		@ 0x01;
//static volatile       unsigned char	PCL		@ 0x02;
static volatile       unsigned char	STATUS		@ 0x03;
static                unsigned char	FSR		@ 0x04;
static volatile       unsigned char	WB_DATA		@ 0x05;
static volatile       unsigned char	WB_CTL		@ 0x06;*/
static char reg_name[30];
char*find_reg(unsigned int t)
{/*
    //puts(&ins[7]);
    if(t==0)
    {
        //  printf("t=%d",t);
        strcpy(reg_name,"WB_ADDR");
        return reg_name ;
    }
    //    if(reg_no==0)strcpy(reg_name,"WB_CTL");
    else if(t==1)
    {
        strcpy(reg_name,"TMR");
        return reg_name ;
    }
    //    else if(reg_no==1)strcpy(reg_name,"WB_ADDR");
    else if(t==2)
    {
        strcpy(reg_name,"PCL");
        return reg_name ;
    }
    
    else
    */ if(t-3==0)
    {
        strcpy(reg_name,"STATUS");
        return reg_name ;
    }/*
    else if(t==0+4)
    {
        strcpy(reg_name,"FSR");
        return reg_name ;
    }
    else if(t==5+0)
    {
        strcpy(reg_name,"WB_DATA");
        return reg_name ;
    }
    //else if(reg_no==5)strcpy(reg_name,"WB_WR_DATA");
    else if(t==6+0)
    {
        strcpy(reg_name,"WB_CTL");
        return reg_name ;
    }
    //else if(reg_no==6)strcpy(reg_name,"WB_RD_DATA");
    else if(t==0+1+6)
    {
        strcpy(reg_name,"PORTC");
        return reg_name ;
    }
    */
    return NULL ;
}

char hex[]=
{
    "0123456789abcdef" 
}
;
char*p,__hex[20]=
{
    0 
}
;
unsigned char*bs2hs(char*bs)
{
    unsigned int t=0,i=0 ;
    for(i=0;;++i)
    {
        if(bs[i]==0)break ;
        t=t*2+bs[i]-'0' ;
    }
    //printf("now t==%d",t);
    p=find_reg(t);
    //if (t>=8) goto else
    if(p!=NULL)
    strcpy(__hex,p);
    else 
    {
        __hex[0]='0' ;
        __hex[1]='x' ;
        __hex[2]=hex[t/16];
        __hex[3]=hex[t%16];
        __hex[4]=0 ;
    }
    return __hex ;
}

char _temp[100];
//get file reg adderss from instruction!
char*gen_ins_fa(char*ins)
{//gen_ins_in(
    strcpy(_temp,ins);
    return bs2hs(&_temp[7]);
}

//get bit data from instruction!
unsigned int gen_ins_bd(char*ins)
{
//1111_1111_1111
    unsigned int t=0 ;
    if(ins[5+1]=='1')t+=1 ;
    if(ins[4+1]=='1')t+=2 ;
    if(ins[3+1]=='1')t+=4 ;
    return t ;
}

//get goto(and call) address data from instruction!
unsigned int gen_ins_goto(char*ins)
{
//000_111111001
    unsigned int t=0 ;
    if(ins[11-0]=='1')t+=1;
    if(ins[11-1]=='1')t+=2 ;
    if(ins[11-2]=='1')t+=4;
    if(ins[11-3]=='1')t+=8 ;
    if(ins[11-4]=='1')t+=16;//1<<4 ;
    if(ins[11-5]=='1')t+=32;//1<<5 ;
    if(ins[11-6]=='1')t+=64;//1<<6 ;
    if(ins[11-7]=='1')t+=128;//1<<7 ;
   // if(ins[11-8]=='1')t+=256;//1<<8 ;
    return t ;
}

//get instant data from instruction!
unsigned int gen_ins_in(char*ins)
{
    unsigned int t=0 ;
    if(ins[11-0]=='1')t+=1;
    if(ins[11-1]=='1')t+=2 ;
    if(ins[11-2]=='1')t+=4;//1<<3 ;
    if(ins[11-3]=='1')t+=8;//1<<4 ;
    if(ins[11-4]=='1')t+=16;//1<<4 ;
    if(ins[11-5]=='1')t+=32;//1<<5 ;
    if(ins[11-6]=='1')t+=64;//1<<6 ;
    if(ins[11-7]=='1')t+=128;//1<<7 ;
    // if(ins[11-8]=='1')t+=1<<8 ;
    return t ;
}


unsigned int inscmp(char*src,char*dst)
{
    unsigned int i ;
    for(i=0;i<=9;i++)
    {
        if(src[i]=='X')continue ;
        else if(src[i]!=dst[i])return 0 ;
    }
    return 1 ;
}


unsigned int str2u12(char*str)
{
    unsigned int ret=0 ;
    unsigned int i ;
    for(i=0;i<=11;++i)
    {
        if(str[i]==0)return ret ;
        ret=ret*10+str[i]-'0' ;
    }
    return ret ;
}
/*
unsigned int getfno(char *ins,unsigned char start,
unsigned char len)
{
unsigned int data = str2u12(ins);
    unsigned int tmp1=0xffff<<len ;
    unsigned int tmp2=data>>start ;
    unsigned int ret ;
    tmp1=~tmp1 ;
    ret=tmp1&tmp2 ;
    ret=ret&0xffff ;
    return ret ;

unsigned int i,ret=0;
for(i=11-start;i<len;++i)
ret=ret+(ins[i]-'0')*2;
return ret;
}*/
/*
void test_main(void)
{
    printf("%d",getno(str2u12("0xff"),0,1));
    getchar();
}*/



char tmp_str[100]=
{
    0 
}
;
void init_temp_str(void)
{
    int i ;
    for(i=0;i<100;++i)
    tmp_str[i]=0 ;
}

char*op_ins_NOP(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"NOP");
    add_ins("NOP");
    //ok
    return tmp_str ;
    
}
char*op_ins_MOVWF(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"MOVWF %s",gen_ins_fa(ins));
    add_ins("MOVWF");
    //ok
    return tmp_str ;
}
char*op_ins_CLRW(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"CLRW");
    add_ins("CLRW");
    return tmp_str ;
}
char*op_ins_CLRF(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"CLRF %s",gen_ins_fa(ins));
    add_ins("CLRF");
    return tmp_str ;
}
char*op_ins_SUBWFW(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"SUBWFW %s",gen_ins_fa(ins));
    add_ins("SUBWFW");
    return tmp_str ;
}
char*op_ins_SUBWFF(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"SUBWFF %s",gen_ins_fa(ins));
    add_ins("WUBWFF");
    return tmp_str ;
}
char*op_ins_DECFW(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"DECFW %s",gen_ins_fa(ins));
    add_ins("DECFW");
    return tmp_str ;
}
char*op_ins_DECFF(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"DECFF %s",gen_ins_fa(ins));
    add_ins("DECFF");
    return tmp_str ;
}
char*op_ins_IORWFW(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"IORWFW %s",gen_ins_fa(ins));
    add_ins("IORWFW");
    return tmp_str ;
}
char*op_ins_IORWFF(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"IORWFF %s",gen_ins_fa(ins));
    add_ins("IORWFF");
    return tmp_str ;
}
char*op_ins_ANDWFW(char*ins)
{
    init_temp_str();
    sprintf(tmp_str,"ANDWFW %s",gen_ins_fa(ins));
    add_ins("ANDWFW");
    return tmp_str ;
}
char*op_ins_ANDWFF(char*ins)
{
    init_temp_str();
    add_ins("ANDWFF");
    sprintf(tmp_str,"ANDWFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_XORWFW(char*ins)
{
    init_temp_str();
    add_ins("XORWFW");
    sprintf(tmp_str,"XORWFW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_XORWFF(char*ins)
{
    init_temp_str();
    add_ins("XORWFF");
    sprintf(tmp_str,"XORWFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_ADDWFW(char*ins)
{
    init_temp_str();
    add_ins("ADDWFW");
    sprintf(tmp_str,"ADDWFW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_ADDWFF(char*ins)
{
    init_temp_str();
    add_ins("ADDWFF");
    sprintf(tmp_str,"ADDWFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_MOVFW(char*ins)
{
    init_temp_str();
    add_ins("MOVFW");
    sprintf(tmp_str,"MOVFW %s",gen_ins_fa(ins));
    return tmp_str ;
    
    
}
char*op_ins_MOVFF(char*ins)
{
    init_temp_str();
    add_ins("MOVFF");
    sprintf(tmp_str,"MOVFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_COMFW(char*ins)
{
    init_temp_str();
    add_ins("COMFW");
    sprintf(tmp_str,"COMFW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_COMFF(char*ins)
{
    init_temp_str();
    add_ins("COMFF");
    sprintf(tmp_str,"COMFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_INCFW(char*ins)
{
    init_temp_str();
    add_ins("INCFW");
    sprintf(tmp_str,"INCFW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_INCFF(char*ins)
{
    init_temp_str();
    add_ins("INCFF");
    sprintf(tmp_str,"INCFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_DECFSZW(char*ins)
{
    init_temp_str();
    add_ins("DECFSZW");
    sprintf(tmp_str,"DECFSZW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_DECFSZF(char*ins)
{
    init_temp_str();
    add_ins("DECFSZF");
    sprintf(tmp_str,"DECFSZF %s  [%d]",gen_ins_fa(ins),gen_ins_bd(ins));
    return tmp_str ;
}
char*op_ins_RRFW(char*ins)
{
    init_temp_str();
    add_ins("RRFW");
    sprintf(tmp_str,"RRFW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_RRFF(char*ins)
{
    init_temp_str();
    add_ins("RRFF");
    sprintf(tmp_str,"RRFF%s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_RLFW(char*ins)
{
    init_temp_str();
    add_ins("RRFW");
    sprintf(tmp_str,"RLFW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_RLFF(char*ins)
{
    init_temp_str();
    add_ins("RLFF");
    sprintf(tmp_str,"RLFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_SWAPFW(char*ins)
{
    init_temp_str();
    add_ins("SWAPFW");
    sprintf(tmp_str,"SWAPFW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_SWAPFF(char*ins)
{
    init_temp_str();
    add_ins("SWAPFF");
    sprintf(tmp_str,"SWAPFF %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_INCFSZW(char*ins)
{
    init_temp_str();
    add_ins("INCFZW");
    sprintf(tmp_str,"INCFSZW %s",gen_ins_fa(ins));
    return tmp_str ;
}
char*op_ins_INCFSZF(char*ins)
{
    init_temp_str();
    add_ins("INCFSZF");
    sprintf(tmp_str,"INCFSZF %s  [%d]",gen_ins_fa(ins),gen_ins_bd(ins));
    return tmp_str ;
}
char*op_ins_BCF(char*ins)
{
    init_temp_str();
    add_ins("BCF");
    sprintf(tmp_str,"BCF %s  [%d]",gen_ins_fa(ins),gen_ins_bd(ins));
    return tmp_str ;
}
char*op_ins_BSF(char*ins)
{
    init_temp_str();
    add_ins("BSF");
    sprintf(tmp_str,"BSF %s  [%d]",gen_ins_fa(ins),gen_ins_bd(ins));
    return tmp_str ;
}
char*op_ins_BTFSC(char*ins)
{
    init_temp_str();
    add_ins("BTFSC");
    sprintf(tmp_str,"BTFSC %s  [%d]",gen_ins_fa(ins),gen_ins_bd(ins));
    return tmp_str ;
}
char*op_ins_BTFSS(char*ins)
{
    init_temp_str();
    add_ins("BTFSS");
    sprintf(tmp_str,"BTFSS %s  [%d]",gen_ins_fa(ins),gen_ins_bd(ins));
    return tmp_str ;
}
char*op_ins_RETLW(char*ins)
{
    init_temp_str();
    add_ins("RETLW");
    sprintf(tmp_str,"RETLW %d",gen_ins_in(ins));
    return tmp_str ;
}
char*op_ins_CALL(char*ins)
{
    init_temp_str();
    add_ins("CALL");
    sprintf(tmp_str,"CALL %d",gen_ins_goto(ins));
    return tmp_str ;
}
char*op_ins_GOTO(char*ins)
{
    init_temp_str();
    add_ins("GOTO");
    sprintf(tmp_str,"GOTO %d",gen_ins_goto(ins));
    return tmp_str ;
}
char*op_ins_MOVLW(char*ins)
{
    init_temp_str();
    add_ins("MOVLW");
    sprintf(tmp_str,"MOVLW %d",gen_ins_in(ins));
    return tmp_str ;
}
char*op_ins_IORLW(char*ins)
{
    init_temp_str();
    add_ins("IORLW");
    sprintf(tmp_str,"IORLW %d",gen_ins_in(ins));
    return tmp_str ;
}
char*op_ins_ANDLW(char*ins)
{
    init_temp_str();
    add_ins("ANDLW");
    sprintf(tmp_str,"ANDLW %d",gen_ins_in(ins));
    return tmp_str ;
}
char*op_ins_XORLW(char*ins)
{
    init_temp_str();
    add_ins("XORLW");
    sprintf(tmp_str,"XORLW %d",gen_ins_in(ins));
    return tmp_str ;
}


char*branch_ins(char*ins)
{
    if(inscmp("000000000000",ins)==1)
    return op_ins_NOP(ins);
    // char * op_ins_NOP (char *ins){}
    else if(inscmp("0000001XXXXX",ins)==1)
    return op_ins_MOVWF(ins);
    // char * op_ins_MOVWF (char *ins){}
    else if(inscmp("000001000000",ins)==1)
    return op_ins_CLRW(ins);
    // char * op_ins_CLRW (char *ins){}
    else if(inscmp("0000011XXXXX",ins)==1)
    return op_ins_CLRF(ins);
    // char * op_ins_CLRF (char *ins){}
    else if(inscmp("0000100XXXXX",ins)==1)
    return op_ins_SUBWFW(ins);
    // char * op_ins_SUBWFW (char *ins){}
    else if(inscmp("0000101XXXXX",ins)==1)
    return op_ins_SUBWFF(ins);
    // char * op_ins_SUBWFF (char *ins){}
    else if(inscmp("0000110XXXXX",ins)==1)
    return op_ins_DECFW(ins);
    // char * op_ins_DECFW (char *ins){}
    else if(inscmp("0000111XXXXX",ins)==1)
    return op_ins_DECFF(ins);
    // char *op_ins_DECFF  (char *ins){}
    else if(inscmp("0001000XXXXX",ins)==1)
    return op_ins_IORWFW(ins);
    // char * op_ins_IORWFW (char *ins){}
    else if(inscmp("0001001XXXXX",ins)==1)
    return op_ins_IORWFF(ins);
    // char * op_ins_IORWFF (char *ins){}
    else if(inscmp("0001010XXXXX",ins)==1)
    return op_ins_ANDWFW(ins);
    // char * op_ins_ANDWFW (char *ins){}
    else if(inscmp("0001011XXXXX",ins)==1)
    return op_ins_ANDWFF(ins);
    // char *  op_ins_ANDWFF(char *ins){}
    else if(inscmp("0001100XXXXX",ins)==1)
    return op_ins_XORWFW(ins);
    // char * op_ins_XORWFW (char *ins){}
    else if(inscmp("0001101XXXXX",ins)==1)
    return op_ins_XORWFF(ins);
    // char *  op_ins_XORWFF(char *ins){}
    else if(inscmp("0001110XXXXX",ins)==1)
    return op_ins_ADDWFW(ins);
    // char *   op_ins_ADDWFW(char *ins){}
    else if(inscmp("0001111XXXXX",ins)==1)
    return op_ins_ADDWFF(ins);
    // char *  op_ins_ADDWFF(char *ins){}
    else if(inscmp("0010000XXXXX",ins)==1)
    return op_ins_MOVFW(ins);
    // char * op_ins_MOVFW (char *ins){}
    else if(inscmp("0010001XXXXX",ins)==1)
    return op_ins_MOVFF(ins);
    // char *  op_ins_MOVFF(char *ins){}
    else if(inscmp("0010010XXXXX",ins)==1)
    return op_ins_COMFW(ins);
    // char * op_ins_COMFW (char *ins){}
    else if(inscmp("0010011XXXXX",ins)==1)
    return op_ins_COMFF(ins);
    // char *  op_ins_COMFF(char *ins){}
    else if(inscmp("0010100XXXXX",ins)==1)
    return op_ins_INCFW(ins);
    // char *  op_ins_INCFW(char *ins){}
    else if(inscmp("0010101XXXXX",ins)==1)
    return op_ins_INCFF(ins);
    // char *  op_ins_INCFF(char *ins){}
    else if(inscmp("0010110XXXXX",ins)==1)
    return op_ins_DECFSZW(ins);
    // char *op_ins_DECFSZW  (char *ins){}
    else if(inscmp("0010111XXXXX",ins)==1)
    return op_ins_DECFSZF(ins);
    // char *  op_ins_DECFSZF(char *ins){}
    else if(inscmp("0011000XXXXX",ins)==1)
    return op_ins_RRFW(ins);
    // char * op_ins_RRFW (char *ins){}
    else if(inscmp("0011001XXXXX",ins)==1)
    return op_ins_RRFF(ins);
    // char * op_ins_RRFF (char *ins){}
    else if(inscmp("0011010XXXXX",ins)==1)
    return op_ins_RLFW(ins);
    // char *  op_ins_RLFW(char *ins){}
    else if(inscmp("0011011XXXXX",ins)==1)
    return op_ins_RLFF(ins);
    // char *  op_ins_RLFF(char *ins){}
    else if(inscmp("0011100XXXXX",ins)==1)
    return op_ins_SWAPFW(ins);
    // char * op_ins_SWAPFW (char *ins){}
    else if(inscmp("0011101XXXXX",ins)==1)
    return op_ins_SWAPFF(ins);
    // char *  op_ins_SWAPFF(char *ins){}
    else if(inscmp("0011110XXXXX",ins)==1)
    return op_ins_INCFSZW(ins);
    // char *op_ins_INCFSZW  (char *ins){}
    else if(inscmp("0011111XXXXX",ins)==1)
    return op_ins_INCFSZF(ins);
    // char * op_ins_INCFSZF (char *ins){}
    else if(inscmp("0100XXXXXXXX",ins)==1)
    return op_ins_BCF(ins);
    // char * op_ins_BCF (char *ins){}
    else if(inscmp("0101XXXXXXXX",ins)==1)
    return op_ins_BSF(ins);
    // char *  op_ins_BSF(char *ins){}
    else if(inscmp("0110XXXXXXXX",ins)==1)
    return op_ins_BTFSC(ins);
    // char *  op_ins_BTFSC(char *ins){}
    else if(inscmp("0111XXXXXXXX",ins)==1)
    return op_ins_BTFSS(ins);
    // char * op_ins_BTFSS (char *ins){}
    else if(inscmp("1000XXXXXXXX",ins)==1)
    return op_ins_RETLW(ins);
    // char *  op_ins_RETLW(char *ins){}
    else if(inscmp("1001XXXXXXXX",ins)==1)
    return op_ins_CALL(ins);
    // char * op_ins_CALL (char *ins){}
    else if(inscmp("101XXXXXXXXX",ins)==1)
    return op_ins_GOTO(ins);
    // char *  op_ins_GOTO( (char *ins){}
    else if(inscmp("1100XXXXXXXX",ins)==1)
    return op_ins_MOVLW(ins);
    // char * op_ins_MOVLW (char *ins){}
    else if(inscmp("1101XXXXXXXX",ins)==1)
    return op_ins_IORLW(ins);
    // char *  op_ins_IORLW(char *ins){}
    else if(inscmp("1110XXXXXXXX",ins)==1)
    return op_ins_ANDLW(ins);
    // char * op_ins_ANDLW (char *ins){}
    else if(inscmp("1111XXXXXXXX",ins)==1)
    return op_ins_XORLW(ins);
    // char *  op_ins_XORLW(char *ins){}
    return NULL ;
}

/*  Input and Output file streams. */
FILE*fpi ;

/*  Well.. Let's read stuff in completely before outputting.. Programs */
/*  should be pretty small.. */
/*  */
#define MAX_MEMORY_SIZE 4096
struct 
{
int nAddress ;
     int byData ;
    char ins[30];
    char dasm[30];
}


Memory[MAX_MEMORY_SIZE];

char szLine[80];
unsigned int start_address,address,ndata_bytes,ndata_words ;
unsigned int data ;
unsigned int nMemoryCount ;
char mif_fn[20]=
{
    0 
}
;
char fin[20]=
{
    0 
}
; 

char ins_tsted[100][10];
int index=0;
void init1(void){
int i,j;
    for(i=0;i<100;++i)
    for(j=0;j<10;++j)
    ins_tsted[i][j]=0;
    index=0;
}

void add_ins(char *ins){
int i;
for(i=0;i<=index;++i)
if (strcmp(ins_tsted[i],ins)==0) return ;
++index;
//printf("add string >%s<\n",ins);getchar();
strcpy(ins_tsted[index],ins);
}

int main(int argc,char*argv[])
{


    int i ;
       int addr_wdt,wd_no;
    int max=0;
   init1();

    if(argc==2)strcpy(fin,argv[1]);
    else 
    {
   //     printf("\nThe Synthetic PIC --- Intel HEX File to Altera memory file");
   //     printf("\nUsage: hex2mif <infile>");
  //      printf("\n");
        getchar();
        return 0 ;
        printf("Input Hex file name:");
        scanf("%s",fin);
        printf("Input Mif file name:");
        scanf("%s",mif_fn);
    }
    
    
    
    /*  Open input HEX file */
    fpi=fopen(argv[1],"r");
    if(!fpi)
    {
        printf("\nCan't open input file %s.\n",argv[1]);
        return 1 ;
    }
    
    /*  Read in the HEX file */
    /*  */
    /*  !! Note, that things are a little strange for us, because the PIC is */
    /*     a 12-bit instruction, addresses are 16-bit, and the hex format is */
    /*     8-bit oriented!! */
    /*  */
    nMemoryCount=0 ;
    while(!feof(fpi))
    {
        /*  Get one Intel HEX line */
        fgets(szLine,80,fpi);
        if(strlen(szLine)>=10)
        {
            /*  This is the PIC, with its 12-bit "words".  We're interested in these */
            /*  words and not the bytes.  Read 4 hex digits at a time for each */
            /*  address. */
            /*  */
            sscanf(&szLine[1],"%2x%4x",&ndata_bytes,&start_address);
            if(start_address>=0&&start_address<=20000&&ndata_bytes>0)
            {
                /*  Suck up data bytes starting at 9th byte. */
                i=9 ;
                
                /*  Words.. not bytes.. */
                ndata_words=ndata_bytes/2 ;
                start_address=start_address/2 ;
                
                /*  Spit out all the data that is supposed to be on this line. */
                for(address=start_address;address<start_address+ndata_words;address++)
                {
                    /*  Scan out 4 hex digits for a word.  This will be one address. */
                    sscanf(&szLine[i],"%04x",&data);
                    
                    /*  Need to swap bytes... */
                    data=((data>>8)&0x00ff)|((data<<8)&0xff00);
                    i+=4 ;
                    
                    /*  Store in our memory buffer */
                    Memory[nMemoryCount].nAddress=address ;
                    Memory[nMemoryCount].byData=data ;
                    nMemoryCount++;
                }
            }
        }
    }
    fclose(fpi);
    
    /*
            for(i=0;;++i)
            {
                mif_fn[i]=fin[i];
                if(mif_fn[i]=='.')
                {
                    mif_fn[i+1]='m' ;
                    mif_fn[i+2]='i' ;
                    mif_fn[3+i]='f' ;
                    mif_fn[4+i]=0 ;
                    break ;
                }
            }
                                  */
    
    strcpy(mif_fn,"init_file.mif");
    
    fpi=fopen(mif_fn,"w");
    if(NULL==fpi)return ;
    /*  Now output the Verilog $readmemh format! */
    /*  */
    
    /*  Now output the Verilog $readmemh format! */
    /*  */
    fprintf(fpi,"WIDTH=12;\nDEPTH=2048;\n\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n");
    printf("WIDTH=8;\nDEPTH=256;\n\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n");
    printf("Email:McuPro@163.com\n");
    
    for(i=0;i<nMemoryCount;i++)
    {
      //  printf("%X : %X;\n",Memory[i].nAddress,Memory[i].byData);
        fprintf(fpi,"%4X : %4X;\n",Memory[i].nAddress,Memory[i].byData);
    }
    
    fprintf(fpi,"\nEND;\n");
    printf("\END;\n");
    close(fpi);
    /*output simulate verilog code */
    /*
            for(i=0;;++i)
            {
                mif_fn[i]=fin[i];
                if(mif_fn[i]=='.')
                {
                    mif_fn[i+1]='v' ;
                    mif_fn[i+2]=0 ;
                    break ;
                }
            }
                            */
    
    strcpy(mif_fn,"sim_rom.v");
    
    fpi=fopen(mif_fn,"w");
    if(NULL==fpi)return ;
    fprintf(fpi,"//This file was created by a tool wrietten with C.\n");
    fprintf(fpi,"module sim_rom (\n");
    fprintf(fpi,"    address,\n");
    fprintf(fpi,"    clock,\n");
    fprintf(fpi,"    q);\n");
    fprintf(fpi,"    input    [10:0]  address;\n");
    fprintf(fpi,"    input      clock;\n");
    fprintf(fpi,"    output    [11:0]  q;\n");
    fprintf(fpi,"    \n");
    fprintf(fpi,"reg [10:0]    address_latched;\n");
    fprintf(fpi,"// Instantiate the memory array itself.\n");
    fprintf(fpi,"reg [11:0]    mem[0:2048-1];\n");
    fprintf(fpi,"initial begin \n");
    for(i=0;i<nMemoryCount;i++)
    {
    //    printf("mem[%05d] = s;\n",Memory[i].nAddress,Memory[i].ins);
        fprintf(fpi,"mem[%04d] = 12'b%s;\n",Memory[i].nAddress,ins12tostr(Memory[i].byData));
        }
    fprintf(fpi,"end\n");
    fprintf(fpi,"// Latch address\n");
    fprintf(fpi,"always @(posedge clock)\n");
    fprintf(fpi,"   address_latched <= address;\n");
    fprintf(fpi,"   \n");
    fprintf(fpi,"// READ\n");
    fprintf(fpi,"assign q = mem[address_latched];\n");
    fprintf(fpi,"\n");
    fprintf(fpi,"endmodule\n");
    fprintf(fpi,"\n");
    fprintf(fpi,"/*\n");
        for(i=0;i<nMemoryCount;i++)
    {
    //    printf("%04d:%s\n",Memory[i].nAddress,ins12tostr(Memory[i].byData));
        //     sprintf(Memory[i].ins,"%s",ins12tostr(Memory[i].byData));
        fprintf(fpi,"%04d: %s\n",Memory[i].nAddress,branch_ins(ins12tostr(Memory[i].byData)));
        // fprintf(fpi,"mem[%d] = %d;\n",Memory[i].nAddress,Memory[i].byData);
    }
    fprintf(fpi,"*/\n/*\ncovered instructions:\n");
    
    for(i=0;i<=index;++i)
    {
        fprintf(fpi,"%s\n",ins_tsted[i]);
    }
        fprintf(fpi,"*/\n");
    close(fpi);
        
        
    strcpy(mif_fn,"tested_instructions.txt");
     fpi=fopen(mif_fn,"w");
        for(i=0;i<=index;++i)
    {
        fprintf(fpi,"%s\n",ins_tsted[i]);
    }
            close(fpi);
            
    fpi=fopen(mif_fn,"w");
    
    /*output deasm filr*/
    strcpy(mif_fn,"Dasm.txt");
    fpi=fopen(mif_fn,"w");
    for(i=0;i<nMemoryCount;i++)
    {
    //   fprintf(fpi,"%04d:%s\n",Memory[i].nAddress,ins12tostr(Memory[i].byData));
        //     sprintf(Memory[i].ins,"%s",ins12tostr(Memory[i].byData));
        fprintf(fpi,"%04d : %s\n",Memory[i].nAddress,branch_ins(ins12tostr(Memory[i].byData)));
        // fprintf(fpi,"mem[%d] = %d;\n",Memory[i].nAddress,Memory[i].byData);
    }
    close(fpi);
    //   getchar();
    
        
  //  strcpy(mif_fn,"rom_set.h");
 
   // fpi=fopen(mif_fn,"w");
    for(i=0;i<nMemoryCount;i++)
    {
    if ((Memory[i].nAddress==2047)&&(Memory[i-1].nAddress!=2046))continue;
    if ((Memory[i].nAddress==1023)&&(Memory[i-1].nAddress!=1022))continue;
    if (Memory[i].nAddress>max) max=Memory[i].nAddress;
    //   Memory[i].nAddressfprintf(fpi,"%04d:%s\n",Memory[i].nAddress,ins12tostr(Memory[i].byData));
        //     sprintf(Memory[i].ins,"%s",ins12tostr(Memory[i].byData));
        //fprintf(fpi,"%04d : %s\n",Memory[i].nAddress,branch_ins(ins12tostr(Memory[i].byData)));
        // fprintf(fpi,"mem[%d] = %d;\n",Memory[i].nAddress,Memory[i].byData);
       // fprintf(fpi,"mem[%d] = %d;\n",
    }
    addr_wdt = func1(max);
    //  fprintf(fpi,"`define     ALT_MEM_WIDTHAD   %d\n",addr_wdt);
   //   fprintf(fpi,"`define     ALT_MEM_NUMWORDS  %d\n",1<<addr_wdt); 
   //   `define      MIF_NAME  %s\n\n","init_file.mif");  
//    fprintf(fpi,"`define    ROM_TYPE  rom%dx12\n\n",1<<func1(max));
 
   // close(fpi);
    //   getchar();
}

