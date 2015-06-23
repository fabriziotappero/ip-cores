CC=gcc
CFLAGS=

C_SRCS += \
	./cpBlazeMRG.c

EXE="./cpBlazeMRG.exe"

# All Target
all: $
	$(CC) $(CFLAGS) $(C_SRCS) -o $(EXE)

	
# Other Targets
clean:
	$(RM) $(OBJS)
	$(RM) $(EXE)

.PHONY: all clean
.SECONDARY:
