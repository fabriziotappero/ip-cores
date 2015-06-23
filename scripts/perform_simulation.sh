#!/bin/bash
#
# Author: Matthias Alles
# Date  : 2012/01/05
# Short : Create simulation library and run simulation in console mode.
#

# Create target library
vlib dec_viterbi
vmap dec_viterbi ./dec_viterbi

# Compile source files
vcom -work dec_viterbi ../packages/pkg_helper.vhd
vcom -work dec_viterbi ../packages/pkg_param.vhd
vcom -work dec_viterbi ../packages/pkg_param_derived.vhd
vcom -work dec_viterbi ../packages/pkg_types.vhd
vcom -work dec_viterbi ../packages/pkg_components.vhd
vcom -work dec_viterbi ../packages/pkg_trellis.vhd
vcom -work dec_viterbi ../src/generic_sp_ram.vhd
vcom -work dec_viterbi ../src/axi4s_buffer.vhd
vcom -work dec_viterbi ../src/branch_distance.vhd
vcom -work dec_viterbi ../src/traceback.vhd
vcom -work dec_viterbi ../src/acs.vhd
vcom -work dec_viterbi ../src/ram_ctrl.vhd
vcom -work dec_viterbi ../src/reorder.vhd
vcom -work dec_viterbi ../src/recursion.vhd
vcom -work dec_viterbi ../src/dec_viterbi.vhd
vcom -work dec_viterbi ../testbench/txt_util.vhd
vcom -work dec_viterbi ../testbench/pkg_tb_fileio.vhd
vcom -work dec_viterbi ../testbench/tb_dec_viterbi.vhd

# Run simulation
vsim dec_viterbi.tb_dec_viterbi -c -do "run -all; exit"

