//************************************************
//
//		Small-C Compiler 
// 
//		by Ron Cain 
// 
//************************************************

// with minor mods by RDK 
#define BANNER  " <><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>"
#define VERSION " <><><><><>   CP/M Large String Space Version   <><><><><>"
#define AUTHOR  " <><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>"
#define TLINE   " <><><><><><><><><><><><><><>X<><><><><><><><><><><><><><>"

/*	Define system dependent parameters	*/
/*	Stand-alone definitions			*/
/* INCLUDE THE LIBRARY TO COMPILE THE COMPILER (RDK) */
/* #include smallc.lib */ /* small-c library included in source now */
/* IN DOS USE THE SMALL-C OBJ LIBRARY RATHER THAN IN-LINE ASSEMBLER */
#define NULL 0
#define eol 10 /* was 13 */

#include "stdio.h"  /* was <stdio.h> */

/*	Define the symbol table parameters	*/
#define	symsiz		16
#define	symtbsz		5760
#define numglbs 	300
#define	startglb 	symtab
#define	endglb		startglb+numglbs*symsiz
#define	startloc 	endglb+symsiz
#define	endloc		symtab+symtbsz-symsiz

/*	Define symbol table entry format	*/
#define	name		0
#define	ident		9
#define	type		10
#define	storage		11
#define	offset		12
#define initptr		14

/*	System wide name size (for symbols)	*/
#define	namesize 	9
#define namemax  	8

/*	Define possible entries for "ident"	*/
#define	variable	1
#define	array		2
#define	pointer		3
#define	function	4

/*	Define possible entries for "type"	*/
#define	cchar		1
#define	cint		2
#define cport		3 

/*	Define possible entries for "storage"	*/
#define	statik		1
#define	stkloc		2

/*	Define the "while" statement queue	*/
#define	wqtabsz		300
#define	wqsiz		4
#define	wqmax		wq+wqtabsz-wqsiz

/*	Define entry offsets in while queue	*/
#define	wqsym		0
#define	wqsp		1
#define	wqloop		2
#define	wqlab		3

/*	Define the literal pool			*/
#define	litabsz		8000
#define	litmax		litabsz-1

/*	Define the input line			*/
#define	linesize 	256
#define	linemax		linesize-1
#define	mpmax		linemax

/*	Define the macro (define) pool		*/
#define	macqsize 	3000
#define	macmax		macqsize-1

/*	Define statement types (tokens)		*/
#define	stif		1
#define	stwhile		2
#define	streturn 	3
#define	stbreak		4
#define	stcont		5
#define	stasm		6
#define	stexp		7

/* Define how to carve up a name too long for the assembler */
#define asmpref		7
#define asmsuff		7

// define the global variable init values que size 
#define initqsz		8192

/*	Now reserve some storage words		*/
char	symtab[symtbsz];	/* symbol table */
char	*glbptr,*locptr;	/* ptrs to next entries */

int		wq[wqtabsz];		/* while queue */
int		*wqptr;				/* ptr to next entry */

char	litq[litabsz];		/* literal pool */
int		litptr;				/* ptr to next entry */

char	macq[macqsize];		/* macro string buffer */
int		macptr;				/* and its index */

char	inittbq[initqsz];	// init value buffer 
int		inittbptr;			// and its index 

char	line[linesize];		/* parsing buffer */
char	mline[linesize];	/* temp macro buffer */
int		lptr,mptr;			/* ptrs into each */

/*	Misc storage	*/
int	nxtlab,		/* next avail label # */
	litlab,		/* label # assigned to literal pool */
	Zsp,		/* compiler relative stk ptr */
	argstk,		/* function arg sp */
	ncmp,		/* # open compound statements */
	errcnt,		/* # errors in compilation */
	errstop,	/* stop on error			gtf 7/17/80 */
	eof,		/* set non-zero on final input eof */
	input,		/* iob # for input file */
	output,		/* iob # for output file (if any) */
	outputv,	/* output valid flag */
	input2,		/* iob # for "include" file */
	glbflag,	/* non-zero if internal globals */
	ctext,		/* non-zero to intermix c-source */
	cmode,		/* non-zero while parsing c-code */
			/* zero when passing assembly code */
	lastst,		/* last executed statement type */
	mainflg,	/* output is to be first asm file	gtf 4/9/80 */
	saveout,	/* holds output ptr when diverted to console	   */
			/*					gtf 7/16/80 */
	fnstart,	/* line# of start of current fn.	gtf 7/2/80 */
	lineno,		/* line# in current file		gtf 7/2/80 */
	infunc,		/* "inside function" flag		gtf 7/2/80 */
	savestart,	/* copy of fnstart "	"		gtf 7/16/80 */
	saveline,	/* copy of lineno  "	"		gtf 7/16/80 */
	saveinfn;	/* copy of infunc  "	"		gtf 7/16/80 */

char   *currfn,		/* ptr to symtab entry for current fn.	gtf 7/17/80 */
       *savecurr;	/* copy of currfn for #include		gtf 7/17/80 */
char	*cptr;		/* work ptr to any char buffer */
int	*iptr;		/* work ptr to any int buffer */

// interactive mode flag 
int intmode;
// pointer array to input files list from argv[] 
#define MAXINFILES		64
char *infiles[MAXINFILES];
int filesnum, filesidx;
// initial stack pointer value 
int stackptr;

/*	>>>>> start cc1 <<<<<<		*/

/*					*/
/*	Compiler begins execution here	*/
/*					*/
void main(int argc, char *argv[])
{
int argi, phelp;
	
	glbptr=startglb;	/* clear global symbols */
	locptr=startloc;	/* clear local symbols */
	wqptr=wq;0;		/* clear while queue */
	macptr=0;		/* clear the macro pool */
	litptr=0;		/* clear literal pool */
  	Zsp =0;			/* stack ptr (relative) */
	errcnt=0;		/* no errors */
	errstop=0;		/* keep going after an error		gtf 7/17/80 */
	eof=0;			/* not eof yet */
	input=0;		/* no input file */
	input2=0;		/* or include file */
	output=0;		/* no open units */
	outputv=0;		/* output is not valid */
	saveout=0;		/* no diverted output */
	ncmp=0;			/* no open compound states */
	lastst=0;		/* no last statement yet */
	mainflg=0;		/* not first file to asm 		gtf 4/9/80 */
	fnstart=0;		/* current "function" started at line 0 gtf 7/2/80 */
	lineno=0;		/* no lines read from file		gtf 7/2/80 */
	infunc=0;		/* not in function now			gtf 7/2/80 */
	currfn=NULL;	/* no function yet			gtf 7/2/80 */
	cmode=1;		/* enable preprocessing */
	stackptr=0;		/* default value of stack pointer */
	inittbptr=0;	// clear pointer to init array 
	
	intmode = 1;	// default mode is interactive mode 
	filesnum = 0;	// no input files for now 
	filesidx = 0;

	// print original banner 
	printf("\n");
	printf(" <><><><><><><><><><><><><><>X<><><><><><><><><><><><><><>\n");
	printf(" <><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>\n");
	printf(" <><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>\n");
	printf(" <><><><><>   CP/M Large String Space Version   <><><><><>\n");
	printf(" <><><><><><><><><><><><><><>X<><><><><><><><><><><><><><>\n");
		
	// print adapted banner and usage 
	printf("\n");
	printf(" <><><><><><><><><><><><><><>X<><><><><><><><><><><><><><>\n");
	printf(" <><><>  Small-C adapted for embedded systems by  <><><><>\n");
	printf(" <><><><><><><><><>  Moti  Litochevski  <><><><><><><><><>\n");
	printf(" <><><><><><> Version 0.1 (February 20, 2012) <><><><><><>\n");
	printf(" <><><><><><><><><><><><><><>X<><><><><><><><><><><><><><>\n");
	printf("\n");
	// check if command line options where specified 
	if (argc <= 1) {
		printf(" command line mode usage:\n");
		printf("      c80 -s<hexvalue> -o<filename> <input files>\n");
		printf(" options:\n");
		printf("      -s<hexvalue>   Initial stack pointer value in hex value.\n");
		printf("                     Example: -s800 will init the stack pointer\n");
		printf("                     to 0x800.\n");
		printf("      -o<filename>   Compiler output filename including extension.\n");
		printf(" \n");
	}
	
	// start from the first valid argument 
	argi = 1;
	phelp = 0;
    // loop through input options 
    while (argi < argc) {
	    // copy pointer of the current option to the work buffer 
	    cptr = argv[argi];
	    // loop through input options 
	    if (cptr[0] == '-') {
		    // compiler options 
		    if (cptr[1] == 's') {
			    // stack pointer address value 
			    sscanf(&cptr[2], "%x", &stackptr);
			} else if (cptr[1] == 'o') {
				// copy the output filename to the line 
				strcpy(line, &cptr[2]);
				// open output file 
				openout(0);
			} else if ((cptr[1] == 'h') | (cptr[1] == '?')) {
				// sign that only help should be printed 
				phelp = 1;
		    } else {
			    printf("error: illegal option.\n");
		    }
		} else {
			// after all other options the list of input files is given and 
			// compiler is operated in non-interactive mode 
			intmode = 0;
			
			// copy the input files names pointers to the local array 
			for (filesnum=0; (argi < argc) && (filesnum < MAXINFILES); filesnum++) {
				infiles[filesnum] = argv[argi];
				argi++;
			}
		}   
		// update argument index 
		argi++;
    }
    
    // check if compiler should be started 
    if (!phelp) {
	    // announce interactive mode compiler 
		printf(" Starting compiler in interactive mode.\n\n");
		// compiler body 
		ask();			/* get user options */
		if (outputv == 0) openout(1);		/* get an output file */
		openin();		/* and initial input file */
		header();		/* intro code */
		parse(); 		/* process ALL input */
		dumplits();		/* then dump literal pool */
		dumpglbs();		/* and all static memory */
		trailer();		/* follow-up code */
		closeout();		/* close the output (if any) */
		errorsummary();		/* summarize errors (on console!) */
	}
	return;			/* then exit to system */
}

