#
# makefile for compiling for Windoze using MinGW w/o eclipse
# 16-jul-09	hvk	initial
# 24-jul-09	hvk	fixed echo
# 15-oct-10	hvk	using ''tcc' of http://bellard.org/tcc/ and 'rm' of Xilinx/cygwin
#

## defines

RM = rm
MP = "C:/tcc/inc"
CC = "C:/tcc/tcc"
 
C_SRCS += \
./pBlazMRG.c \
./pbLibgen.c \
./getopt.c

EXE = "./pBlazMRG.exe"
OBJS = $(C_SRCS:.c=.o)
LIBS = 
INCS = -I$(MP)"/include" -I"./inc"
CFLAGS = $(INCS) -g3 -DWINDOWS -Wall -c -O3 -DTCC -DHAVE_STRING_H

MGFLAGS = -stest_data.mem -v
ENTITY = test

## rules

# All Target
all:	test

test:	$(EXE)
	$(EXE) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem ROM_form_S6_1K_16Sept10.vhd S6_1k.vhd 
	$(EXE) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem ROM_form_S6_2K_16Sept10.vhd S6_2k.vhd 
	$(EXE) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem ROM_form_V6_1K_16Sept10.vhd V6_1k.vhd 
	$(EXE) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem ROM_form_V6_2K_16Sept10.vhd V6_2k.vhd 
	$(EXE) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem ROM_form_V6_4K_17Sept10.vhd V6_4k.vhd 
	$(EXE) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem ROM_form_64.vhd D64.vhd 
	$(EXE) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem ROM_form_256_10Nov10.vhd D256.vhd 

# Tool invocations
$(EXE):	$(OBJS)
	@echo Building: $(EXE)
	$(CC) -o $@ $^ $(LIBS)
	
%.o : %.c
	@echo Building: "$@"
	$(CC) $(CFLAGS) -o"$@" "$<"

# Other Targets
clean:
	-@echo Clean up: $(OBJS) $(EXE)
	-$(RM) $(OBJS) $(EXE)

.PHONY: all clean
.SECONDARY:
