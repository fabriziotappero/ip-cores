current_design leon3mp 
set_operating_conditions -library ut025sf25v af_max

set sys_clk_freq 80.0
set pci_clk_freq 33.3
set eth_clk_freq 25.0
set spw_clk_freq 200.0
set clock_skew  0.10
set input_setup  2.0
set output_delay 6.0

set sys_peri [expr 1000.0 / $sys_clk_freq]
set spw_peri [expr 1000.0 / $spw_clk_freq]
set pci_peri [expr 1000.0 / $pci_clk_freq]
set eth_peri [expr 1000.0 / $eth_clk_freq]
set input_delay [expr $sys_peri - $input_setup]
set tdelay  [expr $output_delay + 1]

create_clock -name "clk" -period $sys_peri {"core0/clk" }
set_dont_touch_network clk
create_clock -name "spw_txclk" -period $spw_peri { "core0/spw_clk"}
set_dont_touch_network spw_txclk
create_clock -name "pci_clk" -period $pci_peri { "core0/pciclk"}
set_dont_touch_network pci_clk
create_clock -name "etx_clk" -period $eth_peri { "core0/etx_clk" }
set_dont_touch_network etx_clk
create_clock -name "erx_clk" -period $eth_peri { "core0/erx_clk" }
set_dont_touch_network erx_clk

create_clock -name "spw_rxclk0" -period $spw_peri { "core0/leon3core0/grspw0_0/grspwc0/rxclko[0]" }
set_dont_touch_network spw_rxclk0
create_clock -name "spw_rxclk1" -period $spw_peri { "core0/leon3core0/grspw0_1/grspwc0/rxclko[0]" }
set_dont_touch_network spw_rxclk1
create_clock -name "spw_rxclk2" -period $spw_peri { "core0/leon3core0/grspw0_2/grspwc0/rxclko[0]" }
set_dont_touch_network spw_rxclk2
create_clock -name "spw_rxclk3" -period $spw_peri { "core0/leon3core0/grspw0_3/grspwc0/rxclko[0]" }
set_dont_touch_network spw_rxclk3

set_false_path -from resetn
set_false_path -from test
set_false_path -from resetn
set_false_path -from test
set_false_path -from rxd1
set_false_path -from dsubre
set_false_path -from dsuen

set_false_path -from clk -to spw_txclk 
set_false_path -to clk -from spw_txclk 
set_false_path -from clk -to spw_rxclk0 
set_false_path -to clk -from spw_rxclk0 
set_false_path -from clk -to spw_rxclk1 
set_false_path -to clk -from spw_rxclk1 
set_false_path -from clk -to spw_rxclk2 
set_false_path -to clk -from spw_rxclk2 
set_false_path -from clk -to spw_rxclk3 
set_false_path -to clk -from spw_rxclk3 
set_false_path -from spw_txclk -to spw_rxclk0 
set_false_path -to spw_txclk -from spw_rxclk0 
set_false_path -from spw_txclk -to spw_rxclk1 
set_false_path -to spw_txclk -from spw_rxclk1 
set_false_path -from spw_txclk -to spw_rxclk2 
set_false_path -to spw_txclk -from spw_rxclk2 
set_false_path -from spw_txclk -to spw_rxclk3 
set_false_path -to spw_txclk -from spw_rxclk3 
set_false_path -to clk -from etx_clk 
set_false_path -to etx_clk -from clk 
set_false_path -to clk -from erx_clk 
set_false_path -to erx_clk -from clk 
set_false_path -to pci_clk -from clk 
set_false_path -to clk -from pci_clk 

set_input_delay $input_delay -clock clk { \
	 gpio\[*\] data\[*\] brdyn bexcn rxd1 cb\[*\] }

set_max_delay $output_delay -to { errorn wdogn \
         gpio\[*\] data\[*\] txd1 cb\[*\] }

set_max_delay $output_delay -to { \
	 wdogn writen romsn\[*\] read oen iosn rwen\[*\] ramsn\[*\] \
	 ramoen\[*\] sdcsn\[*\] sdwen sdrasn sdcasn \
	 sddqm\[*\] address\[*\] \
	}

set_false_path -to dsuact
set_ideal_network test
