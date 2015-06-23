% This file is part of the MMIXware package (c) Donald E Knuth 1999
@i boilerplate.w %<< legal stuff: PLEASE READ IT BEFORE MAKING ANY CHANGES!

\def\title{MMOTYPE}
\def\MMIX{\.{MMIX}}
\def\MMIXAL{\.{MMIXAL}}
\def\Hex#1{\hbox{$^{\scriptscriptstyle\#}$\tt#1}} % experimental hex constant

@* Introduction. This program reads a binary \.{mmo} file output by
the \MMIXAL\ processor and lists it in human-readable form. It lists
only the symbol table, if invoked with the \.{-s} option. It lists
also the tetrabytes of input, if invoked with the \.{-v} option.

@s tetra int

@c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
@<Prototype preparations@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Subroutines@>@;
@#
int main(argc,argv)
  int argc;@+char*argv[];
{
  register int j,delta,postamble=0;
  register char *p;
  @<Process the command line@>;
  @<Initialize everything@>;
  @<List the preamble@>;
  do @<List the next item@>@;@+while (!postamble);
  @<List the postamble@>;
  @<List the symbol table@>;
  return 0;
}

@ @<Process the command line@>=
listing=1, verbose=0;
for (j=1;j<argc-1 && argv[j][0]=='-' && argv[j][2]=='\0';j++) {
  if (argv[j][1]=='s') listing=0;
  else if (argv[j][1]=='v') verbose=1;
  else break;
}
if (j!=argc-1) {
  fprintf(stderr,"Usage: %s [-s] [-v] mmofile\n",argv[0]);
@.Usage: ...@>
  exit(-1);
}

@ @<Initialize everything@>=
mmo_file=fopen(argv[argc-1],"rb");
if (!mmo_file) {
  fprintf(stderr,"Can't open file %s!\n",argv[argc-1]);
@.Can't open...@>
  exit(-2);
}

@ @<Glob...@>=
int listing; /* are we listing everything? */
int verbose; /* are we also showing the tetras of input as they are read? */
FILE *mmo_file; /* the input file */

@ @<Prototype preparations@>=
#ifdef __STDC__
#define ARGS(list) list
#else
#define ARGS(list) ()
#endif

@ A complete definition of \.{mmo} format appears in the \MMIXAL\ document.
Here we need to define only the basic constants used for interpretation.

@d mm 0x98 /* the escape code of \.{mmo} format */
@d lop_quote 0x0 /* the quotation lopcode */
@d lop_loc 0x1 /* the location lopcode */
@d lop_skip 0x2 /* the skip lopcode */
@d lop_fixo 0x3 /* the octabyte-fix lopcode */
@d lop_fixr 0x4 /* the relative-fix lopcode */
@d lop_fixrx 0x5 /* extended relative-fix lopcode */
@d lop_file 0x6 /* the file name lopcode */
@d lop_line 0x7 /* the file position lopcode */
@d lop_spec 0x8 /* the special hook lopcode */
@d lop_pre 0x9 /* the preamble lopcode */
@d lop_post 0xa /* the postamble lopcode */
@d lop_stab 0xb /* the symbol table lopcode */
@d lop_end 0xc /* the end-it-all lopcode */

@* Low-level arithmetic. This program is intended to work correctly
whenever an |int| has at least 32 bits.

@<Type...@>=
typedef unsigned char byte; /* a monobyte */
typedef unsigned int tetra; /* a tetrabyte */
typedef struct {@+tetra h,l;}@+octa; /* an octabyte */

@ The |incr| subroutine adds a signed integer to an (unsigned) octabyte.

@<Sub...@>=
octa incr @,@,@[ARGS((octa,int))@];
octa incr(o,delta)
  octa o;
  int delta;
{
  register tetra t;
  octa x;
  if (delta>=0) {
    t=0xffffffff-delta;
    if (o.l<=t) x.l=o.l+delta, x.h=o.h;
    else x.l=o.l-t-1, x.h=o.h+1;
  } else {
    t=-delta;
    if (o.l>=t) x.l=o.l-t, x.h=o.h;
    else x.l=o.l+(0xffffffff+delta)+1, x.h=o.h-1;
  }
  return x;
}

@* Low-level input. The tetrabytes of an \.{mmo} file are stored in
friendly big-endian fashion, but this program is supposed to work also
on computers that are little-endian. Therefore we read four successive bytes
and pack them into a tetrabyte, instead of reading a single tetrabyte.

