#!/bin/sh
SRCROOT=../../../rtl/vhdl
TBROOT=../../../bench/vhdl
ghdl -a --ieee=synopsys $SRCROOT/aes_pkg.vhdl
ghdl -a --ieee=synopsys $SRCROOT/sbox.vhdl
ghdl -a --ieee=synopsys $SRCROOT/subsh.vhdl
ghdl -a --ieee=synopsys $SRCROOT/mixcol.vhdl
ghdl -a --ieee=synopsys $SRCROOT/colmix.vhdl
ghdl -a --ieee=synopsys $SRCROOT/keysched1.vhdl
ghdl -a --ieee=synopsys $SRCROOT/addkey.vhdl
ghdl -a --ieee=synopsys $SRCROOT/aes_top.vhdl
ghdl -a --ieee=synopsys $TBROOT/tb_aes.vhdl
ghdl -e --ieee=synopsys tb_aes
./tb_aes
ghdl --clean
