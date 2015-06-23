CUR_DIR=$(shell pwd)


# IP-Library
LIB_DIR=$(CUR_DIR)/../EDK_Libs
# Wishbone Library
WISHBONE_LIB_DIR=$(LIB_DIR)/WishboneIPLib
# VHDL compile flags
VHDL_CFLAGS="-novopt -93 -error -check_synthesis -defercheck -deferSubpgmCheck -rangecheck "

# not used at the moment
#PLB_BFM_LIB_DIR=/opt/Xilinx/11.1/EDK/hw/XilinxBFMinterface

## Uncomment this, if you are using cygwin in a windows environment
#  (Check the paths in common/Makefile  ->> vmap entries)
#ENVIRONMENT="cygwin"




all: sim assert.log simulation.log error.log

.PHONY: sim assert.log simulation.log error.log

newsim: cleansim sim

sim: t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13


TEST_CASES+="32bit_on_128bitPLB_syn/simulation/test_cases/simple_read_write" 
TEST_CASES+="32bit_on_128bitPLB_syn/simulation/test_cases/simple_line_rw" 
TEST_CASES+="32bit_on_128bitPLB_syn/simulation/test_cases/simple_burst_rw" 
TEST_CASES+="32bit_on_128bitPLB_syn/simulation/test_cases/stressful_read_write" 
TEST_CASES+="32bit_on_128bitPLB_asyn/simulation/test_cases/simple_read_write" 
TEST_CASES+="32bit_on_128bitPLB_asyn/simulation/test_cases/simple_line_rw" 
TEST_CASES+="32bit_on_128bitPLB_asyn/simulation/test_cases/simple_burst_rw" 
TEST_CASES+="32bit_on_128bitPLB_asyn/simulation/test_cases/stressful_read_write" 
TEST_CASES+="wb_retries/simulation/test_cases/simple_retries" 
TEST_CASES+="wb_err_and_rst/simulation/test_cases/errors_and_rst" 
TEST_CASES+="wb_err_and_rst/simulation/test_cases/timeouts" 
TEST_CASES+="wb_irqs/simulation/test_cases/irq_tests" 
TEST_CASES+="simple/simulation/test_cases/stressful_read_write"


t1:
	$(MAKE) -C "32bit_on_128bitPLB_syn/simulation/test_cases/simple_read_write" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t2:
	$(MAKE) -C "32bit_on_128bitPLB_syn/simulation/test_cases/simple_line_rw" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t3:
	$(MAKE) -C "32bit_on_128bitPLB_syn/simulation/test_cases/simple_burst_rw" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t4:
	$(MAKE) -C "32bit_on_128bitPLB_syn/simulation/test_cases/stressful_read_write" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);


t5:
	$(MAKE) -C "32bit_on_128bitPLB_asyn/simulation/test_cases/simple_read_write" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t6:
	$(MAKE) -C "32bit_on_128bitPLB_asyn/simulation/test_cases/simple_line_rw" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t7:
	$(MAKE) -C "32bit_on_128bitPLB_asyn/simulation/test_cases/simple_burst_rw" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t8:
	$(MAKE) -C "32bit_on_128bitPLB_asyn/simulation/test_cases/stressful_read_write" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t9:
	$(MAKE) -C "wb_retries/simulation/test_cases/simple_retries" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t10:
	$(MAKE) -C "wb_err_and_rst/simulation/test_cases/errors_and_rst" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t11:
	$(MAKE) -C "wb_err_and_rst/simulation/test_cases/timeouts" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t12:
	$(MAKE) -C "wb_irqs/simulation/test_cases/irq_tests" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);

t13:
	$(MAKE) -C "simple/simulation/test_cases/stressful_read_write" sim LIB_DIR=$(LIB_DIR) WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) PLB_BFM_LIB_DIR=$(PLB_BFM_LIB_DIR) VHDL_CFLAGS=$(VHDL_CFLAGS);




compile:
	$(MAKE) -C $(CUR_DIR)/32bit_on_128bitPLB_syn/simulation compile LIB_DIR=$(LIB_DIR)   WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) VHDL_CFLAGS=$(VHDL_CFLAGS);
	$(MAKE) -C $(CUR_DIR)/32bit_on_128bitPLB_asyn/simulation compile LIB_DIR=$(LIB_DIR)  WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) VHDL_CFLAGS=$(VHDL_CFLAGS);
	$(MAKE) -C $(CUR_DIR)/wb_retries/simulation compile LIB_DIR=$(LIB_DIR)  WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) VHDL_CFLAGS=$(VHDL_CFLAGS);
	$(MAKE) -C $(CUR_DIR)/wb_err_and_rst/simulation compile LIB_DIR=$(LIB_DIR)  WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) VHDL_CFLAGS=$(VHDL_CFLAGS);
	$(MAKE) -C $(CUR_DIR)/wb_irqs/simulation compile LIB_DIR=$(LIB_DIR)  WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) VHDL_CFLAGS=$(VHDL_CFLAGS);
	$(MAKE) -C $(CUR_DIR)/simple/simulation compile LIB_DIR=$(LIB_DIR)  WISHBONE_LIB_DIR=$(WISHBONE_LIB_DIR) ENVIRONMENT=$(ENVIRONMENT) VHDL_CFLAGS=$(VHDL_CFLAGS);


clean:
	$(MAKE) -C $(CUR_DIR)/32bit_on_128bitPLB_syn/simulation 	clean
	$(MAKE) -C $(CUR_DIR)/32bit_on_128bitPLB_asyn/simulation	clean
	$(MAKE) -C $(CUR_DIR)/wb_retries/simulation					clean
	$(MAKE) -C $(CUR_DIR)/wb_err_and_rst/simulation				clean
	$(MAKE) -C $(CUR_DIR)/wb_irqs/simulation						clean
	$(MAKE) -C $(CUR_DIR)/simple/simulation						clean
	@for i in $(TEST_CASES); do \
		$(MAKE) -C $$i clean;	\
	done;

cleansim:
	@for i in $(TEST_CASES); do \
		$(MAKE) -C $$i clean;	\
	done;
	rm -rf error.log assert.log simulation.log



simulation.log: sim
	@rm -rf simulation.log
	@for i in $(TEST_CASES); do \
	echo "------------------------------------------------------" >> simulation.log; \
	echo "----  $$i  ----" >> simulation.log; \
	echo "------------------------------------------------------" >> simulation.log; \
	cat $$i/result/simulation.log >> simulation.log;	\
	done;

error.log: sim
	@rm -rf error.log
	@for i in $(TEST_CASES); do \
	echo "------------------------------------------------------" >> error.log; \
	echo "----  $$i  ----" >> error.log; \
	echo "------------------------------------------------------" >> error.log; \
	cat $$i/result/error.log >> error.log;	\
	done;


assert.log: sim
	@rm -rf assert.log
	@for i in $(TEST_CASES); do \
	echo "------------------------------------------------------" >> assert.log; \
	echo "----  $$i  ----" >> assert.log; \
	echo "------------------------------------------------------" >> assert.log; \
	cat $$i/result/assert.log >> assert.log;	\
	done;


