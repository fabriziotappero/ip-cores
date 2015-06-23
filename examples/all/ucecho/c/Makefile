GCC=gcc -pipe -g

all: UCEcho

UCEcho: UCEcho.c
	$(GCC) UCEcho.c -lusb -o UCEcho

clean:
	rm -f *.o *.old *.bak *~

distclean:
	rm -f UCEcho
