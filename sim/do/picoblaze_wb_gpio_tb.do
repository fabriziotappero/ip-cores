################################################################################
## This sourcecode is released under BSD license.
## Please see http://www.opensource.org/licenses/bsd-license.php for details!
################################################################################
##
## Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without 
## modification, are permitted provided that the following conditions are met:
##
##  * Redistributions of source code must retain the above copyright notice, 
##    this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above copyright notice,
##    this list of conditions and the following disclaimer in the documentation
##    and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
## POSSIBILITY OF SUCH DAMAGE.
##
################################################################################
## filename: picoblaze_wb_gpio_tb.do
## description: ModelSim (R) do-macro / tcl-script for picoblaze_wb_gpio_tb hdl 
##              testbench
## todo4user: modify working directory and hdl variables 
## version: 0.0.0
## changelog: - 0.0.0, initial release
##            - ...
################################################################################

# IMPORTANT NOTICE!
# Verilog (R) simulation flow requires Xilinx (R) ISE (R) to be installed.

# user settings: preferred hdl, working directory and Xilinx (R) ISE (R)
# installation path (needed for Verilog (R) simulation)
set wd "d:/projects/wb4pb/sim"
set isVHDL yes
set XILINX_ISE_PATH "c:/xilinx/13.1"

# working directory cannot be changed while simulation is running
if {![string equal -nocase [pwd] $wd]} {
  quit -sim
  cd $wd
}

# creating library work, if not existing
if {[glob -nocomplain -types d "work"] == {}} {
  vlib work
}

# compiling hdl modules and starting simulator
if {$isVHDL} {

  vcom -check_synthesis "../rtl/picoblaze_wb_gpio.vhd"
  vcom -check_synthesis "../rtl/wbm_picoblaze.vhd"
  vcom -check_synthesis "../rtl/wbs_gpio.vhd"
  vcom "../rtl/kcpsm3.vhd"
  vcom "../asm/pbwbgpio.vhd"
  vcom "../sim/hdl/picoblaze_wb_gpio_tb.vhd"
  
  vsim picoblaze_wb_gpio_tb behavioral
  
} else {

  vlog "../rtl/picoblaze_wb_gpio.v"
  vlog "../rtl/wbm_picoblaze.v"
  vlog "../rtl/wbs_gpio.v"
  vlog "../rtl/kcpsm3.v"
  vlog "../asm/pbwbgpio.v"
  vlog "../sim/hdl/picoblaze_wb_gpio_tb.v"
  vlog "${XILINX_ISE_PATH}/ise_ds/ise/verilog/src/glbl.v"
  
  vsim picoblaze_wb_gpio_tb glbl
  
}

# configuring wave window
view -undock -x 0 -y 0 -width 1024 -height 640 wave

# adding signals of interest

proc add_wave_sys_sig? {on_off_n} {
  if {$on_off_n} {
    add wave -divider "SYSTEM SIGNALS"
    add wave sim:/dut/rst
    add wave sim:/dut/clk
  }
}

proc add_wave_wb_sig? {on_off_n} {
  if {$on_off_n} {
    add wave -divider "WISHBONE SIGNALS"
    #add wave sim:/dut/wb_cyc
    add wave sim:/dut/wb_stb
    add wave sim:/dut/wb_we
    add wave -radix hex sim:/dut/wb_adr
    add wave -radix hex sim:/dut/wb_dat_m2s
    add wave -radix hex sim:/dut/wb_dat_s2m
    add wave sim:/dut/wb_ack
  }
}

proc add_wave_pbport_sig? {on_off_n} {
  if {$on_off_n} {
    add wave -divider "PICOBLAZE PORT SIGNALS"
    add wave -radix hex sim:/dut/pb_port_id
    add wave sim:/dut/pb_write_strobe
    add wave -radix hex sim:/dut/pb_out_port
    add wave sim:/dut/pb_read_strobe
    add wave -radix hex sim:/dut/pb_in_port
  }
}

proc add_wave_pbimem_sig? {on_off_n} {
  if {$on_off_n} {
    add wave -divider "PICOBLAZE INSTRUCTION MEMORY SIGNALS"
    add wave -radix hex sim:/dut/address
    add wave -radix hex sim:/dut/instruction
  }
}

proc add_wave_gpio_sig? {on_off_n} {
  if {$on_off_n} {
    add wave -divider "GPIO SIGNALS"
    add wave -radix hex sim:/dut/gpio_in
    add wave -radix hex sim:/dut/gpio_out
    add wave -radix hex sim:/dut/gpio_oe
    add wave -radix hex sim:/dut/p_gpio_io
  }
}

# selecting active signal groups
add_wave_sys_sig? yes
add_wave_wb_sig? yes
add_wave_pbport_sig? yes
add_wave_pbimem_sig? no
add_wave_gpio_sig? yes

# setting simulation runtime
run 10 us

# zooming to time area of interest
wave zoomfull
