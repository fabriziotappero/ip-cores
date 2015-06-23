# Remove all old libraries
echo Cleaning old libraries
vdel -lib work -all -verbose
vdel -lib utility -all -verbose
vdel -lib hdlc -all -verbose
vdel -lib memLib -all -verbose
# Build
echo building new libraries
vlib work
vlib utility
vlib hdlc
vlib memLib
echo mapping new libraries
vmap work work
vmap utility utility
vmap hdlc hdlc
vmap memLib memLib
# Compile files
# Utility Files
vcom -work utility tools_pkg.vhd
#hdlc lib files
vcom -work hdlc PCK_CRC16_D8.vhd

#memLib lib files
vcom -work memLib spmem.vhd
vcom -work memLib mem_pkg.vhd

#Core files
vcom -work work TxFCS.vhd
vcom -work work TxBuff.vhd

#Simulation core files
vcom -work work TxTop_tb.vhd

#Load 
#vsim work.txtop_ent_tb 
