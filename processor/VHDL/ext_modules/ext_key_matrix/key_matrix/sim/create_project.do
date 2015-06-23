file delete -force ../../modelsim
file mkdir ../../modelsim
cd ../../modelsim
project new . key_matrix
project addfolder scripts
project addfolder sim
project addfolder key_matrix
project addfolder testbench_util
project addfolder math
project addfolder debounce
project addfolder sync
project addfile ../src/sim/key_matrix_tb.vhd vhdl sim
project addfile ../src/key_matrix.vhd vhdl key_matrix
project addfile ../src/key_matrix_beh.vhd vhdl key_matrix
project addfile ../src/key_matrix_pkg.vhd vhdl key_matrix
project addfile ../../testbench_util/src/testbench_util_pkg.vhd vhdl testbench_util
project addfile ../../math/src/math_pkg.vhd vhdl math
project addfile ../../debounce/src/debounce.vhd vhdl debounce
project addfile ../../debounce/src/debounce_struct.vhd vhdl debounce
project addfile ../../debounce/src/debounce_fsm.vhd vhdl debounce
project addfile ../../debounce/src/debounce_fsm_beh.vhd vhdl debounce
project addfile ../../debounce/src/debounce_pkg.vhd vhdl debounce
project addfile ../../synchronizer/src/sync.vhd vhdl sync
project addfile ../../synchronizer/src/sync_beh.vhd vhdl sync
project addfile ../../synchronizer/src/sync_pkg.vhd vhdl sync
project addfile ../src/sim/sim_all.do tcl scripts
project addfile ../src/sim/sim_restart.do tcl scripts
project addfile ../src/sim/sim_quit.do tcl scripts
project calculateorder
