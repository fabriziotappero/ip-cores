
################################################################################
# some environment variables
################################################################################
MODULE          := key_schedule                   # the module name  
TEST_TIMES      := 1                              # check times
DEBUG           := n                              # whether debug is enable


################################################################################
TEST_IN_FILE    := test_dat/$(MODULE).in



################################################################################
# depend
################################################################################

all:bench sw_sim rtl

.PHONY: rtl
rtl:
	@echo compiling rtl ...
	@make -s -C rtl    PROJ_NAME=$(MODULE) DEBUG=$(DEBUG)
 
.PHONY: bench
bench:
	@echo compiling bench ...
	@make -s -C bench  PROJ_NAME=$(MODULE) DEBUG=$(DEBUG)

.PHONY: sw_sim
sw_sim:
	@echo compiling sw_sim ...
	@make -s -C sw_sim PROJ_NAME=$(MODULE) DEBUG=$(DEBUG)

preare_bin_fn =                                              \
        str="" ;                                             \
        for ((i=0;i<$1;i=i+1));                              \
        do                                                   \
                n=$$(expr $$RANDOM % 256 )    ;              \
                binstr=$$(echo "ibase=10;obase=16;$$n"|bc) ; \
                binstr=$$(echo "000: $$binstr " | xxd -r );  \
                str+=$$binstr ;                              \
        done          ;                                      \
        echo -n $$str  >$(TEST_IN_FILE)  ;             

prepare_block_decypher:
	$(call preare_bin_fn,64)

prepare_key_perm:
	$(call preare_bin_fn,8)

prepare_key_schedule:
	$(call preare_bin_fn,8)

prepare_group_decrypt:
	$(call preare_bin_fn,192)

prepare_stream_cypher:
	$(call preare_fn,24)
        
check:
	@(for ((i=0;i<$(TEST_TIMES);i=i+1))                                       \
                do                                                                \
                        make -s preare_$(MODULE);                                 \
                        make -s -C sw_sim test PROJ_NAME=$(MODULE);               \
                        make -s -C bench test PROJ_NAME=$(MODULE);                \
                        diff test_dat/$(MODULE).out.sw test_dat/$(MODULE).out.v ; \
                done)

clean:
	echo clean sw_sim
	@make -s -C sw_sim clean
	echo clean rtl
	@make -s -C rtl clean
	echo clean bench
	@make -s -C bench clean
	@rm -fr test_dat/*

cscope:
	@find . -name "*.[ch]" >cscope.files
	@cscope -b

help:
	@echo "avaliable make tagers:"
	@echo "help                  --- display this help information"
	@echo "prepare_<module_name> --- prepare the input data for test the module"
	@echo "all                   --- compile the rtl bench and c programs, don't run test"
	@echo "check                 --- run test"
	@echo "clean                 --- remove the compiled file"
	@echo "cscope                --- gernerate a cscope file for c files( i use vim )"
	@echo "avaliable make variable:"
	@echo "MODULE                --- the current module name"
	@echo "TEST_TIMES            --- check times"
	@echo "DEBUG                 --- whether enable debug"


