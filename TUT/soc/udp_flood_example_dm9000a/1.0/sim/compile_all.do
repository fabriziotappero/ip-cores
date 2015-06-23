# Script compiles all vhdl-files and generates a makefile for them
# This script is tested for Modelsim version 6.6a 

.main clear

echo " Generating libraries for files"

echo "Processing component TUT:ip.hwp.interface:udp_ip_dm9000a:1.0"
echo "Processing file set HDLsources of component TUT:ip.hwp.interface:udp_ip_dm9000a:1.0."
echo " Adding library work"
vlib work
echo "Processing file set eth_ctrl_vhd of component TUT:ip.hwp.interface:udp_ip_dm9000a:1.0."
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/eth_dm9000a_ctrl/1.0/vhd/DM9kA_ctrl_pkg.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/eth_dm9000a_ctrl/1.0/vhd/DM9kA_send_module.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/eth_dm9000a_ctrl/1.0/vhd/DM9kA_comm_module.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/eth_dm9000a_ctrl/1.0/vhd/DM9kA_init_module.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/eth_dm9000a_ctrl/1.0/vhd/DM9kA_interrupt_handler.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/eth_dm9000a_ctrl/1.0/vhd/DM9kA_read_module.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/eth_dm9000a_ctrl/1.0/vhd/DM9kA_controller.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/udp_ip_pkg.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/arp3.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/arpsnd.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/ip_checksum.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/udp.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/udp_arp_data_mux.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/udp_ip.vhd
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/udp_ip_dm9000a.vhd

echo "Processing component TUT:ip.hwp.misc:altera_de2_pll_25:1.0"
echo "Processing file set HDLsources of component TUT:ip.hwp.misc:altera_de2_pll_25:1.0."
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/altera_de2_pll_25/vhd/ALTPLL_for_DE2_50to25.vhd

echo "Processing component TUT:ip.hwp.interface:simple_udp_flood_example:1.0"
echo "Processing file set HDLsources of component TUT:ip.hwp.interface:simple_udp_flood_example:1.0."
vcom -work work -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/udp_ip/1.0/vhd/simple_udp_flood_example.vhd

echo "Processing component TUT:soc:udp_flood_example_dm9000a:1.0"
echo "Processing file set vhdlSource of component TUT:soc:udp_flood_example_dm9000a:1.0."
vcom -quiet -check_synthesis -work work D:/user/ege/Svn/daci_ip/trunk/soc/udp_flood_example_dm9000a/1.0/vhd/udp_flood_example_dm9000a.vhd

echo " Creating a new Makefile"

# remove the old makefile
rm -f Makefile
vmake work > Makefile
echo " Script has been executed "
