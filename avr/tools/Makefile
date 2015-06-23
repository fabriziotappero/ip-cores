# Makefile for igor tools
CC= gcc
CFLAGS=

TARGETS= formatsd readbs serialdmp

all: $(TARGETS)

formatsd:
	$(CC) $(CFLAGS) -o formatsd formatsd.c
readbs:
	$(CC) $(CFLAGS) -o readbs readbs.c
serialdmp:
	$(CC) $(CFLAGS) -o serialdmp serialdmp.c
clean:
	rm -f $(TARGETS)
