#include "systemc.h"

class vc_ht_tunnel_l1 : public sc_foreign_module
{
public:
    sc_in<bool> clk;
    sc_in<bool> resetx;
    sc_in<bool> pwrok;
    sc_in<bool> ldtstopx;
    sc_in<bool> phy0_available_lk0;
    sc_in<sc_bv<4> > phy0_ctl_lk0;
    sc_in<sc_bv<4> > phy0_cad_lk0__0;
    sc_in<sc_bv<4> > phy0_cad_lk0__1;
    sc_in<sc_bv<4> > phy0_cad_lk0__2;
    sc_in<sc_bv<4> > phy0_cad_lk0__3;
    sc_in<sc_bv<4> > phy0_cad_lk0__4;
    sc_in<sc_bv<4> > phy0_cad_lk0__5;
    sc_in<sc_bv<4> > phy0_cad_lk0__6;
    sc_in<sc_bv<4> > phy0_cad_lk0__7;
    sc_out<sc_bv<4> > lk0_ctl_phy0;
    sc_out<sc_bv<4> > lk0_cad_phy0__0;
    sc_out<sc_bv<4> > lk0_cad_phy0__1;
    sc_out<sc_bv<4> > lk0_cad_phy0__2;
    sc_out<sc_bv<4> > lk0_cad_phy0__3;
    sc_out<sc_bv<4> > lk0_cad_phy0__4;
    sc_out<sc_bv<4> > lk0_cad_phy0__5;
    sc_out<sc_bv<4> > lk0_cad_phy0__6;
    sc_out<sc_bv<4> > lk0_cad_phy0__7;
    sc_in<bool> phy0_consume_lk0;
    sc_out<bool> lk0_disable_drivers_phy0;
    sc_out<bool> lk0_disable_receivers_phy0;
    sc_in<bool> phy1_available_lk1;
    sc_in<sc_bv<4> > phy1_ctl_lk1;
    sc_in<sc_bv<4> > phy1_cad_lk1__0;
    sc_in<sc_bv<4> > phy1_cad_lk1__1;
    sc_in<sc_bv<4> > phy1_cad_lk1__2;
    sc_in<sc_bv<4> > phy1_cad_lk1__3;
    sc_in<sc_bv<4> > phy1_cad_lk1__4;
    sc_in<sc_bv<4> > phy1_cad_lk1__5;
    sc_in<sc_bv<4> > phy1_cad_lk1__6;
    sc_in<sc_bv<4> > phy1_cad_lk1__7;
    sc_out<sc_bv<4> > lk1_ctl_phy1;
    sc_out<sc_bv<4> > lk1_cad_phy1__0;
    sc_out<sc_bv<4> > lk1_cad_phy1__1;
    sc_out<sc_bv<4> > lk1_cad_phy1__2;
    sc_out<sc_bv<4> > lk1_cad_phy1__3;
    sc_out<sc_bv<4> > lk1_cad_phy1__4;
    sc_out<sc_bv<4> > lk1_cad_phy1__5;
    sc_out<sc_bv<4> > lk1_cad_phy1__6;
    sc_out<sc_bv<4> > lk1_cad_phy1__7;
    sc_in<bool> phy1_consume_lk1;
    sc_out<bool> lk1_disable_drivers_phy1;
    sc_out<bool> lk1_disable_receivers_phy1;
    sc_out<bool> ui_memory_write0;
    sc_out<bool> ui_memory_write1;
    sc_out<sc_bv<7> > ui_memory_write_address;
    sc_out<sc_bv<32> > ui_memory_write_data;
    sc_out<sc_bv<7> > ui_memory_read_address0;
    sc_out<sc_bv<7> > ui_memory_read_address1;
    sc_in<sc_bv<32> > ui_memory_read_data0;
    sc_in<sc_bv<32> > ui_memory_read_data1;
    sc_out<bool> history_memory_write0;
    sc_out<sc_uint<7> > history_memory_write_address0;
    sc_out<sc_bv<32> > history_memory_write_data0;
    sc_out<sc_uint<7> > history_memory_read_address0;
    sc_in<sc_bv<32> > history_memory_output0;
    sc_out<bool> history_memory_write1;
    sc_out<sc_uint<7> > history_memory_write_address1;
    sc_out<sc_bv<32> > history_memory_write_data1;
    sc_out<sc_uint<7> > history_memory_read_address1;
    sc_in<sc_bv<32> > history_memory_output1;
    sc_out<bool> memory_write0;
    sc_out<sc_uint<2> > memory_write_address_vc0;
    sc_out<sc_uint<3> > memory_write_address_buffer0;
    sc_out<sc_uint<4> > memory_write_address_pos0;
    sc_out<sc_bv<32> > memory_write_data0;
    sc_out<sc_uint<2> > memory_read_address_vc0__0;
    sc_out<sc_uint<2> > memory_read_address_vc0__1;
    sc_out<sc_uint<3> > memory_read_address_buffer0__0;
    sc_out<sc_uint<3> > memory_read_address_buffer0__1;
    sc_out<sc_uint<4> > memory_read_address_pos0__0;
    sc_out<sc_uint<4> > memory_read_address_pos0__1;
    sc_in<sc_bv<32> > memory_output0__0;
    sc_in<sc_bv<32> > memory_output0__1;
    sc_out<bool> memory_write1;
    sc_out<sc_uint<2> > memory_write_address_vc1;
    sc_out<sc_uint<3> > memory_write_address_buffer1;
    sc_out<sc_uint<4> > memory_write_address_pos1;
    sc_out<sc_bv<32> > memory_write_data1;
    sc_out<sc_uint<2> > memory_read_address_vc1__0;
    sc_out<sc_uint<2> > memory_read_address_vc1__1;
    sc_out<sc_uint<3> > memory_read_address_buffer1__0;
    sc_out<sc_uint<3> > memory_read_address_buffer1__1;
    sc_out<sc_uint<4> > memory_read_address_pos1__0;
    sc_out<sc_uint<4> > memory_read_address_pos1__1;
    sc_in<sc_bv<32> > memory_output1__0;
    sc_in<sc_bv<32> > memory_output1__1;
    sc_out<sc_bv<64> > ui_packet_usr;
    sc_out<sc_uint<2> > ui_vc_usr;
    sc_out<bool> ui_side_usr;
    sc_out<bool> ui_directroute_usr;
    sc_out<bool> ui_eop_usr;
    sc_out<bool> ui_available_usr;
    sc_out<bool> ui_output_64bits_usr;
    sc_in<bool> usr_consume_ui;
    sc_in<sc_bv<64> > usr_packet_ui;
    sc_in<bool> usr_available_ui;
    sc_in<bool> usr_side_ui;
    sc_out<sc_bv<6> > ui_freevc0_usr;
    sc_out<sc_bv<6> > ui_freevc1_usr;
    sc_out<sc_bv<40> > csr_bar__0;
    sc_out<sc_bv<40> > csr_bar__1;
    sc_out<sc_bv<40> > csr_bar__2;
    sc_out<sc_bv<40> > csr_bar__3;
    sc_out<sc_bv<40> > csr_bar__4;
    sc_out<sc_bv<40> > csr_bar__5;
    sc_out<sc_bv<5> > csr_unit_id;
    sc_in<bool> usr_receivedResponseError_csr;
    sc_out<sc_uint<6> > csr_read_addr_usr;
    sc_in<sc_bv<32> > usr_read_data_csr;
    sc_out<bool> csr_write_usr;
    sc_out<sc_uint<6> > csr_write_addr_usr;
    sc_out<sc_bv<32> > csr_write_data_usr;
    sc_out<sc_bv<4> > csr_write_mask_usr;


