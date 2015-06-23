# The Potato Processor - A simple RISC-V based processor for FPGAs
# (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
# Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

.PHONY: all clean checkout-riscv-tests potato.prj

SOURCE_FILES := \
	src/pp_alu.vhd \
	src/pp_alu_mux.vhd \
	src/pp_alu_control_unit.vhd \
	src/pp_icache.vhd \
	src/pp_comparator.vhd \
	src/pp_constants.vhd \
	src/pp_control_unit.vhd \
	src/pp_core.vhd \
	src/pp_counter.vhd \
	src/pp_csr.vhd \
	src/pp_csr_unit.vhd \
	src/pp_csr_alu.vhd \
	src/pp_decode.vhd \
	src/pp_execute.vhd \
	src/pp_fetch.vhd \
	src/pp_imm_decoder.vhd \
	src/pp_memory.vhd \
	src/pp_potato.vhd \
	src/pp_register_file.vhd \
	src/pp_types.vhd \
	src/pp_utilities.vhd \
	src/pp_wb_arbiter.vhd \
	src/pp_wb_adapter.vhd \
	src/pp_writeback.vhd
TESTBENCHES := \
	testbenches/tb_processor.vhd \
	testbenches/tb_soc.vhd \
	soc/pp_soc_memory.vhd

TOOLCHAIN_PREFIX ?= riscv64-unknown-elf

# ISA tests to use from the riscv-tests repository:
RISCV_TESTS += \
	simple \
	add \
	addi \
	and \
	andi \
	auipc \
	beq \
	bge \
	bgeu \
	blt \
	bltu \
	bne \
	jal \
	jalr \
	j \
	or \
	ori \
	sll \
	slli \
	slt \
	slti \
	sra \
	srai \
	srl \
	srli \
	sub \
	sb \
	sh \
	sw \
	xor \
	xori \
	lb \
	lbu \
	lh \
	lhu \
	lw

# Local tests to run:
LOCAL_TESTS ?= \
	scall \
	sbreak \
	sw-jal

all: potato.prj run-tests

potato.prj:
	-$(RM) potato.prj
	for file in $(SOURCE_FILES) $(TESTBENCHES); do \
		echo "vhdl work $$file" >> potato.prj; \
	done

copy-riscv-tests:
	for test in $(RISCV_TESTS); do \
		cp riscv-tests/$$test.S tests; \
	done

compile-tests: copy-riscv-tests
	test -d tests-build || mkdir tests-build
	for test in $(RISCV_TESTS) $(LOCAL_TESTS); do \
		echo "Compiling test $$test..."; \
		$(TOOLCHAIN_PREFIX)-gcc -c -m32 -march=RV32I -Iriscv-tests -o tests-build/$$test.o tests/$$test.S; \
		$(TOOLCHAIN_PREFIX)-ld -m elf32lriscv -T tests.ld tests-build/$$test.o -o tests-build/$$test.elf; \
		scripts/extract_hex.sh tests-build/$$test.elf tests-build/$$test-imem.hex tests-build/$$test-dmem.hex; \
	done

run-tests: potato.prj compile-tests
	for test in $(RISCV_TESTS) $(LOCAL_TESTS); do \
		echo -ne "Running test $$test:\t"; \
		DMEM_FILENAME="empty_dmem.hex"; \
		test -f tests-build/$$test-dmem.hex && DMEM_FILENAME="tests-build/$$test-dmem.hex"; \
		xelab tb_processor -generic_top "IMEM_FILENAME=tests-build/$$test-imem.hex" -generic_top "DMEM_FILENAME=$$DMEM_FILENAME" -prj potato.prj > /dev/null; \
		xsim tb_processor -R --onfinish quit > tests-build/$$test.results; \
		cat tests-build/$$test.results | awk '/Note:/ {print}' | sed 's/Note://' | awk '/Success|Failure/ {print}'; \
	done

run-soc-tests: potato.prj compile-tests
	for test in $(RISCV_TESTS) $(LOCAL_TESTS); do \
		echo -ne "Running SOC test $$test:\t"; \
		DMEM_FILENAME="empty_dmem.hex"; \
		test -f tests-build/$$test-dmem.hex && DMEM_FILENAME="tests-build/$$test-dmem.hex"; \
		xelab tb_soc -generic_top "IMEM_FILENAME=tests-build/$$test-imem.hex" -generic_top "DMEM_FILENAME=$$DMEM_FILENAME" -prj potato.prj > /dev/null; \
		xsim tb_soc -R --onfinish quit > tests-build/$$test.results-soc; \
		cat tests-build/$$test.results-soc | awk '/Note:/ {print}' | sed 's/Note://' | awk '/Success|Failure/ {print}'; \
	done

remove-xilinx-garbage:
	-$(RM) -r xsim.dir 
	-$(RM) xelab.* webtalk* xsim*

clean: remove-xilinx-garbage
	for test in $(RISCV_TESTS); do $(RM) tests/$$test.S; done
	-$(RM) -r tests-build
	-$(RM) potato.prj

distclean: clean

