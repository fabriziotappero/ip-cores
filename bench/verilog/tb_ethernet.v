

//   Created by Igor Mohor 
//   Changed by Ran Minerbi
//
//`include "switch.v"
`include "eth_phy_defines.v"
`include "wb_model_defines.v"
`include "tb_eth_defines.v"
`include "ethmac_defines.v"
`include "timescale.v"

  
module tb_instantiations( );

     wire [3:0] Rx1, Rx2,Rx3, Rx4,Rx5, Rx6;
     wire [3:0] Tx1 ,Tx2,Tx3 ,Tx4,Tx5 ,Tx6;      //B2B
     wire  Tx_En1 , Tx_En2,Tx_En3 , Tx_En4 ,Tx_En5 , Tx_En6 , Rx_Valid1, Rx_Valid2,Rx_Valid3, Rx_Valid4,Rx_Valid5, Rx_Valid6;
    // assign Rx2 = Tx1;
     //assign Rx1 = Tx2;
     assign Rx_Valid2 = Tx_En1;
     assign Rx_Valid1 = Tx_En2;
     assign Rx_Valid4 = Tx_En3; 
     assign Rx_Valid3 = Tx_En4; 
     assign Rx_Valid6 = Tx_En5; 
     assign Rx_Valid5 = Tx_En6; 
     
	     reg [63:0] MAC1,MAC2,MAC3,MAC4,MAC5,MAC6;
     initial begin
          MAC1 =  64'h0000_AA203040_5060;
          MAC2 =  64'h0000_FFCCBB44_0011; 
          MAC3 =  64'h0000_DDFFBB55_0022; 
          MAC4 =  64'h0000_CCBBAA99_0099; 
          MAC5 =  64'h0000_66EECC00_1133;  
          MAC6 =  64'h0000_1100AAFF_00AA;  
         end
    tb_ethernet nic1(Tx1,Rx1 , 2'h2 ,Tx_En1,Rx_Valid1, MAC1, MAC2 );   // mode=1 --nic 1 transmit test 23  --> nic2 rcv ethmac output
    tb_ethernet nic2(Tx2,Rx2 , 2'h2 ,Tx_En2,Rx_Valid2 ,MAC2, MAC1 );    //mode =0 -- nic 2 transmit test ::rcv  15     -->  nic1 rcv eth_phy output
    tb_ethernet nic3(Tx3,Rx3 , 2'h2 ,Tx_En3,Rx_Valid3, MAC3, MAC4 );   // mode=1 --nic 1 transmit test 23  --> nic2 rcv ethmac output
    tb_ethernet nic4(Tx4,Rx4 , 2'h2 ,Tx_En4,Rx_Valid4 ,MAC4, MAC3 );    //mode =0 -- nic 2 transmit test ::rcv  15     -->  nic1 rcv eth_phy output
    
    switch SX(Tx1,Tx2,Tx3,Tx4,Tx5,Tx6,Rx2,Rx1,Rx4,Rx3,Rx6,Rx5);
      // tb_ethernet nic3(1'h0);
 /* $display("#########  tb_instantiations occurance ###################################");
  $display("===========================================================================");
    */
    
endmodule
    
  
module tb_ethernet(Tx , Rx , mode ,Tx_en , Rx_valid ,MAC ,DMAC);     //Tx , Rx , mode(transmit = 1 / rcv = 0) , mac    , 

 input [1:0] mode;
input  [3:0] Rx;
input [63:0] MAC ,DMAC;
output [3:0] Tx;
output  Tx_en;
input   Rx_valid;

reg           wb_clk;
reg           wb_rst;
wire          wb_int;

wire          mtx_clk;  // This goes to PHY
wire          mrx_clk;  // This goes to PHY

wire   [3:0]  MTxD;
wire          MTxEn;
wire          MTxErr;

wire   [3:0]  MRxD;     // This goes to PHY
wire   [3:0]  MRxD_to_ethmac;
wire   [3:0]  MRxD_to_Tx;
wire          MRxDV_to_ethmac;
wire          MRxDV;    // This goes to PHY
wire          MRxErr;   // This goes to PHY
wire          MColl;    // This goes to PHY
wire          MCrs;     // This goes to PHY

wire          Mdi_I;
wire          Mdo_O;
wire          Mdo_OE;
tri           Mdio_IO;
wire          Mdc_O;

assign  Tx =mode? MTxD:MRxD;   
assign  MRxD_to_ethmac = Rx;
assign  MRxD_to_Tx = MRxD;
assign  Tx_en = mode? MTxEn:MRxDV;
assign  MRxDV_to_ethmac = Rx_valid;
//assign  MRxD_to_Tx = Rx;


parameter Tp = 1;

    
// Ethernet Slave Interface signals
wire [31:0] eth_sl_wb_adr;
wire [31:0] eth_sl_wb_adr_i, eth_sl_wb_dat_o, eth_sl_wb_dat_i;
wire  [3:0] eth_sl_wb_sel_i;
wire        eth_sl_wb_we_i, eth_sl_wb_cyc_i, eth_sl_wb_stb_i, eth_sl_wb_ack_o, eth_sl_wb_err_o;

// Ethernet Master Interface signals
wire [31:0] eth_ma_wb_adr_o, eth_ma_wb_dat_i, eth_ma_wb_dat_o;
wire  [3:0] eth_ma_wb_sel_o;
wire        eth_ma_wb_we_o, eth_ma_wb_cyc_o, eth_ma_wb_stb_o, eth_ma_wb_ack_i, eth_ma_wb_err_i;

wire  [2:0] eth_ma_wb_cti_o;
wire  [1:0] eth_ma_wb_bte_o;
             

     
  
// Connecting Ethernet top module
ethmac eth_top
(
  // WISHBONE common
  .wb_clk_i(wb_clk),              .wb_rst_i(wb_rst), 

  // WISHBONE slave
  .wb_adr_i(eth_sl_wb_adr_i[11:2]), .wb_sel_i(eth_sl_wb_sel_i),   .wb_we_i(eth_sl_wb_we_i), 
  .wb_cyc_i(eth_sl_wb_cyc_i),       .wb_stb_i(eth_sl_wb_stb_i),   .wb_ack_o(eth_sl_wb_ack_o), 
  .wb_err_o(eth_sl_wb_err_o),       .wb_dat_i(eth_sl_wb_dat_i),   .wb_dat_o(eth_sl_wb_dat_o), 
 	
  // WISHBONE master
  .m_wb_adr_o(eth_ma_wb_adr_o),     .m_wb_sel_o(eth_ma_wb_sel_o), .m_wb_we_o(eth_ma_wb_we_o), 
  .m_wb_dat_i(eth_ma_wb_dat_i),     .m_wb_dat_o(eth_ma_wb_dat_o), .m_wb_cyc_o(eth_ma_wb_cyc_o), 
  .m_wb_stb_o(eth_ma_wb_stb_o),     .m_wb_ack_i(eth_ma_wb_ack_i), .m_wb_err_i(eth_ma_wb_err_i), 

`ifdef ETH_WISHBONE_B3
  .m_wb_cti_o(eth_ma_wb_cti_o),     .m_wb_bte_o(eth_ma_wb_bte_o),
