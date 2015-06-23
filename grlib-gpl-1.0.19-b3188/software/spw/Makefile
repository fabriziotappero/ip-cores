CC=sparc-elf-gcc
CCOPT=-msoft-float -g

all: rmapapi.h spwapi.h spwapi.c rmapapi.c spw_test_dual.c
	$(CC) $(CCOPT) -o spw_test_dual spw_test_dual.c spwapi.c rmapapi.c