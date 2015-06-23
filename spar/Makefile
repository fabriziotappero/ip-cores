CC=gcc
LEX=flex -l
YACC=bison -y

CFLAGS = -ansi -pedantic -D_GNU_SOURCE -Wall -Wno-format -g
LFLAGS = -Ce -8
YFLAGS = -d

all: as1

as1: checks.o code.o emit.o expand.o fixes.o optab.o output.o segtab.o	\
  spar.o symtab.o ui.o lex.exprs.o exprs.tab.o
	$(CC) -o $@ $^

spar.o: spar.c spar.h ui.h checks.h segtab.h code.h emit.h exprs.h \
  fixes.h optab.h output.h symtab.h
spar.o: spar.c exprs.h exprs.tab.h spar.h symtab.h
spar.c: spar.l

checks.o: checks.c spar.h ui.h checks.h segtab.h code.h exprs.h optab.h \
  symtab.h
code.o: code.c code.h segtab.h
emit.o: emit.c spar.h optab.h code.h segtab.h emit.h exprs.h
expand.o: expand.c spar.h expand.h code.h segtab.h optab.h
fixes.o: fixes.c spar.h ui.h code.h segtab.h exprs.h fixes.h optab.h \
  symtab.h
optab.o: optab.c optab.h code.h segtab.h
output.o: output.c spar.h ui.h output.h segtab.h code.h
segtab.o: segtab.c spar.h segtab.h code.h
symtab.o: symtab.c spar.h symtab.h
ui.o: ui.c ui.h

lex.exprs.o: lex.exprs.c exprs.h exprs.tab.h spar.h symtab.h
lex.exprs.c: exprs.l exprs.tab.h exprs.h
	$(LEX) $(LFLAGS) -Pexprs exprs.l

exprs.tab.o: exprs.tab.c
exprs.tab.c exprs.tab.h: exprs.y exprs.h
	$(YACC) $(YFLAGS) -b exprs -p exprs exprs.y
	sed -i '/^yydestruct (/ N; s/\n[ \t]*int64_t \*retval,//' exprs.tab.c

clean:
	rm -f as1 *.o exprs.tab.h exprs.tab.c lex.exprs.c spar.c
