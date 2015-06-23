Building and installing the GDB for the SCARTS 32-bit architecture
variant works as follows:

./configure \
	--prefix=$SCARTS_TOOLCHAIN_DIR \
	--target=scarts_32-none-eabi \
	CFLAGS="-O2 -I$INST_SCARTS_TOOLCHAIN_NEWLIB_LIBGLOSS_DIR/scarts_32 -DSCARTS_TOOLCHAIN_LIB_SIM_DIR=$SCARTS_TOOLCHAIN_LIB_SIM_DIR" \
	LDFLAGS="-ldl -lz"
make && make install

Finally, install the simulator plugins in scarts-gdb/sim-plugins.
