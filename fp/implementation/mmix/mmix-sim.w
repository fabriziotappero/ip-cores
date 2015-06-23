% This file is part of the MMIXware package (c) Donald E Knuth 1999
@i boilerplate.w %<< legal stuff: PLEASE READ IT BEFORE MAKING ANY CHANGES!

\def\title{MMIX-SIM}
\def\MMIX{\.{MMIX}}
\def\NNIX{\hbox{\mc NNIX}}
\def\Hex#1{\hbox{$^{\scriptscriptstyle\#}$\tt#1}} % experimental hex constant
\def\<#1>{\hbox{$\langle\,$#1$\,\rangle$}}\let\is=\longrightarrow
\def\dts{\mathinner{\ldotp\ldotp}}
\def\bull{\smallskip\textindent{$\bullet$}}
@s xor normal @q unreserve a C++ keyword @>
@s bool normal @q unreserve a C++ keyword @>

@*Introduction. This program simulates a simplified version of the \MMIX\
computer. Its main goal is to help people create and test \MMIX\ programs for
{\sl The Art of Computer Programming\/} and related publications. It provides
only a rudimentary terminal-oriented interface, but it has enough
infrastructure to support a cool graphical user interface --- which could be
added by a motivated reader. (Hint, hint.)

\MMIX\ is simplified in the following ways:

\bull
There is no pipeline, and there are no
caches. Thus, commands like \.{SYNC} and \.{SYNCD} and \.{PREGO} do nothing.

\bull
Simulation applies only to user programs, not to an operating system kernel.
Thus, all addresses must be nonnegative; ``privileged'' commands such as
\.{PUT}~\.{rK,z} or \.{RESUME}~\.1 or \.{LDVTS}~\.{x,y,z} are not allowed;
instructions should be executed only from addresses in segment~0
(addresses less than \Hex{2000000000000000}).
Certain special registers remain constant: $\rm rF=0$,
$\rm rK=\Hex{ffffffffffffffff}$,
$\rm rQ=0$;
$\rm rT=\Hex{8000000500000000}$,
$\rm rTT=\Hex{8000000600000000}$,
$\rm rV=\Hex{369c200400000000}$.

\bull
No trap interrupts are implemented, except for a few special cases of \.{TRAP}
that provide rudimentary input-output.
@^interrupts@>

\bull
All instructions take a fixed amount of time, given by the rough estimates
stated in the \MMIX\ documentation. For example, \.{MUL} takes $10\upsilon$,
\.{LDB} takes $\mu+\upsilon\mkern1mu$; all times are expressed in terms of
$\mu$ and~$\upsilon$, ``mems'' and ``oops.'' The clock register~rC increases by
@^mems@>
@^oops@>
$2^{32}$ for each~$\mu$ and 1~for each~$\upsilon$. But the interval
counter~rI decreases by~1 for each instruction, and the usage
counter~rU increases by~1 for each instruction.
@^rC@>
@^rI@>
@^rU@>

@ To run this simulator, assuming \UNIX/ conventions, you say
`\.{mmix} \<options> \.{progfile} \.{args...}',
where \.{progfile} is an output of the \.{MMIXAL} assembler,
\.{args...} is a sequence of optional command-line arguments passed
to the simulated program, and \<options> is any subset of the following:
@^command line arguments@>

\bull \.{-t<n>}\quad Trace each instruction the first $n$ times it
is executed. (The notation \.{<n>} in this option, and in several
other options and interactive commands below, stands for a decimal integer.)

\bull \.{-e<x>}\quad Trace each instruction that raises an arithmetic
exception belonging to the given bit pattern. (The notation \.{<x>} in this
option, and in several other commands below, stands for a hexadecimal integer.)
The exception bits are DVWIOUZX as they appear in rA, namely
\Hex{80} for~D (integer divide check), \Hex{40} for~V (integer overflow),
\dots, \Hex{01} for~X (floating inexact). The option \.{-e} by itself
is equivalent to \.{-eff}, tracing all eight exceptions.

\bull \.{-r}\quad Trace details of the register stack. This option
shows all the ``hidden'' loads and stores that occur when octabytes are
written from the ring of local registers into memory, or read from memory into
that ring. It also shows the full details of \.{SAVE} and \.{UNSAVE}
operations.

\bull \.{-l<n>}\quad List the source line corresponding to each traced
instruction, filling gaps of length $n$ or less.
For example, if one instruction came from line 10 of the source file
and the next instruction to be traced came from line 12, line 11 would
be shown also, provided that $n\ge1$. If \.{<n>} is omitted it is
assumed to be~3.

\bull \.{-s}\quad Show statistics of running time with each traced instruction.

\bull \.{-P}\quad Show the program profile (that is, the frequency counts
of each instruction that was executed) when the simulation ends.

\bull \.{-L<n>}\quad List the source lines corresponding to each instruction
that appears in the program profile, filling gaps of length $n$ or less.
This option implies \.{-P}.  If \.{<n>} is omitted it is assumed to be~3.

\bull \.{-v}\quad Be verbose: \kern-2.5ptTurn on all options.
(More precisely, the \.{-v} option is
shorthand for \.{-t9999999999}~\.{-e} \.{-r} \.{-s} \.{-l10}~\.{-L10}.)

\bull \.{-q}\quad Be quiet: Cancel all previously specified options.

\bull \.{-i}\quad Go into interactive mode before starting the simulation.

\bull \.{-I}\quad Go into interactive mode when the simulated program
halts or pauses for a breakpoint.

\bull \.{-b<n>}\quad Set the buffer size of source lines to $\max(72,n)$.

\bull \.{-c<n>}\quad Set the capacity of the local register ring
to $\max(256,n)$; this number must be a power of~2.

\bull \.{-f<filename>}\quad Use the named file for standard input to the
simulated program. This option should be used whenever the simulator
is not being used interactively, because the simulator will not recognize
end of file when standard input has been defined in any other way.

\bull \.{-D<filename>}\quad Prepare the named file for use by other
simulators, instead of actually doing a simulation.

\bull \.{-?}\quad Print the ``\.{Usage}'' message, which summarizes
the command-line options.

\smallskip\noindent
The author recommends \.{-t2} \.{-l} \.{-L} for initial offline debugging.

While the program is being simulated, an {\it interrupt\/}
signal (usually control-C) will cause the simulator to
@^interrupts@>
break and go into interactive mode after tracing the current instruction,
even if \.{-i} and \.{-I} were not specified on the command line.

@ In interactive mode, the user is prompted `\.{mmix>}' and a variety of
@.mmix>@>
commands can be typed online. Any command-line option can be given
in response to such a prompt (including the `\.-' that begins the option),
and the following operations are also available:

\bull Simply typing \<return> or \.n\<return> to the \.{mmix>} prompt causes
one \MMIX\ instruction to be executed and traced; then the user is prompted
again.

\bull \.c continues simulation until the program halts or reaches
a breakpoint. (Actually the command is `\.c\<return>', but we won't
bother to mention the \<return> in the following description.)

\bull \.q quits (terminates the simulation), after printing the
profile (if it was requested) and the final statistics.

\bull \.s prints out the current statistics (the clock times and the
current instruction location). We have already discussed the \.{-s} option
on the command line, which
causes these statistics to be printed automatically;
but a lot of statistics can fill up a lot of file space, so users may
prefer to see the statistics only on demand.

\bull \.{l<n><t>}, \.{g<n><t>}, \.{\$<n><t>}, \.{rA<t>}, \.{rB<t>}, \dots,
\.{rZZ<t>}, and \.{M<x><t>} will show the current value of a local register,
global register, dynamically numbered register, special register, or memory
location. Here \.{<t>} specifies the type of value to be displayed;
if \.{<t>} is `\.!', the value will be given in decimal notation;
if \.{<t>} is `\..' it will be given in floating point notation;
if \.{<t>} is `\.\#' it will be given in hexadecimal, and
if \.{<t>} is `\."'  it will be given as a string of eight one-byte
characters. Just typing \.{<t>} by itself will repeat the most recently shown
value, perhaps in another format; for example, the command `\.{l10\#}'
will show local register 10 in hexadecimal notation, then the command
`\.!' will show it in decimal and `\..' will show it as a floating point
number. If \.{<t>} is empty, the previous type will be repeated;
the default type is decimal. Register \.{rA} is equivalent to \.{g22},
according to the numbering used in \.{GET} and \.{PUT} commands.

