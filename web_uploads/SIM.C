//STEFAN, Istvan
//Little endian???
//published under GPL
//Version of the core

#include <curses.h>
#include <stdio.h>
int version=3;
//Instruction's names
#define MAXCMD 16
char *cmds[MAXCMD+1]={"coA","coB","add","sub","mvA","mvB","shl","shr"
		,"and","orr","xor","jmp","Fmv","mvD","Dmv","mvP",""};
char *cmds2[MAXCMD+1]={"mvA","coA","mvB","coB","csB","shl","shr","and"
		,"orr","xor","add","sub","cal","ret","Imv","jmp",""};
char *cmds3[MAXCMD+1]={"mvA","coA","mvB","coB","csB","shl","shr","and"
		,"orr","xor","add","sub","int","ire","Imv","jmp",""};
//Register's names
#define MAXREG 16
char *regs[MAXREG+1]={"r0","r1","r2","r3","r4","r5","r6","r7"
		,"r8","r9","r10","r11","r12","r13","r14","r15",""};

//Table of the registres
unsigned regtab[16];
unsigned IP,DP,SP;//The Instruction Pointer, data, stack
unsigned A,B;//The two hidden registers
unsigned irq=0;//Interrupt

int htu(char * name){
    printf("nCore simulator by STEFAN, Istvan\n");
    printf("%s program\n",name);
    return -1;
}

int freshreg(){
    int i;
    for(i=0;i<16;i++)
	mvprintw(3+i%4,(i/4)*10,"Reg%d:%d",i,regtab[i]);
    mvprintw(7,0,"IP:%d A:%d B:%d DP:%d SP:%d",IP,A,B,DP,SP);
    return 0;
}

int freshdata(int DP,int datal,unsigned *data){
    int i;
    for(i=DP;i<((DP+16>datal)?datal:DP+16);i++)
	mvprintw(9+i/4,(i%4)*14,"Dat[%d]:%d",i,data[i]);
    return 0;
}

int freshtext(int IP,int textl,unsigned char* text){
    int i,j=((IP+18>textl)?textl:IP+18);
//    for(i=IP;i<j;i++)
    for(i=0;i<(j-IP);i++)
	switch(version){
	case 1:
	    mvprintw(15+i%6,(i/6)*20,"Tex[IP+%d]:%s %d",
			    i,cmds[text[i+IP]>>4],text[i+IP]&15);
	case 2:
	    mvprintw(15+i%6,(i/6)*20,"Tex[IP+%d]:%s %d",
			    i,cmds2[text[i+IP]>>4],text[i+IP]&15);
	case 3:
	    mvprintw(15+i%6,(i/6)*20,"Tex[IP+%d]:%s %d",
			    i,cmds3[text[i+IP]>>4],text[i+IP]&15);
	}
    return 0;
}
#undef debug
#define debug
int runInst(unsigned char inst){
int par=inst&15;
/*char *cmds[MAXCMD+1]={"coA","coB","add","sub","mvA","mvB","shl","shr"
		,"and","orr","xor","jmp","Fmv","mvD","Dmv","mvP",""};
*/
#ifdef debug
    mvprintw(1,0,"par=%d",par);
#endif
switch(version){
    case 3:
        switch(inst>>4){
    	    case 0:A=regtab[par];//mvA
    	    	break;
    	    case 1:A=par;//coA
    	    	break;
    	    case 2:B=regtab[par];//mvB
    	    	break;
    	    case 3:B=par;//coB
    	    	break;
    	    case 4:B=(B<<4)+par;//csB
    	    	break;
    	    case 5:regtab[par]=A<<B;//shl
    	    	break;
    	    case 6:regtab[par]=A>>B;//shr
    	    	break;
    	    case 7:regtab[par]=A&B;//and
    		break;
    	    case 8:regtab[par]=A|B;//orr
    		break;
    	    case 9:regtab[par]=A^B;//xor
    		break;
    	    case 10:regtab[par]=A+B;//add
    		break;
    	    case 11:regtab[par]=A-B;//sub
    		break;
    	    case 12:irq=1;
		    IP=16;//int
    		break;
    	    case 13:irq=0;//ire
		    IP=regtab[12];
    		break;
    	    case 14:regtab[par]=IP;//Imv
    		break;
    	    case 15:if(A&1)
			IP=regtab[par];//jmp
    		break;
        }
    }
    return 0;
}

