

all:
	bison -d --verbose yacc.in
	cp yacc.tab.in y.tab.c
	cp yacc.tab.in.h y.tab.h
	flex lex.in
	gcc  y.tab.c lex.yy.c tools.c -o asm
	./asm -h eratost.asm

bin: 	
	@./asm -b eratost.asm
	@echo ;

all2:
	yacc -d templates.yacc
	lex templates.lex
	tcc  -Itcc-0.9.23\include -Ltcc-0.9.23\lib y.tab.c lex.yy.c tools.c

clean: 
	rm *.o

run2: all2
	./a.out

run: all
	./a.out

		
