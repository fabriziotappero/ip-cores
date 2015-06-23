--Require Modelsim
--Tested on Modelsim 6.5b Revison 2009.05
puts {
  ModelSimSE SD_HOST_CONTROLLER compile script version 1.1
  Copyright (c) Doulos June 2004,
  Modifed 2010, Adam Edvardsson, ORSoC
}

# Simply change the project settings in this section
# for each new project. There should be no need to
# modify the rest of the script.

set library_file_list {
                           design_library {
											../../../rtl/sdc_dma/verilog/sd_defines.v
											../../../rtl/sdc_dma/verilog/sd_bd.v
											../../../rtl/sdc_dma/verilog/sd_clock_divider.v
											../../../rtl/sdc_dma/verilog/sd_cmd_master.v
											../../../rtl/sdc_dma/verilog/sd_cmd_serial_host.v
											../../../rtl/sdc_dma/verilog/sdc_controller.v
											../../../rtl/sdc_dma/verilog/sd_controller_wb.v
											../../../rtl/sdc_dma/verilog/sd_crc_7.v
											../../../rtl/sdc_dma/verilog/sd_crc_16.v
											../../../rtl/sdc_dma/verilog/sd_data_serial_host.v
											../../../rtl/sdc_dma/verilog/sd_data_master.v
											../../../rtl/sdc_dma/verilog/sd_fifo_rx_filler.v
											../../../rtl/sdc_dma/verilog/sd_fifo_tx_filler.v
										
										}
										
                           test_library   {	../../../bench/sdc_dma/verilog/wb_model_defines.v
											../../../bench/sdc_dma/verilog/sd_controller_top_tb.v
											../../../bench/sdc_dma/verilog/sdModel.v                                           
											../../../bench/sdc_dma/verilog/timescale.v
											../../../bench/sdc_dma/verilog/wb_bus_mon.v
											../../../bench/sdc_dma/verilog/wb_master32.v
											../../../bench/sdc_dma/verilog/wb_master_behavioral.v											
											../../../bench/sdc_dma/verilog/wb_slave_behavioral.v
											../../../rtl/sdc_dma/verilog/sd_defines.v
											../../../rtl/sdc_dma/verilog/sd_bd.v
											../../../rtl/sdc_dma/verilog/sd_clock_divider.v
											../../../rtl/sdc_dma/verilog/sd_cmd_master.v
											../../../rtl/sdc_dma/verilog/sd_cmd_serial_host.v
											../../../rtl/sdc_dma/verilog/sdc_controller.v
											../../../rtl/sdc_dma/verilog/sd_controller_wb.v
											../../../rtl/sdc_dma/verilog/sd_crc_7.v
											../../../rtl/sdc_dma/verilog/sd_crc_16.v
											../../../rtl/sdc_dma/verilog/sd_data_serial_host.v
											../../../rtl/sdc_dma/verilog/sd_data_master.v
											../../../rtl/sdc_dma/verilog/sd_fifo_rx_filler.v
											../../../rtl/sdc_dma/verilog/sd_fifo_tx_filler.v
											../../../rtl/sdc_dma/verilog/sd_rx_fifo.v
											../../../rtl/sdc_dma/verilog/sd_tx_fifo.v
										}
}
set top_level              test_library.sd_controller_top_tb



set wave_patterns {
                           /*
}
set wave_radices {
                           hexadecimal {data q}
}

puts {
  Script commands are:

  r = Recompile changed and dependent files
 rr = Recompile everything
  q = Quit without confirmation
}
# After sourcing the script from ModelSim for the
# first time use these commands to recompile.

proc r  {} {uplevel #0 source compile.tcl}
proc rr {} {global last_compile_time
            set last_compile_time 0
            r                            }
proc q  {} {quit -force                  }

#Does this installation support Tk?
set tk_ok 1
if [catch {package require Tk}] {set tk_ok 0}

# Prefer a fixed point font for the transcript
set PrefMain(font) {Courier 10 roman normal}

# Compile out of date files
 set time_now [clock seconds]
 if [catch {set last_compile_time}] {
   set last_compile_time 0
 }
foreach {library file_list} $library_file_list {
  vlib $library
  vmap work $library
  foreach file $file_list {
    if { $last_compile_time < [file mtime $file] } {
      if [regexp {.vhdl?$} $file] {
        vcom -93 $file
      } else {
        vlog +incdir+../../../rtl/sdc_dma/verilog/ +incdir+../../../bench/sdc_dma/verilog/ $file
      }
      set last_compile_time 0
    }
  }
}
set last_compile_time $time_now

# Load the simulation
eval vsim $top_level

# If waves are required
if [llength $wave_patterns] {
  noview wave
  foreach pattern $wave_patterns {
    add wave $pattern
  }
  configure wave -signalnamewidth 1
  foreach {radix signals} $wave_radices {
    foreach signal $signals {
      catch {property wave -radix $radix $signal}
    }
  }
 # if $tk_ok {wm geometry .wave [winfo screenwidth .]x330+0-20}
}

# Run the simulation
 when {/sd_controller_top_tb/succes = 1} {stop}
 run -all
 

# If waves are required
if [llength $wave_patterns] {
  if $tk_ok {.wave.tree zoomfull}
}



# How long since project began?
if {[file isfile start_time.txt] == 0} {
  set f [open start_time.txt w]
  puts $f "Start time was [clock seconds]"
  close $f
} else {
  set f [open start_time.txt r]
  set line [gets $f]
  close $f
  regexp {\d+} $line start_time
  set total_time [expr ([clock seconds]-$start_time)/60]
  puts "Project time is $total_time minutes"
}


