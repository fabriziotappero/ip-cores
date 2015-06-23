//STEFAN, Istvan
//Little endian???
//published under GPL
//Mukodik:
//	utasitasok, regiszterek, direktivak felismerese
//	kovetkezo direktivaknal szam felismerese:
//		.byte,.word,.dword,.qword,.ascii,.asciiz
//		nincs szohatarhoz igazitva az adatsor vege sem eleje
//	nincs kezelve, szukseges?:
//		.nibble,.bool,.space!!!Ez kellene
//		.stack:verem meretenek beallitasa
//	todo:
//		stack meretenek olvasasa
//		hexa szamok felismerese (boolean, octa?)
//		szohatarhoz igazitas
//		kimeneti fajlformatum:
//			szekciok meretenek kiirasa
//			!!eddig nem tud futni a sim
//		a sorszamok helyes szamolasa

#include <stdio.h>
#include <string.h>//strcmp(),strcpy()
#include <stdlib.h>//atoll()

//Line number
int line=0;
//Version of the core
int version=1;;
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
char *regs[MAXREG+1]={"reg0","reg1","reg2","reg3","reg4","reg5","reg6","reg7"
		,"reg8","reg9","reg10","reg11","reg12","reg13","reg14","reg15",""};
char *regs_d[MAXREG+1]={"$0","$1","$2","$3","$4","$5","$6","$7"
		,"$8","$9","$10","$11","$12","$13","$14","$15",""};
char *regs_r[MAXREG+1]={"r0","r1","r2","r3","r4","r5","r6","r7"
		,"r8","r9","r10","r11","r12","r13","r14","r15",""};
char *regs_n[MAXREG+1]={"","","","","","","",""
		,"","","","ireA","FLAG","mem","DP","IP",""};//???

//Directive's names
#define MAXDIR 12
char *dire[MAXDIR+1]={".data",".stack",".text",".core3",".byte",".word",".dword",
		".qword",".ascii",".asciiz",".space",".core2",""};

int dorg=0,torg=0;//Global vars, place actual in the section .data/.text
int stackl=0;
char datab=0,stackb=0,textb=0;//These directives can be declared only one time
    //0:not yet defined,1:defined,2:actual section

struct labstruct{
    char name[15];
    unsigned int address;
    unsigned char label_type;//0:address not defined,1:data label,2:text label 
};

//Storing the labels
struct labstruct lab[100];
int maxlab=0;//Current number of labels

//Structure of the binary file:
//	address of main function (unsigned int)
//	length of stack section (unsigned int)
//		???length of the next section (unsigned int)
//	.data section
//		//0x0000:the adress of the stack at runtime->deleted
//		label's pointers
//		initialised datas
//		???length of the next section (unsigned int)
//	.text section
//		???length of the next section (unsigned int){0}
//	???chksum???
//Structure on execution:
//	.text segment
//	.data segment:
//		address of stack?->deleted
//	.stack
//Structure of the data section at the runtime
//	0x0 address of the stack
//	0x1 addresses of the labels (functions, variables, etc)

int wordsize=32;//This is the width of the registers and granulity of the .data

int htu(char *c){
    printf("Asm compiler for the nCore project at opencores.org\n");
    printf("Published under the GPL.\n");
    printf("\tUse:\n");
    printf("\t%s infile.asm [outfile]\n",c);
    return(0);
}

char fgetc_line(FILE *f){
    char c=fgetc(f);
    if(c=='\n')
	line++;//We count the line-number
    return c;
}

int whitespace(char c){
return ((c==' ')|(c=='\t')|(c=='\n')|(c=='\r')|(c==';')
	|(c==':'));//For labels
}
#undef debug
//#define debug
char readchar(FILE * f){
    char c;
#ifdef debug
    printf("\treadchar");
    c=fputc(fgetc_line(f),stdout);
#else
    c=fgetc_line(f);
#endif
    if(feof(f))return(-10);
    while(whitespace(c)){
	if(c==';'){
#ifdef debug
	    while(fputc(fgetc_line(f),stdout)!='\n')
#else
	    while(fgetc_line(f)!='\n')
#endif
		    if(feof(f))return(-10);
		    //line++;
		    }
#ifdef debug
	c=fputc(fgetc_line(f),stdout);
#else
	c=fgetc_line(f);
#endif
	if(feof(f))return(-10);
	}
#ifdef debug
    fputc('\n',stdout);
#endif
//    if(c=='\n')
	//line++;
    return(c);
}