/*					*/
/*	Abort compilation		*/
/*		gtf 7/17/80		*/
zabort()
{
	if(input2)
		endinclude();
	if(input)
		fclose(input);
	closeout();
	toconsole();
	pl("Compilation aborted.");  nl();
	exit();
/* end zabort */}

/*					*/
/*	Process all input text		*/
/*					*/
/* At this level, only static declarations, */
/*	defines, includes, and function */
/*	definitions are legal...	*/
parse()
{
	while (eof==0)		/* do until no more input */
	{
		if(amatch("char",4)){declglb(cchar);ns();}
		else if(amatch("int",3)){declglb(cint);ns();}
		else if(amatch("port",4)){declglb(cport);ns();}
		else if(match("#asm"))doasm();
		else if(match("#include"))doinclude();
		else if(match("#define"))addmac();
		else newfunc();
		blanks();	/* force eof if pending */
	}
}
/*					*/
/*	Dump the literal pool		*/
/*					*/
dumplits()
	{int j,k;
	if (litptr==0) return;	/* if nothing there, exit...*/
	printlabel(litlab);col();nl(); /* print literal label */
	k=0;			/* init an index... */
	while (k<litptr)	/* 	to loop with */
		{defbyte();	/* pseudo-op to define byte */
		j=10;		/* max bytes per line */
		while(j--)
			{outdec((litq[k++]&127));
			if ((j==0) | (k>=litptr))
				{nl();		/* need <cr> */
				break;
				}
			outbyte(',');	/* separate bytes */
			}
		}
	}
/*					*/
/*	Dump all static variables	*/
/*					*/
dumpglbs()
{
int j,dptr,idx;

	if (glbflag==0) return;	/* don't if user said no */
	cptr=startglb;
	while (cptr<glbptr) {
		if ((cptr[ident]!=function) && (cptr[type]!=cport)) {
			// do if anything but function or port 
			// output name as label ... 
			outname(cptr);col();nl();
			// calculate number of bytes 
			j = ((cptr[offset]&255) + ((cptr[offset+1]&255)<<8));
			if ((cptr[type]==cint) | (cptr[ident]==pointer)) 
				j=j+j;	// 2 bytes for integer values 
			// check if the global has an init value 
			dptr = ((cptr[initptr]&255) + ((cptr[initptr+1]&255)<<8));
			// the value below represent the -1 value 
			if (dptr==0xffff) {
				// no init value, use original storage definition 
				// define storage 
				defstorage();
				outdec(j);	/* need that many */
				nl();
			} 
			else {
				// define the data section 
				defbyte();
				// loop through init value 
				idx=1;
				while (j--) {
					// write the next byte 
					outdec(inittbq[dptr++]);
					if ((j==0) | (dptr>=inittbptr)) {
						nl();		/* need <cr> */
						break;
					}
					// every 10 values reopen the line 
					if (idx++ == 10) {
						// add <cr> and restart byte definition 
						nl(); 
						defbyte();
						idx=1;
					} else 
						// separate bytes 
						outbyte(',');	
				}
			}
		}
		cptr=cptr+symsiz;
	}
}
/*					*/
/*	Report errors for user		*/
/*					*/
errorsummary()
{
	/* see if anything left hanging... */
	if (ncmp) error("missing closing bracket");
		/* open compound statement ... */
	printf("\nThere were %d errors in compilation.\n\n", errcnt);
}

/* Get options from user */
ask()
{
int k,num[1];

	kill();			/* clear input line */
	// by default enabling C text in the output file in form of comments (for clarity) 
	ctext=1;	/* user said yes */
	// by default assuming all files are compiled together 
	glbflag=1;	/* define globals */
	mainflg=1;	/* first file to assembler */
	nxtlab =0;	/* start numbers at lowest possible */
	// compiler does noy pause on errors 
	errstop=0;
	
	litlab=getlabel();	/* first label=literal pool */ 
	kill();			/* erase line */
}

/*					*/
/*	Get output filename		*/
/*					*/
openout(char flag)
{
	if (flag) {
		kill();			/* erase line */
		output=0;		/* start with none */
		pl("Output filename? "); /* ask...*/
		gets(line);	/* get a filename */
	}
	if(ch()==0)return;	/* none given... */
	/* if given, open */ 
	if((output=fopen(line,"w"))==NULL) {
		output=0;	/* can't open */
		error("Open failure!");
	} else 
		outputv = 1;
	kill();			/* erase line */
}
/*					*/
/*	Get (next) input file		*/
/*					*/
openin()
{
	input=0;		/* none to start with */
	while (input==0) {	/* any above 1 allowed */
		kill();		/* clear line */
		// check if we are using interactive mode or not 
		if (intmode) {
			// use the old style input file from the user 
			if (eof) break;	/* if user said none */
			pl("Input filename? ");
			gets(line);	/* get a name */
			if (ch()==0)
				{eof=1;break;} /* none given... */
		} else {
			// copy the file names from the name array 
			if (filesidx < filesnum) {
				strcpy(line, infiles[filesidx]);
				printf("Processing Input file %d: %s\n", filesidx, line);
				filesidx++;
			} else {
				// no more files 
				eof=1; 
				break;
			}
		}
		
		if ((input=fopen(line,"r"))!=NULL)
			newfile();			/* gtf 7/16/80 */
		else {	
			input=0;	/* can't open it */
			pl("Open failure");
		}
	}
	kill();		/* erase line */
}

/*					*/
/*	Reset line count, etc.		*/
/*			gtf 7/16/80	*/
newfile()
{
	lineno  = 0;	/* no lines read */
	fnstart = 0;	/* no fn. start yet. */
	currfn  = NULL;	/* because no fn. yet */
	infunc  = 0;	/* therefore not in fn. */
/* end newfile */}

/*					*/
/*	Open an include file		*/
/*					*/
doinclude()
{
	blanks();	/* skip over to name */

	toconsole();					/* gtf 7/16/80 */
	outstr("#include "); outstr(line+lptr); nl();
	tofile();

	if(input2)					/* gtf 7/16/80 */
		error("Cannot nest include files");
	else if ((input2=fopen(line+lptr,"r"))==NULL) {
		input2=0;
		error("Open failure on include file");
	} 
	else {	
		saveline = lineno;
		savecurr = currfn;
		saveinfn = infunc;
		savestart= fnstart;
		newfile();
	}
	kill();		/* clear rest of line */
			/* so next read will come from */
			/* new file (if open */
}

/*					*/
/*	Close an include file		*/
/*			gtf 7/16/80	*/
endinclude()
{
	toconsole();
	outstr("#end include"); nl();
	tofile();

	input2  = 0;
	lineno  = saveline;
	currfn  = savecurr;
	infunc  = saveinfn;
	fnstart = savestart;
/* end endinclude */}