@<Sub...@>=
void read_tet @,@,@[ARGS((void))@];
void read_tet()
{
  if (fread(buf,1,4,mmo_file)!=4) {
    fprintf(stderr,"Unexpected end of file after %d tetras!\n",count);
@.Unexpected end of file...@>
    exit(-3);
  }
  yz=(buf[2]<<8)+buf[3];
  tet=(((buf[0]<<8)+buf[1])<<16)+yz;
  if (verbose) printf("  %08x\n",tet);
  count++;
}

@ @<Sub...@>=
byte read_byte @,@,@[ARGS((void))@];
byte read_byte()
{
  register byte b;
  if (!byte_count) read_tet();
  b=buf[byte_count];
  byte_count=(byte_count+1)&3;
  return b;
}

@ @<Glob...@>=
int count; /* the number of tetrabytes we've read */
int byte_count; /* index of the next-to-be-read byte */
byte buf[4]; /* the most recently read bytes */
int yz; /* the two least significant bytes */
tetra tet; /* |buf| bytes packed big-endianwise */

@ @<Init...@>=
count=byte_count=0;

@* The main loop. Now for the bread-and-butter part of this program.

@<List the next item@>=
{
  read_tet();
 loop:@+if (buf[0]==mm) switch (buf[1]) {
   case lop_quote:@+if (yz!=1)
       err("YZ field of lop_quote should be 1");
@.YZ field...should be 1@>
    read_tet();@+break;
   @t\4@>@<Cases for lopcodes in the main loop@>@;
   default: err("Unknown lopcode");
@.Unknown lopcode@>
  }
  if (listing) @<List |tet| as a normal item@>;
}

@ We want to catch all cases where the rules of \.{mmo} format are
not obeyed. The |err| macro ameliorates this somewhat tedious chore.

@d err(m) {@+fprintf(stderr,"Error in tetra %d: %s!\n",count,m);@+ continue;@+}
@.Error in tetra...@>

@ In a normal situation, the newly read tetrabyte is simply supposed
to be loaded into the current location. We list not only the current
location but also the current file position, if |cur_line| is nonzero
and |cur_loc| belongs to segment~0.

@<List |tet| as a normal item@>=
{
  printf("%08x%08x: %08x",cur_loc.h,cur_loc.l,tet);
  if (!cur_line) printf("\n");
  else {
    if (cur_loc.h&0xe0000000) printf("\n");
    else {
      if (cur_file==listed_file) printf(" (line %d)\n",cur_line);
      else {
        printf(" (\"%s\", line %d)\n", file_name[cur_file], cur_line);
        listed_file=cur_file;
      }
    }
    cur_line++;
  }
  cur_loc=incr(cur_loc,4);@+ cur_loc.l &=-4;
}

@ @<Glob...@>=
octa cur_loc; /* the current location */
int listed_file; /* the most recently listed file number */
int cur_file; /* the most recently selected file number */
int cur_line; /* the current position in |cur_file| */
char *file_name[256]; /* file names seen */
octa tmp; /* an octabyte of temporary interest */

@ @<Init...@>=
cur_loc.h=cur_loc.l=0;
listed_file=cur_file=-1;
cur_line=0;

@* The simple lopcodes. We have already implemented |lop_quote|, which
falls through to the normal case after reading an extra tetrabyte.
Now let's consider the other lopcodes in turn.

@d y buf[2] /* the next-to-least significant byte */
@d z buf[3] /* the least significant byte */

@<Cases...@>=
case lop_loc:@+if (z==2) {
   j=y;@+ read_tet();@+ cur_loc.h=(j<<24)+tet;
 }@+else if (z==1) cur_loc.h=y<<24;
 else err("Z field of lop_loc should be 1 or 2");
@:Z field of lop_loc...}\.{Z field of lop\_loc...@>
 read_tet();@+ cur_loc.l=tet;
 continue;
case lop_skip: cur_loc=incr(cur_loc,yz);@+continue;

@ Fixups load information out of order, when future references have
been resolved. The current file name and line number are not considered
relevant.

@<Cases...@>=
case lop_fixo:@+if (z==2) {
   j=y;@+ read_tet();@+ tmp.h=(j<<24)+tet;
 }@+else if (z==1) tmp.h=y<<24;
 else err("Z field of lop_fixo should be 1 or 2");
@:Z field of lop_fixo...}\.{Z field of lop\_fixo...@>
 read_tet();@+ tmp.l=tet;
 if (listing) printf("%08x%08x: %08x%08x\n",tmp.h,tmp.l,cur_loc.h,cur_loc.l);
 continue;
case lop_fixr: delta=yz; goto fixr;
case lop_fixrx:j=yz;@+if (j!=16 && j!=24)
    err("YZ field of lop_fixrx should be 16 or 24");
@:YZ field of lop_fixrx...}\.{YZ field of lop\_fixrx...@>
 read_tet(); delta=tet;
 if (delta&0xfe000000) err("increment of lop_fixrx is too large");
@.increment...too large@>
fixr: tmp=incr(cur_loc,-(delta>=0x1000000? (delta&0xffffff)-(1<<j): delta)<<2);
 if (listing) printf("%08x%08x: %08x\n",tmp.h,tmp.l,delta);
 continue;

@ The space for file names isn't allocated until we are sure we need it.

@<Cases...@>=
case lop_file:@+if (file_name[y]) {
   for (j=z;j>0;j--) read_tet();
   cur_file=y;
   if (z) err("Two file names with the same number");
@.Two file names...@>
 }@+else {
   if (!z) err("No name given for newly selected file");
@.No name given...@>
   file_name[y]=(char*)calloc(4*z+1,1);
   if (!file_name[y]) {
     fprintf(stderr,"No room to store the file name!\n");@+exit(-4);
@.No room...@>
   }
   cur_file=y;
   for (j=z,p=file_name[y]; j>0; j--,p+=4) {
     read_tet();
     *p=buf[0];@+*(p+1)=buf[1];@+*(p+2)=buf[2];@+*(p+3)=buf[3];
   }
 }
 cur_line=0;@+continue;
case lop_line:@+if (cur_file<0) err("No file was selected for lop_line");
@.No file was selected...@>
 cur_line=yz;@+continue;

@ Special bytes in the file might be in synch with the current location
and/or the current file position, so we list those parameters too.

@<Cases...@>=
case lop_spec:@+if (listing) {
   printf("Special data %d at loc %08x%08x", yz, cur_loc.h, cur_loc.l);
   if (!cur_line) printf("\n");
   else if (cur_file==listed_file) printf(" (line %d)\n",cur_line);
   else {
     printf(" (\"%s\", line %d)\n", file_name[cur_file], cur_line);
     listed_file=cur_file;
   }
 }
 while(1) {
   read_tet();
   if (buf[0]==mm) {
     if (buf[1]!=lop_quote || yz!=1) goto loop; /* end of special data */
     read_tet();
   }
   if (listing) printf("                   %08x\n",tet);
 }

@ The other cases shouldn't appear in the main loop.

@<Cases...@>=
case lop_pre: err("Can't have another preamble");
@.Can't have another...@>
case lop_post: postamble=1;
 if (y) err("Y field of lop_post should be zero");
@:Y field of lop_post...}\.{Y field of lop\_post...@>
 if (z<32) err("Z field of lop_post must be 32 or more");
@:Z field of lop_post...}\.{Z field of lop\_post...@>
 continue;
case lop_stab: err("Symbol table must follow postamble");
@.Symbol table...@>
case lop_end: err("Symbol table can't end before it begins");

@* The preamble and postamble. Now here's what we do before and after
the main loop.

@<List the preamble@>=
read_tet(); /* read the first tetrabyte of input */
if (buf[0]!=mm || buf[1]!=lop_pre) {
  fprintf(stderr,"Input is not an MMO file (first two bytes are wrong)!\n");
@.Input is not...@>
  exit(-5);
}
if (y!=1) fprintf(stderr,
    "Warning: I'm reading this file as version 1, not version %d!\n",y);
@.I'm reading this file...@>
if (z>0) {
  j=z;
  read_tet();
  if (listing)
    printf("File was created %s",asctime(localtime((time_t*)&tet)));
  for (j--;j>0;j--) {
    read_tet();
    if (listing) printf("Preamble data %08x\n",tet);
  }
}

@ @<List the postamble@>=
for (j=z;j<256;j++) {
  read_tet();@+tmp.h=tet;@+read_tet();
  if (listing) {
    if (tmp.h || tet) printf("g%03d: %08x%08x\n",j,tmp.h,tet);
    else printf("g%03d: 0\n",j);
  }
}

@* The symbol table. Finally we come to the symbol table, which is
the most interesting part of this program because it recursively
traces an implicit ternary trie structure.

@<List the symbol table@>=
read_tet();
if (buf[0]!=mm || buf[1]!=lop_stab) {
  fprintf(stderr,"Symbol table does not follow the postamble!\n");
@.Symbol table...@>
  exit(-6);
}
if (yz) fprintf(stderr,"YZ field of lop_stab should be zero!\n");
@.YZ field...should be zero@>
printf("Symbol table (beginning at tetra %d):\n",count);
stab_start=count;
sym_ptr=sym_buf;
print_stab();
@<Check the |lop_end|@>;

@ The main work is done by a recursive subroutine called |print_stab|,
which manipulates a global array |sym_buf| containing the current
symbol prefix; the global variable |sym_ptr| points to the first
unfilled character of that array.

@<Sub...@>=
void print_stab @,@,@[ARGS((void))@];
void print_stab()
{
  register int m=read_byte(); /* the master control byte */
  register int c; /* the character at the current trie node */
  register int j,k;
  if (m&0x40) print_stab(); /* traverse the left subtrie, if it is nonempty */
  if (m&0x2f) {
    @<Read the character |c|@>;
    *sym_ptr++=c;
    if (sym_ptr==&sym_buf[sym_length_max]) {
      fprintf(stderr,"Oops, the symbol is too long!\n");@+exit(-7);
@.Oops...too long@>
    }
    if (m&0xf)
      @<Print the current symbol with its equivalent and serial number@>;
    if (m&0x20) print_stab(); /* traverse the middle subtrie */
    sym_ptr--;
  }
  if (m&0x10) print_stab(); /* traverse the right subtrie, if it is nonempty */
}

@ The present implementation doesn't support Unicode; characters with
more than 8-bit codes are printed as `\.?'. However, the changes
for 16-bit codes would be quite easy if proper fonts for Unicode output
were available. In that case, |sym_buf| would be an array of wyde characters.
@^Unicode@>
@^system dependencies@>

@<Read the character |c|@>=
if (m&0x80) j=read_byte(); /* 16-bit character */
else j=0;  
c=read_byte();
if (j) c='?'; /* oops, we can't print |(j<<8)+c| easily at this time */

@ @<Print the current symbol with its equivalent and serial number@>=
{
  *sym_ptr='\0';
  j=m&0xf;
  if (j==15) sprintf(equiv_buf,"$%03d",read_byte());
  else if (j<=8) {
    strcpy(equiv_buf,"#");
    for (;j>0;j--) sprintf(equiv_buf+strlen(equiv_buf),"%02x",read_byte());
    if (strcmp(equiv_buf,"#0000")==0) strcpy(equiv_buf,"?"); /* undefined */
  }@+else {
    strncpy(equiv_buf,"#20000000000000",33-2*j);
    equiv_buf[33-2*j]='\0';
    for (;j>8;j--) sprintf(equiv_buf+strlen(equiv_buf),"%02x",read_byte());
  }
  for (j=k=read_byte();; k=read_byte(),j=(j<<7)+k) if (k>=128) break;
    /* the serial number is now $j-128$ */
  printf("    %s = %s (%d)\n",sym_buf+1,equiv_buf,j-128);
}

@ @d sym_length_max 1000

@<Glob...@>=
int stab_start; /* where the symbol table began */
char sym_buf[sym_length_max];
   /* the characters on middle transitions to current node */
char *sym_ptr; /* the character in |sym_buf| following the current prefix */
char equiv_buf[20]; /* equivalent of the current symbol */

@ @<Check the |lop_end|@>=
while (byte_count)
  if (read_byte()) fprintf(stderr,"Nonzero byte follows the symbol table!\n");
@.Nonzero byte follows...@>
read_tet();
if (buf[0]!=mm || buf[1]!=lop_end)
  fprintf(stderr,"The symbol table isn't followed by lop_end!\n");
@.The symbol table isn't...@>
else if (count!=stab_start+yz+1)
  fprintf(stderr,"YZ field at lop_end should have been %d!\n",count-yz-1);
@:YZ field at lop_end...}\.{YZ field at lop\_end...@>
else {
  if (verbose) printf("Symbol table ends at tetra %d.\n",count);
  if (fread(buf,1,1,mmo_file))
    fprintf(stderr,"Extra bytes follow the lop_end!\n");
@.Extra bytes follow...@>
}


@* Index.
