vlib work
vmap work work

vlib altera
vmap altera work

vlib stratixii
vmap stratixii work 

vlib altera_mf
vmap altera_mf work

set ALTERA_LIB_PATH /opt/altera/10.0/quartus/eda/sim_lib

vcom  -work altera_mf $ALTERA_LIB_PATH/altera_mf_components.vhd
vcom  -work altera_mf $ALTERA_LIB_PATH/altera_mf.vhd

vcom  -work stratixii $ALTERA_LIB_PATH/stratixii_atoms.vhd
vcom  -work stratixii $ALTERA_LIB_PATH/stratixii_components.vhd

do compile.do