task gmac_test1;
reg [31:0] read_data;
reg [3:0]  desc_ptr;
reg [9:0]  desc_rx_qbase;
reg [9:0]  desc_tx_qbase;
reg [7:0]  iFrmCnt;

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

   desc_ptr = 0;
   desc_rx_qbase = 10'h1C0;
   desc_tx_qbase = 10'h1C1;
   iFrmCnt  = 0;
   tb_top.u_tb_eth.init_port(3'b1, 3'b1, 1'b1, 0);

   tb_top.cpu_write('h1,8'h0,{4'h1,4'h1,8'h45,8'h01});  // tx/rx-control
   tb_top.cpu_write('h1,8'h8,{16'h0,8'd22,8'd22}); // Tx/Rx IFG
   tb_top.cpu_write('h1,8'h24,{desc_tx_qbase,desc_ptr,2'b00,
                               desc_rx_qbase,desc_ptr,2'b00}); // Tx/Rx Descriptor

   tb_top.u_tb_eth.set_flow_type(0);//L2 unicast 
   tb_top.u_tb_eth.set_L2_frame_size(1, 64, 84, 1); //, 1, 17, 33, 49, 64
   tb_top.u_tb_eth.set_payload_type(2, 5000,0); //make sure frame size is honored
   tb_top.u_tb_eth.set_L2_protocol(0); // Untagged frame
   tb_top.u_tb_eth.set_L2_source_address(0, 48'h12_34_56_78_9a_bc, 0,0);
   tb_top.u_tb_eth.set_L2_destination_address(0, 48'h16_22_33_44_55_66, 0,0);
   tb_top.u_tb_eth.set_L3_protocol(4); // IPV4
   tb_top.u_tb_eth.set_crc_option(0,0);
   
   fork
     tb_top.u_tb_eth.transmit_packet_sequence(10, 96, 1, 500000);
     begin
         tb_top.u_tb_eth.wait_for_event(3, 0);
         tb_top.u_tb_eth.wait_for_event(3, 0);
     end
     begin
        while(iFrmCnt != 10) begin
          tb_top.cpu_read('h1,8'h30,read_data); // Tx/Rx Counter
          if(read_data[3:0] != 0) begin // Check the Rx Q Counter
              // Read the Receive Descriptor
              tb_top.cpu_read('h4,{desc_rx_qbase,desc_ptr,2'b0},read_data); 
              // Write the Tx Descriptor
              tb_top.cpu_write('h4,{desc_tx_qbase,desc_ptr,2'b0},read_data); 
              desc_ptr = desc_ptr+1;
              iFrmCnt  = iFrmCnt+1;
          end
          #1000;
       end
     end
   join

  #100000;

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

