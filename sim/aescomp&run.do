# Simple script to automate the verification process

#------------------------------------------------------------------------------
#    Project directory settings (Put your actual directory paths here)
#------------------------------------------------------------------------------
set proj_dir "d:/cvsroot/aes128"
set sim_dir "$proj_dir/sim"
set rtl_dir "$proj_dir/rtl"
set tb_dir "$proj_dir/tb"


#------------------------------------------------------------------------------
#    Project compile variable settings
#    0 -> disabled; 1 -> enabled
#------------------------------------------------------------------------------
set compile_rtl 1
set compile_tb  1


#------------------------------------------------------------------------------
#    Compile RTL and TB modules
#------------------------------------------------------------------------------
cd $sim_dir
if {$compile_rtl == 1} then {
vcom -work work $rtl_dir/aes_package.vhd
vcom -work work $rtl_dir/key_expander.vhd
vcom -work work $rtl_dir/aes128_fast.vhd
}
if {$compile_tb == 1} then {
vcom -work work $tb_dir/aes_tb_package.vhd
vcom -work work $tb_dir/aes_tester.vhd
vcom -work work $tb_dir/aes_fips_tester.vhd
vcom -work work $tb_dir/aes_fips_mctester.vhd
}

#------------------------------------------------------------------------------
#    Test variable settings (can run only one test at a time)
#    0 -> disabled; 1 -> enabled
#    Set the "mode_tb" and "indicator" in aes_tester.vhd before choosing sim_aes_tester
#-------------------------------------------------------------------------------
set sim_aes_tester 0
set sim_aes_fips_tester 0
set sim_aes_fips_mctester 0


#------------------------------------------------------------------------------
#    Simulation
#------------------------------------------------------------------------------
if {$sim_aes_tester == 1} then {
  vsim work.aes_tester
  run 17 us
  quit -sim
} elseif {$sim_aes_fips_tester == 1} then {
  vsim work.aes_fips_tester
  run 2 ms
  quit -sim
} elseif {$sim_aes_fips_mctester == 1} then {
  vsim work.aes_fips_mctester
  run 8 sec
  quit -sim
}