int newlabel(char * s){//Add the label name s to the list of labels(w/o address)
    int i=0;
    while(((i<maxlab)&(strcmp(lab[i].name,s)!=0)))
	i++;
    if(i<maxlab)
	return(-1);//The label already exist, we can't overwrite it
    strcpy(lab[maxlab].name,s);
    lab[maxlab].address=0;
    lab[maxlab].label_type=0;//'Not yet used' label
    maxlab++;
    return(i);//i=maxlab-1
}

int findlabel(char * s){//Search the label s in the label's list
    int i=0;
    while(((i<maxlab)&(strcmp(lab[i].name,s)!=0)))
	i++;
    if(i==maxlab)
	return(-1);//The label not exist
    return(i);
}

//#define debug
int addlabel(char * s){//Add the address to the existing label s
    int i=0;
    while(((i<maxlab)&(strcmp(lab[i].name,s)!=0)))
    	i++;
    if(datab==2){
	lab[i].address=dorg;
	lab[i].label_type=1;//Label under use, pointing to data
	return(i);
	}
    else if(textb==2){
	lab[i].address=torg;
	lab[i].label_type=2;//Label under use, pointing to function
#ifdef debug
	printf("Marked label at %d:%d\n",torg,lab[i].address);
#endif
	return(i);
	}
    else return(-2);//We can't define a label out of the .data/.text sections
}

#undef debug
//#define debug
int readreg(FILE * f){//visszateres: 0< regiszter, <0 cimke, <maxlab: hiba
    char cmd[31];
    int i=0;
    if(feof(f))return(-10);
    cmd[0]=readchar(f);
    while(!whitespace(cmd[i])){
	i++;
	cmd[i]=fgetc_line(f);
    if(feof(f))return(-10);
    }
    cmd[i]=0;
#ifdef debug
    printf("\treg:%s\n",cmd);
#endif
    i=0;
    while((strcmp(cmd,regs[i])!=0)&(i<MAXREG)){//Looking for the register
#ifdef debug
	printf("%s:%s\n",cmd,regs[i]);
#endif
	i++;}
    if(i<MAXREG){
#ifdef debug
	printf("%s\n",regs[i]);
#endif
	return(i);
    }
//Not in the regs set
    i=0;
    while((strcmp(cmd,regs_d[i])!=0)&(i<MAXREG)){//Looking for the register
	i++;}
    if(i<MAXREG){
#ifdef debug
	printf("%s\n",regs_d[i]);
#endif
        return(i);
    }
//Not in the regs_d set
    i=0;
    while((strcmp(cmd,regs_r[i])!=0)&(i<MAXREG)){//Looking for the register
	i++;}
    if(i<MAXREG){
#ifdef debug
	printf("%s\n",regs_r[i]);
#endif
	return(i);
    }
//Not in the regs_r set
    i=0;
    while((strcmp(cmd,regs_n[i])!=0)&(i<MAXREG)){//Looking for the register
	i++;}
    if(i<MAXREG){
#ifdef debug
	printf("%s\n",regs_n[i]);
#endif
	return(i);
    }
if(version>1){//We can use a label as param only after version 2 of the core
#ifdef debug
	printf("Unknown register:%s, searching in labels...",cmd);
#endif
    i=findlabel(cmd);
    if(i==-1){
	i=newlabel(cmd);
#ifdef debug
	printf("created.\n");
#endif
	}
#ifdef debug
    else
	printf("found.\n");
#endif
    return (-i-1);
}
	printf("Unknown register:%s, at line %d\n",cmd,line);
	return(-maxlab-10);//Unknown register/label
}

