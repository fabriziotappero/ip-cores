% This file is part of the MMIXware package (c) Donald E Knuth 1999
@i boilerplate.w %<< legal stuff: PLEASE READ IT BEFORE MAKING ANY CHANGES!

\def\title{MMIXAL}

\def\MMIX{\.{MMIX}}
\def\MMIXAL{\.{MMIXAL}}
\def\Hex#1{\hbox{$^{\scriptscriptstyle\#}$\tt#1}} % experimental hex constant
\def\<#1>{\hbox{$\langle\,$#1$\,\rangle$}}\let\is=\longrightarrow
\def\bull{\smallbreak\textindent{$\bullet$}}
@s and normal @q unreserve a C++ keyword @>
@s or normal @q unreserve a C++ keyword @>
@s xor normal @q unreserve a C++ keyword @>

\ifx\exotic+
 \font\heb=heb8 at 10pt
 \font\rus=lhwnr8
 \input unicode
 \unicodeptsize=8pt
\fi

@* Definition of MMIXAL. This program takes input written in \MMIXAL,
the \MMIX\ assembly language, and translates it
@^assembly language@>
into binary files that can be loaded and executed
on \MMIX\ simulators. \MMIXAL\ is much simpler than the ``industrial
strength'' assembly languages that computer manufacturers usually provide,
because it is primarily intended for the simple demonstration programs
in {\sl The Art of Computer Programming}. Yet it tries to have enough
features to serve also as the back end of compilers for \CEE/ and other
high-level languages.

Instructions for using the program appear at the end of this document.
First we will discuss the input and output languages in detail; then we'll
consider the translation process, step by step; then we'll put everything
together.

@ A program in \MMIXAL\ consists of a series of {\it lines}, each of which
usually contains a single instruction. However, lines with no instructions are
possible, and so are lines with two or more instructions.

Each instruction has
three parts called its label field, opcode field, and operand field; these
fields are separated from each other by one or more spaces.
The label field, which is often empty, consists of all characters up to the
first blank space. The opcode field, which is never empty, runs from the first
nonblank after the label to the next blank space. The operand field, which
again might be empty, runs from the next nonblank character (if any) to the
first blank or semicolon that isn't part of a string or character constant.
If the operand field is followed by a semicolon, possibly with intervening
blanks, a new instruction begins immediately after the semicolon; otherwise
the rest of the line is ignored. The end of a line is treated as a blank space
for the purposes of these rules, with the additional proviso that
string or character constants are not allowed to extend from one line to
another.

