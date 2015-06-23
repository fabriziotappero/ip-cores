VHDLS = \
  src/sys_config.vhd \
  src/sorter_pkg.vhd \
  src/dpram4.vhd \
  src/sort_dpram.vhd \
  src/sorter_ctrl.vhd \
  src/sorter_sys.vhd \
  src/sorter_sys_tb.vhd \

#STD=standard
STD=synopsys
VSTD=93c
ENTITY=sorter_sys_tb
RUN_OPTIONS= 
all: events.in events.out test
events.in: sort_test_gen.py
	./sort_test_gen.py
reader:   ${ENTITY} ${ENTITY}.ghw
	gtkwave ${ENTITY}.ghw ${ENTITY}.sav
${ENTITY}: ${VHDLS}
#	vhdlp -work fmf fmf/*.vhd
	ghdl -a --workdir=comp --std=${VSTD} --ieee=${STD} ${VHDLS} 
	ghdl -e --workdir=comp --std=${VSTD} -fexplicit --ieee=${STD} ${ENTITY}
events.out: ${ENTITY} events.in
#	./${ENTITY} --wave=${ENTITY}.ghw  ${RUN_OPTIONS} --stop-time=50000ns 2>&1 > res.txt
	./${ENTITY} ${RUN_OPTIONS}  2>&1 > res.txt
test:
	./sort_test_check.py
clean:
	rm -f comp/* *.o *.vcd *.ghw events* ${ENTITY}
	
