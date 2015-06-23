CUR_DIR=$(shell pwd)
SIM_DIR=$(CUR_DIR)/../..
SIM_BIN_DIR=$(SIM_DIR)/sim_bin
RESULT_DIR=$(CUR_DIR)/result
VSIM=vsim -quiet -c -assertfile $(RESULT_DIR)/assert.log -errorfile $(RESULT_DIR)/error.log -l $(RESULT_DIR)/simulation.log -do

TEST_CASE_TARGETS=./result/wave.wlf





sim: $(TEST_CASE_TARGETS)


$(TEST_CASE_TARGETS): $(SIM_BIN_DIR)/modelsim.ini $(COMPILE_COMPONENTS) transfers.do 
	@$(MAKE) link
	@mkdir -p result
	@echo "Run vsim ....."
	@$(VSIM) "do sim.do; exit" > /dev/null
	@echo ".... done! Result in $(RESULT_DIR)"



#
#	we first do `unlink`. If there are no links,  this does nothing.
#	If there are links,  we unlink it and link it again
link: unlink
	@ln -s `find ../../sim_bin -maxdepth 1` ./


unlink:
	@for file in $(shell find . -maxdepth 1 -type l); do \
	unlink $$file;	\
	done;

transfers.do: transfers.bfl
	xilbfc transfers.bfl



view:
	vsim -do "vsim -view result/wave.wlf; view wave; do wave.do"


clean: unlink 
	rm -rf \
	xilbfc.log \
	transfers.do \
	log \
	result


cleansim:
	rm -rf result
