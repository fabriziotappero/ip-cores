quietly set ACTELLIBNAME proasic3
do PATH.do

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   vlib presynth
}
vmap presynth presynth
vmap proasic3 "C:/Actel/Libero_v9.1/Designer/lib/modelsim/precompiled/vhdl/proasic3"

vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_Usefull_Pkg.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_Toggle.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_Interrupt.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_ProgramCounter.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_Stack.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_ProgramFlowControl.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_FullAdder.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_CLAAdder.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_Alu.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_Flags.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_BancRegister.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_ScratchPad.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_DecodeControl.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_copyBlaze.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_ROM_Code.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/rtl/vhdl/cp_copyBlaze_ecoSystem.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/sim/rtl_sim/src/wb_timer/wb_timer_8.vhd"
vcom -93 -explicit -work presynth "C:/Users/AbdAllah/Documents/mP/mP/copyblaze/copyblaze/bench/vhdl/tb_copyBlaze_ecoSystem_wb-timer.vhd"

vsim -L proasic3 -L presynth  -t 1ps presynth.tb_copyBlaze_ecoSystem_wb_timer
# The following lines are commented because no testbench is associated with the project
# add wave /testbench/*
# run 1000ns

do tb_copyBlaze_ecoSystem_wb-timer_wave.do

run -all
