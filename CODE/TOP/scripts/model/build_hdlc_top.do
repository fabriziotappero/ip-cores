vlib work
vlib utility
vlib hdlc
vlib memLib

vmap work
vmap utility
vmap hdlc
vmap memLib


# Utility files
vcom -work utility  ../code/tools_pkg.vhd


#memLib
vcom -work memLib ../code/spmem.vhd 

vcom -work memLib  ../code/mem_pkg.vhd 


#HDLC files
vcom -work hdlc  ../code/libs/PCK_CRC16_D8.vhd

vcom -work hdlc  ../code/libs/hdlc_components_pkg.vhd

#Work files
#Rx
vcom -work work  ../code/TOP/core/RxFCS.vhd

vcom -work work  ../code/TOP/core/RxBuff.vhd -explicit

vcom -work work  ../code/Rx/core/Zero_detect.vhd

vcom -work work  ../code/Rx/core/flag_detect.vhd

vcom -work work  ../code/Rx/core/Rxcont.vhd


vcom -work work  ../code/Rx/core/RxChannel.vhd

vcom -work work  ../code/TOP/core/RxSync.vhd


#Tx
vcom -work work  ../code/TOP/core/TxFCS.vhd

vcom -work work  ../code/TOP/core/TxBuff.vhd -explicit

vcom -work work  ../code/Tx/core/flag_ins.vhd

vcom -work work  ../code/Tx/core/zero_ins.vhd

vcom -work work  ../code/Tx/core/TXcont.vhd


vcom -work work  ../code/Tx/core/TxChannel.vhd

vcom -work work  ../code/TOP/core/TxSync.vhd


#WB and host
vcom -work work  ../code/TOP/core/WB_IF.vhd

vcom -work work  ../code/TOP/core/hdlc.vhd

# Test bench
vcom -work work  ../code/TOP/tb/hdlc_tb.vhd -explicit


