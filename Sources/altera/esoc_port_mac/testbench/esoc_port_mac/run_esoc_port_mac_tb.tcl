# Copyright (C) 1991-2008 Altera Corporation
# Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
# support information,  device programming or simulation file,  and any other
# associated  documentation or information  provided by  Altera  or a partner
# under  Altera's   Megafunction   Partnership   Program  may  be  used  only
# to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
# other  use  of such  megafunction  design,  netlist,  support  information,
# device programming or simulation file,  or any other  related documentation
# or information  is prohibited  for  any  other purpose,  including, but not
# limited to  modification,  reverse engineering,  de-compiling, or use  with
# any other  silicon devices,  unless such use is  explicitly  licensed under
# a separate agreement with  Altera  or a megafunction partner.  Title to the
# intellectual property,  including patents,  copyrights,  trademarks,  trade
# secrets,  or maskworks,  embodied in any such megafunction design, netlist,
# support  information,  device programming or simulation file,  or any other
# related documentation or information provided by  Altera  or a megafunction
# partner, remains with Altera, the megafunction partner, or their respective
# licensors. No other licenses, including any licenses needed under any third
# party's intellectual property, are provided herein.

global env ;
if [regexp {ModelSim ALTERA} [vsim -version]] {
        ;# Using OEM Version?s ModelSIM .ini file (modelsim.ini at ModelSIM Altera installation directory)
} else {
        # Using non-OEM Version, compile all of the libraries
        vlib lpm
        vmap lpm lpm 
        vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220pack.vhd
        vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.vhd 
 
        vlib altera_mf
        vmap altera_mf altera_mf
        vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf_components.vhd
        vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.vhd
 
        vlib sgate
        vmap sgate sgate
        vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate_pack.vhd
        vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.vhd
 
}
 
# Create the work library
vlib work
 
# Now compile the VHDL files one by one 
 
vcom -work work -93 ../../esoc_port_mac.vho
vcom -work work -93 ../model/*.vhd
vcom -work work -93 *.vhd
 
 
# Now run the simulation 
vsim\
-novopt\
-t ps\
-GTB_RXFRAMES="0"\
-GTB_MACINSERT_ADDR="false"\
-GTB_PROMIS_ENA="true"\
tb
 
set NumericStdNoWarnings 1
set StdArithNoWarnings 1 
onbreak { resume } 
do esoc_port_mac_wave.do
run -all
 
