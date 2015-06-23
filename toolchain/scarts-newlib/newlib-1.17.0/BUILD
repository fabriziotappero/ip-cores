Building and installing the GDB for the SCARTS 32-bit architecture
variant works as follows:

./configure \
	--prefix=$SCARTS_TOOLCHAIN_DIR \
	--enable-newlib-io-long-double=no \
	--enable-newlib-io-long-long=no \
	--enable-newlib-multithread=no \
	--target=scarts_32-none-eabi \
	CFLAGS_FOR_TARGET="-O0"
make && make install