/*					*/
/*	Close the output file		*/
/*					*/
closeout()
{
	tofile();	/* if diverted, return to file */
	if(output)fclose(output); /* if open, close it */
	output=0;		/* mark as closed */
}
/*					*/
/*	Declare a static variable	*/
/*	  (i.e. define for use)		*/
/*					*/
/* makes an entry in the symbol table so subsequent */
/*  references can call symbol by name	*/
declglb(typ)		/* typ is cchar or cint or cport (added by Moti Litchevski) */
	int typ;
{	
int k,j,iptr,idx,num[1];
char sname[namesize];

	while (1) {
		while (1) {
			if(endst())return;	/* do line */
			k=1;		/* assume 1 element */
			if(match("*"))	/* pointer ? */
				j=pointer;	/* yes */
			else 
				j=variable; /* no */
			
			// added by Moti Litochevski 
			if (match("(")) {
				// make sure this option is only used for port definition 
				if (typ != cport)
					error("port address definition is only used for port type");
				// get port address 
				k=portadr(); 
				k=k&0xff;
			} else if (typ == cport) {
				error("port definition syntax error, need to define port address in brackets");
			}
			
			if (symname(sname)==0) /* name ok? */
				illname(); /* no... */
			if(findglb(sname)) /* already there? */
				multidef(sname);
			if (match("[")) {	/* array? */
				if (typ==cport) error("port cannot be defined as an array");
				k=needsub();	/* get size */
				if(k)j=array;	/* !0=array */
				else j=pointer; /* 0=ptr */
			}
			
			// check if the declared global has a default value 
			if (match("=")) {
				// check if variable type supports init 
				if ((typ!=cchar) & (typ!=cint))
					error("variable type does not support init value");
				
				// set the init pointer to the current init pointer 
				iptr=inittbptr;
				idx=0;
					
				// new defined variable has a default init value 
				// check if the variable is defined as string, list of values {} or a 
				// single value
				if (match("\"")) {
					// init value is defined as a string 
					// copy the string values to the init buffer 
					while (idx++ < k) {
						// check if new value is valid 
						if ((ch() != '"') & (ch() != 0))
							inittbq[inittbptr++] = gch();
						else 
							inittbq[inittbptr++] = 0;
						
						// check that init buffer is full 
						if (inittbptr == initqsz) {
							// clear the variable init pointer and print error message 
							iptr=0xffff;
							error("init buffer is full, variable will not be initialized");
							// sign that init is done 
							idx=k;
						}
					}
					// look for matching quote mark 
					if (match("\"")==0) {
						error("end of string expected");
					}
				}
				else if (match("{")) {
					// init value is defined as a list of values 
					// copy the list of values to the init buffer 
					while (idx++ < k) {
						// check if new value is valid 
						if ((ch() != '}') & (ch() != 0)) {
							// make sure that the next value is a number 
							if (!number(num) & !pstr(num))
								error("could not find valid value in initialization list");
						}
						else 
							// use zero value as init 
							num[0]=0;
						
						// save the values according to array type 
						if (typ==cint) {
							inittbq[inittbptr++] = (char)(num[0]&255);
							inittbq[inittbptr++] = (char)((num[0]>>8)&255);
						}
						else 
							inittbq[inittbptr++] = (char)(num[0]&255);
						
						// check that init buffer is full 
						if (inittbptr == initqsz) {
							// clear the variable init pointer and print error message 
							iptr=0xffff;
							error("init buffer is full, variable will not be initialized");
							// sign that init is done 
							idx=k;
						}
						// remove comma if it is there 
						match(",");
					}
					// look for ending brackets 
					if (match("}")==0) {
						error("end of initialization list expected");
					}
				}
				else {
					// expecting a single input value 
					if (!number(num) & !pstr(num))
						error("could not find initialization value");
						
					// save the values according to variable type 
					if (typ==cint) {
						inittbq[inittbptr++] = (char)(num[0]&255);
						inittbq[inittbptr++] = (char)((num[0]>>8)&255);
					}
					else 
						inittbq[inittbptr++] = (char)(num[0]&255);
					// update index 
					idx=1;
					
					// init to end of array is more than one 
					while (idx++ < k) {
						// fill the rest of the init list with zeros 
						if (typ==cint) {
							inittbq[inittbptr++] = 0;
							inittbq[inittbptr++] = 0;
						}
						else 
							inittbq[inittbptr++] = 0;
						
						// check that init buffer is full 
						if (inittbptr == initqsz) {
							// clear the variable init pointer and print error message 
							iptr=0xffff;
							error("init buffer is full, variable will not be initialized");
							// sign that init is done 
							idx=k;
						}
					}
				}
			} else {
				// no default value point init pointer to null 
				iptr=0xffff;
			}
			// add symbol 
			addglb(sname,j,typ,k,iptr); 
			break;
		}
		if (match(",")==0) return; /* more? */
	}
}
/*					*/
/*	Declare local variables		*/
/*	(i.e. define for use)		*/
/*					*/
/* works just like "declglb" but modifies machine stack */
/*	and adds symbol table entry with appropriate */
/*	stack offset to find it again			*/
declloc(typ)		/* typ is cchar or cint */
	int typ;
	{
	int k,j;char sname[namesize];
	while(1)
		{while(1)
			{if(endst())return;
			if(match("*"))
				j=pointer;
				else j=variable;
			if (symname(sname)==0)
				illname();
			if(findloc(sname))
				multidef(sname);
			if (match("["))
				{k=needsub();
				if(k)
					{j=array;
					if(typ==cint)k=k+k;
					}
				else
					{j=pointer;
					k=2;
					}
				}
			else
				if((typ==cchar)
					&(j!=pointer))
					k=1;else k=2;
			/* change machine stack */
			Zsp=modstk(Zsp-k);
			addloc(sname,j,typ,Zsp);
			break;
			}
		if (match(",")==0) return;
		}
	}
/*	>>>>>> start of cc2 <<<<<<<<	*/

/*					*/
/*	Get required array size		*/
/*					*/
/* invoked when declared variable is followed by "[" */
/*	this routine makes subscript the absolute */
/*	size of the array. */
needsub()
{
int num[1];

	if(match("]"))return 0;	/* null size */
	if (number(num)==0)	/* go after a number */
		{error("must be constant");	/* it isn't */
		num[0]=1;		/* so force one */
		}
	if (num[0]<0)
		{error("negative size illegal");
		num[0]=(-num[0]);
		}
	needbrack("]");		/* force single dimension */
	return num[0];		/* and return size */
}
//
// get array size function changed to get a port address 
//
portadr()
{
int num[1];

	if(match(")")) {
		error("port address value must be defined");
		return 0;	/* null size */
	}
	if (number(num)==0) {	/* go after a number */
		error("port address must be constant");	/* it isn't */
		num[0]=1;		/* so force one */
	}
	if (num[0]<0) {
		error("negative port address illegal");
		num[0]=(-num[0]);
	}
	needbrack(")");		/* force single dimension */
	return num[0];		/* and return size */
}

/*					*/
/*	Begin a function		*/
/*					*/
/* Called from "parse" this routine tries to make a function */
/*	out of what follows.	*/
newfunc()
	{
	char n[namesize];	/* ptr => currfn,  gtf 7/16/80 */
	if (symname(n)==0)
		{error("illegal function or declaration");
		kill();	/* invalidate line */
		return;
		}
	fnstart=lineno;		/* remember where fn began	gtf 7/2/80 */
	infunc=1;		/* note, in function now.	gtf 7/16/80 */
	if(currfn=findglb(n))	/* already in symbol table ? */
		{if(currfn[ident]!=function)multidef(n);
			/* already variable by that name */
		else if(currfn[offset]==function)multidef(n);
			/* already function by that name */
		else currfn[offset]=function;
			/* otherwise we have what was earlier*/
			/*  assumed to be a function */
		}
	/* if not in table, define as a function now */
	else currfn=addglb(n,function,cint,function,-1);

	toconsole();					/* gtf 7/16/80 */
	outstr("====== "); outstr(currfn+name); outstr("()"); nl();
	tofile();

	/* we had better see open paren for args... */
	if(match("(")==0)error("missing open paren");
	outname(n);col();nl();	/* print function name */
	argstk=0;		/* init arg count */
	while(match(")")==0)	/* then count args */
		/* any legal name bumps arg count */
		{if(symname(n))argstk=argstk+2;
		else{error("illegal argument name");junk();}
		blanks();
		/* if not closing paren, should be comma */
		if(streq(line+lptr,")")==0)
			{if(match(",")==0)
			error("expected comma");
			}
		if(endst())break;
		}
	locptr=startloc;	/* "clear" local symbol table*/
	Zsp=0;			/* preset stack ptr */
	while(argstk)
		/* now let user declare what types of things */
		/*	those arguments were */
		{if(amatch("char",4)){getarg(cchar);ns();}
		else if(amatch("int",3)){getarg(cint);ns();}
		else{error("wrong number args");break;}
		}
	if(statement()!=streturn) /* do a statement, but if */
				/* it's a return, skip */
				/* cleaning up the stack */
		{modstk(0);
		zret();
		}
	Zsp=0;			/* reset stack ptr again */
	locptr=startloc;	/* deallocate all locals */
	infunc=0;		/* not in fn. any more		gtf 7/2/80 */
	}
