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
        ;# Using OEM Version's ModelSIM .ini file (modelsim.ini at ModelSIM Altera installation directory)
} else {
        # Using non-OEM Version, compile all of the libraries
        vlib lpm_ver
        vmap lpm_ver lpm_ver 
        vlog -work lpm_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v 
 
        vlib altera_mf_ver
        vmap altera_mf_ver altera_mf_ver
        vlog -work altera_mf_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v
 
        vlib sgate_ver
        vmap sgate_ver sgate_ver
        vlog -work sgate_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.v
 
        vlib cycloneiv_hssi_ver
        vmap cycloneiv_hssi_ver cycloneiv_hssi_ver
        vlog -work cycloneiv_hssi_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/cycloneiv_hssi_atoms.v
 
}
 
# Create the work library
vlib work
 
# Now compile the Verilog files one by one 
 
vlog -work work ../../sgmii.vo
vlog -work work ../model/*.v
vlog -work work *.v
 
# Now run the simulation 
vsim \
-novopt\
+transport_int_delays \
+transport_path_delays \
+notimingchecks \
-L altera_mf_ver -L lpm_ver -L sgate_ver  -L cycloneiv_hssi_ver\
-t ps \
-noglitch \
-multisource_delay latest \
tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1 
onbreak { resume } 
do sgmii_wave.do
run -all
 
