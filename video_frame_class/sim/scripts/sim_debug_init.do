# ------------------------------------
#
# ------------------------------------

do ../../scripts/sim_procs.do

global env

set env(SIM_TARGET) rtl


radix -hexadecimal

# do ./setup_test.do
# sim_compile_all rtl
sim_run_test



