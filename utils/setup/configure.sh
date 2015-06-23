. ${SCRIPT_DIR}/beautify.sh

#Configuring MinSoC
cecho "\nConfiguring MinSoC"
execcmd "cd ${DIR_TO_INSTALL}/minsoc/backend/std"
execcmd "Configuring MinSoC as standard board (simulatable but not synthesizable)" "./configure"
execcmd "cd ${DIR_TO_INSTALL}"

#Compiling and moving adv_jtag_bridge debug modules for simulation
execcmd "cd ${DIR_TO_INSTALL}/minsoc/rtl/verilog/adv_debug_sys/Software/adv_jtag_bridge/sim_lib/icarus"
execcmd "Compiling VPI interface to connect GDB with simulation" "make"
execcmd "cp jp-io-vpi.vpi ${DIR_TO_INSTALL}/minsoc/bench/verilog/vpi"