/*					*/
/*	Declare argument types		*/
/*					*/
/* called from "newfunc" this routine adds an entry in the */
/*	local symbol table for each named argument */
getarg(t)		/* t = cchar or cint */
	int t;
	{
	char n[namesize],c;int j;
	while(1)
		{if(argstk==0)return;	/* no more args */
		if(match("*"))j=pointer;
			else j=variable;
		if(symname(n)==0) illname();
		if(findloc(n))multidef(n);
		if(match("["))	/* pointer ? */
		/* it is a pointer, so skip all */
		/* stuff between "[]" */
			{while(inbyte()!=']')
				if(endst())break;
			j=pointer;
			/* add entry as pointer */
			}
		addloc(n,j,t,argstk);
		argstk=argstk-2;	/* cnt down */
		if(endst())return;
		if(match(",")==0)error("expected comma");
		}
	}
/*					*/
/*	Statement parser		*/
/*					*/
/* called whenever syntax requires	*/
/*	a statement. 			 */
/*  this routine performs that statement */
/*  and returns a number telling which one */
statement()
{
        /* NOTE (RDK) --- On DOS there is no CPM function so just try */
        /* commenting it out for the first test compilation to see if */
        /* the compiler basic framework works OK in the DOS environment */
	/* if(cpm(11,0) & 1)	/* check for ctrl-C gtf 7/17/80 */
		/* if(getchar()==3) */
			/* zabort(); */

	if ((ch()==0) & (eof)) return;
	else if(amatch("char",4))
		{declloc(cchar);ns();}
	else if(amatch("int",3))
		{declloc(cint);ns();}
	else if(match("{"))compound();
	else if(amatch("if",2))
		{doif();lastst=stif;}
	else if(amatch("while",5))
		{dowhile();lastst=stwhile;}
	else if(amatch("return",6))
		{doreturn();ns();lastst=streturn;}
	else if(amatch("break",5))
		{dobreak();ns();lastst=stbreak;}
	else if(amatch("continue",8))
		{docont();ns();lastst=stcont;}
	else if(match(";"));
	else if(match("#asm"))
		{doasm();lastst=stasm;}
	/* if nothing else, assume it's an expression */
	else{expression();ns();lastst=stexp;}
	return lastst;
}
/*					*/
/*	Semicolon enforcer		*/
/*					*/
/* called whenever syntax requires a semicolon */
ns()	{if(match(";")==0)error("missing semicolon");}
/*					*/
/*	Compound statement		*/
/*					*/
/* allow any number of statements to fall between "{}" */
compound()
	{
	++ncmp;		/* new level open */
	while (match("}")==0) statement(); /* do one */
	--ncmp;		/* close current level */
	}
/*					*/
/*		"if" statement		*/
/*					*/
doif()
	{
	int flev,fsp,flab1,flab2;
	flev=locptr;	/* record current local level */
	fsp=Zsp;		/* record current stk ptr */
	flab1=getlabel(); /* get label for false branch */
	test(flab1);	/* get expression, and branch false */
	statement();	/* if true, do a statement */
	Zsp=modstk(fsp);	/* then clean up the stack */
	locptr=flev;	/* and deallocate any locals */
	if (amatch("else",4)==0)	/* if...else ? */
		/* simple "if"...print false label */
		{printlabel(flab1);col();nl();
		return;		/* and exit */
		}
	/* an "if...else" statement. */
	jump(flab2=getlabel());	/* jump around false code */
	printlabel(flab1);col();nl();	/* print false label */
	statement();		/* and do "else" clause */
	Zsp=modstk(fsp);		/* then clean up stk ptr */
	locptr=flev;		/* and deallocate locals */
	printlabel(flab2);col();nl();	/* print true label */
	}
/*					*/
/*	"while" statement		*/
/*					*/
dowhile()
	{
	int wq[4];		/* allocate local queue */
	wq[wqsym]=locptr;	/* record local level */
	wq[wqsp]=Zsp;		/* and stk ptr */
	wq[wqloop]=getlabel();	/* and looping label */
	wq[wqlab]=getlabel();	/* and exit label */
	addwhile(wq);		/* add entry to queue */
				/* (for "break" statement) */
	printlabel(wq[wqloop]);col();nl(); /* loop label */
	test(wq[wqlab]);	/* see if true */
	statement();		/* if so, do a statement */
	Zsp = modstk(wq[wqsp]);	/* zap local vars: 9/25/80 gtf */
	jump(wq[wqloop]);	/* loop to label */
	printlabel(wq[wqlab]);col();nl(); /* exit label */
	locptr=wq[wqsym];	/* deallocate locals */
	delwhile();		/* delete queue entry */
	}
/*					*/
/*	"return" statement		*/
/*					*/
doreturn()
	{
	/* if not end of statement, get an expression */
	if(endst()==0)expression();
	modstk(0);	/* clean up stk */
	zret();		/* and exit function */
	}
/*					*/
/*	"break" statement		*/
/*					*/
dobreak()
	{
	int *ptr;
	/* see if any "whiles" are open */
	if ((ptr=readwhile())==0) return;	/* no */
	modstk((ptr[wqsp]));	/* else clean up stk ptr */
	jump(ptr[wqlab]);	/* jump to exit label */
	}
/*					*/
/*	"continue" statement		*/
/*					*/
docont()
	{
	int *ptr;
	/* see if any "whiles" are open */
	if ((ptr=readwhile())==0) return;	/* no */
	modstk((ptr[wqsp]));	/* else clean up stk ptr */
	jump(ptr[wqloop]);	/* jump to loop label */
	}
/*					*/
/*	"asm" pseudo-statement		*/
/*					*/
/* enters mode where assembly language statement are */
/*	passed intact through parser	*/
doasm()
{
	cmode=0;		/* mark mode as "asm" */
	while (1) {
		finline();	/* get and print lines */
		if (match("#endasm")) break;	/* until... */
		if(eof)break;
		outstr(line);
		nl();
	}
	kill();		/* invalidate line */
	cmode=1;		/* then back to parse level */
}
/*	>>>>> start of cc3 <<<<<<<<<	*/

