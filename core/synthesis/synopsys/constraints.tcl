##############################################################################
#                                                                            #
#                            CLOCK DEFINITION                                #
#                                                                            #
##############################################################################

#set CLOCK_PERIOD 100.0; #  10 MHz
#set CLOCK_PERIOD 66.6; #  15 MHz
#set CLOCK_PERIOD 50.0; #  20 MHz
set CLOCK_PERIOD 40.0; #  25 MHz
#set CLOCK_PERIOD 33.3; #  30 MHz
#set CLOCK_PERIOD 30.0; #  33 MHz
#set CLOCK_PERIOD 25.0; #  40 MHz
#set CLOCK_PERIOD 22.2; #  45 MHz
#set CLOCK_PERIOD 20.0; #  50 MHz
#set CLOCK_PERIOD 16.7; #  60 MHz
#set CLOCK_PERIOD 15.4; #  65 MHz
#set CLOCK_PERIOD 15.0; #  66 MHz
#set CLOCK_PERIOD 14.3; #  70 MHz
#set CLOCK_PERIOD 12.5; #  80 MHz
#set CLOCK_PERIOD 11.1; #  90 MHz
#set CLOCK_PERIOD 10.0; # 100 MHz
#set CLOCK_PERIOD  8.0; # 125 MHz


create_clock -name     "dco_clk"                              \
             -period   "$CLOCK_PERIOD"                        \
             -waveform "[expr $CLOCK_PERIOD/2] $CLOCK_PERIOD" \
             [get_ports dco_clk]

create_clock -name     "lfxt_clk"                             \
             -period   "$CLOCK_PERIOD"                        \
             -waveform "[expr $CLOCK_PERIOD/2] $CLOCK_PERIOD" \
             [get_ports lfxt_clk]


##############################################################################
#                                                                            #
#                          CREATE PATH GROUPS                                #
#                                                                            #
##############################################################################

group_path -name REGOUT      -to   [all_outputs] 
group_path -name REGIN       -from [remove_from_collection [all_inputs] [get_ports dco_clk]]
group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] [get_ports dco_clk]] -to [all_outputs]


##############################################################################
#                                                                            #
#                          BOUNDARY TIMINGS                                  #
#                                                                            #
##############################################################################
# NOTE: There are some path through between Program/Data memory signals
#      which are limiting the maximum frequency achievable by the core.
#       The memory constraints set on these interfaces are therefore quite
#      critical regarding the achievable performance of the core.
#       As a consequence, the constrains on the pmem_*/dmem_* signals must
#      be set with some absolute values as they are specified by the targeted
#      process RAM/ROM generator.

#================#
# PROGRAM MEMORY #
#================#

set PMEM_DOUT_DLY    2.25

set PMEM_ADDR_DLY    0.64
set PMEM_CEN_DLY     0.63
set PMEM_DIN_DLY     0.39
set PMEM_WEN_DLY     0.44

set_input_delay  $PMEM_DOUT_DLY            -max -clock "dco_clk"  [get_ports pmem_dout]
set_input_delay  0                         -min -clock "dco_clk"  [get_ports pmem_dout]

set_output_delay $PMEM_ADDR_DLY -add_delay -max -clock "dco_clk"  [get_ports pmem_addr]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports pmem_addr]

set_output_delay $PMEM_CEN_DLY  -add_delay -max -clock "dco_clk"  [get_ports pmem_cen]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports pmem_cen]

set_output_delay $PMEM_DIN_DLY  -add_delay -max -clock "dco_clk"  [get_ports pmem_din]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports pmem_din]

set_output_delay $PMEM_WEN_DLY  -add_delay -max -clock "dco_clk"  [get_ports pmem_wen]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports pmem_wen]


#================#
# DATA MEMORY    #
#================#

set DMEM_DOUT_DLY    2.25

set DMEM_ADDR_DLY    0.64
set DMEM_CEN_DLY     0.63
set DMEM_DIN_DLY     0.39
set DMEM_WEN_DLY     0.44


set_input_delay $DMEM_DOUT_DLY             -max -clock "dco_clk"  [get_ports dmem_dout]
set_input_delay 0                          -min -clock "dco_clk"  [get_ports dmem_dout]

