Building and installing the GCC for the SCARTS 32-bit architecture
variant works as follows:

./configure \
	--prefix=$SCARTS_TOOLCHAIN_DIR \
	--target=scarts_32-none-eabi \
	--enable-languages=c \
	--disable-libssp \
	--with-gnu-as \
	--with-gnu-ld \
	--with-newlib
make && make install
