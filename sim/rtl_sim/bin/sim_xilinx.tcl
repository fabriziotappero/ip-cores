# Usage:
# cd /versatile_mem_ctrl/trunk/sim/rtl_sim/run/
# vsim -gui -do ../bin/sim_xilinx.tcl

set DESIGN_NAME "versatile_memory_controller"
set WAVE_FILE wave_ddr.do
set FORCE_LIBRARY_RECOMPILE 0

# Quit simulation if you are running one
quit -sim

# Create and open project
if {[file exists ${DESIGN_NAME}_sim_xilinx.mpf]} {
project open ${DESIGN_NAME}_sim_xilinx
} else {
project new . ${DESIGN_NAME}_sim_xilinx
}

# Compile Xilinx libraries
if {![file exists unisims_ver] || $FORCE_LIBRARY_RECOMPILE} {
vlib unisims_ver
vmap unisims_ver unisims_ver
vlog -work unisims_ver /opt/Xilinx/11.1/ISE/verilog/src/unisims/*.v
}
if {![file exists simprims_ver] || $FORCE_LIBRARY_RECOMPILE} {
vlib simprims_ver
vmap simprims_ver simprims_ver
vlog -work simprims_ver /opt/Xilinx/11.1/ISE/verilog/src/simprims/*.v
}
if {![file exists xilinxcorelib_ver] || $FORCE_LIBRARY_RECOMPILE} {
vlib xilinxcorelib_ver
vmap xilinxcorelib_ver xilinxcorelib_ver
vlog -work xilinxcorelib_ver /opt/Xilinx/11.1/ISE/verilog/src/XilinxCoreLib/*.v
}

# Compile the glbl.v module
vlog /opt/Xilinx/11.1/ISE/verilog/src/glbl.v

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
vsim -gui -novopt -L unisims_ver -L xilinxcorelib_ver work.versatile_mem_ctrl_tb work.glbl

# Open waveform viewer
view wave -title "${DESIGN_NAME}"

# Open signal viewer
view signals

# Run the .do file to load signals to the waveform viewer
do $WAVE_FILE

# Run the simulation
run 330 us

