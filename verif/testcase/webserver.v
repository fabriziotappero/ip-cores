task webserver;
reg [31:0] read_data;
reg [3:0]  desc_ptr;
reg [9:0]  desc_rx_qbase;
reg [9:0]  desc_tx_qbase;
reg [7:0]  iFrmCnt;

reg [31:0] outfile;
begin
  //--------------------------
  // Data Memory MAP
  //-------------------------
  // 0x0000 to 0x0FFF - 4K - Processor Data Memory
  // 0x1000 to 0x1FFF - 4K - Gmac Rx Data Memory
  // 0x2000 to 0x2FFF - 4K - Reserved for Rx
  // 0x3000 to 0x3FFF - 4K - Gmac Tx Data Memory
  // 0x4000 to 0x4FFF - 4K - Reserved for Tx
  // 0x7000 to 0x703F - 64 - Rx Descriptor
  // 0x7040 to 0x707F - 64 - Tx Descripto

   events_log = $fopen("../test_log_files/test1_events.log");
   tb_top.u_tb_eth.event_file = events_log;

   outfile = $fopen("../test_log_files/test1_outfile.log");
   tb_top.u_tb_eth.outfile = outfile;
   $system("cp ../testcase/dat/webserver.dat ./dat/oc8051_xrom.in");
   // Enable the RISC booting + Internal ROM Mode
   tb_top.ea_in       = 1;
   tb_top.master_mode = 1;

   #1000 wait(reset_out_n == 1);


   desc_ptr = 0;
   desc_rx_qbase = 10'h1C0; // MSB 10 Bits of 0x7000
   desc_tx_qbase = 10'h1C1; // MSB 10 Bits of 0x7040
   iFrmCnt  = 0;
   tb_top.u_tb_eth.init_port(3'b1, 3'b1, 1'b1, 0);

   tb_top.cpu_write('h1,8'h0,{4'h1,4'h1,8'h45,8'h19});  // tx/rx-control
   tb_top.cpu_write('h1,8'h8,{16'h0,8'd22,8'd22}); // Tx/Rx IFG
   tb_top.cpu_write('h1,8'h24,{desc_tx_qbase,desc_ptr,2'b00,
                               desc_rx_qbase,desc_ptr,2'b00}); // Tx/Rx Descriptor

   tb_top.u_tb_eth.set_L2_custom_header(42,336'h01_02_03_04_05_06_11_12_13_14_15_16_08_06_00_01_11_22_06_04_00_01_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_0A_01_01_01);//L2 unicast 
   tb_top.u_tb_eth.set_flow_type(0);//L2 unicast 
   tb_top.u_tb_eth.set_L2_frame_size(1, 64, 84, 1); //, 1, 17, 33, 49, 64
   tb_top.u_tb_eth.set_payload_type(2, 5000,0); //make sure frame size is honored
   //tb_top.u_tb_eth.set_L2_protocol(0); // Untagged frame
   //tb_top.u_tb_eth.set_L2_source_address(0, 48'h12_34_56_78_9a_bc, 0,0);
   //tb_top.u_tb_eth.set_L2_destination_address(0, 48'h16_22_33_44_55_66, 0,0);
   tb_top.u_tb_eth.set_L3_protocol(4); // IPV4
   tb_top.u_tb_eth.set_crc_option(0,0);
   
   fork
     begin
	   // Send ARP Packet
        tb_top.u_tb_eth.set_L2_custom_header(42,336'h01_02_03_04_05_06_11_12_13_14_15_16_08_06_00_01_11_22_06_04_00_01_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_0A_01_01_01);//L2 unicast 
	tb_top.u_tb_eth.print_packet_parameters();
          tb_top.u_tb_eth.transmit_packet_sequence(1, 96, 1, 500000);
	  #1000; // wait for IFG
	   // Send IP Packet + ICMP Request
        tb_top.u_tb_eth.set_L2_custom_header(42,336'h01_02_03_04_05_06_11_12_13_14_15_16_08_00_00_01_11_22_06_04_00_01_00_01_00_00_00_00_00_00_0A_01_01_01_08_00_00_00_0A_01_01_01);//L2 unicast 
	tb_top.u_tb_eth.print_packet_parameters();
          tb_top.u_tb_eth.transmit_packet_sequence(1, 96, 1, 500000);
	  #1000; // wait for IFG
 
	  // Packet No: 3 
	  // Send IP4 + TCP + Flag with SYNC
	  tb_top.u_tb_eth.set_flow_type(5);//L4
          tb_top.u_tb_eth.set_L2_protocol(0); // Ethernet without VLAN
          tb_top.u_tb_eth.set_L3_protocol(4); // IPV4
          tb_top.u_tb_eth.set_L4_protocol(0); // TCP
	  tb_top.u_tb_eth.set_IP_header(32'h0a010102,32'h0a010101,0,1,0,0,0,6);
	  tb_top.u_tb_eth.set_TCP_header_fields(0,8'h2,0,0);
	  tb_top.u_tb_eth.set_TCP_port_numbers(16'h1000,16'h50); // decimal: 80. Hex:50
	  tb_top.u_tb_eth.print_packet_parameters();
          tb_top.u_tb_eth.transmit_packet_sequence(1, 96, 1, 500000);
	  #1000; // wait for IFG

	  // Packet No: 4 
	  // Send IP4 + TCP + Flag with ACk
	  tb_top.u_tb_eth.set_flow_type(5);//L4
          tb_top.u_tb_eth.set_L2_protocol(0); // Ethernet without VLAN
          tb_top.u_tb_eth.set_L3_protocol(4); // IPV4
          tb_top.u_tb_eth.set_L4_protocol(0); // TCP
	  tb_top.u_tb_eth.set_IP_header(32'h0a010102,32'h0a010101,0,1,0,0,0,6);
	  tb_top.u_tb_eth.set_TCP_header_fields(0,16'h10,0,0);
	  tb_top.u_tb_eth.set_TCP_port_numbers(16'h1000,16'h50); // decimal: 80. Hex:50
	  tb_top.u_tb_eth.print_packet_parameters();
          tb_top.u_tb_eth.transmit_packet_sequence(1, 96, 1, 500000);
	  #1000; // wait for IFG
          $display("Status: End of Transmission Loop");
     end
     begin
         tb_top.u_tb_eth.wait_for_event(3, 0);
         tb_top.u_tb_eth.wait_for_event(3, 0);
         $display("Status: End of Waiting Event Loop");
     end
   join

  #3500000;
  $display("Status: End of Waiting Delay Loop");

  `TB_AGENTS_GMAC.full_mii.status; // test status

  // Check the Transmitted & Received Frame cnt
  if(`TB_AGENTS_GMAC.full_mii.transmitted_packet_count != `TB_AGENTS_GMAC.full_mii.receive_packet_count)
       `TB_GLBL.test_err;

  // Check the Transmitted & Received Byte cnt
  if(`TB_AGENTS_GMAC.full_mii.transmitted_packet_byte_count != `TB_AGENTS_GMAC.full_mii.receive_packet_byte_count)
       `TB_GLBL.test_err;

  if(`TB_AGENTS_GMAC.full_mii.receive_crc_err_count)
       `TB_GLBL.test_err;

end
endtask

