VCOM    = /usr/local/bin/vcom 
VCOMOPS = -explicit -check_synthesis -2002 -quiet 
#MAKEFLAGS = --silent
HDL_DIR = ../rtl/VHDL/


##
# avs_aes hdl files
##
AVS_AES_SRC =$(HDL_DIR)avs_aes_pkg.vhd \
		 $(HDL_DIR)mux2.vhd \
	 	 $(HDL_DIR)mux3.vhd \
		 $(HDL_DIR)memory_word.vhd \
		 $(HDL_DIR)addroundkey.vhd \
		 $(HDL_DIR)aes_fsm_encrypt.vhd \
		 $(HDL_DIR)aes_fsm_decrypt.vhd \
		 $(HDL_DIR)keyexpansionV2.vhd \
		 $(HDL_DIR)mixcol.vhd \
		 $(HDL_DIR)mixcol_fwd.vhd \
		 $(HDL_DIR)mixcol_inv.vhd \
		 $(HDL_DIR)sbox.vhd \
		 $(HDL_DIR)sboxM4k.vhd \
		 $(HDL_DIR)shiftrow.vhd \
		 $(HDL_DIR)shiftrow_fwd.vhd \
		 $(HDL_DIR)shiftrow_inv.vhd \
		 $(HDL_DIR)aes_core.vhd \
		 $(HDL_DIR)avs_aes.vhd \

##
# Testbench HDL file
##
TB_SRC_DIR = ../bench/VHDL/
AVS_AES_TB_SRC =  $(TB_SRC_DIR)avs_aes_tb.vhd 

#######################################
all: simaes

clean:
	rm -rf .deps
	rm -rf *_lib

.deps: 
	mkdir .deps > /dev/null 2>&1

avs_aes_lib: 
	vlib avs_aes_lib

work:
	vlib work

libs: avs_aes_lib work

avs_aes: .deps avs_aes_lib .deps/avs_aes
.deps/avs_aes: $(AVS_AES_SRC)  
	@echo --
	@echo building AVS_AES
	@echo --
	$(VCOM) $(VCOMOPS) -work avs_aes_lib  $^
	touch .deps/avs_aes

avs_aes_tb: .deps .deps/avs_aes .deps/avs_aes_tb
.deps/avs_aes_tb: work $(AVS_AES_TB_SRC)
	@echo --
	@echo building AVS_AES Testbench
	@echo --
	$(VCOM) $(VCOMOPS) -work work  $^
	touch .deps/avs_aes_tb



simaes: avs_aes avs_aes_tb 
	vsim -title "Avalon AES Slave Test" -do avs_aes_tb.do -lib work avs_aes_tb