#undef debug
#define debug
int main(int par,char **pars){
    FILE *f;
    unsigned char *text;//.text section
    unsigned *data,*stack;//.data,.stack sections
    unsigned long textl, datal,stackl;//Long of the sections
    unsigned long i=0,j=0,k=0,add_init=0,add=0;//32 bit variables
    if(par!=2)
	return htu(pars[0]);
    
    if(!(f=fopen(pars[1],"ro"))){
	printf("Error opening the file %s\nQuitting\n",pars[1]);
	return -1;
	}
//Init the hidden regs
    A=0;
    B=0;
    irq=0;
//Read the version of the used instruction set
    //Little endian reading
    j=fgetc(f);
    j+=fgetc(f)*(1<<8);
    j+=fgetc(f)*(1<<16);
    j+=fgetc(f)*(1<<24);
    version=j;
#ifdef debug
//    mvprintw(0,0,"Address of the __main function:%ld\n",j);
    printf("Version of the instruction set:%ld\n",j);
#endif

    //Little endian reading
    j=fgetc(f);
    j+=fgetc(f)*(1<<8);
    j+=fgetc(f)*(1<<16);
    j+=fgetc(f)*(1<<24);
#ifdef debug
//    mvprintw(0,0,"Address of the __main function:%ld\n",j);
    printf("Address of the __main function:%ld\n",j);
#endif
    IP=j;//Address of the main function
    DP=0;//Data pointer

    j=fgetc(f);
    j+=fgetc(f)*(1<<8);
    j+=fgetc(f)*(1<<16);
    j+=fgetc(f)*(1<<24);
#ifdef debug
    printf("Length of the stack:%d\n",j);
#endif
    stackl=(unsigned)j;
    stack=(unsigned*)calloc(stackl,sizeof(unsigned));
    SP=DP+stackl;
#ifdef debug
    printf("Pointer of the stack:%d\n",SP);
#endif
    
    j=fgetc(f);
    j+=fgetc(f)*(1<<8);
    j+=fgetc(f)*(1<<16);
    j+=fgetc(f)*(1<<24);
#ifdef debug
    printf("Length of the first section(.data):%ld\n",j);
#endif
    datal=j;
    data=(unsigned*)calloc(datal,sizeof(unsigned));
    for(i=0;i<datal;i++){
	j=fgetc(f);
	j+=fgetc(f)*(1<<8);
	j+=fgetc(f)*(1<<16);
	j+=fgetc(f)*(1<<24);
	data[i]=j;
#ifdef debug
	printf("Readed data:%d\n",j);
#endif
	}
    
    j=fgetc(f);
    j+=fgetc(f)*(1<<8);
    j+=fgetc(f)*(1<<16);
    j+=fgetc(f)*(1<<24);
#ifdef debug
    printf("Length of the second section(.text):%ld\n",j);
#endif
    textl=j;
    text=(unsigned char*)calloc(textl,sizeof(unsigned char));
    i=0;
    if(i>=0)
    while((i<textl)&&(!feof(f))){
//    for(i=0;i<textl;i++){
	j=fgetc(f);
	text[i]=j;
	i++;
#ifdef debug
	printf("Readed data:%d;%s:%s\n",j,cmds2[j>>4],cmds2[text[i-1]>>4]);
#endif
	}

#ifdef debug
    getchar();
#endif
    //Init the ncurses env
    initscr();
    cbreak();
    noecho();

do{
    clear();
    runInst(text[IP]);
    freshreg();
    freshdata(regtab[14],datal,data);
//    freshtext(add,textl,text);
    freshtext(IP,textl,text);
    IP++;
    }while((getch()=='r')&&(IP<textl));

//    freshtext(regtab[15],textl);
    
//    getch();
    
    //Close the ncurses env
    endwin();
    return 0;
}