`endif

  //TX
  .mtx_clk_pad_i(mtx_clk), .mtxd_pad_o(MTxD), .mtxen_pad_o(MTxEn), .mtxerr_pad_o(MTxErr),

  //RX
  .mrx_clk_pad_i(mrx_clk), .mrxd_pad_i(MRxD_to_ethmac), .mrxdv_pad_i(MRxDV_to_ethmac), .mrxerr_pad_i(MRxErr), 
  .mcoll_pad_i(MColl),    .mcrs_pad_i(MCrs), 
  
  // MIIM
  .mdc_pad_o(Mdc_O), .md_pad_i(Mdi_I), .md_pad_o(Mdo_O), .md_padoe_o(Mdo_OE),
  
  .int_o(wb_int)

  // Bist
`ifdef ETH_BIST
  ,
  .mbist_si_i       (1'b0),
  .mbist_so_o       (),
  .mbist_ctrl_i       (3'b001) // {enable, clock, reset}
`endif
);

   

// Connecting Ethernet PHY Module
assign Mdio_IO = Mdo_OE ? Mdo_O : 1'bz ;   
assign Mdi_I   = Mdio_IO;
integer phy_log_file_desc;

eth_phy eth_phy
(
  // WISHBONE reset
  .m_rst_n_i(!wb_rst),

  // MAC TX
  .mtx_clk_o(mtx_clk),    .mtxd_i(MTxD),    .mtxen_i(MTxEn),    .mtxerr_i(MTxErr),

  // MAC RX
  .mrx_clk_o(mrx_clk),    .mrxd_o(MRxD),    .mrxdv_o(MRxDV),    .mrxerr_o(MRxErr),
  .mcoll_o(MColl),        .mcrs_o(MCrs),

  // MIIM
  .mdc_i(Mdc_O),          .md_io(Mdio_IO),

  // SYSTEM
  .phy_log(phy_log_file_desc)
);



// Connecting WB Master as Host Interface
integer host_log_file_desc;
   
WB_MASTER_BEHAVIORAL wb_master
(
    .CLK_I(wb_clk),
    .RST_I(wb_rst),
    .TAG_I({`WB_TAG_WIDTH{1'b0}}),
    .TAG_O(),
    .ACK_I(eth_sl_wb_ack_o),
    .ADR_O(eth_sl_wb_adr), // only eth_sl_wb_adr_i[11:2] used
    .CYC_O(eth_sl_wb_cyc_i),
    .DAT_I(eth_sl_wb_dat_o),
    .DAT_O(eth_sl_wb_dat_i),
    .ERR_I(eth_sl_wb_err_o),
    .RTY_I(1'b0),  // inactive (1'b0)
    .SEL_O(eth_sl_wb_sel_i),
    .STB_O(eth_sl_wb_stb_i),
    .WE_O (eth_sl_wb_we_i),
    .CAB_O()       // NOT USED for now!
);

assign eth_sl_wb_adr_i = {20'h0, eth_sl_wb_adr[11:2], 2'h0};



// Connecting WB Slave as Memory Interface Module
integer memory_log_file_desc;

WB_SLAVE_BEHAVIORAL wb_slave
(
    .CLK_I(wb_clk),
    .RST_I(wb_rst),
    .ACK_O(eth_ma_wb_ack_i),
    .ADR_I(eth_ma_wb_adr_o),
    .CYC_I(eth_ma_wb_cyc_o),
    .DAT_O(eth_ma_wb_dat_i),
    .DAT_I(eth_ma_wb_dat_o),
    .ERR_O(eth_ma_wb_err_i),
    .RTY_O(),      // NOT USED for now!
    .SEL_I(eth_ma_wb_sel_o),
    .STB_I(eth_ma_wb_stb_o),
    .WE_I (eth_ma_wb_we_o),
    .CAB_I(1'b0)
);



// Connecting WISHBONE Bus Monitors to ethernet master and slave interfaces
integer wb_s_mon_log_file_desc ;
integer wb_m_mon_log_file_desc ;

WB_BUS_MON wb_eth_slave_bus_mon
(
  // WISHBONE common
  .CLK_I(wb_clk),
  .RST_I(wb_rst),

  // WISHBONE slave
  .ACK_I(eth_sl_wb_ack_o),
  .ADDR_O({20'h0, eth_sl_wb_adr_i[11:2], 2'b0}),
  .CYC_O(eth_sl_wb_cyc_i),
  .DAT_I(eth_sl_wb_dat_o),
  .DAT_O(eth_sl_wb_dat_i),
  .ERR_I(eth_sl_wb_err_o),
  .RTY_I(1'b0),
  .SEL_O(eth_sl_wb_sel_i),
  .STB_O(eth_sl_wb_stb_i),
  .WE_O (eth_sl_wb_we_i),
  .TAG_I({`WB_TAG_WIDTH{1'b0}}),
`ifdef ETH_WISHBONE_B3
  .TAG_O({eth_ma_wb_cti_o, eth_ma_wb_bte_o}),
`else
  .TAG_O(5'h0),
`endif
  .CAB_O(1'b0),
`ifdef ETH_WISHBONE_B3
  .check_CTI          (1'b1),
`else
  .check_CTI          (1'b0),
`endif
  .log_file_desc (wb_s_mon_log_file_desc)
);

WB_BUS_MON wb_eth_master_bus_mon
(
  // WISHBONE common
  .CLK_I(wb_clk),
  .RST_I(wb_rst),

  // WISHBONE master
  .ACK_I(eth_ma_wb_ack_i),
  .ADDR_O(eth_ma_wb_adr_o),
  .CYC_O(eth_ma_wb_cyc_o),
  .DAT_I(eth_ma_wb_dat_i),
  .DAT_O(eth_ma_wb_dat_o),
  .ERR_I(eth_ma_wb_err_i),
  .RTY_I(1'b0),
  .SEL_O(eth_ma_wb_sel_o),
  .STB_O(eth_ma_wb_stb_o),
  .WE_O (eth_ma_wb_we_o),
  .TAG_I({`WB_TAG_WIDTH{1'b0}}),
  .TAG_O(5'h0),
  .CAB_O(1'b0),
  .check_CTI(1'b0), // NO need
  .log_file_desc(wb_m_mon_log_file_desc)
);

   

reg         StartTB;
integer     tb_log_file;

initial
begin
  tb_log_file = $fopen("../log/eth_tb.log");
  if (tb_log_file < 2)
  begin
    $display("*E Could not open/create testbench log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(tb_log_file, "========================== ETHERNET IP Core Testbench results ===========================");
  $fdisplay(tb_log_file, " ");

  phy_log_file_desc = $fopen("../log/eth_tb_phy.log");
  if (phy_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_phy.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(phy_log_file_desc, "================ PHY Module  Testbench access log ================");
  $fdisplay(phy_log_file_desc, " ");

  memory_log_file_desc = $fopen("../log/eth_tb_memory.log");
  if (memory_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_memory.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(memory_log_file_desc, "=============== MEMORY Module Testbench access log ===============");
  $fdisplay(memory_log_file_desc, " ");

  host_log_file_desc = $fopen("../log/eth_tb_host.log");
  if (host_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_host.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(host_log_file_desc, "================ HOST Module Testbench access log ================");
  $fdisplay(host_log_file_desc, " ");

  wb_s_mon_log_file_desc = $fopen("../log/eth_tb_wb_s_mon.log");
  if (wb_s_mon_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_wb_s_mon.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(wb_s_mon_log_file_desc, "============== WISHBONE Slave Bus Monitor error log ==============");
  $fdisplay(wb_s_mon_log_file_desc, " ");
  $fdisplay(wb_s_mon_log_file_desc, "   Only ERRONEOUS conditions are logged !");
  $fdisplay(wb_s_mon_log_file_desc, " ");

  wb_m_mon_log_file_desc = $fopen("../log/eth_tb_wb_m_mon.log");
  if (wb_m_mon_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_wb_m_mon.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(wb_m_mon_log_file_desc, "============= WISHBONE Master Bus Monitor  error log =============");
  $fdisplay(wb_m_mon_log_file_desc, " ");
  $fdisplay(wb_m_mon_log_file_desc, "   Only ERRONEOUS conditions are logged !");
  $fdisplay(wb_m_mon_log_file_desc, " ");

`ifdef VCD
   $dumpfile("../build/sim/ethmac.vcd");
   $dumpvars(0);
`endif
  // Reset pulse
  wb_rst =  1'b1;
  #423 wb_rst =  1'b0;

  // Clear memories
  clear_memories;
  clear_buffer_descriptors;

  #423 StartTB  =  1'b1;
end



// Generating wb_clk clock
initial
begin
  wb_clk=0;
//  forever #2.5 wb_clk = ~wb_clk;  // 2*2.5 ns -> 200.0 MHz    
//  forever #5 wb_clk = ~wb_clk;  // 2*5 ns -> 100.0 MHz    
//  forever #10 wb_clk = ~wb_clk;  // 2*10 ns -> 50.0 MHz    
//  forever #12.5 wb_clk = ~wb_clk;  // 2*12.5 ns -> 40 MHz    
  forever #15 wb_clk = ~wb_clk;  // 2*10 ns -> 33.3 MHz    
//  forever #20 wb_clk = ~wb_clk;  // 2*20 ns -> 25 MHz    
//  forever #25 wb_clk = ~wb_clk;  // 2*25 ns -> 20.0 MHz
//  forever #31.25 wb_clk = ~wb_clk;  // 2*31.25 ns -> 16.0 MHz    
//  forever #50 wb_clk = ~wb_clk;  // 2*50 ns -> 10.0 MHz
//  forever #55 wb_clk = ~wb_clk;  // 2*55 ns ->  9.1 MHz    
end



integer      tests_successfull;
integer      tests_failed;
reg [799:0]  test_name; // used for tb_log_file

reg   [3:0]  wbm_init_waits; // initial wait cycles between CYC_O and STB_O of WB Master
reg   [3:0]  wbm_subseq_waits; // subsequent wait cycles between STB_Os of WB Master
reg   [3:0]  wbs_waits; // wait cycles befor WB Slave responds
reg   [7:0]  wbs_retries; // if RTY response, then this is the number of retries before ACK

reg          wbm_working; // tasks wbm_write and wbm_read set signal when working and reset it when stop working


initial
begin
  wait(StartTB);  // Start of testbench

  // Initial global values
  tests_successfull = 0;
  tests_failed = 0;
  
  wbm_working = 0;

  wbm_init_waits = 4'h1;
  wbm_subseq_waits = 4'h3;
  wbs_waits = 4'h1;
  wbs_retries = 8'h2; 
  wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

  // set DIFFERENT mrx_clk to mtx_clk!
//  eth_phy.set_mrx_equal_mtx = 1'b0;

  //  Call tests
  //  ----------
  //  test_access_to_mac_reg(0, 4);           // 0 - 4
  //  test_mii(0, 17);                        // 0 - 17
  $display("");
  $display("===========================================================================");
  $display("PHY generates ideal Carrier sense and Collision signals for following tests");
  $display("===========================================================================");
  test_note("PHY generates ideal Carrier sense and Collision signals for following tests");
  eth_phy.carrier_sense_real_delay(0);
   if (mode == 1)   //transmit
     test_mac_full_duplex_transmit(23, 23);    // 0 - 23
   if (mode ==0)
     test_mac_full_duplex_receive(15, 15);     // 0 - 15
    if (mode ==2)  
    test_mac_full_duplex_flow_control(5, MAC ,DMAC); // 0 - 5

    // Tests not working, yet.
    // test_mac_half_duplex_flow(0, 5);  // 0, 1, 2, 3, 4, 5 These tests need to be fixed !!!

    $display("");
    $display("===========================================================================");
    $display("PHY generates 'real delayed' Carrier sense and Collision signals for following tests");
    $display("===========================================================================");
    test_note("PHY generates 'real delayed' Carrier sense and Collision signals for following tests");
  //  eth_phy.carrier_sense_real_delay(1);
  //  test_mac_full_duplex_transmit(0, 23);    // 0 - 23
  //  test_mac_full_duplex_receive(0, 15);     // 0 - 15
//    test_mac_full_duplex_flow_control(0, 5); // 0 - 5
    //test_mac_half_duplex_flow(0, 5);
 
 
  // Finish test's logs
  test_summary;
  $display("\n\n END of SIMULATION");
  $fclose(tb_log_file | phy_log_file_desc | memory_log_file_desc | host_log_file_desc);
  $fclose(wb_s_mon_log_file_desc | wb_m_mon_log_file_desc);

  $stop;
end
  


//////////////////////////////////////////////////////////////
// Test tasks
//////////////////////////////////////////////////////////////
 

task test_mac_full_duplex_transmit;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        num_of_frames;
  integer        num_of_bd;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_len;
  integer        tmp_bd;
  integer        tmp_bd_num;
  integer        tmp_data;
  integer        tmp_ipgt;
  integer        test_num;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        speed;
  reg            no_underrun;
  reg            frame_started;
  reg            frame_ended;
  reg            wait_for_frame;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg    [31:0]  tmp;
  reg    [ 7:0]  st_data;
  reg    [15:0]  max_tmp;
  reg    [15:0]  min_tmp;

begin
// MAC FULL DUPLEX TRANSMIT TEST
test_heading("MAC FULL DUPLEX TRANSMIT TEST");
$display(" ");
$display("MAC FULL DUPLEX TRANSMIT TEST");
fail = 0;

// reset MAC registers
hard_reset;
// set wb slave response
wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);


//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_mac_full_duplex_transmit:                              ////
////                                                              ////
////  0: Test no transmit when all buffers are RX ( 10Mbps ).     ////
////  1: Test no transmit when all buffers are RX ( 100Mbps ).    ////
////  2: Test transmit packets from MINFL to MAXFL sizes at       ////
////     one TX buffer decriptor ( 10Mbps ).                      ////
////  3: Test transmit packets from MINFL to MAXFL sizes at       ////
////     one TX buffer decriptor ( 100Mbps ).                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

   ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets (DELAYED CRC) from MINFL to MAXFL   ////
  ////  sizes at one TX buffer decriptor ( 100Mbps ).             ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 23) //
  begin
    // TEST 23: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )
    test_name = "TEST 23: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )";
    `TIME; $display("  TEST 23: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )");
  
 // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 TX and 1 RX buffer descriptor (8'h01) - must be set before RX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h01, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG |
              `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
                         
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
//set Rx descriptor
     
    max_tmp = 0;
    min_tmp = 0;
    // set one TX buffer descriptor - must be set before TX enable
        wait (wbm_working == 0);
     wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
     wait (wbm_working == 0);
     wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
     wait (wbm_working == 0);
     wbm_write(`ETH_IPv4_L1_ADR, 32'h45020265, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h5A;
    set_tx_packet(`MEMORY_BASE, (max_tmp), st_data); // length without CRC
    st_data = 8'h10;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0])); //tx_bd_num_start ,tx_bd_num_end ,len,irq,pad,crc,txpnt
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      eth_phy.set_tx_mem_addr(max_tmp);
      // set wrap bit
      set_tx_bd_wrap(0);
      set_tx_bd_ready(0, 0);
      #1 check_tx_bd(0, data);
      if (i_length < min_tmp) // just first four
      begin
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else if (i_length > (max_tmp - 8)) // just last four
      begin
        tmp = 0;
        wait (MTxEn === 1'b1); // start transmit
        while (tmp < (i_length - 20))
        begin
          #1 tmp = tmp + 1;
          @(posedge wb_clk);
        end
        #1 check_tx_bd(0, data);
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else
      begin
        wait (MTxEn === 1'b1); // start transmit
        #1 check_tx_bd(0, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      // check length of a PACKET
           // check transmitted TX packet data
      if (i_length[0] == 0)
      begin
        check_tx_packet((`MEMORY_BASE + i_length[1:0]), max_tmp, i_length, tmp);
      end
      else
      begin
        check_tx_packet(((`MEMORY_BASE + i_length[1:0]) + max_tmp), max_tmp, i_length, tmp);
      end
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      check_tx_crc_delayed(max_tmp, i_length, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E tx WB INT signal should not be set");
          test_fail("WB INT tx signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(0, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if (data[15:0] !== 16'h3800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX buffer descriptor
      clear_tx_bd(0, 0);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h", data);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 60 byte)",
                 min_tmp, (min_tmp + 64));
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    pads appending to packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 500 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 60 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 60;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 500;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 60;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end



end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mac_full_duplex_transmit
            
              
task test_mac_full_duplex_receive;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        num_of_frames;
  integer        num_of_bd;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_len;
  integer        tmp_bd;
  integer        tmp_bd_num;
  integer        tmp_data;
  integer        tmp_ipgt;
  integer        test_num;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        speed;
  reg            frame_started;
  reg            frame_ended;
  reg            wait_for_frame;
  reg            check_frame;
  reg            stop_checking_frame;
  reg            first_fr_received;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg    [31:0]  tmp;
  reg    [ 7:0]  st_data;
  reg    [15:0]  max_tmp;
  reg    [15:0]  min_tmp;
begin
// MAC FULL DUPLEX RECEIVE TEST
test_heading("MAC FULL DUPLEX RECEIVE TEST");
$display(" ");
$display("MAC FULL DUPLEX RECEIVE TEST");
fail = 0;

// reset MAC registers
hard_reset;
// set wb slave response
wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

 for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test no receive when all buffers are TX ( 10Mbps ).       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets (delayed CRC) at one RX BD and       ////
  ////  check addresses ( 100Mbps ).                              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 15) //
  begin
    // TEST 15: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )
    test_name   = "TEST 15: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )";
    `TIME; $display("  TEST 15: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )");

    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    num_of_frames = 0;
    i_length = 64;
    while (num_of_frames < 1)
    begin
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      case (num_of_frames)
      0: // unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
     //  st_data = 8'h0F;
     //   set_rx_packet_delayed_L3(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
      //  append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet (delayed CRC) is going to be received with PRO bit (wrap at 1st BD)");
      end
      1: // unicast + delayed CRC
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG, set delayed CRC
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
      //  st_data = 8'h12;
      //  set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
     //   append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet (delayed CRC) is going to be received without PRO bit (wrap at 1st BD)");
      end
      2: // wrong unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
       st_data = 8'h31;
       set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
       append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet (delayed CRC) is going to be received with PRO bit (wrap at 1st BD)");
      end
      3: // wrong unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
       st_data = 8'h0F;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet (delayed CRC) is NOT going to be received without PRO bit (wrap at 1st BD)");
      end
      4: // broadcast + PRO + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
         st_data = 8'h84;
         set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
         append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received with PRO & without Reject_BRO bit (wrap at 1st BD)");
      end
      5: // broadcast       + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
         st_data = 8'h48;
         set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
         append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received without Reject_BRO bit (wrap at 1st BD)");
      end
      6: // broadcast + PRO + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h30;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received with PRO & with Reject_BRO bit (wrap at 1st BD)");
      end
      7: // broadcast       + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG |
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_FFCC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_MAC_ADDR0, 32'hBB44_0011, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
      st_data = 8'h04;
      set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
      append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is NOT going to be received with Reject_BRO bit (wrap at 1st BD)");
      end
      default:
      begin
      end
      endcase
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
         // #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: wait_for_rece1
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          while (data[15] === 1)
          begin
            #1 check_rx_bd(127, data);
            @(posedge wb_clk);
          end
          disable check_wait_for_rece1;
          $display("    ->packet received");
          repeat (1) @(posedge wb_clk);
        end
        begin: check_wait_for_rece1
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          repeat(10) @(posedge mrx_clk);
          repeat(50) @(posedge wb_clk);
          wait (wbm_working == 0);
          disable wait_for_rece1;
          $display("    ->packet NOT received");
        end
      join
      // PACKET checking
      wait (wbm_working == 0);
      check_rx_bd(127, data);
      case (num_of_frames)
      0, 1, 4, 5:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      2, 6:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      3, 7:
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hE000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      default:
      begin
      end
      endcase
      // clear RX buffer descriptor
      clear_rx_bd(127, 127);
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      num_of_frames = num_of_frames + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mac_full_duplex_receive

                     
     

task test_mac_full_duplex_flow_control;
  input  [31:0]  start_task;
  input  [63:0]  MAC ,DMAC;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        num_of_frames;
  integer        num_of_rx_frames;
  integer        num_of_bd;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_len;
  integer        tmp_bd;
  integer        tmp_bd_num;
  integer        tmp_data;
  integer        tmp_ipgt;
  integer        test_num;
  integer        rx_len;
  integer        tx_len;
  reg    [31:0]  tx_bd_num;
  reg    [31:0]  rx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        speed;
  integer        mac_hi_addr;
  integer        mac_lo_addr;
  reg            frame_started;
  reg            frame_ended;
  reg            wait_for_frame;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg    [31:0]  tmp;
  reg    [ 7:0]  st_data;
  reg    [15:0]  max_tmp;
  reg    [15:0]  min_tmp;
  reg            PassAll;
  reg            RxFlow;
  reg            enable_irq_in_rxbd;
  reg    [15:0]  pause_value;
  
begin
// MAC FULL DUPLEX FLOW CONTROL TEST
test_heading("MAC FULL DUPLEX FLOW CONTROL TEST");
$display(" ");
$display("MAC FULL DUPLEX FLOW CONTROL TEST");
fail = 0;

// reset MAC registers
hard_reset;
// set wb slave response
wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

 
for (test_num = start_task; test_num <= start_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Random receive and transmit frames at one TX and          ////
  ////  one RX buffer decriptor ( 100Mbps ).                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) // 
  begin
    // TEST 5: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 100Mbps )
    test_name   = "TEST 5: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 100Mbps )";
    `TIME; $display("  TEST 5: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 100Mbps )");

    // unmask interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 TX and 1 RX buffer descriptor (8'h01) - must be set before RX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h01, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable flow control

    wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL | `ETH_CTRLMODER_RXFLOW | `ETH_CTRLMODER_TXFLOW, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);

         wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, MAC[63:32], 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_MAC_ADDR0, MAC[31:0], 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.

        wait (wbm_working == 0);
        wbm_write(`ETH_DMAC_ADDR1, DMAC[63:32], 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);               
        wbm_write(`ETH_DMAC_ADDR0, DMAC[31:0], 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.


    // prepare one RX and one TX packet of 100 bytes long
    rx_len = 100; // length of frame without CRC
    st_data = 8'h1A;
    set_rx_packet(200, rx_len, 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    append_rx_crc (200, rx_len, 1'b0, 1'b0); // CRC for data packet
    tx_len = 73; // length of frame without CRC
    st_data = 8'h01;
    set_tx_packet(`MEMORY_BASE + 64, tx_len, st_data); // length without CRC
    // set TX and RX Buffer Descriptors 
    tx_bd_num = 0; // tx BDs go from 0 to 0
    rx_bd_num = 1; // rx BDs go from 1 to 1
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end

    // set EQUAL mrx_clk to mtx_clk!
//    eth_phy.set_mrx_equal_mtx = 1'b1;

    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    // TXB and RXB interrupts masked
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXE | `ETH_INT_RXE | `ETH_INT_BUSY | `ETH_INT_TXC | `ETH_INT_RXC, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    tmp_len = 0;
    num_of_frames = 0;
    num_of_rx_frames = 0;
//    num_of_iter = 0;
    // TX frame loop & RX frame loop work independently


    fork
      // TX frame loop
      while (num_of_frames < 8)
      begin
        eth_phy.set_tx_mem_addr(64 + num_of_frames);
        // set tx bd
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        set_tx_bd(0, 0, tx_len, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + 64));
        set_tx_bd_wrap(0);
        set_tx_bd_ready(0, 0);
        check_tx_bd(0, data);
        // check frame
        i = 0;
        while((i < 100) && (MTxEn === 1'b0)) // wait for start of TX frame!
        begin
          @(posedge mtx_clk);
          i = i + 1;
        end
        if (MTxEn != 1'b1)
        begin
          `TIME; $display("*E Tx Frame %0d: MAC TX didn't start transmitting the packet ,MTxEn %d", num_of_frames,MTxEn);
          test_fail("MAC TX didn't start transmitting the packet");
          fail = fail + 1;
          #10000 $stop;
        end

        repeat (30) @(posedge mtx_clk); // waiting some time so PHY clears the tx_len

        wait ((MTxEn === 1'b0) /*|| (eth_phy.tx_len > (tx_len + 4))*/) // wait for end of TX frame
        if (MTxEn != 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: MAC TX didn't stop transmitting the packet,MTxEn %d", num_of_frames,MTxEn);
          test_fail("MAC TX didn't stop transmitting the packet");
          fail = fail + 1;
          #10000 $stop;
        end
        tmp_len = eth_phy.tx_len;
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        check_tx_bd(0, data);
        while (data[15] === 1)
        begin
            // wait for WB master if it is working
            @(posedge wb_clk);
            while (wbm_working)
            begin
              @(posedge wb_clk);
            end
          check_tx_bd(0, data);
        end
        repeat (1) @(posedge wb_clk);
        // check length of a PACKET
  /*      if (tmp_len != (tx_len + 4))
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong length of the packet out from MAC (%0d instead of %0d)", num_of_frames, 
                          tmp_len, (tx_len + 4));
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end    */
        // check transmitted TX packet data
        check_tx_packet((`MEMORY_BASE + 64), (64 + num_of_frames), (tx_len), tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong data of the transmitted packet", num_of_frames);
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        check_tx_crc((64 + num_of_frames), (tx_len), 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong CRC of the transmitted packet", num_of_frames);
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: WB INT signal should not be set", num_of_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check TX buffer descriptor of a packet
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        check_tx_bd(0, data);
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E Tx Frame %0d: TX buffer descriptor status is not correct: %0h", num_of_frames, data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_TXB) !== `ETH_INT_TXB)
        begin
          `TIME; $display("*E Tx Frame %0d: Interrupt Transmit Buffer was not set, interrupt reg: %0h", num_of_frames, data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~(`ETH_INT_TXB | `ETH_INT_RXB))) !== 0) // RXB might occur at the same time - not error
        begin
          `TIME; $display("*E Tx Frame %0d: Other interrupts (except Tx and Rx Buffer) were set, interrupt reg: %0h", 
                          num_of_frames, data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts (except RXB)
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        wbm_write(`ETH_INT, (data & (~`ETH_INT_RXB)), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: WB INT signal should not be set", num_of_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // Displays
        if (num_of_frames[2:0] == 3'b111)
        begin
          $display("   ->8 frames transmitted");
        end
        // set length (loop variable)
        num_of_frames = num_of_frames + 1;
      end // TX frame loop
      // RX frame loop
      while (num_of_rx_frames < 400)
      begin
        // set rx bd
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        set_rx_bd(1, 1, 1'b1, (`MEMORY_BASE + 200 + num_of_rx_frames));
        set_rx_bd_wrap(1);
        set_rx_bd_empty(1, 1);
        // check frame
        fork
          begin
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 200, (rx_len + 4), 1'b0);
            repeat(10) @(posedge mrx_clk);
          end
          begin
            wait (MRxDV === 1'b1); // start receive
              // wait for WB master if it is working
              @(posedge wb_clk);
              #1;
              while (wbm_working)
              begin
                @(posedge wb_clk);
                #1;
              end
            check_rx_bd(1, data);
            if (data[15] !== 1)
            begin
              `TIME; $display("*E Rx Frame %0d: Wrong buffer descriptor's ready bit read out from MAC", num_of_rx_frames);
              test_fail("Wrong buffer descriptor's ready bit read out from MAC");
              fail = fail + 1;
            end
            wait (MRxDV === 1'b0); // end receive

            while (data[15] === 1)
            begin
                // wait for WB master if it is working
                @(posedge wb_clk);
                #1;
                while (wbm_working)
                begin
                  @(posedge wb_clk);
                  #1;
                end
              check_rx_bd(1, data);
            end
            repeat (1) @(posedge wb_clk);
          end
        join
        // check length of a PACKET

        // Additional read because simulator was not working OK.
        // wait for WB master if it is working
        @(posedge wb_clk);
        #1;
        while (wbm_working)
        begin
          @(posedge wb_clk);
          #1;
        end
        check_rx_bd(1, data);

        if (data[31:16] != (rx_len + 4))
        begin
          `TIME; $display("*E Rx Frame %0d: Wrong length of the packet written to MAC's register (%0d instead of %0d)", 
                          num_of_rx_frames, data[31:16], (rx_len + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(200, (`MEMORY_BASE + 200 + num_of_rx_frames), (rx_len + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Rx Frame %0d: Wrong data of the received packet", num_of_rx_frames);
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
         
           `TIME; $display("*E Rx Frame %0d: WB INT signal should not be set", num_of_rx_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        check_rx_bd(1, data);
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E Rx Frame %0d: RX buffer descriptor status is not correct: %0h", num_of_rx_frames, data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Rx Frame %0d: Interrupt Receive Buffer was not set, interrupt reg: %0h", 
                          num_of_rx_frames, data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~(`ETH_INT_RXB | `ETH_INT_TXB))) !== 0) // TXB might occur at the same time - not error
        begin
          `TIME; $display("*E Rx Frame %0d: Other interrupts (except Rx and Tx Buffer) were set, interrupt reg: %0h", 
                          num_of_rx_frames, data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts (except TXB)
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        wbm_write(`ETH_INT, (data & (~`ETH_INT_TXB)), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Rx Frame %0d: WB INT signal should not be set", num_of_rx_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // Displays
        if (num_of_rx_frames[2:0] == 3'b111)
        begin
          $display("   ->8 frames received");
        end
        // set length (loop variable)
        num_of_rx_frames = num_of_rx_frames + 1;
      end // RX frame loop
    join
    // disable TX & RX
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_PAD | `ETH_MODER_CRCEN | 
              `ETH_MODER_IFG | `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set DIFFERENT mrx_clk to mtx_clk!
//    eth_phy.set_mrx_equal_mtx = 1'b0;
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end

end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mac_full_duplex_flow_control



//////////////////////////////////////////////////////////////
// WB Behavioral Models Basic tasks
//////////////////////////////////////////////////////////////

task wbm_write;
  input  [31:0] address_i;
  input  [((`MAX_BLK_SIZE * 32) - 1):0] data_i;
  input  [3:0]  sel_i;
  input  [31:0] size_i;
  input  [3:0]  init_waits_i;
  input  [3:0]  subseq_waits_i;

  reg `WRITE_STIM_TYPE write_data;
  reg `WB_TRANSFER_FLAGS flags;
  reg `WRITE_RETURN_TYPE write_status;
  integer i;
begin
  wbm_working = 1;
  
  write_status = 0;

  flags                    = 0;
  flags`WB_TRANSFER_SIZE   = size_i;
  flags`INIT_WAITS         = init_waits_i;
  flags`SUBSEQ_WAITS       = subseq_waits_i;

  write_data               = 0;
  write_data`WRITE_DATA    = data_i[31:0];
  write_data`WRITE_ADDRESS = address_i;
  write_data`WRITE_SEL     = sel_i;

  for (i = 0; i < size_i; i = i + 1)
  begin
    wb_master.blk_write_data[i] = write_data;
    data_i                      = data_i >> 32;
    write_data`WRITE_DATA       = data_i[31:0];
    write_data`WRITE_ADDRESS    = write_data`WRITE_ADDRESS + 4;
  end

  wb_master.wb_block_write(flags, write_status);

  if (write_status`CYC_ACTUAL_TRANSFER !== size_i)
  begin
    `TIME;
    $display("*E WISHBONE Master was unable to complete the requested write operation to MAC!");
  end

  @(posedge wb_clk);
  #3;
  wbm_working = 0;
  #1;
end
endtask // wbm_write

task wbm_read;
  input  [31:0] address_i;
  output [((`MAX_BLK_SIZE * 32) - 1):0] data_o;
  input  [3:0]  sel_i;
  input  [31:0] size_i;
  input  [3:0]  init_waits_i;
  input  [3:0]  subseq_waits_i;

  reg `READ_RETURN_TYPE read_data;
  reg `WB_TRANSFER_FLAGS flags;
  reg `READ_RETURN_TYPE read_status;
  integer i;
begin
  wbm_working = 1;

  read_status = 0;
  data_o      = 0;

  flags                  = 0;
  flags`WB_TRANSFER_SIZE = size_i;
  flags`INIT_WAITS       = init_waits_i;
  flags`SUBSEQ_WAITS     = subseq_waits_i;

  read_data              = 0;
  read_data`READ_ADDRESS = address_i;
  read_data`READ_SEL     = sel_i;

  for (i = 0; i < size_i; i = i + 1)
  begin
    wb_master.blk_read_data_in[i] = read_data;
    read_data`READ_ADDRESS        = read_data`READ_ADDRESS + 4;
  end

  wb_master.wb_block_read(flags, read_status);

  if (read_status`CYC_ACTUAL_TRANSFER !== size_i)
  begin
    `TIME;
    $display("*E WISHBONE Master was unable to complete the requested read operation from MAC!");
  end

  for (i = 0; i < size_i; i = i + 1)
  begin
    data_o       = data_o << 32;
    read_data    = wb_master.blk_read_data_out[(size_i - 1) - i]; // [31 - i];
    data_o[31:0] = read_data`READ_DATA;
  end

  @(posedge wb_clk);
  #3;
  wbm_working = 0;
  #1;
end
endtask // wbm_read


//////////////////////////////////////////////////////////////
// Ethernet Basic tasks
//////////////////////////////////////////////////////////////

task hard_reset; //  MAC registers
begin
  // reset MAC registers
  @(posedge wb_clk);
  #2 wb_rst = 1'b1;
  repeat(2) @(posedge wb_clk);
  #2 wb_rst = 1'b0;
end
endtask // hard_reset

task set_tx_bd;
  input  [6:0]  tx_bd_num_start;
  input  [6:0]  tx_bd_num_end;
  input  [15:0] len;
  input         irq;
  input         pad;
  input         crc;
  input  [31:0] txpnt;

  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
//  integer       buf_addr;
begin
  for(i = tx_bd_num_start; i <= tx_bd_num_end; i = i + 1) 
  begin
//    buf_addr = `TX_BUF_BASE + i * 32'h600;
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    // initialize BD - status
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, {len, 1'b0, irq, 1'b0, pad, crc, 11'h0}, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits); // IRQ + PAD + CRC
    // initialize BD - pointer
    wait (wbm_working == 0);
    wbm_write(bd_ptr_addr, txpnt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Initializing BD-pointer
  end
end
endtask // set_tx_bd

task set_tx_bd_wrap;
  input  [6:0]  tx_bd_num_end;
  integer       bd_status_addr, tmp;
begin
  bd_status_addr = `TX_BD_BASE + tx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // set wrap bit to this BD - this BD should be last-one
  wait (wbm_working == 0);
  wbm_write(bd_status_addr, (`ETH_TX_BD_WRAP | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
end
endtask // set_tx_bd_wrap

task set_tx_bd_ready;
  input  [6:0]  tx_nd_num_strat;
  input  [6:0]  tx_bd_num_end;
  integer       i;
  integer       bd_status_addr, tmp;
begin
  for(i = tx_nd_num_strat; i <= tx_bd_num_end; i = i + 1)
  begin
    bd_status_addr = `TX_BD_BASE + i * 8;
    wait (wbm_working == 0);
    wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set empty bit to this BD - this BD should be ready
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, (`ETH_TX_BD_READY | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // set_tx_bd_ready

task check_tx_bd;
  input  [6:0]  tx_bd_num_end;
  output [31:0] tx_bd_status;
  integer       bd_status_addr, tmp;
begin
  bd_status_addr = `TX_BD_BASE + tx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  tx_bd_status = tmp;
end
endtask // check_tx_bd

task clear_tx_bd;
  input  [6:0]  tx_nd_num_strat;
  input  [6:0]  tx_bd_num_end;
  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
begin
  for(i = tx_nd_num_strat; i <= tx_bd_num_end; i = i + 1)
  begin
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    // clear BD - status
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // clear BD - pointer
    wait (wbm_working == 0);
    wbm_write(bd_ptr_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // clear_tx_bd

task set_rx_bd;
  input  [6:0]  rx_bd_num_strat;
  input  [6:0]  rx_bd_num_end;
  input         irq;
  input  [31:0] rxpnt;
//  input  [6:0]  rxbd_num;
  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
//  integer       buf_addr;
begin
  for(i = rx_bd_num_strat; i <= rx_bd_num_end; i = i + 1) 
  begin
//    buf_addr = `RX_BUF_BASE + i * 32'h600;
//    bd_status_addr = `RX_BD_BASE + i * 8;
//    bd_ptr_addr = bd_status_addr + 4; 
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    
    // initialize BD - status
    wait (wbm_working == 0);
//    wbm_write(bd_status_addr, 32'h0000c000, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // IRQ + PAD + CRC
    wbm_write(bd_status_addr, {17'h0, irq, 14'h0}, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // initialize BD - pointer
    wait (wbm_working == 0);
//    wbm_write(bd_ptr_addr, buf_addr, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Initializing BD-pointer
    wbm_write(bd_ptr_addr, rxpnt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Initializing BD-pointer
  end
end
endtask // set_rx_bd

task set_rx_bd_wrap;
  input  [6:0]  rx_bd_num_end;
  integer       bd_status_addr, tmp;
begin
//  bd_status_addr = `RX_BD_BASE + rx_bd_num_end * 8;
  bd_status_addr = `TX_BD_BASE + rx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // set wrap bit to this BD - this BD should be last-one
  wait (wbm_working == 0);
  wbm_write(bd_status_addr, (`ETH_RX_BD_WRAP | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
end
endtask // set_rx_bd_wrap

task set_rx_bd_empty;
  input  [6:0]  rx_bd_num_strat;
  input  [6:0]  rx_bd_num_end;
  integer       i;
  integer       bd_status_addr, tmp;
begin
  for(i = rx_bd_num_strat; i <= rx_bd_num_end; i = i + 1)
  begin
//    bd_status_addr = `RX_BD_BASE + i * 8;
    bd_status_addr = `TX_BD_BASE + i * 8;
    wait (wbm_working == 0);
    wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set empty bit to this BD - this BD should be ready
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, (`ETH_RX_BD_EMPTY | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // set_rx_bd_empty

task check_rx_bd;
  input  [6:0]  rx_bd_num_end;
  output [31:0] rx_bd_status;
  integer       bd_status_addr, tmp;
begin
//  bd_status_addr = `RX_BD_BASE + rx_bd_num_end * 8;
  bd_status_addr = `TX_BD_BASE + rx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  rx_bd_status = tmp;
end
endtask // check_rx_bd

task clear_rx_bd;
  input  [6:0]  rx_bd_num_strat;
  input  [6:0]  rx_bd_num_end;
  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
begin
  for(i = rx_bd_num_strat; i <= rx_bd_num_end; i = i + 1)
  begin
//    bd_status_addr = `RX_BD_BASE + i * 8;
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    // clear BD - status
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // clear BD - pointer
    wait (wbm_working == 0);
    wbm_write(bd_ptr_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // clear_rx_bd

task set_tx_packet;
  input  [31:0] txpnt;
  input  [15:0] len;
  input  [7:0]  eth_start_data;
  integer       i, sd;
  integer       buffer;
  reg           delta_t;
begin
  buffer = txpnt;
  sd = eth_start_data;
  delta_t = 0;

  // First write might not be word allign.
  if(buffer[1:0] == 1)  
  begin
    wb_slave.wr_mem(buffer - 1, {8'h0, sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2}, 4'h7);
    sd = sd + 3;
    i = 3;
  end
  else if(buffer[1:0] == 2)  
  begin
    wb_slave.wr_mem(buffer - 2, {16'h0, sd[7:0], sd[7:0] + 3'h1}, 4'h3);
    sd = sd + 2;
    i = 2;
  end      
  else if(buffer[1:0] == 3)
  begin
    wb_slave.wr_mem(buffer - 3, {24'h0, sd[7:0]}, 4'h1);
    sd = sd + 1;
    i = 1;
  end
  else
    i = 0;
  delta_t = !delta_t;

  for(i = i; i < (len - 4); i = i + 4) // Last 0-3 bytes are not written
  begin  
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2, sd[7:0] + 3'h3}, 4'hF);
    sd = sd + 4;
  end
  delta_t = !delta_t;
  
  // Last word
  if((len - i) == 3)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2, 8'h0}, 4'hE);
  end
  else if((len - i) == 2)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, 16'h0}, 4'hC);
  end
  else if((len - i) == 1)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], 24'h0}, 4'h8);
  end
  else if((len - i) == 4)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2, sd[7:0] + 3'h3}, 4'hF);
  end
  else
    $display("(%0t)(%m) ERROR", $time);
  delta_t = !delta_t;
end
endtask // set_tx_packet

task check_tx_packet;
  input  [31:0] txpnt_wb;  // source
  input  [31:0] txpnt_phy; // destination
  input  [15:0] len;
  output [31:0] failure;
  integer       i, data_wb, data_phy;
  reg    [31:0] addr_wb, addr_phy;
  reg    [31:0] failure;
  reg           delta_t;
begin
  addr_wb = txpnt_wb;
  addr_phy = txpnt_phy;
  delta_t = 0;
  failure = 0;
  #1;
  // First write might not be word allign.
  if(addr_wb[1:0] == 1)
  begin
    wb_slave.rd_mem(addr_wb - 1, data_wb, 4'h7);
    data_phy[31:24] = 0;
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0]];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + 1];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 2];
    i = 3;
    if (data_phy[23:0] !== data_wb[23:0])
    begin
      //`TIME;
      //$display("*E Wrong 1. word (3 bytes) of TX packet! phy: %0h, wb: %0h", data_phy[23:0], data_wb[23:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 2)
  begin
    wb_slave.rd_mem(addr_wb - 2, data_wb, 4'h3);
    data_phy[31:16] = 0;
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0]];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 1];
    i = 2;
    if (data_phy[15:0] !== data_wb[15:0])
    begin
      //`TIME;
      //$display("*E Wrong 1. word (2 bytes) of TX packet! phy: %0h, wb: %0h", data_phy[15:0], data_wb[15:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 3)
  begin
    wb_slave.rd_mem(addr_wb - 3, data_wb, 4'h1);
    data_phy[31: 8] = 0;
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0]];
    i = 1;
    if (data_phy[7:0] !== data_wb[7:0])
    begin
      //`TIME;
      //$display("*E Wrong 1. word (1 byte) of TX packet! phy: %0h, wb: %0h", data_phy[7:0], data_wb[7:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = 1;
    end
  end
  else
    i = 0;
  delta_t = !delta_t;
  #1;
  for(i = i; i < (len - 4); i = i + 4) // Last 0-3 bytes are not checked
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + i + 3];

    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (4 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;
  #1;
  // Last word
  if((len - i) == 3)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hE);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = 0;
    if (data_phy[31:8] !== data_wb[31:8])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (3 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:8], data_wb[31:8]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else if((len - i) == 2)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hC);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:16] !== data_wb[31:16])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (2 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:16], data_wb[31:16]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else if((len - i) == 1)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'h8);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = 0;
    data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:24] !== data_wb[31:24])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (1 byte) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:24], data_wb[31:24]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else if((len - i) == 4)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + i + 3];
    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (4 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else
    $display("(%0t)(%m) ERROR", $time);
  delta_t = !delta_t;
end
endtask // check_tx_packet

task set_rx_packet;
  input  [31:0] rxpnt;
  input  [15:0] len;
  input         plus_dribble_nibble; // if length is longer for one nibble
  input  [47:0] eth_dest_addr;
  input  [47:0] eth_source_addr;
  input  [15:0] eth_type_len;
  input  [7:0]  eth_start_data;
  integer       i, sd;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  buffer = rxpnt[21:0];
  dest_addr = eth_dest_addr;
  source_addr = eth_source_addr;
  type_len = eth_type_len;
  sd = eth_start_data;
  delta_t = 0;
  for(i = 0; i < len; i = i + 1) 
  begin
    if (i < 6)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 12)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else if (i < 14)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    else
    begin
      eth_phy.rx_mem[buffer] = sd[7:0];
      sd = sd + 1;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
  if (plus_dribble_nibble)
    eth_phy.rx_mem[buffer] = {4'h0, 4'hD /*sd[3:0]*/};
  delta_t = !delta_t;
end
endtask // set_rx_packet

task set_rx_packet_delayed;
  input  [31:0] rxpnt;
  input  [15:0] len;
  input         delayed_crc;
  input         plus_dribble_nibble; // if length is longer for one nibble
  input  [31:0] eth_data_preamble;
  input  [47:0] eth_dest_addr;
  input  [47:0] eth_source_addr;
  input  [15:0] eth_type_len;
  input  [7:0]  eth_start_data;
  integer       i, sd, start;
  reg    [16:0] tmp_len;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  buffer = rxpnt[21:0];
  dest_addr = eth_dest_addr;
  source_addr = eth_source_addr;
  type_len = eth_type_len;
  sd = eth_start_data;
  delta_t = 0;

  if (delayed_crc)
    begin
      tmp_len = len;
      start = 0;
    end
  else
    begin
      tmp_len = len+4;
      start = 4;
    end

  for(i = start; i < tmp_len; i = i + 1) 
  begin
    if (i < 4)
    begin
      eth_phy.rx_mem[buffer] = eth_data_preamble[31:24];
      eth_data_preamble = eth_data_preamble << 8;
    end
    else if (i < 10)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 16)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else if (i < 18)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    else
    begin
      eth_phy.rx_mem[buffer] = sd[7:0];
      sd = sd + 1;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
  if (plus_dribble_nibble)
    eth_phy.rx_mem[buffer] = {4'h0, 4'hD /*sd[3:0]*/};
  delta_t = !delta_t;
end
endtask // set_rx_packet_delayed

task set_rx_control_packet;
  input  [31:0] rxpnt;
  input  [15:0] PauseTV;
  integer       i;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
  reg    [15:0] PTV;
  reg    [15:0] opcode;
begin
  buffer = rxpnt[21:0];
  dest_addr = 48'h0180_c200_0001;
  source_addr = 48'h0708_090A_0B0C;
  type_len = 16'h8808;
  opcode = 16'h0001;
  PTV = PauseTV;
  delta_t = 0;
  for(i = 0; i < 60; i = i + 1) 
  begin
    if (i < 6)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 12)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else if (i < 14)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    else if (i < 16)
    begin
      eth_phy.rx_mem[buffer] = opcode[15:8];
      opcode = opcode << 8;
    end
    else if (i < 18)
    begin
      eth_phy.rx_mem[buffer] = PTV[15:8];
      PTV = PTV << 8;
    end
    else
    begin
      eth_phy.rx_mem[buffer] = 0;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
  append_rx_crc (rxpnt, 60, 1'b0, 1'b0); // CRC for control packet
end
endtask // set_rx_control_packet

task set_rx_addr_type;
  input  [31:0] rxpnt;
  input  [47:0] eth_dest_addr;
  input  [47:0] eth_source_addr;
  input  [15:0] eth_type_len;
  integer       i;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  buffer = rxpnt[21:0];
  dest_addr = eth_dest_addr;
  source_addr = eth_source_addr;
  type_len = eth_type_len;
  delta_t = 0;
  for(i = 0; i < 14; i = i + 1) 
  begin
    if (i < 6)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 12)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else // if (i < 14)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
end
endtask // set_rx_addr_type

task check_rx_packet;
  input  [31:0] rxpnt_phy; // source
  input  [31:0] rxpnt_wb;  // destination
  input  [15:0] len;
  input         plus_dribble_nibble; // if length is longer for one nibble
  input         successful_dribble_nibble; // if additional nibble is stored into memory
  output [31:0] failure;
  integer       i, data_wb, data_phy;
  reg    [31:0] addr_wb, addr_phy;
  reg    [31:0] failure;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  addr_phy = rxpnt_phy;
  addr_wb = rxpnt_wb;
  delta_t = 0;
  failure = 0;

  // First write might not be word allign.
  if(addr_wb[1:0] == 1)
  begin
    wb_slave.rd_mem(addr_wb[21:0] - 1, data_wb, 4'h7);
    data_phy[31:24] = 0;
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0]];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + 1];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + 2];
    i = 3;
    if (data_phy[23:0] !== data_wb[23:0])
    begin
      //`TIME;
      //$display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong 1. word (3 bytes) of RX packet! phy = %h, wb = %h", data_phy[23:0], data_wb[23:0]);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 2)
  begin
    wb_slave.rd_mem(addr_wb[21:0] - 2, data_wb, 4'h3);
    data_phy[31:16] = 0;
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0]];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + 1];
    i = 2;
    if (data_phy[15:0] !== data_wb[15:0])
    begin
      //`TIME;
      //$display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong 1. word (2 bytes) of RX packet! phy = %h, wb = %h", data_phy[15:0], data_wb[15:0]);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 3)
  begin
    wb_slave.rd_mem(addr_wb[21:0] - 3, data_wb, 4'h1);
    data_phy[31: 8] = 0;
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0]];
    i = 1;
    if (data_phy[7:0] !== data_wb[7:0])
    begin
      //`TIME;
      //$display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong 1. word (1 byte) of RX packet! phy = %h, wb = %h", data_phy[7:0], data_wb[7:0]);
      failure = 1;
    end
  end
  else
    i = 0;
  delta_t = !delta_t;

  for(i = i; i < (len - 4); i = i + 4) // Last 0-3 bytes are not checked
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + i + 3];
    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //if (i == 0)
      //  $display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong %0d. word (4 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;

  // Last word
  if((len - i) == 3)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    if (plus_dribble_nibble)
      data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + i + 3];
    else
      data_phy[ 7: 0] = 0;
    if (data_phy[31:8] !== data_wb[31:8])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (3 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:8], data_wb[31:8]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble && successful_dribble_nibble)
    begin
      if (data_phy[3:0] !== data_wb[3:0])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (3 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
    else if (plus_dribble_nibble && !successful_dribble_nibble)
    begin
      if (data_phy[3:0] === data_wb[3:0])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (3 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
  end
  else if((len - i) == 2)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hE);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    if (plus_dribble_nibble)
      data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    else
      data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:16] !== data_wb[31:16])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (2 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:16], data_wb[31:16]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble && successful_dribble_nibble)
    begin
      if (data_phy[11:8] !== data_wb[11:8])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (2 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
    else if (plus_dribble_nibble && !successful_dribble_nibble)
    begin
      if (data_phy[11:8] === data_wb[11:8])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (2 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
  end
  else if((len - i) == 1)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hC);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    if (plus_dribble_nibble)
      data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    else
      data_phy[23:16] = 0;
    data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:24] !== data_wb[31:24])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (1 byte) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:24], data_wb[31:24]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble && successful_dribble_nibble)
    begin
      if (data_phy[19:16] !== data_wb[19:16])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (1 byte) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
    else if (plus_dribble_nibble && !successful_dribble_nibble)
    begin
      if (data_phy[19:16] === data_wb[19:16])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (1 byte) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
  end
  else if((len - i) == 4)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + i + 3];
    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (4 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble)
    begin
      wb_slave.rd_mem(addr_wb[21:0] + i + 4, data_wb, 4'h8);
      data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i + 4];
      if (successful_dribble_nibble)
      begin
        if (data_phy[27:24] !== data_wb[27:24])
        begin
          //`TIME;
          //$display("*E Wrong dribble nibble in %0d. word (0 bytes) of RX packet!", ((i/4)+2));
          failure = failure + 1;
        end
      end
      else
      begin
        if (data_phy[27:24] === data_wb[27:24])
        begin
          //`TIME;
          //$display("*E Wrong dribble nibble in %0d. word (0 bytes) of RX packet!", ((i/4)+2));
          failure = failure + 1;
        end
      end
    end
  end
  else
    $display("(%0t)(%m) ERROR", $time);
  delta_t = !delta_t;
end
endtask // check_rx_packet

//////////////////////////////////////////////////////////////
// Ethernet CRC Basic tasks
//////////////////////////////////////////////////////////////

task append_tx_crc;
  input  [31:0] txpnt_wb;  // source
  input  [15:0] len; // length in bytes without CRC
  input         negated_crc; // if appended CRC is correct or not
  reg    [31:0] crc;
  reg    [31:0] addr_wb;
  reg           delta_t;
begin
  addr_wb = txpnt_wb + {16'h0, len};
  delta_t = 0;
  // calculate CRC from prepared packet
  paralel_crc_mac(txpnt_wb, {16'h0, len}, 1'b0, crc);
  if (negated_crc)
    crc = ~crc;
  delta_t = !delta_t;

  // Write might not be word allign.
  if (addr_wb[1:0] == 1)
  begin
    wb_slave.wr_mem(addr_wb - 1, {8'h0, crc[7:0], crc[15:8], crc[23:16]}, 4'h7);
    wb_slave.wr_mem(addr_wb + 3, {crc[31:24], 24'h0}, 4'h8);
  end
  else if (addr_wb[1:0] == 2)
  begin
    wb_slave.wr_mem(addr_wb - 2, {16'h0, crc[7:0], crc[15:8]}, 4'h3);
    wb_slave.wr_mem(addr_wb + 2, {crc[23:16], crc[31:24], 16'h0}, 4'hC);
  end
  else if (addr_wb[1:0] == 3)
  begin
    wb_slave.wr_mem(addr_wb - 3, {24'h0, crc[7:0]}, 4'h1);
    wb_slave.wr_mem(addr_wb + 1, {crc[15:8], crc[23:16], crc[31:24], 8'h0}, 4'hE);
  end
  else
  begin
//    wb_slave.wr_mem(addr_wb, {crc[7:0], crc[15:8], crc[23:16], crc[31:24]}, 4'hF);
    wb_slave.wr_mem(addr_wb, crc[31:0], 4'hF);
  end
  delta_t = !delta_t;
end
endtask // append_tx_crc

task check_tx_crc; // used to check crc added to TX packets by MAC
  input  [31:0] txpnt_phy; // destination
  input  [15:0] len; // length in bytes without CRC
  input         negated_crc; // if appended CRC is correct or not
  output [31:0] failure;
  reg    [31:0] failure;
  reg    [31:0] crc_calc;
  reg    [31:0] crc;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = txpnt_phy;
  failure = 0;
  // calculate CRC from sent packet
//  serial_crc_phy_tx(addr_phy, {16'h0, len}, 1'b0, crc_calc);
//#10;
  paralel_crc_phy_tx(addr_phy, {16'h0, len}, 1'b0, crc_calc);
  #1;
  addr_phy = addr_phy + len;
  // Read CRC - BIG endian
  crc[31:24] = eth_phy.tx_mem[addr_phy[21:0]];
  crc[23:16] = eth_phy.tx_mem[addr_phy[21:0] + 1];
  crc[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + 2];
  crc[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 3];

  delta_t = !delta_t;
  if (negated_crc)
  begin
    if ((~crc_calc) !== crc)
    begin
      `TIME;
      $display("*E Negated CRC was not successfuly transmitted!");
      failure = failure + 1;
    end
  end
  else
  begin
    if (crc_calc !== crc)
    begin
      `TIME;
      $display("*E Transmitted CRC was not correct; crc_calc: %0h, crc_mem: %0h", crc_calc, crc);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;
end
endtask // check_tx_crc

task check_tx_crc_delayed; // used to check crc added to TX packets by MAC
  input  [31:0] txpnt_phy; // destination
  input  [15:0] len; // length in bytes without CRC
  input         negated_crc; // if appended CRC is correct or not
  output [31:0] failure;
  reg    [31:0] failure;
  reg    [31:0] crc_calc;
  reg    [31:0] crc;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = txpnt_phy;
  failure = 0;
  // calculate CRC from sent packet
//  serial_crc_phy_tx(addr_phy, {16'h0, len}, 1'b0, crc_calc);
//#10;
  paralel_crc_phy_tx(addr_phy+4, {16'h0, len}-4, 1'b0, crc_calc);
  #1;
  addr_phy = addr_phy + len;
  // Read CRC - BIG endian
  crc[31:24] = eth_phy.tx_mem[addr_phy[21:0]];
  crc[23:16] = eth_phy.tx_mem[addr_phy[21:0] + 1];
  crc[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + 2];
  crc[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 3];

  delta_t = !delta_t;
  if (negated_crc)
  begin
    if ((~crc_calc) !== crc)
    begin
      `TIME;
      $display("*E Negated CRC was not successfuly transmitted!");
      failure = failure + 1;
    end
  end
  else
  begin
    if (crc_calc !== crc)
    begin
      `TIME;
      $display("*E Transmitted CRC was not correct; crc_calc: %0h, crc_mem: %0h", crc_calc, crc);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;
end
endtask // check_tx_crc_delayed

task set_rx_packet_delayed_L3;
  input  [31:0] rxpnt;
  input  [15:0] len;
  input         delayed_crc;
  input         plus_dribble_nibble; // if length is longer for one nibble
  input  [31:0] eth_data_preamble;
  input  [47:0] eth_dest_addr;
  input  [47:0] eth_source_addr;
  input  [15:0] eth_type_len;
  input  [7:0]  eth_start_data;
  integer       i, sd, start ;
  reg    [16:0] tmp_len;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [3:0]  vlan;
  reg    [3:0]  prio;
  reg    [15:0] ethertype;
  reg    [3:0]  ipv4_version;
  reg    [3:0]  ipv4_HLEN;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
  reg    [15:0] tot_len;
  reg    [7:0] ttl;
  reg    [7:0] protocol;
  reg    [15:0] Header_CheckSum;
  reg    [31:0] Source_IP;
  reg    [31:0] Dest_IP;
  reg    [31:0] identification;
begin
  buffer = rxpnt[21:0];
  dest_addr = eth_dest_addr;
  source_addr = eth_source_addr;
  type_len = eth_type_len;
  sd = eth_start_data;
  tot_len = 16'h21c; // len + 20;
  delta_t = 0;
  vlan=4'h1;
  prio = 4'h0;
  ethertype = 16'h800;
  ipv4_version = 4'h4;
  ipv4_HLEN = 4'h5;
  ttl = 8'hff;
  identification = 32'h3;
  protocol = 8'h11;
  Header_CheckSum = 16'heda8;
  Source_IP = 32'he8f9d0bf;
  Dest_IP = 32'hc1a850c1;
  if (delayed_crc)
    begin
      tmp_len = len;
      start = 0;
    end
  else
    begin
      tmp_len = len+4;
      start = 4;
    end

  for(i = start; i < tmp_len; i = i + 1)
  begin
    if (i < 4)
    begin
      eth_phy.rx_mem[buffer] = eth_data_preamble[31:24];
      eth_data_preamble = eth_data_preamble << 8;
    end
    else if (i < 10)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 16)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else if (i < 18)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    else if (i < 19)
    begin
      eth_phy.rx_mem[buffer] = {prio,vlan};          // 0x01
    end
    else if (i < 21)
      begin
          eth_phy.rx_mem[buffer] = ethertype[15:8] ;   //  0x800
          ethertype = ethertype << 8;
      end
    else if (i < 22)
      begin
          eth_phy.rx_mem[buffer] = {ipv4_version,ipv4_HLEN};  // Version = 4 (ipv4) +HLEN = 5
      end
     else if (i < 23)
         begin
            eth_phy.rx_mem[buffer] = 8'h2; //TOS
         end
         else if (i < 25)
         begin
           eth_phy.rx_mem[buffer] = tot_len[15:8];     // ipv4+payload    length
            tot_len = tot_len << 8;
         end
          else if (i < 29)
         begin
           eth_phy.rx_mem[buffer] = identification[31:24];        //identification+flag+fragment
           identification = identification << 8;
         end
          else if (i < 30)
         begin
           eth_phy.rx_mem[buffer] = ttl[7:0];
         end
         else if (i < 31)
         begin
           eth_phy.rx_mem[buffer] = protocol[7:0];        //11 - udp
         end
          else if (i < 33)
         begin
           eth_phy.rx_mem[buffer] = Header_CheckSum[15:8];
           Header_CheckSum = Header_CheckSum << 8;
         end
          else if (i < 37)
         begin
           eth_phy.rx_mem[buffer] = Source_IP[31:24];
           Source_IP = Source_IP << 8;
         end
         else if (i < 41)
         begin
           eth_phy.rx_mem[buffer] = Dest_IP[31:24];
           Dest_IP = Dest_IP << 8;
         end

    else
    begin
      eth_phy.rx_mem[buffer] = sd[7:0];
      sd = sd + 1;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
  if (plus_dribble_nibble)
    eth_phy.rx_mem[buffer] = {4'h0, 4'hD /*sd[3:0]*/};
  delta_t = !delta_t;
end
endtask // set_rx_packet_delayed_L3


task append_rx_crc;
  input  [31:0] rxpnt_phy; // source
  input  [15:0] len; // length in bytes without CRC
  input         plus_dribble_nibble; // if length is longer for one nibble
  input         negated_crc; // if appended CRC is correct or not
  reg    [31:0] crc;
  reg    [7:0]  tmp;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = rxpnt_phy + len;
  delta_t = 0;
  // calculate CRC from prepared packet
  paralel_crc_phy_rx(rxpnt_phy, {16'h0, len}, plus_dribble_nibble, crc);
  if (negated_crc)
    crc = ~crc;
  delta_t = !delta_t;

  if (plus_dribble_nibble)
  begin
    tmp = eth_phy.rx_mem[addr_phy];
    eth_phy.rx_mem[addr_phy]     = {crc[27:24], tmp[3:0]};
    eth_phy.rx_mem[addr_phy + 1] = {crc[19:16], crc[31:28]};
    eth_phy.rx_mem[addr_phy + 2] = {crc[11:8], crc[23:20]};
    eth_phy.rx_mem[addr_phy + 3] = {crc[3:0], crc[15:12]};
    eth_phy.rx_mem[addr_phy + 4] = {4'h0, crc[7:4]};
  end
  else
  begin
    eth_phy.rx_mem[addr_phy]     = crc[31:24];
    eth_phy.rx_mem[addr_phy + 1] = crc[23:16];
    eth_phy.rx_mem[addr_phy + 2] = crc[15:8];
    eth_phy.rx_mem[addr_phy + 3] = crc[7:0];
  end
end
endtask // append_rx_crc

task append_rx_crc_delayed;
  input  [31:0] rxpnt_phy; // source
  input  [15:0] len; // length in bytes without CRC
  input         plus_dribble_nibble; // if length is longer for one nibble
  input         negated_crc; // if appended CRC is correct or not
  reg    [31:0] crc;
  reg    [7:0]  tmp;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = rxpnt_phy + len;
  delta_t = 0;
  // calculate CRC from prepared packet
  paralel_crc_phy_rx(rxpnt_phy+4, {16'h0, len}-4, plus_dribble_nibble, crc);
  if (negated_crc)
    crc = ~crc;
  delta_t = !delta_t;

  if (plus_dribble_nibble)
  begin
    tmp = eth_phy.rx_mem[addr_phy];
    eth_phy.rx_mem[addr_phy]     = {crc[27:24], tmp[3:0]};
    eth_phy.rx_mem[addr_phy + 1] = {crc[19:16], crc[31:28]};
    eth_phy.rx_mem[addr_phy + 2] = {crc[11:8], crc[23:20]};
    eth_phy.rx_mem[addr_phy + 3] = {crc[3:0], crc[15:12]};
    eth_phy.rx_mem[addr_phy + 4] = {4'h0, crc[7:4]};
  end
  else
  begin
    eth_phy.rx_mem[addr_phy]     = crc[31:24];
    eth_phy.rx_mem[addr_phy + 1] = crc[23:16];
    eth_phy.rx_mem[addr_phy + 2] = crc[15:8];
    eth_phy.rx_mem[addr_phy + 3] = crc[7:0];
  end
end
endtask // append_rx_crc_delayed

// paralel CRC checking for PHY TX
task paralel_crc_phy_tx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc_out;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       nibble_cnt;
  reg    [31:0] load_reg;
  reg           delta_t;
  reg    [31:0] crc_next;
  reg    [31:0] crc;
  reg           crc_error;
  reg     [3:0] data_in;
  integer       i;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // 27; // start of the frame - nibble granularity (MSbit first)
  crc = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of nibbles from Byte length (2^1 = 2)
  if (plus_dribble_nibble)
    nibble_cnt = ((len + 4) << 1) + 1'b1; // one nibble longer
  else
    nibble_cnt = ((len + 4) << 1);
  // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
  load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  while (nibble_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // shift data in

    if(nibble_cnt <= 8) // for additional 8 nibbles shift ZEROs in!
      data_in[3:0] = 4'h0;
    else

      data_in[3:0] = {load_reg[word_cnt], load_reg[word_cnt+1], load_reg[word_cnt+2], load_reg[word_cnt+3]};
    crc_next[0]  = (data_in[0] ^ crc[28]);
    crc_next[1]  = (data_in[1] ^ data_in[0] ^ crc[28]    ^ crc[29]);
    crc_next[2]  = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]);
    crc_next[3]  = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]);
    crc_next[4]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[0];
    crc_next[5]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[1];
    crc_next[6]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[ 2];
    crc_next[7]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[3];
    crc_next[8]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[4];
    crc_next[9]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[5];
    crc_next[10] = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[6];
    crc_next[11] = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[7];
    crc_next[12] = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]) ^ crc[8];
    crc_next[13] = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]) ^ crc[9];
    crc_next[14] = (data_in[3] ^ data_in[2] ^ crc[30]    ^ crc[31]) ^ crc[10];
    crc_next[15] = (data_in[3] ^ crc[31])   ^ crc[11];
    crc_next[16] = (data_in[0] ^ crc[28])   ^ crc[12];
    crc_next[17] = (data_in[1] ^ crc[29])   ^ crc[13];
    crc_next[18] = (data_in[2] ^ crc[30])   ^ crc[14];
    crc_next[19] = (data_in[3] ^ crc[31])   ^ crc[15];
    crc_next[20] =  crc[16];
    crc_next[21] =  crc[17];
    crc_next[22] = (data_in[0] ^ crc[28])   ^ crc[18];
    crc_next[23] = (data_in[1] ^ data_in[0] ^ crc[29]    ^ crc[28]) ^ crc[19];
    crc_next[24] = (data_in[2] ^ data_in[1] ^ crc[30]    ^ crc[29]) ^ crc[20];
    crc_next[25] = (data_in[3] ^ data_in[2] ^ crc[31]    ^ crc[30]) ^ crc[21];
    crc_next[26] = (data_in[3] ^ data_in[0] ^ crc[31]    ^ crc[28]) ^ crc[22];
    crc_next[27] = (data_in[1] ^ crc[29])   ^ crc[23];
    crc_next[28] = (data_in[2] ^ crc[30])   ^ crc[24];
    crc_next[29] = (data_in[3] ^ crc[31])   ^ crc[25];
    crc_next[30] =  crc[26];
    crc_next[31] =  crc[27];

    crc = crc_next;
    crc_error = crc[31:0] != 32'hc704dd7b;  // CRC not equal to magic number
    case (nibble_cnt)
    9: crc_out = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
                  !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
                  !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
                  !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    default: crc_out = crc_out;
    endcase
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if ((word_cnt+3) == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
    end
    // set new load bit position
    if((word_cnt+3) == 31)
      word_cnt = 16;
    else if ((word_cnt+3) == 23)
      word_cnt = 8;
    else if ((word_cnt+3) == 15)
      word_cnt = 0;
    else if ((word_cnt+3) == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 4;// - 4;
    // decrement nibble counter
    nibble_cnt = nibble_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while
  #1;
end
endtask // paralel_crc_phy_tx

// paralel CRC calculating for PHY RX
task paralel_crc_phy_rx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc_out;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       nibble_cnt;
  reg    [31:0] load_reg;
  reg           delta_t;
  reg    [31:0] crc_next;
  reg    [31:0] crc;
  reg           crc_error;
  reg     [3:0] data_in;
  integer       i;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // 27; // start of the frame - nibble granularity (MSbit first)
  crc = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of nibbles from Byte length (2^1 = 2)
  if (plus_dribble_nibble)
    nibble_cnt = ((len + 4) << 1) + 1'b1; // one nibble longer
  else
    nibble_cnt = ((len + 4) << 1);
  // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
  load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15: 8] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[ 7: 0] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  while (nibble_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // shift data in

    if(nibble_cnt <= 8) // for additional 8 nibbles shift ZEROs in!
      data_in[3:0] = 4'h0;
    else

      data_in[3:0] = {load_reg[word_cnt], load_reg[word_cnt+1], load_reg[word_cnt+2], load_reg[word_cnt+3]};
    crc_next[0]  = (data_in[0] ^ crc[28]);
    crc_next[1]  = (data_in[1] ^ data_in[0] ^ crc[28]    ^ crc[29]);
    crc_next[2]  = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]);
    crc_next[3]  = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]);
    crc_next[4]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[0];
    crc_next[5]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[1];
    crc_next[6]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[ 2];
    crc_next[7]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[3];
    crc_next[8]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[4];
    crc_next[9]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[5];
    crc_next[10] = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[6];
    crc_next[11] = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[7];
    crc_next[12] = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]) ^ crc[8];
    crc_next[13] = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]) ^ crc[9];
    crc_next[14] = (data_in[3] ^ data_in[2] ^ crc[30]    ^ crc[31]) ^ crc[10];
    crc_next[15] = (data_in[3] ^ crc[31])   ^ crc[11];
    crc_next[16] = (data_in[0] ^ crc[28])   ^ crc[12];
    crc_next[17] = (data_in[1] ^ crc[29])   ^ crc[13];
    crc_next[18] = (data_in[2] ^ crc[30])   ^ crc[14];
    crc_next[19] = (data_in[3] ^ crc[31])   ^ crc[15];
    crc_next[20] =  crc[16];
    crc_next[21] =  crc[17];
    crc_next[22] = (data_in[0] ^ crc[28])   ^ crc[18];
    crc_next[23] = (data_in[1] ^ data_in[0] ^ crc[29]    ^ crc[28]) ^ crc[19];
    crc_next[24] = (data_in[2] ^ data_in[1] ^ crc[30]    ^ crc[29]) ^ crc[20];
    crc_next[25] = (data_in[3] ^ data_in[2] ^ crc[31]    ^ crc[30]) ^ crc[21];
    crc_next[26] = (data_in[3] ^ data_in[0] ^ crc[31]    ^ crc[28]) ^ crc[22];
    crc_next[27] = (data_in[1] ^ crc[29])   ^ crc[23];
    crc_next[28] = (data_in[2] ^ crc[30])   ^ crc[24];
    crc_next[29] = (data_in[3] ^ crc[31])   ^ crc[25];
    crc_next[30] =  crc[26];
    crc_next[31] =  crc[27];

    crc = crc_next;
    crc_error = crc[31:0] != 32'hc704dd7b;  // CRC not equal to magic number
    case (nibble_cnt)
    9: crc_out = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
                  !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
                  !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
                  !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    default: crc_out = crc_out;
    endcase
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if ((word_cnt+3) == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[15: 8] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[ 7: 0] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
    end
    // set new load bit position
    if((word_cnt+3) == 31)
      word_cnt = 16;
    else if ((word_cnt+3) == 23)
      word_cnt = 8;
    else if ((word_cnt+3) == 15)
      word_cnt = 0;
    else if ((word_cnt+3) == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 4;// - 4;
    // decrement nibble counter
    nibble_cnt = nibble_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while
  #1;
end
endtask // paralel_crc_phy_rx

// paralel CRC checking for MAC
task paralel_crc_mac;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc_out;

  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       nibble_cnt;
  reg    [31:0] load_reg;
  reg           delta_t;
  reg    [31:0] crc_next;
  reg    [31:0] crc;
  reg           crc_error;
  reg     [3:0] data_in;
  integer       i;
begin
  #1 addr_cnt = start_addr[19:0];
  // set starting point depending with which byte frame starts (e.g. if addr_cnt[1:0] == 0, then
  //   MSB of the packet must be written to the LSB of Big ENDIAN Word [31:24])
  if (addr_cnt[1:0] == 2'h1)
    word_cnt = 16; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h2)
    word_cnt = 8; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h3)
    word_cnt = 0; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else 
    word_cnt = 24; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  crc = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of nibbles from Byte length (2^1 = 2)
  if (plus_dribble_nibble)
    nibble_cnt = ((len + 4) << 1) + 1'b1; // one nibble longer
  else
    nibble_cnt = ((len + 4) << 1);
  load_reg = wb_slave.wb_memory[{12'h0, addr_cnt[21:2]}];
  addr_cnt = addr_cnt + 4;
  while (nibble_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // shift data in

    if(nibble_cnt <= 8) // for additional 8 nibbles shift ZEROs in!
      data_in[3:0] = 4'h0;
    else

      data_in[3:0] = {load_reg[word_cnt], load_reg[word_cnt+1], load_reg[word_cnt+2], load_reg[word_cnt+3]};
    crc_next[0]  = (data_in[0] ^ crc[28]);
    crc_next[1]  = (data_in[1] ^ data_in[0] ^ crc[28]    ^ crc[29]);
    crc_next[2]  = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]);
    crc_next[3]  = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]);
    crc_next[4]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[0];
    crc_next[5]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[1];
    crc_next[6]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[ 2];
    crc_next[7]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[3];
    crc_next[8]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[4];
    crc_next[9]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[5];
    crc_next[10] = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[6];
    crc_next[11] = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[7];
    crc_next[12] = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]) ^ crc[8];
    crc_next[13] = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]) ^ crc[9];
    crc_next[14] = (data_in[3] ^ data_in[2] ^ crc[30]    ^ crc[31]) ^ crc[10];
    crc_next[15] = (data_in[3] ^ crc[31])   ^ crc[11];
    crc_next[16] = (data_in[0] ^ crc[28])   ^ crc[12];
    crc_next[17] = (data_in[1] ^ crc[29])   ^ crc[13];
    crc_next[18] = (data_in[2] ^ crc[30])   ^ crc[14];
    crc_next[19] = (data_in[3] ^ crc[31])   ^ crc[15];
    crc_next[20] =  crc[16];
    crc_next[21] =  crc[17];
    crc_next[22] = (data_in[0] ^ crc[28])   ^ crc[18];
    crc_next[23] = (data_in[1] ^ data_in[0] ^ crc[29]    ^ crc[28]) ^ crc[19];
    crc_next[24] = (data_in[2] ^ data_in[1] ^ crc[30]    ^ crc[29]) ^ crc[20];
    crc_next[25] = (data_in[3] ^ data_in[2] ^ crc[31]    ^ crc[30]) ^ crc[21];
    crc_next[26] = (data_in[3] ^ data_in[0] ^ crc[31]    ^ crc[28]) ^ crc[22];
    crc_next[27] = (data_in[1] ^ crc[29])   ^ crc[23];
    crc_next[28] = (data_in[2] ^ crc[30])   ^ crc[24];
    crc_next[29] = (data_in[3] ^ crc[31])   ^ crc[25];
    crc_next[30] =  crc[26];
    crc_next[31] =  crc[27];

    crc = crc_next;
    crc_error = crc[31:0] != 32'hc704dd7b;  // CRC not equal to magic number
    case (nibble_cnt)
    9: crc_out = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
                  !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
                  !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
                  !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    default: crc_out = crc_out;
    endcase
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if ((word_cnt+3) == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg = wb_slave.wb_memory[{12'h0, addr_cnt[21:2]}];
      addr_cnt = addr_cnt + 4;
    end
    // set new load bit position
    if((word_cnt+3) == 31)
      word_cnt = 16;
    else if ((word_cnt+3) == 23)
      word_cnt = 8;
    else if ((word_cnt+3) == 15)
      word_cnt = 0;
    else if ((word_cnt+3) == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 4;// - 4;
    // decrement nibble counter
    nibble_cnt = nibble_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while
  #1;
end
endtask // paralel_crc_mac

// serial CRC checking for PHY TX
task serial_crc_phy_tx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       bit_cnt;
  reg    [31:0] load_reg;
  reg    [31:0] crc_shift_reg;
  reg    [31:0] crc_store_reg;
  reg           delta_t;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // 27; // start of the frame - nibble granularity (MSbit first)
  crc_store_reg = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of bits from Byte length (2^3 = 8)
  if (plus_dribble_nibble)
    bit_cnt = ((len + 4) << 3) + 3'h4; // one nibble longer
  else
    bit_cnt = ((len + 4) << 3);
  // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
  load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
#1;
  while (bit_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
#1;
    // shift data in

    if(bit_cnt <= 32) // for additional 32 bits shift ZEROs in!
     crc_shift_reg[0] = 1'b0               ^ crc_store_reg[31];
    else

     crc_shift_reg[0] = load_reg[word_cnt] ^ crc_store_reg[31];
    crc_shift_reg[1]  = crc_store_reg[0]   ^ crc_store_reg[31];
    crc_shift_reg[2]  = crc_store_reg[1]   ^ crc_store_reg[31];
    crc_shift_reg[3]  = crc_store_reg[2];
    crc_shift_reg[4]  = crc_store_reg[3]   ^ crc_store_reg[31];
    crc_shift_reg[5]  = crc_store_reg[4]   ^ crc_store_reg[31];
    crc_shift_reg[6]  = crc_store_reg[5];
    crc_shift_reg[7]  = crc_store_reg[6]   ^ crc_store_reg[31];
    crc_shift_reg[8]  = crc_store_reg[7]   ^ crc_store_reg[31];
    crc_shift_reg[9]  = crc_store_reg[8];
    crc_shift_reg[10] = crc_store_reg[9]   ^ crc_store_reg[31];
    crc_shift_reg[11] = crc_store_reg[10]  ^ crc_store_reg[31];
    crc_shift_reg[12] = crc_store_reg[11]  ^ crc_store_reg[31];
    crc_shift_reg[13] = crc_store_reg[12];
    crc_shift_reg[14] = crc_store_reg[13];
    crc_shift_reg[15] = crc_store_reg[14];
    crc_shift_reg[16] = crc_store_reg[15]  ^ crc_store_reg[31];
    crc_shift_reg[17] = crc_store_reg[16];
    crc_shift_reg[18] = crc_store_reg[17];
    crc_shift_reg[19] = crc_store_reg[18];
    crc_shift_reg[20] = crc_store_reg[19];
    crc_shift_reg[21] = crc_store_reg[20];
    crc_shift_reg[22] = crc_store_reg[21]  ^ crc_store_reg[31];
    crc_shift_reg[23] = crc_store_reg[22]  ^ crc_store_reg[31];
    crc_shift_reg[24] = crc_store_reg[23];
    crc_shift_reg[25] = crc_store_reg[24];
    crc_shift_reg[26] = crc_store_reg[25]  ^ crc_store_reg[31];
    crc_shift_reg[27] = crc_store_reg[26];
    crc_shift_reg[28] = crc_store_reg[27];
    crc_shift_reg[29] = crc_store_reg[28];
    crc_shift_reg[30] = crc_store_reg[29];
    crc_shift_reg[31] = crc_store_reg[30];
    // wait for delta time
    delta_t = !delta_t;

    // store previous data
    crc_store_reg = crc_shift_reg;

    // put CRC out
    case (bit_cnt)
    33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 1:
    begin
      crc = crc_store_reg;
      crc = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
             !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
             !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
             !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    end
    default: crc = crc;
    endcase

    // increment address and load new data
#1;
    if (word_cnt == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
//      load_reg[31:24] = {load_reg[28], load_reg[29], load_reg[30], load_reg[31], 
//                         load_reg[24], load_reg[25], load_reg[26], load_reg[27]};
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
//      load_reg[23:16] = {load_reg[20], load_reg[21], load_reg[22], load_reg[23], 
//                         load_reg[16], load_reg[17], load_reg[18], load_reg[19]};
      addr_cnt = addr_cnt + 1;
      load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
//      load_reg[15: 8] = {load_reg[12], load_reg[13], load_reg[14], load_reg[15], 
//                         load_reg[ 8], load_reg[ 9], load_reg[10], load_reg[11]};
      addr_cnt = addr_cnt + 1;
      load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
//      load_reg[ 7: 0] = {load_reg[ 4], load_reg[ 5], load_reg[ 6], load_reg[ 7], 
//                         load_reg[ 0], load_reg[ 1], load_reg[ 2], load_reg[ 3]};
      addr_cnt = addr_cnt + 1;
    end
#1;
    // set new load bit position
    if(word_cnt == 31)
      word_cnt = 16;
    else if (word_cnt == 23)
      word_cnt = 8;
    else if (word_cnt == 15)
      word_cnt = 0;
    else if (word_cnt == 7)
      word_cnt = 24;

//   if(word_cnt == 24)
//     word_cnt = 31;
//   else if (word_cnt == 28)
//     word_cnt = 19;
//   else if (word_cnt == 16)
//     word_cnt = 23;
//   else if (word_cnt == 20)
//     word_cnt = 11;
//   else if(word_cnt == 8)
//     word_cnt = 15;
//   else if (word_cnt == 12)
//     word_cnt = 3;
//   else if (word_cnt == 0)
//     word_cnt = 7;
//   else if (word_cnt == 4)
//     word_cnt = 27;
    else
      word_cnt = word_cnt + 1;// - 1;
#1;
    // decrement bit counter
    bit_cnt = bit_cnt - 1;
#1;
    // wait for delta time
    delta_t = !delta_t;
  end // while

  #1;
end
endtask // serial_crc_phy_tx

// serial CRC calculating for PHY RX
task serial_crc_phy_rx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       bit_cnt;
  reg    [31:0] load_reg;
  reg    [31:0] crc_shift_reg;
  reg    [31:0] crc_store_reg;
  reg           delta_t;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // start of the frame
  crc_shift_reg = 0;
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of bits from Byte length (2^3 = 8)
  if (plus_dribble_nibble)
    bit_cnt = ((len + 4) << 3) + 3'h4; // one nibble longer
  else
    bit_cnt = ((len + 4) << 3);
  load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15:8]  = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[7:0]   = eth_phy.rx_mem[addr_cnt];

  while (bit_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // store previous data
    crc_store_reg = crc_shift_reg;
    // shift data in
    if(bit_cnt <= 32) // for additional 32 bits shift ZEROs in!
     crc_shift_reg[0] = 1'b0               ^ crc_store_reg[31];
    else
     crc_shift_reg[0] = load_reg[word_cnt] ^ crc_store_reg[31];
    crc_shift_reg[1]  = crc_store_reg[0]   ^ crc_store_reg[31];
    crc_shift_reg[2]  = crc_store_reg[1]   ^ crc_store_reg[31];
    crc_shift_reg[3]  = crc_store_reg[2];
    crc_shift_reg[4]  = crc_store_reg[3]   ^ crc_store_reg[31];
    crc_shift_reg[5]  = crc_store_reg[4]   ^ crc_store_reg[31];
    crc_shift_reg[6]  = crc_store_reg[5];
    crc_shift_reg[7]  = crc_store_reg[6]   ^ crc_store_reg[31];
    crc_shift_reg[8]  = crc_store_reg[7]   ^ crc_store_reg[31];
    crc_shift_reg[9]  = crc_store_reg[8];
    crc_shift_reg[10] = crc_store_reg[9]   ^ crc_store_reg[31];
    crc_shift_reg[11] = crc_store_reg[10]  ^ crc_store_reg[31];
    crc_shift_reg[12] = crc_store_reg[11]  ^ crc_store_reg[31];
    crc_shift_reg[13] = crc_store_reg[12];
    crc_shift_reg[14] = crc_store_reg[13];
    crc_shift_reg[15] = crc_store_reg[14];
    crc_shift_reg[16] = crc_store_reg[15]  ^ crc_store_reg[31];
    crc_shift_reg[17] = crc_store_reg[16];
    crc_shift_reg[18] = crc_store_reg[17];
    crc_shift_reg[19] = crc_store_reg[18];
    crc_shift_reg[20] = crc_store_reg[19];
    crc_shift_reg[21] = crc_store_reg[20];
    crc_shift_reg[22] = crc_store_reg[21]  ^ crc_store_reg[31];
    crc_shift_reg[23] = crc_store_reg[22]  ^ crc_store_reg[31];
    crc_shift_reg[24] = crc_store_reg[23];
    crc_shift_reg[25] = crc_store_reg[24];
    crc_shift_reg[26] = crc_store_reg[25]  ^ crc_store_reg[31];
    crc_shift_reg[27] = crc_store_reg[26];
    crc_shift_reg[28] = crc_store_reg[27];
    crc_shift_reg[29] = crc_store_reg[28];
    crc_shift_reg[30] = crc_store_reg[29];
    crc_shift_reg[31] = crc_store_reg[30];
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if (word_cnt == 7)
    begin
      addr_cnt = addr_cnt + 1;
      load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[15:8]  = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[7:0]   = eth_phy.rx_mem[addr_cnt];
    end
    // set new load bit position
    if(word_cnt == 31)
      word_cnt = 16;
    else if (word_cnt == 23)
      word_cnt = 8;
    else if (word_cnt == 15)
      word_cnt = 0;
    else if (word_cnt == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 1;
    // decrement bit counter
    bit_cnt = bit_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while

  // put CRC out
  crc = crc_shift_reg;
  #1;
end
endtask // serial_crc_phy_rx

// serial CRC checking for MAC
task serial_crc_mac;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc;
  reg    [19:0] addr_cnt; // only 20 address lines
  integer       word_cnt;
  integer       bit_cnt;
  reg    [31:0] load_reg;
  reg    [31:0] crc_shift_reg;
  reg    [31:0] crc_store_reg;
  reg           delta_t;
begin
  #1 addr_cnt = start_addr[19:0];
  // set starting point depending with which byte frame starts (e.g. if addr_cnt[1:0] == 0, then
  //   MSB of the packet must be written to the LSB of Big ENDIAN Word [31:24])
  if (addr_cnt[1:0] == 2'h1)
    word_cnt = 16; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h2)
    word_cnt = 8; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h3)
    word_cnt = 0; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else 
    word_cnt = 24; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)

  crc_shift_reg = 0;
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of bits from Byte length (2^3 = 8)
  if (plus_dribble_nibble)
    bit_cnt = ((len + 4) << 3) + 3'h4; // one nibble longer
  else
    bit_cnt = ((len + 4) << 3);
  load_reg = wb_slave.wb_memory[{12'h0, addr_cnt}];

  while (bit_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // store previous data
    crc_store_reg = crc_shift_reg;
    // shift data in
    if(bit_cnt <= 32) // for additional 32 bits shift ZEROs in!
     crc_shift_reg[0] = 1'b0               ^ crc_store_reg[31];
    else
     crc_shift_reg[0] = load_reg[word_cnt] ^ crc_store_reg[31];
    crc_shift_reg[1]  = crc_store_reg[0]   ^ crc_store_reg[31];
    crc_shift_reg[2]  = crc_store_reg[1]   ^ crc_store_reg[31];
    crc_shift_reg[3]  = crc_store_reg[2];
    crc_shift_reg[4]  = crc_store_reg[3]   ^ crc_store_reg[31];
    crc_shift_reg[5]  = crc_store_reg[4]   ^ crc_store_reg[31];
    crc_shift_reg[6]  = crc_store_reg[5];
    crc_shift_reg[7]  = crc_store_reg[6]   ^ crc_store_reg[31];
    crc_shift_reg[8]  = crc_store_reg[7]   ^ crc_store_reg[31];
    crc_shift_reg[9]  = crc_store_reg[8];
    crc_shift_reg[10] = crc_store_reg[9]   ^ crc_store_reg[31];
    crc_shift_reg[11] = crc_store_reg[10]  ^ crc_store_reg[31];
    crc_shift_reg[12] = crc_store_reg[11]  ^ crc_store_reg[31];
    crc_shift_reg[13] = crc_store_reg[12];
    crc_shift_reg[14] = crc_store_reg[13];
    crc_shift_reg[15] = crc_store_reg[14];
    crc_shift_reg[16] = crc_store_reg[15]  ^ crc_store_reg[31];
    crc_shift_reg[17] = crc_store_reg[16];
    crc_shift_reg[18] = crc_store_reg[17];
    crc_shift_reg[19] = crc_store_reg[18];
    crc_shift_reg[20] = crc_store_reg[19];
    crc_shift_reg[21] = crc_store_reg[20];
    crc_shift_reg[22] = crc_store_reg[21]  ^ crc_store_reg[31];
    crc_shift_reg[23] = crc_store_reg[22]  ^ crc_store_reg[31];
    crc_shift_reg[24] = crc_store_reg[23];
    crc_shift_reg[25] = crc_store_reg[24];
    crc_shift_reg[26] = crc_store_reg[25]  ^ crc_store_reg[31];
    crc_shift_reg[27] = crc_store_reg[26];
    crc_shift_reg[28] = crc_store_reg[27];
    crc_shift_reg[29] = crc_store_reg[28];
    crc_shift_reg[30] = crc_store_reg[29];
    crc_shift_reg[31] = crc_store_reg[30];
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data for Big ENDIAN Bytes (Litle ENDIAN bits)
    if (word_cnt == 7)
    begin
      addr_cnt = addr_cnt + 4;
      load_reg = wb_slave.wb_memory[{12'h0, addr_cnt}];
    end
    // set new load bit position for Big ENDIAN Bytes (Litle ENDIAN bits)
    if(word_cnt == 31)
      word_cnt = 16;
    else if (word_cnt == 23)
      word_cnt = 8;
    else if (word_cnt == 15)
      word_cnt = 0;
    else if (word_cnt == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 1;
    // decrement bit counter
    bit_cnt = bit_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while

  // put CRC out
  crc = crc_shift_reg;
  #1;
end
endtask // serial_crc_mac

//////////////////////////////////////////////////////////////
// MIIM Basic tasks
//////////////////////////////////////////////////////////////

task mii_set_clk_div; // set clock divider for MII clock
  input [7:0]  clk_div;
begin
  // MII mode register
  wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_CLKDIV & clk_div), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
end
endtask // mii_set_clk_div


task check_mii_busy; // MII - check if BUSY
  reg [31:0] tmp;
begin
  @(posedge wb_clk);                                                                  
  // MII read status register
  wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  while(tmp[`ETH_MIISTATUS_BUSY] !== 1'b0) //`ETH_MIISTATUS_BUSY
  begin
    @(posedge wb_clk);
    wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // check_mii_busy


task check_mii_scan_valid; // MII - check if SCAN data are valid
  reg [31:0] tmp;
begin
  @(posedge wb_clk);
  // MII read status register
  wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  while(tmp[`ETH_MIISTATUS_NVALID] !== 1'b0) //`ETH_MIISTATUS_NVALID
  begin
    @(posedge wb_clk);
    wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // check_mii_scan_valid


task mii_write_req; // requests write to MII
  input [4:0]  phy_addr;
  input [4:0]  reg_addr;
  input [15:0] data_in;
begin
  // MII address, PHY address = 1, command register address = 0
  wbm_write(`ETH_MIIADDRESS, (`ETH_MIIADDRESS_FIAD & phy_addr) | (`ETH_MIIADDRESS_RGAD & (reg_addr << 8)), 
            4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII TX data
  wbm_write(`ETH_MIITX_DATA, {16'h0000, data_in}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII command
  wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_WCTRLDATA, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);                                                                  
end
endtask // mii_write_req


task mii_read_req; // requests read from MII
  input [4:0]  phy_addr;
  input [4:0]  reg_addr;
begin
  // MII address, PHY address = 1, command register address = 0
  wbm_write(`ETH_MIIADDRESS, (`ETH_MIIADDRESS_FIAD & phy_addr) | (`ETH_MIIADDRESS_RGAD & (reg_addr << 8)), 
            4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII command
  wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_RSTAT, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);
end
endtask // mii_read_req


task mii_scan_req; // requests scan from MII
  input [4:0]  phy_addr;
  input [4:0]  reg_addr;
begin
  // MII address, PHY address = 1, command register address = 0
  wbm_write(`ETH_MIIADDRESS, (`ETH_MIIADDRESS_FIAD & phy_addr) | (`ETH_MIIADDRESS_RGAD & (reg_addr << 8)), 
            4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII command
  wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_SCANSTAT, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);
end
endtask // mii_scan_req


task mii_scan_finish; // finish scan from MII
begin
  // MII command
  wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);
end
endtask // mii_scan_finish

//////////////////////////////////////////////////////////////
// Log files and memory tasks
//////////////////////////////////////////////////////////////

task clear_memories;
  reg    [22:0]  adr_i;
  reg            delta_t;
begin
  for (adr_i = 0; adr_i < 4194304; adr_i = adr_i + 1)
  begin
    eth_phy.rx_mem[adr_i[21:0]] = 0;
    eth_phy.tx_mem[adr_i[21:0]] = 0;
    wb_slave.wb_memory[adr_i[21:2]] = 0;
  end
end
endtask // clear_memories

task clear_buffer_descriptors;
  reg    [8:0]  adr_i;
  reg            delta_t;
begin
  delta_t = 0;
  for (adr_i = 0; adr_i < 256; adr_i = adr_i + 1)
  begin
    wbm_write((`TX_BD_BASE + {adr_i[7:0], 2'b0}), 32'h0, 4'hF, 1, 4'h1, 4'h1);
    delta_t = !delta_t;
  end
end
endtask // clear_buffer_descriptors

task test_note;
  input [799:0] test_note ;
  reg   [799:0] display_note ;
begin
  display_note = test_note;
  while ( display_note[799:792] == 0 )
    display_note = display_note << 8 ;
  $fdisplay( tb_log_file, " " ) ;
  $fdisplay( tb_log_file, "NOTE: %s", display_note ) ;
  $fdisplay( tb_log_file, " " ) ;
end
endtask // test_note

task test_heading;
  input [799:0] test_heading ;
  reg   [799:0] display_test ;
begin
  display_test = test_heading;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, "  Heading: %s", display_test ) ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;
end
endtask // test_heading


task test_fail ;
  input [7999:0] failure_reason ;
//  reg   [8007:0] display_failure ;
  reg   [7999:0] display_failure ;
  reg   [799:0] display_test ;
begin
  tests_failed = tests_failed + 1 ;

  display_failure = failure_reason; // {failure_reason, "!"} ;
  while ( display_failure[7999:7992] == 0 )
    display_failure = display_failure << 8 ;

  display_test = test_name ;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;

  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, "    At time: %t ", $time ) ;
  $fdisplay( tb_log_file, "    Test: %s", display_test ) ;
  $fdisplay( tb_log_file, "    *FAILED* because") ;
  $fdisplay( tb_log_file, "    %s", display_failure ) ;
  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;

 `ifdef STOP_ON_FAILURE
    #20 $stop ;
 `endif
end
endtask // test_fail


task test_fail_num ;
  input [7999:0] failure_reason ;
  input [31:0]   number ;
//  reg   [8007:0] display_failure ;
  reg   [7999:0] display_failure ;
  reg   [799:0] display_test ;
begin
  tests_failed = tests_failed + 1 ;

  display_failure = failure_reason; // {failure_reason, "!"} ;
  while ( display_failure[7999:7992] == 0 )
    display_failure = display_failure << 8 ;

  display_test = test_name ;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;

  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, "    At time: %t ", $time ) ;
  $fdisplay( tb_log_file, "    Test: %s", display_test ) ;
  $fdisplay( tb_log_file, "    *FAILED* because") ;
  $fdisplay( tb_log_file, "    %s; %d", display_failure, number ) ;
  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;

 `ifdef STOP_ON_FAILURE
    #20 $stop ;
 `endif
end
endtask // test_fail_num


task test_ok ;
  reg [799:0] display_test ;
begin
  tests_successfull = tests_successfull + 1 ;

  display_test = test_name ;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;

  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, "    At time: %t ", $time ) ;
  $fdisplay( tb_log_file, "    Test: %s", display_test ) ;
  $fdisplay( tb_log_file, "    reported *SUCCESSFULL*! ") ;
  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;
end
endtask // test_ok


task test_summary;
begin
  $fdisplay(tb_log_file, "**************************** Ethernet MAC test summary **********************************") ;
  $fdisplay(tb_log_file, "Tests performed:   %d", tests_successfull + tests_failed) ;
  $fdisplay(tb_log_file, "Failed tests   :   %d", tests_failed) ;
  $fdisplay(tb_log_file, "Successfull tests: %d", tests_successfull) ;
  $fdisplay(tb_log_file, "**************************** Ethernet MAC test summary **********************************") ;
  $fclose(tb_log_file) ;
end
endtask // test_summary
        
endmodule
