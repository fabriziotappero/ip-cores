## $Id: gost28147-89.tcl 13 2012-03-22 11:02:55Z Doka $
## From Russia with love

####################################################################
#    This file is part of the GOST 28147-89 CryptoCore project     #
#                                                                  #
#    Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)   # 
####################################################################

set name_tb "gost28147-89_tb"
set timesim 2500ns
#set timesim 1000us

#####################################################
## path to verilog source code
set dir_src ../../rtl/verilog

## path to testbenches dir
set dir_sim ../../sim/src

## path to script dir
set dir_script ../bin

## path to work  dir
set dir_work ../run

## set include file dirs
set dir_inc  $dir_src+$dir_sim+../../rtl/tech

## set project defines
set DEFINE GOST_R_3411_TESTPARAM

#####################################################
quit -sim
vlib work
vlog +define+$DEFINE +incdir+$dir_inc -sv  $dir_src/gost28147-89.sv
vlog +define+$DEFINE +incdir+$dir_inc -sv  $dir_sim/$name_tb.sv
vsim -novopt +notimingchecks -wlfdeleteonquit -t 1ns    work.tb

#####################################################
radix -decimal
radix -unsigned
view wave

add wave -color {indian red}  -binary clk rst 
add wave -color {violet}  -hex clk_counter(7:0)
add wave -divider { - key - }
add wave -color {orange}  -hex key kload 

add wave -divider { - u - }
add wave -color {aquamarine}  -hex /u_cipher/a /u_cipher/b 
add wave -color {pink}  -hex /u_cipher/state_*

add wave -divider { - state cycles - }
add wave -color {cyan}  -dec -unsigned /u_cipher/i /u_cipher/kindex
add wave  /u_cipher/mode

add wave -divider { - IN - }
add wave -color {violet}  -hex   load pdata

add wave -divider { - OUT - }
add wave -color {cyan}  -hex   done cdata  reference_data

add wave -divider { - EQUAL - }
add wave  EQUAL
add wave  -color {aquamarine} -ascii STATUS

add wave -divider { - KEY - }
add wave -color {indian red}  -hex  /u_cipher/K(0) /u_cipher/K(1) /u_cipher/K(2) /u_cipher/K(3) /u_cipher/K(4)  /u_cipher/K(5) /u_cipher/K(6) /u_cipher/K(7) 

add wave -divider { - data - }
add wave -color {orange} -hex  pdata
add wave -color {orange} -hex  cdata

#####################################################
run $timesim 
#WaveRestoreZoom 400ns  $timesim 
WaveRestoreZoom 0ns  800ns








