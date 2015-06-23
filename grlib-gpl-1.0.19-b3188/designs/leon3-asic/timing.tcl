
set_operating_conditions -library RH_UMC018_IOLIB_WCMIL WCMIL
set_operating_conditions -library RH_UMC018_LVDSLIB_WCMIL WCMIL
set_operating_conditions -library RadHardUMC18_CORE_STD_WCMIL WCMIL
set_operating_conditions -library RadHardUMC18_CORE_HIT_WCMIL WCMIL
set_wire_load_mode segmented
set auto_wire_load_selection "true"
set_wire_load_mode segmented

set sys_clk_freq 300.0
set spw_clk_freq 300.0
set clock_skew  0.10
set input_setup  2.0
set output_delay 6.0

set sys_peri [expr 1000.0 / $sys_clk_freq]
set spw_peri [expr 1000.0 / $spw_clk_freq]
set spw_rxperi [expr 1500.0 / $spw_clk_freq]
set input_delay [expr $sys_peri - $input_setup]
set tdelay  [expr $output_delay + 1]

create_clock -name "clk" -period $sys_peri {"core0/leon3core0/clk" }
set_dont_touch_network clk
create_clock -name "spw_txclk" -period $spw_peri { "core0/leon3core0/spw_clk"}
set_dont_touch_network spw_txclk

create_clock -name "spw_rxclk0" -period $spw_peri { "core0/leon3core0/grspw0_0/grspwc0/rx0_0/rxclko" }
#create_clock -name "spw_rxclk0" -period $spw_peri { "spw_rxsp[0]" }
set_dont_touch_network spw_rxclk0
create_clock -name "spw_rxclk1" -period $spw_peri { "core0/leon3core0/grspw0_1/grspwc0/rx0_0/rxclko" }
#create_clock -name "spw_rxclk1" -period $spw_peri { "spw_rxsp[1]" }
set_dont_touch_network spw_rxclk1

set_false_path -from resetn
set_false_path -from testen
set_ideal_network testen
set_false_path -from rxd1
set_false_path -from dsubre
set_false_path -from dsuen
set_false_path -from dsurx
set_false_path -to dsuact
set_false_path -from clk -to spw_txclk 
set_false_path -to clk -from spw_txclk 
set_false_path -from clk -to spw_rxclk0 
set_false_path -to clk -from spw_rxclk0 
set_false_path -from clk -to spw_rxclk1 
set_false_path -to clk -from spw_rxclk1 
set_false_path -from spw_txclk -to spw_rxclk0 
set_false_path -to spw_txclk -from spw_rxclk0 
set_false_path -from spw_txclk -to spw_rxclk1 
set_false_path -to spw_txclk -from spw_rxclk1 
set_false_path -from core0/leon3core0/ftmctrl0/rst -to [get_ports {data* cb*}]
set_false_path -from core0/leon3core0/grgpio0/rst -to [get_ports {gpio*}]

set_input_delay $input_delay -clock clk { \
	 gpio\[*\] data\[*\] brdyn bexcn cb\[*\] }

set_max_delay $output_delay -to { data\[*\] cb\[*\] }

set_max_delay 15 -to { errorn wdogn txd1 gpio\[*\] }

set_max_delay $output_delay -to { \
	 writen romsn\[*\] read oen iosn rwen\[*\] ramsn\[*\] \
	 ramoen\[*\] sdcsn\[*\] sdwen sdrasn sdcasn \
	 sddqm\[*\] address\[*\] \
	}

#set_load 8.0 [all_outputs]
#set_load 50 { address\[2\] address\[3\] address\[4\] address\[5\] \
	address\[6\] address\[7\] address\[8\] address\[9\] address\[10\] \
	address\[11\] address\[12\] address\[13\] address\[14\] address\[15\] \
	address\[16\] address\[17\] address\[18\] address\[19\] address\[20\]}
	
#set_load 20 [get_ports {data* cb*}]

set_critical_range 2.0 leon3mp
