### start simulation

vsim -t ps -novopt +notimingchecks -L unisim work.virtex7_dma_top

onerror {resume}
#Log all the objects in design. These will appear in .wlf file#
log -r /*

### Load waveforms
#add wave sim:/sim_tb_top/inst_BufferMemoryController/*
do wave.do

###Change radix to Hexadecimal
radix hex
#Supress Numeric Std package and Arith package warnings.#
#For VHDL designs we get some warnings due to unknown values on some signals at startup#
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0#
#We may also get some Arithmetic packeage warnings because of unknown values on#
#some of the signals that are used in an Arithmetic operation.#
#In order to suppress these warnings, we use following two commands#
set NumericStdNoWarnings 1
set StdArithNoWarnings 1


#Choose simulation run time by inserting a breakpoint and then run for specified #
#period. For more details, refer to user guide (UG406).#
#when {/BufferMemoryController_tb/inst_BufferMemoryController/MIG_PHY_init_done = 1} {
#if {[when -label a_100] == ""} {
#when -label a_100 { $now = 50 us } {
#nowhen a_100
#report simulator control
#report simulator state
#if {[examine /sim_tb_top/error] == 0} {
#echo "TEST PASSED"
#stop
#}
#if {[examine /sim_tb_top/error] != 0} {
#echo "TEST FAILED: DATA ERROR"
#stop
#}
#}
#}
#}

#Wait for calibration to complete before sending own stimuli#
#when -label calibration {/sim_tb_top/inst_BufferMemoryController/mig_phy_init_done = 1} {
#echo "CALIBRATION COMPLETE!"
#stop
#abort
#}

#nowhen calibration

### Run stimuli 
#run 100 ns
#do stimuli_dma_write_CH0_req.tcl

#run -all
#stop

