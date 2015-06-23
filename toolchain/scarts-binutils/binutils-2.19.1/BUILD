Building and installing the GNU Binutils for the SCARTS 32-bit architecture
variant works as follows:

./configure \
	--prefix=$SCARTS_TOOLCHAIN_DIR \
	--target=scarts_32-none-eabi \
	--enable-cgen-maint \
	CFLAGS="-O2"
make && make install

Note: compiling the binutils-2.19 with CFLAG '-O1' or '-O2' made the SCARTS
GAS (GNU Assembler) fail with a segmentation fault on some testing machines.
You might experience such a segmentation fault during the build of the GCC
for the SCARTS architecture when the libgcc.a is cross-compiled. The only
known workarounds to this are to compile the binutils with '-O0' instead.


