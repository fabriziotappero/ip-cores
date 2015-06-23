

modelsim_win32: modelsim_win32/jp-io-vpi.dll

modelsim_linux_x86: modelsim_linux_x86/jp-io-vpi.so

icarus: icarus/jp-io-vpi.vpi



modelsim_win32/jp-io-vpi.dll: src/jp-io-vpi.c
	cd modelsim_win32 && make

modelsim_linux_x86/jp-io-vpi.so: src/jp-io-vpi.c
	cd modelsim_linux_x86 && make

icarus/jp-io-vpi.vpi: src/jp-io-vpi.c
	cd icarus && make