set_output_delay $DMEM_ADDR_DLY -add_delay -max -clock "dco_clk"  [get_ports dmem_addr]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports dmem_addr]

set_output_delay $DMEM_CEN_DLY  -add_delay -max -clock "dco_clk"  [get_ports dmem_cen]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports dmem_cen]

set_output_delay $DMEM_DIN_DLY  -add_delay -max -clock "dco_clk"  [get_ports dmem_din]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports dmem_din]

set_output_delay $DMEM_WEN_DLY  -add_delay -max -clock "dco_clk"  [get_ports dmem_wen]
set_output_delay 0                         -min -clock "dco_clk"  [get_ports dmem_wen]


#==========================#
# REMAINING INPUT PORTS    #
#==========================#

set IRQ_DLY          [expr ($CLOCK_PERIOD/100) * 30]
set PER_DOUT_DLY     [expr ($CLOCK_PERIOD/100) * 20]


set_input_delay $IRQ_DLY       -max -clock "dco_clk"  [get_ports irq]
set_input_delay 0              -min -clock "dco_clk"  [get_ports irq]

set_input_delay $PER_DOUT_DLY  -max -clock "dco_clk"  [get_ports per_dout]
set_input_delay 0              -min -clock "dco_clk"  [get_ports per_dout]


#=========================#
# REMAINING OUTPUT PORTS  #
#=========================#

set ACLK_EN_DLY      [expr ($CLOCK_PERIOD/100) * 85]
set SMCLK_EN_DLY     [expr ($CLOCK_PERIOD/100) * 85]
set DBG_FREEZE_DLY   [expr ($CLOCK_PERIOD/100) * 85]
set IRQ_ACC_DLY      [expr ($CLOCK_PERIOD/100) * 60]

set PER_ADDR_DLY     [expr ($CLOCK_PERIOD/100) * 25]
set PER_DIN_DLY      [expr ($CLOCK_PERIOD/100) * 25]
set PER_WEN_DLY      [expr ($CLOCK_PERIOD/100) * 25]
set PER_EN_DLY       [expr ($CLOCK_PERIOD/100) * 25]

set PUC_DLY          [expr ($CLOCK_PERIOD/100) * 75]


set_output_delay $ACLK_EN_DLY    -add_delay -max -clock "dco_clk"             [get_ports aclk_en]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports aclk_en]

set_output_delay $SMCLK_EN_DLY   -add_delay -max -clock "dco_clk"             [get_ports smclk_en]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports smclk_en]

set_output_delay $DBG_FREEZE_DLY -add_delay -max -clock "dco_clk"             [get_ports dbg_freeze]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports dbg_freeze]

set_output_delay $IRQ_ACC_DLY    -add_delay -max -clock "dco_clk"             [get_ports irq_acc]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports irq_acc]


set_output_delay $PER_ADDR_DLY   -add_delay -max -clock "dco_clk"             [get_ports per_addr]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports per_addr]

set_output_delay $PER_DIN_DLY    -add_delay -max -clock "dco_clk"             [get_ports per_din]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports per_din]

set_output_delay $PER_WEN_DLY    -add_delay -max -clock "dco_clk"             [get_ports per_we]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports per_we]

set_output_delay $PER_EN_DLY     -add_delay -max -clock "dco_clk"             [get_ports per_en]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports per_en]

set_output_delay $PUC_DLY        -add_delay -max -clock "dco_clk"             [get_ports puc_rst]
set_output_delay 0                          -min -clock "dco_clk"             [get_ports puc_rst]


#========================#
# FEEDTHROUGH EXCEPTIONS #
#========================#

#set_max_delay [expr 2.0 + $DMEM_DOUT_DLY + $DMEM_ADDR_DLY] \
#              -from       [get_ports dmem_dout]            \
#              -to         [get_ports dmem_addr]            \
#              -group_path FEEDTHROUGH


#===============#
# FALSE PATHS   #
#===============#
# The following signals are internaly synchronized to
# the dco_clk domain and can be set as false path.

set_false_path -from dbg_uart_rxd
set_false_path -to   dbg_uart_txd

set_false_path -from nmi
set_false_path -from lfxt_clk
set_false_path -from reset_n

set_false_path -from cpu_en
set_false_path -from dbg_en