/*					*/
/*	Perform a function call		*/
/*					*/
/* called from heir11, this routine will either call */
/*	the named function, or if the supplied ptr is */
/*	zero, will call the contents of HL		*/
callfunction(ptr)
	char *ptr;	/* symbol table entry (or 0) */
{	int nargs;
	nargs=0;
	blanks();	/* already saw open paren */
	if(ptr==0)zpush();	/* calling HL */
	while(streq(line+lptr,")")==0)
		{if(endst())break;
		expression();	/* get an argument */
		if(ptr==0)swapstk(); /* don't push addr */
		zpush();	/* push argument */
		nargs=nargs+2;	/* count args*2 */
		if (match(",")==0) break;
		}
	needbrack(")");
	if(ptr)zcall(ptr);
	else callstk();
	Zsp=modstk(Zsp+nargs);	/* clean up arguments */
}
junk()
{	if(an(inbyte()))
		while(an(ch()))gch();
	else while(an(ch())==0)
		{if(ch()==0)break;
		gch();
		}
	blanks();
}
endst()
{	blanks();
	return ((streq(line+lptr,";")|(ch()==0)));
}
illname()
{	error("illegal symbol name");junk();}
multidef(sname)
	char *sname;
{	error("already defined");
	comment();
	outstr(sname);nl();
}
needbrack(str)
	char *str;
{	
	if (match(str)==0) {
		error("missing bracket");
		comment();outstr(str);nl();
	}
}
needlval()
{	error("must be lvalue");
}
findglb(sname)
	char *sname;
{	char *ptr;
	ptr=startglb;
	while(ptr!=glbptr) {
		if (astreq(sname,ptr,namemax)) return ptr;
		ptr=ptr+symsiz;
	}
	return 0;
}
findloc(sname)
	char *sname;
{	char *ptr;
	ptr=startloc;
	while (ptr!=locptr) {
		if(astreq(sname,ptr,namemax))return ptr;
		ptr=ptr+symsiz;
	}
	return 0;
}
addglb(sname,id,typ,value,iptr)
	char *sname,id,typ;
	int value,iptr;
{	char *ptr;
	if(cptr=findglb(sname))return cptr;
	if(glbptr>=endglb)
		{error("global symbol table overflow");
		return 0;
		}
	cptr=ptr=glbptr;
	while (an(*ptr++ = *sname++));	/* copy name */
	cptr[ident]=id;
	cptr[type]=typ;
	cptr[storage]=statik;
	cptr[offset]=value;
	cptr[offset+1]=value>>8;
	cptr[initptr]=iptr&255;
	cptr[initptr+1]=iptr>>8;
	glbptr=glbptr+symsiz;
	return cptr;
}
addloc(sname,id,typ,value)
	char *sname,id,typ;
	int value;
{	char *ptr;
	if(cptr=findloc(sname))return cptr;
	if(locptr>=endloc)
		{error("local symbol table overflow");
		return 0;
		}
	cptr=ptr=locptr;
	while(an(*ptr++ = *sname++));	/* copy name */
	cptr[ident]=id;
	cptr[type]=typ;
	cptr[storage]=stkloc;
	cptr[offset]=value;
	cptr[offset+1]=value>>8;
	locptr=locptr+symsiz;
	return cptr;
}
/* Test if next input string is legal symbol name */
symname(sname)
	char *sname;
{	int k;char c;
	blanks();
	if(alpha(ch())==0)return 0;
	k=0;
	while(an(ch()))sname[k++]=gch();
	sname[k]=0;
	return 1;
	}
/* Return next avail internal label number */
getlabel()
{	return(++nxtlab);
}
/* Print specified number as label */
printlabel(label)
	int label;
{	outasm("cc");
	outdec(label);
}
/* Test if given character is alpha */
alpha(c)
	char c;
{	c=c&127;
	return(((c>='a')&(c<='z'))|
		((c>='A')&(c<='Z'))|
		(c=='_'));
}
// Test if given character is numeric 
numeric(c)
	char c;
{	c=c&127;
	return ((c>='0')&(c<='9'));
}
// Test if given character is hexadecimal 
hexnum(c)
	char c;
{	c=c&127;
	return (((c>='0')&(c<='9')) | ((c>='a')&(c<='f')) | ((c>='A')&(c<='F')));
}
/* Test if given character is alphanumeric */
an(c)
	char c;
{	return((alpha(c))|(numeric(c)));
}
/* Print a carriage return and a string only to console */
pl(str)
	char *str;
{	int k;
	k=0;
	putchar(eol);
	while(str[k])putchar(str[k++]);
}
addwhile(ptr)
	int ptr[];
 {
	int k;
	if (wqptr==wqmax)
		{error("too many active whiles");return;}
	k=0;
	while (k<wqsiz)
		{*wqptr++ = ptr[k++];}
}
delwhile()
	{if(readwhile()) wqptr=wqptr-wqsiz;
	}
readwhile()
 {
	if (wqptr==wq){error("no active whiles");return 0;}
	else return (wqptr-wqsiz);
 }
ch()
{	return(line[lptr]&127);
}
nch()
{	if(ch()==0)return 0;
		else return(line[lptr+1]&127);
}
gch()
{	if(ch()==0)return 0;
		else return(line[lptr++]&127);
}
kill()
{	lptr=0;
	line[lptr]=0;
}
inbyte()
{
	while(ch()==0)
		{if (eof) return 0;
		finline();
		preprocess();
		}
	return gch();
}
inchar()
{
	if(ch()==0)finline();
	if(eof)return 0;
	return(gch());
}
finline()
{
	int k,unit;
	while(1)
		{if (input==0)openin();
		if(eof)return;
		if((unit=input2)==0)unit=input;
		kill();
		while((k=getc(unit))>0)
			{if((k==eol)|(lptr>=linemax))break;
			line[lptr++]=k;
			}
		line[lptr]=0;	/* append null */
		lineno++;	/* read one more line		gtf 7/2/80 */
		if(k<=0)
			{fclose(unit);
			if(input2)endinclude();		/* gtf 7/16/80 */
				else input=0;
			}
		if(lptr)
			{if((ctext)&(cmode))
				{comment();
				outstr(line);
				nl();
				}
			lptr=0;
			return;
			}
		}
}
/*	>>>>>> start of cc4 <<<<<<<	*/

keepch(c)
	char c;
{	mline[mptr]=c;
	if(mptr<mpmax)mptr++;
	return c;
}
preprocess()
{	int k;
	char c,sname[namesize];
	if(cmode==0)return;
	mptr=lptr=0;
	while(ch())
		{if((ch()==' ')|(ch()==9))
			{keepch(' ');
			while((ch()==' ')|
				(ch()==9))
				gch();
			}
		else if(ch()=='"')
			{keepch(ch());
			gch();
			while(ch()!='"')
				{if(ch()==0)
				  {error("missing quote");
				  break;
				  }
				keepch(gch());
				}
			gch();
			keepch('"');
			}
		else if(ch()==39)
			{keepch(39);
			gch();
			while(ch()!=39)
				{if(ch()==0)
				  {error("missing apostrophe");
				  break;
				  }
				keepch(gch());
				}
			gch();
			keepch(39);
			}
		else if((ch()=='/')&(nch()=='/')) {
			// delete the entire line 
			kill();
		}
		else if((ch()=='/')&(nch()=='*')) {
			inchar();inchar();
			while (((ch()=='*') & (nch()=='/'))==0) {
				if(ch()==0)finline();
					else inchar();
				if(eof)break;
			}
			inchar();inchar();
		}
		else if(alpha(ch()))	/* from an(): 9/22/80 gtf */
			{k=0;
			while(an(ch()))
				{if(k<namemax)sname[k++]=ch();
				gch();
				}
			sname[k]=0;
			if(k=findmac(sname))
				while(c=macq[k++])
					keepch(c);
			else
				{k=0;
				while(c=sname[k++])
					keepch(c);
				}
			}
		else keepch(gch());
		}
	keepch(0);
	if(mptr>=mpmax)error("line too long");
	lptr=mptr=0;
	while(line[lptr++]=mline[mptr++]);
	lptr=0;
	}
addmac()
{	
char sname[namesize];
int k;

	if (symname(sname)==0) {
		illname();
		kill();
		return;
	}
	k=0;
	while (putmac(sname[k++]));
	while (ch()==' ' | ch()==9) gch();
	while (putmac(gch()));
	if (macptr>=macmax) error("macro table full");
}
putmac(c)
	char c;
{	
	macq[macptr]=c;
	if(macptr<macmax)macptr++;
	return c;
}
findmac(sname)
	char *sname;
{	int k;
	k=0;
	while (k<macptr) {
		if (astreq(sname, macq+k, namemax)) {
			while(macq[k++]);
			return k;
			}
		while(macq[k++]);
		while(macq[k++]);
	}
	return 0;
}
/* direct output to console		gtf 7/16/80 */
toconsole()
{
	saveout = output;
	output = 0;
/* end toconsole */}

/* direct output back to file		gtf 7/16/80 */
tofile()
{
	if(saveout)
		output = saveout;
	saveout = 0;
/* end tofile */}

outbyte(c)
	char c;
{
	if(c==0)return 0;
	if(output)
		{if((putc(c,output))<=0)
			{closeout();
			error("Output file error");
			zabort();			/* gtf 7/17/80 */
			}
		}
	else putchar(c);
	return c;
}
outstr(ptr)
	char ptr[];
 {
	int k;
	k=0;
	while(outbyte(ptr[k++]));
 }

/* write text destined for the assembler to read */
/* (i.e. stuff not in comments)			*/
/*  gtf  6/26/80 */
outasm(ptr)
char *ptr;
{
	while(outbyte(lower(*ptr++)));
/* end outasm */}

nl()
	{outbyte(eol);}
tab()
	{outbyte(9);}
col()
	{outbyte(58);}
bell()				/* gtf 7/16/80 */
	{outbyte(7);}
