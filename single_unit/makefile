VHDLS = \
  src/fft_len.vhd \
  src/icpx_pkg.vhd \
  src/butterfly.vhd \
  src/dpram_inf.vhd \
  src/icpxram.vhd \
  src/fft_engine.vhd \
  src/fft_engine_tb.vhd \


#STD=standard
STD=synopsys
VSTD=93c
ENTITY=fft_engine_tb
#RUN_OPTIONS= --stop-time=10000ns --wave=${ENTITY}.ghw 
RUN_OPTIONS= 
#--trace-processes
all: ${ENTITY}.ghw
reader:   ${ENTITY} ${ENTITY}.ghw
	gtkwave ${ENTITY}.ghw ${ENTITY}.sav
${ENTITY}: ${VHDLS}
#	vhdlp -work fmf fmf/*.vhd
	ghdl -a --workdir=comp --std=${VSTD} --ieee=${STD} ${VHDLS} 
	ghdl -e --workdir=comp --std=${VSTD} -fexplicit --ieee=${STD} ${ENTITY}
${ENTITY}.ghw: ${ENTITY}
#	./${ENTITY} --wave=${ENTITY}.ghw  ${RUN_OPTIONS} --stop-time=50000ns 2>&1 > res.txt
	./${ENTITY} ${RUN_OPTIONS} 
#> res.txt  2>&1 
clean:
	rm -f comp/* *.o *.vcd *.ghw events* ${ENTITY}
	