#undef debug
int direrr(char * dire){
    printf("%s was declared more than once.\nLine:%d",dire,line);
    return(-1);
}
#undef debug
//#define debug
int getvalue(FILE *f,FILE * d,int w){//Recognizing dec,hex,oct,bin numbers!!!,
			//and writing to .data
    char s[15];//TODO!!!!
    int i=0;//No of readed numbers
    long long j=0;
    int l;//writed bytes
    int ch;
    char c;//the next character in f
    int k;//altalanos ciklusvaltozo
    c=fgetc_line(f);
#ifdef debug
    printf("Readed0:%c",c);
#endif
    if(feof(f))
        return(-1);//Early file-end
    while(!feof(f)){
	while(((c==' ')|(c=='\t'))&(!feof(f))){
	    c=fgetc_line(f);
#ifdef debug
	    printf("Readed1:%c",c);
#endif
	    }
#ifdef debug
	printf("\t First readed char:'%c',%d\n",c,c);
#endif
	if(feof(f))
	    return(-1);//Early file-end
	if(((c>'9')|(c<'0'))&((c!='\'')&(c!='\"')&(c!=',')&(c!=' ')&(c!='\t'))){
	    printf("Need number after this directive\nLine:%d",line);
	    return(-1);//Early end-of-line or not well-formatted
	    }
	switch(c){
	    case '\''://This will be a character
		c=fgetc_line(f);
#ifdef debug
		printf("Readed2:%c",c);
#endif
		if(feof(f))
		    return(-1);//Early file-end
		if((ch=fgetc_line(f))!='\'')//Not well-coded
		    return(-1);
#ifdef debug
		printf("readed3:%c",ch);
#endif
		fputc(c,d);//Writing out the data
#ifdef debug
		printf("writed:'%c'",c);
#endif
		i++;//We have one more data
		c=fgetc_line(f);
		break;
	    case '\"'://This will be a string
		c=fgetc_line(f);
#ifdef debug
		printf("readed4:%c",c);
#endif
		if(feof(f))
		    return(-1);//Early file-end
		while((c!='\"')&(c!='\n')&(c!='\r')&(!feof(f))){//Until the end
		    if((c=='\n')|(c=='\r'))
			return(-1);//Not well-coded
		    if((c!='\"')){
			fputc(c,d);
#ifdef debug
			printf("writed:'%c'",c);
#endif
			i++;
			c=fgetc_line(f);
#ifdef debug
			printf("readed5:%c",c);
#endif
			if(feof(f))
			    return(-1);//Early file-end
			}
		    }
		c=fgetc_line(f);
		break;
	    case ';'://This is a comment? Not well-coded?
	    case '\n'://This is the end of the line
	    case '\r'://This is the end of the line
		goto end_of_function;//:-S
//		return(i);
		break;
	    default://This is possibly a number
		j=0;
		s[0]=c;
		while(((!whitespace(c))&(c!=','))&(!feof(f))){
		    j++;
		    c=fgetc_line(f);
		    s[j]=c;
#ifdef debug
    		    printf("readed6:'%c'",c);
#endif
		    }
		if(feof(f))
		    return(-1);//Early end of file
		s[j]='\0';
		j=atoll(s);
#ifdef debug
    		    printf("\nreaded6 number:\"%lld\",'%s', till now:%d\n",j,s,i);
#endif

		do{//little endian
		    ch=j%256;
		    fputc(ch,d);
#ifdef debug
		    printf("writed:'%d',bytes:%d",ch,i);
#endif
		    i++;
		    j=j/256;
		}while(j!=0);
	}
	while((whitespace(c))&((c!='\n')&(c!='\r'))&(!feof(f)))
	    c=fgetc_line(f);
#ifdef debug
	    printf("Readed7:'%c'",c);
#endif
	switch(c){
	    case ';'://This is comment? Not well-coded?
	    case '\n':
	    case '\r'://End of line..
//		line++;
		goto end_of_function;//:-S
//		return(i);
		break;
	    case ' '://Next item
	    case '\t'://Next item
	    case ','://Next item
		c=fgetc_line(f);
#ifdef debug
		printf("%c",c);
#endif
		break;
	    default:
		return(-1);//Something not well...
	}
    }
    
    return(-1);
    end_of_function:
//    while(i%(wordsize/8)!=0){
//    while(i%w!=0){
    while(i%4!=0){
	fputc(0,d);
	i++;
	}

    return i;
}

