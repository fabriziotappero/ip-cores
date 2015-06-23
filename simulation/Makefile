MODULE=RS_dec
TESTBENCH=${MODULE}_tb.v
SOURCES=$(wildcard ../rtl/*.v)

all: sim

${MODULE}.vvp: ${TESTBENCH} ${SOURCES}
	iverilog ${TESTBENCH} ${SOURCES} -o $@

sim: ${MODULE}.vvp
	vvp -n ${MODULE}.vvp

clean:
	rm -f a.out ${MODULE}.vvp

all-clean: clean
	rm -f *~

