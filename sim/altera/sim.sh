quit -sim
vlib work
vdel -lib work -all
vlib work

set sim_started 0

# compile vendor independent files
vlog -work work ../../rtl/up_monitor.v +initreg+0
vlog -work work ../../rtl/up_monitor_wrapper.v +initreg+0

# compile altera virtual jtag files
source virtual_jtag_stimulus.tcl
vlog -work work ../../rtl/altera/virtual_jtag_adda_fifo.v +incdir+../../rtl/altera
vlog -work work ../../rtl/altera/virtual_jtag_adda_trig.v +incdir+../../rtl/altera
vlog -work work ../../rtl/altera/virtual_jtag_addr_mask.v +incdir+../../rtl/altera
vlog -work work altera_mf.v

# compile testbench files
vlog -work work -sv ../up_monitor_tb.v

# compile register bfm files
vlog -work work -sv ../reg_bfm_sv.v

# compile cpu bfm files
# Sytemverilog DPI steps to combine sv and c
# step 1: generate dpiheader.h
vlog -work work -sv -dpiheader ../dpiheader.h ../up_bfm_sv.v
## step 2: generate up_bfm_sv.obj
#vsim -dpiexportobj up_bfm_sv up_bfm_sv
# step 3: generate up_bfm_c.o
gcc -c -I $::env(MODEL_TECH)/../include ../up_bfm_c.c
# step 4: generate up_bfm_c.dll
gcc -shared -Bsymbolic -o up_bfm_c.so up_bfm_c.o

# compile jtag bfms files
vlog -work work -sv jtag_bfm_sv.v +incdir+../../rtl/altera

vsim -novopt \
     -sv_lib up_bfm_c \
     -t ps \
     up_monitor_tb 

set sim_started 1

log -r */*
radix -hexadecimal
do wave.do

run 10000ns
