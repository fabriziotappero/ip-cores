
SRCDIR=../src/

# The location of the ModelSim installation, used
# to build the C lib for VPI.  Used by MinGW, so use windows dir name, not /cygdrive/...
MODEL=c:/altera/90/modelsim_ase

# Different installs of Modelsim keep their libraries in different
# directories (e.g. the version that comes with the Altera web version).
# This directory must contain mtipli.dll
MODEL_LIB=$(MODEL)/win32aloem

# If building under windows, Modelsim requires that the VPI
# library be compiled with MinGW, NOT cygwin GCC.  The location
# here is the default used by the auto-installer.
MINGW_CC = c:/MinGW/bin/mingw32-gcc.exe


default: vpi

# This is for ModelSim under cygwin.  Modelsim requires the shared lib
# to be compiled with MinGW, not cygwin GCC.
jp-io-vpi.dll: $(SRCDIR)jp-io-vpi.c Makefile
	$(MINGW_CC) -DWIN32 -c -I$(MODEL)/include $(SRCDIR)jp-io-vpi.c -o jp-io-vpi.o
	$(MINGW_CC) -DWIN32 -shared -Bsymbolic -o jp-io-vpi.dll jp-io-vpi.o -L$(MODEL_LIB) -lmtipli -lws2_32

vpi: jp-io-vpi.dll Makefile