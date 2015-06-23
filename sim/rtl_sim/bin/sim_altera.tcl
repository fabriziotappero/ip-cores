# Usage:
# cd /versatile_mem_ctrl/trunk/sim/rtl_sim/run/
# vsim -gui -do ../bin/sim_altera.tcl

set DESIGN_NAME "versatile_memory_controller"
set WAVE_FILE ../bin/wave_ddr.do
set FORCE_LIBRARY_RECOMPILE 0

# Quit simulation if you are running one
quit -sim

# Create and open project
if {[file exists ${DESIGN_NAME}_sim_altera.mpf]} {
project open ${DESIGN_NAME}_sim_altera
} else {
project new . ${DESIGN_NAME}_sim_altera
}

# Compile Altera libraries
if {![file exists altera_primitives] || $FORCE_LIBRARY_RECOMPILE} {
vlib altera_primitives
vmap altera_primitives altera_primitives
#vlog -work altera_primitives /opt/altera9.1/quartus/eda/sim_lib/altera_primitives.v
vcom -work altera_primitives /opt/altera9.1/quartus/eda/sim_lib/altera_primitives_components.vhd
vcom -work altera_primitives /opt/altera9.1/quartus/eda/sim_lib/altera_primitives.vhd
}
if {![file exists altera_mf] || $FORCE_LIBRARY_RECOMPILE} {
vlib altera_mf
vmap altera_mf altera_mf
#vlog -work altera_mf /opt/altera9.1/quartus/eda/sim_lib/altera_mf.v
vcom -work altera_mf /opt/altera9.1/quartus/eda/sim_lib/altera_mf_components.vhd
vcom -work altera_mf /opt/altera9.1/quartus/eda/sim_lib/altera_mf.vhd
}
if {![file exists lpm] || $FORCE_LIBRARY_RECOMPILE} {
vlib lpm
vmap lpm lpm
vlog -work lpm /opt/altera9.1/quartus/eda/sim_lib/220model.v
}

# Compile project source code
vlog ../../../rtl/verilog/versatile_mem_ctrl_ip.v +incdir+../../../rtl/verilog/

# Compile test bench source code
vlog ../../../bench/ddr/ddr2.v +incdir+../../../bench/ddr/
vlog ../../../bench/wb0_ddr.v ../../../bench/wb1_ddr.v ../../../bench/wb4_ddr.v +define+x16 ../../../bench/tb_top.v +incdir+../../../bench/

# Quit without asking
set PrefMain(forceQuit) 1

# Invoke the simulator
# -gui      Open the GUI without loading a design
# -novopt   Force incremental mode (pre-6.0 behavior)
# -L        Search library for design units instantiated from Verilog and for VHDL default component binding
vsim -gui -novopt -L altera_mf -L lpm work.versatile_mem_ctrl_tb

# Open waveform viewer
view wave -title "${DESIGN_NAME}"

# Open signal viewer
view signals

# Run the .do file to load signals to the waveform viewer
do $WAVE_FILE

# Run the simulation
run 330 us

