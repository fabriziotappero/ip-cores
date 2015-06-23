vlib work
vlog -work work ../../rtl/rtc/rtc.v +initreg+0
vlog -work work rtc_timer_tb.v
vsim -novopt work.rtc_timer_tb

log -r */*
radix -hexadecimal
do wave.do

run -all
