# $Id: xilinx.do,v 1.1 2006-01-16 03:40:22 arif_endro Exp $
# -----------------------------------------------------------------------------
#  Title       : 
#  Project     :  
# -----------------------------------------------------------------------------
#  File        :
#  Author      : "Arif E. Nugroho" <arif_endro@yahoo.com>
#  Created     : 2005/12/18
#  Last update : 
#  Simulators  :
#  Synthesizers: 
#  Target      : 
# -----------------------------------------------------------------------------
#  Description : 
# -----------------------------------------------------------------------------
#  Copyright (C) 2005 Arif E. Nugroho
###############################################################################
## 
## 	THIS SOURCE FILE MAY BE USED AND DISTRIBUTED WITHOUT RESTRICTION
## PROVIDED THAT THIS COPYRIGHT STATEMENT IS NOT REMOVED FROM THE FILE AND THAT
## ANY DERIVATIVE WORK CONTAINS THE ORIGINAL COPYRIGHT NOTICE AND THE
## ASSOCIATED DISCLAIMER.
## 
###############################################################################
## 
## 	THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
## IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
## EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
## OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
## OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
## ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
###############################################################################

# Quit Current simulations
quit -sim;

# Destroy output window
destroy .wave;
destroy .list;

# Create new work library
vlib work;

# Compile all source
vcom ../source/fulladder.vhdl;
vcom ../source/adder_08bit.vhdl;
vcom ../source/bit_comparator.vhdl;
vcom ../source/comparator_7bit.vhdl;
vcom ../source/twos_c_8bit.vhdl;
vcom ../source/ext_val.vhdl;
vcom ../source/ser2par8bit.vhdl;
vcom ../source/product_code.vhdl;
vcom input.vhdl;
vcom senddata.vhdl;
vcom analyze.vhdl;
vcom xilinx.vhdl;

# Simulate the test_bench and design
vsim xilinx

# Show the signal to wave window
add wave sim:/xilinx/clock
add wave sim:/xilinx/clear
add wave sim:/xilinx/start
add wave sim:/xilinx/rxin
add wave sim:/xilinx/rom_pos
add wave sim:/xilinx/y0d
add wave sim:/xilinx/y1d
add wave sim:/xilinx/y2d
add wave sim:/xilinx/y3d
add wave sim:/xilinx/senddata
add wave sim:/xilinx/match
add wave sim:/xilinx/bit_error

add wave -dec sim:/xilinx/my_product_code/y0
add wave -dec sim:/xilinx/my_product_code/y1
add wave -dec sim:/xilinx/my_product_code/y2
add wave -dec sim:/xilinx/my_product_code/y3
add wave -dec sim:/xilinx/my_product_code/r0
add wave -dec sim:/xilinx/my_product_code/r1
add wave -dec sim:/xilinx/my_product_code/c0
add wave -dec sim:/xilinx/my_product_code/c1

add wave -dec sim:/xilinx/my_product_code/y0e
add wave -dec sim:/xilinx/my_product_code/y1e
add wave -dec sim:/xilinx/my_product_code/y2e
add wave -dec sim:/xilinx/my_product_code/y3e

add wave -dec sim:/xilinx/my_product_code/row0/ext_r_o
add wave -dec sim:/xilinx/my_product_code/row1/ext_r_o
add wave -dec sim:/xilinx/my_product_code/row2/ext_r_o
add wave -dec sim:/xilinx/my_product_code/row3/ext_r_o

add wave -dec sim:/xilinx/my_product_code/col0/ext_r_o
add wave -dec sim:/xilinx/my_product_code/col1/ext_r_o
add wave -dec sim:/xilinx/my_product_code/col2/ext_r_o
add wave -dec sim:/xilinx/my_product_code/col3/ext_r_o

add wave -dec sim:/xilinx/my_product_code/sum_r_0/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_r_1/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_r_2/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_r_3/adder08_output

add wave -dec sim:/xilinx/my_product_code/sum_c_0/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_c_1/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_c_2/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_c_3/adder08_output

add wave -dec sim:/xilinx/my_product_code/sum_p_0/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_p_1/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_p_2/adder08_output
add wave -dec sim:/xilinx/my_product_code/sum_p_3/adder08_output

add wave -dec sim:/xilinx/my_product_code/ext_b_r_0
add wave -dec sim:/xilinx/my_product_code/ext_b_r_1
add wave -dec sim:/xilinx/my_product_code/ext_b_r_2
add wave -dec sim:/xilinx/my_product_code/ext_b_r_3

add wave -dec sim:/xilinx/my_product_code/ext_b_c_0
add wave -dec sim:/xilinx/my_product_code/ext_b_c_1
add wave -dec sim:/xilinx/my_product_code/ext_b_c_2
add wave -dec sim:/xilinx/my_product_code/ext_b_c_3

# Run the simulation
force -freeze sim:/xilinx/clock 1 0,0 {50ns} -r 100

# 20024 sample at 100ns => 2002400ns
# 20024 sample at 1ns   =>   20024ns
run  2001000ns
