# ------------------------------------
#
# ------------------------------------


# ------------------------------------
#
proc sim_compile_all { target } {

  global env

  set env(ROOT_DIR) ../../../..
  set env(PROJECT_DIR) ../../..
  set env(SIM_TARGET) $target

  if {[file exists work/_info]} {
     echo "INFO: Simulation library work already exists"
     echo "INFO: deleting ./work and recompiling all"
     file delete -force ./work
     vlib work
  } else {
     vlib work
  }

  if { [file exists ../../libs/altera_sim.f] } {
    vlog -O0 -f ../../libs/altera_sim.f
  } elseif {[file exists ../../libs/xilinx_sim.f]} {
    vlog -O0 -f ../../libs/xilinx_sim.f
  }

  foreach filename [glob -nocomplain -directory ../../libs/FPGA_verilog/ *.f] {
    echo "INFO: compiling $filename"
    vlog -O0 -f $filename
  }
  
  foreach filename [glob -nocomplain -directory ../../libs/FPGA_VHDL/ *.f] {
    echo "INFO: compiling $filename"
    vcom -explicit -O0 -f $filename
  }
  
  foreach filename [glob -nocomplain -directory ../../libs/sim_verilog/ *.f] {
    echo "INFO: compiling $filename"
    vlog -O0 -f $filename
  }
  
  foreach filename [glob -nocomplain -directory ../../libs/sim_VHDL/ *.f] {
    echo "INFO: compiling $filename"
    vcom -explicit -O0 -f $filename
  }
  
  switch $target {

    "rtl"   {
              echo "INFO: compiling FPGA rtl"
              foreach filename [glob -nocomplain -directory ../../libs/FPGA/ *.f] {
                echo "INFO: compiling $filename"
                # vlog -O0 -f $filename
                vcom -93 -explicit -O0 -f $filename
              }
            }

    default {
              echo "ERROR: <$target> Target not suported!!!"
            }
  }

}


# ------------------------------------
#
proc sim_run_sim {  } {

  if {[file exists ./sim.do]} {
    do ./sim.do
  } elseif {[file exists ../../libs/sim.do]} {
    do ../../libs/sim.do
  } elseif {[file exists ../../libs/altera_sim.f]} {
    vsim -novopt -f ../../libs/altera_sim.f -l transcript.txt work.tb_top
  } elseif {[file exists ../../libs/xilinx_sim.f]} {
    vsim -novopt -f ../../libs/xilinx_sim.f -l transcript.txt work.tb_top work.glbl
  }
  
  if { [file exists ./wave.do] } {
     do ./wave.do
  }
}


# ------------------------------------
#
proc sim_run_test {  } {

  global env

  if { [file exists work/_info] } {
    echo "INFO: Simulation library work already exists"
  } else {
    vlib work
  }

  # unique setup
  if { [file exists ./setup_test.do] } {
     do ./setup_test.do
  }

  if { [info exists env(MAKEFILE_TEST_RUN)] } {

     vlog +define+MAKEFILE_TEST_RUN ../../src/tb_top.v

  } else {

      sim_run_sim
  }

  run -all

}


# ------------------------------------
#
proc sim_restart {  } {

  global env

  # work in progress files to compile
  if { [file exists ./wip.do] } {
    echo "INFO: found ./wip.do"
    do ./wip.do
  } else {

    sim_compile_all $::env(SIM_TARGET)
  }
  
  if { [string equal nodesign [runStatus]] } {
    sim_run_sim
  } else {
    restart -force
  }

  run -all

}