#undef debug
//#define debug
long readconst(FILE * f){//Recognizing dec,hex,oct,bin numbers!!!,
			//and writing to .data
    int i;//Var for reading the string
    long j=-1;//The readed consant
    char s[15];//TODO!!!!
    int ch;
    char c;//the next character in f
    int k;//altalanos ciklusvaltozo
    c=fgetc_line(f);
#ifdef debug
    printf("Readed0:%c",c);
#endif
    if(feof(f))
        return(-1);//Early file-end
//    while(!feof(f)){
	while(((c==' ')|(c=='\t'))&(!feof(f))){
	    c=fgetc_line(f);
#ifdef debug
	    printf("Readed1:%c",c);
#endif
	    }
#ifdef debug
	printf("\t First readed char:'%c',%d\n",c,c);
#endif
	if(feof(f))
	    return(-1);//Early file-end
	if(((c>'9')|(c<'0'))&((c!='\'')&(c!='\"')&(c!=','))){
	    printf("Need number after this directive\nLine:%d",line);
	    return(-1);//Early end-of-line or not well-formatted
	    }
	switch(c){
	    case ';'://This is a comment? Not well-coded?
	    case '\n'://This is the end of the line
	    case '\r'://This is the end of the line
		goto end_of_function;//:-S
//		return(i);
		break;
	    default://This is possibly a number
		i=0;
		s[0]=c;
		while(((!whitespace(c))&(c!=','))&(!feof(f))){
		    i++;
		    c=fgetc_line(f);
		    s[i]=c;
#ifdef debug
    		    printf("readed6:'%c'",c);
#endif
		    }
		if(feof(f))
		    return(-1);//Early end of file
		s[i]='\0';
		j=atoll(s);
#ifdef debug
    		    printf("\nreaded6 number:\"%ld\",'%s'\n",j,s);
#endif

	}
//    }
    end_of_function:
    return j;
}
#undef debug
//#define debug
int directive(char * s,FILE * f,FILE * d){
    int i=0,j=0,k,l;
    while((strcmp(s,dire[i])!=0)&(i<MAXDIR)){//Looking for the instruction
#ifdef debug
//	printf("%s:%s\n",s,dire[i]);
#endif
	i++;}
    if(i==MAXDIR){
	printf("Unknown directive:%s\nLine:%d",s,line);
	return(-5);//Unknown instruction
	}
#ifdef debug
    printf("Directive recognized:\n\t%s,%d\nLine:%d",dire[i],i,line);
#endif
    switch(i){
	case 0://.data
		if(stackb==2)
		    stackb=1;
		if(textb==2)
		    textb=1;
		datab=2;
	    break;
	case 1://.stack
	    if(stackb){
		return(direrr(s));
	    }
	    else{
		if(datab==2)
		    datab=1;
		if(textb==2)
		    textb=1;
		stackb=2;
		if(!(stackl=readconst(f))){
		    printf("Not found size after directive .stack\n");
		    return(-1);
		    }
	    }
	    break;
	case 2://.text
		if(stackb==2)
		    stackb=1;
		if(datab==2)
		    datab=1;
		textb=2;
	    break;
	case 3://.core3 we are working with the 3d version
	    version=3;
	    break;
	case 4://.byte
	    if(datab==2){
		j=getvalue(f,d,1);
		dorg+=j*8/(wordsize);
//		dorg+=(j*8)/wordsize;
//		if((j*8)%wordsize!=0)
//		    dorg++;
		}
	    else j=-5;
	    break;
	case 5://.word
	    if(datab==2){
		j=getvalue(f,d,2);
		dorg+=j*16/(wordsize);
//		dorg+=(j*16)/wordsize;
//		if((j*16)%wordsize!=0)
//		    dorg++;
		}
	    else j=-5;
	    break;
	case 6://.dword
	    if(datab==2){
		j=getvalue(f,d,4);
printf("\t%d\n",j);
		dorg+=j*32/(wordsize);
//		dorg+=(j*32)/wordsize;
//		if((j*32)%wordsize!=0)
//		    dorg++;
		}
	    else j=-5;
	    break;
	case 7://.qword
	    if(datab==2){
		j=getvalue(f,d,8);
printf("\t%d\n",j);
		dorg+=j*64/(wordsize);
//		dorg+=(j*64)/wordsize;
		}
	    else j=-5;
	    break;
	case 8://.ascii we will using one character per word
	    if(datab==2){
		dorg+=getvalue(f,d,1)*8/(wordsize);
		}
	    else j=-5;
	    break;
	case 9://.asciiz we will using one character per word
	    if(datab==2){//!!bug, end of the string&dorg
		dorg+=(getvalue(f,d,1)+1)*8/(wordsize);
		for(k=0;k<(wordsize/8.0);k++)
		    fputc('0',d);
		//dorg++;
		}
	    else j=-5;
	    break;
	case 10://.space in byte
	    if(datab==2){
		j=readconst(f);
		for(k=0;k<j;k++)
		    fputc('0',d);
		dorg+=(j*8)/wordsize;
		if((j*8)%wordsize!=0)
		    dorg++;
		while((j*8)%wordsize!=0){
		    fputc(0,d);
		    j++;
		    }
		}
	    else j=-5;//Not in the data section
	    break;
	case 11://.core2 we are working with the 2nd version
	    version=2;
	    break;
	default:
	    return(-5);//Something error
    }
    if(j<0){
#ifdef debug
        printf("Wrong place of data.\nLine:%d",line);
#endif
	return(j);
    }
    return(i);
}