/*				replaced 7/2/80 gtf
 * error(ptr)
 *	char ptr[];
 * {
 *	int k;
 *	comment();outstr(line);nl();comment();
 *	k=0;
 *	while(k<lptr)
 *		{if(line[k]==9) tab();
 *			else outbyte(' ');
 *		++k;
 *		}
 *	outbyte('^');
 *	nl();comment();outstr("******  ");
 *	outstr(ptr);
 *	outstr("  ******");
 *	nl();
 *	++errcnt;
 * }
 */

error(ptr)
char ptr[];
{	int k;
	char junk[81];

	toconsole();
	bell();
	outstr("Line "); outdec(lineno); outstr(", ");
	if(infunc==0)
		outbyte('(');
	if(currfn==NULL)
		outstr("start of file");
	else	outstr(currfn+name);
	if(infunc==0)
		outbyte(')');
	outstr(" + ");
	outdec(lineno-fnstart);
	outstr(": ");  outstr(ptr);  nl();

	outstr(line); nl();

	k=0;	/* skip to error position */
	while(k<lptr){
		if(line[k++]==9)
			tab();
		else	outbyte(' ');
		}
	outbyte('^');  nl();
	++errcnt;

	if(errstop){
		pl("Continue (Y,n,g) ? ");
		gets(junk);		
		k=junk[0];
		if((k=='N') | (k=='n'))
			zabort();
		if((k=='G') | (k=='g'))
			errstop=0;
		}
	tofile();
/* end error */}

ol(ptr)
	char ptr[];
{
	ot(ptr);
	nl();
}
ot(ptr)
	char ptr[];
{
	tab();
	outasm(ptr);
}
streq(str1,str2)
	char str1[],str2[];
{
int k;

	k=0;
	while (str2[k])
		{if ((str1[k])!=(str2[k])) return 0;
		k++;
		}
	return k;
}
astreq(str1,str2,len)
	char str1[],str2[];int len;
{
int k;

	k=0;
	while (k<len) {
		if ((str1[k])!=(str2[k]))break;
		if(str1[k]==0)break;
		if(str2[k]==0)break;
		k++;
	}
	if (an(str1[k]))return 0;
	if (an(str2[k]))return 0;
	return k;
}
match(lit)
	char *lit;
{
	int k;
	blanks();
	if (k=streq(line+lptr,lit)) {
		lptr=lptr+k;
		return 1;
	}
 	return 0;
}
amatch(lit,len)
	char *lit;int len;
 {
	int k;
	blanks();
	if (k=astreq(line+lptr,lit,len))
		{lptr=lptr+k;
		while(an(ch())) inbyte();
		return 1;
		}
	return 0;
 }
blanks()
{
	while (1) {
		while (ch()==0) {
			finline();
			preprocess();
			if(eof)break;
		}
		if (ch()==' ') gch();
		else if (ch()==9) gch();
		else return;
	}
}
/* output a decimal number - rewritten 4/1/81 gtf */
outdec(n)
int n;
{
	if(n<0)
		outbyte('-');
	else	n = -n;
	outint(n);
/* end outdec */}

outint(n)	/* added 4/1/81 */
int n;
{	int q;

	q = n/10;
	if(q) outint(q);
	outbyte('0'+(n-q*10));
/* end outint */}

/* return the length of a string */
/* gtf 4/8/80 */
strlen(s)
char *s;
{	char *t;

	t = s;
	while(*s) s++;
	return(s-t);
/* end strlen */}

/* convert lower case to upper */
/* gtf 6/26/80 */
raise(c)
char c;
{
	if((c>='a') & (c<='z'))
		c = c - 'a' + 'A';
	return(c);
/* end raise */}

/* convert upper case to lower */
/* ml 28/2/2012 */
lower(c)
char c;
{
	if((c>='A') & (c<='Z'))
		c = c - 'A' + 'a';
	return(c);
/* end raise */}

/* ------------------------------------------------------------- */

/*	>>>>>>> start of cc5 <<<<<<<	*/

/* as of 5/5/81 rj */

expression()
{
	int lval[2];
	if(heir1(lval))rvalue(lval);
}
heir1(lval)
	int lval[];
{
	int k,lval2[2];
	k=heir2(lval);
	if (match("="))
		{if(k==0){needlval();return 0;}
		if (lval[1])zpush();
		if(heir1(lval2))rvalue(lval2);
		store(lval);
		return 0;
		}
	else return k;
}
heir2(lval)
	int lval[];
{	int k,lval2[2];
	k=heir3(lval);
	blanks();
	if(ch()!='|')return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("|"))
			{zpush();
			if(heir3(lval2)) rvalue(lval2);
			zpop();
			zor();
			}
		else return 0;
		}
}
heir3(lval)
	int lval[];
{	int k,lval2[2];
	k=heir4(lval);
	blanks();
	if(ch()!='^')return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("^"))
			{zpush();
			if(heir4(lval2))rvalue(lval2);
			zpop();
			zxor();
			}
		else return 0;
		}
}
heir4(lval)
	int lval[];
{	int k,lval2[2];
	k=heir5(lval);
	blanks();
	if(ch()!='&')return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("&"))
			{zpush();
			if(heir5(lval2))rvalue(lval2);
			zpop();
			zand();
			}
		else return 0;
		}
}
heir5(lval)
	int lval[];
{
	int k,lval2[2];
	k=heir6(lval);
	blanks();
	if((streq(line+lptr,"==")==0)&
		(streq(line+lptr,"!=")==0))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("=="))
			{zpush();
			if(heir6(lval2))rvalue(lval2);
			zpop();
			zeq();
			}
		else if (match("!="))
			{zpush();
			if(heir6(lval2))rvalue(lval2);
			zpop();
			zne();
			}
		else return 0;
		}
}
heir6(lval)
	int lval[];
{
	int k,lval2[2];
	k=heir7(lval);
	blanks();
	if((streq(line+lptr,"<")==0)&
		(streq(line+lptr,">")==0)&
		(streq(line+lptr,"<=")==0)&
		(streq(line+lptr,">=")==0))return k;
		if(streq(line+lptr,">>"))return k;
		if(streq(line+lptr,"<<"))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("<="))
			{zpush();
			if(heir7(lval2))rvalue(lval2);
			zpop();
			if(cptr=lval[0])
				if(cptr[ident]==pointer)
				{ule();
				continue;
				}
			if(cptr=lval2[0])
				if(cptr[ident]==pointer)
				{ule();
				continue;
				}
			zle();
			}
		else if (match(">="))
			{zpush();
			if(heir7(lval2))rvalue(lval2);
			zpop();
			if(cptr=lval[0])
				if(cptr[ident]==pointer)
				{uge();
				continue;
				}
			if(cptr=lval2[0])
				if(cptr[ident]==pointer)
				{uge();
				continue;
				}
			zge();
			}
		else if((streq(line+lptr,"<"))&
			(streq(line+lptr,"<<")==0))
			{inbyte();
			zpush();
			if(heir7(lval2))rvalue(lval2);
			zpop();
			if(cptr=lval[0])
				if(cptr[ident]==pointer)
				{ult();
				continue;
				}
			if(cptr=lval2[0])
				if(cptr[ident]==pointer)
				{ult();
				continue;
				}
			zlt();
			}
		else if((streq(line+lptr,">"))&
			(streq(line+lptr,">>")==0))
			{inbyte();
			zpush();
			if(heir7(lval2))rvalue(lval2);
			zpop();
			if(cptr=lval[0])
				if(cptr[ident]==pointer)
				{ugt();
				continue;
				}
			if(cptr=lval2[0])
				if(cptr[ident]==pointer)
				{ugt();
				continue;
				}
			zgt();
			}
		else return 0;
		}
}
/*	>>>>>> start of cc6 <<<<<<	*/

