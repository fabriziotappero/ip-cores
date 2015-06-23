#!/bin/bash 

# analysis
ghdl -a ../../rtl/vhdl/parse_price.vhd
ghdl -a ../../rtl/vhdl/search_item.vhd
ghdl -a ../../rtl/vhdl/search_control.vhd
#
ghdl -a ../../sim/rtl_sim/src/parse_price_sim.vhd
ghdl -a ../../sim/rtl_sim/src/hitter_sim.vhd
ghdl -a search_item_wrapper.vhd
ghdl -a search_control_wrapper.vhd
ghdl -a parse_price_wrapper.vhd
ghdl -a hitter_wrapper.vhd


# elaboration & run
ghdl -e parse_price

ghdl -e hitter_sim
ghdl -e parse_price_sim

ghdl -e parse_price_wrapper
#ghdl -r parse_price_wrapper

ghdl -e hitter_wrapper
#ghdl -r hitter_wrapper

ghdl -e search_item_wrapper
#ghdl -r search_item_wrapper

ghdl -e search_control_wrapper
ghdl -r search_control_wrapper