The label field must begin with a letter or a digit; otherwise the entire
line is treated as a comment. Popular ways to introduce comments,
either at the beginning of a line or after the operand field, are to
precede them by the character \.\% as in \TeX, or by \.{//} as in \CPLUSPLUS/;
\MMIXAL\ is not very particular. However, Lisp-style comments introduced
by single semicolons will fail if they follow an instruction, because
they will be assumed to introduce another instruction.

@ \MMIXAL\ has no built-in macro capability, nor does it know how to
include header files and such things. But users can run their files
through a standard \CEE/ preprocessor to obtain \MMIXAL\ programs in which
macros and such things have been expanded. (Caution: The preprocessor also
removes \CEE/-style comments, unless it is told not to do so.)
Literate programming tools could also be used for preprocessing.
@^C preprocessor@>
@^literate programming@>

If a line begins with the special form `\.\# \<integer> \<string>',
this program interprets it as a {\it line directive\/} emitted by a
preprocessor. For example,
$$\leftline{\indent\.{\# 13 "foo.mms"}}$$
means that the following line was line 13 in the user's source file
\.{foo.mms}. Line directives allow us to correlate errors with the
user's original file; we also pass them to the output, for use by
simulators and debuggers.
@^line directives@>

@ \MMIXAL\ deals primarily with {\it symbols\/} and {\it constants}, which it
interprets and combines to form machine language instructions and data.
Constants are simplest, so we will discuss them first.

A {\it decimal constant\/} is a sequence of digits, representing a number in
radix~10. A~{\it hexadecimal constant\/} is a sequence of hexadecimal digits,
preceded by~\.\#, representing a number in radix~16:
$$\vbox{\halign{$#$\hfil\cr
\<digit>\is\.0\mid\.1\mid\.2\mid\.3\mid\.4\mid
        \.5\mid\.6\mid\.7\mid\.8\mid\.9\cr
\<hex digit>\is\<digit>\mid\.A\mid\.B\mid\.C\mid\.D\mid\.E\mid\.F\mid
        \.a\mid\.b\mid\.c\mid\.d\mid\.e\mid\.f\cr
\<decimal constant>\is\<digit>\mid\<decimal constant>\<digit>\cr
\<hex constant>\is\.\#\<hex digit>\mid\<hex constant>\<hex digit>\cr
}}$$
Constants whose value is $2^{64}$ or more are reduced modulo $2^{64}$.

@ A {\it character constant\/} is a single character enclosed in
single quote marks; it denotes the {\mc ASCII} or Unicode number
@^Unicode@>
corresponding to that character. For example, \.{'a'}
represents the constant \.{\#61}, also known as~\.{97}. The quoted character
can be 
anything except the character that the \CEE/ library calls \.{\\n} or {\it
newline}; that character should be represented as \.{\#a}.
$$\vbox{\halign{$#$\hfil\cr
\<character constant>\is\.'\<single byte character except newline>\.'\cr
\<constant>\is\<decimal constant>\mid\<hex constant>\mid\<character constant>
\cr}}$$
Notice that \.{'''} represents a single quote, the code \.{\#27}; and
\.{'\\'} represents a backslash, the code \.{\#5c}. \MMIXAL~characters are
never ``quoted'' by backslashes as in the \CEE/~language.

In the present implementation
a character constant will always be at most 255, since wyde character
input is not supported.
\ifx\exotic+ But if the input were in Unicode one could write,
say, \.'{\heb\char"40}\.' or \.'{\rus ZH}\.' for \.{\#05d0} or
\.{\#0416}. \fi
The present program
does not support Unicode directly because basic software for inputting and
outputting 16-bit characters was still in a primitive state at the time of
writing. But the data structures below are designed so that a change to
Unicode will not be difficult when the time is ripe.

@ A {\it string constant\/} like \.{"Hello"} is an abbreviation for
a sequence of one or more character constants separated by commas:
\.{'H','e','l','l','o'}.
Any character except newline or the double quote mark~\."
can appear between the double quotes of a string constant.
\ifx\exotic+ Similarly,
\."\Uni1.08:24:24:-1:20% Unicode char "9ad8
<002000001800000806ffffff00000002004003ffe00300e00300c00300c003ffc0%
0300c02000043ffffe30000e31008c31ffcc3181cc31818c31818c31ff8c31818c3%
0007c300018>%
\thinspace\Uni1.08:24:24:-1:20% Unicode char "5fb7
<1c038018030018030631ffff30060067860446fffe86ccce0ccccc0ccccc18cccc%
18fffc38c00c38001878fffc58040098030818398618b18318b00b19b0081b300c1%
b3ffc181ff8>%
\thinspace\Uni1.08:24:24:-1:20% Unicode char "7eb3
<0601c00e01800c018018018018218231bfff61b187433186ff3186c631860c3186%
18334630332663b6367e341660380600300600300603b0061e3006f03006c030060%
0303e00300c>%
\kern.1em\." is an abbreviation for
\.'\Uni1.08:24:24:-1:20% Unicode char "9ad8
<002000001800000806ffffff00000002004003ffe00300e00300c00300c003ffc0%
0300c02000043ffffe30000e31008c31ffcc3181cc31818c31818c31ff8c31818c3%
0007c300018>%
\.{','}\Uni1.08:24:24:-1:20% Unicode char "5fb7
<1c038018030018030631ffff30060067860446fffe86ccce0ccccc0ccccc18cccc%
18fffc38c00c38001878fffc58040098030818398618b18318b00b19b0081b300c1%
b3ffc181ff8>%
\.{','}\Uni1.08:24:24:-1:20% Unicode char "7eb3
<0601c00e01800c018018018018218231bfff61b187433186ff3186c631860c3186%
18334630332663b6367e341660380600300600300603b0061e3006f03006c030060%
0303e00300c>%
\.' (namely \.{\#9ad8,\#5fb7,\#7eb3}) when Unicode is supported.
@^Unicode@>
\fi

@ A {\it symbol\/} in \MMIXAL\ is any sequence of letters and digits,
beginning with a letter. A~colon~`\.:' or underscore symbol `\.\_'
is regarded as a letter, for purposes of this definition.
All extended-ASCII characters like `{\tt \'e}',
whose 8-bit code exceeds 126, are also treated as letters.
$$\vbox{\halign{$#$\hfil\cr
\<letter>\is\.A\mid\.B\mid\cdots\mid\.Z\mid\.a\mid\.b\mid\cdots\mid\.z\mid
        \.:\mid\.\_\mid\<{character with code value $>126$}>\cr
\<symbol>\is\<letter>\mid\<symbol>\<letter>\mid\<symbol>\<digit>\cr
}}$$

In future implementations, when \MMIXAL\ is used with Unicode,
@^Unicode@>
all wyde characters whose 16-bit code exceeds 126 will be regarded
as letters; thus \MMIXAL\ symbols will be able to involve Greek letters or
Chinese characters or thousands of other glyphs.
@ A symbol is said to
be {\it fully qualified\/} if it begins with a colon. Every symbol
that is not fully qualified is an abbreviation for the fully qualified
symbol obtained by placing the {\it current prefix\/} in front of it;
the current prefix is always fully qualified. At the beginning of an
\MMIXAL\ program the current prefix is simply the single character~`\.:',
but the user can change it with the \.{PREFIX} command. For example,
$$\vbox{\halign{&\quad\tt#\hfil\cr
ADD&x,y,z&\% means ADD :x,:y,:z\cr
PREFIX&Foo:&\% current prefix is :Foo:\cr
ADD&x,y,z&\% means ADD :Foo:x,:Foo:y,:Foo:z\cr
PREFIX&Bar:&\% current prefix is :Foo:Bar:\cr
ADD&:x,y,:z&\% means ADD :x,:Foo:Bar:y,:z\cr
PREFIX&:&\% current prefix reverts to :\cr
ADD&x,Foo:Bar:y,Foo:z&\% means ADD :x,:Foo:Bar:y,:Foo:z\cr
}}$$
This mechanism allows large programs to avoid conflicts between symbol names,
when parts of the program are independent and/or written by different users.
The current prefix conventionally ends with a colon, but this convention
need not be obeyed.

@ A {\it local symbol\/} is a decimal digit followed by one of the
letters \.B, \.F, or~\.H, meaning ``backward,'' ``forward,'' or ``here'':
$$\vbox{\halign{$#$\hfill\cr
\<local operand>\is\<digit>\,\.B\mid\<digit>\,\.F\cr
\<local label>\is\<digit>\,\.H\cr
}}$$
The \.B and \.F forms are permitted only in the operand field of \MMIXAL\
instructions; the \.H form is permitted only in the label field. A local
operand such as~\.{2B} stands for the last local label~\.{2H}
in instructions before the current one, or 0 if \.{2H} has not yet appeared
as a label. A~local operand such as~\.{2F} stands
for the first \.{2H} in instructions after the current one. Thus, in a
sequence such as
$$\vbox{\halign{\tt#\cr 2H JMP 2F\cr 2H JMP 2B\cr}}$$
the first instruction jumps to the second and the second jumps to the first.

Local symbols are useful for references to nearby points of a program, in
cases where no meaningful name is appropriate. They can also be useful
in special situations where a redefinable symbol is needed; for example,
an instruction like
$$\.{9H IS 9B+1}$$
will maintain a running counter.

@ Each symbol receives a value called its {\it equivalent\/} when it
appears in the label field of an instruction; it is said to be {\it defined\/}
after its equivalent has been established. A few symbols, like \.{rA}
and \.{ROUND\_OFF} and \.{Fopen},
are predefined because they refer to fixed constants
associated with the \MMIX\ hardware or its rudimentary operating system;
otherwise every symbol should be
defined exactly once. The two appearances of `\.{2H}' in the example
above do not violate this rule, because the second `\.{2H}' is not the
same symbol as the first.

A predefined symbol can be redefined (given a new equivalent). After it
has been redefined it acts like an ordinary symbol and cannot be
redefined again. A complete list of the predefined symbols appears
in the program listing below.
@^predefined symbols@>

Equivalents are either {\it pure\/} or {\it register numbers}. A pure
equivalent is an unsigned octabyte, but a register number
equivalent is a one-byte value, between 0 and~255.
A dollar sign is used to change a pure number into a register number;
for example, `\.{\$20}' means register number~20.

@ Constants and symbols are combined into {\it expressions\/} in a simple way:
$$\vbox{\halign{$#$\hfil\cr
\<primary expression>\is\<constant>\mid\<symbol>\mid\<local operand>\mid
  \.{@@}\mid\cr
\hskip12pc\.(\<expression>\.)\mid\<unary operator>\<primary expression>\cr
\<term>\is\<primary expression>\mid
  \<term>\<strong operator>\<primary expression>\cr
\<expression>\is\<term>\mid\<expression>\<weak operator>\<term>\cr
\<unary operator>\is\.+\mid\.-\mid\.\~\mid\.\$\mid\.\&\cr
\<strong operator>\is\.*\mid\./\mid\.{//}\mid\.\%\mid\.{<<}\mid\.{>>}
       \mid\.\&\cr
\<weak operator>\is\.+\mid\.-\mid\.{\char'174}\mid\.\^\cr
}}$$
Each expression has a value that is either pure or a register number.
The character \.{@@} stands for the current location, which is always pure.
The unary operators
\.+, \.-, \.\~, \.\$, and \.\& mean, respectively, ``do nothing,''
``subtract from zero,'' ``complement the bits,'' ``change from pure value
to register number,'' and ``take the serial number.'' Only the first of these,
\.+, can be applied to a register number. The last unary operator, \.\&,
applies only to symbols, and it is of interest primarily to system programmers;
it converts a symbol to the unique positive integer that is used to identify
it in the binary file output by \MMIXAL.
@^serial number@>

Binary operators come in two flavors, strong and weak. The strong ones
are essentially concerned with multiplication or division: \.{x*y},
\.{x/y}, \.{x//y}, \.{x\%y}, \.{x<<y}, \.{x>>y}, and \.{x\&y}
stand respectively for
$(x\times y)\bmod2^{64}$ (multiplication), $\lfloor x/y\rfloor$ (division),
$\lfloor2^{64}x/y\rfloor$ (fractional division), $x\bmod y$ (remainder),
$(x\times2^y)\bmod2^{64}$ (left~shift), $\lfloor x/2^y\rfloor$
(right shift), and $x\land y$ (bitwise and) on unsigned octabytes.
Division is legal only if $y>0$; fractional division is
legal only if $x<y$. None of the strong binary operations can be
applied to register numbers.

The weak binary operations \.{x+y}, \.{x-y}, \.{x\char'174 y}, and
\.{x\^y} stand respectively for $(x+y)\bmod2^{64}$ (addition),
$(x-y)\bmod2^{64}$ (subtraction),
$x\lor y$ (bitwise or), and $x\oplus y$ (bitwise exclusive-or) on
unsigned octabytes. These operations can be applied to register
numbers only in four contexts: $\<register>+\<pure>$, $\<pure>+\<register>$,
$\<register>-\<pure>$
and $\<register>-\<register>$. For example, if \.{x} denotes \.{\$1} and
\.{y} denotes \.{\$10}, then \.{x+3} and \.{3+x} denote \.{\$4}, and
\.{y-x} denotes the pure value \.{9}.

Register numbers within expressions are allowed to be
arbitrary octabytes, but a register number assigned as the
equivalent of a symbol should not exceed 255.

(Incidentally, one might ask why the designer of \MMIXAL\ did not simply
adopt the existing rules of \CEE/ for expressions. The primary reason is that
the designers of \CEE/ chose to give \.{<<}, \.{>>}, and \.\& a lower
precedence than~\.+; but in \MMIXAL\ we want to be able to write things
like \.{o<<24+x<<16+y<<8+z} or \.{@@+yz<<2} or \.{@@+(\#100-@@)\&\#ff}.
Since the conventions of \CEE/ were inappropriate, it was better
to make a clean break, not pretending to have a close relationship
with that language. The new rules are quite easily memorized,
because \MMIXAL\ has just two levels of precedence, and the strong binary
operations are all essentially multiplicative by nature
while the weak binary operations are essentially additive.)

@ A symbol is called a {\it future reference\/} until it has been defined.
\MMIXAL\ restricts the use of future references, so that programs can
be assembled quickly in one pass over the input; therefore all
expressions can be evaluated when the \MMIXAL\ processor first sees them.

The restrictions are easily stated: Future references
cannot be used in expressions together with unary or binary operators (except
the unary~\.+, which does nothing); moreover, future references
can appear as operands only in instructions that have relative
addresses (namely branches, probable branches, \.{JMP}, \.{PUSHJ},
\.{GETA}) or in octabyte constants (the pseudo-operation \.{OCTA}).
Thus, for example, one can say \.{JMP}~\.{1F} or \.{JMP}~\.{1B-4}, but not
\.{JMP}~\.{1F-4}.

@ We noted earlier that each \MMIXAL\ instruction contains
a label field, an opcode field, and an operand field. The label field is
either empty or a symbol or local label; when it is nonempty, the
symbol or local label receives an equivalent. The operand field is
either empty or a sequence of expressions separated by commas; when
it is empty, it is equivalent to the simple operand field~`\.0'.
$$\vbox{\halign{$#$\hfil\cr
\<instruction>\is\<label>\<opcode>\<operand list>\cr
\<label>\is\<empty>\mid\<symbol>\mid\<local label>\cr
\<operand list>\is\<empty>\mid\<expression list>\cr
\<expression list>\is\<expression>\mid\<expression list>\.,\<expression>\cr
}}$$

The opcode field either contains a symbolic \MMIX\ operation name (like
\.{ADD}), or an {\it alias operation}, or a {\it pseudo-operation}.
Alias operations are alternate names for \MMIX\ operations whose standard
names are inappropriate in certain contexts. 
Pseudo-operations do not correspond
directly to \MMIX\ commands, but they govern the assembly process in
important ways.

There are two alias operations:

\bull \.{SET} \.{\$X,\$Y} is equivalent to \.{OR} \.{\$X,\$Y,0}; it sets
register~X to register~Y. Similarly, \.{SET} \.{\$X,Y} (when \.Y is
not a register) is equivalent to \.{SETL} \.{\$X,Y}.
@.SET@>

\bull \.{LDA} \.{\$X,\$Y,\$Z} is equivalent to \.{ADDU} \.{\$X,\$Y,\$Z};
it loads the address of memory location $\rm \$Y+\$Z$ into register~X.
Similarly, \.{LDA} \.{\$X,\$Y,Z} is equivalent to \.{ADDU} \.{\$X,\$Y,Z}.
@.LDA@>

\smallskip
The symbolic operation names for genuine \MMIX\ operations
should not include the suffix~\.I for an immediate operation or the suffix~\.B
for a backward jump; \MMIXAL\ determines such things automatically.
Thus, one never writes \.{ADDI} or \.{JMPB} in the source input to
\MMIXAL, although such opcodes might appear when a simulator or
debugger or disassembler is presenting a numeric instruction in symbolic form.
$$\vbox{\halign{$#$\hfil\cr
\<opcode>\is\<symbolic \MMIX\ operation>\mid\<alias operation>\cr
\hskip12pc\mid\<pseudo-operation>\cr
\<symbolic \MMIX\ operation>\is\.{TRAP}\mid\.{FCMP}\mid\cdots\mid\.{TRIP}\cr
\<alias operation>\is\.{SET}\mid\.{LDA}\cr
\<pseudo-operation>\is\.{IS}\mid\.{LOC}\mid\.{PREFIX}\mid
   \.{GREG}\mid\.{LOCAL}\mid\.{BSPEC}\mid\.{ESPEC}\cr
\hskip12pc\mid\.{BYTE}\mid\.{WYDE}\mid\.{TETRA}\mid\.{OCTA}\cr
}}$$

@ \MMIX\ operations like \.{ADD} require exactly three expressions as
operands. The first two must be register numbers. The third must be either a
register number or a pure number between 0 and~255; in the latter case,
\.{ADD} becomes \.{ADDI} in the assembled output. Thus, for example,
the command ``set register~1 to the sum of register~2 and register~3'' could be
expressed as
$$\.{ADD \$1,\$2,\$3}$$
or as, say,
$$\.{ADD x,y,y+1}$$
if the equivalent of \.x is \.{\$1} and the equivalent of \.y is \.{\$2}.
The command ``subtract 5 from register~1'' could be expressed as
$$\.{SUB \$1,\$1,5}$$
or as
$$\.{SUB x,x,5}$$
but not as `\.{SUBI} \.{\$1,\$1,5}' or `\.{SUBI} \.{x,x,5}'.

\MMIX\ operations like \.{FLOT} require either three operands
(register, pure, register/pure) or only two (register, register/pure).
In the first case the middle operand is the rounding mode, which is
best expressed in terms of the predefined symbolic values
\.{ROUND\_CURRENT}, \.{ROUND\_OFF}, \.{ROUND\_UP}, \.{ROUND\_DOWN},
\.{ROUND\_NEAR}, for $(0,1,2,3,4)$ respectively. In the second case
the middle operand is understood to be zero (namely,
\.{ROUND\_CURRENT}).
@:ROUND_OFF}\.{ROUND\_OFF@>
@:ROUND_UP}\.{ROUND\_UP@>
@:ROUND_DOWN}\.{ROUND\_DOWN@>
@:ROUND_NEAR}\.{ROUND\_NEAR@>
@:ROUND_CURRENT}\.{ROUND\_CURRENT@>

\MMIX\ operations like \.{SETL} or \.{INCH}, which involve a wyde
intermediate constant, require exactly two operands, (register, pure).
The value of the second operand should fit in two bytes.

\MMIX\ operations like \.{BNZ}, which mention a register and a
relative address, also require two operands. The first operand
should be a register number. The second operand should yield a result~$r$
in the range $-2^{16}\le r<2^{16}$ when the current location is subtracted
from it and the result is divided by~4. The second operand might also
be undefined; in that case, the eventual value must satisfy the
restriction stated for defined values. The opcodes \.{GETA} and
\.{PUSHJ} are similar, except that the first operand to \.{PUSHJ}
might also be pure (see below). The \.{JMP} operation is also
similar, but it has only one operand, and it allows the larger
address range $-2^{24}\le r<2^{24}$.

\MMIX\ operations that refer to memory, like \.{LDO} and \.{STHT} and \.{GO},
are treated like \.{ADD}
if they have three operands, except that the first operand should be
pure (not a register number) in the case of \.{PRELD}, \.{PREGO},
\.{PREST}, \.{STCO}, \.{SYNCD}, and \.{SYNCID}. These opcodes
also accept a special two-operand form, in which the second operand
stands for a {\it base address\/} and an immediate offset (see below).

The first operand of \.{PUSHJ} and \.{PUSHGO} can be either a pure
number or a register number. In the first case (`\.{PUSHJ}~\.{2,Sub}'
or `\.{PUSHGO}~\.{2,Sub}')
the programmer might be thinking ``let's push down two registers'';
in the second case (`\.{PUSHJ}~\.{\$2,Sub}' or `\.{PUSHGO}~\.{\$2,Sub}')
the programmer might be thinking ``let's make register~2 the hole
position for this subroutine call.'' Both cases result in the same
assembled output.

The remaining \MMIX\ opcodes are idiosyncratic:
$$\def\\{{\rm\quad or\quad}}
\vbox{\halign{\tt#\hfill\cr
NEG r,p,z;\cr
PUT s,z;\cr
GET r,s;\cr
POP p,yz;\cr
RESUME xyz;\cr
SAVE r,0;\cr
UNSAVE r;\cr
SYNC xyz;\cr
TRAP x,y,z\\TRAP x,yz\\TRAP xyz;\cr
}}$$
\.{SWYM} and \.{TRIP} are like \.{TRAP}. Here \.s is an integer
between 0 and~31, preferably given by one of the predefined
symbols \.{rA}, \.{rB}, \dots~for special register codes;
\.r is a register number; \.p is a pure byte; \.x, \.y, and \.z are
either register numbers or pure bytes; \.{yz} and \.{xyz} are pure
values that fit respectively in two and three bytes.

All of these rules can be summarized by saying that \MMIXAL\ treats each
\MMIX\ opcode in the most natural way. When there are three operands,
they affect fields X,~Y, and~Z of the assembled \MMIX\ instruction;
when there are two operands, they affect fields X and~YZ;
when there is just one operand, it affects field XYZ.

@ In all cases when the opcode corresponds to an \MMIX\ operation,
the \MMIXAL\ instruction tells the assembler to carry out four steps:
(1)~Align the current location
so that it is a multiple of~4, by adding 1, 2, or~3 if necessary;
(2)~Define the equivalent of the label field to be the
current location, if the label is nonempty;
(3)~Evaluate the operands and assemble the specified \MMIX\ instruction into
the current location;
(4)~Increase the current location by~4.

@ Now let's consider the pseudo-operations, starting with the simplest cases.

\bull\<label> \.{IS} \<expression>
defines the value of the label to be the value of the expression,
which must not be a future reference. The expression may be
either pure or a register number.

\bull\<label> \.{LOC} \<expression>
first defines the label to be the value of the current location, if the label
is nonempty. Then the current location is changed to the value of the
expression, which must be pure.

\smallskip For example, `\.{LOC} \.{\#1000}' will start assembling subsequent
instructions or data in location whose hexa\-decimal value is \Hex{1000}.
`\.X~\.{LOC}~\.{@@+500}' defines \.X to be the address of the first
of 500 bytes in memory; assembly will continue at location $\.X+500$.
The operation of aligning the current location to a multiple of~256,
if it is not already aligned in that way, can be expressed as
`\.{LOC}~\.{@@+(256-@@)\&255}'.

A less trivial example arises if we want to emit instructions and data into
two separate areas of memory, but we want to intermix them in the
\MMIXAL\ source file. We could start by defining \.{8H} and \.{9H}
to be the starting addresses of the instruction and data segments,
respectively. Then, a sequence of instructions could be enclosed
in `\.{LOC}~\.{8B}; \dots; \.{8H}~\.{IS}~\.{@@}'; a sequence of
data could be enclosed in `\.{LOC}~\.{9B}; \dots; \.{9H}~\.{IS}~\.{@@}'.
Any number of such sequences could then be combined.
Instead of the two pseudo-instructions `\.{8H}~\.{IS}~\.{@@;} \.{LOC}~\.{9B}'
one could in fact write simply `\.{8H}~\.{LOC}~\.{9B}' when
switching from instructions to data.

\bull \.{PREFIX} \<symbol>
redefines the current prefix to be the given symbol (fully qualified).
The label field should be blank.

@ The next pseudo-operations assemble bytes, wydes, tetrabytes, or
octabytes of data.

\bull \<label> \.{BYTE} \<expression list>
defines the label to be the current location, if the label field is nonempty;
then it assembles one byte for each expression in the expression list, and
advances the current location by the number of bytes. The expressions
should all be pure numbers that fit in one byte.

String constants are often used in such expression lists.
For example, if the current location is \Hex{1000}, the instruction
\.{BYTE}~\.{"Hello",0} assembles six bytes containing the constants
\.{'H'}, \.{'e'}, \.{'l'}, \.{'l'}, \.{'o'}, and~\.0 into locations
\Hex{1000}, \dots,~\Hex{1005}, and advances the current location
to \Hex{1006}.

\bull \<label> \.{WYDE} \<expression list>
is similar, but it first makes the current location even, by adding~1 to it
if necessary. Then it defines the label (if a nonempty label is present),
and assembles each expression as a two-byte value. The current location
is advanced by twice the number of expressions in the list. The
expressions should all be pure numbers that fit in two bytes.

\bull \<label> \.{TETRA} \<expression list>
is similar, but it aligns the current location to a multiple of~4
before defining the label; then it
assembles each expression as a four-byte value. The current location
is advanced by $4n$ if there are $n$~expressions in the list. Each
expression should be a pure number that fits in four bytes.

\bull \<label> \.{OCTA} \<expression list>
is similar, but it first aligns the current location to a multiple of~8;
it assembles each expression as an eight-byte value. The current location
is advanced by $8n$ if there are $n$~expressions in the list. Any or all
of the expressions may be future references, but they should all
be defined as pure numbers eventually.

@ Global registers are important for accessing memory in \MMIX\ programs.
They could be allocated by hand, and defined with \.{IS} instructions,
but \MMIXAL\ provides a mechanism that is usually much more convenient:

\bull \<label> \.{GREG} \<expression>
allocates a new global register, and assigns its number as the
equivalent of the label.
At the beginning of assembly, the current global threshold~G is~\$255.
Each distinct \.{GREG} instruction decreases~G by~1; the final value of~G will
be the initial value of~rG when the assembled program is loaded.

The value of the expression will be loaded into the global register
at the beginning of the program. {\it If this value is nonzero, it
should remain constant throughout the program execution\/}; such
global registers are considered to be {\it base addresses}. Two or
more base addresses with the same constant value are assigned to the
same global register number.

Base addresses can simplify memory accesses in an important way.
Suppose, for example, five octabyte values appear in a data segment,
and their addresses are called \.{AA}, \.{BB}, \.{CC}, \.{DD}, and
\.{EE}:
$$\.{AA LOC @@+8;BB LOC @@+8;CC LOC @@+8;DD LOC @@+8;EE LOC @@+8}$$
Then if you say \.{Base GREG AA}, you will be able to write simply
`\.{LDO}~\.{\$1,AA}' to bring \.{AA} into register~\.{\$1}, and
`\.{LDO}~\.{\$2,CC}' to bring \.{CC} into register~\.{\$2}.

Here's how it works: Whenever a memory operation such as
\.{LDO} or \.{STB} or \.{GO} has only two operands, the second
operand should be a pure number whose value can be expressed
as $b+\delta$, where $0\le\delta<256$ and $b$ is the value of
a base address in one of the preceding \.{GREG} commands. The \MMIXAL\
processor will find the closest base address and manufacture an
appropriate command. For example, the instruction `\.{LDO}~\.{\$2,CC}' in the
example of the preceding paragraph would be converted automatically to
`\.{LDO}~\.{\$2,Base,16}'.

If no base address is close enough, an error message will be
generated, unless this program is run with the \.{-x} option
on the command line. The \.{-x} option inserts additional instructions
if necessary, using global register~255, so that any address is
accessible. For example,
if there is no base address that allows \.{LDO}~\.{\$2,FF} to be
implemented in a single instruction, but if \.{FF} equals \.{Base+1000},
then the \.{-x} option would assemble two instructions,
$$\.{SETL \$255,1000; LDO \$2,Base,\$255}$$
in place of \.{LDO}~\.{\$2,FF}. Caution:~The \.{-x} feature makes the
number of actual \MMIX\ instructions hard to predict, so extreme care must
be used if your style of coding includes relative branch instructions
in dangerous forms like `\.{BNZ}~\.{x,@@+8}'.

This base address convention can be used also with the alias
operation~\.{LDA}. For example, `\.{LDA}~\.{\$3,CC}' loads the
@.LDA@>
address of \.{CC} into register~3, by assembling the instruction
`\.{ADDU}~\.{\$3,Base,16}'.

\MMIXAL\ also allows a two-operand form for memory operations such as
$$\hbox{\.{LDO} \.{\$1,\$2}}$$
to be an abbreviation for `\.{LDO} \.{\$1,\$2,0}'.

When \MMIXAL\ programs use subroutines with a memory stack in addition
to the built-in register stack, they usually begin with the
instructions `\.{sp}~\.{GREG}~\.{0;fp}~\.{GREG}~\.0'; these instructions
allocate a {\it stack pointer\/} \.{sp=\$254} and a {\it frame pointer\/}
\.{fp=\$253}. However, subroutine libraries are free to implement any
conventions for global registers and stacks that they like.
@^stack pointer@>
@^frame pointer@>

@ Short programs rarely run out of global registers, but long programs
need a mechanism to check that \.{GREG} hasn't been used too often.
The following pseudo-instruction provides the necessary safety valve:

\bull \.{LOCAL} \<expression>
ensures that the expression will be a local register in the program
being assembled. The expression should be a register number, and
the label field should be blank. At the close of
assembly, \MMIXAL\ will report an error if the final value of~G does
not exceed all register numbers that are declared local in this way.

A \.{LOCAL} instruction need not be given unless the register number
is 32 or~more. (\MMIX\ always considers \.{\$0} through \.{\$31} to be
local, so \MMIXAL\ implicitly acts as if the
instruction `\.{LOCAL}~\.{\$31}' were present.)

@ Finally, there are two pseudo-instructions to pass information
and hints to the loading routine and/or to debuggers that will be
using the assembled program.

\bull \.{BSPEC} \<expression>
begins ``special mode''; the \<expression> should have a value that
fits in two bytes, and the label field should be blank.

\bull \.{ESPEC}
ends ``special mode''; the operand field is ignored, and the label
field should be blank.

\smallskip\noindent
All material assembled between \.{BSPEC} and \.{ESPEC} is passed
directly to the output, but not loaded as part of the assembled program.
Ordinary \MMIX\ instructions cannot appear in special mode; only the
pseudo-operations \.{IS}, \.{PREFIX}, \.{BYTE}, \.{WYDE}, \.{TETRA},
\.{OCTA}, \.{GREG}, and \.{LOCAL} are allowed. The operand of
\.{BSPEC} should have a value that fits in two bytes; this value
identifies the kind of data that follows. (For example, \.{BSPEC}~\.0
might introduce information about subroutine calling conventions at the
current location, and \.{BSPEC}~\.1 might introduce line numbers from
a high-level-language program that was compiled into the code at
the current place.
System routines often need to pass such information through an assembler
to the operating system, hence \MMIXAL\ provides a general-purpose conduit.)

@ A program should begin at the special symbolic location \.{Main}
@.Main@>
(more precisely, at the address corresponding to
the fully qualified symbol \.{:Main}).
This symbol always has serial number~1, and it must always be defined.
@^serial number@>

Locations should not receive assembled data more than once.
(More precisely, the loader will load the bitwise~xor of all the
data assembled for each byte position; but the general rule ``do not load
two things into the same byte'' is safest.)
All locations that do not receive assembled data are initially zero,
except that the loading routine will put register stack data into
segment~3, and the operating system may put command-line data and
debugger data into segment~2.
(The rudimentary \MMIX\ operating system starts a program
with the number of command-line arguments in~\$0, and a pointer to
the beginning of an array of argument pointers in~\$1.)
Segments 2 and 3 should not get assembled data, unless the
user is a true hacker who is willing to take the risk that such data
might crash the system.

@* Binary MMO output. When the \MMIXAL\ processor assembles a file
called \.{foo.mms}, it produces a binary output file called \.{foo.mmo}.
(The suffix \.{mms} stands for ``\MMIX\ symbolic,'' and \.{mmo} stands
for ``\MMIX\ object.'') Such \.{mmo} files have a simple structure
consisting of a sequence of tetrabytes. Some of the tetrabytes are
instructions to a loading routine; others are data to be loaded.
@^object files@>

Loader instructions are distinguished from tetrabytes of data by their
first (most significant) byte, which has the special escape-code value
\Hex{98}, called |mm| in the program below. This code value corresponds
to \MMIX's opcode \.{LDVTS}, which is unlikely to occur in tetras of
data. The second byte~X of a loader instruction is the loader opcode,
called the {\it lopcode}. The third and fourth bytes, Y~and~Z, are
operands. Sometimes they are combined into a single 16-bit operand called~YZ.
@^lopcodes@>

@d mm 0x98

@ A small, contrived example will help explain the basic ideas of \.{mmo}
format. Consider the following input file, called \.{test.mms}:
$$\obeyspaces\vbox{\halign{\tt#\hfil\cr
\% A peculiar example of MMIXAL\cr
\     LOC   Data\_Segment      \% location \#2000000000000000\cr
\     OCTA  1F                \% a future reference\cr
a    GREG  @@                 \% \$254 is base address for ABCD\cr
ABCD BYTE  "ab"              \% two bytes of data\cr
\     LOC   \#123456789        \% switch to the instruction segment\cr
Main JMP   1F                \% another future reference\cr
\     LOC   @@+\#4000           \% skip past 16384 bytes\cr
2H   LDB   \$3,ABCD+1         \% use the base address\cr
\     BZ    \$3,1F; TRAP       \% and refer to the future again\cr
\# 3 "foo.mms"                \% this comment is a line directive\cr
\     LOC   2B-4*10           \% move 10 tetras before previous location\cr
1H   JMP   2B                \% resolve previous references to 1F\cr
\     BSPEC 5                 \% begin special data of type 5\cr
\     TETRA {\AM}a<<8             \% four bytes of special data\cr
\     WYDE  a-\$0              \% two more bytes of special data\cr
\     ESPEC                   \% end a special data packet\cr
\     LOC   ABCD+2            \% resume the data segment\cr
\     BYTE  "cd",\#98          \% assemble three more bytes of data\cr
}}$$
It defines a silly program that essentially puts \.{'b'} into register~3;
the program halts when it gets to an all-zero \.{TRAP} instruction
following the~\.{BZ}. But the assembled output of this file illustrates most
of the features of \MMIX\ objects, and in fact \.{test.mms} was the
first test file tried by the author when the \MMIXAL\ processor was originally
written.

The binary output file \.{test.mmo} assembled from \.{test.mms} consists
of the following tetrabytes, shown in hexadecimal notation with brief
comments.  Fuller explanations
appear with the descriptions of individual lopcodes below.
$$
\halign{\hskip.5in\tt#&\quad#\hfil\cr
98090101&|lop_pre| $1,1$ (preamble, version 1, 1 tetra)\cr
36f4a363&(the file creation time)\cr
% Sat Mar 20 23:44:35 1999
98012001&|lop_loc| $\Hex{20},1$ (data segment, 1 tetra)\cr
00000000&(low tetrabyte of address in data segment)\cr
00000000&(high tetrabyte of \.{OCTA} \.{1F})\cr
00000000&(low tetrabyte, will be fixed up later)\cr
61620000&(\.{"ab"}, padded with trailing zeros)\cr
\noalign{\penalty-200}
98010002&|lop_loc| $0,2$ (instruction segment, 2 tetras)\cr
00000001&(high tetrabyte of address in instruction segment)\cr
2345678c&(low tetrabyte of address, after alignment)\cr
98060002&|lop_file| $0,2$ (file name 0, 2 tetras)\cr
74657374&(\.{"test"})\cr
2e6d6d73&(\.{".mms"})\cr
98070007&|lop_line| 7 (line 7 of the current file)\cr
f0000000&(\.{JMP} \.{1F}, will be fixed up later)\cr
98024000&|lop_skip| \Hex{4000} (advance 16384 bytes)\cr
98070009&|lop_line| 9 (line 9 of the current file)\cr
8103fe01&(\.{LDB} \.{\$3,b,1}, uses base address \.b)\cr
42030000&(\.{BZ} \.{\$3,1F}, will be fixed later)\cr
9807000a&|lop_line| 10 (stay on line 10)\cr
00000000&(\.{TRAP})\cr
98010002&|lop_loc| $0,2$ (instruction segment, 2 tetras)\cr
00000001&(high tetrabyte of address in instruction segment)\cr
2345a768&(low tetrabyte of address \.{1H})\cr
98050010&|lop_fixrx| 16 (fix 16-bit relative address)\cr
0100fff5&(fixup for location \.{@@-4*-11})\cr
98040ff7&|lop_fixr| \Hex{ff7} (fix \.{@@-4*\#ff7})\cr
98032001&|lop_fixo| $\Hex{20},1$ (data segment, 1 tetra)\cr
00000000&(low tetrabyte of data segment address to fix)\cr
98060102&|lop_file| $1,2$ (file name 1, 2 tetras)\cr
666f6f2e&(\.{"foo."})\cr
6d6d7300&(\.{"mms",0})\cr
98070004&|lop_line| 4 (line 4 of the current file)\cr
f000000a&(\.{JMP} \.{2B})\cr
98080005&|lop_spec| 5 (begin special data of type 5)\cr
00000200&(\.{TETRA} \.{\&a<<8})\cr
00fe0000&(\.{WYDE} \.{a-\$0})\cr
98012001&|lop_loc| $\Hex{20},1$ (data segment, 1 tetra)\cr
0000000a&(low tetrabyte of address in data segment)\cr
00006364&(\.{"cd"} with leading zeros, because of alignment)\cr
98000001&|lop_quote| (don't treat next tetrabyte as a lopcode)\cr
98000000&(\.{BYTE} \.{\#98}, padded with trailing zeros)\cr
980a00fe&|lop_post| \$254 (begin postamble, G is 254)\cr
20000000&(high tetrabyte of the initial contents of \$254)\cr
00000008&(low tetrabyte of base address \$254)\cr
00000001&(high tetrabyte of the initial contents of \$255)\cr
2345678c&(low tetrabyte of \$255, is address of \.{Main})\cr
980b0000&|lop_stab| (begin symbol table)\cr
203a5040&(compressed form for symbol table as a ternary trie)\cr
50404020\cr
41204220\cr
43094408\cr
83404020&(\.{ABCD} = \Hex{2000000000000008}, serial 3)\cr
4d206120\cr
69056e01\cr
2345678c\cr
81400f61&(\.{Main} = \Hex{000000012345678c}, serial 1)\cr
fe820000&(\.{a} = \$254, serial 2)\cr
980c000a&|lop_end| (end symbol table, 10 tetras)\cr
}$$

@ When a tetrabyte of the \.{mmo} file does not begin with the escape code,
it is loaded into the current location~$\lambda$, and $\lambda$ is increased
to the next higher multiple of~4.
(If $\lambda$ is not a multiple of~4, the tetrabyte actually goes
into location $\lambda\land(-4)=4\lfloor\lambda/4\rfloor$, according
to \MMIX's usual conventions.) The current line number is also increased
by~1, if it is nonzero.

When a tetrabyte does begin with the escape code, its next byte
is the lopcode defining a loader instruction. There are thirteen lopcodes:

\bull |lop_quote|: $\rm X=\Hex{00}$, $\rm YZ=1$. Treat the next tetra as
an ordinary tetrabyte, even if it begins with the escape code.

\bull |lop_loc|: $\rm X=\Hex{01}$, $\rm Y=high$ byte, $\rm Z=tetra$ count
($\rm Z=1$~or~2). Set the current location to the 64-bit address defined
by the next Z tetras, plus $\rm 2^{56}Y$. Usually $\rm Y=0$ (for the
instruction segment) or $\rm Y=\Hex{20}$ (for the data segment).
If $\rm Z=2$, the high tetra appears first.

\bull |lop_skip|: $\rm X=\Hex{02}$, $\rm YZ=delta$. Increase the
current location by~YZ.

\bull |lop_fixo|: $\rm X=\Hex{03}$, $\rm Y=high$ byte, $\rm Z=tetra$ count
($\rm Z=1$~or~2). Load the value of the current location~$\lambda$ into
octabyte~P, where P~is the 64-bit address defined by the next Z tetras
plus $\rm2^{56}Y$ as in |lop_loc|. (The octabyte at~P was previously assembled
as zero because of a future reference.)

\bull |lop_fixr|: $\rm X=\Hex{04}$, $\rm YZ=delta$. Load YZ into the YZ~field
of the tetrabyte in location~P, where P~is
$\rm\lambda-4YZ$, namely the address that precedes the current location
by YZ~tetrabytes. (This tetrabyte was previously loaded with an \MMIX\
instruction that takes a relative address: a branch, probable branch,
\.{JMP}, \.{PUSHJ}, or~\.{GETA}. Its YZ~field was previously
assembled as zero because of a future reference.)

\bull |lop_fixrx|: $\rm X=\Hex{05}$, $\rm Y=0$, $\rm Z=16$ or 24.
Proceed as in |lop_fixr|,
but load $\delta$ into tetrabyte $\rm P=\lambda-4\delta$ instead of loading
YZ into $\rm P=\lambda-4YZ$. Here $\delta$ is the value of the tetrabyte
following the |lop_fixrx| instruction; its leading byte will either
0 or~1. If the leading byte is~1, $\delta$ should be treated as the
{\it negative\/} number $(\delta\land\Hex{ffffff})-2^{\rm Z}$ when
calculating the address~P. (The latter case arises only rarely,
but it is needed when fixing up a relative ``future'' reference that
ultimately leads to a ``backward'' instruction. The value of~$\delta$ that
is xored into location~P in such cases will change \.{BZ} to \.{BZB},
or \.{JMP} to \.{JMPB}, etc.; we have $\rm Z=24$ when fixing a~\.{JMP},
$\rm Z=16$ otherwise.)

\bull |lop_file|: $\rm X=\Hex{06}$, $\rm Y=file$ number, $\rm Z=tetra$ count.
Set the current file number to~Y and the current line number to~zero. If this
file number has occurred previously, Z~should be zero; otherwise Z~should be
positive, and the next Z tetrabytes are the characters of the file name in
big-endian order.
Trailing zeros follow the file name if its length is not a multiple of~4.

\bull |lop_line|: $\rm X=\Hex{07}$, $\rm YZ=line$ number. Set the current line
number to~YZ\null. If the line number is nonzero, the current file and current
line should correspond to the source location that generated the next data to
be loaded, for use in diagnostic messages. (The \MMIXAL\ processor gives
precise line numbers to the sources of tetrabytes in segment~0, which tend to
be instructions, but not to the sources of tetrabytes assembled in other
segments.)

\bull |lop_spec|: $\rm X=\Hex{08}$, $\rm YZ=type$. Begin special data of
type~YZ\null. The subsequent tetrabytes, continuing until the next loader
operation other than |lop_quote|, comprise the special data. A |lop_quote|
instruction allows tetrabytes of special data to begin with the escape code.

\bull |lop_pre|: $\rm X=\Hex{09}$, $\rm Y=1$, $\rm Z=tetra$ count. A~|lop_pre|
instruction, which defines the ``preamble,'' must be the first tetrabyte of
every \.{mmo} file. The Y~field specifies the version number of \.{mmo}
format, currently~1; other version numbers may be defined later, but
version~1 should always be supported as described in the present document.
The Z~tetrabytes following a |lop_pre| command provide additional information
that might be of interest to system routines. If $\rm Z>0$, the first tetra
of additional information records the time that this \.{mmo} file was
created, measured in seconds since 00:00:00 Greenwich Mean Time on
1~Jan~1970.

\bull |lop_post|: $\rm X=\Hex{0a}$, $\rm Y=0$, $\rm Z=G$ (must be 32~or~more).
This instruction begins the {\it postamble}, which follows all instructions
and data to be loaded. It causes the loaded program to begin with rG equal to
the stated value of~G, and with \$G, $\rm G+1$, \dots,~\$255 initially set to
the values of the next $\rm(256-G)*2$ tetrabytes. These tetrabytes specify
$\rm 256-G$ octabytes in big-endian fashion (high half first).

\bull |lop_stab|: $\rm X=\Hex{0b}$, $\rm YZ=0$. This instruction must appear
immediately after the $\rm(256-G)*2$ tetrabytes following~|lop_post|. It is
followed by the symbol table, which lists the equivalents of all user-defined
symbols in a compact form that will be described later.

\bull |lop_end|: $\rm X=\Hex{0c}$, $\rm YZ=tetra$ count. This instruction
must be the very last tetrabyte of each \.{mmo} file. Furthermore,
exactly YZ tetrabytes must appear between it and the |lop_stab| command.
(Therefore a program can easily find the symbol table without reading
forward through the entire \.{mmo} file.)

\smallskip
A separate routine called \.{MMOtype} is available to translate
binary \.{mmo} files into human-readable form.

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

@ Many readers will have noticed that \MMIXAL\ has no facilities for
relocatable output, nor does \.{mmo} format support such features. The
author's first drafts of \MMIXAL\ and \.{mmo} did allow relocatable objects,
with external linkages, but the rules were substantially more complicated and
therefore inconsistent with the goals of {\sl The Art of Computer Programming}.
The present design might actually prove to be superior to the current
practice, now that computer memory is significantly cheaper than it
used to be, because one-pass assembly and loading are extremely fast when
relocatability and external linkages are disallowed. Different program modules
can be assembled together about as fast as they could be linked together under
a relocatable scheme, and they can communicate with each other in much more
flexible ways. Debugging tools are enhanced when open-source libraries are
combined with user programs, and such libraries will certainly improve in
quality when their source form is accessible to a larger community of users.

@* Basic data types.
This program for the 64-bit \MMIX\ architecture is based on 32-bit integer
arithmetic, because nearly every computer available to the author at the time
of writing was limited in that way.
Details of the basic arithmetic appear in a separate program module
called {\mc MMIX-ARITH}, because the same routines are needed also
for the simulators. The definition of type \&{tetra} should be changed, if
necessary, to conform with the definitions found in {\mc MMIX-ARITH}.
@^system dependencies@>

@<Type...@>=
typedef unsigned int tetra;
  /* assumes that an int is exactly 32 bits wide */
typedef struct { tetra h,l;} octa; /* two tetrabytes make one octabyte */
typedef enum {@!false,@!true}@+@!bool;

@ @<Glob...@>=
extern octa zero_octa; /* |zero_octa.h=zero_octa.l=0| */
extern octa neg_one; /* |neg_one.h=neg_one.l=-1| */
extern octa aux; /* auxiliary output of a subroutine */
extern bool overflow; /* set by certain subroutines for signed arithmetic */

@ Most of the subroutines in {\mc MMIX-ARITH} return an octabyte as
a function of two octabytes; for example, |oplus(y,z)| returns the
sum of octabytes |y| and~|z|. Division inputs the high 
half of a dividend in the global variable~|aux| and returns
the remainder in~|aux|.

@<Sub...@>=
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
extern octa odiv @,@,@[ARGS((octa x,octa y,octa z))@];
  /* unsigned $(x,y)/z$; $|aux|=(x,y)\bmod z$ */

@ Here's a rudimentary check to see if arithmetic is in trouble.

@<Init...@>=
acc=shift_left(neg_one,1);
if (acc.h!=0xffffffff) panic("Type tetra is not implemented correctly");
@.Type tetra...@>

@ Future versions of this program will work with symbols formed from Unicode
characters, but the present code limits itself to an 8-bit subset.
@^Unicode@>
The type \&{Char} is defined here in order to ease the later transition:
At present, \&{Char} is the same as \&{unsigned} \&{char}, but
\&{Char} can be changed to a 16-bit type in the Unicode version.

Other changes will also be necessary when the transition to Unicode is made;
for example, some calls of |fprintf| will become calls of |fwprintf|,
and some occurrences of \.{\%s} will become \.{\%ls} in print formats.
The switchable type name \&{Char} provides at least a first step
towards a brighter future with Unicode.

@<Type...@>=
typedef unsigned char Char; /* bytes that will become wydes some day */

@ While we're talking about classic systems versus future systems, we
might as well define the |ARGS| macro, which makes function prototypes
available on {\mc ANSI \CEE/} systems without making them
uncompilable on older systems. Each subroutine below is declared first
with a prototype, then with an old-style definition.

@<Preprocessor definitions@>=
#ifdef __STDC__
#define ARGS(list) list
#else
#define ARGS(list) ()
#endif

@* Basic input and output. Input goes into a buffer that is normally
limited to 72 characters. This limit can be raised, by using the
\.{-b} option when invoking the assembler; but short buffers will keep listings
from becoming unwieldy, because a symbolic listing adds 19 characters per~line.

@<Initialize everything@>=
if (buf_size<72) buf_size=72;
buffer=(Char*)calloc(buf_size+1,sizeof(Char));
lab_field=(Char*)calloc(buf_size+1,sizeof(Char));
op_field=(Char*)calloc(buf_size,sizeof(Char));
operand_list=(Char*)calloc(buf_size,sizeof(Char));
err_buf=(Char*)calloc(buf_size+60,sizeof(Char));
if (!buffer || !lab_field || !op_field || !operand_list || !err_buf)
  panic("No room for the buffers");
@.No room...@>

@ @<Glob...@>=
Char *buffer; /* raw input of the current line */
Char *buf_ptr; /* current position within |buffer| */
Char *lab_field; /* copy of the label field of the current instruction */
Char *op_field; /* copy of the opcode field of the current instruction */
Char *operand_list; /* copy of the operand field of the current instruction */
Char *err_buf; /* place where dynamic error messages are sprinted */

@ @<Get the next line of input text, or |break| if the input has ended@>=
if (!fgets(buffer,buf_size+1,src_file)) break;
line_no++;
line_listed=false;
j=strlen(buffer);
if (buffer[j-1]=='\n') buffer[j-1]='\0'; /* remove the newline */
else if ((j=fgetc(src_file))!=EOF)
  @<Flush the excess part of an overlong line@>;
if (buffer[0]=='#') @<Check for a line directive@>;
buf_ptr=buffer;

@ @<Flush the excess...@>=
{
  while(j!='\n' && j!= EOF) j=fgetc(src_file);
  if (!long_warning_given) {
    long_warning_given=true;
    err("*trailing characters of long input line have been dropped");
@.trailing characters...@>
    fprintf(stderr,
       "(say `-b <number>' to increase the length of my input buffer)\n");
  }@+else err("*trailing characters dropped");
}

@ @<Glob...@>=
int cur_file; /* index of the current file in |filename| */
int line_no; /* current position in the file */
bool line_listed; /* have we listed the buffer contents? */
bool long_warning_given; /* have we given the hint about \.{-b}? */

@ We keep track of source file name and line number at all times, for
error reporting and for synchronization data in the object file.
Up to 256 different source file names can be remembered.

@<Glob...@>=
Char *filename[257];
  /* source file names, including those in line directives */
int filename_count; /* how many |filename| entries have we filled? */

@ If the current line is a line directive, it will also be treated
as a comment by the assembler.

@<Check for a line directive@>=
{
  for (p=buffer+1;isspace(*p);p++);
  for (j=*p++-'0';isdigit(*p);p++) j=10*j+*p-'0';
  for (;isspace(*p);p++);
  if (*p=='\"') {
    if (!filename[filename_count]) {
      filename[filename_count]=(Char*)calloc(FILENAME_MAX+1,sizeof(Char));
      if (!filename[filename_count])
        panic("Capacity exceeded: Out of filename memory");
@.Capacity exceeded...@>
    }
    for (p++,q=filename[filename_count];*p && *p!='\"';p++,q++) *q=*p;
    if (*p=='\"' && *(p-1)!='\"') { /* yes, it's a line directive */
      *q='\0';
      for (k=0;strcmp(filename[k],filename[filename_count])!=0;k++);
      if (k==filename_count) filename_count++;
      cur_file=k;
      line_no=j-1;
    }
  }
}

@ Archaic versions of the \CEE/ library do not define |FILENAME_MAX|.

@<Preprocessor definitions@>=
#ifndef FILENAME_MAX
#define FILENAME_MAX 256
#endif

@ @<Local variables@>=
register Char *p,*q; /* the place where we're currently scanning */

@ The next several subroutines are useful for preparing a listing of
the assembled results. In such a listing, which the user can request
with a command-line option, we fill the leftmost 19 columns with
a representation of the output that has been assembled from the
input in the buffer. Sometimes the assembled output requires
more than one line, because we have room to output only a tetrabyte per line.

The |flush_listing_line| subroutine is called when we have finished
generating one line's worth of assembled material. Its parameter is
a string to be printed between the assembled material and the
buffer contents, if the input line hasn't yet been echoed. The length
of this string should be 19 minus the number of characters already printed
on the current line of the listing.

@<Sub...@>=
void flush_listing_line @,@,@[ARGS((char*))@];@+@t}\6{@>
void flush_listing_line(s)
  char *s;
{
  if (line_listed) fprintf(listing_file,"\n");
  else {
    fprintf(listing_file,"%s%s\n",s,buffer);
    line_listed=true;
  }
}  

@ Only the three least significant hex digits of a location are shown on
the listing, unless the other digits have changed. The following subroutine
prints an extra line when a change needs to be shown.

@<Sub...@>=
void update_listing_loc @,@,@[ARGS((int))@];@+@t}\6{@>
void update_listing_loc(k)
  int k; /* the location to display, mod 4 */
{
  if (cur_loc.h!=listing_loc.h || ((cur_loc.l^listing_loc.l)&0xfffff000)) {
    fprintf(listing_file,"%08x%08x:",cur_loc.h,(cur_loc.l&-4)|k);
    flush_listing_line("  ");
  }
  listing_loc.h=cur_loc.h;@+
  listing_loc.l=(cur_loc.l&-4)|k;
}

@ @<Glob...@>=
octa cur_loc; /* current location of assembled output */
octa listing_loc; /* current location on the listing */
unsigned char hold_buf[4]; /* assembled bytes */
unsigned char held_bits; /* which bytes of |hold_buf| are active? */
unsigned char listing_bits; /* which of them haven't been listed yet? */
bool spec_mode; /* are we between |BSPEC| and |ESPEC|? */
tetra spec_mode_loc; /* number of bytes in the current special output */

@ When bytes are assembled, they are placed into the |hold_buf|.
More precisely, a byte assembled for a location that is |j|~plus a
multiple of~4 is placed into |hold_buf[j]|; two auxiliary variables,
|held_bits| and |listing_bits|, are then increased by |1<<j|.
Furthermore, |listing_bits|
is increased by |0x10<<j| if that byte is a future reference to be
resolved later.

The bytes are held until we need to output them.
The |listing_clear| routine lists any that have been held
but not yet shown. It should be called only when |listing_bits!=0|.

@<Sub...@>=
void listing_clear @,@,@[ARGS((void))@];@+@t}\6{@>
void listing_clear()
{
  register int j,k;
  for (k=0;k<4;k++) if (listing_bits&(1<<k)) break;
  if (spec_mode) fprintf(listing_file,"         ");
  else {
    update_listing_loc(k);
    fprintf(listing_file," ...%03x: ",(listing_loc.l&0xffc)|k);
  }
  for (j=0;j<4;j++)
    if (listing_bits&(0x10<<j)) fprintf(listing_file,"xx"); 
    else if (listing_bits&(1<<j)) fprintf(listing_file,"%02x",hold_buf[j]);
    else fprintf(listing_file,"  ");
  flush_listing_line("  ");
  listing_bits=0;
}

@ Error messages are written to |stderr|. If the message begins with
`\.*' it is merely a warning; if it begins with `\.!' it is fatal;
otherwise the error is probably serious enough to make manual correction
necessary, yet it is not tragic. Errors and warnings appear
also on the optional listing file.

@d err(m) {@+report_error(m);@+if (m[0]!='*') goto bypass;@+}
@d derr(m,p) {@+sprintf(err_buf,m,p);
   report_error(err_buf);@+if (err_buf[0]!='*') goto bypass;@+}
@d dderr(m,p,q) {@+sprintf(err_buf,m,p,q);
   report_error(err_buf);@+if (err_buf[0]!='*') goto bypass;@+}
@d panic(m) {@+sprintf(err_buf,"!%s",m);@+report_error(err_buf);@+}
@d dpanic(m,p) {@+err_buf[0]='!';@+sprintf(err_buf+1,m,p);@+
                                          report_error(err_buf);@+}

@<Sub...@>=
void report_error @,@,@[ARGS((char*))@];@+@t}\6{@>
void report_error(message)
  char *message;
{
  if (!filename[cur_file]) filename[cur_file]="(nofile)";
  if (message[0]=='*')
    fprintf(stderr,"\"%s\", line %d warning: %s\n",
                 filename[cur_file],line_no,message+1);
  else if (message[0]=='!')
    fprintf(stderr,"\"%s\", line %d fatal error: %s\n",
                 filename[cur_file],line_no,message+1);
  else {
    fprintf(stderr,"\"%s\", line %d: %s!\n",
                 filename[cur_file],line_no,message);
    err_count++;
  }
  if (listing_file) {
    if (!line_listed) flush_listing_line("****************** ");
    if (message[0]=='*') fprintf(listing_file,
            "************ warning: %s\n",message+1);
    else if (message[0]=='!') fprintf(listing_file,
            "******** fatal error: %s!\n",message+1);
    else fprintf(listing_file,
            "********** error: %s!\n",message);
  }
  if (message[0]=='!') exit(-2);
}

@ @<Glob...@>=
int err_count; /* this many errors were found */

@ Output to the binary |obj_file| occurs four bytes at a time. The
bytes are assembled in small buffers, not output as single tetrabytes,
because we want the output to be big-endian even when the assembler
is running on a little-endian machine.
@^big-endian versus little-endian@>
@^little-endian versus big-endian@>

@d mmo_write(buf) if (fwrite(buf,1,4,obj_file)!=4)
     dpanic("Can't write on %s",obj_file_name)
@.Can't write...@>

@<Sub...@>=
void mmo_clear @,@,@[ARGS((void))@];
void mmo_out @,@,@[ARGS((void))@];
unsigned char lop_quote_command[4]={mm,lop_quote,0,1};
void mmo_clear() /* clears |hold_buf|, when |held_bits!=0| */
{
  if (hold_buf[0]==mm) mmo_write(lop_quote_command);
  mmo_write(hold_buf);
  if (listing_file && listing_bits) listing_clear();
  held_bits=0;
  hold_buf[0]=hold_buf[1]=hold_buf[2]=hold_buf[3]=0;
  mmo_cur_loc=incr(mmo_cur_loc,4);@+ mmo_cur_loc.l&=-4;
  if (mmo_line_no) mmo_line_no++;
}
@#  
unsigned char mmo_buf[4];
int mmo_ptr;
void mmo_out() /* output the contents of |mmo_buf| */
{
  if (held_bits) mmo_clear();
  mmo_write(mmo_buf);
}

@ @<Sub...@>=
void mmo_tetra @,@,@[ARGS((tetra))@];
void mmo_byte @,@,@[ARGS((unsigned char))@];
void mmo_lop @,@,@[ARGS((char,unsigned char,unsigned char))@];
void mmo_lopp @,@,@[ARGS((char,unsigned short))@];
void mmo_tetra(t) /* output a tetrabyte */
  tetra t;
{
  mmo_buf[0]=t>>24;@+ mmo_buf[1]=(t>>16)&0xff;
  mmo_buf[2]=(t>>8)&0xff;@+ mmo_buf[3]=t&0xff;
  mmo_out();
}
@#
void mmo_byte(b)
  unsigned char b;
{
  mmo_buf[(mmo_ptr++)&3]=b;
  if (!(mmo_ptr&3)) mmo_out();
}
@#
void mmo_lop(x,y,z) /* output a loader operation */
  char x;
  unsigned char y,z;
{
  mmo_buf[0]=mm;@+ mmo_buf[1]=x;@+ mmo_buf[2]=y;@+ mmo_buf[3]=z;
  mmo_out();
}
@#
void mmo_lopp(x,yz) /* output a loader operation with two-byte operand */
  char x;
  unsigned short yz;
{
  mmo_buf[0]=mm;@+ mmo_buf[1]=x;@+
  mmo_buf[2]=yz>>8;@+ mmo_buf[3]=yz&0xff;
  mmo_out();
}

@ The |mmo_loc| subroutine makes the current location in the object file
equal to |cur_loc|.

@<Sub...@>=
void mmo_loc @,@,@[ARGS((void))@];@+@t}\6{@>
void mmo_loc()
{
  octa o;
  if (held_bits) mmo_clear();
  o=ominus(cur_loc,mmo_cur_loc);
  if (o.h==0 && o.l<0x10000) {
    if (o.l) mmo_lopp(lop_skip,o.l);
  }@+else {
    if (cur_loc.h&0xffffff) {
      mmo_lop(lop_loc,0,2);
      mmo_tetra(cur_loc.h);
    }@+else mmo_lop(lop_loc,cur_loc.h>>24,1);
    mmo_tetra(cur_loc.l);
  }
  mmo_cur_loc=cur_loc;
}

@ Similarly, the |mmo_sync| subroutine makes sure that the current file and
line number in the output file agree with |cur_file| and |line_no|.

@<Sub...@>=
void mmo_sync @,@,@[ARGS((void))@];@+@t}\6{@>
void mmo_sync()
{
  register int j; register unsigned char *p;
  if (cur_file!=mmo_cur_file) {
    if (filename_passed[cur_file]) mmo_lop(lop_file,cur_file,0);
    else {
      mmo_lop(lop_file,cur_file,(strlen(filename[cur_file])+3)>>2);
      for (j=0,p=filename[cur_file];*p;p++,j=(j+1)&3) {
        mmo_buf[j]=*p;
        if (j==3) mmo_out();
      }
      if (j) {
        for (;j<4;j++) mmo_buf[j]=0;
        mmo_out();
      }
    filename_passed[cur_file]=1;
    }
    mmo_cur_file=cur_file;
    mmo_line_no=0;
  }
  if (line_no!=mmo_line_no) {
    if (line_no>=0x10000)
      panic("I can't deal with line numbers exceeding 65535");
@.I can't deal with...@>
    mmo_lopp(lop_line,line_no);
    mmo_line_no=line_no;
  }
}

@ @<Glob...@>=
octa mmo_cur_loc; /* current location in the object file */
int mmo_line_no; /* current line number in the \.{mmo} output so far */
int mmo_cur_file; /* index of the current file in the \.{mmo} output so far */
char filename_passed[256]; /* has a filename been recorded in the output? */

@ Here is a basic subroutine that assembles |k| bytes starting at |cur_loc|.
The value of |k| should be 1, 2, or~4, and |cur_loc| should be a multiple
of~|k|. The |x_bits| parameter tells which bytes, if any, are part of
a future reference.

@<Sub...@>=
void assemble @,@,@[ARGS((char,tetra,unsigned char))@];@+@t}\6{@>
void assemble(k,dat,x_bits)
  char k;
  tetra dat;
  unsigned char x_bits;
{
  register int j,jj,l;
  if (spec_mode) l=spec_mode_loc;
  else {
    l=cur_loc.l;
    @<Make sure |cur_loc| and |mmo_cur_loc| refer to the same tetrabyte@>;
    if (!held_bits && !(cur_loc.h&0xe0000000)) mmo_sync();
  }
  for (j=0;j<k;j++) {
    jj=(l+j)&3;
    hold_buf[jj]=(dat>>(8*(k-1-j)))&0xff;
    held_bits|=1<<jj;
    listing_bits|=1<<jj;
  }
  listing_bits|=x_bits;
  if (((l+k)&3)==0) {
    if (listing_file) listing_clear();
    mmo_clear();
  }
  if (spec_mode) spec_mode_loc+=k; else cur_loc=incr(cur_loc,k);
}

@ @<Make sure |cur_loc| and |mmo_cur_loc| refer to the same tetrabyte@>=
if (cur_loc.h!=mmo_cur_loc.h || ((cur_loc.l^mmo_cur_loc.l)&0xfffffffc))
  mmo_loc();

@* The symbol table. Symbols are stored and retrieved by means of
a {\it ternary search trie}, following ideas of Bentley and
Sedgewick. (See {\sl ACM--SIAM Symp.\ on Discrete Algorithms\/ \bf8} (1997),
360--369; R.~Sedgewick, {\sl Algorithms in C\/} (Reading, Mass.:\
Addison--Wesley, 1998), \S15.4.) Each trie node stores a character,
@^Bentley, Jon Louis@>
@^Sedgewick, Robert@>
and there are branches to subtries for the cases where a given character
is less than, equal to, or greater than the character in the trie.
There also is a pointer to a symbol table entry if a symbol ends at
the current node.

@s sym_tab_struct int

@<Type...@>=
typedef struct ternary_trie_struct {
  unsigned short ch; /* the (possibly wyde) character stored here */
  struct ternary_trie_struct *left, *mid, *right; /* downward
                                                 in the ternary trie */
  struct sym_tab_struct *sym; /* equivalents of symbols */
} trie_node;

@ We allocate trie nodes in chunks of 1000 at a time.

@<Sub...@>=
trie_node* new_trie_node @,@,@[ARGS((void))@];@+@t}\6{@>
trie_node* new_trie_node()
{
  register trie_node *t=next_trie_node;
  if (t==last_trie_node) {
    t=(trie_node*)calloc(1000,sizeof(trie_node));
    if (!t) panic("Capacity exceeded: Out of trie memory");
@.Capacity exceeded...@>
    last_trie_node=t+1000;
  }
  next_trie_node=t+1;
  return t;
}
  
@ @<Glob...@>=
trie_node *trie_root; /* root of the trie */
trie_node *op_root; /* root of subtrie for opcodes */
trie_node *next_trie_node, *last_trie_node; /* allocation control */
trie_node *cur_prefix; /* root of subtrie for unqualified symbols */

@ The |trie_search| subroutine starts at a given node of the trie and finds
a given string in its middle subtrie, inserting new nodes if necessary.
The string ends with the first nonletter or nondigit; the location
of the terminating character is stored in global variable~|terminator|. 

@d isletter(c) (isalpha(c)||c=='_'||c==':'||c>126)

@<Sub...@>=
trie_node *trie_search @,@,@[ARGS((trie_node*,Char*))@];
Char *terminator; /* where the search ended */
trie_node *trie_search(t,s)
  trie_node *t;
  Char *s;
{
  register trie_node *tt=t;
  register Char *p=s;
  while (1) {
    if (!isletter(*p) && !isdigit(*p)) {
      terminator=p;@+return tt;
    }
    if (tt->mid) {
      tt=tt->mid;
      while (*p!=tt->ch) {
        if (*p<tt->ch) {
          if (tt->left) tt=tt->left;
          else {
            tt->left=new_trie_node();@+tt=tt->left;@+goto store_new_char;
          }
        }@+else {
          if (tt->right) tt=tt->right;
          else {
            tt->right=new_trie_node();@+tt=tt->right;@+goto store_new_char;
          }
        }
      }
      p++;
    }@+else {
      tt->mid=new_trie_node();@+tt=tt->mid;
  store_new_char: tt->ch=*p++;
    }
  }
}

@ Symbol table nodes hold the serial numbers and
equivalents of defined symbols. They also
hold ``fixup information'' for undefined symbols; this will allow the
loader to correct any previously assembled instructions that refer to such
symbols when they are eventually defined.

In the symbol table node for a defined symbol, the |link| field
has one of the special codes |DEFINED| or |REGISTER| or |PREDEFINED|, and the
|equiv| field holds the defined value. The |serial| number
is a unique identifier for all user-defined symbols.

In the symbol table node for an undefined symbol, the |equiv| field
is ignored. The |link| field
points to the first node of fixup information; that node is, in turn,
a symbol table node that might link to other fixups. The |serial| number
in a fixup node is either 0 or 1 or 2, meaning respectively ``fixup the
octabyte pointed to by |equiv|'' or ``fixup the relative address in the YZ
field of the instruction pointed to by |equiv|'' or ``fixup the relative
address in the XYZ field of the instruction pointed to by |equiv|.''

@s sym_node int
@s bool int

@d DEFINED (sym_node*)1 /* code value for octabyte equivalents */
@d REGISTER (sym_node*)2 /* code value for register-number equivalents */
@d PREDEFINED (sym_node*)3 /* code value for not-yet-used equivalents */
@d fix_o 0 /* |serial| code for octabyte fixup */
@d fix_yz 1 /* |serial| code for relative fixup */
@d fix_xyz 2 /* |serial| code for \.{JMP} fixup */

@<Type...@>=
typedef struct sym_tab_struct {
  int serial; /* serial number of symbol; type number for fixups */
  struct sym_tab_struct *link; /* |DEFINED| status or link to fixup */
  octa equiv; /* the equivalent value */
} sym_node;

@ The allocation of new symbol table nodes proceeds in chunks, like the
allocation of trie nodes. But in this case we also have the possibility
of reusing old fixup nodes that are no longer needed.

@d recycle_fixup(pp) pp->link=sym_avail, sym_avail=pp

@<Sub...@>=
sym_node* new_sym_node @,@,@[ARGS((bool))@];@+@t}\6{@>
sym_node* new_sym_node(serialize)
  bool serialize; /* should the new node receive a unique serial number? */
{
  register sym_node *p=sym_avail;
  if (p) {
    sym_avail=p->link;@+p->link=NULL;@+p->serial=0;@+p->equiv=zero_octa;
  }@+else {
    p=next_sym_node;
    if (p==last_sym_node) {
      p=(sym_node*)calloc(1000,sizeof(sym_node));
      if (!p) panic("Capacity exceeded: Out of symbol memory");
@.Capacity exceeded...@>
      last_sym_node=p+1000;
    }
    next_sym_node=p+1;
  }
  if (serialize) p->serial=++serial_number;
  return p;
}
  
@ @<Glob...@>=
int serial_number;
sym_node *sym_root; /* root of the sym */
sym_node *next_sym_node, *last_sym_node; /* allocation control */
sym_node *sym_avail; /* stack of recycled symbol table nodes */

@ We initialize the trie by inserting all the predefined symbols.
Opcodes are given the prefix \.{\^}, to distinguish them from
ordinary symbols; this character nicely divides uppercase letters from
lowercase letters.

@<Init...@>=
trie_root=new_trie_node();
cur_prefix=trie_root;
op_root=new_trie_node();
trie_root->mid=op_root;
trie_root->ch=':';
op_root->ch='^';
@<Put the \MMIX\ opcodes and \MMIXAL\ pseudo-ops into the trie@>;
@<Put the special register names into the trie@>;
@<Put other predefined symbols into the trie@>;

@ Most of the assembly work can be table driven, based on bits that
are stored as the ``equivalents'' of opcode symbols like \.{\^ADD}.

@d rel_addr_bit 0x1 /* is YZ or XYZ relative? */
@d immed_bit 0x2 /* should opcode be immediate if Z or YZ not register? */
@d zar_bit 0x4 /* should register status of Z be ignored? */
@d zr_bit 0x8 /* must Z be a register? */
@d yar_bit 0x10 /* should register status of Y be ignored? */
@d yr_bit 0x20 /* must Y be a register? */
@d xar_bit 0x40 /* should register status of X be ignored? */
@d xr_bit 0x80 /* must X be a register? */
@d yzar_bit 0x100 /* should register status of YZ be ignored? */
@d yzr_bit 0x200 /* must YZ be a register? */
@d xyzar_bit 0x400 /* should register status of XYZ be ignored? */
@d xyzr_bit 0x800 /* must XYZ be a register? */
@d one_arg_bit 0x1000 /* is it OK to have zero or one operand? */
@d two_arg_bit 0x2000 /* is it OK to have exactly two operands? */
@d three_arg_bit 0x4000 /* is it OK to have exactly three operands? */
@d many_arg_bit 0x8000 /* is it OK to have more than three operands? */
@d align_bits 0x30000 /* how much alignment: byte, wyde, tetra, or octa? */
@d no_label_bit 0x40000 /* should the label be blank? */
@d mem_bit 0x80000 /* must YZ be a memory reference? */
@d spec_bit 0x100000 /* is this opcode allowed in \.{SPEC} mode? */

@<Type...@>=
typedef struct {
 Char *name; /* symbolic opcode */
 short code; /* numeric opcode */
 int bits; /* treatment of operands */
} op_spec;
@#
typedef enum {
@!SET=0x100,@!IS,@!LOC,@!PREFIX,@!BSPEC,@!ESPEC,@!GREG,@!LOCAL,@/
@!BYTE,@!WYDE,@!TETRA,@!OCTA}@+@!pseudo_op;

@ @<Glob...@>=
op_spec op_init_table[]={@/
{"TRAP", 0x00, 0x27554},
@.TRAP@>
{"FCMP", 0x01, 0x240a8},
@.FCMP@>
{"FUN", 0x02, 0x240a8},
@.FUN@>
{"FEQL", 0x03, 0x240a8},@/
@.FEQL@>
{"FADD", 0x04, 0x240a8},
@.FADD@>
{"FIX", 0x05, 0x26288},
@.FIX@>
{"FSUB", 0x06, 0x240a8},
@.FSUB@>
{"FIXU", 0x07, 0x26288},@/
@.FIXU@>
{"FLOT", 0x08, 0x26282},
@.FLOT@>
{"FLOTU", 0x0a, 0x26282},
@.FLOTU@>
{"SFLOT", 0x0c, 0x26282},
@.SFLOT@>
{"SFLOTU", 0x0e, 0x26282},@/
@.SFLOTU@>
{"FMUL", 0x10, 0x240a8},
@.FMUL@>
{"FCMPE", 0x11, 0x240a8},
@.FCMPE@>
{"FUNE", 0x12, 0x240a8},
@.FUNE@>
{"FEQLE", 0x13, 0x240a8},@/
@.FEQLE@>
{"FDIV", 0x14, 0x240a8},
@.FDIV@>
{"FSQRT", 0x15, 0x26288},
@.FSQRT@>
{"FREM", 0x16, 0x240a8},
@.FREM@>
{"FINT", 0x17, 0x26288},@/
@.FINT@>
{"MUL", 0x18, 0x240a2},
@.MUL@>
{"MULU", 0x1a, 0x240a2},
@.MULU@>
{"DIV", 0x1c, 0x240a2},
@.DIV@>
{"DIVU", 0x1e, 0x240a2},@/
@.DIVU@>
{"ADD", 0x20, 0x240a2},
@.ADD@>
{"ADDU", 0x22, 0x240a2},
@.ADDU@>
{"SUB", 0x24, 0x240a2},
@.SUB@>
{"SUBU", 0x26, 0x240a2},@/
@.SUBU@>
{"2ADDU", 0x28, 0x240a2},
@.2ADDU@>
{"4ADDU", 0x2a, 0x240a2},
@.4ADDU@>
{"8ADDU", 0x2c, 0x240a2},
@.8ADDU@>
{"16ADDU", 0x2e, 0x240a2},@/
@.16ADDU@>
{"CMP", 0x30, 0x240a2},
@.CMP@>
{"CMPU", 0x32, 0x240a2},
@.CMPU@>
{"NEG", 0x34, 0x26082},
@.NEG@>
{"NEGU", 0x36, 0x26082},@/
@.NEGU@>
{"SL", 0x38, 0x240a2},
@.SL@>
{"SLU", 0x3a, 0x240a2},
@.SLU@>
{"SR", 0x3c, 0x240a2},
@.SR@>
{"SRU", 0x3e, 0x240a2},@/
@.SRU@>
{"BN", 0x40, 0x22081},
@.BN@>
{"BZ", 0x42, 0x22081},
@.BZ@>
{"BP", 0x44, 0x22081},
@.BP@>
{"BOD", 0x46, 0x22081},@/
@.BOD@>
{"BNN", 0x48, 0x22081},
@.BNN@>
{"BNZ", 0x4a, 0x22081},
@.BNZ@>
{"BNP", 0x4c, 0x22081},
@.BNP@>
{"BEV", 0x4e, 0x22081},@/
@.BEV@>
{"PBN", 0x50, 0x22081},
@.PBN@>
{"PBZ", 0x52, 0x22081},
@.PBZ@>
{"PBP", 0x54, 0x22081},
@.PBP@>
{"PBOD", 0x56, 0x22081},@/
@.PBOD@>
{"PBNN", 0x58, 0x22081},
@.PBNN@>
{"PBNZ", 0x5a, 0x22081},
@.PBNZ@>
{"PBNP", 0x5c, 0x22081},
@.PBNP@>
{"PBEV", 0x5e, 0x22081},@/
@.PBEV@>
{"CSN", 0x60, 0x240a2},
@.CSN@>
{"CSZ", 0x62, 0x240a2},
@.CSZ@>
{"CSP", 0x64, 0x240a2},
@.CSP@>
{"CSOD", 0x66, 0x240a2},@/
@.CSOD@>
{"CSNN", 0x68, 0x240a2},
@.CSNN@>
{"CSNZ", 0x6a, 0x240a2},
@.CSNZ@>
{"CSNP", 0x6c, 0x240a2},
@.CSNP@>
{"CSEV", 0x6e, 0x240a2},@/
@.CSEV@>
{"ZSN", 0x70, 0x240a2},
@.ZSN@>
{"ZSZ", 0x72, 0x240a2},
@.ZSZ@>
{"ZSP", 0x74, 0x240a2},
@.ZSP@>
{"ZSOD", 0x76, 0x240a2},@/
@.ZSOD@>
{"ZSNN", 0x78, 0x240a2},
@.ZSNN@>
{"ZSNZ", 0x7a, 0x240a2},
@.ZSNZ@>
{"ZSNP", 0x7c, 0x240a2},
@.ZSNP@>
{"ZSEV", 0x7e, 0x240a2},@/
@.ZSEV@>
{"LDB", 0x80, 0xa60a2},
@.LDB@>
{"LDBU", 0x82, 0xa60a2},
@.LDBU@>
{"LDW", 0x84, 0xa60a2},
@.LDW@>
{"LDWU", 0x86, 0xa60a2},@/
@.LDWU@>
{"LDT", 0x88, 0xa60a2},
@.LDT@>
{"LDTU", 0x8a, 0xa60a2},
@.LDTU@>
{"LDO", 0x8c, 0xa60a2},
@.LDO@>
{"LDOU", 0x8e, 0xa60a2},@/
@.LDOU@>
{"LDSF", 0x90, 0xa60a2},
@.LDSF@>
{"LDHT", 0x92, 0xa60a2},
@.LDHT@>
{"CSWAP", 0x94, 0xa60a2},
@.CSWAP@>
{"LDUNC", 0x96, 0xa60a2},@/
@.LDUNC@>
{"LDVTS", 0x98, 0xa60a2},
@.LDVTS@>
{"PRELD", 0x9a, 0xa6022},
@.PRELD@>
{"PREGO", 0x9c, 0xa6022},
@.PREGO@>
{"GO", 0x9e, 0xa60a2},@/
@.GO@>
{"STB", 0xa0, 0xa60a2},
@.STB@>
{"STBU", 0xa2, 0xa60a2},
@.STBU@>
{"STW", 0xa4, 0xa60a2},
@.STW@>
{"STWU", 0xa6, 0xa60a2},@/
@.STWU@>
{"STT", 0xa8, 0xa60a2},
@.STT@>
{"STTU", 0xaa, 0xa60a2},
@.STTU@>
{"STO", 0xac, 0xa60a2},
@.STO@>
{"STOU", 0xae, 0xa60a2},@/
@.STOU@>
{"STSF", 0xb0, 0xa60a2},
@.STSF@>
{"STHT", 0xb2, 0xa60a2},
@.STHT@>
{"STCO", 0xb4, 0xa6022},
@.STCO@>
{"STUNC", 0xb6, 0xa60a2},@/
@.STUNC@>
{"SYNCD", 0xb8, 0xa6022},
@.SYNCD@>
{"PREST", 0xba, 0xa6022},
@.PREST@>
{"SYNCID", 0xbc, 0xa6022},
@.SYNCID@>
{"PUSHGO", 0xbe, 0xa6062},@/
@.PUSHGO@>
{"OR", 0xc0, 0x240a2},
@.OR@>
{"ORN", 0xc2, 0x240a2},
@.ORN@>
{"NOR", 0xc4, 0x240a2},
@.NOR@>
{"XOR", 0xc6, 0x240a2},@/
@.XOR@>
{"AND", 0xc8, 0x240a2},
@.AND@>
{"ANDN", 0xca, 0x240a2},
@.ANDN@>
{"NAND", 0xcc, 0x240a2},
@.NAND@>
{"NXOR", 0xce, 0x240a2},@/
@.NXOR@>
{"BDIF", 0xd0, 0x240a2},
@.BDIF@>
{"WDIF", 0xd2, 0x240a2},
@.WDIF@>
{"TDIF", 0xd4, 0x240a2},
@.TDIF@>
{"ODIF", 0xd6, 0x240a2},@/
@.ODIF@>
{"MUX", 0xd8, 0x240a2},
@.MUX@>
{"SADD", 0xda, 0x240a2},
@.SADD@>
{"MOR", 0xdc, 0x240a2},
@.MOR@>
{"MXOR", 0xde, 0x240a2},@/
@.MXOR@>
{"SETH", 0xe0, 0x22080},
@.SETH@>
{"SETMH", 0xe1, 0x22080},
@.SETMH@>
{"SETML", 0xe2, 0x22080},
@.SETML@>
{"SETL", 0xe3, 0x22080},@/
@.SETL@>
{"INCH", 0xe4, 0x22080},
@.INCH@>
{"INCMH", 0xe5, 0x22080},
@.INCMH@>
{"INCML", 0xe6, 0x22080},
@.INCML@>
{"INCL", 0xe7, 0x22080},@/
@.INCL@>
{"ORH", 0xe8, 0x22080},
@.ORH@>
{"ORMH", 0xe9, 0x22080},
@.ORMH@>
{"ORML", 0xea, 0x22080},
@.ORML@>
{"ORL", 0xeb, 0x22080},@/
@.ORL@>
{"ANDNH", 0xec, 0x22080},
@.ANDNH@>
{"ANDNMH", 0xed, 0x22080},
@.ANDNMH@>
{"ANDNML", 0xee, 0x22080},
@.ANDNML@>
{"ANDNL", 0xef, 0x22080},@/
@.ANDNL@>
{"JMP", 0xf0, 0x21001},
@.JMP@>
{"PUSHJ", 0xf2, 0x22041},
@.PUSHJ@>
{"GETA", 0xf4, 0x22081},
@.GETA@>
{"PUT", 0xf6, 0x22002},@/
@.PUT@>
{"POP", 0xf8, 0x23000},
@.POP@>
{"RESUME", 0xf9, 0x21000},
@.RESUME@>
{"SAVE", 0xfa, 0x22080},
@.SAVE@>
{"UNSAVE", 0xfb, 0x23a00},@/
@.UNSAVE@>
{"SYNC", 0xfc, 0x21000},
@.SYNC@>
{"SWYM", 0xfd, 0x27554},
@.SWYM@>
{"GET", 0xfe, 0x22080},
@.GET@>
{"TRIP", 0xff, 0x27554},@/
@.TRIP@>
{"SET",SET, 0x22180},
@.SET@>
{"LDA", 0x22, 0xa60a2},@/
@.LDA@>
{"IS", IS, 0x101400},
@.IS@>
{"LOC", LOC, 0x1400},
@.LOC@>
{"PREFIX", PREFIX, 0x141000},@/
@.PREFIX@>
{"BYTE", BYTE, 0x10f000},
@.BYTE@>
{"WYDE", WYDE, 0x11f000},
@.WYDE@>
{"TETRA", TETRA, 0x12f000},
@.TETRA@>
{"OCTA", OCTA, 0x13f000},@/
@.OCTA@>
{"BSPEC", BSPEC, 0x41400},
@.BSPEC@>
{"ESPEC", ESPEC, 0x141000},@/
@.ESPEC@>
{"GREG", GREG, 0x101000},
@.GREG@>
{"LOCAL", LOCAL, 0x141800}};
@.LOCAL@>
int op_init_size; /* the number of items in |op_init_table| */

@ @<Put the \MMIX\ opcodes and \MMIXAL\ pseudo-ops into the trie@>=
op_init_size=(sizeof op_init_table)/sizeof(op_spec);
for (j=0;j<op_init_size;j++) {
  tt=trie_search(op_root,op_init_table[j].name);
  pp=tt->sym=new_sym_node(false);
  pp->link=PREDEFINED;
  pp->equiv.h=op_init_table[j].code, pp->equiv.l=op_init_table[j].bits;
}

@ @<Local...@>=
register trie_node *tt;
register sym_node *pp,*qq;

@ @<Put the special register names into the trie@>=
for (j=0;j<32;j++) {
  tt=trie_search(trie_root,special_name[j]);
  pp=tt->sym=new_sym_node(false);
  pp->link=PREDEFINED;
  pp->equiv.l=j;
}

@ @<Glob...@>=
Char *special_name[32]={"rB","rD","rE","rH","rJ","rM","rR","rBB",
 "rC","rN","rO","rS","rI","rT","rTT","rK","rQ","rU","rV","rG","rL",
 "rA","rF","rP","rW","rX","rY","rZ","rWW","rXX","rYY","rZZ"};
@^predefined symbols@>

@ @<Type...@>=
typedef struct {
  Char* name;
  tetra h,l;
}@+predef_spec;

@ @<Glob...@>=
predef_spec predefs[]={
{"ROUND_CURRENT",0,0},
@:ROUND_CURRENT}\.{ROUND\_CURRENT@>
{"ROUND_OFF",0,1},
@:ROUND_OFF}\.{ROUND\_OFF@>
{"ROUND_UP",0,2},
@:ROUND_UP}\.{ROUND\_UP@>
{"ROUND_DOWN",0,3},
@:ROUND_DOWN}\.{ROUND\_DOWN@>
{"ROUND_NEAR",0,4},@/
@:ROUND_NEAR}\.{ROUND\_NEAR@>
{"Inf",0x7ff00000,0},@/
@.Inf@>
{"Data_Segment",0x20000000,0},
@:Data_Segment}\.{Data\_Segment@>
{"Pool_Segment",0x40000000,0},
@:Pool_Segment}\.{Pool\_Segment@>
{"Stack_Segment",0x60000000,0},@/
@:Stack_Segment}\.{Stack\_Segment@>
{"D_BIT",0,0x80},
@:D_BIT}\.{D\_BIT@>
{"V_BIT",0,0x40},
@:V_BIT}\.{V\_BIT@>
{"W_BIT",0,0x20},
@:W_BIT}\.{W\_BIT@>
{"I_BIT",0,0x10},
@:I_BIT}\.{I\_BIT@>
{"O_BIT",0,0x08},
@:O_BIT}\.{O\_BIT@>
{"U_BIT",0,0x04},
@:U_BIT}\.{U\_BIT@>
{"Z_BIT",0,0x02},
@:Z_BIT}\.{Z\_BIT@>
{"X_BIT",0,0x01},@/
@:X_BIT}\.{X\_BIT@>
{"D_Handler",0,0x10},
@:D_Handler}\.{D\_Handler@>
{"V_Handler",0,0x20},
@:V_Handler}\.{V\_Handler@>
{"W_Handler",0,0x30},
@:W_Handler}\.{W\_Handler@>
{"I_Handler",0,0x40},
@:I_Handler}\.{I\_Handler@>
{"O_Handler",0,0x50},
@:O_Handler}\.{O\_Handler@>
{"U_Handler",0,0x60},
@:U_Handler}\.{U\_Handler@>
{"Z_Handler",0,0x70},
@:Z_Handler}\.{Z\_Handler@>
{"X_Handler",0,0x80},@/
@:X_Handler}\.{X\_Handler@>
{"StdIn",0,0},
@.StdIn@>
{"StdOut",0,1},
@.StdOut@>
{"StdErr",0,2},@/
@.StdErr@>
{"TextRead",0,0},
@.TextRead@>
{"TextWrite",0,1},
@.TextWrite@>
{"BinaryRead",0,2},
@.BinaryRead@>
{"BinaryWrite",0,3},
@.BinaryWrite@>
{"BinaryReadWrite",0,4},@/
@.BinaryReadWrite@>
{"Halt",0,0},
@.Halt@>
{"Fopen",0,1},
@.Fopen@>
{"Fclose",0,2},
@.Fclose@>
{"Fread",0,3},
@.Fread@>
{"Fgets",0,4},
@.Fgets@>
{"Fgetws",0,5},
@.Fgetws@>
{"Fwrite",0,6},
@.Fwrite@>
{"Fputs",0,7},
@.Fputs@>
{"Fputws",0,8},
@.Fputws@>
{"Fseek",0,9},
@.Fseek@>
{"Ftell",0,10}};
@.Ftell@>
int predef_size;
@^predefined symbols@>

@ @<Put other predefined symbols into the trie@>=
predef_size=(sizeof predefs)/sizeof(predef_spec);
for (j=0;j<predef_size;j++) {
  tt=trie_search(trie_root,predefs[j].name);
  pp=tt->sym=new_sym_node(false);
  pp->link=PREDEFINED;
  pp->equiv.h=predefs[j].h, pp->equiv.l=predefs[j].l;
}

@ We place \.{Main} into the trie at the beginning of assembly,
so that it will show up as an undefined symbol if the user
specifies no starting point.
@.Main@>

@<Init...@>=
trie_search(trie_root,"Main")->sym=new_sym_node(true);

@ At the end of assembly we traverse the entire symbol table, visiting each
symbol in lexicographic order and transmitting the trie structure to the
output file. We detect any undefined future references at this time.

The order of traversal has a simple recursive pattern: To traverse the subtrie
rooted at~|t|, we
$$\vbox{\halign{#\hfil\cr
traverse |t->left|, if the left subtrie is nonempty;\cr
visit |t->sym|, if this symbol table entry is present;\cr
traverse |t->mid|, if the middle subtrie is nonempty;\cr
traverse |t->right|, if the right subtrie is nonempty.\cr
}}$$
This pattern leads to a compact representation in the \.{mmo} file, usually
requiring fewer than two bytes per trie node plus the bytes needed to encode
the equivalents and serial numbers. Each node of the trie is encoded as a
``master byte'' followed by the encodings of the left subtrie, 
character, equivalent, middle subtrie, and right subtrie.
The master byte is the sum of
$$\vbox{\halign{#\hfil\cr
\Hex{80}, if the character occupies two bytes instead of one;\cr
\Hex{40}, if the left subtrie is nonempty;\cr
\Hex{20}, if the middle subtrie is nonempty;\cr
\Hex{10}, if the right subtrie is nonempty;\cr
\Hex{01} to \Hex{08}, if the symbol's equivalent is one to eight bytes long;\cr
\Hex{09} to \Hex{0e}, if the symbol's equivalent is $2^{61}$ plus one
  to six bytes;\cr
\Hex{0f}, if the symbol's equivalent is \$0 plus one byte;\cr}}$$
the character is omitted if the middle subtrie and the equivalent are
both empty. The ``equivalent'' of an undefined symbol is zero, but
stated as two bytes long.
Symbol equivalents are followed by the serial number, represented as a
sequence of one or more bytes in radix~128; the final byte of the serial
number is tagged by adding~128. (Thus, serial number $2^{14}-1$ is
encoded as \Hex{7fff}; serial number $2^{14}$ is \Hex{010080}.)

@ First we prune the trie by removing all predefined symbols that the
user did not redefine.

@<Sub...@>=
trie_node* prune @,@,@[ARGS((trie_node*))@];@+@t}\6{@>
trie_node* prune(t)
  trie_node* t;
{
  register int useful=0;
  if (t->sym) {
    if (t->sym->serial) useful=1;
    else t->sym=NULL;
  }
  if (t->left) {
    t->left=prune(t->left);
    if (t->left) useful=1;
  }
  if (t->mid) {
    t->mid=prune(t->mid);
    if (t->mid) useful=1;
  }
  if (t->right) {
    t->right=prune(t->right);
    if (t->right) useful=1;
  }
  if (useful) return t;
  else return NULL;
}

@ Then we output the trie by following the recursive traversal pattern.

@<Sub...@>=
void out_stab @,@,@[ARGS((trie_node*))@];@+@t}\6{@>
void out_stab(t)
  trie_node* t;
{
  register int m=0,j;
  register sym_node *pp;
  if (t->ch>0xff) m+=0x80;
  if (t->left) m+=0x40;
  if (t->mid) m+=0x20;
  if (t->right) m+=0x10;
  if (t->sym) {
    if (t->sym->link==REGISTER) m+=0xf;
    else if (t->sym->link==DEFINED)
      @<Encode the length of |t->sym->equiv|@>@;
    else if (t->sym->link || t->sym->serial==1) @<Report an undefined symbol@>;
  }
  mmo_byte(m);
  if (t->left) out_stab(t->left);
  if (m&0x2f) @<Visit |t| and traverse |t->mid|@>;
  if (t->right) out_stab(t->right);
}

@ A global variable called |sym_buf| holds all characters on middle branches to
the current trie node; |sym_ptr| is the first currently unused
character in |sym_buf|.
@^Unicode@>

@<Visit |t| and traverse |t->mid|@>=
{
  if (m&0x80) mmo_byte(t->ch>>8);
  mmo_byte(t->ch&0xff);
  *sym_ptr++=(m&0x80? '?': t->ch); /* Unicode? not yet */
  m&=0xf;@+ if (m && t->sym->link) {
    if (listing_file) @<Print symbol |sym_buf| and its equivalent@>;
    if (m==15) m=1;
    else if (m>8) m-=8;
    for (;m>0;m--)
      if (m>4) mmo_byte((t->sym->equiv.h>>(8*(m-5)))&0xff);
      else mmo_byte((t->sym->equiv.l>>(8*(m-1)))&0xff);
    for (m=0;m<4;m++) if (t->sym->serial<(1<<(7*(m+1)))) break;
    for (;m>=0;m--)
      mmo_byte(((t->sym->serial>>(7*m))&0x7f)+(m? 0: 0x80));
  }
  if (t->mid) out_stab(t->mid);
  sym_ptr--;
}

@ @<Encode the length of |t->sym->equiv|@>=
{@+register tetra x;
  if ((t->sym->equiv.h&0xffff0000)==0x20000000)
    m+=8, x=t->sym->equiv.h-0x20000000; /* data segment */
  else x=t->sym->equiv.h;
  if (x) m+=4;@+ else x=t->sym->equiv.l;
  for (j=1;j<4;j++) if (x<(1<<(8*j))) break;
  m+=j;
}

@ We make room for symbols up to 999 bytes long. Strictly speaking,
the program should check if this limit is exceeded; but really!

@<Glob...@>=
Char sym_buf[1000];
Char *sym_ptr;

@ The initial `\.:' of each fully qualified symbol is omitted here, since most
users of \MMIXAL\ will probably not need the \.{PREFIX} feature. One
consequence of this omission is that the one-character symbol~`\.:'
itself, which is allowed by the rules of \MMIXAL, is printed as the null
string.

@<Print symbol |sym_buf| and its equivalent@>=
{
  *sym_ptr='\0';
  fprintf(listing_file," %s = ",sym_buf+1);
  pp=t->sym;
  if (pp->link==DEFINED)
    fprintf(listing_file,"#%08x%08x",pp->equiv.h,pp->equiv.l);
  else if (pp->link==REGISTER)
    fprintf(listing_file,"$%03d",pp->equiv.l);
  else fprintf(listing_file,"?");
  fprintf(listing_file," (%d)\n",pp->serial);
}

@ @<Report an undefined symbol@>=
{
  *sym_ptr=(m&0x80? '?': t->ch); /* Unicode? not yet */
  *(sym_ptr+1)='\0';
  fprintf(stderr,"undefined symbol: %s\n",sym_buf+1);
@.undefined symbol@>
  err_count++;
  m+=2;
}

@ @<Check and output the trie@>=
op_root->mid=NULL; /* annihilate all the opcodes */
prune(trie_root);
sym_ptr=sym_buf;
if (listing_file) fprintf(listing_file,"\nSymbol table:\n");
mmo_lop(lop_stab,0,0);
out_stab(trie_root);
while (mmo_ptr&3) mmo_byte(0);
mmo_lopp(lop_end,mmo_ptr>>2);

@* Expressions. The most intricate part of the assembly process is
the task of scanning and evaluating expressions in the operand field.
Fortunately, \MMIXAL's expressions have a simple structure that can
be handled easily with a stack-based approach.

Two stacks hold pending data as the operand field is scanned and evaluated.
The |op_stack| contains operators that have not yet been performed; the
|val_stack| contains values that have not yet been used. After an entire
operand list has been scanned, the |op_stack| will be empty and the
|val_stack| will hold the operand values needed to assemble the current
instruction.

@ Entries on |op_stack| have one of the constant values defined here, and they
have one of the precedence levels defined here.

Entries on |val_stack| have |equiv|, |link|, and |status| fields; the |link|
points to a trie node if the expression is a symbol that has not yet
been subjected to any operations.

@<Type...@>=
typedef enum {@!negate,@!serialize,@!complement,@!registerize,@!inner_lp,@|
 @!plus,@!minus,@!times,@!over,@!frac,@!mod,@!shl,@!shr,@!and,@!or,@!xor,@|
 @!outer_lp,@!outer_rp,@!inner_rp} @!stack_op;
typedef enum {@!zero,@!weak,@!strong,@!unary} @!prec;
typedef enum {@!pure,@!reg_val,@!undefined} @!stat;
typedef struct {
  octa equiv; /* current value */
  trie_node *link; /* trie reference for symbol */
  stat status; /* |pure|, |reg_val|, or |undefined| */
} val_node;

@ @d top_op op_stack[op_ptr-1] /* top entry on the operator stack */
@d top_val val_stack[val_ptr-1] /* top entry on the value stack */
@d next_val val_stack[val_ptr-2] /* next-to-top entry of the value stack */

@<Glob...@>=
stack_op *op_stack; /* stack for pending operators */
int op_ptr; /* number of items on |op_stack| */
val_node *val_stack; /* stack for pending operands */
int val_ptr; /* number of items on |val_stack| */
prec precedence[]={unary,unary,unary,unary,zero,@|
 weak,weak,strong,strong,strong,strong,strong,strong,strong,weak,weak,@|
 zero,zero,zero}; /* precedences of the respective |stack_op| values */
stack_op rt_op; /* newly scanned operator */
octa acc; /* temporary accumulator */

@ @<Init...@>=
op_stack=(stack_op*)calloc(buf_size,sizeof(stack_op));
val_stack=(val_node*)calloc(buf_size,sizeof(val_node));
if (!op_stack || !val_stack) panic("No room for the stacks");
@.No room...@>

@ The operand field of an instruction will have been copied into a separate
\&{Char} array called |operand_list| when we reach this part of the program.

@<Scan the operand field@>=
p=operand_list;
val_ptr=0; /* |val_stack| is empty */
op_stack[0]=outer_lp, op_ptr=1;
   /* |op_stack| contains an ``outer left parenthesis'' */
while (1) {
  @<Scan opening tokens until putting something on |val_stack|@>;
 scan_close: @<Scan a binary operator or closing token, |rt_op|@>;
  while (precedence[top_op]>=precedence[rt_op])
    @<Perform the top operation on |op_stack|@>;
 hold_op: op_stack[op_ptr++]=rt_op;
}
operands_done:@;

@ A comment that follows an empty operand list needs to be detected here.

@<Scan opening tokens until putting something on |val_stack|@>=
scan_open:@+if (isletter(*p)) @<Scan a symbol@>@;
else if (isdigit(*p)) {
  if (*(p+1)=='F') @<Scan a forward local@>@;
  else if (*(p+1)=='B') @<Scan a backward local@>@;
  else @<Scan a decimal constant@>;
}@+else@+ switch(*p++) {
 case '#': @<Scan a hexadecimal constant@>;@+break;
 case '\'': @<Scan a character constant@>;@+break;
 case '\"': @<Scan a string constant@>;@+break;
 case '@@': @<Scan the current location@>;@+break;
 case '-': op_stack[op_ptr++]=negate;
 case '+': goto scan_open;
 case '&': op_stack[op_ptr++]=serialize;@+goto scan_open;
 case '~': op_stack[op_ptr++]=complement;@+goto scan_open;
 case '$': op_stack[op_ptr++]=registerize;@+goto scan_open;
 case '(': op_stack[op_ptr++]=inner_lp;@+goto scan_open;
 default: if (p==operand_list+1) { /* treat operand list as empty */
    operand_list[0]='0', operand_list[1]='\0', p=operand_list;
    goto scan_open;
  }
 if (*(p-1)) derr("syntax error at character `%c'",*(p-1));
 derr("syntax error after character `%c'",*(p-2));
@.syntax error...@>
}

@ @<Scan a symbol@>=
{
  if (*p==':') tt=trie_search(trie_root,p+1);
  else tt=trie_search(cur_prefix,p);
  p=terminator;
 symbol_found: val_ptr++;
  pp=tt->sym;
  if (!pp) pp=tt->sym=new_sym_node(true);
  top_val.link=tt, top_val.equiv=pp->equiv;
  if (pp->link==PREDEFINED) pp->link=DEFINED;
  top_val.status=(pp->link==DEFINED? pure: pp->link==REGISTER? reg_val:
      undefined);
}

@ @<Scan a forward local@>=
{
  tt=&forward_local_host[*p-'0'];@+ p+=2;@+ goto symbol_found;
}

@ @<Scan a backward local@>=
{
  tt=&backward_local_host[*p-'0'];@+ p+=2;@+ goto symbol_found;
}

@ Statically allocated variables |forward_local_host[j]| and
|backward_local_host[j]| masquerade as nodes of the trie.

@<Glob...@>=
trie_node forward_local_host[10], backward_local_host[10];
sym_node forward_local[10], backward_local[10];

@ Initially \.{0H}, \.{1H}, \dots, \.{9H} are defined to be zero.

@<Init...@>=
for (j=0;j<10;j++) {
  forward_local_host[j].sym=&forward_local[j];
  backward_local_host[j].sym=&backward_local[j];
  backward_local[j].link=DEFINED;
}

@ We have already checked to make sure that the character constant is legal.

@<Scan a character constant@>=
acc.h=0, acc.l=*p;
p+=2;
goto constant_found;

@ @<Scan a string constant@>=
acc.h=0, acc.l=*p;
if (*p=='\"') {
  p++; acc.l=0; err("*null string is treated as zero");
@.null string...@>
}@+else if (*(p+1)=='\"') p+=2;
else *p='\"', *--p=',';
goto constant_found;

@ @<Scan a decimal constant@>=
acc.h=0, acc.l=*p-'0';
for (p++;isdigit(*p);p++) {
  acc=oplus(acc,shift_left(acc,2));
  acc=incr(shift_left(acc,1),*p-'0');
}
constant_found: val_ptr++;
top_val.link=NULL;
top_val.equiv=acc;
top_val.status=pure;

@ @<Scan a hexadecimal constant@>=
if (!isxdigit(*p)) err("illegal hexadecimal constant");
@.illegal hexadecimal constant@>
acc.h=acc.l=0;
for (;isxdigit(*p);p++) {
  acc=incr(shift_left(acc,4),*p-'0');
  if (*p>='a') acc=incr(acc,'0'-'a'+10);
  else if (*p>='A') acc=incr(acc,'0'-'A'+10);
}
goto constant_found;

@ @<Scan the current location@>=
acc=cur_loc;
goto constant_found;

@ @<Scan a binary operator or closing token, |rt_op|@>=
switch(*p++) {
 case '+': rt_op=plus;@+break;
 case '-': rt_op=minus;@+break;
 case '*': rt_op=times;@+break;
 case '/':@+if (*p!='/') rt_op=over;
   else p++,rt_op=frac;@+break;
 case '%': rt_op=mod;@+break;
 case '<': rt_op=shl;@+goto sh_check;
 case '>': rt_op=shr;
  sh_check:@+if (*p++==*(p-1)) break;
  derr("syntax error at `%c'",*(p-2));
@.syntax error...@>
 case '&': rt_op=and;@+break;
 case '|': rt_op=or;@+break;
 case '^': rt_op=xor;@+break;
 case ')': rt_op=inner_rp;@+break;
 case '\0': case ',': rt_op=outer_rp;@+break;
 default: derr("syntax error at `%c'",*(p-1));
}

@ @<Perform the top operation on |op_stack|@>=
switch(op_stack[--op_ptr]) {
 case inner_lp:@+if (rt_op==inner_rp) goto scan_close;
  err("*missing right parenthesis");@+break;
@.missing right parenthesis@>
 case outer_lp:@+if (rt_op==outer_rp) {
     if (top_val.status==reg_val && (top_val.equiv.l>0xff||top_val.equiv.h)) {
       err("*register number too large, will be reduced mod 256");
@.register number...@>
       top_val.equiv.h=0, top_val.equiv.l &= 0xff;
     }
     if (!*(p-1)) goto operands_done;
     else rt_op=outer_lp;@+goto hold_op; /* comma */ 
   }@+else {
     op_ptr++;
     err("*missing left parenthesis");
@.missing left parenthesis@>
     goto scan_close;
   }
 @t\4@>@<Cases for unary operators@>@;
 @t\4@>@<Cases for binary operators@>@;
}

@ Now we come to the part where equivalents are changed by unary
or binary operators found in the expression being scanned.

The most typical operator, and in some ways the fussiest one
to deal with, is binary addition. Once we've written the code for
this case, the other cases almost take care of themselves.

@<Cases for binary...@>=
case plus:@+if (top_val.status==undefined)
  err("cannot add an undefined quantity");
@.cannot add...@>
 if (next_val.status==undefined)
  err("cannot add to an undefined quantity");
 if (top_val.status==reg_val && next_val.status==reg_val)
  err("cannot add two register numbers");
 next_val.equiv=oplus(next_val.equiv,top_val.equiv);
 fin_bin: next_val.status=(top_val.status==next_val.status? pure: reg_val);
 val_ptr--;
 delink: top_val.link=NULL;@+break;

@ @d unary_check(verb) if (top_val.status!=pure)
                 derr("can %s pure values only",verb)

@<Cases for unary...@>=
case negate: unary_check("negate");
@.can negate...@>
 top_val.equiv=ominus(zero_octa,top_val.equiv);@+goto delink;
case complement: unary_check("complement");
@.can complement...@>
 top_val.equiv.h=~top_val.equiv.h, top_val.equiv.l=~top_val.equiv.l;
 goto delink;
case registerize: unary_check("registerize");
@.can registerize...@>
 top_val.status=reg_val;@+goto delink;
case serialize:@+if (!top_val.link)
   err("can take serial number of symbol only");
@.can take serial number...@>
 top_val.equiv.h=0, top_val.equiv.l=top_val.link->sym->serial;
 top_val.status=pure;@+goto delink;

@ @d binary_check(verb)
    if (top_val.status!=pure || next_val.status!=pure)
      derr("can %s pure values only",verb)

@<Cases for binary...@>=
case minus:@+if (top_val.status==undefined)
  err("cannot subtract an undefined quantity");
@.cannot subtract...@>
 if (next_val.status==undefined)
  err("cannot subtract from an undefined quantity");
 if (top_val.status==reg_val && next_val.status!=reg_val)
  err("cannot subtract register number from pure value");
 next_val.equiv=ominus(next_val.equiv,top_val.equiv);@+goto fin_bin;
case times: binary_check("multiply");
@.can multiply...@>
  next_val.equiv=omult(next_val.equiv,top_val.equiv);@+goto fin_bin;
case over: case mod: binary_check("divide");
@.can divide...@>
 if (top_val.equiv.l==0 && top_val.equiv.h==0)
   err("*division by zero");
@.division by zero@>
 next_val.equiv=odiv(zero_octa,next_val.equiv,top_val.equiv);
 if (op_stack[op_ptr]==mod) next_val.equiv=aux;
 goto fin_bin;
case frac: binary_check("compute a ratio of");
@.can compute...@>
 if (next_val.equiv.h>=top_val.equiv.h &&
  (next_val.equiv.l>=top_val.equiv.l || next_val.equiv.h>top_val.equiv.h))
    err("*illegal fraction");
@.illegal fraction@>
 next_val.equiv=odiv(next_val.equiv,zero_octa,top_val.equiv);@+goto fin_bin;
case shl: case shr: binary_check("compute a bitwise shift of");
 if (top_val.equiv.h || top_val.equiv.l>63) next_val.equiv=zero_octa;
 else if (op_stack[op_ptr]==shl)
   next_val.equiv=shift_left(next_val.equiv,top_val.equiv.l);
 else next_val.equiv=shift_right(next_val.equiv,top_val.equiv.l,true);
 goto fin_bin;
case and: binary_check("compute bitwise and of");
 next_val.equiv.h&=top_val.equiv.h, next_val.equiv.l&=top_val.equiv.l;
 goto fin_bin;
case or: binary_check("compute bitwise or of");
 next_val.equiv.h|=top_val.equiv.h, next_val.equiv.l|=top_val.equiv.l;
 goto fin_bin;
case xor: binary_check("compute bitwise xor of");
 next_val.equiv.h^=top_val.equiv.h, next_val.equiv.l^=top_val.equiv.l;
 goto fin_bin;

@* Assembling an instruction.
Now let's move up from the expression level to the instruction level. We get to
this part of the program at the beginning of a line, or after a
semicolon at the end of an instruction earlier on the current line.
Our current position in the buffer is the value of |buf_ptr|.

@<Process the next \MMIXAL\ instruction or comment@>=
p=buf_ptr;@+ buf_ptr="";
@<Scan the label field; |goto bypass| if there is none@>;
@<Scan the opcode field; |goto bypass| if there is none@>;
@<Copy the operand field@>;
buf_ptr=p;
if (spec_mode && !(op_bits&spec_bit))
  derr("cannot use `%s' in special mode",op_field);
@.cannot use...@>
if ((op_bits&no_label_bit) && lab_field[0]) {
  derr("*label field of `%s' instruction is ignored",op_field);
  lab_field[0]='\0';
}
@.label field...ignored@>
if (op_bits&align_bits) @<Align the location pointer@>;
@<Scan the operand field@>;
if (opcode==GREG) @<Allocate a global register@>;
if (lab_field[0]) @<Define the label@>;
@<Do the operation@>;
bypass:@;

@ @<Scan the label field; |goto bypass| if there is none@>=
if (!*p) goto bypass;
q=lab_field;
if (!isspace(*p)) {
  if (!isdigit(*p)&&!isletter(*p)) goto bypass; /* comment */
  for (*q++=*p++;isdigit(*p)||isletter(*p);p++,q++) *q=*p;
  if (*p && !isspace(*p)) derr("label syntax error at `%c'",*p);
@.label syntax error...@>
}
*q='\0';
if (isdigit(lab_field[0]) && (lab_field[1]!='H' || lab_field[2]))
  derr("improper local label `%s'",lab_field);
@.improper local label...@>
for (p++;isspace(*p);p++);

@ We copy the opcode field to a special buffer because we might
want to refer to the symbolic opcode in error messages.

@<Scan the opcode field...@>=
q=op_field;@+
while (isletter(*p)||isdigit(*p)) *q++=*p++;
*q='\0';
if (!isspace(*p) && *p && op_field[0]) derr("opcode syntax error at `%c'",*p);
@.opcode syntax error...@>
pp=trie_search(op_root,op_field)->sym;
if (!pp) {
  if (op_field[0]) derr("unknown operation code `%s'",op_field);
@.unknown operation code@>
  if (lab_field[0]) derr("*no opcode; label `%s' will be ignored",lab_field);
@.no opcode...@>
  goto bypass;
}
opcode=pp->equiv.h, op_bits=pp->equiv.l;
while (isspace(*p)) p++;

@ @<Glob...@>=
tetra opcode; /* numeric code for \MMIX\ operation or \MMIXAL\ pseudo-op */
tetra op_bits; /* flags describing an operator's special characteristics */

@ We copy the operand field to a special buffer so that we can
change string constants while scanning them later.

@<Copy the operand field@>=
q=operand_list;
while (*p) {
  if (*p==';') break;
  if (*p=='\'') {
    *q++=*p++;
    if (!*p) err("incomplete character constant");
@.incomplete...constant@>
    *q++=*p++;
    if (*p!='\'') err("illegal character constant");
@.illegal character constant@>
  }@+else if (*p=='\"') {
    for (*q++=*p++;*p && *p!='\"';p++,q++) *q=*p;
    if (!*p) err("incomplete string constant");
  }
  *q++=*p++;
  if (isspace(*p)) break;
}
while (isspace(*p)) p++;
if (*p==';') p++;
else p=""; /* if not followed by semicolon, rest of the line is a comment */
if (q==operand_list) *q++='0'; /* change empty operand field to `\.0' */
*q='\0';

@ It is important to do the alignment in this step before defining
the label or evaluating the operand field.

@<Align the location pointer@>=
{
  j=(op_bits&align_bits)>>16;
  acc.h=-1, acc.l=-(1<<j);
  cur_loc=oand(incr(cur_loc,(1<<j)-1),acc);
}

@ @<Allocate a global register@>=
{
  if (val_stack[0].equiv.l || val_stack[0].equiv.h) {
    for (j=greg;j<255;j++)
      if (greg_val[j].l==val_stack[0].equiv.l &&
          greg_val[j].h==val_stack[0].equiv.h) {
        cur_greg=j; goto got_greg;
      }
  }
  if (greg==32) err("too many global registers");
@.too many global registers@>
  greg--;
  greg_val[greg]=val_stack[0].equiv;@+  cur_greg=greg;
got_greg:;
}

@ If the label is, say \.{2H}, we will already have used the old
value of \.{2B} when evaluating the operands. Furthermore, an
operand of \.{2F} will have been treated as undefined, which it
still is.

Symbols can be defined more than once, but only if each definition
gives them the same equivalent value.

A warning message is given when a predefined symbol is being redefined,
if its predefined value has already been used.

@<Define the label@>=
{
  sym_node *new_link=DEFINED;
  acc=cur_loc;
  if (opcode==IS) {
    cur_loc=val_stack[0].equiv;
    if (val_stack[0].status==reg_val) new_link=REGISTER;
  }@+else if (opcode==GREG) cur_loc.h=0, cur_loc.l=cur_greg, new_link=REGISTER;
  @<Find the symbol table node, |pp|@>;
  if (pp->link==DEFINED || pp->link==REGISTER) {
    if (pp->equiv.l!=cur_loc.l||pp->equiv.h!=cur_loc.h || pp->link!=new_link) {
      if (pp->serial) derr("symbol `%s' is already defined",lab_field);
@.symbol...already defined@>
      pp->serial=++serial_number;
      derr("*redefinition of predefined symbol `%s'",lab_field);
@.redefinition...@>
    }
  }@+ else if (pp->link==PREDEFINED) pp->serial=++serial_number;
  else if (pp->link) {
    if (new_link==REGISTER) err("future reference cannot be to a register");
@.future reference cannot...@>
    do @<Fix prior references to this label@>@;@+while (pp->link);
  }
  if (isdigit(lab_field[0])) pp=&backward_local[lab_field[0]-'0'];
  pp->equiv=cur_loc;@+ pp->link=new_link;
  @<Fix references that might be in the |val_stack|@>;
  if (listing_file && (opcode==IS || opcode==LOC))
    @<Make special listing to show the label equivalent@>;
  cur_loc=acc;
}

@ @<Fix references that might be in the |val_stack|@>=
if (!isdigit(lab_field[0]))
  for (j=0;j<val_ptr;j++)
    if (val_stack[j].status==undefined && val_stack[j].link->sym==pp) {
      val_stack[j].status=(new_link==REGISTER? reg_val: pure);
      val_stack[j].equiv=cur_loc;
    }

@ @<Find the symbol table node, |pp|@>=
if (isdigit(lab_field[0])) pp=&forward_local[lab_field[0]-'0'];
else {
  if (lab_field[0]==':') tt=trie_search(trie_root,lab_field+1);
  else tt=trie_search(cur_prefix,lab_field);
  pp=tt->sym;
  if (!pp) pp=tt->sym=new_sym_node(true);
}

@ @<Fix prior references to this label@>=
{
  qq=pp->link;
  pp->link=qq->link;
  mmo_loc();
  if (qq->serial==fix_o) @<Fix a future reference from an octabyte@>@;
  else @<Fix a future reference from a relative address@>;
  recycle_fixup(qq);
}

@ @<Fix a future reference from an octabyte@>=
{
  if (qq->equiv.h&0xffffff) {
    mmo_lop(lop_fixo,0,2);
    mmo_tetra(qq->equiv.h);
  }@+else mmo_lop(lop_fixo,qq->equiv.h>>24,1);
  mmo_tetra(qq->equiv.l);
}

@ @<Fix a future reference from a relative address@>=
{
  octa o;
  o=ominus(cur_loc,qq->equiv);
  if (o.l&3)
    dderr("*relative address in location #%08x%08x not divisible by 4",
@.relative address...@>
      qq->equiv.h,qq->equiv.l);
  o=shift_right(o,2,0);@+
  k=0;
  if (o.h==0)
    if (o.l<0x10000) mmo_lopp(lop_fixr,o.l);
    else if (qq->serial==fix_xyz && o.l<0x1000000) {
      mmo_lop(lop_fixrx,0,24);@+mmo_tetra(o.l);
    }@+else k=1;
  else if (o.h==0xffffffff)
    if (qq->serial==fix_xyz && o.l>=0xff000000) {
      mmo_lop(lop_fixrx,0,24);@+mmo_tetra(o.l&0x1ffffff);
    }@+else if (qq->serial==fix_yz && o.l>=0xffff0000) {
      mmo_lop(lop_fixrx,0,16);@+mmo_tetra(o.l&0x100ffff);
    }@+else k=1;
  else k=1;
  if (k) dderr("relative address in location #%08x%08x is too far away",
               qq->equiv.h,qq->equiv.l);
}

@ @<Make special listing to show the label equivalent@>=
if (new_link==DEFINED) {
  fprintf(listing_file,"(%08x%08x)",cur_loc.h,cur_loc.l);
  flush_listing_line(" ");
}@+else {
  fprintf(listing_file,"($%03d)",cur_loc.l&0xff);
  flush_listing_line("             ");
}

@ @<Do the operation@>=
future_bits=0;
if (op_bits&many_arg_bit) @<Do a many-operand operation@>@;
else@+switch (val_ptr) {
case 1:@+if (!(op_bits&one_arg_bit))
    derr("opcode `%s' needs more than one operand",op_field);
@.opcode...operand(s)@>
  @<Do a one-operand operation@>;
case 2:@+if (!(op_bits&two_arg_bit))
    if (op_bits&one_arg_bit)
      derr("opcode `%s' must not have two operands",op_field)@;
    else derr("opcode `%s' must have more than two operands",op_field);
  @<Do a two-operand operation@>;
case 3:@+if (!(op_bits&three_arg_bit))
    derr("opcode `%s' must not have three operands",op_field);
  @<Do a three-operand operation@>;
default: derr("too many operands for opcode `%s'",op_field);
@.too many operands...@>
}

@ The many-operand operators are |BYTE|, |WYDE|, |TETRA|, and |OCTA|.

@<Do a many-operand operation@>=
for (j=0;j<val_ptr;j++) {
  @<Deal with cases where |val_stack[j]| is impure@>;
  k=1<<(opcode-BYTE);
  if ((val_stack[j].equiv.h && opcode<OCTA) ||@|
           (val_stack[j].equiv.l>0xffff && opcode<TETRA) ||@|
           (val_stack[j].equiv.l>0xff && opcode<WYDE))
    if (k==1) err("*constant doesn't fit in one byte")@;
@.constant doesn't fit...@>
    else derr("*constant doesn't fit in %d bytes",k);
  if (k<8) assemble(k,val_stack[j].equiv.l,0);
  else if (val_stack[j].status==undefined)
    assemble(4,0,0xf0), assemble(4,0,0xf0);
  else assemble(4,val_stack[j].equiv.h,0), assemble(4,val_stack[j].equiv.l,0);
}

@ @<Deal with cases where |val_stack[j]| is impure@>=
if (val_stack[j].status==reg_val)
  err("*register number used as a constant")@;
@.register number...@>
else if (val_stack[j].status==undefined) {
  if (opcode!=OCTA) err("undefined constant");
@.undefined constant@>
  pp=val_stack[j].link->sym;
  qq=new_sym_node(false);
  qq->link=pp->link;
  pp->link=qq;
  qq->serial=fix_o;
  qq->equiv=cur_loc;
}

@ @<Do a three-operand operation@>=
@<Do the Z field@>;
@<Do the Y field@>;
assemble_X: @<Do the X field@>;
assemble_inst: assemble(4,(opcode<<24)+xyz,future_bits);
break;

@ Individual fields of an instruction are placed into
global variables |z|, |y|, |x|, |yz|, and/or |xyz|.

@<Glob...@>=
tetra z,y,x,yz,xyz; /* pieces for assembly */
int future_bits; /* places where there are future references */

@ @<Do the Z field@>=
if (val_stack[2].status==undefined) err("Z field is undefined");
@.Z field is undefined@>
if (val_stack[2].status==reg_val) {
  if (!(op_bits&(immed_bit+zr_bit+zar_bit)))
    derr("*Z field of `%s' should not be a register number",op_field);
@.Z field...register number@>
}@+ else if (op_bits&immed_bit) opcode++; /* immediate */
else if (op_bits&zr_bit)
  derr("*Z field of `%s' should be a register number",op_field);
if (val_stack[2].equiv.h || val_stack[2].equiv.l>0xff)
  err("*Z field doesn't fit in one byte");
@.Z field doesn't fit...@>
z=val_stack[2].equiv.l&0xff;

@ @<Do the Y field@>=
if (val_stack[1].status==undefined) err("Y field is undefined");
@.Y field is undefined@>
if (val_stack[1].status==reg_val) {
  if (!(op_bits&(yr_bit+yar_bit)))
    derr("*Y field of `%s' should not be a register number",op_field);
@.Y field...register number@>
}@+ else if (op_bits&yr_bit)
  derr("*Y field of `%s' should be a register number",op_field);
if (val_stack[1].equiv.h || val_stack[1].equiv.l>0xff)
  err("*Y field doesn't fit in one byte");
@.Y field doesn't fit...@>
y=val_stack[1].equiv.l&0xff;@+
yz=(y<<8)+z;

@ @<Do the X field@>=
if (val_stack[0].status==undefined) err("X field is undefined");
@.X field is undefined@>
if (val_stack[0].status==reg_val) {
  if (!(op_bits&(xr_bit+xar_bit)))
    derr("*X field of `%s' should not be a register number",op_field);
@.X field...register number@>
}@+ else if (op_bits&xr_bit)
  derr("*X field of `%s' should be a register number",op_field);
if (val_stack[0].equiv.h || val_stack[0].equiv.l>0xff)
  err("*X field doesn't fit in one byte");
@.X field doesn't fit...@>
x=val_stack[0].equiv.l&0xff;@+
xyz=(x<<16)+yz;

@ @<Do a two-operand operation@>=
if (val_stack[1].status==undefined) {
  if (op_bits&rel_addr_bit)
    @<Assemble YZ as a future reference and |goto assemble_X|@>@;
  else err("YZ field is undefined");
@.YZ field is undefined@>
}@+else if (val_stack[1].status==reg_val) {
  if (!(op_bits&(immed_bit+yzr_bit+yzar_bit)))
    derr("*YZ field of `%s' should not be a register number",op_field);
@.YZ field...register number@>
  if (opcode==SET) val_stack[1].equiv.l<<=8,opcode=0xc1; /* change to \.{OR} */
  else if (op_bits&mem_bit)
    val_stack[1].equiv.l<<=8,opcode++; /* silently append \.{,0} */
}@+ else { /* |val_stack[1].status==pure| */
  if (op_bits&mem_bit)
    @<Assemble YZ as a memory address and |goto assemble_X|@>;
  if (opcode==SET) opcode=0xe3; /* change to \.{SETL} */
  else if (op_bits&immed_bit) opcode++; /* immediate */
  else if (op_bits&yzr_bit) {
    derr("*YZ field of `%s' should be a register number",op_field);
  }
  if (op_bits&rel_addr_bit)
    @<Assemble YZ as a relative address and |goto assemble_X|@>;
}
if (val_stack[1].equiv.h || val_stack[1].equiv.l>0xffff)
  err("*YZ field doesn't fit in two bytes");
@.YZ field doesn't fit...@>
yz=val_stack[1].equiv.l&0xffff;
goto assemble_X;

@ @<Assemble YZ as a future reference...@>=
{
  pp=val_stack[1].link->sym;
  qq=new_sym_node(false);
  qq->link=pp->link;
  pp->link=qq;
  qq->serial=fix_yz;
  qq->equiv=cur_loc;
  yz=0;
  future_bits=0xc0;
  goto assemble_X;
}

@ @<Assemble YZ as a relative address and |goto assemble_X|@>=
{
  octa source, dest;
  if (val_stack[1].equiv.l&3)
    err("*relative address is not divisible by 4");
@.relative address...@>
  source=shift_right(cur_loc,2,0);
  dest=shift_right(val_stack[1].equiv,2,0);
  acc=ominus(dest,source);
  if (!(acc.h&0x80000000)) {
    if (acc.l>0xffff || acc.h)
      err("relative address is more than #ffff tetrabytes forward");
  }@+else {
    acc=incr(acc,0x10000);
    opcode++;
    if (acc.l>0xffff || acc.h)
      err("relative address is more than #10000 tetrabytes backward");
  }
  yz=acc.l;
  goto assemble_X;
}

@ @<Assemble YZ as a memory address and |goto assemble_X|@>=
{
  octa o;
  o=val_stack[1].equiv, k=0;
  for (j=greg;j<255;j++) if (greg_val[j].h || greg_val[j].l) {
    acc=ominus(val_stack[1].equiv,greg_val[j]);
    if (acc.h<=o.h && (acc.l<=o.l || acc.h<o.h)) o=acc, k=j;
  }
  if (o.l<=0xff && !o.h && k) yz=(k<<8)+o.l, opcode++;
  else if (!expanding) err("no base address is close enough to the address A")@;
@.no base address...@>
  else @<Assemble instructions to put supplementary data in \$255@>;
  goto assemble_X;
}

@ @d SETH 0xe0
@d ORH 0xe8
@d ORL 0xeb

@<Assemble instructions to put supplementary data in \$255@>=
{
  for (j=SETH;j<=ORL;j++) {
    switch (j&3) {
     case 0: yz=o.h>>16;@+break; /* \.{SETH} */
     case 1: yz=o.h&0xffff;@+break; /* \.{SETMH} or \.{ORMH} */
     case 2: yz=o.l>>16;@+break; /* \.{SETML} or \.{ORML} */
     case 3: yz=o.l&0xffff;@+break; /* \.{SETL} or \.{ORL} */
     }
    if (yz) {
      assemble(4,(j<<24)+(255<<16)+yz,0);
      j |= ORH;
    }
  }
  if (k) yz=(k<<8)+255; /* Y = \$$k$, Z = \$255 */
  else yz=255<<8, opcode++; /* Y = \$255, Z = 0 */
}

@ @<Do a one-operand operation@>=
if (val_stack[0].status==undefined) {
  if (op_bits&rel_addr_bit)
    @<Assemble XYZ as a future reference and |goto assemble_inst|@>@;
  else if (opcode!=PREFIX) err("the operand is undefined");
@.the operand is undefined@>
}@+else if (val_stack[0].status==reg_val) {
  if (!(op_bits&(xyzr_bit+xyzar_bit)))
    derr("*operand of `%s' should not be a register number",op_field);
@.operand...register number@>
}@+ else { /* |val_stack[0].status==pure| */
  if (op_bits&xyzr_bit)
    derr("*operand of `%s' should be a register number",op_field);
  if (op_bits&rel_addr_bit)
    @<Assemble XYZ as a relative address and |goto assemble_inst|@>;
}
if (opcode>0xff) @<Do a pseudo-operation and |goto bypass|@>;
if (val_stack[0].equiv.h || val_stack[0].equiv.l>0xffffff)
  err("*XYZ field doesn't fit in three bytes");
@.XYZ field doesn't fit...@>
xyz=val_stack[0].equiv.l&0xffffff;
goto assemble_inst;

@ @<Assemble XYZ as a future reference...@>=
{
  pp=val_stack[0].link->sym;
  qq=new_sym_node(false);
  qq->link=pp->link;
  pp->link=qq;
  qq->serial=fix_xyz;
  qq->equiv=cur_loc;
  xyz=0;
  future_bits=0xe0;
  goto assemble_inst;
}

@ @<Assemble XYZ as a relative address...@>=
{
  octa source, dest;
  if (val_stack[0].equiv.l&3)
    err("*relative address is not divisible by 4");
@.relative address...@>
  source=shift_right(cur_loc,2,0);
  dest=shift_right(val_stack[0].equiv,2,0);
  acc=ominus(dest,source);
  if (!(acc.h&0x80000000)) {
    if (acc.l>0xffffff || acc.h)
      err("relative address is more than #ffffff tetrabytes forward");
  }@+else {
    acc=incr(acc,0x1000000);
    opcode++;
    if (acc.l>0xffffff || acc.h)
      err("relative address is more than #1000000 tetrabytes backward");
  }
  xyz=acc.l;
  goto assemble_inst;
}

@ @<Do a pseudo-operation...@>=
switch(opcode) {
 case LOC: cur_loc=val_stack[0].equiv;
 case IS: goto bypass;
 case PREFIX:@+if (!val_stack[0].link) err("not a valid prefix");
@.not a valid prefix@>
   cur_prefix=val_stack[0].link;@+goto bypass;
 case GREG:@+if (listing_file) @<Make listing for |GREG|@>;
   goto bypass;
 case LOCAL:@+if (val_stack[0].equiv.l>lreg) lreg=val_stack[0].equiv.l;
   if (listing_file) {
     fprintf(listing_file,"($%03d)",val_stack[0].equiv.l);
     flush_listing_line("             ");
   }
   goto bypass;
 case BSPEC:@+if (val_stack[0].equiv.l>0xffff || val_stack[0].equiv.h)
     err("*operand of `BSPEC' doesn't fit in two bytes");
@.operand of `BSPEC'...@>
   mmo_loc();@+mmo_sync();
   mmo_lopp(lop_spec,val_stack[0].equiv.l);
   spec_mode=true;@+spec_mode_loc=0;@+ goto bypass;
 case ESPEC: spec_mode=false;@+goto bypass;
}

@ @<Glob...@>=
octa greg_val[256]; /* initial values of global registers */

@ @<Make listing for |GREG|@>=
if (val_stack[0].equiv.l || val_stack[0].equiv.h) {
  fprintf(listing_file,"($%03d=#%08x",cur_greg,val_stack[0].equiv.h);
  flush_listing_line("    ");
  fprintf(listing_file,"         %08x)",val_stack[0].equiv.l);
  flush_listing_line(" ");
}@+else {
  fprintf(listing_file,"($%03d)",cur_greg);
  flush_listing_line("             ");
}

@* Running the program. On a \UNIX/-like system, the command
$$\.{mmixal [options] sourcefilename}$$
will assemble the \MMIXAL\ program in file \.{sourcefilename},
writing any error messages on the standard error file. (Nothing is written to
the standard output.) The options, which may appear in any order, are:

\bull\.{-o objectfilename}\quad Send the output to a binary file called
\.{objectfilename}.
If no \.{-o} specification is given, the object file name is obtained from the
input file name by changing the final letter from `\.s' to~`\.o', or by
appending `\.{.mmo}' if \.{sourcefilename} doesn't end with~\.s.

\bull\.{-l listingname}\quad Output a listing of the assembled input and
output to a text file called \.{listingname}.

\bull\.{-x}\quad Expand memory-oriented commands that cannot be assembled
as single instructions, by assembling auxiliary instructions that make
temporary use of global register~\$255.

\bull\.{-b bufsize}\quad Allow up to \.{bufsize} characters per line of input.

@ Here, finally, is the overall structure of this program.

@c
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
@#
@<Preprocessor definitions@>@;
@<Type definitions@>@;
@<Global variables@>@;
@<Subroutines@>@;
@#
int main(argc,argv)
  int argc;@+
  char *argv[];
{
  register int j,k; /* all-purpose integers */
  @<Local variables@>;
  @<Process the command line@>;
  @<Initialize everything@>;
  while(1) {
    @<Get the next line of input text, or |break| if the input has ended@>;
    while(1) {
      @<Process the next \MMIXAL\ instruction or comment@>;
      if (!*buf_ptr) break;
    }
    if (listing_file) {
      if (listing_bits) listing_clear();
      else if (!line_listed) flush_listing_line("                   ");
    }
  }
  @<Finish the assembly@>;
}

@ The space after |"-b"| is optional, because
{\mc MMIX-SIM} does not use a space in this context.

@<Process the command line@>=
for (j=1;j<argc-1 && argv[j][0]=='-';j++) if (!argv[j][2]) {
  if (argv[j][1]=='x') expanding=1;
  else if (argv[j][1]=='o') j++,strcpy(obj_file_name,argv[j]);
  else if (argv[j][1]=='l') j++,strcpy(listing_name,argv[j]);
  else if (argv[j][1]=='b' && sscanf(argv[j+1],"%d",&buf_size)==1) j++;
  else break;
}@+else if (argv[j][1]!='b' || sscanf(argv[j]+1,"%d",&buf_size)!=1) break;
if (j!=argc-1) {
  fprintf(stderr,"Usage: %s %s sourcefilename\n",
@.Usage: ...@>
    argv[0],"[-x] [-l listingname] [-b buffersize] [-o objectfilename]");
  exit(-1);
}
src_file_name=argv[j];

@ @<Open the files@>=
src_file=fopen(src_file_name,"r");
if (!src_file) dpanic("Can't open the source file %s",src_file_name);
@.Can't open...@>
if (!obj_file_name[0]) {
  j=strlen(src_file_name);
  if (src_file_name[j-1]=='s') {
    strcpy(obj_file_name,src_file_name);@+ obj_file_name[j-1]='o';
  } else sprintf(obj_file_name,"%s.mmo",src_file_name);
}
obj_file=fopen(obj_file_name,"wb");
if (!obj_file) dpanic("Can't open the object file %s",obj_file_name);
if (listing_name[0]) {
  listing_file=fopen(listing_name,"w");
  if (!listing_file) dpanic("Can't open the listing file %s",listing_name);
}

@ @<Glob...@>=
char *src_file_name; /* name of the \MMIXAL\ input file */
char obj_file_name[FILENAME_MAX+1]; /* name of the binary output file */
char listing_name[FILENAME_MAX+1]; /* name of the optional listing file */
FILE *src_file, *obj_file, *listing_file;
int expanding; /* are we expanding instructions when base address fail? */
int buf_size; /* maximum number of characters per line of input */

@ @<Init...@>=
@<Open the files@>;
filename[0]=src_file_name;
filename_count=1;
@<Output the preamble@>;

@ @<Output the preamble@>=
mmo_lop(lop_pre,1,1);
mmo_tetra(time(NULL));
mmo_cur_file=-1;

@ @<Finish the assembly@>=
if (lreg>=greg)
  dpanic("Danger: Must reduce the number of GREGs by %d",lreg-greg+1);
@.Danger@>
@<Output the postamble@>;
@<Check and output the trie@>;
@<Report any undefined local symbols@>;
if (err_count) {
  if (err_count>1) fprintf(stderr,"(%d errors were found.)\n",err_count);
  else fprintf(stderr,"(One error was found.)\n");
}
exit(err_count);

@ @<Glob...@>=
int greg=255; /* global register allocator */
int cur_greg; /* global register just allocated */
int lreg=32; /* local register allocator */

@ @<Output the postamble@>=
mmo_lop(lop_post,0,greg);
greg_val[255]=trie_search(trie_root,"Main")->sym->equiv;
for (j=greg;j<256;j++) {
  mmo_tetra(greg_val[j].h);
  mmo_tetra(greg_val[j].l);
}

@ @<Report any undefined local symbols@>=
for (j=0;j<10;j++) if (forward_local[j].link)
  err_count++,fprintf(stderr,"undefined local symbol %dF\n",j);
@.undefined local symbol@>

@* Index.

