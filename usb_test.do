  ################################################################################################
  # This tcl-file is for usage with Model Sim, adopt this information to your simulator needs MN #
  ################################################################################################

  echo  "===>"
  echo  "===> Recompiling Sources"
  echo  "===>"

 #if {[file exists work]} { vdel -lib work -all }
  vlib                      D:/Design/work
  vmap           work       D:/Design/work

  # Open Cores USB Phy, designed by Rudolf Usselmanns and translated to VHDL by Martin Neumann

  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_phy/usb_rx_phy_60MHz.vhdl
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_phy/usb_tx_phy.vhdl
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_phy/usb_phy.vhdl

  # Open Cores  USB Serial, designed by Joris van Rantwijk
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_serial/usb_pkg.vhdl
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_serial/usb_init.vhdl
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_serial/usb_control.vhdl
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_serial/usb_transact.vhdl
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_serial/usb_packet.vhdl
  vcom -93 -work work       D:/design/completed_vhdl/usb_fs_port/usb_serial/usb_serial.vhdl

  # The USB FS test bench files
  vcom -93 -work work       D:/OpenCores/usb11_sim_model/trunk/usb_fs_port.vhdl
  vcom -93 -work work       D:/OpenCores/usb11_sim_model/trunk/usb_commands.vhd
  vcom -93 -work work       D:/OpenCores/usb11_sim_model/trunk/usb_stimuli.vhd
  vcom -93 -work work       D:/OpenCores/usb11_sim_model/trunk/usb_fs_monitor.vhd
  vcom -93 -work work       D:/OpenCores/usb11_sim_model/trunk/usb_fs_master.vhd
  vcom -93 -work work       D:/OpenCores/usb11_sim_model/trunk/usb_tb.vhd

  echo  "===>"
  echo  "===> Start Simulation"
  echo  "===>"
  vsim  -quiet usb_tb

  #view source
  view wave
  configure wave -signalnamewidth 1

  add wave -noupdate -divider {USB_Monitor}
  add wave -noupdate -format Literal -radix decimal     /usb_tb/usb_fs_master/test_case/t_no
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_master/usb_fs_monitor/*
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_master/stimuli_bit

  add wave -noupdate -divider {USB_MASTER}
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_master/*

  add wave -noupdate -divider {USB_STIMULI}
  add wave -noupdate -format Literal -radix decimal     /usb_tb/usb_fs_master/test_case/t_no
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_master/test_case/*

  add wave -noupdate -divider {USB_PHY}
  add wave -noupdate -format Literal -radix decimal     /usb_tb/usb_fs_master/test_case/t_no
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_phy_1/*

# add wave -noupdate -divider {USB_RX_PHY}
# add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_phy_1/i_rx_phy/*
#
# add wave -noupdate -divider
# add wave -noupdate -divider {USB_TX_PHY}
# add wave -noupdate -format Literal -radix decimal /usb_tb/usb_fs_master/test_case/t_no
# add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_phy_1/i_tx_phy/*
  add wave -noupdate -divider {USB_SERIAL}
  add wave -noupdate -format Literal -radix decimal     /usb_tb/usb_fs_master/test_case/t_no
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_serial_1/*
  add wave -noupdate -divider {USB_S-INIT}
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_serial_1/usb_init_inst/*
  add wave -noupdate -divider {USB_S-PACKET}
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_serial_1/usb_packet_inst/*
  add wave -noupdate -divider {USB_S-TRANSACT}
  add wave -noupdate -format Literal -radix decimal     /usb_tb/usb_fs_master/test_case/t_no
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_serial_1/usb_transact_inst/*
  add wave -noupdate -divider {USB_S-CONTROL}
  add wave -noupdate -format Logic   -radix hexadecimal /usb_tb/usb_fs_slave_1/usb_serial_1/usb_control_inst/*

  onbreak {resume}
  run -all