#undef debug

//#define debug
int readcmd(FILE *f,FILE *d,FILE *t){
    char cmd[31];//TODO!!
    int j;//The register part
    int i=0;//The instruction part
#ifdef debugg
printf("\t\ttorg:%d,dorg:%d\n",torg,dorg);
#endif

    if(feof(f))return(-10);
    cmd[0]=readchar(f);
    while(!whitespace(cmd[i])){
	i++;
	cmd[i]=fgetc_line(f);
    if(feof(f))return(-10);
    }
    if(cmd[i]!=':')
	cmd[i]='\0';
    else
	cmd[i+1]='\0';
    if(cmd[0]=='.'){//This is compiler-directive
	if(directive(cmd,f,d)<0){
#ifdef debug
	    printf("Directive:'%s'\n",cmd);
#endif
	    return(-2);
	    }
	return(-1);
	}
    if(cmd[i]==':'){
    cmd[i]=0;
#ifdef debug
    printf("Label:'%s',at %d\n",cmd,torg);
#endif
	//Searching for a pre-defined label
	i=findlabel(cmd);
	if(i<0)
	    newlabel(cmd);
	addlabel(cmd);//Setting the address of the label
	return(-3);}//This is label
#ifdef debug
    printf("\tcmd:'%s'\n",cmd);
#endif
    i=0;
switch(version){
case 1:{//version==1
    while((strcmp(cmd,cmds[i])!=0)&(i<MAXCMD)){//Looking for the instruction
#ifdef debug
    printf("%s:%s\n",cmd,cmds[i]);
#endif
	i++;}
    }
case 2:{//version==2
    while((strcmp(cmd,cmds2[i])!=0)&(i<MAXCMD)){//Looking for the instruction
#ifdef debug
    printf("%s:%s\n",cmd,cmds2[i]);
#endif
	i++;}
    }
case 3:{//version==3
    while((strcmp(cmd,cmds3[i])!=0)&(i<MAXCMD)){//Looking for the instruction
#ifdef debug
    printf("%s:%s\n",cmd,cmds3[i]);
#endif
	i++;}
    }
}
    if(i==MAXCMD){
	printf("Unknown instruction:%s\nLine:%d\n",cmd,line);
	return(-5);//Unknown instruction
	}
#ifdef debug
    printf("Instruction recognized:\n\t%s ",cmds[i]);
#endif
    if(textb!=2){
//Only for ver1!!!
#ifdef debug
        printf("Found instruction not in the text section:%s!\nLine:%d\n",cmds[i],line);
#endif
	return(-5);
    }
//	instruction in 'i', register or label in 'j'
    //If the instruction is cxx, we need to read the constant
if(((version==1)&((i==0) | (i==1)))|((version>2)&((i==1) | (i==3) | (i==4)))){
    torg++;
    j=readconst(f);
    fprintf(t,"%c",(i<<4)+j);
#ifdef debug
    printf("Writed instruction:%s\n",cmd);
#endif
    }
else {
j=readreg(f);;
if (j==-1)return -5;//There was an error evaluating the parameter
if(version>2){
    if(j<0){
//#ifdef debug
    printf("Found label as parameter at line %d: turning the instruction to macro\n",line);
//#endif
    }
    torg++;
//Writing the coded instruction to the .text section
    if(j>=0){
	fprintf(t,"%c",(i<<4)+j);
#ifdef debug
    printf("Writed instruction:%s\n",cmd);
#endif
	}
    else{
	fprintf(t,"%c",i<<4);//TODO!!! The macros
#ifdef debug
    printf("Writed instruction:%s\n",cmd);
#endif
	}
}
else{
    if(j<0)
	return(-5);
    else
	fprintf(t,"%c",(i<<4)+j);
}
}
#ifdef debug
    printf("torg:%d,dorg:%d\n",torg,dorg);
#endif
    return(i);
};
//Egyszeres forditas:
//	a cimkek tablazatat a .data elejere kiirjuk, igy nem valtozik
//	a kod a cimkektol fuggoen
//	cimkere valo hivatkozaskor nem a cimke cimet olvassuk be, hanem
//	a .data elejenek cimehez adjuk hozza a cimke sorszamat, onnan
//	olvassuk be a cimke cimet->athelyezhetoek akar futas kozben is!!!
//	(feltetel: minden olvasas es iras elott be kell olvasni a cimet,
//	valamint/illetve csak kooperativ taszk eseten, mert preemptiv
//	eseten a betoltes utan is athelyezodhet a kod-vagy csak bizonyos
//	rendszerhivas eseten helyezodjon at)
//	ha nem athelyezheto, gyorsabb, mert kevesebb a konstans
//Jo lenne az elf formatum:
//	kovetelmeny a 32 bit
#undef debug
#define debug
int main(int arg,char **argv){
    FILE * f;
    FILE * d;//Data section,temporary
    FILE * t;//Text section,temporary
    FILE * o;//Output file
    int cer;
    int i;
    int m=0;//Is the __main defined?
    char chartmp;
    if(arg==1){
	htu(argv[0]);
	return(0);
    }

    if(arg>=2){//There's an input file
	if(!(f=fopen(argv[1],"ro"))){
	    printf("Error opening the input file\n");
	    return(-1);
	}
    }

    if(arg==3){//There's an output file
	if(!(o=fopen(argv[2],"w+"))){
	    printf("Error opening the output file '%s\n'\n",argv[2]);
	    return(-1);
	}
    }else
	if(!(o=fopen("out","w+"))){
	    printf("Error opening the output file 'out'\n");
	    return(-1);
	}

    d=tmpfile();//Temp file to store the informations about the .data section
    t=tmpfile();//Temp file to store the informations about the .text section
//Init de SP->do at init of the task    
//newlabel("SP");
//datab=2;
//addlabel("SP");
    while(!feof(f)){
#ifdef debug
//    	printf("readcmd\n");
#endif
	cer=readcmd(f,d,t);
	if(cer==-5){
	    printf("Unknown instruction or register at line %d\n",line);

	    fclose(d);
	    fclose(t);
	    fclose(f);
	    fclose(o);
	    return(-1);
	}
	if(cer==-2){
	    printf("Wrong utilisation of directive at line %d\n",line);

	    fclose(t);
	    fclose(f);
	    fclose(o);
	    return(-1);
	}

    }
//Creating the output file
//Writing out the version of the used instruction set
	fprintf(o,"%c%c%c%c",(version & 0xFF),
			(version>>8)& 0xFF,
			(version>>16)& 0xFF,
			(version>>24));//Little endian
//Address of the __main function, verifing the labels
for(i=0;i<maxlab;i++){//->while
    if(strcmp(lab[i].name,"__main")==0){
#ifdef debug
	printf("__main found:%d::%d,%d\n",lab[i].address,(lab[i].address & 0xFF),lab[i].address>>8);
#endif
//Big or little endian?
//	fprintf(o,"%c%c",(lab[i].address & 0xFF),lab[i].address>>8);//Little
//	fprintf(o,"%c%c",lab[i].address>>8,(lab[i].address & 255));//Big
//	//Big or little endian?32 bit
	fprintf(o,"%c%c%c%c",(lab[i].address & 0xFF),
			(lab[i].address>>8)& 0xFF,
			(lab[i].address>>16)& 0xFF,
			(lab[i].address>>24));//Little
////	fprintf(o,"%c%c%c%c",lab[i].address>>24,
//			(lab[i].address>>16)& 0xFF,
//			(lab[i].address>>8)& 0xFF,
//			(lab[i].address & 255));//Big
	m=1;
	}

    if(lab[i].label_type==0){
	printf("Error:\nThe following label is not defined but used:%s\n"
	    ,lab[i].name);
	fclose(d);
	fclose(t);
	fclose(f);
	fclose(o);
	remove("out");
	return(-1);
	}
#ifdef debug
    else{
	printf("Label:%s,position at %d\n",lab[i].name,lab[i].address);
	}
#endif
    }

if(m==0)//If there's no main function, we begin at the start of the code
//    fprintf(o,"%c%c",0,0);//16 bit address
    fprintf(o,"%c%c%c%c",0,0,0,0);//32 bit address

#ifdef debug
    printf("Length of the .stack section:%d\n",stackl);
#endif
//Writing the length of the stack section
	fprintf(o,"%c%c%c%c",(stackl & 0xFF),
			(stackl>>8)& 0xFF,
			(stackl>>16)& 0xFF,
			(stackl>>24));//Little endian

//Writing the length of the next (.data) section
//That's equ:dorg+no of labels!
dorg+=maxlab;
#ifdef debug
    printf("Length of the .data section:%d\n",dorg);
#endif
	fprintf(o,"%c%c%c%c",(dorg & 0xFF),
			(dorg>>8)& 0xFF,
			(dorg>>16)& 0xFF,
			(dorg>>24));//Little endian

//Writing out the labels
for(i=0;i<maxlab;i++){
    if(lab[i].label_type==1)
	lab[i].address+=maxlab;
//    lab[i].address+=1;//+address of the stack at runtime->deleted, done at ini
	//Big or little endian?
//	fprintf(o,"%c%c",(lab[i].address & 0xFF),lab[i].address>>8);//Little
//	fprintf(o,"%c%c",lab[i].address>>8,(lab[i].address & 255));//Big
//	//Big or little endian?32 bit
	fprintf(o,"%c%c%c%c",(lab[i].address & 0xFF),
			(lab[i].address>>8)& 0xFF,
			(lab[i].address>>16)& 0xFF,
			(lab[i].address>>24));//Little
	printf("%d:%d,%d,%d,%d;%d\n",i,(lab[i].address & 0xFF),
			(lab[i].address>>8)& 0xFF,
			(lab[i].address>>16)& 0xFF,
			(lab[i].address>>24),lab[i].address);//Little
////	fprintf(o,"%c%c%c%c",lab[i].address>>24,
//			(lab[i].address>>16)& 0xFF,
//			(lab[i].address>>8)& 0xFF,
//			(lab[i].address & 255));//Big
    }

rewind(d);//Writing the rest of the data section
while(!feof(d)){
    chartmp=fgetc(d);
    if(!feof(d))
	fputc(chartmp,o);
	}
#ifdef debug
    printf("Length of the .text section:%d\n",torg);
#endif
//Writing the length of the next (.text) section
	fprintf(o,"%c%c%c%c",(torg & 0xFF),
			(torg>>8)& 0xFF,
			(torg>>16)& 0xFF,
			(torg>>24));//Little endian

	printf("%d,%d,%d,%d\n",(torg & 0xFF),
			(torg>>8)& 0xFF,
			(torg>>16)& 0xFF,
			(torg>>24));//Little endian

rewind(t);//Writing the text section
while(!feof(t)){
    chartmp=fgetc(t);
    if(!feof(t))
	fputc(chartmp,o);
	}
//while(!feof(t))->to del
//    fputc(fgetc(t),o);

    fclose(d);
    fclose(t);
    fclose(f);
    fclose(o);
    return 0;
}
