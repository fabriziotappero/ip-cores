MODULE=RS_dec
DEPS ?=

all: syn

syn:
	[ -d work ] || mkdir work
	[ -d report ] || mkdir report
	[ -d gatenet ] || mkdir gatenet
	bash -c "dc_shell-t -f syn.tcl > report/syn.log"

config:
	echo -n > analyze.tcl
	for src in ../../rtl/*.v; do \
		echo analyze -work WORK -format verilog $$src >> analyze.tcl; \
	done;
	for src in $(DEPS); do \
		echo read_db ../../../$$src/syn/asic/gatenet/$$src.db >> analyze.tcl; \
	done;
	echo set module $(MODULE) >> analyze.tcl

clean:
	-${RM} -r work/ gatenet/ *.log default.svf

all-clean: clean
	-${RM} -r report/ *~
