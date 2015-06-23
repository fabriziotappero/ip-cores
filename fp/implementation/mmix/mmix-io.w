% This file is part of the MMIXware package (c) Donald E Knuth 1999
@i boilerplate.w %<< legal stuff: PLEASE READ IT BEFORE MAKING ANY CHANGES!

\def\title{MMIX-IO}
\def\MMIX{\.{MMIX}}
\def\Hex#1{\hbox{$^{\scriptscriptstyle\#}$\tt#1}} % experimental hex constant

@*Introduction. This program module contains brute-force implementations
of the ten input/output primitives defined at the beginning of {\mc MMIX-SIM}.
The subroutines are grouped here as a separate package, because they
are intended to be loaded with the pipeline simulator as well as with the
simple simulator.
@^I/O@>
@^input/output@>

@c
@<Preprocessor macros@>@;
@<Type definitions@>@;
@<External subroutines@>@;
@<Global variables@>@;
@<Subroutines@>@;

@ Of course we include standard \CEE/ library routines, and we set things
up to accommodate older versions of \CEE/.

@<Preproc...@>=
#include <stdio.h>
#include <stdlib.h>
#ifdef __STDC__
#define ARGS(list) list
#else
#define ARGS(list) ()
#endif
#ifndef FILENAME_MAX
#define FILENAME_MAX 256
#endif
#ifndef SEEK_SET
#define SEEK_SET 0
#endif
#ifndef SEEK_END
#define SEEK_END 2
#endif

@ The unsigned 32-bit type \&{tetra} must agree with its definition
in the simulators.

@<Type...@>=
typedef unsigned int tetra;
typedef struct {tetra h,l;} octa; /* two tetrabytes make one octabyte */

@ Three basic subroutines are used to get strings from the simulated
memory and to put strings into that memory. These subroutines are
defined appropriately in each simulator. We also use a few subroutines
and constants defined in {\mc MMIX-ARITH}.

@<External...@>=
extern char stdin_chr @,@,@[ARGS((void))@];
extern int mmgetchars @,@,@[ARGS((char* buf,int size,octa addr,int stop))@];
extern void mmputchars @,@,@[ARGS((unsigned char* buf,int size,octa addr))@];
extern octa oplus @,@,@[ARGS((octa,octa))@];
extern octa ominus @,@,@[ARGS((octa,octa))@];
extern octa incr @,@,@[ARGS((octa,int))@];
extern octa zero_octa; /* |zero_octa.h=zero_octa.l=0| */
extern octa neg_one; /* |neg_one.h=neg_one.l=-1| */

@ Each possible handle has a file pointer and a current mode.

@<Type...@>=
typedef struct {
  FILE *fp; /* file pointer */
  int mode; /* [read OK] + 2[write OK] + 4[binary] + 8[readwrite] */
} sim_file_info;

@ @<Glob...@>=
sim_file_info sfile[256];

@ The first three handles are initially open.

