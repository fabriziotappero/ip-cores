##############################################################################
# Source:    run.do
# Author:    Ami Castonguay
# Date:      August 9, 2005
# Modified:  August 9, 2005
# File:      DO file for ModelSim HT top simulation
# Description: Command file to simulate the design in ModelSim.  
#
#            Simulation can also easily e compiled into an executable with 
#            any compiler, but this script can still be useful because most 
#            of it can be reuse to test the design post-synthesis.
##############################################################################

onbreak {resume}

# create library
if [file exists work] {
    vdel -all
}
vlib work

# compile and link C source files

#top Linking module
sccom -g -D SYSTEMC_SIM -D MTI2_SYSTEMC bench/vc_ht_tunnel_l1_tb/main.cpp

#the testbench
sccom -g -D SYSTEMC_SIM bench/vc_ht_tunnel_l1_tb/InterfaceLayer.cpp
sccom -g -D SYSTEMC_SIM bench/vc_ht_tunnel_l1_tb/LogicalLayer.cpp
sccom -g -D SYSTEMC_SIM bench/vc_ht_tunnel_l1_tb/PhysicalLayer.cpp
sccom -g -D SYSTEMC_SIM bench/vc_ht_tunnel_l1_tb/vc_ht_tunnel_l1_tb.cpp

#the design
sccom -g -D SYSTEMC_SIM rtl/systemc/link_l2/link_frame_rx_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/link_l2/link_frame_tx_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/link_l2/link_l2.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_cmd_buffer_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_cmdwdata_buffer_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_counter_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_history_rx_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_mux_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_nop_handler_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_packet_crc_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/cd_state_machine_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/decoder_l2/decoder_l2.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/databuffer_l2/databuffer_l2.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/chain_marker_l4.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/entrance_reordering_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/final_reordering_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/nophandler_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/nposted_vc_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/posted_vc_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/response_vc_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/reordering_l2.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/fetch_packet_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/reordering_l2/address_manager_l3.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/errorhandler_l2/errorhandler_l2.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/userinterface_l2/userinterface_l2.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/csr_l2/csr_l2.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/fairness_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/fc_packet_crc_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/flow_control_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/history_buffer_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/multiplexer_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/nop_framer_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/rx_farend_cnt_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/user_fifo_l3.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/flow_control_l2/flow_control_l2.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/core_synth/synth_control_packet.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/core_synth/synth_datatypes.cpp

sccom -g -D SYSTEMC_SIM bench/core/ControlPacket.cpp
sccom -g -D SYSTEMC_SIM bench/core/ht_datatypes.cpp
sccom -g -D SYSTEMC_SIM bench/core/PacketContainer.cpp
sccom -g -D SYSTEMC_SIM bench/core/RequestPacket.cpp
sccom -g -D SYSTEMC_SIM bench/core/ResponsePacket.cpp

sccom -g -D SYSTEMC_SIM rtl/systemc/vc_ht_tunnel_l1/misc_logic_l2.cpp
sccom -g -D SYSTEMC_SIM rtl/systemc/vc_ht_tunnel_l1/vc_ht_tunnel_l1.cpp

#final link
sccom -link