The `\.{<t>}' in any of these commands can also have the form
`\.{=<value>}', where the value is a decimal or floating point or
hexadecimal or string constant. (The syntax rules for floating point constants
appear in {\mc MMIX-ARITH}. A string constant is treated as in the
\.{BYTE} command of \.{MMIXAL}, but padded at the left with zeros if
fewer than eight characters are specified.) This assigns a new value
before displaying it. For example, `\.{l10=.1e3}'
sets local register 10 equal to 100; `\.{g250="ABCD",\#a}' sets global
register 250 equal to \Hex{000000414243440a}; `\.{M1000=-Inf}' sets
M$[\Hex{1000}]_8=\Hex{fff0000000000000}$, the representation of $-\infty$.
Special registers other than~rI cannot be set to values disallowed by~\.{PUT}.
Marginal registers cannot be set to nonzero values.

The command `\.{rI=250}' sets the interval counter to 250; this will
cause a break in simulation after 250 instructions have been executed.

\bull \.{+<n><t>} shows the next $n$ octabytes following the one
most recently shown, in format \.{<t>}. For example, after `\.{l10\#}'
a subsequent `\.{+30}' will show \.{l11}, \.{l12}, \dots, \.{l40} in
hexadecimal notation. After `\.{g200=3}' a subsequent `\.{+30}' will
set \.{g201}, \.{g202}, \dots, \.{g230} equal to~3, but a subsequent
`\.{+30!}' would merely display \.{g201} through~\.{g230} in decimal
notation. Memory addresses will advance by~8 instead of by~1. If \.{<n>}
is empty, the default value $n=1$ is used.

\bull \.{@@<x>} sets the address of the next tetrabyte to be
simulated, sort of like a \.{GO} command.

\bull \.{t<x>} says that the instruction in tetrabyte location $x$ should
always be traced, regardless of its frequency count.

\bull \.{u<x>} undoes the effect of \.{t<x>}.

\bull \.{b[rwx]<x>} sets breakpoints at tetrabyte $x$; here \.{[rwx]}
stands for any subset of the letters \.r, \.w, and/or~\.x, meaning to
break when the tetrabyte is read, written, and/or executed. For example,
`\.{bx1000}' causes a break in the simulation just after the tetrabyte
in \Hex{1000} is executed; `\.{b1000}' undoes this breakpoint;
`\.{brwx1000}' causes a break just after any simulated instruction loads,
stores, or appears in tetrabyte number \Hex{1000}.

\bull \.{T}, \.{D}, \.{P}, \.{S} sets the ``current segment'' to
\.{Text\_Segment}, \.{Data\_Segment}, \.{Pool\_Segment}, or
\.{Stack\_Segment}, respectively, namely to \Hex{0}, \Hex{2000000000000000},
\Hex{4000000000000000}, or \Hex{6000000000000000}. The current segment,
initially \Hex{0}, is added to all
memory addresses in \.{M}, \.{@@}, \.{t}, \.{u}, and \.{b} commands.
@:Text_Segment}\.{Text\_Segment@>
@:Data_Segment}\.{Data\_Segment@>
@:Pool_Segment}\.{Pool\_Segment@>
@:Stack_Segment}\.{Stack\_Segment@>

\bull \.{B} lists all current breakpoints and tracepoints.

\bull \.{i<filename>} reads a sequence of interactive commands from the
specified file, one command per line, ignoring blank lines. This feature
can be used to set many breakpoints or to display a number of key
registers, etc. Included lines that begin with \.\% or \.i are ignored;
therefore an included file cannot include {\it another\/} file. 
Included lines that begin with a blank space are reproduced in the standard
output, otherwise ignored.

\bull \.h (help) reminds the user of the available interactive commands.

@* Rudimentary I/O.
Input and output are provided by the following ten primitive system calls:
@^I/O@>
@^input/output@>

\bull \.{Fopen}|(handle,name,mode)|. Here |handle| is a
one-byte integer, |name| is a string, and |mode| is one of the
values \.{TextRead}, \.{TextWrite}, \.{BinaryRead}, \.{BinaryWrite},
\.{BinaryReadWrite}. An \.{Fopen} call associates |handle| with the
external file called |name| and prepares to do input and/or output
on that file. It returns 0 if the file was opened successfully; otherwise
returns the value~$-1$. If |mode| is \.{TextWrite}, \.{BinaryWrite}, or
\.{BinaryReadWrite},
any previous contents of the named file are discarded. If |mode| is
\.{TextRead} or \.{TextWrite}, the file consists of ``lines'' terminated
by ``newline'' characters, and it is said to be a text file; otherwise
the file consists of uninterpreted bytes, and it is said to be a binary file.
@.Fopen@>
@.TextRead@>
@.TextWrite@>
@.BinaryRead@>
@.BinaryWrite@>
@.BinaryReadWrite@>

Text files and binary files are essentially equivalent in cases
where this simulator is hosted by an operating system derived from \UNIX/;
in such cases files can be written as text and read as binary or vice versa.
But with other operating systems, text files and binary files often have
quite different representations, and certain characters with byte
codes less than~|' '| are forbidden in text. Within any \MMIX\ program,
the newline character has byte code $\Hex{0a}=10$.

At the beginning of a program three handles have already been opened: The
``standard input'' file \.{StdIn} (handle~0) has mode \.{TextRead}, the
``standard output'' file \.{StdOut} (handle~1) has mode \.{TextWrite}, and the
``standard error'' file \.{StdErr} (handle~2) also has mode \.{TextWrite}.
@.StdIn@>
@.StdOut@>
@.StdErr@>
When this simulator is being run interactively, lines of standard input
should be typed following a prompt that says `\.{StdIn>\ }', unless the \.{-f}
option has been used.
The standard output and standard error files of the simulated program
are intermixed with the output of the simulator~itself.

The input/output operations supported by this simulator can perhaps be
understood most easily with reference to the standard library \.{stdio}
that comes with the \CEE/ language, because the conventions of~\CEE/
have been explained in hundreds of books. If we declare an array
|FILE *file[256]| and set |file[0]=stdin|, |file[1]=stdout|, and
|file[2]=stderr|, then the simulated system call \.{Fopen}|(handle,name,mode)|
is essentially equivalent to the \CEE/ expression
$$\displaylines{
\hskip5em\hbox{(|file[handle]|?
     |(file[handle]=freopen(name,mode_string[mode],file[handle]))|:}\hfill\cr
\hfill\hbox{|(file[handle]=fopen(name,mode_string[mode]))|)? 0: $-1$},%
      \hskip5em\cr}$$
if we set |mode_string|[\.{TextRead}]~=~|"r"|,
|mode_string|[\.{TextWrite}]~=~|"w"|,
|mode_string|[\.{BinaryRead}]~=~|"rb"|,
|mode_string|[\.{BinaryWrite}]~=~|"wb"|, and
|mode_string|[\.{BinaryReadWrite}]~=~|"wb+"|.

\bull \.{Fclose}|(handle)|. If the given file handle has been opened, it is
closed---no longer associated with any file. Again the result is 0 if
successful, or $-1$ if the file was already closed or unclosable.
The \CEE/ equivalent is
$$\hbox{|fclose(file[handle])? -1: 0|}$$
with the additional side effect of setting |file[handle]=NULL|.

\bull \.{Fread}|(handle,buffer,size)|.
The file handle should have been opened with mode \.{TextRead},
\.{BinaryRead}, or \.{BinaryReadWrite}.
@.Fread@>
The next |size| characters are read into \MMIX's memory starting at address
|buffer|. If an error occurs, the value |-1-size| is returned;
otherwise, if the end of file does not intervene, 0~is returned;
otherwise the negative value |n-size| is returned, where |n|~is the number of
characters successfully read and stored. The statement
$$\hbox{|fread(buffer,1,size,file[handle])-size|}$$
has the equivalent effect in \CEE/, in the absence of file errors.

\bull \.{Fgets}|(handle,buffer,size)|.
The file handle should have been opened with mode \.{TextRead},
\.{BinaryRead}, or \.{BinaryReadWrite}.
@.Fgets@>
Characters are read into \MMIX's memory starting at address |buffer|, until
either |size-1| characters have been read and stored or a newline character has
been read and stored; the next byte in memory is then set to zero.
If an error or end of file occurs before reading is complete, the memory
contents are undefined and the value $-1$ is returned; otherwise
the number of characters successfully read and stored is returned.
The equivalent in \CEE/ is
$$\hbox{|fgets(buffer,size,file[handle])? strlen(buffer): -1|}$$
if we assume that no null characters were read in; null characters may,
however, precede a newline, and they are counted just like other characters.

\bull \.{Fgetws}|(handle,buffer,size)|.
@.Fgetws@>
This command is the same as \.{Fgets}, except that it applies to wyde
characters instead of one-byte characters. Up to |size-1| wyde
characters are read; a wyde newline is $\Hex{000a}$. The \CEE/~version,
using conventions of the ISO multibyte string extension (MSE), is
@^MSE@>
approximately
$$\hbox{|fgetws(buffer,size,file[handle])? wcslen(buffer): -1|}$$
where |buffer| now has type |wchar_t*|.

\bull \.{Fwrite}|(handle,buffer,size)|.
The file handle should have been opened with one of the modes \.{TextWrite},
\.{BinaryWrite}, or \.{BinaryReadWrite}.
@.Fwrite@>
The next |size| characters are written from \MMIX's memory starting at address
|buffer|. If no error occurs, 0~is returned;
otherwise the negative value |n-size| is returned, where |n|~is the number of
characters successfully written. The statement
$$\hbox{|fwrite(buffer,1,size,file[handle])-size|}$$
together with |fflush(file[handle])| has the equivalent effect in \CEE/.

\bull \.{Fputs}|(handle,string)|.
The file handle should have been opened with mode \.{TextWrite},
\.{BinaryWrite}, or \.{BinaryReadWrite}.
@.Fputs@>
One-byte characters are written from \MMIX's memory to the file, starting
at address |string|, up to but not including the first byte equal to~zero.
The number of bytes written is returned, or $-1$ on error.
The \CEE/ version is
$$\hbox{|fputs(string,file[handle])>=0? strlen(string): -1|,}$$
together with |fflush(file[handle])|.

\bull \.{Fputws}|(handle,string)|.
The file handle should have been opened with mode \.{TextWrite},
\.{BinaryWrite}, or \.{BinaryReadWrite}.
@.Fputws@>
Wyde characters are written from \MMIX's memory to the file, starting
at address |string|, up to but not including the first wyde equal to~zero.
The number of wydes written is returned, or $-1$ on error.
The \CEE/+MSE version is
$$\hbox{|fputws(string,file[handle])>=0? wcslen(string): -1|}$$
together with |fflush(file[handle])|, where |string| now has type |wchar_t*|.

\bull \.{Fseek}|(handle,offset)|.
The file handle should have been opened with mode \.{BinaryRead},
\.{BinaryWrite}, or \.{BinaryReadWrite}.
@.Fseek@>
This operation causes the next input or output operation to begin at
|offset| bytes from the beginning of the file, if |offset>=0|, or at
|-offset-1| bytes before the end of the file, if |offset<0|. (For
example, |offset=0| ``rewinds'' the file to its very beginning;
|offset=-1| moves forward all the way to the end.) The result is 0
if successful, or $-1$ if the stated positioning could not be done.
The \CEE/ version is
$$\hbox{|fseek(file[handle],@,offset<0? offset+1: offset,@,
              offset<0? SEEK_END: SEEK_SET)|? $-1$: 0.}$$
If a file in mode \.{BinaryReadWrite} is used for both reading and writing,
an \.{Fseek} command must be given when switching from input to output
or from output to input.

\bull \.{Ftell}|(handle)|.
The file handle should have been opened with mode \.{BinaryRead},
\.{BinaryWrite}, or \.{BinaryReadWrite}.
@.Ftell@>
This operation returns the current file position, measured in bytes
from the beginning, or $-1$ if an error has occurred. In this case the
\CEE/ function
$$\hbox{|ftell(file[handle])|}$$
has exactly the same meaning.

\smallskip
Although these ten operations are quite primitive, they provide
the necessary functionality for extremely complex input/output behavior.
For example, every function in the \.{stdio} library of \CEE/,
with the exception of the two administrative operations \\{remove} and
\\{rename}, can be implemented as a subroutine in terms of the six basic
operations \.{Fopen}, \.{Fclose}, \.{Fread}, \.{Fwrite}, \.{Fseek}, and
\.{Ftell}.

Notice that the \MMIX\ function calls are much more consistent than
those in the \CEE/ library. The first argument is always a handle;
the second, if present, is always an address; the third, if present,
is always a size. {\it The result returned is always nonnegative if the
operation was successful, negative if an anomaly arose.} These common
features make the functions reasonably easy to remember.

@ The ten input/output operations of the previous section are invoked by
\.{TRAP} commands with $\rm X=0$, $\rm Y=\.{Fopen}$ or \.{Fclose} or \dots~or
\.{Ftell}, and $\rm Z=\.{Handle}$. If~there are two arguments, the
second argument is placed in \$255. If there are three arguments,
the address of the second is placed in~\$255; the second argument
is M$[\$255]_8$ and the third argument is M$[\$255+8]_8$. The returned
value will be in \$255 when the system call is finished. (See the
example below.)

@ The user program starts at symbolic location \.{Main}. At this time
@.Main@>
@:Pool_Segment}\.{Pool\_Segment@>
the global registers are initialized according to the \.{GREG}
statements in the \.{MMIXAL} program, and \$255 is set to the
numeric equivalent of~\.{Main}. Local register~\$0 is
initially set to the number of {\it command-line arguments\/}; and
@^command line arguments@>
local register~\$1 points to the first such argument, which
is always a pointer to the program name. Each command-line argument is a
pointer to a string; the last such pointer is M$[\$0\ll3+\$1]_8$, and
M$[\$0\ll3+\$1+8]_8$ is zero. (Register~\$1 will point to an octabyte in
\.{Pool\_Segment}, and the command-line strings will be in that segment
too.) Location M[\.{Pool\_Segment}] will be the address of the first
unused octabyte of the pool segment.

Registers rA, rB, rD, rE, rF, rH, rI, rJ, rM, rP, rQ, and rR
are initially zero, and $\rm rL=2$.

A subroutine library loaded with the user program might need to initialize
itself. If an instruction has been loaded into tetrabyte M$[\Hex{90}]_4$,
the simulator actually begins execution at \Hex{90} instead of at~\.{Main};
in this case \$255 holds the location of~\.{Main}.
@^subroutine library initialization@>
@^initialization of a user program@>
(The routine at \Hex{90} can pass control to \.{Main} without increasing~rL,
if it starts with the slightly tricky sequence
$$\.{PUT rW, \$255;{ } PUT rB, \$255;{ } SETML \$255,\#F700;{ } % PUTI rB,0!
      PUT rX,\$255}$$
and eventually says \.{RESUME}; this \.{RESUME} command will restore
\$255 and~rB. But the user program should {\it not\/} really count on
the fact that rL is initially~2.)

@ The main program ends when \MMIX\ executes the system
call \.{TRAP}~\.{0}, which is often symbolically written
`\.{TRAP}~\.{0,Halt,0}' to make its intention clear. The contents
of \$255 at that time are considered to be the value ``returned''
by the main program, as in the |exit| statement of~\CEE/; a nonzero
value indicates an anomalous exit. All open files are closed
@.Halt@>
when the program ends.

@ Here, for example, is a complete program that copies a text file
to the standard output, given the name of the file to be copied.
It includes all necessary error checking.
\vskip-14pt
$$\baselineskip=10pt
\obeyspaces\halign{\qquad\.{#}\hfil\cr
* SAMPLE PROGRAM: COPY A GIVEN FILE TO STANDARD OUTPUT\cr
\noalign{\smallskip}
t        IS   \$255\cr
argc     IS   \$0\cr
argv     IS   \$1\cr
s        IS   \$2\cr
Buf\_Size IS   1000\cr
{}         LOC  Data\_Segment\cr
Buffer   LOC  @@+Buf\_Size\cr
{}         GREG @@\cr
Arg0     OCTA 0,TextRead\cr
Arg1     OCTA Buffer,Buf\_Size\cr
\noalign{\smallskip}
{}         LOC  \#200              main(argc,argv) \{\cr
Main     CMP  t,argc,2          if (argc==2) goto openit\cr
{}         PBZ  t,OpenIt\cr
{}         GETA t,1F              fputs("Usage: ",stderr)\cr
{}         TRAP 0,Fputs,StdErr\cr
{}         LDOU t,argv,0          fputs(argv[0],stderr)\cr
{}         TRAP 0,Fputs,StdErr\cr
{}         GETA t,2F              fputs(" filename\\n",stderr)\cr
Quit     TRAP 0,Fputs,StdErr    \cr
{}         NEG  t,0,1             quit: exit(-1)\cr
{}         TRAP 0,Halt,0\cr
1H       BYTE "Usage: ",0\cr
{}         LOC  (@@+3)\&-4          align to tetrabyte\cr
2H       BYTE " filename",\#a,0\cr
\noalign{\smallskip}
OpenIt   LDOU s,argv,8          openit: s=argv[1]\cr
{}         STOU s,Arg0\cr
{}         LDA  t,Arg0            fopen(argv[1],"r",file[3])\cr
{}         TRAP 0,Fopen,3\cr
{}         PBNN t,CopyIt          if (no error) goto copyit\cr
{}         GETA t,1F              fputs("Can't open file ",stderr)\cr
{}         TRAP 0,Fputs,StdErr\cr
{}         SET  t,s               fputs(argv[1],stderr)\cr
{}         TRAP 0,Fputs,StdErr\cr
{}         GETA t,2F              fputs("!\\n",stderr)\cr
{}         JMP  Quit              goto quit\cr
1H       BYTE "Can't open file ",0\cr
{}         LOC  (@@+3)\&-4          align to tetrabyte\cr
2H       BYTE "!",\#a,0\cr
\noalign{\smallskip}
CopyIt   LDA  t,Arg1            copyit:\cr
{}         TRAP 0,Fread,3         items=fread(buffer,1,buf\_size,file[3])\cr
{}         BN   t,EndIt           if (items < buf\_size) goto endit\cr
{}         LDA  t,Arg1            items=fwrite(buffer,1,buf\_size,stdout)\cr
{}         TRAP 0,Fwrite,StdOut\cr
{}         PBNN t,CopyIt          if (items >= buf\_size) goto copyit\cr
Trouble  GETA t,1F              trouble: fputs("Trouble w...!",stderr)\cr
{}         JMP  Quit              goto quit\cr
1H       BYTE "Trouble writing StdOut!",\#a,0\cr
\noalign{\smallskip}
EndIt    INCL t,Buf\_Size\cr
{}         BN   t,ReadErr         if (ferror(file[3])) goto readerr\cr
{}         STO  t,Arg1+8\cr
{}         LDA  t,Arg1            n=fwrite(buffer,1,items,stdout)\cr
{}         TRAP 0,Fwrite,StdOut\cr
{}         BN   t,Trouble         if (n < items) goto trouble\cr
{}         TRAP 0,Halt,0          exit(0)\cr
ReadErr  GETA t,1F              readerr: fputs("Trouble r...!",stderr)\cr
{}         JMP  Quit              goto quit \}\cr
1H       BYTE "Trouble reading!",\#a,0\cr
}$$

@* Basics. To get started, we define a type that provides semantic sugar.

@<Type...@>=
typedef enum {@!false,@!true}@+@!bool;

@ This program for the 64-bit \MMIX\ architecture is based on 32-bit integer
arithmetic, because nearly every computer available to the author at the time
of writing (1999) was limited in that way. It uses subroutines
from the {\mc MMIX-ARITH} module, assuming only that type \&{tetra}
represents unsigned 32-bit integers. The definition of \&{tetra}
given here should be changed, if necessary, to agree with the
definition in that module.
@^system dependencies@>

@<Type...@>=
typedef unsigned int tetra;
  /* for systems conforming to the LP-64 data model */
typedef struct {tetra h,l;} octa; /* two tetrabytes make one octabyte */
typedef unsigned char byte; /* a monobyte */

@ We declare subroutines twice, once with a prototype and once
with the old-style~\CEE/ conventions. The following hack makes
this work with new compilers as well as the old standbys.

@<Preprocessor macros@>=
#ifdef __STDC__
#define ARGS(list) list
#else
#define ARGS(list) ()
#endif

@ @<Sub...@>=
void print_hex @,@,@[ARGS((octa))@];@+@t}\6{@>
void print_hex(o)
  octa o;
{
  if (o.h) printf("%x%08x",o.h,o.l);
  else printf("%x",o.l);
}

@ Most of the subroutines in {\mc MMIX-ARITH} return an octabyte as
a function of two octabytes; for example, |oplus(y,z)| returns the
sum of octabytes |y| and~|z|. Division inputs the high 
half of a dividend in the global variable~|aux| and returns
the remainder in~|aux|.

@<Sub...@>=
extern octa zero_octa; /* |zero_octa.h=zero_octa.l=0| */
extern octa neg_one; /* |neg_one.h=neg_one.l=-1| */
extern octa aux,val; /* auxiliary data */
extern bool overflow; /* flag set by signed multiplication and division */
extern int exceptions; /* bits set by floating point operations */
extern int cur_round; /* the current rounding mode */
extern char *next_char; /* where a scanned constant ended */
extern octa oplus @,@,@[ARGS((octa y,octa z))@];
  /* unsigned $y+z$ */
extern octa ominus @,@,@[ARGS((octa y,octa z))@];
  /* unsigned $y-z$ */
extern octa incr @,@,@[ARGS((octa y,int delta))@];
  /* unsigned $y+\delta$ ($\delta$ is signed) */
extern octa oand @,@,@[ARGS((octa y,octa z))@];
  /* $y\land z$ */
extern octa shift_left @,@,@[ARGS((octa y,int s))@];
  /* $y\LL s$, $0\le s\le64$ */
extern octa shift_right @,@,@[ARGS((octa y,int s,int uns))@];
  /* $y\GG s$, signed if |!uns| */
extern octa omult @,@,@[ARGS((octa y,octa z))@];
  /* unsigned $(|aux|,x)=y\times z$ */
extern octa signed_omult @,@,@[ARGS((octa y,octa z))@];
  /* signed $x=y\times z$ */
extern octa odiv @,@,@[ARGS((octa x,octa y,octa z))@];
  /* unsigned $(x,y)/z$; $|aux|=(x,y)\bmod z$ */
extern octa signed_odiv @,@,@[ARGS((octa y,octa z))@];
  /* signed $x=y/z$ */
extern int count_bits @,@,@[ARGS((tetra z))@];
  /* $x=\nu(z)$ */
extern tetra byte_diff @,@,@[ARGS((tetra y,tetra z))@];
  /* half of \.{BDIF} */
extern tetra wyde_diff @,@,@[ARGS((tetra y,tetra z))@];
  /* half of \.{WDIF} */
extern octa bool_mult @,@,@[ARGS((octa y,octa z,bool xor))@];
  /* \.{MOR} or \.{MXOR} */
extern octa load_sf @,@,@[ARGS((tetra z))@];
  /* load short float */
extern tetra store_sf @,@,@[ARGS((octa x))@];
  /* store short float */
extern octa fplus @,@,@[ARGS((octa y,octa z))@];
  /* floating point $x=y\oplus z$ */
extern octa fmult @,@,@[ARGS((octa y ,octa z))@];
  /* floating point $x=y\otimes z$ */
extern octa fdivide @,@,@[ARGS((octa y,octa z))@];
  /* floating point $x=y\oslash z$ */
extern octa froot @,@,@[ARGS((octa,int))@];
  /* floating point $x=\sqrt z$ */
extern octa fremstep @,@,@[ARGS((octa y,octa z,int delta))@];
  /* floating point $x\,{\rm rem}\,z=y\,{\rm rem}\,z$ */
extern octa fintegerize @,@,@[ARGS((octa z,int mode))@];
  /* floating point $x={\rm round}(z)$ */
extern int fcomp @,@,@[ARGS((octa y,octa z))@];
  /* $-1$, 0, 1, or 2 if $y<z$, $y=z$, $y>z$, $y\parallel z$ */
extern int fepscomp @,@,@[ARGS((octa y,octa z,octa eps,int sim))@];
  /* $x=|sim|?\ [y\sim z\ (\epsilon)]:\ [y\approx z\ (\epsilon)]$ */
extern octa floatit @,@,@[ARGS((octa z,int mode,int unsgnd,int shrt))@];
  /* fix to float */
extern octa fixit @,@,@[ARGS((octa z,int mode))@];
  /* float to fix */
extern void print_float @,@,@[ARGS((octa z))@];
  /* print octabyte as floating decimal */
extern int scan_const @,@,@[ARGS((char* buf))@];
  /* |val| = floating or integer constant; returns the type */

@ Here's a quick check to see if arithmetic is in trouble.

@d panic(m) {@+fprintf(stderr,"Panic: %s!\n",m);@+exit(-2);@+}
@<Initialize...@>=
if (shift_left(neg_one,1).h!=0xffffffff)
  panic("Incorrect implementation of type tetra");
@.Incorrect implementation...@>

@ Binary-to-decimal conversion is used when we want to see an octabyte
as a signed integer. The identity $\lfloor(an+b)/10\rfloor=
\lfloor a/10\rfloor n+\lfloor((a\bmod 10)n+b)/10\rfloor$ is helpful here.

@d sign_bit ((unsigned)0x80000000)

@<Sub...@>=
void print_int @,@,@[ARGS((octa))@];@+@t}\6{@>
void print_int(o)
  octa o;
{
  register tetra hi=o.h, lo=o.l, r, t;
  register int j;
  char dig[20];
  if (lo==0 && hi==0) printf("0");
  else {
    if (hi&sign_bit) {
      printf("-");
      if (lo==0) hi=-hi;
      else lo=-lo, hi=~hi;
    }
    for (j=0;hi;j++) { /* 64-bit division by 10 */
      r=((hi%10)<<16)+(lo>>16);
      hi=hi/10;
      t=((r%10)<<16)+(lo&0xffff);
      lo=((r/10)<<16)+(t/10);
      dig[j]=t%10;
    }
    for (;lo;j++) {
      dig[j]=lo%10;
      lo=lo/10;
    }
    for (j--;j>=0;j--) printf("%c",dig[j]+'0');
  }
}
    
@* Simulated memory. Chunks of simulated memory, 2048 bytes each,
are kept in a tree structure organized as a {\it treap},
following ideas of Vuillemin, Aragon, and Seidel
@^Vuillemin, Jean Etienne@>
@^Aragon, Cecilia Rodriguez@>
@^Seidel, Raimund@>
[{\sl Communications of the ACM\/ \bf23} (1980), 229--239;
{\sl IEEE Symp.\ on Foundations of Computer Science\/ \bf30} (1989), 540--546].
Each node of the treap has two keys: One, called |loc|, is the
base address of 512 simulated tetrabytes; it follows the conventions
of an ordinary binary search tree, with all locations in the left subtree
less than the |loc| of a node and all locations in the right subtree
greater than that~|loc|. The other, called |stamp|, can be thought of as the
time the node was inserted into the tree; all subnodes of a given node
have a larger~|stamp|. By assigning time stamps at random, we maintain
a tree structure that almost always is fairly well balanced.

Each simulated tetrabyte has an associated frequency count and
source file reference.

@<Type...@>=
typedef struct {
  tetra tet; /* the tetrabyte of simulated memory */
  tetra freq; /* the number of times it was obeyed as an instruction */
  unsigned char bkpt; /* breakpoint information for this tetrabyte */
  unsigned char file_no; /* source file number, if known */
  unsigned short line_no; /* source line number, if known */
} mem_tetra;
@#
typedef struct mem_node_struct {
  octa loc; /* location of the first of 512 simulated tetrabytes */
  tetra stamp; /* time stamp for treap balancing */
  struct mem_node_struct *left, *right; /* pointers to subtrees */
  mem_tetra dat[512]; /* the chunk of simulated tetrabytes */
} mem_node;

@ The |stamp| value is actually only pseudorandom, based on the
idea of Fibonacci hashing [see {\sl Sorting and Searching}, Section~6.4].
This is good enough for our purposes, and it guarantees that
no two stamps will be identical.

@<Sub...@>=
mem_node* new_mem @,@,@[ARGS((void))@];@+@t}\6{@>
mem_node* new_mem()
{
  register mem_node *p;
  p=(mem_node*)calloc(1,sizeof(mem_node));
  if (!p) panic("Can't allocate any more memory");
@.Can't allocate...@>
  p->stamp=priority;
  priority+=0x9e3779b9; /* $\lfloor2^{32}(\phi-1)\rfloor$ */
  return p;
}

@ Initially we start with a chunk for the pool segment, since
the simulator will be putting command-line information there before
it runs the program.

@<Initialize...@>=
mem_root=new_mem();
mem_root->loc.h=0x40000000;
last_mem=mem_root;

@ @<Glob...@>=
tetra priority=314159265; /* pseudorandom time stamp counter */
mem_node *mem_root; /* root of the treap */
mem_node *last_mem; /* the memory node most recently read or written */

@ The |mem_find| routine finds a given tetrabyte in the simulated
memory, inserting a new node into the treap if necessary.

@<Sub...@>=
mem_tetra* mem_find @,@,@[ARGS((octa))@];@+@t}\6{@>
mem_tetra* mem_find(addr)
  octa addr;
{
  octa key;
  register int offset;
  register mem_node *p=last_mem;
  key.h=addr.h;
  key.l=addr.l&0xfffff800;
  offset=addr.l&0x7fc;
  if (p->loc.l!=key.l || p->loc.h!=key.h)
    @<Search for |key| in the treap,
        setting |last_mem| and |p| to its location@>;
  return &p->dat[offset>>2];
}

@ @<Search for |key| in the treap...@>=
{@+register mem_node **q;
  for (p=mem_root; p; ) {
    if (key.l==p->loc.l && key.h==p->loc.h) goto found;
    if ((key.l<p->loc.l && key.h<=p->loc.h) || key.h<p->loc.h) p=p->left;
    else p=p->right;
  }
  for (p=mem_root,q=&mem_root; p && p->stamp<priority; p=*q) {
    if ((key.l<p->loc.l && key.h<=p->loc.h) || key.h<p->loc.h) q=&p->left;
    else q=&p->right;
  }
  *q=new_mem();
  (*q)->loc=key;
  @<Fix up the subtrees of |*q|@>;
  p=*q;
found: last_mem=p;
}

@ At this point we want to split the binary search tree |p| into two
parts based on the given |key|, forming the left and right subtrees
of the new node~|q|. The effect will be as if |key| had been inserted
before all of |p|'s nodes.

@<Fix up the subtrees of |*q|@>=
{
  register mem_node **l=&(*q)->left,**r=&(*q)->right;
  while (p) {
    if ((key.l<p->loc.l && key.h<=p->loc.h) || key.h<p->loc.h)
      *r=p, r=&p->left, p=*r;
    else *l=p, l=&p->right, p=*l;
  }
  *l=*r=NULL;
}

@* Loading an object file. To get the user's program into memory,
we read in an \MMIX\ object, using modifications of the routines
in the utility program \.{MMOtype}. Complete details of \.{mmo}
format appear in the program for {\mc MMIXAL}; a reader
who hopes to understand this section ought to at least skim
that documentation.
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

@ We do not load the symbol table. (A more ambitious simulator could
implement \.{MMIXAL}-style expressions for interactive debugging,
but such enhancements are left to the interested reader.)

@<Initialize everything@>=
mmo_file=fopen(mmo_file_name,"rb");
if (!mmo_file) {
  register char *alt_name=(char*)calloc(strlen(mmo_file_name)+5,sizeof(char));
  if (!alt_name) panic("Can't allocate file name buffer");
@.Can't allocate...@>
  sprintf(alt_name,"%s.mmo",mmo_file_name);
  mmo_file=fopen(alt_name,"rb");
  if (!mmo_file) {
    fprintf(stderr,"Can't open the object file %s or %s!\n",
@.Can't open...@>
               mmo_file_name,alt_name);
    exit(-3);
  }
  free(alt_name);
}
byte_count=0;

@ @<Glob...@>=
FILE *mmo_file; /* the input file */
int postamble; /* have we encountered |lop_post|? */
int byte_count; /* index of the next-to-be-read byte */
byte buf[4]; /* the most recently read bytes */
int yzbytes; /* the two least significant bytes */
int delta; /* difference for relative fixup */
tetra tet; /* |buf| bytes packed big-endianwise */

@ The tetrabytes of an \.{mmo} file are stored in
friendly big-endian fashion, but this program is supposed to work also
on computers that are little-endian. Therefore we read four successive bytes
and pack them into a tetrabyte, instead of reading a single tetrabyte.

@d mmo_err { 
     fprintf(stderr,"Bad object file! (Try running MMOtype.)\n");
@.Bad object file@>
     exit(-4);
   }

@<Sub...@>=
void read_tet @,@,@[ARGS((void))@];@+@t}\6{@>
void read_tet()
{
  if (fread(buf,1,4,mmo_file)!=4) mmo_err;
  yzbytes=(buf[2]<<8)+buf[3];
  tet=(((buf[0]<<8)+buf[1])<<16)+yzbytes;
}

@ @<Sub...@>=
byte read_byte @,@,@[ARGS((void))@];@+@t}\6{@>
byte read_byte()
{
  register byte b;
  if (!byte_count) read_tet();
  b=buf[byte_count];
  byte_count=(byte_count+1)&3;
  return b;
}

@ @<Load the preamble@>=
read_tet(); /* read the first tetrabyte of input */
if (buf[0]!=mm || buf[1]!=lop_pre) mmo_err;
if (ybyte!=1) mmo_err;
if (zbyte==0) obj_time=0xffffffff;
else {
  j=zbyte-1;
  read_tet();@+ obj_time=tet; /* file creation time */
  for (;j>0;j--) read_tet();
}

@ @<Load the next item@>=
{
  read_tet();
 loop:@+if (buf[0]==mm) switch (buf[1]) {
   case lop_quote:@+if (yzbytes!=1) mmo_err;
    read_tet();@+break;
   @t\4@>@<Cases for lopcodes in the main loop@>@;
   case lop_post: postamble=1;
     if (ybyte || zbyte<32) mmo_err;
     continue;
   default: mmo_err;
  }
  @<Load |tet| as a normal item@>;
}

@ In a normal situation, the newly read tetrabyte is simply supposed
to be loaded into the current location. We load not only the current
location but also the current file position, if |cur_line| is nonzero
and |cur_loc| belongs to segment~0.

@d mmo_load(loc,val) ll=mem_find(loc), ll->tet^=val

@<Load |tet| as a normal item@>=
{
  mmo_load(cur_loc,tet);
  if (cur_line) {
    ll->file_no=cur_file;
    ll->line_no=cur_line;
    cur_line++;
  }
  cur_loc=incr(cur_loc,4);@+ cur_loc.l &=-4;
}

@ @<Glob...@>=
octa cur_loc; /* the current location */
int cur_file=-1; /* the most recently selected file number */
int cur_line; /* the current position in |cur_file|, if nonzero */
octa tmp; /* an octabyte of temporary interest */
tetra obj_time; /* when the object file was created */

@ @<Initialize...@>=
cur_loc.h=cur_loc.l=0;
cur_file=-1;
cur_line=0;
@<Load the preamble@>;
do @<Load the next item@>@;@+while (!postamble);
@<Load the postamble@>;
fclose(mmo_file);
cur_line=0;

@ We have already implemented |lop_quote|, which
falls through to the normal case after reading an extra tetrabyte.
Now let's consider the other lopcodes in turn.

@d ybyte buf[2] /* the next-to-least significant byte */
@d zbyte buf[3] /* the least significant byte */

@<Cases for lopcodes...@>=
case lop_loc:@+if (zbyte==2) {
   j=ybyte;@+ read_tet();@+ cur_loc.h=(j<<24)+tet;
 }@+else if (zbyte==1) cur_loc.h=ybyte<<24;
 else mmo_err;
 read_tet();@+ cur_loc.l=tet;
 continue;
case lop_skip: cur_loc=incr(cur_loc,yzbytes);@+continue;

@ Fixups load information out of order, when future references have
been resolved. The current file name and line number are not considered
relevant.

@<Cases for lopcodes...@>=
case lop_fixo:@+if (zbyte==2) {
   j=ybyte;@+ read_tet();@+ tmp.h=(j<<24)+tet;
 }@+else if (zbyte==1) tmp.h=ybyte<<24;
 else mmo_err;
 read_tet();@+ tmp.l=tet;
 mmo_load(tmp,cur_loc.h);
 mmo_load(incr(tmp,4),cur_loc.l);
 continue;
case lop_fixr: delta=yzbytes; goto fixr;
case lop_fixrx:j=yzbytes;@+if (j!=16 && j!=24) mmo_err;
 read_tet(); delta=tet;
 if (delta&0xfe000000) mmo_err;
fixr: tmp=incr(cur_loc,-(delta>=0x1000000? (delta&0xffffff)-(1<<j): delta)<<2);
 mmo_load(tmp,delta);
 continue;

@ The space for file names isn't allocated until we are sure we need it.

@<Cases for lopcodes...@>=
case lop_file:@+if (file_info[ybyte].name) {
   if (zbyte) mmo_err;
   cur_file=ybyte;
 }@+else {
   if (!zbyte) mmo_err;
   file_info[ybyte].name=(char*)calloc(4*zbyte+1,1);
   if (!file_info[ybyte].name) {
     fprintf(stderr,"No room to store the file name!\n");@+exit(-5);
@.No room...@>
   }
   cur_file=ybyte;
   for (j=zbyte,p=file_info[ybyte].name; j>0; j--,p+=4) {
     read_tet();
     *p=buf[0];@+*(p+1)=buf[1];@+*(p+2)=buf[2];@+*(p+3)=buf[3];
   }
 }
 cur_line=0;@+continue;
case lop_line:@+if (cur_file<0) mmo_err;
 cur_line=yzbytes;@+continue;

@ Special bytes are ignored (at least for now).

@<Cases for lopcodes...@>=
case lop_spec:@+ while(1) {
   read_tet();
   if (buf[0]==mm) {
     if (buf[1]!=lop_quote || yzbytes!=1) goto loop; /* end of special data */
     read_tet();
   }
 }

@ Since a chunk of memory holds 512 tetrabytes, the |ll| pointer in the
following loop stays in the same chunk (namely, the first chunk
of segment~3, also known as \.{Stack\_Segment}).
@:Stack_Segment}\.{Stack\_Segment@>
@:Pool_Segment}\.{Pool\_Segment@>

@<Load the postamble@>=
aux.h=0x60000000;@+ aux.l=0x18;
ll=mem_find(aux);
(ll-1)->tet=2; /* this will ultimately set |rL=2| */
(ll-5)->tet=argc; /* and $\$0=|argc|$ */
(ll-4)->tet=0x40000000;
(ll-3)->tet=0x8; /* and $\$1=\.{Pool\_Segment}+8$ */
G=zbyte;@+ L=0;
for (j=G+G;j<256+256;j++,ll++,aux.l+=4) read_tet(), ll->tet=tet;
inst_ptr.h=(ll-2)->tet, inst_ptr.l=(ll-1)->tet; /* \.{Main} */
(ll+2*12)->tet=G<<24;
g[255]=incr(aux,12*8); /* we will |UNSAVE| from here, to get going */

@* Loading and printing source lines.
The loaded program generally contains cross references to the lines
of symbolic source files, so that the context of each instruction
can be understood. The following sections of this program
make such information available when it is desired.

Source file data is kept in a \&{file\_node} structure:

@<Type...@>=
typedef struct {
  char *name; /* name of source file */
  int line_count; /* number of lines in the file */
  long *map; /* pointer to map of file positions */
} file_node;

@ In partial preparation for the day when source files are in
Unicode, we define a type \&{Char} for the source characters.

@<Type...@>=
typedef char Char; /* bytes that will become wydes some day */

@ @<Glob...@>=
file_node file_info[256]; /* data about each source file */
int buf_size; /* size of buffer for source lines */
Char *buffer;

@ As in \.{MMIXAL}, we prefer source lines of length 72 characters or less,
but the user is allowed to increase the limit. (Longer lines will silently
be truncated to the buffer size when the simulator lists them.)

@<Initialize...@>=
if (buf_size<72) buf_size=72;
buffer=(Char*)calloc(buf_size+1,sizeof(Char));
if (!buffer) panic("Can't allocate source line buffer");
@.Can't allocate...@>

@ The first time we are called upon to list a line from a given source
file, we make a map of starting locations for each line. Source files
should contain at most 65535 lines. We assume that they contain
no null characters.

@<Sub...@>=
void make_map @,@,@[ARGS((void))@];@+@t}\6{@>
void make_map()
{
  long map[65536];
  register int k,l;
  register long*p;
  @<Check if the source file has been modified@>;
  for (l=1;l<65536 && !feof(src_file);l++) {
    map[l]=ftell(src_file);
   loop:@+if (!fgets(buffer,buf_size,src_file)) break;
    if (buffer[strlen(buffer)-1]!='\n') goto loop;
  }
  file_info[cur_file].line_count=l;
  file_info[cur_file].map=p=(long*)calloc(l,sizeof(long));
  if (!p) panic("No room for a source-line map");
@.No room...@>
  for (k=1;k<l;k++) p[k]=map[k];
}

@ We want to warn the user if the source file has changed since the
object file was written. The standard \CEE/ library doesn't provide
the information we need; so we use the \UNIX/ system function |stat|,
in hopes that other operating systems provide a similar way to do the job.
@^system dependencies@>

@<Preprocessor macros@>=
#include <sys/types.h>
#include <sys/stat.h>

@ @<Check if the source file has been modified@>=
@^system dependencies@>
{
  struct stat stat_buf;
  if (stat(file_info[cur_file].name,&stat_buf)>=0)
    if ((tetra)stat_buf.st_mtime > obj_time)
      fprintf(stderr,
         "Warning: File %s was modified; it may not match the program!\n",
@.File...was modified@>
         file_info[cur_file].name);
}

@ Source lines are listed by the |print_line| routine, preceded by
12 characters containing the line number. If a file error occurs,
nothing is printed---not even an error message; the absence of
listed data is itself a message.

@<Sub...@>=
void print_line @,@,@[ARGS((int))@];@+@t}\6{@>
void print_line(k)
  int k;
{
  char buf[11];
  if (k>=file_info[cur_file].line_count) return;
  if (fseek(src_file,file_info[cur_file].map[k],SEEK_SET)!=0) return;
  if (!fgets(buffer,buf_size,src_file)) return;
  sprintf(buf,"%d:    ",k);
  printf("line %.6s %s",buf,buffer);
  if (buffer[strlen(buffer)-1]!='\n') printf("\n");
  line_shown=true;
}

@ @<Preprocessor macros@>=
#ifndef SEEK_SET
#define SEEK_SET 0 /* code for setting the file pointer to a given offset */
#endif

@ The |show_line| routine is called when we want to output line |cur_line|
of source file number |cur_file|, assuming that |cur_line!=0|. Its job
is primarily to maintain continuity, by opening or reopening the |src_file|
if the source file changes, and by connecting the previously output
lines to the new one. Sometimes no output is necessary, because the
desired line has already been printed.

@<Sub...@>=
void show_line @,@,@[ARGS((void))@];@+@t}\6{@>
void show_line()
{
  register int k;
  if (shown_file!=cur_file) @<Prepare to list lines from a new source file@>@;
  else if (shown_line==cur_line) return; /* already shown */
  if (cur_line>shown_line+gap+1 || cur_line<shown_line) {
    if (shown_line>0)
      if (cur_line<shown_line) printf("--------\n"); /* indicate upward move */
      else printf("     ...\n"); /* indicate the gap */
    print_line(cur_line);
  }@+else@+ for (k=shown_line+1;k<=cur_line;k++) print_line(k);
  shown_line=cur_line;
}
    
@ @<Glob...@>=
FILE *src_file; /* the currently open source file */
int shown_file=-1; /* index of the most recently listed file */
int shown_line; /* the line most recently listed in |shown_file| */
int gap; /* minimum gap between consecutively listed source lines */
bool line_shown; /* did we list anything recently? */
bool showing_source; /* are we listing source lines? */
int profile_gap; /* the |gap| when printing final frequencies */
bool profile_showing_source; /* |showing_source| within final frequencies */

@ @<Prepare to list lines from a new source file@>=
{
  if (!src_file) src_file=fopen(file_info[cur_file].name,"r");
  else freopen(file_info[cur_file].name,"r",src_file);
  if (!src_file) {
    fprintf(stderr,"Warning: I can't open file %s; source listing omitted.\n",
@.I can't open...@>
               file_info[cur_file].name);
    showing_source=false;
    return;
  }
  printf("\"%s\"\n",file_info[cur_file].name);
  shown_file=cur_file;
  shown_line=0;
  if (!file_info[cur_file].map) make_map();
}

@ Here is a simple application of |show_line|. It is a recursive routine that
prints the frequency counts of all instructions that occur in a
given subtree of the simulated memory and that were executed at least once.
The subtree is traversed in symmetric order; therefore the frequencies
appear in increasing order of the instruction locations.

@<Sub...@>=
void print_freqs @,@,@[ARGS((mem_node*))@];@+@t}\6{@>
void print_freqs(p)
  mem_node *p;
{
  register int j;
  octa cur_loc;
  if (p->left) print_freqs(p->left);
  for (j=0;j<512;j++) if (p->dat[j].freq)
    @<Print frequency data for location |p->loc+4*j|@>;
  if (p->right) print_freqs(p->right);
}

@ An ellipsis (\.{...}) is printed between frequency data for nonconsecutive
instructions, unless source line information intervenes.

@<Print frequency data...@>=
{
  cur_loc=incr(p->loc,4*j);
  if (showing_source && p->dat[j].line_no) {
    cur_file=p->dat[j].file_no, cur_line=p->dat[j].line_no;
    line_shown=false;
    show_line();
    if (line_shown) goto loc_implied;
  }
  if (cur_loc.l!=implied_loc.l || cur_loc.h!=implied_loc.h)
    if (profile_started) printf("         0.        ...\n");
 loc_implied: printf("%10d. %08x%08x: %08x (%s)\n",
      p->dat[j].freq, cur_loc.h, cur_loc.l, p->dat[j].tet,
      info[p->dat[j].tet>>24].name);
  implied_loc=incr(cur_loc,4);@+ profile_started=true;
}
    
@ @<Glob...@>=
octa implied_loc; /* location following the last shown frequency data */
bool profile_started; /* have we printed at least one frequency count? */

@ @<Print all the frequency counts@>=
{
  printf("\nProgram profile:\n");
  shown_file=cur_file=-1;@+ shown_line=cur_line=0;
  gap=profile_gap;
  showing_source=profile_showing_source;
  implied_loc=neg_one;
  print_freqs(mem_root);
}

@* Lists. This simulator needs to deal with 256 different opcodes,
so we might as well enumerate them~now.

@<Type...@>=
typedef enum{@/
@!TRAP,@!FCMP,@!FUN,@!FEQL,@!FADD,@!FIX,@!FSUB,@!FIXU,@/
@!FLOT,@!FLOTI,@!FLOTU,@!FLOTUI,@!SFLOT,@!SFLOTI,@!SFLOTU,@!SFLOTUI,@/
@!FMUL,@!FCMPE,@!FUNE,@!FEQLE,@!FDIV,@!FSQRT,@!FREM,@!FINT,@/
@!MUL,@!MULI,@!MULU,@!MULUI,@!DIV,@!DIVI,@!DIVU,@!DIVUI,@/
@!ADD,@!ADDI,@!ADDU,@!ADDUI,@!SUB,@!SUBI,@!SUBU,@!SUBUI,@/
@!IIADDU,@!IIADDUI,@!IVADDU,@!IVADDUI,@!VIIIADDU,@!VIIIADDUI,@!XVIADDU,@!XVIADDUI,@/
@!CMP,@!CMPI,@!CMPU,@!CMPUI,@!NEG,@!NEGI,@!NEGU,@!NEGUI,@/
@!SL,@!SLI,@!SLU,@!SLUI,@!SR,@!SRI,@!SRU,@!SRUI,@/
@!BN,@!BNB,@!BZ,@!BZB,@!BP,@!BPB,@!BOD,@!BODB,@/
@!BNN,@!BNNB,@!BNZ,@!BNZB,@!BNP,@!BNPB,@!BEV,@!BEVB,@/
@!PBN,@!PBNB,@!PBZ,@!PBZB,@!PBP,@!PBPB,@!PBOD,@!PBODB,@/
@!PBNN,@!PBNNB,@!PBNZ,@!PBNZB,@!PBNP,@!PBNPB,@!PBEV,@!PBEVB,@/
@!CSN,@!CSNI,@!CSZ,@!CSZI,@!CSP,@!CSPI,@!CSOD,@!CSODI,@/
@!CSNN,@!CSNNI,@!CSNZ,@!CSNZI,@!CSNP,@!CSNPI,@!CSEV,@!CSEVI,@/
@!ZSN,@!ZSNI,@!ZSZ,@!ZSZI,@!ZSP,@!ZSPI,@!ZSOD,@!ZSODI,@/
@!ZSNN,@!ZSNNI,@!ZSNZ,@!ZSNZI,@!ZSNP,@!ZSNPI,@!ZSEV,@!ZSEVI,@/
@!LDB,@!LDBI,@!LDBU,@!LDBUI,@!LDW,@!LDWI,@!LDWU,@!LDWUI,@/
@!LDT,@!LDTI,@!LDTU,@!LDTUI,@!LDO,@!LDOI,@!LDOU,@!LDOUI,@/
@!LDSF,@!LDSFI,@!LDHT,@!LDHTI,@!CSWAP,@!CSWAPI,@!LDUNC,@!LDUNCI,@/
@!LDVTS,@!LDVTSI,@!PRELD,@!PRELDI,@!PREGO,@!PREGOI,@!GO,@!GOI,@/
@!STB,@!STBI,@!STBU,@!STBUI,@!STW,@!STWI,@!STWU,@!STWUI,@/
@!STT,@!STTI,@!STTU,@!STTUI,@!STO,@!STOI,@!STOU,@!STOUI,@/
@!STSF,@!STSFI,@!STHT,@!STHTI,@!STCO,@!STCOI,@!STUNC,@!STUNCI,@/
@!SYNCD,@!SYNCDI,@!PREST,@!PRESTI,@!SYNCID,@!SYNCIDI,@!PUSHGO,@!PUSHGOI,@/
@!OR,@!ORI,@!ORN,@!ORNI,@!NOR,@!NORI,@!XOR,@!XORI,@/
@!AND,@!ANDI,@!ANDN,@!ANDNI,@!NAND,@!NANDI,@!NXOR,@!NXORI,@/
@!BDIF,@!BDIFI,@!WDIF,@!WDIFI,@!TDIF,@!TDIFI,@!ODIF,@!ODIFI,@/
@!MUX,@!MUXI,@!SADD,@!SADDI,@!MOR,@!MORI,@!MXOR,@!MXORI,@/
@!SETH,@!SETMH,@!SETML,@!SETL,@!INCH,@!INCMH,@!INCML,@!INCL,@/
@!ORH,@!ORMH,@!ORML,@!ORL,@!ANDNH,@!ANDNMH,@!ANDNML,@!ANDNL,@/
@!JMP,@!JMPB,@!PUSHJ,@!PUSHJB,@!GETA,@!GETAB,@!PUT,@!PUTI,@/
@!POP,@!RESUME,@!SAVE,@!UNSAVE,@!SYNC,@!SWYM,@!GET,@!TRIP}@+@!mmix_opcode;

@ We also need to enumerate the special names for special registers.

@<Type...@>=
typedef enum{
@!rB,@!rD,@!rE,@!rH,@!rJ,@!rM,@!rR,@!rBB,
 @!rC,@!rN,@!rO,@!rS,@!rI,@!rT,@!rTT,@!rK,@!rQ,@!rU,@!rV,@!rG,@!rL,
 @!rA,@!rF,@!rP,@!rW,@!rX,@!rY,@!rZ,@!rWW,@!rXX,@!rYY,@!rZZ} @!special_reg;

@ @<Glob...@>=
char *special_name[32]={"rB","rD","rE","rH","rJ","rM","rR","rBB",
 "rC","rN","rO","rS","rI","rT","rTT","rK","rQ","rU","rV","rG","rL",
 "rA","rF","rP","rW","rX","rY","rZ","rWW","rXX","rYY","rZZ"};

@ Here are the bit codes for arithmetic exceptions. These codes, except
|H_BIT|, are defined also in {\mc MMIX-ARITH}.

@d X_BIT (1<<8) /* floating inexact */
@d Z_BIT (1<<9) /* floating division by zero */
@d U_BIT (1<<10) /* floating underflow */
@d O_BIT (1<<11) /* floating overflow */
@d I_BIT (1<<12) /* floating invalid operation */
@d W_BIT (1<<13) /* float-to-fix overflow */
@d V_BIT (1<<14) /* integer overflow */
@d D_BIT (1<<15) /* integer divide check */
@d H_BIT (1<<16) /* trip */

@ The |bkpt| field associated with each tetrabyte of memory has
bits associated with forced tracing and/or
breaking for reading, writing, and/or execution.

@d trace_bit (1<<3)
@d read_bit (1<<2)
@d write_bit (1<<1)
@d exec_bit (1<<0)

@ To complete our lists of lists,
we enumerate the rudimentary operating system calls
that are built in to \.{MMIXAL}.

@d max_sys_call Ftell

@<Type...@>=
typedef enum{
@!Halt,@!Fopen,@!Fclose,@!Fread,@!Fgets,@!Fgetws,
@!Fwrite,@!Fputs,@!Fputws,@!Fseek,@!Ftell} @!sys_call;

@* The main loop. Now let's plunge in to the guts of the simulator,
the master switch that controls most of the action.

@<Perform one instruction@>=
{
  if (resuming) loc=incr(inst_ptr,-4), inst=g[rX].l;
  else @<Fetch the next instruction@>;
  op=inst>>24;@+xx=(inst>>16)&0xff;@+yy=(inst>>8)&0xff;@+zz=inst&0xff;
  f=info[op].flags;@+yz=inst&0xffff;
  x=y=z=a=b=zero_octa;@+ exc=0;@+ old_L=L;
  if (f&rel_addr_bit) @<Convert relative address to absolute address@>;
  @<Install operand fields@>;
  if (f&X_is_dest_bit) @<Install register~X as the destination,
          adjusting the register stack if necessary@>;
  w=oplus(y,z);
  if (loc.h>=0x20000000) goto privileged_inst;
  switch(op) {
  @t\4@>@<Cases for individual \MMIX\ instructions@>;
  }
  @<Check for trip interrupt@>;
  @<Update the clocks@>;
  @<Trace the current instruction, if requested@>;
  if (resuming && op!=RESUME) resuming=false;
}

@ Operands |x| and |a| are usually destinations (results), computed from
the source operands |y|, |z|, and/or~|b|.

@<Glob...@>=
octa w,x,y,z,a,b,ma,mb; /* operands */
octa *x_ptr; /* destination */
octa loc; /* location of the current instruction */
octa inst_ptr; /* location of the next instruction */
tetra inst; /* the current instruction */
int old_L; /* value of |L| before the current instruction */
int exc; /* exceptions raised by the current instruction */
int tracing_exceptions; /* exception bits that cause tracing */
int rop; /* ropcode of a resumed instruction */
int round_mode; /* the style of floating point rounding just used */
bool resuming; /* are we resuming an interrupted instruction? */
bool halted; /* did the program come to a halt? */
bool breakpoint; /* should we pause after the current instruction? */
bool tracing; /* should we trace the current instruction? */
bool stack_tracing; /* should we trace details of the register stack? */
bool interacting; /* are we in interactive mode? */
bool interact_after_break; /* should we go into interactive mode? */
bool tripping; /* are we about to go to a trip handler? */
bool good; /* did the last branch instruction guess correctly? */
tetra trace_threshold; /* each instruction should be traced this many times */

@ @<Local...@>=
register mmix_opcode op; /* operation code of the current instruction */
register int xx,yy,zz,yz; /* operand fields of the current instruction */
register tetra f; /* properties of the current |op| */
register int i,j,k; /* miscellaneous indices */
register mem_tetra *ll; /* current place in the simulated memory */
register char *p; /* current place in a string */

@ @<Fetch the next instruction@>=
{
  loc=inst_ptr;
  ll=mem_find(loc);
  inst=ll->tet;
  cur_file=ll->file_no;
  cur_line=ll->line_no;
  ll->freq++;
  if (ll->bkpt&exec_bit) breakpoint=true;
  tracing=breakpoint||(ll->bkpt&trace_bit)||(ll->freq<=trace_threshold);
  inst_ptr=incr(inst_ptr,4);
}

@ Much of the simulation is table-driven, based on a static data
structure called the \&{op\_info} for each operation code.

@<Type...@>=
typedef struct {
  char *name; /* symbolic name of an opcode */
  unsigned char flags; /* its instruction format */
  unsigned char third_operand; /* its special register input */
  unsigned char mems; /* how many $\mu$ it costs */
  unsigned char oops; /* how many $\upsilon$ it costs */
  char *trace_format; /* how it appears when traced */
} op_info;

@ For example, the |flags| field of |info[op]|
tells us how to obtain the operands from the X, Y, and~Z fields
of the current instruction. Each entry records special properties of an
operation code, in binary notation:
\Hex{1}~means Z~is an immediate value, \Hex{2}~means rZ is
a source operand, \Hex{4}~means Y~is an immediate value, \Hex{8}~means rY is a
source operand, \Hex{10}~means rX is a source operand, \Hex{20}~means
rX is a destination, \Hex{40}~means YZ is part of a relative address,
\Hex{80}~means a push or pop or unsave instruction.

The |trace_format| field will be explained later.

@d Z_is_immed_bit 0x1
@d Z_is_source_bit 0x2
@d Y_is_immed_bit 0x4
@d Y_is_source_bit 0x8
@d X_is_source_bit 0x10
@d X_is_dest_bit 0x20
@d rel_addr_bit 0x40
@d push_pop_bit 0x80

@<Glob...@>=
op_info info[256]={
@<Info for arithmetic commands@>,
@<Info for branch commands@>,
@<Info for load/store commands@>,
@<Info for logical and control commands@>};

@ @<Info for arithmetic commands@>=
{"TRAP",0x0a,255,0,5,"%r"},@|
{"FCMP",0x2a,0,0,1,"%l = %.y cmp %.z = %x"},@|
{"FUN",0x2a,0,0,1,"%l = [%.y(||)%.z] = %x"},@|
{"FEQL",0x2a,0,0,1,"%l = [%.y(==)%.z] = %x"},@|
{"FADD",0x2a,0,0,4,"%l = %.y %(+%) %.z = %.x"},@|
{"FIX",0x26,0,0,4,"%l = %(fix%) %.z = %x"},@|
{"FSUB",0x2a,0,0,4,"%l = %.y %(-%) %.z = %.x"},@|
{"FIXU",0x26,0,0,4,"%l = %(fix%) %.z = %#x"},@|
{"FLOT",0x26,0,0,4,"%l = %(flot%) %z = %.x"},@|
{"FLOTI",0x25,0,0,4,"%l = %(flot%) %z = %.x"},@|
{"FLOTU",0x26,0,0,4,"%l = %(flot%) %#z = %.x"},@|
{"FLOTUI",0x25,0,0,4,"%l = %(flot%) %z = %.x"},@|
{"SFLOT",0x26,0,0,4,"%l = %(sflot%) %z = %.x"},@|
{"SFLOTI",0x25,0,0,4,"%l = %(sflot%) %z = %.x"},@|
{"SFLOTU",0x26,0,0,4,"%l = %(sflot%) %#z = %.x"},@|
{"SFLOTUI",0x25,0,0,4,"%l = %(sflot%) %z = %.x"},@|
{"FMUL",0x2a,0,0,4,"%l = %.y %(*%) %.z = %.x"},@|
{"FCMPE",0x2a,rE,0,4,"%l = %.y cmp %.z (%.b)) = %x"},@|
{"FUNE",0x2a,rE,0,1,"%l = [%.y(||)%.z (%.b)] = %x"},@|
{"FEQLE",0x2a,rE,0,4,"%l = [%.y(==)%.z (%.b)] = %x"},@|
{"FDIV",0x2a,0,0,40,"%l = %.y %(/%) %.z = %.x"},@|
{"FSQRT",0x26,0,0,40,"%l = %(sqrt%) %.z = %.x"},@|
{"FREM",0x2a,0,0,4,"%l = %.y %(rem%) %.z = %.x"},@|
{"FINT",0x26,0,0,4,"%l = %(int%) %.z = %.x"},@|
{"MUL",0x2a,0,0,10,"%l = %y * %z = %x"},@|
{"MULI",0x29,0,0,10,"%l = %y * %z = %x"},@|
{"MULU",0x2a,0,0,10,"%l = %#y * %#z = %#x, rH=%#a"},@|
{"MULUI",0x29,0,0,10,"%l = %#y * %z = %#x, rH=%#a"},@|
{"DIV",0x2a,0,0,60,"%l = %y / %z = %x, rR=%a"},@|
{"DIVI",0x29,0,0,60,"%l = %y / %z = %x, rR=%a"},@|
{"DIVU",0x2a,rD,0,60,"%l = %#b%0y / %#z = %#x, rR=%#a"},@|
{"DIVUI",0x29,rD,0,60,"%l = %#b%0y / %z = %#x, rR=%#a"},@|
{"ADD",0x2a,0,0,1,"%l = %y + %z = %x"},@|
{"ADDI",0x29,0,0,1,"%l = %y + %z = %x"},@|
{"ADDU",0x2a,0,0,1,"%l = %#y + %#z = %#x"},@|
{"ADDUI",0x29,0,0,1,"%l = %#y + %z = %#x"},@|
{"SUB",0x2a,0,0,1,"%l = %y - %z = %x"},@|
{"SUBI",0x29,0,0,1,"%l = %y - %z = %x"},@|
{"SUBU",0x2a,0,0,1,"%l = %#y - %#z = %#x"},@|
{"SUBUI",0x29,0,0,1,"%l = %#y - %z = %#x"},@|
{"2ADDU",0x2a,0,0,1,"%l = %#y <<1+ %#z = %#x"},@|
{"2ADDUI",0x29,0,0,1,"%l = %#y <<1+ %z = %#x"},@|
{"4ADDU",0x2a,0,0,1,"%l = %#y <<2+ %#z = %#x"},@|
{"4ADDUI",0x29,0,0,1,"%l = %#y <<2+ %z = %#x"},@|
{"8ADDU",0x2a,0,0,1,"%l = %#y <<3+ %#z = %#x"},@|
{"8ADDUI",0x29,0,0,1,"%l = %#y <<3+ %z = %#x"},@|
{"16ADDU",0x2a,0,0,1,"%l = %#y <<4+ %#z = %#x"},@|
{"16ADDUI",0x29,0,0,1,"%l = %#y <<4+ %z = %#x"},@|
{"CMP",0x2a,0,0,1,"%l = %y cmp %z = %x"},@|
{"CMPI",0x29,0,0,1,"%l = %y cmp %z = %x"},@|
{"CMPU",0x2a,0,0,1,"%l = %#y cmp %#z = %x"},@|
{"CMPUI",0x29,0,0,1,"%l = %#y cmp %z = %x"},@|
{"NEG",0x26,0,0,1,"%l = %y - %z = %x"},@|
{"NEGI",0x25,0,0,1,"%l = %y - %z = %x"},@|
{"NEGU",0x26,0,0,1,"%l = %y - %#z = %#x"},@|
{"NEGUI",0x25,0,0,1,"%l = %y - %z = %#x"},@|
{"SL",0x2a,0,0,1,"%l = %y << %#z = %x"},@|
{"SLI",0x29,0,0,1,"%l = %y << %z = %x"},@|
{"SLU",0x2a,0,0,1,"%l = %#y << %#z = %#x"},@|
{"SLUI",0x29,0,0,1,"%l = %#y << %z = %#x"},@|
{"SR",0x2a,0,0,1,"%l = %y >> %#z = %x"},@|
{"SRI",0x29,0,0,1,"%l = %y >> %z = %x"},@|
{"SRU",0x2a,0,0,1,"%l = %#y >> %#z = %#x"},@|
{"SRUI",0x29,0,0,1,"%l = %#y >> %z = %#x"}

@ @<Info for branch commands@>=
{"BN",0x50,0,0,1,"%b<0? %t%g"},@|
{"BNB",0x50,0,0,1,"%b<0? %t%g"},@|
{"BZ",0x50,0,0,1,"%b==0? %t%g"},@|
{"BZB",0x50,0,0,1,"%b==0? %t%g"},@|
{"BP",0x50,0,0,1,"%b>0? %t%g"},@|
{"BPB",0x50,0,0,1,"%b>0? %t%g"},@|
{"BOD",0x50,0,0,1,"%b odd? %t%g"},@|
{"BODB",0x50,0,0,1,"%b odd? %t%g"},@|
{"BNN",0x50,0,0,1,"%b>=0? %t%g"},@|
{"BNNB",0x50,0,0,1,"%b>=0? %t%g"},@|
{"BNZ",0x50,0,0,1,"%b!=0? %t%g"},@|
{"BNZB",0x50,0,0,1,"%b!=0? %t%g"},@|
{"BNP",0x50,0,0,1,"%b<=0? %t%g"},@|
{"BNPB",0x50,0,0,1,"%b<=0? %t%g"},@|
{"BEV",0x50,0,0,1,"%b even? %t%g"},@|
{"BEVB",0x50,0,0,1,"%b even? %t%g"},@|
{"PBN",0x50,0,0,1,"%b<0? %t%g"},@|
{"PBNB",0x50,0,0,1,"%b<0? %t%g"},@|
{"PBZ",0x50,0,0,1,"%b==0? %t%g"},@|
{"PBZB",0x50,0,0,1,"%b==0? %t%g"},@|
{"PBP",0x50,0,0,1,"%b>0? %t%g"},@|
{"PBPB",0x50,0,0,1,"%b>0? %t%g"},@|
{"PBOD",0x50,0,0,1,"%b odd? %t%g"},@|
{"PBODB",0x50,0,0,1,"%b odd? %t%g"},@|
{"PBNN",0x50,0,0,1,"%b>=0? %t%g"},@|
{"PBNNB",0x50,0,0,1,"%b>=0? %t%g"},@|
{"PBNZ",0x50,0,0,1,"%b!=0? %t%g"},@|
{"PBNZB",0x50,0,0,1,"%b!=0? %t%g"},@|
{"PBNP",0x50,0,0,1,"%b<=0? %t%g"},@|
{"PBNPB",0x50,0,0,1,"%b<=0? %t%g"},@|
{"PBEV",0x50,0,0,1,"%b even? %t%g"},@|
{"PBEVB",0x50,0,0,1,"%b even? %t%g"},@|
{"CSN",0x3a,0,0,1,"%l = %y<0? %z: %b = %x"},@|
{"CSNI",0x39,0,0,1,"%l = %y<0? %z: %b = %x"},@|
{"CSZ",0x3a,0,0,1,"%l = %y==0? %z: %b = %x"},@|
{"CSZI",0x39,0,0,1,"%l = %y==0? %z: %b = %x"},@|
{"CSP",0x3a,0,0,1,"%l = %y>0? %z: %b = %x"},@|
{"CSPI",0x39,0,0,1,"%l = %y>0? %z: %b = %x"},@|
{"CSOD",0x3a,0,0,1,"%l = %y odd? %z: %b = %x"},@|
{"CSODI",0x39,0,0,1,"%l = %y odd? %z: %b = %x"},@|
{"CSNN",0x3a,0,0,1,"%l = %y>=0? %z: %b = %x"},@|
{"CSNNI",0x39,0,0,1,"%l = %y>=0? %z: %b = %x"},@|
{"CSNZ",0x3a,0,0,1,"%l = %y!=0? %z: %b = %x"},@|
{"CSNZI",0x39,0,0,1,"%l = %y!=0? %z: %b = %x"},@|
{"CSNP",0x3a,0,0,1,"%l = %y<=0? %z: %b = %x"},@|
{"CSNPI",0x39,0,0,1,"%l = %y<=0? %z: %b = %x"},@|
{"CSEV",0x3a,0,0,1,"%l = %y even? %z: %b = %x"},@|
{"CSEVI",0x39,0,0,1,"%l = %y even? %z: %b = %x"},@|
{"ZSN",0x2a,0,0,1,"%l = %y<0? %z: 0 = %x"},@|
{"ZSNI",0x29,0,0,1,"%l = %y<0? %z: 0 = %x"},@|
{"ZSZ",0x2a,0,0,1,"%l = %y==0? %z: 0 = %x"},@|
{"ZSZI",0x29,0,0,1,"%l = %y==0? %z: 0 = %x"},@|
{"ZSP",0x2a,0,0,1,"%l = %y>0? %z: 0 = %x"},@|
{"ZSPI",0x29,0,0,1,"%l = %y>0? %z: 0 = %x"},@|
{"ZSOD",0x2a,0,0,1,"%l = %y odd? %z: 0 = %x"},@|
{"ZSODI",0x29,0,0,1,"%l = %y odd? %z: 0 = %x"},@|
{"ZSNN",0x2a,0,0,1,"%l = %y>=0? %z: 0 = %x"},@|
{"ZSNNI",0x29,0,0,1,"%l = %y>=0? %z: 0 = %x"},@|
{"ZSNZ",0x2a,0,0,1,"%l = %y!=0? %z: 0 = %x"},@|
{"ZSNZI",0x29,0,0,1,"%l = %y!=0? %z: 0 = %x"},@|
{"ZSNP",0x2a,0,0,1,"%l = %y<=0? %z: 0 = %x"},@|
{"ZSNPI",0x29,0,0,1,"%l = %y<=0? %z: 0 = %x"},@|
{"ZSEV",0x2a,0,0,1,"%l = %y even? %z: 0 = %x"},@|
{"ZSEVI",0x29,0,0,1,"%l = %y even? %z: 0 = %x"}

@ @<Info for load/store commands@>=
{"LDB",0x2a,0,1,1,"%l = M1[%#y+%#z] = %x"},@|
{"LDBI",0x29,0,1,1,"%l = M1[%#y%?+] = %x"},@|
{"LDBU",0x2a,0,1,1,"%l = M1[%#y+%#z] = %#x"},@|
{"LDBUI",0x29,0,1,1,"%l = M1[%#y%?+] = %#x"},@|
{"LDW",0x2a,0,1,1,"%l = M2[%#y+%#z] = %x"},@|
{"LDWI",0x29,0,1,1,"%l = M2[%#y%?+] = %x"},@|
{"LDWU",0x2a,0,1,1,"%l = M2[%#y+%#z] = %#x"},@|
{"LDWUI",0x29,0,1,1,"%l = M2[%#y%?+] = %#x"},@|
{"LDT",0x2a,0,1,1,"%l = M4[%#y+%#z] = %x"},@|
{"LDTI",0x29,0,1,1,"%l = M4[%#y%?+] = %x"},@|
{"LDTU",0x2a,0,1,1,"%l = M4[%#y+%#z] = %#x"},@|
{"LDTUI",0x29,0,1,1,"%l = M4[%#y%?+] = %#x"},@|
{"LDO",0x2a,0,1,1,"%l = M8[%#y+%#z] = %x"},@|
{"LDOI",0x29,0,1,1,"%l = M8[%#y%?+] = %x"},@|
{"LDOU",0x2a,0,1,1,"%l = M8[%#y+%#z] = %#x"},@|
{"LDOUI",0x29,0,1,1,"%l = M8[%#y%?+] = %#x"},@|
{"LDSF",0x2a,0,1,1,"%l = (M4[%#y+%#z]) = %.x"},@|
{"LDSFI",0x29,0,1,1,"%l = (M4[%#y%?+]) = %.x"},@|
{"LDHT",0x2a,0,1,1,"%l = M4[%#y+%#z]<<32 = %#x"},@|
{"LDHTI",0x29,0,1,1,"%l = M4[%#y%?+]<<32 = %#x"},@|
{"CSWAP",0x3a,0,2,2,"%l = [M8[%#y+%#z]==%a] = %x, %r"},@|
{"CSWAPI",0x39,0,2,2,"%l = [M8[%#y%?+]==%a] = %x, %r"},@|
{"LDUNC",0x2a,0,1,1,"%l = M8[%#y+%#z] = %#x"},@|
{"LDUNCI",0x29,0,1,1,"%l = M8[%#y%?+] = %#x"},@|
{"LDVTS",0x2a,0,0,1,""},@|
{"LDVTSI",0x29,0,0,1,""},@|
{"PRELD",0x0a,0,0,1,"[%#y+%#z .. %#x]"},@|
{"PRELDI",0x09,0,0,1,"[%#y%?+ .. %#x]"},@|
{"PREGO",0x0a,0,0,1,"[%#y+%#z .. %#x]"},@|
{"PREGOI",0x09,0,0,1,"[%#y%?+ .. %#x]"},@|
{"GO",0x2a,0,0,3,"%l = %#x, -> %#y+%#z"},@|
{"GOI",0x29,0,0,3,"%l = %#x, -> %#y%?+"},@|
{"STB",0x1a,0,1,1,"M1[%#y+%#z] = %b, M8[%#w]=%#a"},@|
{"STBI",0x19,0,1,1,"M1[%#y%?+] = %b, M8[%#w]=%#a"},@|
{"STBU",0x1a,0,1,1,"M1[%#y+%#z] = %#b, M8[%#w]=%#a"},@|
{"STBUI",0x19,0,1,1,"M1[%#y%?+] = %#b, M8[%#w]=%#a"},@|
{"STW",0x1a,0,1,1,"M2[%#y+%#z] = %b, M8[%#w]=%#a"},@|
{"STWI",0x19,0,1,1,"M2[%#y%?+] = %b, M8[%#w]=%#a"},@|
{"STWU",0x1a,0,1,1,"M2[%#y+%#z] = %#b, M8[%#w]=%#a"},@|
{"STWUI",0x19,0,1,1,"M2[%#y%?+] = %#b, M8[%#w]=%#a"},@|
{"STT",0x1a,0,1,1,"M4[%#y+%#z] = %b, M8[%#w]=%#a"},@|
{"STTI",0x19,0,1,1,"M4[%#y%?+] = %b, M8[%#w]=%#a"},@|
{"STTU",0x1a,0,1,1,"M4[%#y+%#z] = %#b, M8[%#w]=%#a"},@|
{"STTUI",0x19,0,1,1,"M4[%#y%?+] = %#b, M8[%#w]=%#a"},@|
{"STO",0x1a,0,1,1,"M8[%#y+%#z] = %b"},@|
{"STOI",0x19,0,1,1,"M8[%#y%?+] = %b"},@|
{"STOU",0x1a,0,1,1,"M8[%#y+%#z] = %#b"},@|
{"STOUI",0x19,0,1,1,"M8[%#y%?+] = %#b"},@|
{"STSF",0x1a,0,1,1,"%(M4[%#y+%#z]%) = %.b, M8[%#w]=%#a"},@|
{"STSFI",0x19,0,1,1,"%(M4[%#y%?+]%) = %.b, M8[%#w]=%#a"},@|
{"STHT",0x1a,0,1,1,"M4[%#y+%#z] = %#b>>32, M8[%#w]=%#a"},@|
{"STHTI",0x19,0,1,1,"M4[%#y%?+] = %#b>>32, M8[%#w]=%#a"},@|
{"STCO",0x0a,0,1,1,"M8[%#y+%#z] = %b"},@|
{"STCOI",0x09,0,1,1,"M8[%#y%?+] = %b"},@|
{"STUNC",0x1a,0,1,1,"M8[%#y+%#z] = %#b"},@|
{"STUNCI",0x19,0,1,1,"M8[%#y%?+] = %#b"},@|
{"SYNCD",0x0a,0,0,1,"[%#y+%#z .. %#x]"},@|
{"SYNCDI",0x09,0,0,1,"[%#y%?+ .. %#x]"},@|
{"PREST",0x0a,0,0,1,"[%#y+%#z .. %#x]"},@|
{"PRESTI",0x09,0,0,1,"[%#y%?+ .. %#x]"},@|
{"SYNCID",0x0a,0,0,1,"[%#y+%#z .. %#x]"},@|
{"SYNCIDI",0x09,0,0,1,"[%#y%?+ .. %#x]"},@|
{"PUSHGO",0xaa,0,0,3,"%lrO=%#b, rL=%a, rJ=%#x, -> %#y+%#z"},@|
{"PUSHGOI",0xa9,0,0,3,"%lrO=%#b, rL=%a, rJ=%#x, -> %#y%?+"}

@ @<Info for logical and control commands@>=
{"OR",0x2a,0,0,1,"%l = %#y | %#z = %#x"},@|
{"ORI",0x29,0,0,1,"%l = %#y | %z = %#x"},@|
{"ORN",0x2a,0,0,1,"%l = %#y |~ %#z = %#x"},@|
{"ORNI",0x29,0,0,1,"%l = %#y |~ %z = %#x"},@|
{"NOR",0x2a,0,0,1,"%l = %#y ~| %#z = %#x"},@|
{"NORI",0x29,0,0,1,"%l = %#y ~| %z = %#x"},@|
{"XOR",0x2a,0,0,1,"%l = %#y ^ %#z = %#x"},@|
{"XORI",0x29,0,0,1,"%l = %#y ^ %z = %#x"},@|
{"AND",0x2a,0,0,1,"%l = %#y & %#z = %#x"},@|
{"ANDI",0x29,0,0,1,"%l = %#y & %z = %#x"},@|
{"ANDN",0x2a,0,0,1,"%l = %#y \\ %#z = %#x"},@|
{"ANDNI",0x29,0,0,1,"%l = %#y \\ %z = %#x"},@|
{"NAND",0x2a,0,0,1,"%l = %#y ~& %#z = %#x"},@|
{"NANDI",0x29,0,0,1,"%l = %#y ~& %z = %#x"},@|
{"NXOR",0x2a,0,0,1,"%l = %#y ~^ %#z = %#x"},@|
{"NXORI",0x29,0,0,1,"%l = %#y ~^ %z = %#x"},@|
{"BDIF",0x2a,0,0,1,"%l = %#y bdif %#z = %#x"},@|
{"BDIFI",0x29,0,0,1,"%l = %#y bdif %z = %#x"},@|
{"WDIF",0x2a,0,0,1,"%l = %#y wdif %#z = %#x"},@|
{"WDIFI",0x29,0,0,1,"%l = %#y wdif %z = %#x"},@|
{"TDIF",0x2a,0,0,1,"%l = %#y tdif %#z = %#x"},@|
{"TDIFI",0x29,0,0,1,"%l = %#y tdif %z = %#x"},@|
{"ODIF",0x2a,0,0,1,"%l = %#y odif %#z = %#x"},@|
{"ODIFI",0x29,0,0,1,"%l = %#y odif %z = %#x"},@|
{"MUX",0x2a,rM,0,1,"%l = %#b? %#y: %#z = %#x"},@|
{"MUXI",0x29,rM,0,1,"%l = %#b? %#y: %z = %#x"},@|
{"SADD",0x2a,0,0,1,"%l = nu(%#y\\%#z) = %x"},@|
{"SADDI",0x29,0,0,1,"%l = nu(%#y%?\\) = %x"},@|
{"MOR",0x2a,0,0,1,"%l = %#y mor %#z = %#x"},@|
{"MORI",0x29,0,0,1,"%l = %#y mor %z = %#x"},@|
{"MXOR",0x2a,0,0,1,"%l = %#y mxor %#z = %#x"},@|
{"MXORI",0x29,0,0,1,"%l = %#y mxor %z = %#x"},@|
{"SETH",0x20,0,0,1,"%l = %#z"},@|
{"SETMH",0x20,0,0,1,"%l = %#z"},@|
{"SETML",0x20,0,0,1,"%l = %#z"},@|
{"SETL",0x20,0,0,1,"%l = %#z"},@|
{"INCH",0x30,0,0,1,"%l = %#y + %#z = %#x"},@|
{"INCMH",0x30,0,0,1,"%l = %#y + %#z = %#x"},@|
{"INCML",0x30,0,0,1,"%l = %#y + %#z = %#x"},@|
{"INCL",0x30,0,0,1,"%l = %#y + %#z = %#x"},@|
{"ORH",0x30,0,0,1,"%l = %#y | %#z = %#x"},@|
{"ORMH",0x30,0,0,1,"%l = %#y | %#z = %#x"},@|
{"ORML",0x30,0,0,1,"%l = %#y | %#z = %#x"},@|
{"ORL",0x30,0,0,1,"%l = %#y | %#z = %#x"},@|
{"ANDNH",0x30,0,0,1,"%l = %#y \\ %#z = %#x"},@|
{"ANDNMH",0x30,0,0,1,"%l = %#y \\ %#z = %#x"},@|
{"ANDNML",0x30,0,0,1,"%l = %#y \\ %#z = %#x"},@|
{"ANDNL",0x30,0,0,1,"%l = %#y \\ %#z = %#x"},@|
{"JMP",0x40,0,0,1,"-> %#z"},@|
{"JMPB",0x40,0,0,1,"-> %#z"},@|
{"PUSHJ",0xe0,0,0,1,"%lrO=%#b, rL=%a, rJ=%#x, -> %#z"},@|
{"PUSHJB",0xe0,0,0,1,"%lrO=%#b, rL=%a, rJ=%#x, -> %#z"},@|
{"GETA",0x60,0,0,1,"%l = %#z"},@|
{"GETAB",0x60,0,0,1,"%l = %#z"},@|
{"PUT",0x02,0,0,1,"%s = %r"},@|
{"PUTI",0x01,0,0,1,"%s = %r"},@|
{"POP",0x80,rJ,0,3,"%lrL=%a, rO=%#b, -> %#y%?+"},@|
{"RESUME",0x00,0,0,5,"{%#b} -> %#z"},@|
{"SAVE",0x20,0,20,1,"%l = %#x"},@|
{"UNSAVE",0x82,0,20,1,"%#z: rG=%x, ..., rL=%a"},@|
{"SYNC",0x01,0,0,1,""},@|
{"SWYM",0x00,0,0,1,""},@|
{"GET",0x20,0,0,1,"%l = %s = %#x"},@|
{"TRIP",0x0a,255,0,5,"rW=%#w, rX=%#x, rY=%#y, rZ=%#z, rB=%#b, g[255]=%#a"}

@ @<Convert relative address to absolute address@>=
{
  if ((op&0xfe)==JMP) yz=inst&0xffffff;
  if (op&1) yz-=(op==JMPB? 0x1000000: 0x10000);
  y=inst_ptr;@+ z=incr(loc,yz<<2);
}

@ @<Install operand fields@>=
if (resuming && rop!=RESUME_AGAIN)
  @<Install special operands when resuming an interrupted operation@>@;
else {
  if (f&0x10) @<Set |b| from register X@>;
  if (info[op].third_operand) @<Set |b| from special register@>;
  if (f&0x1) z.l=zz;
  else if (f&0x2) @<Set |z| from register Z@>@;
  else if ((op&0xf0)==SETH) @<Set |z| as an immediate wyde@>;
  if (f&0x4) y.l=yy;
  else if (f&0x8) @<Set |y| from register Y@>;
}

@ There are 256 global registers, |g[0]| through |g[255]|; the
first 32 of them are used for the special registers |rA|, |rB|, etc.
There are |lring_mask+1| local registers, usually 256 but the
user can increase this to a larger power of~2 if desired.

The current values of rL, rG, rO, and rS are kept in separate variables
called |L|, |G|, |O|, and |S| for convenience. (In fact, |O| and |S|
actually hold the values rO/8 and rS/8, modulo |lring_size|.)

@<Set |z| from register Z@>=
{
  if (zz>=G) z=g[zz];
  else if (zz<L) z=l[(O+zz)&lring_mask];
}

@ @<Set |y| from register Y@>=
{
  if (yy>=G) y=g[yy];
  else if (yy<L) y=l[(O+yy)&lring_mask];
}

@ @<Set |b| from register X@>=
{
  if (xx>=G) b=g[xx];
  else if (xx<L) b=l[(O+xx)&lring_mask];
}
  
@ @<Local...@>=
register int G,L,O; /* accessible copies of key registers */

@ @<Glob...@>=
octa g[256]; /* global registers */
octa *l; /* local registers */
int lring_size; /* the number of local registers (a power of 2) */
int lring_mask; /* one less than |lring_size| */
int S; /* congruent to $\rm rS\GG 3$ modulo |lring_size| */

@ Several of the global registers have constant values, because
of the way \MMIX\ has been simplified in this simulator.

Special register rN has a constant value identifying the time of compilation.
(The macro \.{ABSTIME} is defined externally in the file \.{abstime.h},
which should have just been created by {\mc ABSTIME}\kern.05em;
{\mc ABSTIME} is
a trivial program that computes the value of the standard library function
|time(NULL)|. We assume that this number, which is the number of seconds in
the ``{\mc UNIX} epoch,'' is less than~$2^{32}$. Beware: Our assumption will
fail in February of 2106.)
@^system dependencies@>

@d VERSION 1 /* version of the \MMIX\ architecture that we support */
@d SUBVERSION 0 /* secondary byte of version number */
@d SUBSUBVERSION 1 /* further qualification to version number */

@<Initialize...@>=
g[rK]=neg_one;
g[rN].h=(VERSION<<24)+(SUBVERSION<<16)+(SUBSUBVERSION<<8);
g[rN].l=ABSTIME; /* see comment and warning above */
g[rT].h=0x80000005;
g[rTT].h=0x80000006;
g[rV].h=0x369c2004;
if (lring_size<256) lring_size=256;
lring_mask=lring_size-1;
if (lring_size&lring_mask)
  panic("The number of local registers must be a power of 2");
@.The number of local...@>
l=(octa*)calloc(lring_size,sizeof(octa));
if (!l) panic("No room for the local registers");
@.No room...@>
cur_round=ROUND_NEAR;

@ In operations like |INCH|, we want |z| to be the |yz| field,
shifted left 48 bits. We also want |y| to be register~X, which has
previously been placed in |b|; then |INCH| can be simulated as if
it were |ADDU|.

@<Set |z| as an immediate wyde@>=
{
  switch (op&3) {
 case 0: z.h=yz<<16;@+break;
 case 1: z.h=yz;@+break;
 case 2: z.l=yz<<16;@+break;
 case 3: z.l=yz;@+break;
  }
  y=b;
}  

@ @<Set |b| from special register@>=
b=g[info[op].third_operand];

@ @<Install register~X as the destination...@>=
if (xx>=G) {
  sprintf(lhs,"$%d=g[%d]",xx,xx);
  x_ptr=&g[xx];
}@+else {
  while (xx>=L) @<Increase rL@>;
  sprintf(lhs,"$%d=l[%d]",xx,(O+xx)&lring_mask);
  x_ptr=&l[(O+xx)&lring_mask];
}

@ @<Increase rL@>=
{
  l[(O+L)&lring_mask]=zero_octa;
  L=g[rL].l=L+1;
  if (((S-O-L)&lring_mask)==0) stack_store();
}

@ The |stack_store| routine advances the ``gamma'' pointer in the
ring of local registers, by storing the oldest local register into memory
location~rS and advancing rS.

@d test_store_bkpt(ll) if ((ll)->bkpt&write_bit) breakpoint=tracing=true

@<Sub...@>=
void stack_store @,@,@[ARGS((void))@];@+@t}\6{@>
void stack_store()
{
  register mem_tetra *ll=mem_find(g[rS]);
  register int k=S&lring_mask;
  ll->tet=l[k].h;@+test_store_bkpt(ll);
  (ll+1)->tet=l[k].l;@+test_store_bkpt(ll+1);
  if (stack_tracing) {
    tracing=true;
    if (cur_line) show_line();
    printf("             M8[#%08x%08x]=l[%d]=#%08x%08x, rS+=8\n",
              g[rS].h,g[rS].l,k,l[k].h,l[k].l);
  }
  g[rS]=incr(g[rS],8),  S++;
}

@ The |stack_load| routine is essentially the inverse of |stack_store|.

@d test_load_bkpt(ll) if ((ll)->bkpt&read_bit) breakpoint=tracing=true

@<Sub...@>=
void stack_load @,@,@[ARGS((void))@];@+@t}\6{@>
void stack_load()
{
  register mem_tetra *ll;
  register int k;
  S--, g[rS]=incr(g[rS],-8);
  ll=mem_find(g[rS]);
  k=S&lring_mask;
  l[k].h=ll->tet;@+test_load_bkpt(ll);
  l[k].l=(ll+1)->tet;@+test_load_bkpt(ll+1);
  if (stack_tracing) {
    tracing=true;
    if (cur_line) show_line();
    printf("             rS-=8, l[%d]=M8[#%08x%08x]=#%08x%08x\n",
              k,g[rS].h,g[rS].l,l[k].h,l[k].l);
  }
}

@* Simulating the instructions. The master switch branches in 256
directions, one for each \MMIX\ instruction.

Let's start with |ADD|, since it is somehow the most typical case---not
too easy, and not too hard. The task is to compute |x=y+z|, and to
signal overflow if the sum is out of range. Overflow occurs if and
only if |y| and |z| have the same sign but the sum has a different sign.

Overflow is one of the eight arithmetic exceptions. We record such
exceptions in a variable called~|exc|, which is set to
zero at the beginning of each cycle and used to update~rA at the end.

The main control routine has put the input operands into octabytes
|y| and~|z|. It has also made |x_ptr| point to the octabyte where the
result should be placed.

@<Cases for individual \MMIX\ instructions@>=
case ADD: case ADDI: x=w; /* |w=oplus(y,z)| */
 if (((y.h^z.h)&sign_bit)==0 && ((y.h^x.h)&sign_bit)!=0) exc|=V_BIT;
store_x: *x_ptr=x;@+break;

@ Other cases of signed and unsigned addition and subtraction are,
of course, similar. Overflow occurs in the calculation |x=y-z| if and
only if it occurs in the calculation |y=x+z|.

@<Cases for ind...@>=
case SUB: case SUBI: case NEG: case NEGI: x=ominus(y,z);
 if (((x.h^z.h)&sign_bit)==0 && ((x.h^y.h)&sign_bit)!=0) exc|=V_BIT;
 goto store_x;
case ADDU: case ADDUI: case INCH: case INCMH: case INCML: case INCL:
 x=w;@+goto store_x;
case SUBU: case SUBUI: case NEGU: case NEGUI: x=ominus(y,z);@+goto store_x;
case IIADDU: case IIADDUI: case IVADDU: case IVADDUI:
case VIIIADDU: case VIIIADDUI: case XVIADDU: case XVIADDUI:
 x=oplus(shift_left(y,((op&0xf)>>1)-3),z);@+goto store_x;
case SETH: case SETMH: case SETML: case SETL: case GETA: case GETAB:
 x=z;@+goto store_x;

@ Let's get the simple bitwise operations out of the way too.

@<Cases for ind...@>=
case OR: case ORI: case ORH: case ORMH: case ORML: case ORL:
 x.h=y.h|z.h;@+ x.l=y.l|z.l;@+ goto store_x;
case ORN: case ORNI:
 x.h=y.h|~z.h;@+ x.l=y.l|~z.l;@+ goto store_x;
case NOR: case NORI:
 x.h=~(y.h|z.h);@+ x.l=~(y.l|z.l);@+ goto store_x;
case XOR: case XORI:
 x.h=y.h^z.h;@+ x.l=y.l^z.l;@+ goto store_x;
case AND: case ANDI:
 x.h=y.h&z.h;@+ x.l=y.l&z.l;@+ goto store_x;
case ANDN: case ANDNI: case ANDNH: case ANDNMH: case ANDNML: case ANDNL:
 x.h=y.h&~z.h;@+ x.l=y.l&~z.l;@+ goto store_x;
case NAND: case NANDI:
 x.h=~(y.h&z.h);@+ x.l=~(y.l&z.l);@+ goto store_x;
case NXOR: case NXORI:
 x.h=~(y.h^z.h);@+ x.l=~(y.l^z.l);@+ goto store_x;

@ The less simple bit manipulations are almost equally simple,
given the subroutines of {\mc MMIX-ARITH}.
The |MUX| operation has three inputs;
in such cases the inputs appear in |y|, |z|, and~|b|.

@d shift_amt (z.h || z.l>=64? 64: z.l)

@<Cases for ind...@>=
case SL: case SLI: x=shift_left(y,shift_amt);
  a=shift_right(x,shift_amt,0);
  if (a.h!=y.h || a.l!=y.l) exc|=V_BIT;
  goto store_x;
case SLU: case SLUI: x=shift_left(y,shift_amt);@+goto store_x;
case SR: case SRI: case SRU: case SRUI:
  x=shift_right(y,shift_amt,op&0x2);@+goto store_x;
case MUX: case MUXI:
 x.h=(y.h&b.h)|(z.h&~b.h);@+ x.l=(y.l&b.l)|(z.l&~b.l);
 goto store_x;
case SADD: case SADDI:
 x.l=count_bits(y.h&~z.h)+count_bits(y.l&~z.l);@+goto store_x;
case MOR: case MORI:
 x=bool_mult(y,z,false);@+goto store_x;
case MXOR: case MXORI:
 x=bool_mult(y,z,true);@+goto store_x;
case BDIF: case BDIFI:
 x.h=byte_diff(y.h,z.h);@+x.l=byte_diff(y.l,z.l);@+goto store_x;
case WDIF: case WDIFI:
 x.h=wyde_diff(y.h,z.h);@+x.l=wyde_diff(y.l,z.l);@+goto store_x;
case TDIF: case TDIFI:@+
 if (y.h>z.h) x.h=y.h-z.h;
tdif_l:@+ if (y.l>z.l) x.l=y.l-z.l;@+ goto store_x;
case ODIF: case ODIFI:@+if (y.h>z.h) x=ominus(y,z);
 else if (y.h==z.h) goto tdif_l;
 goto store_x; 

@ When an operation has two outputs, the primary output is placed in~|x|
and the auxiliary output is placed in~|a|.

@<Cases for ind...@>=
case MUL: case MULI: x=signed_omult(y,z);
test_overflow:@+if (overflow) exc|=V_BIT;
 goto store_x;
case MULU: case MULUI: x=omult(y,z);@+a=g[rH]=aux;@+goto store_x;
case DIV: case DIVI:@+if (!z.l && !z.h) aux=y, exc|=D_BIT, overflow=false;
 else x=signed_odiv(y,z);
 a=g[rR]=aux;@+goto test_overflow;
case DIVU: case DIVUI: x=odiv(b,y,z);@+a=g[rR]=aux;@+goto store_x;

@ The floating point routines of {\mc MMIX-ARITH} record exceptional
events in a variable called |exceptions|. Here we simply merge those bits into
the |exc| variable. The |U_BIT| is not exactly the
same as ``underflow,'' but the true definition of underflow will be applied
when |exc| is combined with~rA.

@<Cases for ind...@>=
case FADD: x=fplus(y,z);
 fin_float: round_mode=cur_round;
 store_fx: exc|=exceptions;@+ goto store_x;
case FSUB: a=z;@+if (fcomp(a,zero_octa)!=2) a.h^=sign_bit;
 x=fplus(y,a);@+goto fin_float;
case FMUL: x=fmult(y,z);@+goto fin_float;
case FDIV: x=fdivide(y,z);@+goto fin_float;
case FREM: x=fremstep(y,z,2500);@+goto fin_float;
case FSQRT: x=froot(z,y.l);
 fin_unifloat:@+if (y.h || y.l>4) goto illegal_inst;
 round_mode=(y.l? y.l: cur_round);@+goto store_fx;
case FINT: x=fintegerize(z,y.l);@+goto fin_unifloat;
case FIX: x=fixit(z,y.l);@+goto fin_unifloat;
case FIXU: x=fixit(z,y.l);@+exceptions&=~W_BIT;@+goto fin_unifloat;
case FLOT: case FLOTI: case FLOTU: case FLOTUI:
case SFLOT: case SFLOTI: case SFLOTU: case SFLOTUI:
 x=floatit(z,y.l,op&0x2,op&0x4);@+goto fin_unifloat;

@ We have now done all of the arithmetic operations except for the
cases that compare two registers and yield a value of $-1$~or~0~or~1.

@d cmp_zero store_x /* |x| is 0 by default */

@<Cases for ind...@>=
case CMP: case CMPI:@+if ((y.h&sign_bit)>(z.h&sign_bit)) goto cmp_neg;
 if ((y.h&sign_bit)<(z.h&sign_bit)) goto cmp_pos;
case CMPU: case CMPUI:@+if (y.h<z.h) goto cmp_neg;
 if (y.h>z.h) goto cmp_pos;
 if (y.l<z.l) goto cmp_neg;
 if (y.l==z.l) goto cmp_zero;
cmp_pos: x.l=1;@+goto store_x;
cmp_neg: x=neg_one;@+goto store_x;
case FCMPE: k=fepscomp(y,z,b,true);
 if (k) goto cmp_zero_or_invalid;
case FCMP: k=fcomp(y,z);
 if (k<0) goto cmp_neg;
cmp_fin:@+ if (k==1) goto cmp_pos;
cmp_zero_or_invalid:@+ if (k==2) exc|=I_BIT;
 goto cmp_zero;
case FUN:@+ if (fcomp(y,z)==2) goto cmp_pos;@+else goto cmp_zero;
case FEQL:@+ if (fcomp(y,z)==0) goto cmp_pos;@+else goto cmp_zero;
case FEQLE: k=fepscomp(y,z,b,false);
  goto cmp_fin;
case FUNE:@+if (fepscomp(y,z,b,true)==2) goto cmp_pos;@+else goto cmp_zero;

@ We have now done all the register-register operations except for
the conditional commands. Conditional commands and branch commands
all make use of a simple subroutine that determines whether a given
octabyte satisfies the condition of a given opcode.

@<Sub...@>=
int register_truth @,@,@[ARGS((octa,mmix_opcode))@];@+@t}\6{@>
int register_truth(o,op)
  octa o;
  mmix_opcode op;
{@+register int b;
  switch ((op>>1) & 0x3) {
 case 0: b=o.h>>31;@+break; /* negative? */
 case 1: b=(o.h==0 && o.l==0);@+break; /* zero? */
 case 2: b=(o.h<sign_bit && (o.h||o.l));@+break; /* positive? */
 case 3: b=o.l&0x1;@+break; /* odd? */
}
  if (op&0x8) return b^1;
  else return b;
}

@ The |b| operand will be zero on the \.{ZS} operations; it will be
the contents of register~X on the \.{CS} operations.

@<Cases for ind...@>=
case CSN: case CSNI: case CSZ: case CSZI:@/
case CSP: case CSPI: case CSOD: case CSODI:@/
case CSNN: case CSNNI: case CSNZ: case CSNZI:@/
case CSNP: case CSNPI: case CSEV: case CSEVI:@/
case ZSN: case ZSNI: case ZSZ: case ZSZI:@/
case ZSP: case ZSPI: case ZSOD: case ZSODI:@/
case ZSNN: case ZSNNI: case ZSNZ: case ZSNZI:@/
case ZSNP: case ZSNPI: case ZSEV: case ZSEVI:@/
 x=register_truth(y,op)? z: b;@+goto store_x;

@ Didn't that feel good, when 32 opcodes reduced to a single case?
We get to do it one more time. Happiness!

@<Cases for ind...@>=
case BN: case BNB: case BZ: case BZB:@/
case BP: case BPB: case BOD: case BODB:@/
case BNN: case BNNB: case BNZ: case BNZB:@/
case BNP: case BNPB: case BEV: case BEVB:@/
case PBN: case PBNB: case PBZ: case PBZB:@/
case PBP: case PBPB: case PBOD: case PBODB:@/
case PBNN: case PBNNB: case PBNZ: case PBNZB:@/
case PBNP: case PBNPB: case PBEV: case PBEVB:@/
 x.l=register_truth(b,op);
 if (x.l) {
   inst_ptr=z;
   good=(op>=PBN);
 }@+else good=(op<PBN);
 if (good) good_guesses++;
 else bad_guesses++, g[rC].l+=2; /* penalty is $2\upsilon$ for bad guess */
 break;

@ Memory operations are next on our agenda. The memory address,
|y+z|, has already been placed in~|w|.

@<Cases for ind...@>=
case LDB: case LDBI: case LDBU: case LDBUI:@/
 i=56;@+j=(w.l&0x3)<<3; goto fin_ld;
case LDW: case LDWI: case LDWU: case LDWUI:@/
 i=48;@+j=(w.l&0x2)<<3; goto fin_ld;
case LDT: case LDTI: case LDTU: case LDTUI:@/
 i=32;@+j=0;@+ goto fin_ld;
case LDHT: case LDHTI: i=j=0;
fin_ld: ll=mem_find(w);@+test_load_bkpt(ll);
 x.h=ll->tet;
 x=shift_right(shift_left(x,j),i,op&0x2);
check_ld:@+if (w.h&sign_bit) goto privileged_inst;
 goto store_x;
case LDO: case LDOI: case LDOU: case LDOUI: case LDUNC: case LDUNCI:
 w.l&=-8;@+ ll=mem_find(w);
 test_load_bkpt(ll);@+test_load_bkpt(ll+1);
 x.h=ll->tet;@+ x.l=(ll+1)->tet;
 goto check_ld;
case LDSF: case LDSFI: ll=mem_find(w);@+test_load_bkpt(ll);
 x=load_sf(ll->tet);@+ goto check_ld;

@ @<Cases for ind...@>=
case STB: case STBI: case STBU: case STBUI:@/
 i=56;@+j=(w.l&0x3)<<3; goto fin_pst;
case STW: case STWI: case STWU: case STWUI:@/
 i=48;@+j=(w.l&0x2)<<3; goto fin_pst;
case STT: case STTI: case STTU: case STTUI:@/
 i=32;@+j=0;
fin_pst: ll=mem_find(w);
 if ((op&0x2)==0) {
   a=shift_right(shift_left(b,i),i,0);
   if (a.h!=b.h || a.l!=b.l) exc|=V_BIT;
 }
 ll->tet^=(ll->tet^(b.l<<(i-32-j))) & ((((tetra)-1)<<(i-32))>>j);
 goto fin_st;
case STSF: case STSFI: ll=mem_find(w);
 ll->tet=store_sf(b);@+exc=exceptions;
 goto fin_st;
case STHT: case STHTI: ll=mem_find(w);@+ ll->tet=b.h;
fin_st: test_store_bkpt(ll);
 w.l&=-8;@+ll=mem_find(w);
 a.h=ll->tet;@+ a.l=(ll+1)->tet; /* for trace output */
 goto check_st; 
case STCO: case STCOI: b.l=xx;
case STO: case STOI: case STOU: case STOUI: case STUNC: case STUNCI:
 w.l&=-8;@+ll=mem_find(w);
 test_store_bkpt(ll);@+ test_store_bkpt(ll+1);
 ll->tet=b.h;@+ (ll+1)->tet=b.l;
check_st:@+if (w.h&sign_bit) goto privileged_inst;
 break;

@ The |CSWAP| operation has elements of both loading and storing.
We shuffle some of
the operands around so that they will appear correctly in the trace output.

@<Cases for ind...@>=
case CSWAP: case CSWAPI: w.l&=-8;@+ll=mem_find(w);
 test_load_bkpt(ll);@+test_load_bkpt(ll+1);
 a=g[rP];
 if (ll->tet==a.h && (ll+1)->tet==a.l) {
   x.h=0, x.l=1;
   test_store_bkpt(ll);@+test_store_bkpt(ll+1);
   ll->tet=b.h, (ll+1)->tet=b.l;
   strcpy(rhs,"M8[%#w]=%#b");
 }@+else {
   b.h=ll->tet, b.l=(ll+1)->tet;
   g[rP]=b;
   strcpy(rhs,"rP=%#b");
 }
 goto check_ld;

@ The |GET| command is permissive, but |PUT| is restrictive.

@<Cases for ind...@>=
case GET:@+if (yy!=0 || zz>=32) goto illegal_inst;
  x=g[zz];
  goto store_x;
case PUT: case PUTI:@+ if (yy!=0 || xx>=32) goto illegal_inst;
  strcpy(rhs,"%z = %#z");
  if (xx>=8) {
    if (xx<=11) goto illegal_inst; /* can't change rC, rN, rO, rS */
    if (xx<=18) goto privileged_inst;
    if (xx==rA) @<Get ready to update rA@>@;
    else if (xx==rL) @<Set $L=z=\min(z,L)$@>@;
    else if (xx==rG) @<Get ready to update rG@>;
  }
  g[xx]=z;@+zz=xx;@+break;

@ @<Set $L=z=\min(z,L)$@>=
{
  x=z;@+ strcpy(rhs,z.h? "min(rL,%#x) = %z": "min(rL,%x) = %z");
  if (z.l>L || z.h) z.h=0, z.l=L;
  else old_L=L=z.l;
}

@ @<Get ready to update rG@>=
{
  if (z.h!=0 || z.l>255 || z.l<L || z.l<32) goto illegal_inst;
  for (j=z.l; j<G; j++) g[j]=zero_octa;
  G=z.l;
}

@ @d ROUND_OFF 1
@d ROUND_UP 2
@d ROUND_DOWN 3
@d ROUND_NEAR 4

@<Get ready to update rA@>=
{
  if (z.h!=0 || z.l>=0x40000) goto illegal_inst;
  cur_round=(z.l>=0x10000? z.l>>16: ROUND_NEAR);
}

@ Pushing and popping are rather delicate, because we want to trace
them coherently.

@<Cases for ind...@>=
case PUSHGO: case PUSHGOI: inst_ptr=w;@+goto push;
case PUSHJ: case PUSHJB: inst_ptr=z;
push:@+if (xx>=G) {
   xx=L++;
   if (((S-O-L)&lring_mask)==0) stack_store();
 }
 x.l=xx;@+l[(O+xx)&lring_mask]=x; /* the ``hole'' records the amount pushed */
 sprintf(lhs,"l[%d]=%d, ",(O+xx)&lring_mask,xx);
 x=g[rJ]=incr(loc,4);
 L-=xx+1;@+ O+=xx+1;
 b=g[rO]=incr(g[rO],(xx+1)<<3);
sync_L: a.l=g[rL].l=L;@+break;
case POP:@+if (xx!=0 && xx<=L) y=l[(O+xx-1)&lring_mask];
 if (g[rS].l==g[rO].l) stack_load();
 k=l[(O-1)&lring_mask].l&0xff;
 while ((tetra)(O-S)<=(tetra)k) stack_load();
 L=k+(xx<=L? xx: L+1);
 if (L>G) L=G;
 if (L>k) {
   l[(O-1)&lring_mask]=y;
   if (y.h) sprintf(lhs,"l[%d]=#%x%08x, ",(O-1)&lring_mask,y.h,y.l);
   else sprintf(lhs,"l[%d]=#%x, ",(O-1)&lring_mask,y.l);
 }@+else lhs[0]='\0';
 y=g[rJ];@+ z.l=yz<<2;@+ inst_ptr=oplus(y,z);
 O-=k+1;@+ b=g[rO]=incr(g[rO],-((k+1)<<3));
 goto sync_L;

@ To complete our simulation of \MMIX's register stack, we need
to implement |SAVE| and |UNSAVE|.

@<Cases for ind...@>=
case SAVE:@+if (xx<G || yy!=0 || zz!=0) goto illegal_inst;
 l[(O+L)&lring_mask].l=L, L++;
 if (((S-O-L)&lring_mask)==0) stack_store();
 O+=L;@+ g[rO]=incr(g[rO],L<<3);
 L=g[rL].l=0;
 while (g[rO].l!=g[rS].l) stack_store();
 for (k=G;;) {
   @<Store |g[k]| in the register stack@>;
   if (k==255) k=rB;
   else if (k==rR) k=rP;
   else if (k==rZ+1) break;
   else k++;
 }
 O=S, g[rO]=g[rS];
 x=incr(g[rO],-8);@+goto store_x;

@ This part of the program naturally has a lot in common with the
|stack_store| subroutine. (There's a little white lie in the
section name; if |k|~is |rZ+1|, we store rG and~rA, not |g[k]|.)

@<Store |g[k]| in the register stack...@>=
ll=mem_find(g[rS]);
if (k==rZ+1) x.h=G<<24, x.l=g[rA].l;
else x=g[k];
ll->tet=x.h;@+test_store_bkpt(ll);
(ll+1)->tet=x.l;@+test_store_bkpt(ll+1);
if (stack_tracing) {
  tracing=true;
  if (cur_line) show_line();
  if (k>=32) printf("             M8[#%08x%08x]=g[%d]=#%08x%08x, rS+=8\n",
            g[rS].h,g[rS].l,k,x.h,x.l);
  else printf("             M8[#%08x%08x]=%s=#%08x%08x, rS+=8\n",
            g[rS].h,g[rS].l,k==rZ+1? "(rG,rA)": special_name[k],x.h,x.l);
}
S++, g[rS]=incr(g[rS],8);

@ @<Cases for ind...@>=
case UNSAVE:@+if (xx!=0 || yy!=0) goto illegal_inst;
 z.l&=-8;@+g[rS]=incr(z,8);
 for (k=rZ+1;;) {
   @<Load |g[k]| from the register stack@>;
   if (k==rP) k=rR;
   else if (k==rB) k=255;
   else if (k==G) break;
   else k--;
 }
 S=g[rS].l>>3;
 stack_load();
 k=l[S&lring_mask].l&0xff;
 for (j=0;j<k;j++) stack_load();
 O=S;@+ g[rO]=g[rS];
 L=k>G? G: k;
 g[rL].l=L;@+a=g[rL];
 g[rG].l=G;@+break;

@ @<Load |g[k]| from the register stack@>=
g[rS]=incr(g[rS],-8);
ll=mem_find(g[rS]);
test_load_bkpt(ll);@+test_load_bkpt(ll+1);
if (k==rZ+1) x.l=G=g[rG].l=ll->tet>>24, a.l=g[rA].l=(ll+1)->tet&0x3ffff;
else g[k].h=ll->tet, g[k].l=(ll+1)->tet;
if (stack_tracing) {
  tracing=true;
  if (cur_line) show_line();
  if (k>=32) printf("             rS-=8, g[%d]=M8[#%08x%08x]=#%08x%08x\n",
            k,g[rS].h,g[rS].l,ll->tet,(ll+1)->tet);
  else if (k==rZ+1) printf("             (rG,rA)=M8[#%08x%08x]=#%08x%08x\n",
            g[rS].h,g[rS].l,ll->tet,(ll+1)->tet);
  else printf("             rS-=8, %s=M8[#%08x%08x]=#%08x%08x\n",
            special_name[k],g[rS].h,g[rS].l,ll->tet,(ll+1)->tet);
}

@ The cache maintenance instructions don't affect this simulation,
because there are no caches. But if the user has invoked them, we do
provide a bit of information when tracing, indicating the scope of the
instruction.

@<Cases for ind...@>=
case SYNCID: case SYNCIDI: case PREST: case PRESTI:
case SYNCD: case SYNCDI: case PREGO: case PREGOI:
case PRELD: case PRELDI: x=incr(w,xx);@+break;

@ Several loose ends remain to be nailed down.
% (Incidentally, a ``loose end'' should never be confused with ``Lucent.'')

@<Cases for ind...@>=
case GO: case GOI: x=inst_ptr;@+inst_ptr=w;@+goto store_x;
case JMP: case JMPB: inst_ptr=z;
case SWYM: break;
case SYNC:@+if (xx!=0 || yy!=0 || zz>7) goto illegal_inst;
 if (zz<=3) break;
case LDVTS: case LDVTSI: privileged_inst: strcpy(lhs,"!privileged");
 goto break_inst;
illegal_inst: strcpy(lhs,"!illegal");
break_inst: breakpoint=tracing=true;
 if (!interacting && !interact_after_break) halted=true;
 break;

@* Trips and traps. We have now implemented 253 of the 256 instructions: all
but \.{TRIP}, \.{TRAP}, and \.{RESUME}.

The |TRIP| instruction simply turns |H_BIT| on in the |exc| variable;
this will trigger an interruption to location~0.
@^interrupts@>

The |TRAP| instruction is not simulated, except for the system calls
mentioned in the introduction.

@<Cases for ind...@>=
case TRIP: exc|=H_BIT;@+break;
case TRAP:@+if (xx!=0 || yy>max_sys_call) goto privileged_inst;
 strcpy(rhs,trap_format[yy]);
 g[rWW]=inst_ptr;
 g[rXX].h=sign_bit, g[rXX].l=inst;
 g[rYY]=y, g[rZZ]=z;
 z.h=0, z.l=zz;
 a=incr(b,8);
 @<Prepare memory arguments $|ma|={\rm M}[a]$ and $|mb|={\rm M}[b]$ if needed@>;
 switch (yy) {
case Halt: @<Either halt or print warning@>;@+g[rBB]=g[255];@+break;
case Fopen: g[rBB]=mmix_fopen((unsigned char)zz,mb,ma);@+break;
case Fclose: g[rBB]=mmix_fclose((unsigned char)zz);@+break;
case Fread: g[rBB]=mmix_fread((unsigned char)zz,mb,ma);@+break;
case Fgets: g[rBB]=mmix_fgets((unsigned char)zz,mb,ma);@+break;
case Fgetws: g[rBB]=mmix_fgetws((unsigned char)zz,mb,ma);@+break;
case Fwrite: g[rBB]=mmix_fwrite((unsigned char)zz,mb,ma);@+break;
case Fputs: g[rBB]=mmix_fputs((unsigned char)zz,b);@+break;
case Fputws: g[rBB]=mmix_fputws((unsigned char)zz,b);@+break;
case Fseek: g[rBB]=mmix_fseek((unsigned char)zz,b);@+break;
case Ftell: g[rBB]=mmix_ftell((unsigned char)zz);@+break;
}
 x=g[255]=g[rBB];@+break;

@ @<Either halt or print warning@>=
if (!zz) halted=breakpoint=true;
else if (zz==1) {
  if (loc.h || loc.l>=0x90) goto privileged_inst;
  print_trip_warning(loc.l>>4,incr(g[rW],-4));
}@+else goto privileged_inst;

@ @<Glob...@>=
char arg_count[]={1,3,1,3,3,3,3,2,2,2,1};
char *trap_format[]={
"Halt(%z)",
"$255 = Fopen(%!z,M8[%#b]=%#q,M8[%#a]=%p) = %x",
"$255 = Fclose(%!z) = %x",
"$255 = Fread(%!z,M8[%#b]=%#q,M8[%#a]=%p) = %x",
"$255 = Fgets(%!z,M8[%#b]=%#q,M8[%#a]=%p) = %x",
"$255 = Fgetws(%!z,M8[%#b]=%#q,M8[%#a]=%p) = %x",
"$255 = Fwrite(%!z,M8[%#b]=%#q,M8[%#a]=%p) = %x",
"$255 = Fputs(%!z,%#b) = %x",
"$255 = Fputws(%!z,%#b) = %x",
"$255 = Fseek(%!z,%b) = %x",
"$255 = Ftell(%!z) = %x"};

@ @<Prepare memory arguments...@>=
if (arg_count[yy]==3) {
  ll=mem_find(b);@+test_load_bkpt(ll);@+test_load_bkpt(ll+1);
  mb.h=ll->tet, mb.l=(ll+1)->tet;
  ll=mem_find(a);@+test_load_bkpt(ll);@+test_load_bkpt(ll+1);
  ma.h=ll->tet, ma.l=(ll+1)->tet;
}

@ The input/output operations invoked by \.{TRAP}s are
done by subroutines in an auxiliary program module called {\mc MMIX-IO}.
Here we need only declare those subroutines, and write three primitive
interfaces on which they depend.

@ @<Glob...@>=
extern void mmix_io_init @,@,@[ARGS((void))@];
extern octa mmix_fopen @,@,@[ARGS((unsigned char,octa,octa))@];
extern octa mmix_fclose @,@,@[ARGS((unsigned char))@];
extern octa mmix_fread @,@,@[ARGS((unsigned char,octa,octa))@];
extern octa mmix_fgets @,@,@[ARGS((unsigned char,octa,octa))@];
extern octa mmix_fgetws @,@,@[ARGS((unsigned char,octa,octa))@];
extern octa mmix_fwrite @,@,@[ARGS((unsigned char,octa,octa))@];
extern octa mmix_fputs @,@,@[ARGS((unsigned char,octa))@];
extern octa mmix_fputws @,@,@[ARGS((unsigned char,octa))@];
extern octa mmix_fseek @,@,@[ARGS((unsigned char,octa))@];
extern octa mmix_ftell @,@,@[ARGS((unsigned char))@];
extern void print_trip_warning @,@,@[ARGS((int,octa))@];
extern void mmix_fake_stdin @,@,@[ARGS((FILE*))@];

@ The subroutine |mmgetchars(buf,size,addr,stop)| reads characters
starting at address |addr| in the simulated memory and stores them
in |buf|, continuing until |size| characters have been read or
some other stopping criterion has been met. If |stop<0| there is
no other criterion; if |stop=0| a null character will also terminate
the process; otherwise |addr| is even, and two consecutive null bytes
starting at an even address will terminate the process. The number
of bytes read and stored, exclusive of terminating nulls, is returned.

@<Sub...@>=
int mmgetchars @,@,@[ARGS((char*,int,octa,int))@];@+@t}\6{@>
int mmgetchars(buf,size,addr,stop)
  char *buf;
  int size;
  octa addr;
  int stop;
{
  register char *p;
  register int m;
  register mem_tetra *ll;
  register tetra x;
  octa a;
  for (p=buf,m=0,a=addr; m<size;) {
    ll=mem_find(a);@+test_load_bkpt(ll);
    x=ll->tet;
    if ((a.l&0x3) || m>size-4) @<Read and store one byte; |return| if done@>@;
    else @<Read and store up to four bytes; |return| if done@>@;
  }
  return size;
}

@ @<Read and store one byte...@>=
{
  *p=(x>>(8*((~a.l)&0x3)))&0xff;
  if (!*p && stop>=0) {
    if (stop==0) return m;
    if ((a.l&0x1) && *(p-1)=='\0') return m-1;
  }
  p++,m++,a=incr(a,1);
}

@ @<Read and store up to four bytes...@>=
{
  *p=x>>24;
  if (!*p && (stop==0 || (stop>0 && x<0x10000))) return m;
  *(p+1)=(x>>16)&0xff;
  if (!*(p+1) && stop==0) return m+1;
  *(p+2)=(x>>8)&0xff;
  if (!*(p+2) && (stop==0 || (stop>0 && (x&0xffff)==0))) return m+2;
  *(p+3)=x&0xff;
  if (!*(p+3) && stop==0) return m+3;
  p+=4,m+=4,a=incr(a,4);
}
      
@ The subroutine |mmputchars(buf,size,addr)| puts |size| characters
into the simulated memory starting at address |addr|.

@<Sub...@>=
void mmputchars @,@,@[ARGS((unsigned char*,int,octa))@];@+@t}\6{@>
void mmputchars(buf,size,addr)
  unsigned char *buf;
  int size;
  octa addr;
{
  register unsigned char *p;
  register int m;
  register mem_tetra *ll;
  octa a;
  for (p=buf,m=0,a=addr; m<size;) {
    ll=mem_find(a);@+test_store_bkpt(ll);
    if ((a.l&0x3) || m>size-4) @<Load and write one byte@>@;
    else @<Load and write four bytes@>;
  }
}

@ @<Load and write one byte@>=
{
  register int s=8*((~a.l)&0x3);
  ll->tet^=(((ll->tet>>s)^*p)&0xff)<<s;
  p++,m++,a=incr(a,1);
}

@ @<Load and write four bytes@>=
{
  ll->tet=(*p<<24)+(*(p+1)<<16)+(*(p+2)<<8)+*(p+3);
  p+=4,m+=4,a=incr(a,4);
}

@ When standard input is being read by the simulated program at the same time
as it is being used for interaction, we try to keep the two uses separate
by maintaining a private buffer for the simulated program's \.{StdIn}.
Online input is usually transmitted from the keyboard to a \CEE/ program
a line at a time; therefore an
|fgets| operation works much better than |fread| when we prompt
for new input. But there is a slight complication, because |fgets|
might read a null character before coming to a newline character.
We cannot deduce the number of characters read by |fgets| simply
by looking at |strlen(stdin_buf)|.

@<Sub...@>=
char stdin_chr @,@,@[ARGS((void))@];@+@t}\6{@>
char stdin_chr()
{
  register char* p;
  while (stdin_buf_start==stdin_buf_end) {
    if (interacting) {
      printf("StdIn> ");@+fflush(stdout);
@.StdIn>@>
    }
    if (!fgets(stdin_buf,256,stdin))
      panic("End of file on standard input; use the -f option, not <");
    stdin_buf_start=stdin_buf;
    for (p=stdin_buf;p<stdin_buf+254;p++) if(*p=='\n') break;
    stdin_buf_end=p+1;
  }
  return *stdin_buf_start++;
}

@ @<Glob...@>=
char stdin_buf[256]; /* standard input to the simulated program */
char *stdin_buf_start; /* current position in that buffer */
char *stdin_buf_end; /* current end of that buffer */

@ Just after executing each instruction, we do the following.
Underflow that is exact and not enabled is ignored. (This applies
also to underflow that was triggered by |RESUME_SET|.)

@<Check for trip interrupt@>=
if ((exc&(U_BIT+X_BIT))==U_BIT && !(g[rA].l&U_BIT)) exc &=~U_BIT;
if (exc) {
  if (exc&tracing_exceptions) tracing=true;
  j=exc&(g[rA].l|H_BIT); /* find all exceptions that have been enabled */
  if (j) @<Initiate a trip interrupt@>;
  g[rA].l |= exc>>8;
}

@ @<Initiate a trip interrupt@>=
{
  tripping=true;
  for (k=0; !(j&H_BIT); j<<=1, k++) ;
  exc&=~(H_BIT>>k); /* trips taken are not logged as events */
  g[rW]=inst_ptr;
  inst_ptr.h=0, inst_ptr.l=k<<4;
  g[rX].h=sign_bit, g[rX].l=inst;
  if ((op&0xe0)==STB) g[rY]=w, g[rZ]=b;
  else g[rY]=y, g[rZ]=z;
  g[rB]=g[255];
  g[255]=g[rJ];
  if (op==TRIP) w=g[rW], x=g[rX], a=g[255];
}

@ We are finally ready for the last case.

@<Cases for ind...@>=
case RESUME:@+if (xx || yy || zz) goto illegal_inst;
inst_ptr=z=g[rW];
b=g[rX];
if (!(b.h&sign_bit)) @<Prepare to perform a ropcode@>;
break;

@ Here we check to see if the ropcode restrictions hold.
If so, the ropcode will actually be obeyed on the next fetch phase.

@d RESUME_AGAIN 0 /* repeat the command in rX as if in location $\rm rW-4$ */
@d RESUME_CONT 1 /* same, but substitute rY and rZ for operands */
@d RESUME_SET 2 /* set r[X] to rZ */

@<Prepare to perform a ropcode@>=
{
  rop=b.h>>24; /* the ropcode is the leading byte of rX */
  switch (rop) {
 case RESUME_CONT:@+if ((1<<(b.l>>28))&0x8f30) goto illegal_inst;
 case RESUME_SET: k=(b.l>>16)&0xff;
   if (k>=L && k<G) goto illegal_inst;
 case RESUME_AGAIN:@+if ((b.l>>24)==RESUME) goto illegal_inst;
   break;
 default: goto illegal_inst;
  }
  resuming=true;
}

@ @<Install special operands when resuming an interrupted operation@>=
if (rop==RESUME_SET) {
    op=ORI;
    y=g[rZ];
    z=zero_octa;
    exc=g[rX].h&0xff00;
    f=X_is_dest_bit;
}@+else { /* |RESUME_CONT| */
  y=g[rY];
  z=g[rZ];
}

@ We don't want to count the |UNSAVE| that bootstraps the whole process.

@<Update the clocks@>=
if (g[rU].l || g[rU].h || !resuming) {
  g[rC].h+=info[op].mems; /* clock goes up by $2^{32}$ for each $\mu$ */
  g[rC]=incr(g[rC],info[op].oops); /* clock goes up by 1 for each $\upsilon$ */
  g[rU]=incr(g[rU],1); /* usage counter counts total instructions simulated */
  g[rI]=incr(g[rI],-1); /* interval timer counts down by 1 only */
  if (g[rI].l==0 && g[rI].h==0) tracing=breakpoint=true;
}

@* Tracing. After an instruction has been executed, we often want
to display its effect. This part of the program prints out a
symbolic interpretation of what has just happened.

@<Trace...@>=
if (tracing) {
  if (showing_source && cur_line) show_line();
  @<Print the frequency count, the location, and the instruction@>;
  @<Print a stream-of-consciousness description of the instruction@>;
  if (showing_stats || breakpoint) show_stats(breakpoint);
  just_traced=true;
}@+else if (just_traced) {
  printf(" ...............................................\n");
  just_traced=false;
  shown_line=-gap-1; /* gap will not be filled */
}

@ @<Glob...@>=
bool showing_stats; /* should traced instructions also show the statistics? */
bool just_traced; /* was the previous instruction traced? */

@ @<Print the frequency count, the location, and the instruction@>=
if (resuming && op!=RESUME) {
  switch (rop) {
 case RESUME_AGAIN: printf("           (%08x%08x: %08x (%s)) ",
                     loc.h,loc.l,inst,info[op].name);@+break;
 case RESUME_CONT: printf("           (%08x%08x: %04xrYrZ (%s)) ",
                     loc.h,loc.l,inst>>16,info[op].name);@+break;
 case RESUME_SET: printf("           (%08x%08x: ..%02x..rZ (SET)) ",
                     loc.h,loc.l,(inst>>16)&0xff);@+break;
  }
}@+else {
  ll=mem_find(loc);
  printf("%10d. %08x%08x: %08x (%s) ",ll->freq,loc.h,loc.l,inst,info[op].name);
}

@ This part of the simulator was inspired by ideas of E.~H. Satterthwaite,
@^Satterthwaite, Edwin Hallowell, Jr.@>
{\sl Software---Practice and Experience\/ \bf2} (1972), 197--217.
Online debugging tools have improved significantly since Satterthwaite
published his work, but good offline tools are still valuable;
alas, today's algebraic programming languages do not provide tracing
facilities that come anywhere close to the level of quality that Satterthwaite
was able to demonstrate for {\mc ALGOL} in 1970.

@<Print a stream-of-consciousness description of the instruction@>=
if (lhs[0]=='!') printf("%s instruction!\n",lhs+1); /* privileged or illegal */
else {
  @<Print changes to rL@>;
  if (z.l==0 && (op==ADDUI||op==ORI)) p="%l = %y = %#x"; /* \.{LDA}, \.{SET} */
  else p=info[op].trace_format;
  for (;*p;p++) @<Interpret character |*p| in the trace format@>;
  if (exc) printf(", rA=#%05x", g[rA].l);
  if (tripping) tripping=false, printf(", -> #%02x", inst_ptr.l);
  printf("\n");
}

@ Push, pop, and \.{UNSAVE} instructions display changes to rL and rO
explicitly; otherwise the change is implicit, if |L!=old_L|.

@<Print changes to rL@>=
if (L!=old_L && !(f&push_pop_bit)) printf("rL=%d, ",L);

@ Each \MMIX\ instruction has a {\it trace format\/} string, which defines
its symbolic representation. For example, the string for \.{ADD} is
|"%l = %y + %z = %x"|; if the instruction is, say, \.{ADD}~\.{\$1,\$2,\$3}
with $\$2=5$ and $\$3=8$, and if the stack offset is 100, the trace output
will be |"$1=l[101] = 5 + 8 = 13"|.

Percent signs (\.\%) induce special format conventions, as follows:

\bull \.{\%a}, \.{\%b}, \.{\%p}, \.{\%q}, \.{\%w}, \.{\%x}, \.{\%y}, and
\.{\%z} stand for the numeric contents of octabytes |a|, |b|, |ma|, |mb|, |w|,
|x|, |y|, and~|z|, respectively; a ``style'' character may follow the
percent sign in this case, as explained below.

\bull \.{\%(} and \.{\%)} are brackets that indicate the mode of
floating point rounding. If |round_mode=ROUND_NEAR|, |ROUND_OFF|,
|ROUND_UP|, |ROUND_DOWN|, the corresponding brackets are
\.(~and~\.), \.[~and~\.], \.\^~and~\.\^, \.\_~and~\.\_.
Such brackets are placed around a floating point operator;
for example, floating point addition is denoted
by `\.{[+]}' when the current rounding mode is rounding-off.

\bull \.{\%l} stands for the string |lhs|, which usually represents the
``left hand side'' of the
instruction just performed, formatted as a register number and
its equivalent in the ring of local registers (e.g., `\.{\$1=l[101]}') or
as a register number and its equivalent in the array of global registers
(e.g., `\.{\$255=g[255]}'). The \.{POP} instruction
uses |lhs| to indicate how the ``hole'' in the register stack was plugged.

\bull \.{\%r} means to switch to string |rhs| and continue formatting
from there. This mechanism allows us to use variable formats for opcodes like
\.{TRAP} that have several variants.

\bull \.{\%t} means to print either `\.{Yes, ->loc}' (where \.{loc} is
the location of the next instruction) or `\.{No}', depending on the
value of~|x|.

\bull \.{\%g} means to print `\.{ (bad guess)}' if |good| is |false|.

\bull \.{\%s} stands for the name of special register |g[zz]|.

\bull \.{\%?} stands for omission of
the following operator if |z=0|. For example, the
memory address of \.{LDBI} is described by `\.{\%\#y\%?+}'; this
means to treat the address as simply `\.{\%\#y}' if |z=0|,
otherwise as `\.{\%\#y+\%z}'. This case is used only when
|z| is a relatively small number (|z.h=0|).

@<Interpret character |*p| in the trace format@>=
{
  if (*p!='%') fputc(*p,stdout);
  else {
    style=decimal;
  char_switch:  switch (*++p) {
 @t\4@>@<Cases for formatting characters@>;
   default: printf("BUG!!"); /* can't happen */
    }
  }
}

@ Octabytes are printed as decimal numbers unless a
``style'' character intervenes between the percent sign and the
name of the octabyte: `\.\#' denotes hexadecimal notation, prefixed by~\.\#;
`\.0' denotes hexadecimal notation with no prefixed~\.\# and with leading zeros not suppressed;
`\..' denotes floating decimal notation; and
`\.!' means to use the names \.{StdIn}, \.{StdOut}, or \.{StdErr}
if the value is 0, 1, or~2.
@.StdIn@>
@.StdOut@>
@.StdErr@>

@<Cases for format...@>=
case '#': style=hex;@+ goto char_switch;
case '0': style=zhex;@+ goto char_switch;
case '.': style=floating;@+ goto char_switch;
case '!': style=handle;@+ goto char_switch;

@ @<Type...@>=
typedef enum {@!decimal,@!hex,@!zhex,@!floating,@!handle} fmt_style;

@ @<Cases for format...@>=
case 'a': trace_print(a);@+break;
case 'b': trace_print(b);@+break;
case 'p': trace_print(ma);@+break;
case 'q': trace_print(mb);@+break;
case 'w': trace_print(w);@+break;
case 'x': trace_print(x);@+break;
case 'y': trace_print(y);@+break;
case 'z': trace_print(z);@+break;

@ @<Sub...@>=
fmt_style style;
char *stream_name[]={"StdIn","StdOut","StdErr"};
@.StdIn@>
@.StdOut@>
@.StdErr@>
@#
void trace_print @,@,@[ARGS((octa))@];@+@t}\6{@>
void trace_print(o)
  octa o;
{
  switch (style) {
 case decimal: print_int(o);@+return;
 case hex: fputc('#',stdout);@+print_hex(o);@+return;
 case zhex: printf("%08x%08x",o.h,o.l);@+return;
 case floating: print_float(o);@+return;
 case handle:@+if (o.h==0 && o.l<3) printf(stream_name[o.l]);
    else print_int(o);@+return;
  }
}

@ @<Cases for format...@>=
case '(': fputc(left_paren[round_mode],stdout);@+break;
case ')': fputc(right_paren[round_mode],stdout);@+break;
case 't':@+if (x.l) printf(" Yes, -> #"),print_hex(inst_ptr);
   else printf(" No");@+break;
case 'g':@+if (!good) printf(" (bad guess)");@+break;
case 's': printf(special_name[zz]);@+break;
case '?': p++;@+if (z.l) printf("%c%d",*p,z.l);@+break;
case 'l': printf(lhs);@+break;
case 'r': p=switchable_string;@+break;

@ @d rhs &switchable_string[1]

@<Glob...@>=
char left_paren[]={0,'[','^','_','('}; /* denotes the rounding mode */
char right_paren[]={0,']','^','_',')'}; /* denotes the rounding mode */
char switchable_string[48]; /* holds |rhs|; position 0 is ignored */
 /* |switchable_string| must be able to hold any |trap_format| */
char lhs[32];
int good_guesses, bad_guesses; /* branch prediction statistics */

@ @<Sub...@>=
void show_stats @,@,@[ARGS((bool))@];@+@t}\6{@>
void show_stats(verbose)
  bool verbose;
{
  octa o;
  printf("  %d instruction%s, %d mem%s, %d oop%s; %d good guess%s, %d bad\n",
  g[rU].l,g[rU].l==1? "": "s",@|
  g[rC].h,g[rC].h==1? "": "s",@|
  g[rC].l,g[rC].l==1? "": "s",@|
  good_guesses,good_guesses==1? "": "es",bad_guesses);
  if (!verbose) return;
  o = halted? incr(inst_ptr,-4): inst_ptr;
  printf("  (%s at location #%08x%08x)\n",
     halted? "halted": "now", o.h, o.l);
}

@* Running the program. Now we are ready to fit the pieces together into a
working simulator.

@c
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <signal.h>
#include "abstime.h"
@<Preprocessor macros@>@;
@<Type declarations@>@;
@<Global variables@>@;
@<Subroutines@>@;
@#
int main(argc,argv)
  int argc;
  char *argv[];
{
  @<Local registers@>;
  mmix_io_init();
  @<Process the command line@>;
  @<Initialize everything@>;
  @<Load the command line arguments@>;
  @<Get ready to \.{UNSAVE} the initial context@>;
  while (1) {
    if (interrupt && !breakpoint) breakpoint=interacting=true, interrupt=false;
    else {
      breakpoint=false;
      if (interacting) @<Interact with the user@>;
    }
    if (halted) break;
    do @<Perform one instruction@>@;
    while ((!interrupt && !breakpoint) || resuming);
    if (interact_after_break) interacting=true, interact_after_break=false;
  }
 end_simulation:@+if (profiling) @<Print all the frequency counts@>;
  if (interacting || profiling || showing_stats) show_stats(true);
  return g[255].l; /* provide rudimentary feedback for non-interactive runs */
}

@ Here we process the command-line options; when we finish, |*cur_arg|
should be the name of the object file to be loaded and simulated.

@d mmo_file_name *cur_arg

@<Process the command line@>=
myself=argv[0];
for (cur_arg=argv+1;*cur_arg && (*cur_arg)[0]=='-'; cur_arg++)
  scan_option(*cur_arg+1,true);
if (!*cur_arg) scan_option("?",true); /* exit with usage note */
argc -= cur_arg-argv; /* this is the |argc| of the user program */

@ Careful readers of the following subroutine will notice a little white bug:
A tracing specification like
\.{t1000000000} or even \.{t0000000000} or even \.{t!!!!!!!!!!}
is silently converted to \.{t4294967295}.

The \.{-b} and \.{-c} options are effective only on the command line, but they
are harmless while interacting.

@<Subr...@>=
void scan_option @,@,@[ARGS((char*,bool))@];@+@t}\6{@>
void scan_option(arg,usage)
  char *arg; /* command-line argument (without the `\.-') */
  bool usage; /* should we exit with usage note if unrecognized? */
{
  register int k;
  switch (*arg) {
 case 't':@+if (strlen(arg)>10) trace_threshold=0xffffffff;
  else if (sscanf(arg+1,"%d",&trace_threshold)!=1) trace_threshold=0;
  return;
 case 'e':@+if (!*(arg+1)) tracing_exceptions=0xff;
  else if (sscanf(arg+1,"%x",&tracing_exceptions)!=1) tracing_exceptions=0;
  return;
 case 'r': stack_tracing=true;@+return;
 case 's': showing_stats=true;@+return;
 case 'l':@+if (!*(arg+1)) gap=3;
  else if (sscanf(arg+1,"%d",&gap)!=1) gap=0;
  showing_source=true;@+return;
 case 'L':@+if (!*(arg+1)) profile_gap=3;
  else if (sscanf(arg+1,"%d",&profile_gap)!=1) profile_gap=0;
  profile_showing_source=true;
 case 'P': profiling=true;@+return;
 case 'v': trace_threshold=0xffffffff;@+ tracing_exceptions=0xff;
  stack_tracing=true; @+ showing_stats=true;
  gap=10, showing_source=true;
  profile_gap=10, profile_showing_source=true, profiling=true;
  return;
 case 'q': trace_threshold=tracing_exceptions=0;
  stack_tracing=showing_stats=showing_source=false;
  profiling=profile_showing_source=false;
  return;
 case 'i': interacting=true;@+return;
 case 'I': interact_after_break=true;@+return;
 case 'b':@+if (sscanf(arg+1,"%d",&buf_size)!=1) buf_size=0;@+return;
 case 'c':@+if (sscanf(arg+1,"%d",&lring_size)!=1) lring_size=0;@+return;
 case 'f': @<Open a file for simulated standard input@>;@+return;
 case 'D': @<Open a file for dumping binary output@>;@+return;
 default:@+if (usage) {
    fprintf(stderr,
        "Usage: %s <options> progfile command-line-args...\n",myself);
@.Usage: ...@>
    for (k=0;usage_help[k][0];k++) fprintf(stderr,usage_help[k]);
    exit(-1);
  }@+else@+ for (k=0;usage_help[k][1]!='b';k++) printf(usage_help[k]);
  return;
  }
}

@ @<Glob...@>=
char *myself; /* |argv[0]|, the name of this simulator */
char **cur_arg; /* pointer to current place in the argument vector */
bool interrupt; /* has the user interrupted the simulation recently? */
bool profiling; /* should we print the profile at the end? */
FILE *fake_stdin; /* file substituted for the simulated \.{StdIn} */
FILE *dump_file; /* file used for binary dumps */
char *usage_help[]={@/
" with these options: (<n>=decimal number, <x>=hex number)\n",@|
"-t<n> trace each instruction the first n times\n",@|
"-e<x> trace each instruction with an exception matching x\n",@|
"-r    trace hidden details of the register stack\n",@|
"-l<n> list source lines when tracing, filling gaps <= n\n",@|
"-s    show statistics after each traced instruction\n",@|
"-P    print a profile when simulation ends\n",@|
"-L<n> list source lines with the profile\n",@|
"-v    be verbose: show almost everything\n",@|
"-q    be quiet: show only the simulated standard output\n",@|
"-i    run interactively (prompt for online commands)\n",@|
"-I    interact, but only after the program halts\n",@|
"-b<n> change the buffer size for source lines\n",@|
"-c<n> change the cyclic local register ring size\n",@|
"-f<filename> use given file to simulate standard input\n",@|
"-D<filename> dump a file for use by other simulators\n",@|
""};
char *interactive_help[]={@/
"The interactive commands are:\n",@|
"<return>  trace one instruction\n",@|
"n         trace one instruction\n",@|
"c         continue until halt or breakpoint\n",@|
"q         quit the simulation\n",@|
"s         show current statistics\n",@|
"l<n><t>   set and/or show local register in format t\n",@|
"g<n><t>   set and/or show global register in format t\n",@|
"rA<t>     set and/or show register rA in format t\n",@|
"$<n><t>   set and/or show dynamic register in format t\n",@|
"M<x><t>   set and/or show memory octabyte in format t\n",@|
"+<n><t>   set and/or show n additional octabytes in format t\n",@|
" <t> is ! (decimal) or . (floating) or # (hex) or \" (string)\n",@|
"     or <empty> (previous <t>) or =<value> (change value)\n",@|
"@@<x>      go to location x\n",@|
"b[rwx]<x> set or reset breakpoint at location x\n",@|
"t<x>      trace location x\n",@|
"u<x>      untrace location x\n",@|
"T         set current segment to Text_Segment\n",@|
"D         set current segment to Data_Segment\n",@|
"P         set current segment to Pool_Segment\n",@|
"S         set current segment to Stack_Segment\n",@|
"B         show all current breakpoints and tracepoints\n",@|
"i<file>   insert commands from file\n",@|
"-<option> change a tracing/listing/profile option\n",@|
"-?        show the tracing/listing/profile options  \n",@|
""};

@ @<Open a file for simulated standard input@>=
if (fake_stdin) fclose(fake_stdin);
fake_stdin=fopen(arg+1,"r");
if (!fake_stdin) fprintf(stderr,"Sorry, I can't open file %s!\n",arg+1);
@.Sorry, I can't open...@>
else mmix_fake_stdin(fake_stdin);

@ @<Open a file for dumping binary output@>=
dump_file=fopen(arg+1,"wb");
if (!dump_file) fprintf(stderr,"Sorry, I can't open file %s!\n",arg+1);
@.Sorry, I can't open...@>

@ @<Initialize...@>=
signal(SIGINT,catchint); /* now |catchint| will catch the first interrupt */

@ @<Subr...@>=
void catchint @,@,@[ARGS((int))@];@+@t}\6{@>
void catchint(n)
  int n;
{
  interrupt=true;
  signal(SIGINT,catchint); /* now |catchint| will catch the next interrupt */
}

@ @<Interact with the user@>=
{@+register int repeating;
 interact: @<Put a new command in |command_buf|@>;
  p=command_buf;
  repeating=0;
  switch (*p) {
  case '\n': case 'n': breakpoint=tracing=true; /* trace one inst and break */
  case 'c': goto resume_simulation; /* continue until breakpoint */
  case 'q': goto end_simulation;
  case 's': show_stats(true);@+goto interact;
  case '-': k=strlen(p);@+if (p[k-1]=='\n') p[k-1]='\0';
    scan_option(p+1,false);@+goto interact;
  @t\4@>@<Cases that change |cur_disp_mode|@>;
  @t\4@>@<Cases that define |cur_disp_type|@>;
  @t\4@>@<Cases that set and clear tracing and breakpoints@>;
  default: what_say: k=strlen(command_buf);
    if (k<10 && command_buf[k-1]=='\n') command_buf[k-1]='\0';
    else strcpy(command_buf+9,"...");
    printf("Eh? Sorry, I don't understand `%s'. (Type h for help)\n",
         command_buf);
    goto interact;
  case 'h':@+ for (k=0;interactive_help[k][0];k++) printf(interactive_help[k]);
    goto interact;
  }
 check_syntax:@+ if (*p!='\n') {
   if (!*p) incomplete_str: printf("Syntax error: Incomplete command!\n");
   else {
     p[strlen(p)-1]='\0';
     printf("Syntax error; I'm ignoring `%s'!\n",p);
   }
 }
 while (repeating) @<Display and/or set the value of the current octabyte@>;
 goto interact;
resume_simulation:;
}

@ @<Put a new command...@>=
{@+register bool ready=false;
 incl_read:@+ while (incl_file && !ready)
    if (!fgets(command_buf,command_buf_size,incl_file)) {
      fclose(incl_file);
      incl_file=NULL;
    }@+else if (command_buf[0]!='\n' && command_buf[0]!='i' &&
              command_buf[0]!='%')
      if (command_buf[0]==' ') printf(command_buf);
      else ready=true;
  while (!ready) {
    printf("mmix> ");@+fflush(stdout);
@.mmix>@>
    if (!fgets(command_buf,command_buf_size,stdin)) command_buf[0]='q';
    if (command_buf[0]!='i') ready=true;
    else {
      command_buf[strlen(command_buf)-1]='\0';
      incl_file=fopen(command_buf+1,"r");
      if (incl_file) goto incl_read;
      if (isspace(command_buf[1])) incl_file=fopen(command_buf+2,"r");
      if (incl_file) goto incl_read;
      printf("Can't open file `%s'!\n",command_buf+1);
    }
  }
}

@ @d command_buf_size 1024 /* make it plenty long, for floating point tests */

@<Glob...@>=
char command_buf[command_buf_size];
FILE *incl_file; /* file of commands included by `\.i' */
char cur_disp_mode='l'; /* |'l'| or |'g'| or |'$'| or |'M'| */
char cur_disp_type='!'; /* |'!'| or |'.'| or |'#'| or |'"'| */
bool cur_disp_set; /* was the last \.{<t>} of the form \.{=<val>}? */
octa cur_disp_addr; /* the |h| half is relevant only in mode |'M'| */
octa cur_seg; /* current segment offset */
char spec_reg_code[]={rA,rB,rC,rD,rE,rF,rG,rH,rI,rJ,rK,rL,rM,
      rN,rO,rP,rQ,rR,rS,rT,rU,rV,rW,rX,rY,rZ};
char spec_regg_code[]={0,rBB,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,rTT,0,0,rWW,rXX,rYY,rZZ};

@ @<Cases that change |cur_disp_mode|@>=
case 'l': case 'g': case '$': cur_disp_mode=*p++;
 for (cur_disp_addr.l=0; isdigit(*p); p++)
   cur_disp_addr.l=10*cur_disp_addr.l + *p - '0';
 goto new_mode;
case 'r': p++;@+ cur_disp_mode='g';
 if (*p<'A' || *p>'Z') goto what_say;
 if (*(p+1)!=*p) cur_disp_addr.l=spec_reg_code[*p-'A'],p++;
 else if (spec_regg_code[*p-'A']) cur_disp_addr.l=spec_regg_code[*p-'A'],p+=2;
 else goto what_say;
 goto new_mode;
case 'M': cur_disp_mode=*p;
 cur_disp_addr=scan_hex(p+1,cur_seg);@+ cur_disp_addr.l&=-8;@+ p=next_char;
new_mode: cur_disp_set=false; /* the `\.=' is remembered only by `\.+' */
 repeating=1;
 goto scan_type;
case '+':@+ if (!isdigit(*(p+1))) repeating=1;
 for (p++; isdigit(*p); p++)
   repeating=10*repeating + *p - '0';
 if (repeating) {
   if (cur_disp_mode=='M') cur_disp_addr=incr(cur_disp_addr,8);
   else cur_disp_addr.l++;
 }
 goto scan_type;

@ @<Cases that define |cur_disp_type|@>=
case '!': case '.': case '#': case '"': cur_disp_set=false;
 repeating=1;
set_type: cur_disp_type=*p++;@+break;
scan_type:@+ if (*p=='!' || *p=='.' || *p=='#' || *p=='"') goto set_type;
 if (*p!='=') break;
 goto scan_eql;
case '=': repeating=1;
scan_eql: cur_disp_set=true;
 val=zero_octa;
 if (*++p=='#') cur_disp_type=*p, val=scan_hex(p+1,zero_octa);
 else if (*p=='"' || *p=='\'') goto scan_string;
 else cur_disp_type=(scan_const(p)>0? '.': '!');
 p=next_char;
 if (*p!=',') break;
 val.h=0;@+ val.l&=0xff;
scan_string: cur_disp_type='"';
 @<Scan a string constant@>;@+break;

@ @<Subr...@>=
octa scan_hex @,@,@[ARGS((char*,octa))@];@+@t}\6{@>
octa scan_hex(s,offset)
  char *s;
  octa offset;
{
  register char *p;
  octa o;
  o=zero_octa;
  for (p=s;isxdigit(*p);p++) {
    o=incr(shift_left(o,4),*p-'0');
    if (*p>='a') o=incr(o,'0'-'a'+10);
    else if (*p>='A') o=incr(o,'0'-'A'+10);
  }
  next_char=p;
  return oplus(o,offset);
}

@ @<Scan a string constant@>=
while (*p==',') {
  if (*++p=='#') {
    aux=scan_hex(p+1,zero_octa), p=next_char;
    val=incr(shift_left(val,8),aux.l&0xff);
  }@+else if (isdigit(*p)) {
    for (k=*p++ - '0';isdigit(*p);p++) k=(10*k + *p - '0')&0xff;
    val=incr(shift_left(val,8),k);
  }
  else if (*p=='\n') goto incomplete_str;
}
if (*p=='\'' && *(p+2)==*p) *p=*(p+2)='"';
if (*p=='"') {
  for (p++;*p && *p!='\n' && *p!='"'; p++)
    val=incr(shift_left(val,8),*p);
  if (*p && *p++=='"')
    if (*p==',') goto scan_string;
}

@ @<Display and/or set the value of the current octabyte@>=
{
  if (cur_disp_set) @<Set the current octabyte to |val|@>;
  @<Display the current octabyte@>;
  fputc('\n',stdout);
  repeating--;
  if (!repeating) break;
  if (cur_disp_mode=='M') cur_disp_addr=incr(cur_disp_addr,8);
  else cur_disp_addr.l++;
}

@ @<Set the current octabyte to |val|@>=
switch (cur_disp_mode) {
 case 'l': l[cur_disp_addr.l&lring_mask]=val;@+break;
 case '$': k=cur_disp_addr.l&0xff;
  if (k<L) l[(O+k)&lring_mask]=val;@+else if (k>=G) g[k]=val;
  break;
 case 'g': k=cur_disp_addr.l&0xff;
  if (k<32) @<Set |g[k]=val| only if permissible@>;
  g[k]=val;@+break;
 case 'M':@+if (!(cur_disp_addr.h&sign_bit)) {
    ll=mem_find(cur_disp_addr);
    ll->tet=val.h;@+ (ll+1)->tet=val.l;
  }@+break;
}

@ Here we essentially simulate a |PUT| command, but we simply |break|
if the |PUT| is illegal or privileged.

@<Set |g[k]=val| only if permissible@>=
if (k>=9 && k!=rI) {
  if (k<=19) break;
  if (k==rA) {
    if (val.h!=0 || val.l>=0x40000) break;
    cur_round=(val.l>=0x10000? val.l>>16: ROUND_NEAR);
  }@+else if (k==rG) {
    if (val.h!=0 || val.l>255 || val.l<L || val.l<32) break;
    for (j=val.l; j<G; j++) g[j]=zero_octa;
    G=val.l;
  }@+else if (k==rL) {
    if (val.h==0 && val.l<L) L=val.l;
    else break;
  }
}
    
@ @<Display the current octabyte@>=
switch (cur_disp_mode) {
 case 'l': k=cur_disp_addr.l&lring_mask;
  printf("l[%d]=",k);@+ aux=l[k];@+ break;
 case '$': k=cur_disp_addr.l&0xff;
  if (k<L) printf("$%d=l[%d]=",k,(O+k)&lring_mask), aux=l[(O+k)&lring_mask];
  else if (k>=G) printf("$%d=g[%d]=",k,k), aux=g[k];
  else printf("$%d=",k), aux=zero_octa;
  break;
 case 'g': k=cur_disp_addr.l&0xff;
  printf("g[%d]=",k);@+ aux=g[k];@+ break;
 case 'M':@+if (cur_disp_addr.h&sign_bit) aux=zero_octa;
  else {
    ll=mem_find(cur_disp_addr);
    aux.h=ll->tet;@+ aux.l=(ll+1)->tet;
  }
  printf("M8[#");@+ print_hex(cur_disp_addr);@+ printf("]=");@+break;
}
switch (cur_disp_type) {
 case '!': print_int(aux);@+break;
 case '.': print_float(aux);@+break;
 case '#': fputc('#',stdout);@+print_hex(aux);@+break;
 case '"': print_string(aux);@+break;
}

@ @<Subr...@>=
void print_string @,@,@[ARGS((octa))@];@+@t}\6{@>
void print_string(o)
  octa o;
{
  register int k, state, b;
  for (k=state=0; k<8; k++) {
    b=((k<4? o.h>>(8*(3-k)): o.l>>(8*(7-k))))&0xff;
    if (b==0) {
      if (state) printf("%s,0",state>1? "\"": ""), state=1;
    }@+else if (b>=' ' && b<='~')
        printf("%s%c",state>1? "": state==1? ",\"": "\"",b), state=2;
    else printf("%s#%x",state>1? "\",": state==1? ",": "",b), state=1;
  }
  if (state==0) printf("0");
  else if (state>1) printf("\"");
}

@ @<Cases that set and clear tracing and breakpoints@>=
case '@@': inst_ptr=scan_hex(p+1,cur_seg);@+ p=next_char;
 halted=false;@+break;
case 't': case 'u': k=*p;
 val=scan_hex(p+1,cur_seg);@+ p=next_char;
 if (val.h<0x20000000) {
   ll=mem_find(val);
   if (k=='t') ll->bkpt |= trace_bit;
   else ll->bkpt &=~trace_bit;
 }
 break;
case 'b':@+ for (k=0,p++; !isxdigit(*p); p++)
   if (*p=='r') k|=read_bit;
   else if (*p=='w') k|=write_bit;
   else if (*p=='x') k|=exec_bit;
 val=scan_hex(p,cur_seg);@+ p=next_char;
 if (!(val.h&sign_bit)) {
   ll=mem_find(val);
   ll->bkpt=(ll->bkpt&-8)|k;
 }
 break;
case 'T': cur_seg.h=0;@+goto passit;
case 'D': cur_seg.h=0x20000000;@+goto passit;
case 'P': cur_seg.h=0x40000000;@+goto passit;
case 'S': cur_seg.h=0x60000000;@+goto passit;
case 'B': show_breaks(mem_root);
passit: p++;@+break;

@ @<Sub...@>=
void show_breaks @,@,@[ARGS((mem_node*))@];@+@t}\6{@>
void show_breaks(p)
  mem_node *p;
{
  register int j;
  octa cur_loc;
  if (p->left) show_breaks(p->left);
  for (j=0;j<512;j++) if (p->dat[j].bkpt) {
    cur_loc=incr(p->loc,4*j);
    printf("  %08x%08x %c%c%c%c\n",cur_loc.h,cur_loc.l,@|
             p->dat[j].bkpt&trace_bit? 't': '-',
             p->dat[j].bkpt&read_bit? 'r': '-',
             p->dat[j].bkpt&write_bit? 'w': '-',
             p->dat[j].bkpt&exec_bit? 'x': '-');
  }
  if (p->right) show_breaks(p->right);
}

@ We put pointers to the command-line strings in
M$[\.{Pool\_Segment}+8*(k+1)]_8$ for $0\le k<|argc|$;
the strings themselves are octabyte-aligned, starting at
M$[\.{Pool\_Segment}+8*(|argc|+2)]_8$. The location of the first free
octabyte in the pool segment is placed in M$[\.{Pool\_Segment}]_8$.
@:Pool_Segment}\.{Pool\_Segment@>
@^command line arguments@>

@<Load the command line arguments@>=
x.h=0x40000000, x.l=0x8;
loc=incr(x,8*(argc+1));
for (k=0; k<argc; k++,cur_arg++) {
  ll=mem_find(x);
  ll->tet=loc.h, (ll+1)->tet=loc.l;
  ll=mem_find(loc);
  mmputchars((unsigned char *)*cur_arg,strlen(*cur_arg),loc);
  x.l+=8, loc.l+=8+(strlen(*cur_arg)&-8);
}
x.l=0;@+ll=mem_find(x);@+ll->tet=loc.h, (ll+1)->tet=loc.l;

@ @<Get ready to \.{UNSAVE} the initial context@>=
x.h=0, x.l=0x90;
ll=mem_find(x);
if (ll->tet) inst_ptr=x;
@^subroutine library initialization@>
@^initialization of a user program@>
resuming=true;
rop=RESUME_AGAIN;
g[rX].l=((tetra)UNSAVE<<24)+255;
if (dump_file) {
  x.l=1;
  dump(mem_root);
  dump_tet(0),dump_tet(0);
  exit(0);
}

@ The special option `\.{-D<filename>}' can be used to prepare binary files
needed by the \MMIX-in-\MMIX\ simulator of Section 1.4.3\'{}. This option
puts big-endian octa\-bytes into a given file; a location~$l$ is followed
by one or more nonzero octabytes M$_8[l]$, M$_8[l+8]$, M$_8[l+16]$, \dots,
followed by zero. The simulated simulator knows how to load programs
in such a format (see exercise 1.4.3\'{}--20), and so does
the meta-simulator {\mc MMMIX}.

@<Sub...@>=
void dump @,@,@[ARGS((mem_node*))@];@+@t}\6{@>
void dump_tet @,@,@[ARGS((tetra))@];@+@t}\6{@>
void dump(p)
  mem_node *p;
{
  register int j;
  octa cur_loc;
  if (p->left) dump(p->left);
  for (j=0;j<512;j+=2) if (p->dat[j].tet || p->dat[j+1].tet) {
    cur_loc=incr(p->loc,4*j);
    if (cur_loc.l!=x.l || cur_loc.h!=x.h) {
      if (x.l!=1) dump_tet(0),dump_tet(0);
      dump_tet(cur_loc.h);@+dump_tet(cur_loc.l);@+x=cur_loc;
    }
    dump_tet(p->dat[j].tet);
    dump_tet(p->dat[j+1].tet);
    x=incr(x,8);
  }
  if (p->right) dump(p->right);
}

@ @<Sub...@>=
void dump_tet(t)
  tetra t;
{
  fputc(t>>24,dump_file);
  fputc((t>>16)&0xff,dump_file);
  fputc((t>>8)&0xff,dump_file);
  fputc(t&0xff,dump_file);
}

@* Index.