    vc_ht_tunnel_l1(sc_module_name nm, const char* hdl_name)
     : sc_foreign_module(nm, hdl_name),
       clk("clk"),
       resetx("resetx"),
       pwrok("pwrok"),
       ldtstopx("ldtstopx"),
       phy0_available_lk0("phy0_available_lk0"),
       phy0_ctl_lk0("phy0_ctl_lk0"),
       phy0_cad_lk0__0("phy0_cad_lk0__0"),
       phy0_cad_lk0__1("phy0_cad_lk0__1"),
       phy0_cad_lk0__2("phy0_cad_lk0__2"),
       phy0_cad_lk0__3("phy0_cad_lk0__3"),
       phy0_cad_lk0__4("phy0_cad_lk0__4"),
       phy0_cad_lk0__5("phy0_cad_lk0__5"),
       phy0_cad_lk0__6("phy0_cad_lk0__6"),
       phy0_cad_lk0__7("phy0_cad_lk0__7"),
       lk0_ctl_phy0("lk0_ctl_phy0"),
       lk0_cad_phy0__0("lk0_cad_phy0__0"),
       lk0_cad_phy0__1("lk0_cad_phy0__1"),
       lk0_cad_phy0__2("lk0_cad_phy0__2"),
       lk0_cad_phy0__3("lk0_cad_phy0__3"),
       lk0_cad_phy0__4("lk0_cad_phy0__4"),
       lk0_cad_phy0__5("lk0_cad_phy0__5"),
       lk0_cad_phy0__6("lk0_cad_phy0__6"),
       lk0_cad_phy0__7("lk0_cad_phy0__7"),
       phy0_consume_lk0("phy0_consume_lk0"),
       lk0_disable_drivers_phy0("lk0_disable_drivers_phy0"),
       lk0_disable_receivers_phy0("lk0_disable_receivers_phy0"),
       phy1_available_lk1("phy1_available_lk1"),
       phy1_ctl_lk1("phy1_ctl_lk1"),
       phy1_cad_lk1__0("phy1_cad_lk1__0"),
       phy1_cad_lk1__1("phy1_cad_lk1__1"),
       phy1_cad_lk1__2("phy1_cad_lk1__2"),
       phy1_cad_lk1__3("phy1_cad_lk1__3"),
       phy1_cad_lk1__4("phy1_cad_lk1__4"),
       phy1_cad_lk1__5("phy1_cad_lk1__5"),
       phy1_cad_lk1__6("phy1_cad_lk1__6"),
       phy1_cad_lk1__7("phy1_cad_lk1__7"),
       lk1_ctl_phy1("lk1_ctl_phy1"),
       lk1_cad_phy1__0("lk1_cad_phy1__0"),
       lk1_cad_phy1__1("lk1_cad_phy1__1"),
       lk1_cad_phy1__2("lk1_cad_phy1__2"),
       lk1_cad_phy1__3("lk1_cad_phy1__3"),
       lk1_cad_phy1__4("lk1_cad_phy1__4"),
       lk1_cad_phy1__5("lk1_cad_phy1__5"),
       lk1_cad_phy1__6("lk1_cad_phy1__6"),
       lk1_cad_phy1__7("lk1_cad_phy1__7"),
       phy1_consume_lk1("phy1_consume_lk1"),
       lk1_disable_drivers_phy1("lk1_disable_drivers_phy1"),
       lk1_disable_receivers_phy1("lk1_disable_receivers_phy1"),
       ui_memory_write0("ui_memory_write0"),
       ui_memory_write1("ui_memory_write1"),
       ui_memory_write_address("ui_memory_write_address"),
       ui_memory_write_data("ui_memory_write_data"),
       ui_memory_read_address0("ui_memory_read_address0"),
       ui_memory_read_address1("ui_memory_read_address1"),
       ui_memory_read_data0("ui_memory_read_data0"),
       ui_memory_read_data1("ui_memory_read_data1"),
       history_memory_write0("history_memory_write0"),
       history_memory_write_address0("history_memory_write_address0"),
       history_memory_write_data0("history_memory_write_data0"),
       history_memory_read_address0("history_memory_read_address0"),
       history_memory_output0("history_memory_output0"),
       history_memory_write1("history_memory_write1"),
       history_memory_write_address1("history_memory_write_address1"),
       history_memory_write_data1("history_memory_write_data1"),
       history_memory_read_address1("history_memory_read_address1"),
       history_memory_output1("history_memory_output1"),
       memory_write0("memory_write0"),
       memory_write_address_vc0("memory_write_address_vc0"),
       memory_write_address_buffer0("memory_write_address_buffer0"),
       memory_write_address_pos0("memory_write_address_pos0"),
       memory_write_data0("memory_write_data0"),
       memory_read_address_vc0__0("memory_read_address_vc0__0"),
       memory_read_address_vc0__1("memory_read_address_vc0__1"),
       memory_read_address_buffer0__0("memory_read_address_buffer0__0"),
       memory_read_address_buffer0__1("memory_read_address_buffer0__1"),
       memory_read_address_pos0__0("memory_read_address_pos0__0"),
       memory_read_address_pos0__1("memory_read_address_pos0__1"),
       memory_output0__0("memory_output0__0"),
       memory_output0__1("memory_output0__1"),
       memory_write1("memory_write1"),
       memory_write_address_vc1("memory_write_address_vc1"),
       memory_write_address_buffer1("memory_write_address_buffer1"),
       memory_write_address_pos1("memory_write_address_pos1"),
       memory_write_data1("memory_write_data1"),
       memory_read_address_vc1__0("memory_read_address_vc1__0"),
       memory_read_address_vc1__1("memory_read_address_vc1__1"),
       memory_read_address_buffer1__0("memory_read_address_buffer1__0"),
       memory_read_address_buffer1__1("memory_read_address_buffer1__1"),
       memory_read_address_pos1__0("memory_read_address_pos1__0"),
       memory_read_address_pos1__1("memory_read_address_pos1__1"),
       memory_output1__0("memory_output1__0"),
       memory_output1__1("memory_output1__1"),
       ui_packet_usr("ui_packet_usr"),
       ui_vc_usr("ui_vc_usr"),
       ui_side_usr("ui_side_usr"),
       ui_directroute_usr("ui_directroute_usr"),
       ui_eop_usr("ui_eop_usr"),
       ui_available_usr("ui_available_usr"),
       ui_output_64bits_usr("ui_output_64bits_usr"),
       usr_consume_ui("usr_consume_ui"),
       usr_packet_ui("usr_packet_ui"),
       usr_available_ui("usr_available_ui"),
       usr_side_ui("usr_side_ui"),
       ui_freevc0_usr("ui_freevc0_usr"),
       ui_freevc1_usr("ui_freevc1_usr"),
       csr_bar__0("csr_bar__0"),
       csr_bar__1("csr_bar__1"),
       csr_bar__2("csr_bar__2"),
       csr_bar__3("csr_bar__3"),
       csr_bar__4("csr_bar__4"),
       csr_bar__5("csr_bar__5"),
       csr_unit_id("csr_unit_id"),
       usr_receivedResponseError_csr("usr_receivedResponseError_csr"),
       csr_read_addr_usr("csr_read_addr_usr"),
       usr_read_data_csr("usr_read_data_csr"),
       csr_write_usr("csr_write_usr"),
       csr_write_addr_usr("csr_write_addr_usr"),
       csr_write_data_usr("csr_write_data_usr"),
       csr_write_mask_usr("csr_write_mask_usr")
    {}

     ~vc_ht_tunnel_l1()
     {}

};
