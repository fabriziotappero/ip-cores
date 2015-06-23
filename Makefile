SHELL=/bin/sh
MAKE=make
CUR_DIR=$(shell pwd)
home=$(CUR_DIR)
design=socgen
project=fpgas
vendor=opencores.org





.PHONY all: clean 
all: 
	(\
	${home}/tools/sys/workspace  opencores.org  fpgas;\
	${home}/tools/sys/workspace  opencores.org  logic;\
	${home}/tools/sys/workspace  opencores.org  adv_debug_sys;\
	${home}/tools/sys/workspace  opencores.org  io;\
	${home}/tools/sys/workspace  opencores.org  Mos6502;\
	${home}/tools/sys/workspace  opencores.org  wishbone;\
	${home}/tools/sys/workspace  opencores.org  cde;\
	 )


.PHONY workspace: clean
workspace: 
	(\
	${home}/tools/sys/workspace  opencores.org  fpgas;\
	${home}/tools/sys/workspace  opencores.org  logic;\
	${home}/tools/sys/workspace  opencores.org  adv_debug_sys;\
	${home}/tools/sys/workspace  opencores.org  io;\
	${home}/tools/sys/workspace  opencores.org  Mos6502;\
	${home}/tools/sys/workspace  opencores.org  wishbone;\
	${home}/tools/sys/workspace  opencores.org  cde;\
	 )


.PHONY dock:  
dock: 
	(\
	${home}/tools/documentation/create_lib_doc   opencores.org  cde            ;\
	${home}/tools/documentation/create_lib_doc   opencores.org  adv_debug_sys  ;\
	${home}/tools/documentation/create_lib_doc   opencores.org  logic          ;\
	${home}/tools/documentation/create_lib_doc   opencores.org  io             ;\
	${home}/tools/documentation/create_lib_doc   opencores.org  Mos6502        ;\
	${home}/tools/documentation/create_lib_doc   opencores.org  Testbench      ;\
	${home}/tools/documentation/create_lib_doc   opencores.org  wishbone       ;\
	${home}/tools/documentation/create_lib_doc   opencores.org  fpgas          ;\
	 )








.PHONY clean:
clean: 
	(\
	./tools/yp/clean ;\
	rm -f -r doc/geda/*  ;\
	find . | grep "~" | xargs rm -f  $1 ;\
	 )




.PHONY index:
index: 
	(\
	${home}/tools/busdefs/create_busdefs ;\
	 )



.PHONY build_elab:
build_elab: 
	(\
	rm -f -r dbs/*  ;\
	rm -f -r io_ports  ;\
	${home}/tools/sys/build_elab_master  ;\
	${home}/tools/verilog/gen_instance_roots  ;\
	)



.PHONY build_hw:
build_hw: 
	(\
	${home}/tools/sys/build_hw_master  ;\
	)




.PHONY build_sw:
build_sw:
	(\
	${home}/tools/sys/build_sw_master  ;\
	)


.PHONY run_sims:
run_sims: 
	(\
	${home}/tools/simulation/build_sim_master  ;\
	 )

.PHONY build_fpgas:
build_fpgas:
	(\
	${home}/tools/synthesys/build_fpga_master  ;\
	 )


.PHONY check_sims:
check_sims:   
	@for COMP in `ls $(CUR_DIR)/work`; do \
	echo "*******************************************************************************************";\
	echo " number of $$COMP sims run";\
	find ./work/$$COMP  | grep test_define | grep -v target | grep -v children| grep -v cov | wc -l;\
	echo " number of sims that finished";\
	find ./work/$$COMP  | grep _sim.log | xargs grep PASSED $1    | wc -l    ;\
	echo " number of warnings";\
	find ./work/$$COMP  | grep _sim.log | xargs grep WARNING $1   | wc -l ;\
	echo " number of errors";\
	find ./work/$$COMP  | grep _sim.log | xargs grep ERROR $1     | wc -l ;\
	echo " Elaboration Errors";\
	find ./work/$$COMP  | grep _elab.log | xargs cat $1  ;\
	echo " Code Coverage";\
	echo " number of warnings";\
	find ./work/$$COMP  | grep _cov.log | xargs grep WARNING $1  ;\
	echo " number of errors";\
	find ./work/$$COMP  | grep _cov.log | xargs grep ERROR $1    ;\
	echo " Lint Coverage";\
	echo " number of errors";\
	find ./work/$$COMP  | grep lint.log | xargs grep Error $1  ;\
	done;\




.PHONY check_fpgas:
check_fpgas: 
	(\
	cd ${home}/work  ;\
	echo " number of fpgas";\
	find . | grep syn/ise |grep Yst |  wc -l   ;\
	echo " number that finished";\
	find . | grep Board_Design_jtag.bit | wc -l ;\
	 )






