heir7(lval)
	int lval[];
{
	int k,lval2[2];
	k=heir8(lval);
	blanks();
	if((streq(line+lptr,">>")==0)&
		(streq(line+lptr,"<<")==0))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match(">>"))
			{zpush();
			if(heir8(lval2))rvalue(lval2);
			zpop();
			asr();
			}
		else if (match("<<"))
			{zpush();
			if(heir8(lval2))rvalue(lval2);
			zpop();
			asl();
			}
		else return 0;
		}
}
heir8(lval)
	int lval[];
{
	int k,lval2[2];
	k=heir9(lval);
	blanks();
	if((ch()!='+')&(ch()!='-'))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("+"))
			{zpush();
			if(heir9(lval2))rvalue(lval2);
			if(cptr=lval[0])
				if((cptr[ident]==pointer)&
				(cptr[type]==cint))
				doublereg();
			zpop();
			zadd();
			}
		else if (match("-"))
			{zpush();
			if(heir9(lval2))rvalue(lval2);
			if(cptr=lval[0])
				if((cptr[ident]==pointer)&
				(cptr[type]==cint))
				doublereg();
			zpop();
			zsub();
			}
		else return 0;
		}
}
heir9(lval)
	int lval[];
{
	int k,lval2[2];
	k=heir10(lval);
	blanks();
	if((ch()!='*')&(ch()!='/')&
		(ch()!='%'))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("*"))
			{zpush();
			if(heir9(lval2))rvalue(lval2);
			zpop();
			mult();
			}
		else if (match("/"))
			{zpush();
			if(heir10(lval2))rvalue(lval2);
			zpop();
			div();
			}
		else if (match("%"))
			{zpush();
			if(heir10(lval2))rvalue(lval2);
			zpop();
			zmod();
			}
		else return 0;
		}
}
heir10(lval)
	int lval[];
{
	int k;
	char *ptr;
	if(match("++"))
		{if((k=heir10(lval))==0)
			{needlval();
			return 0;
			}
		if(lval[1])zpush();
		rvalue(lval);
		inc();
		ptr=lval[0];
		if((ptr[ident]==pointer)&
			(ptr[type]==cint))
				inc();
		store(lval);
		return 0;
		}
	else if(match("--"))
		{if((k=heir10(lval))==0)
			{needlval();
			return 0;
			}
		if(lval[1])zpush();
		rvalue(lval);
		dec();
		ptr=lval[0];
		if((ptr[ident]==pointer)&
			(ptr[type]==cint))
				dec();
		store(lval);
		return 0;
		}
	else if (match("-"))
		{k=heir10(lval);
		if (k) rvalue(lval);
		neg();
		return 0;
		}
	else if(match("*"))
		{k=heir10(lval);
		if(k)rvalue(lval);
		lval[1]=cint;
		if(ptr=lval[0])lval[1]=ptr[type];
		lval[0]=0;
		return 1;
		}
	else if(match("&"))
		{k=heir10(lval);
		if(k==0)
			{error("illegal address");
			return 0;
			}
		else if(lval[1])return 0;
		else
			{immed();
			outname(ptr=lval[0]);
			nl();
			lval[1]=ptr[type];
			return 0;
			}
		}
	else 
		{k=heir11(lval);
		if(match("++"))
			{if(k==0)
				{needlval();
				return 0;
				}
			if(lval[1])zpush();
			rvalue(lval);
			inc();
			ptr=lval[0];
			if((ptr[ident]==pointer)&
				(ptr[type]==cint))
					inc();
			store(lval);
			dec();
			if((ptr[ident]==pointer)&
				(ptr[type]==cint))
				dec();
			return 0;
			}
		else if(match("--"))
			{if(k==0)
				{needlval();
				return 0;
				}
			if(lval[1])zpush();
			rvalue(lval);
			dec();
			ptr=lval[0];
			if((ptr[ident]==pointer)&
				(ptr[type]==cint))
					dec();
			store(lval);
			inc();
			if((ptr[ident]==pointer)&
				(ptr[type]==cint))
				inc();
			return 0;
			}
		else return k;
		}
	}
/*	>>>>>> start of cc7 <<<<<<	*/

heir11(lval)
	int *lval;
{	int k;char *ptr;
	k=primary(lval);
	ptr=lval[0];
	blanks();
	if((ch()=='[')|(ch()=='('))
	while(1)
		{if(match("["))
			{if(ptr==0)
				{error("can't subscript");
				junk();
				needbrack("]");
				return 0;
				}
			else if(ptr[ident]==pointer)rvalue(lval);
			else if(ptr[ident]!=array)
				{error("can't subscript");
				k=0;
				}
			zpush();
			expression();
			needbrack("]");
			if(ptr[type]==cint)doublereg();
			zpop();
			zadd();
			lval[1]=ptr[type];
				/* 4/1/81 - after subscripting, not ptr anymore */
			lval[0]=0;
			k=1;
			}
		else if(match("("))
			{if(ptr==0)
				{callfunction(0);
				}
			else if(ptr[ident]!=function)
				{rvalue(lval);
				callfunction(0);
				}
			else callfunction(ptr);
			k=lval[0]=0;
			}
		else return k;
		}
	if(ptr==0)return k;
	if(ptr[ident]==function)
		{immed();
		outname(ptr);
		nl();
		return 0;
		}
	return k;
}
primary(lval)
	int *lval;
{	char *ptr,sname[namesize];int num[1];
	int k;
	if(match("("))
		{k=heir1(lval);
		needbrack(")");
		return k;
		}
	if(symname(sname))
		{if(ptr=findloc(sname))
			{getloc(ptr);
			lval[0]=ptr;
			lval[1]=ptr[type];
			if(ptr[ident]==pointer)lval[1]=cint;
			if(ptr[ident]==array)return 0;
				else return 1;
			}
		if(ptr=findglb(sname))
			if(ptr[ident]!=function)
			{lval[0]=ptr;
			lval[1]=0;
			if(ptr[ident]!=array)return 1;
			immed();
			outname(ptr);nl();
			lval[1]=ptr[type];
			return 0;
			}
		ptr=addglb(sname,function,cint,0,-1);
		lval[0]=ptr;
		lval[1]=0;
		return 0;
		}
	if(constant(num))
		return(lval[0]=lval[1]=0);
	else
		{error("invalid expression");
		immed();outdec(0);nl();
		junk();
		return 0;
		}
	}
store(lval)
	int *lval;
{	if (lval[1]==0)putmem(lval[0]);
	else putstk(lval[1]);
}
rvalue(lval)
	int *lval;
{	if((lval[0] != 0) & (lval[1] == 0))
		getmem(lval[0]);
		else indirect(lval[1]);
}
test(label)
	int label;
{
	needbrack("(");
	expression();
	needbrack(")");
	testjump(label);
}
constant(val)
	int val[];
{	
	if (number(val)) {
		immed();
		outdec(val[0]);
	}
	else if (pstr(val)) {
		immed();
		outdec(val[0]);
	}
	else if (qstr(val)) {
		immed();
		printlabel(litlab);
		outbyte('+');
		outdec(val[0]);
	}
	else 
		return 0;	
	nl();
	return 1;
}
// get a numeric value from the source file 
number(val)
int val[];
{	
int k,minus;
char c;

	k=minus=1;
	while (k) { 
		k=0;
		if (match("+")) k=1;
		if (match("-")) {
			minus=(-minus);
			k=1;
		}
	}
	// check if hexadecimal value 
	if ((ch()=='0') & (nch()=='x')) {
		// remove first two characters ("0x") 
		inchar();inchar();
		// make sure the next value is legal 
		if (hexnum(ch())==0) return 0;
		// continue to read hexadecimal value 
		while (hexnum(ch())) {
			c=raise(inbyte());
			if (numeric(c)!=0)
				k=k*16+(c-'0');
			else 
				k=k*16+(c-'A')+10;
		}
		if (minus<0) k=(-k);
		val[0]=k;
		return 1;
	} 
	// check if decimal value 
	else if (numeric(ch())!=0) {
		while (numeric(ch())) {
			c=inbyte();
			k=k*10+(c-'0');
		}
		if (minus<0) k=(-k);
		val[0]=k;
		return 1;
	} 
	else 
		return 0;
}

pstr(val)
int val[];
{	
int k;
char c;

	k=0;
	if (match("'")==0) return 0;
	while((c=gch())!=39)
		k=(k&255)*256 + (c&127);
	val[0]=k;
	return 1;
}
qstr(val)
int val[];
{
char c;

	if (match("\"")==0) return 0;
	val[0]=litptr;
	while (ch()!='"')
		{if(ch()==0)break;
		if(litptr>=litmax)
			{error("string space exhausted");
			while(match("\"")==0)
				if(gch()==0)break;
			return 1;
			}
		litq[litptr++]=gch();
		}
	gch();
	litq[litptr++]=0;
	return 1;
}
/*	>>>>>> start of cc8 <<<<<<<	*/

/* Begin a comment line for the assembler */
comment()
{	outbyte(';');
}

