###
###     Makefile for H.264 decoder
###
###             generated for UNIX/LINUX environments
###             by H. Schwarz
###



NAME=   ldecod

### include debug information: 1=yes, 0=no
#DBG= 0

DEPEND= dependencies

BINDIR= ../bin
INCDIR= inc
SRCDIR= src
OBJDIR= obj

ADDSRCDIR= ../lcommon/src
ADDINCDIR= ../lcommon/inc

CC=     $(shell which gcc)

LIBS=   -lm
CFLAGS= -std=gnu99 -pedantic -ffloat-store -fno-strict-aliasing
FLAGS=  $(CFLAGS) -Wall -I$(INCDIR) -I$(ADDINCDIR) -D __USE_LARGEFILE64 -D _FILE_OFFSET_BITS=64 
ifdef DBG
SUFFIX= .dbg
FLAGS+= -g
else
SUFFIX=
FLAGS+= -O3
endif

OBJSUF= .o$(SUFFIX)

SRC=    $(wildcard $(SRCDIR)/*.c) 
ADDSRC= $(wildcard $(ADDSRCDIR)/*.c)
OBJ=    $(SRC:$(SRCDIR)/%.c=$(OBJDIR)/%.o$(SUFFIX)) $(ADDSRC:$(ADDSRCDIR)/%.c=$(OBJDIR)/%.o$(SUFFIX)) 
BIN=    $(BINDIR)/$(NAME)$(SUFFIX).exe


default: depend bin tags

dependencies:
	@echo "" >dependencies

clean:
	@echo remove all objects
	@rm -f $(OBJDIR)/*

tags:
	@echo update tag table
	@ctags inc/*.h src/*.c

bin:    $(OBJ)
	@echo
	@echo 'creating binary "$(BIN)"'
	@$(CC) -o $(BIN) $(OBJ) $(LIBS)
	@echo '... done'
	@echo

depend:
	@echo
	@echo 'checking dependencies'
	@$(SHELL) -ec '$(CC) -MM $(CFLAGS) -I$(INCDIR) -I$(ADDINCDIR) $(SRC) $(ADDSRC)                  \
         | sed '\''s@\(.*\)\.o[ :]@$(OBJDIR)/\1.o$(SUFFIX):@g'\''               \
         >$(DEPEND)'
	@echo

$(OBJDIR)/%.o$(SUFFIX): $(SRCDIR)/%.c
	@echo 'compiling object file "$@" ...'
	@$(CC) -c -o $@ $(FLAGS) $<

$(OBJDIR)/%.o$(SUFFIX): $(ADDSRCDIR)/%.c
	@echo 'compiling object file "$@" ...'
	@$(CC) -c -o $@ $(FLAGS) $<


include $(DEPEND)