@<Sub...@>=
void mmix_io_init @,@,@[ARGS((void))@];@+@t}\6{@>
void mmix_io_init()
{
  sfile[0].fp=stdin, sfile[0].mode=1;
  sfile[1].fp=stdout, sfile[1].mode=2;
  sfile[2].fp=stderr, sfile[2].mode=2;
}

@ The only tricky thing about these routines is that we want to
protect the standard input, output, and error streams from being
preempted.

@<Sub...@>=
octa mmix_fopen @,@,@[ARGS((unsigned char,octa,octa))@];@+@t}\6{@>
octa mmix_fopen(handle,name,mode)
  unsigned char handle;
  octa name,mode;
{
  char name_buf[FILENAME_MAX];
  if (mode.h || mode.l>4) goto abort;
  if (mmgetchars(name_buf,FILENAME_MAX,name,0)==FILENAME_MAX) goto abort;
  if (sfile[handle].mode!=0 && handle>2) fclose(sfile[handle].fp);
  sfile[handle].fp=fopen(name_buf,mode_string[mode.l]);
  if (!sfile[handle].fp) goto abort;
  sfile[handle].mode=mode_code[mode.l];
  return zero_octa; /* success */
 abort: sfile[handle].mode=0;
  return neg_one; /* failure */
}

@ @<Glob...@>=
char *mode_string[]={"r","w","rb","wb","w+b"};
int mode_code[]={0x1,0x2,0x5,0x6,0xf};

@ If the simulator is being used interactively, we can avoid competition
for |stdin| by substituting another file.

@<Sub...@>=
void mmix_fake_stdin @,@,@[ARGS((FILE*))@];@+@t}\6{@>
void mmix_fake_stdin(f)
  FILE *f;
{
  sfile[0].fp=f; /* |f| should be open in mode \.{"r"} */
}

@ @<Sub...@>=
octa mmix_fclose @,@,@[ARGS((unsigned char))@];@+@t}\6{@>
octa mmix_fclose(handle)
  unsigned char handle;
{
  if (sfile[handle].mode==0) return neg_one;
  if (handle>2 && fclose(sfile[handle].fp)!=0) return neg_one;
  sfile[handle].mode=0;
  return zero_octa; /* success */
}

@ @<Sub...@>=
octa mmix_fread @,@,@[ARGS((unsigned char,octa,octa))@];@+@t}\6{@>
octa mmix_fread(handle,buffer,size)
  unsigned char handle;
  octa buffer,size;
{
  register unsigned char *buf;
  register int n;
  octa o;
  o=neg_one;
  if (!(sfile[handle].mode&0x1)) goto done;
  if (sfile[handle].mode&0x8) sfile[handle].mode &=~ 0x2;
  if (size.h) goto done;
  buf=(unsigned char*)calloc(size.l,sizeof(char));
  if (!buf) goto done;
  @<Read |n<=size.l| characters into |buf|@>;
  mmputchars(buf,n,buffer);
  free(buf);
  o.h=0, o.l=n;
done: return ominus(o,size);
}

@ @<Read |n<=size.l| characters into |buf|@>=
if (sfile[handle].fp==stdin) {
  register unsigned char *p;
  for (p=buf,n=size.l; p<buf+n; p++) *p=stdin_chr();
} else {
  clearerr(sfile[handle].fp);
  n=fread(buf,1,size.l,sfile[handle].fp);
  if (ferror(sfile[handle].fp)) {
    free(buf);
    goto done;
  }
}

@ @<Sub...@>=
octa mmix_fgets @,@,@[ARGS((unsigned char,octa,octa))@];@+@t}\6{@>
octa mmix_fgets(handle,buffer,size)
  unsigned char handle;
  octa buffer,size;
{
  char buf[256];
  register int n,s;
  register char *p;
  octa o;
  int eof=0;
  if (!(sfile[handle].mode&0x1)) return neg_one;
  if (!size.l && !size.h) return neg_one;
  if (sfile[handle].mode&0x8) sfile[handle].mode &=~ 0x2;
  size=incr(size,-1);
  o=zero_octa;
  while (1) {
    @<Read |n<256| characters into |buf|@>;
    mmputchars(buf,n+1,buffer);
    o=incr(o,n);
    size=incr(size,-n);
    if ((n&&buf[n-1]=='\n') || (!size.l&&!size.h) || eof) return o;
    buffer=incr(buffer,n);
  }
}

@ @<Read |n<256| characters into |buf|@>=
s=255;
if (size.l<s && !size.h) s=size.l;
if (sfile[handle].fp==stdin)
  for (p=buf,n=0;n<s;) {
    *p=stdin_chr();
    n++;
    if (*p++=='\n') break;
  }
else {
  if (!fgets(buf,s+1,sfile[handle].fp)) return neg_one;
  eof=feof(sfile[handle].fp);
  for (p=buf,n=0;n<s;) {
    if (!*p && eof) break;
    n++;
    if (*p++=='\n') break;
  }
}
*p='\0';

@ The routines that deal with wyde characters might need to be
changed on a system that is little-endian; the author wishes
good luck to whoever has to do this.
\MMIX\ is always big-endian, but external files
prepared on random operating systems might be backwards.
@^little-endian versus big-endian@>
@^big-endian versus little-endian@>
@^system dependencies@>

@<Sub...@>=
octa mmix_fgetws @,@,@[ARGS((unsigned char,octa,octa))@];@+@t}\6{@>
octa mmix_fgetws(handle,buffer,size)
  unsigned char handle;
  octa buffer,size;
{
  char buf[256];
  register int n,s;
  register char *p;
  octa o;
  int eof;
  if (!(sfile[handle].mode&0x1)) return neg_one;
  if (!size.l && !size.h) return neg_one;
  if (sfile[handle].mode&0x8) sfile[handle].mode &=~ 0x2;
  buffer.l&=-2;
  size=incr(size,-1);
  o=zero_octa;
  while (1) {
    @<Read |n<128| wyde characters into |buf|@>;
    mmputchars(buf,2*n+2,buffer);
    o=incr(o,n);
    size=incr(size,-n);
    if ((n&&buf[2*n-1]=='\n'&&buf[2*n-2]==0) || (!size.l&&!size.h) || eof)
      return o;
    buffer=incr(buffer,2*n);
  }
}

@ @<Read |n<128| wyde characters into |buf|@>=
s=127;
if (size.l<s && !size.h) s=size.l;
if (sfile[handle].fp==stdin)
  for (p=buf,n=0;n<s;) {
    *p++=stdin_chr();@+*p++=stdin_chr();
    n++;
    if (*(p-1)=='\n' && *(p-2)==0) break;
  }
else for (p=buf,n=0;n<s;) {
  if (fread(p,1,2,sfile[handle].fp)!=2) {
    eof=feof(sfile[handle].fp);
    if (!eof) return neg_one;
    break;
  }
  n++,p+=2;
    if (*(p-1)=='\n' && *(p-2)==0) break;
}
*p=*(p+1)='\0';

@ @<Sub...@>=
octa mmix_fwrite @,@,@[ARGS((unsigned char,octa,octa))@];@+@t}\6{@>
octa mmix_fwrite(handle,buffer,size)
  unsigned char handle;
  octa buffer,size;
{
  char buf[256];
  register int n;
  if (!(sfile[handle].mode&0x2)) return ominus(zero_octa,size);
  if (sfile[handle].mode&0x8) sfile[handle].mode &=~ 0x1;
  while (1) {
    if (size.h || size.l>=256) n=mmgetchars(buf,256,buffer,-1);
    else n=mmgetchars(buf,size.l,buffer,-1);
    size=incr(size,-n);
    if (fwrite(buf,1,n,sfile[handle].fp)!=n) return ominus(zero_octa,size);
    fflush(sfile[handle].fp);
    if (!size.l && !size.h) return zero_octa;
    buffer=incr(buffer,n);
  }
}

@ @<Sub...@>=
octa mmix_fputs @,@,@[ARGS((unsigned char,octa))@];@+@t}\6{@>
octa mmix_fputs(handle,string)
  unsigned char handle;
  octa string;
{
  char buf[256];
  register int n;
  octa o;
  o=zero_octa;
  if (!(sfile[handle].mode&0x2)) return neg_one;
  if (sfile[handle].mode&0x8) sfile[handle].mode &=~ 0x1;
  while (1) {
    n=mmgetchars(buf,256,string,0);
    if (fwrite(buf,1,n,sfile[handle].fp)!=n) return neg_one;
    o=incr(o,n);
    if (n<256) {
      fflush(sfile[handle].fp);
      return o;
    }
    string=incr(string,n);
  }
}

@ @<Sub...@>=
octa mmix_fputws @,@,@[ARGS((unsigned char,octa))@];@+@t}\6{@>
octa mmix_fputws(handle,string)
  unsigned char handle;
  octa string;
{
  char buf[256];
  register int n;
  octa o;
  o=zero_octa;
  if (!(sfile[handle].mode&0x2)) return neg_one;
  if (sfile[handle].mode&0x8) sfile[handle].mode &=~ 0x1;
  while (1) {
    n=mmgetchars(buf,256,string,1);
    if (fwrite(buf,1,n,sfile[handle].fp)!=n) return neg_one;
    o=incr(o,n>>1);
    if (n<256) {
      fflush(sfile[handle].fp);
      return o;
    }
    string=incr(string,n);
  }
}

@ @d sign_bit ((unsigned)0x80000000)

@<Sub...@>=
octa mmix_fseek @,@,@[ARGS((unsigned char,octa))@];@+@t}\6{@>
octa mmix_fseek(handle,offset)
  unsigned char handle;
  octa offset;
{
  if (!(sfile[handle].mode&0x4)) return neg_one;
  if (sfile[handle].mode&0x8) sfile[handle].mode = 0xf;
  if (offset.h&sign_bit) {
    if (offset.h!=0xffffffff || !(offset.l&sign_bit)) return neg_one;
    if (fseek(sfile[handle].fp,(int)offset.l+1,SEEK_END)!=0) return neg_one;
  }@+else {
    if (offset.h || (offset.l&sign_bit)) return neg_one;
    if (fseek(sfile[handle].fp,(int)offset.l,SEEK_SET)!=0) return neg_one;
  }
  return zero_octa;
}

@ @<Sub...@>=
octa mmix_ftell @,@,@[ARGS((unsigned char))@];@+@t}\6{@>
octa mmix_ftell(handle)
  unsigned char handle;
{
  register long x;
  octa o;
  if (!(sfile[handle].mode&0x4)) return neg_one;
  x=ftell(sfile[handle].fp);
  if (x<0) return neg_one;
  o.h=0, o.l=x;  
  return o;
}

@ One last subroutine belongs here, just in case the user has
modified the standard error handle.

@<Sub...@>=
void print_trip_warning @,@,@[ARGS((int,octa))@];@+@t}\6{@>
void print_trip_warning(n,loc)
  int n;
  octa loc;
{
  if (sfile[2].mode&0x2)
    fprintf(sfile[2].fp,"Warning: %s at location %08x%08x\n",
             trip_warning[n],loc.h,loc.l);
}

@ @<Glob...@>=
char *trip_warning[]={
"TRIP",
"integer divide check",
"integer overflow",
"float-to-fix overflow",
"invalid floating point operation",
"floating point overflow",
"floating point underflow",
"floating point division by zero",
"floating point inexact"};

@* Index.
