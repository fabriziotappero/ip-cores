INCLUDE_FILES =
SOURCE_FILES = sc_main.cpp verilated.cpp

SYSTEMPERL_inc = ${SYSTEMPERL}/src
VERILATOR_ROOT = /usr/local/verilator-3.701
SYSC_INC_PREFIX = /usr/local/systemc-2.2/include
SYSC_LIB_PREFIX = /usr/local/systemc-2.2/lib-linux
includedir = /usr/local/scv/include
libdir = /usr/local/scv/lib-linux

SHELL = /bin/sh
AUTOMAKE_OPTIONS = foreign
EXTRA_DIST = ${SOURCE_FILES} ${INCLUDE_FILES} README

OBJECT_FILES = ${addsuffix .o, ${basename ${SOURCE_FILES}}}

CLEANFILES = ${OBJECT_FILES} libscvtestbench.so run.x

DISTCLEANFILES = ${CLEANFILES}
Vinclude = $(VERILATOR_ROOT)/include
all:    
	LD_LIBRARY_PATH=.:${SYSC_LIB_PREFIX}:${libdir}:${LD_LIBRARY_PATH}; \
	export LD_LIBRARY_PATH; \
	g++ -I${SYSC_INC_PREFIX} -I${SYSTEMPERL_inc} -I${Vinclude} -I${includedir} -fPIC -c -g -Wall -O2 ${SOURCE_FILES}; \
	g++ ${OBJECT_FILES} Valu_tb__ALL.a -L${SYSC_LIB_PREFIX} -lsystemc -L${libdir} -lscv -L${SYSC_LIB_PREFIX} -lsystemc -o run.x; \
	./run.x