/* Put out assembler info before any code is generated */
header()
{	comment();
	outstr(BANNER);
	nl();
	comment();
	outstr(VERSION);
	nl();
	comment();
	outstr(AUTHOR);
	nl();
	comment();
	nl();
	if (mainflg) {		/* do stuff needed for first */
		ol("code");
		ol("org #0000"); /* assembler file. */		   
		ot("ld hl,"); outdec(stackptr); nl();	/* set up stack */
		ol("ld sp,hl");
		zcall("main");	/* call the code generated by small-c */
	}
}
/* Print any assembler stuff needed after all code */
trailer()
{	/* ol("END"); */	/*...note: commented out! */

	nl();			/* 6 May 80 rj errorsummary() now goes to console */
	comment();
	outstr(" --- End of Compilation ---");
	nl();
}
/* Print out a name such that it won't annoy the assembler */
/*	(by matching anything reserved, like opcodes.) */
/*	gtf 4/7/80 */
outname(sname)
char *sname;
{	int len, i,j;

	outasm("__");
	len = strlen(sname);
	if (len>(asmpref+asmsuff)) {
		i = asmpref;
		len = len-asmpref-asmsuff;
		while(i-- > 0)
			outbyte(lower(*sname++));
		while(len-- > 0)
			sname++;
		while(*sname)
			outbyte(lower(*sname++));
		}
	else	outasm(sname);
/* end outname */}
/* Fetch a static memory cell into the primary register */
getmem(sym)
	char *sym;
{	
int padr;

	if ((sym[ident]!=pointer)&(sym[type]==cchar)) {
		ot("ld a,(");
		outname(sym+name);
		outasm(")");
		nl();
		callrts("ccsxt");
	} else if (sym[type]==cport) { 
		padr=sym[offset] & 0xff;
		ot("in a,(");outdec(padr);outasm(")");nl();
		callrts("ccsxt");
	} else {
		ot("ld hl,(");
		outname(sym+name);
		outasm(")");
		nl();
	}
}
/* Fetch the address of the specified symbol */
/*	into the primary register */
getloc(sym)
	char *sym;
{	
int off_val;

	immed();
	off_val = ((sym[offset]&255)+((sym[offset+1]&255)<<8))-Zsp;
	off_val &= 0xffff;
	outdec(off_val);
	nl();
	ol("add hl,sp");
}
/* Store the primary register into the specified */
/*	static memory cell */
putmem(sym)
	char *sym;
{	
int padr;

	if((sym[ident]!=pointer)&(sym[type]==cchar)) {
		ol("ld a,l");
		ot("ld (");
		outname(sym+name);
		outasm("),a");
	} else if (sym[type]==cport) {
		padr=sym[offset] & 0xff;
		ol("ld a,l");
		ot("out (");outdec(padr);outasm("),a");nl();
	} else { 
		ot("ld (");
		outname(sym+name);
		outasm("),hl");
	}
	
	nl();
	}
/* Store the specified object type in the primary register */
/*	at the address on the top of the stack */
putstk(typeobj)
char typeobj;
{	zpop();
	if(typeobj==cint)
		callrts("ccpint");
	else {	ol("ld a,l");		/* per Ron Cain: gtf 9/25/80 */
		ol("ld (de),a");
		}
	}
/* Fetch the specified object type indirect through the */
/*	primary register into the primary register */
indirect(typeobj)
	char typeobj;
{	if(typeobj==cchar)callrts("ccgchar");
		else callrts("ccgint");
}
/* Swap the primary and secondary registers */
swap()
{	ol("ex de,hl");
}
/* Print partial instruction to get an immediate value */
/*	into the primary register */
immed()
{	ot("ld hl,");
}
/* Push the primary register onto the stack */
zpush()
{	ol("push hl");
	Zsp=Zsp-2;
}
/* Pop the top of the stack into the secondary register */
zpop()
{	ol("pop de");
	Zsp=Zsp+2;
}
/* Swap the primary register and the top of the stack */
swapstk()
{	ol("ex (sp),hl");
}
/* Call the specified subroutine name */
zcall(sname)
	char *sname;
{	ot("call ");
	outname(sname);
	nl();
}
/* Call a run-time library routine */
callrts(sname)
char *sname;
{
	ot("call ");
	outasm(sname);
	nl();
/*end callrts*/}

/* Return from subroutine */
zret()
{	ol("ret");
}
/* Perform subroutine call to value on top of stack */
callstk()
{	immed();
	outasm("$+5");
	nl();
	swapstk();
	ol("jp (hl)");
	Zsp=Zsp+2; /* corrected 5 May 81 rj */
	}
/* Jump to specified internal label number */
jump(label)
	int label;
{	ot("jp ");
	printlabel(label);
	nl();
	}
/* Test the primary register and jump if false to label */
testjump(label)
	int label;
{	ol("ld a,h");
	ol("or l");
	ot("jp z,");
	printlabel(label);
	nl();
	}
/* Print pseudo-op to define a byte */
defbyte()
{	ot("db ");
}
/*Print pseudo-op to define storage */
defstorage()
{	ot("ds ");
}
/* Print pseudo-op to define a word */
defword()
{	ot("dw ");
}
/* Modify the stack pointer to the new value indicated */
modstk(newsp)
	int newsp;
 {	int k;
	k=newsp-Zsp;
	if(k==0)return newsp;
	if(k>=0)
		{if(k<7)
			{if(k&1)
				{ol("inc sp");
				k--;
				}
			while(k)
				{ol("pop bc");
				k=k-2;
				}
			return newsp;
			}
		}
	if(k<0)
		{if(k>-7)
			{if(k&1)
				{ol("dec sp");
				k++;
				}
			while(k)
				{ol("push bc");
				k=k+2;
				}
			return newsp;
			}
		}
	swap();
	immed();outdec(k);nl();
	ol("add hl,sp");
	ol("ld sp,hl");
	swap();
	return newsp;
}
/* Double the primary register */
doublereg()
{	ol("add hl,hl");
}
/* Add the primary and secondary registers */
/*	(results in primary) */
zadd()
{	ol("add hl,de");
}
/* Subtract the primary register from the secondary */
/*	(results in primary) */
zsub()
{	callrts("ccsub");
}
/* Multiply the primary and secondary registers */
/*	(results in primary */
mult()
{	callrts("ccmult");
}
/* Divide the secondary register by the primary */
/*	(quotient in primary, remainder in secondary) */
div()
{	callrts("ccdiv");
}
/* Compute remainder (mod) of secondary register divided */
/*	by the primary */
/*	(remainder in primary, quotient in secondary) */
zmod()
{	div();
	swap();
	}
/* Inclusive 'or' the primary and the secondary registers */
/*	(results in primary) */
zor()
	{callrts("ccor");}
/* Exclusive 'or' the primary and seconday registers */
/*	(results in primary) */
zxor()
	{callrts("ccxor");}
/* 'And' the primary and secondary registers */
/*	(results in primary) */
zand()
	{callrts("ccand");}
/* Arithmetic shift right the secondary register number of */
/*	times in primary (results in primary) */
asr()
	{callrts("ccasr");}
/* Arithmetic left shift the secondary register number of */
/*	times in primary (results in primary) */
asl()
	{callrts("ccasl");}
/* Form two's complement of primary register */
neg()
	{callrts("ccneg");}
/* Form one's complement of primary register */
com()
	{callrts("cccom");}
/* Increment the primary register by one */
inc()
	{ol("inc hl");}
/* Decrement the primary register by one */
dec()
	{ol("dec hl");}

/* Following are the conditional operators */
/* They compare the secondary register against the primary */
/* and put a literal 1 in the primary if the condition is */
/* true, otherwise they clear the primary register */

/* Test for equal */
zeq()
	{callrts("cceq");}
/* Test for not equal */
zne()
	{callrts("ccne");}
/* Test for less than (signed) */
zlt()
	{callrts("cclt");}
/* Test for less than or equal to (signed) */
zle()
	{callrts("ccle");}
/* Test for greater than (signed) */
zgt()
	{callrts("ccgt");}
/* Test for greater than or equal to (signed) */
zge()
	{callrts("ccge");}
/* Test for less than (unsigned) */
ult()
	{callrts("ccult");}
/* Test for less than or equal to (unsigned) */
ule()
	{callrts("ccule");}
/* Test for greater than (unsigned) */
ugt()
	{callrts("ccugt");}
/* Test for greater than or equal to (unsigned) */
uge()
	{callrts("ccuge");}

/*	<<<<<  End of small-c compiler	>>>>>	*/

