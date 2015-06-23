# ---------------------------------------------------------------------------------
# RUN SCRIPT
# ---------------------------------------------------------------------------------
 puts "========================RUN========================"
 puts "SYNTAX: do run.do <TIME> <WAVE FILE> <MEM INIT> <SCRIPT>"
 puts "==================================================="
#
# ---------------------------------------------------------------------------------
# RESTART MODELSIM
# ---------------------------------------------------------------------------------
#
 quit -sim
#
# copy script input for testbench
 file delete                     $path_project_files/$path_script_files/esoc_control_test_stim.txt
 file delete                     $path_project_files/$path_script_files/esoc_rgmii_test_stim.txt
 file copy                       $path_project_files/$path_script_files/esoc_control_test_stim_$4.txt $path_project_files/$path_script_files/esoc_control_test_stim.txt
 file copy                       $path_project_files/$path_script_files/esoc_rgmii_test_stim_$4.txt   $path_project_files/$path_script_files/esoc_rgmii_test_stim.txt
#
# copy memory init files for testbench
file delete                      $path_project_files/$path_msim_files/esoc_rom_2kx32.mif
file delete                      $path_project_files/$path_msim_files/esoc_ram_4kx1.mif
file copy                        $path_project_files/$path_design_files_altera/esoc_rom_nkx32/esoc_rom_2kx32.mif $path_project_files/$path_msim_files/esoc_rom_2kx32.mif
file copy                        $path_project_files/$path_design_files_altera/esoc_ram_nkx1/esoc_ram_4kx1.mif  $path_project_files/$path_msim_files/esoc_ram_4kx1.mif
#
# rebuild IP
 vcom -work work -2002 $path_project_files/$path_design_files_logixa/esoc_tb.vhd
#
# restart modelsim
 vsim -novopt -t ps work.esoc_tb
 restart -f -nowave
#
# load correct wave file
 do                              $path_project_files/$path_wave_files/test_wave_$2.do
#
# pre-run simulation
 run 1 us
#
# load correct memory initialisation file
 do                              $path_project_files/$path_meminit_files/test_meminit_$3.do
#
# run simulation
 run $1 us
#
# exit, save logging and clean up
 file delete                     $path_project_files/$path_log_files/$4/test_wave_$2.do
 file copy                       $path_project_files/$path_wave_files/test_wave_$2.do                   $path_project_files/$path_log_files/$4/test_wave_$2.do
#
 file delete                     $path_project_files/$path_log_files/$4/esoc_control_test_stim_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_stim_$4.txt
 file copy                       $path_project_files/$path_script_files/esoc_control_test_stim.txt      $path_project_files/$path_log_files/$4/esoc_control_test_stim_$4.txt
 file copy                       $path_project_files/$path_script_files/esoc_rgmii_test_stim.txt        $path_project_files/$path_log_files/$4/esoc_rgmii_test_stim_$4.txt
# 
 file delete                     $path_project_files/$path_log_files/$4/esoc_control_test_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_control_test_log.txt          $path_project_files/$path_log_files/$4/esoc_control_test_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_log.txt            $path_project_files/$path_log_files/$4/esoc_rgmii_test_log_$4.txt
# 
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_0_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_1_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_2_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_3_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_4_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_5_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_6_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_7_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_0_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_0_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_1_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_1_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_2_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_2_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_3_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_3_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_4_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_4_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_5_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_5_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_6_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_6_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_rx_port_7_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_rx_port_7_log_$4.txt
# 
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_0_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_1_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_2_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_3_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_4_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_5_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_6_log_$4.txt
 file delete                     $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_7_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_0_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_0_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_1_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_1_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_2_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_2_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_3_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_3_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_4_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_4_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_5_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_5_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_6_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_6_log_$4.txt
 file copy                       $path_project_files/$path_log_files/esoc_rgmii_test_tx_port_7_log.txt $path_project_files/$path_log_files/$4/esoc_rgmii_test_tx_port_7_log_$4.txt
 