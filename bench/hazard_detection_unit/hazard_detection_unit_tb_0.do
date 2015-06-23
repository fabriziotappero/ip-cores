quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/hazard_detection_unit.v
vlog  +incdir+../rtl ../bench/hazard_detection_unit/hazard_detection_unit_tb_0.v

vsim -t 1ps -novopt -lib work hazard_detection_unit_tb_0_v
view wave
add wave *
view structure
view signals
run -all
