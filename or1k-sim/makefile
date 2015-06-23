###############################################################################
## Simulator Makefile
###############################################################################

# Target
TARGET		= or1knd-sim

# Options
CFLAGS	    = -DINCLUDE_INST_DUMP
LDFLAGS     = 

# Optional (you need libelf-dev)
#CFLAGS	   += -DINCLUDE_ELF_SUPPORT
#LIBS       += -lelf 

# Source Files
OBJ = main.o or32.o or32_inst_dump.o

###############################################################################
# Rules
###############################################################################
all: $(TARGET)
	
clean:
	-rm *.o $(TARGET)

%.o : %.c
	gcc -c $(CFLAGS) $< -o $@

%.o : %.cpp
	g++ -c $(CFLAGS) $< -o $@

$(TARGET): $(OBJ) makefile
	g++ $(LDFLAGS) $(OBJ) $(LIBS) -o $@

