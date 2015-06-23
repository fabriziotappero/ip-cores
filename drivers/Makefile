LIB=libscartsdrivers.a

CC = scarts32-gcc
INCLUDE_DIR = src/include
CFLAGS = -I$(INCLUDE_DIR) -Wall -O0 -c

SRC = src/dis7seg/dis7seg.c \
  src/key_matrix/key_matrix.c \
  src/vgatext/vgatext.c \
  src/counter/counter.c

OBJ = $(SRC:%.c=%.o)

PREFIX = /opt/scarts_toolchain
INSTALL_INCLUDE_DIR = scarts32/include/drivers
INSTALL_LIB_DIR = scarts32/lib


all: $(LIB)

$(LIB): $(OBJ)
	ar rcs $(LIB) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ $< 

install:
	install -m 644 -D $(LIB) $(PREFIX)/$(INSTALL_LIB_DIR)/$(LIB)
	install -d $(PREFIX)/$(INSTALL_INCLUDE_DIR)
	install -m 644 $(INCLUDE_DIR)/* $(PREFIX)/$(INSTALL_INCLUDE_DIR)

.PHONY: clean
clean:
	rm -rf $(LIB) $(OBJ)


