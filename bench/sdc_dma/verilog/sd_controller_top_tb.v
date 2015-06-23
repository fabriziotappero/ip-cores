//////////////////////////////////////////////////////////////////////
////                                                              ////
////  sd_controller_top_tb.v                                      ////
////                                                              ////
////  This file is part of the SD IP core project                 ////
//// http://www.opencores.org/?do=project&who=sdcard_mass_storage_controller                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Adam Edvardsson, adam@opencores.org                   ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//// WB Model, ideas and task borrowed from:                    ////
//// http://www.opencores.org/projects/ethmac/                    ////
////  Author(s):                                                  ////
////      - Tadej Markovic, tadej@opencores.org                   ////
////      - Igor Mohor,     igorM@opencores.org                   ////
//////////////////////////////////////////////////////////////////////
////                  
                                            ////
//// Copyright (C) 2001, 2002 Authors                             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


//`define TX_ERROR_TEST
`include "wb_model_defines.v"
`include "sd_defines.v"
`define TIME $display("  Time: %0t", $time)

`define BD_RX 8'h60
`define BD_TX 8'h80

`define argument 8'h00
`define command 8'h04
`define status 8'h08
`define resp1 8'h0c
`define controller 8'h1c
`define block 8'h20
`define power 8'h24
`define software 8'h28
`define timeout 8'h2c  
`define normal_isr 8'h30   
`define error_isr 8'h34  
`define normal_iser 8'h38
`define error_iser 8'h3c
`define capa 8'h48
`define clock_d 8'h4c
`define bd_status 8'h50
`define bd_isr 8'h54 
`define bd_iser 8'h58 
`define bd_rx 8'h60  
`define bd_tx 8'h80  
`define  BD_ISR  8'h54
`define SD_BASE              32'hd0000000
`define CMD2 16'h200
`define CMD3 16'h300
`define ACMD6 16'h600
`define CMD7 16'h700
`define CMD8 16'h800
`define CMD55 16'h3700
`define ACMD41 16'h2900
`define CMD8 16'h800

`define RSP_48 16'h2
`define RSP_136 16'h1
`define CICE 16'h10
`define CRCE 16'h08

module sd_controller_top_tb(

);



// WISHBONE common
reg           wb_clk;     // WISHBONE clock
reg           wb_rst;     // WISHBONE reset
wire   [31:0]  wbs_sds_dat_i;     // WISHBONE data input
wire [31:0]   wbs_sds_dat_o;     // WISHBONE data output
     // WISHBONE error output
// WISHBONE slave
wire   [9:0]  wbs_sds_adr_i;     // WISHBONE address input
wire    [3:0]  wbs_sds_sel_i;     // WISHBONE byte select input
wire           wbs_sds_we_i;      // WISHBONE write enable input
wire           wbs_sds_cyc_i;     // WISHBONE cycle input
wire           wbs_sds_stb_i;     // WISHBONE strobe input
wire          wbs_sds_ack_o;     // WISHBONE acknowledge output
// WISHBONE master
wire  [31:0]  wbm_sdm_adr_o;
wire   [3:0]  wbm_sdm_sel_o;
wire          wbm_sdm_we_o;

wire   [31:0]  wbm_sdm_dat_i;
wire  [31:0]  wbm_sdm_dat_o;
wire          wbm_sdm_cyc_o;
wire          wbm_sdm_stb_o;
wire           wbm_sdm_ack_i;
wire  	[2:0]  wbm_sdm_cti_o;
wire	[1:0]	   wbm_sdm_bte_o;
//Global variables

reg          wbm_working; // tasks wbm_write and wbm_read set signal when working and reset it when stop working
integer      tests_successfull;
integer      tests_failed;

reg   [3:0]  wbm_init_waits; // initial wait cycles between CYC_O and STB_O of WB Master
reg   [3:0]  wbm_subseq_waits; // subsequent wait cycles between STB_Os of WB Master
reg   [3:0]  wbs_waits; // wait cycles befor WB Slave responds
reg   [7:0]  wbs_retries; // if RTY response, then this is the number of retries before ACK

reg [799:0]  test_name; // used for tb_log_file
//SD Card interface

wire sd_cmd_oe;
wire sd_dat_oe;
wire cmdIn;
wire [3:0] datIn;
wire card_detect;
trireg sd_cmd;
tri [3:0] sd_dat;

assign sd_cmd = sd_cmd_oe ? cmdIn: 1'bz;
assign sd_dat =  sd_dat_oe  ? datIn : 4'bz;
assign card_detect = 1'b1;
reg succes;
sdModel sdModelTB0
(
.sdClk (sd_clk_pad_o),
.cmd (sd_cmd),
.dat (sd_dat)

); 


//Instaciate SD-Card controller

sdc_controller sd_controller_top_0
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_sds_dat_i),
	 .wb_dat_o(wbs_sds_dat_o),
	 .wb_adr_i(wbs_sds_adr_i[7:0]),
	 .wb_sel_i(wbs_sds_sel_i),
	 .wb_we_i(wbs_sds_we_i),
	 .wb_stb_i(wbs_sds_stb_i),
	 .wb_cyc_i(wbs_sds_cyc_i),
	 .wb_ack_o(wbs_sds_ack_o),
	 .m_wb_adr_o(wbm_sdm_adr_o),
	 .m_wb_sel_o(wbm_sdm_sel_o),
	 .m_wb_we_o(wbm_sdm_we_o),
	 .m_wb_dat_o(wbm_sdm_dat_o),
	 .m_wb_dat_i(wbm_sdm_dat_i),
	 .m_wb_cyc_o(wbm_sdm_cyc_o),
	 .m_wb_stb_o(wbm_sdm_stb_o),
	 .m_wb_ack_i(wbm_sdm_ack_i),
	 .m_wb_cti_o(wbm_sdm_cti_o),
	 .m_wb_bte_o(wbm_sdm_bte_o),
	 .sd_cmd_dat_i(sd_cmd),
   .sd_cmd_out_o (cmdIn ),
	 .sd_cmd_oe_o (sd_cmd_oe),
	 .sd_dat_dat_i ( sd_dat  ),  //sd_dat_pad_io),
	 .sd_dat_out_o (datIn  ) ,
   .sd_dat_oe_o ( sd_dat_oe  ),
	 .sd_clk_o_pad  (sd_clk_pad_o),
   .card_detect (card_detect)
	  `ifdef SD_CLK_SEP
   ,sd_clk_i_pad
  `endif
  `ifdef IRQ_ENABLE
   ,.int_a (int_a),
    .int_b (int_b),
    .int_c (int_c) 
  `endif
	 );

integer host_log_file_desc;
WB_MASTER_BEHAVIORAL wb_master
(
    .CLK_I(wb_clk),
    .RST_I(wb_rst),
    .TAG_I(0), //Not in use
    .TAG_O(), //Not in use
    .ACK_I(wbs_sds_ack_o),
    .ADR_O(wbs_sds_adr_i), // only eth_sl_wb_adr_i[11:2] used
    .CYC_O(wbs_sds_cyc_i),
    .DAT_I(wbs_sds_dat_o),
    .DAT_O(wbs_sds_dat_i),
    .ERR_I(0),  //Not in use
    .RTY_I(1'b0),  // inactive (1'b0)
    .SEL_O(wbs_sds_sel_i),
    .STB_O(wbs_sds_stb_i),
    .WE_O (wbs_sds_we_i),
    .CAB_O()       // NOT USED for now!
);
integer memory_log_file_desc;

WB_SLAVE_BEHAVIORAL wb_slave
(
    .CLK_I(wb_clk),
    .RST_I(wb_rst),
    .ACK_O(wbm_sdm_ack_i),
    .ADR_I(wbm_sdm_adr_o),
    .CYC_I(wbm_sdm_cyc_o),
    .DAT_O(wbm_sdm_dat_i),
    .DAT_I(wbm_sdm_dat_o),
    .ERR_O(),
    .RTY_O(),      // NOT USED for now!
    .SEL_I(wbm_sdm_sel_o),
    .STB_I(wbm_sdm_stb_o),
    .WE_I (wbm_sdm_we_o),
    .CAB_I(1'b0)
);
 

 integer phy_log_file_desc;  
integer wb_s_mon_log_file_desc ;
integer wb_m_mon_log_file_desc ;

/*WB_BUS_MON wb_eth_slave_bus_mon
(
  // WISHBONE common
  .CLK_I(wb_clk),
  .RST_I(wb_rst),

  // WISHBONE slave
  .ACK_I(wbs_sds_ack_o),
  .ADDR_O({24'h0,wbs_sds_adr_i[7:0]}),
  .CYC_O(wbs_sds_cyc_i),
  .DAT_I(wbs_sds_dat_o),
  .DAT_O(wbs_sds_dat_i),
  .ERR_I(0),
  .RTY_I(1'b0),
  .SEL_O(wbs_sds_sel_i),
  .STB_O(wbs_sds_stb_i),
  .WE_O (wbs_sds_we_i),
  .TAG_I(0),
`ifdef ETH_WISHBONE_B3
  .TAG_O(),
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
); */

WB_BUS_MON wb_eth_master_bus_mon
(
  // WISHBONE common
  .CLK_I(wb_clk),
  .RST_I(wb_rst),

  // WISHBONE master
  .ACK_I(wbm_sdm_ack_i),
  .ADDR_O(wbm_sdm_adr_o),
  .CYC_O(wbm_sdm_cyc_o),
  .DAT_I(wbm_sdm_dat_i),
  .DAT_O(wbm_sdm_dat_o),
  .ERR_I(0),
  .RTY_I(1'b0),
  .SEL_O(wbm_sdm_sel_o),
  .STB_O(wbm_sdm_stb_o),
  .WE_O (wbm_sdm_we_o),
  .TAG_I(0),
  .TAG_O(5'h0),
  .CAB_O(1'b0),
  .check_CTI(1'b0), // NO need
  .log_file_desc(wb_m_mon_log_file_desc)
);

reg StartTB;
integer card_rca;
initial
begin
  wait(StartTB);
  succes = 1'b0;
  // Initial global values
  tests_successfull = 0;
  tests_failed = 0;  
  wbm_working = 0;
  card_rca=0;
  wbm_init_waits = 4'h1;
  wbm_subseq_waits = 4'h3;
  wbs_waits = 4'h1;
  wbs_retries = 8'h2; 
  wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

  // set DIFFERENT mrx_clk to mtx_clk!
//  eth_phy.set_mrx_equal_mtx = 1'b0;

  //  Call tests
  //  ----------
  //note test T5 only valid when SD is in Testmode (sd_tb_defines.v file)
   $display("T0 Start"); 
  test_access_to_reg(0, 1);           // 0 - 1 //Test RW registers  
  $display("");
  $display("===========================================================================");
  $display("T0 test_access_to_reg Completed");
  $display("===========================================================================");
  
  
  $display("T1 Start");  
  test_send_cmd(0, 3); 
  //   0:  Send CMD0, No Response                               ////
   //  1:  Send CMD3, 48-Bit Response, No error check
    //2:  Send CMD3, 48-Bit Response, All Error check   
  //   3:  Send CMD2, 136-Bit Response 
  $display("");
  $display("===========================================================================");
  $display("T1 test_send_cmd Completed");
  $display("===========================================================================");
  

 $display("T2 Start");  
 test_init_sequnce(0, 1);
 $display("");  
 $display("===========================================================================");
 $display("T2 test_init_sequence Completed");
 $display("===========================================================================");
  
  $display("T3 Start");  
  test_send_data(0, 1);
  $display("");
  $display("===========================================================================");
  $display("T3 test_send_data Completed");
  $display("===========================================================================");
  
 // test_send_rec_data
  $display("T4 Start");  
  test_send_rec_data(0, 1);
  $display("");
  $display("===========================================================================");
  $display("T4 test_send_rec_data Completed");
  $display("===========================================================================");
 
  //test_send_rec_data
   $display("T5 Start");  
  test_send_cmd_error_rsp(0, 3);
 $display("");
 $display("===========================================================================");
 $display("T5 test_send_cmd_error_rsp Complete");
 $display("===========================================================================");
 
   //  test_send_rec_data_error_rsp
 test_send_rec_data_error_rsp(0, 1);
// $display("");
//  $display("===========================================================================");
 $display("T6 test_send_cmd_error_rsp Complete");
 // $display("===========================================================================");
 $display("All Test finnished. Nr Failed: %d, Nr Succes: %d", tests_failed,tests_successfull);
  succes = 1'b1;
end









integer     tb_log_file;

initial
begin
  tb_log_file = $fopen("../log/sdc_tb.log");
  if (tb_log_file < 2)
  begin
    $display("*E Could not open/create testbench log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(tb_log_file, "========================== SD IP Core Testbench results ===========================");
  $fdisplay(tb_log_file, " ");

  phy_log_file_desc = $fopen("../log/eth_tb_phy.log");
  if (phy_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create sd_tb_phy.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(phy_log_file_desc, "================ PHY Module  Testbench access log ================");
  $fdisplay(phy_log_file_desc, " ");

  memory_log_file_desc = $fopen("../log/sd_tb_memory.log");
  if (memory_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create sd_tb_memory.log file in ../log/ directory!");
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

  // Reset pulse
  wb_rst =  1'b1;
  #423 wb_rst =  1'b0;

  // Clear memories
  //clear_memories;  

  #423 StartTB  =  1'b1;
end




// Generating WB_CLK_I clock
always
begin
  wb_clk=0;
//  forever #2.5 WB_CLK_I = ~WB_CLK_I;  // 2*2.5 ns -> 200.0 MHz    
//  forever #5 WB_CLK_I = ~WB_CLK_I;  // 2*5 ns -> 100.0 MHz    
//  forever #10 WB_CLK_I = ~WB_CLK_I;  // 2*10 ns -> 50.0 MHz    
  forever #12.5 wb_clk = ~wb_clk;  // 2*12.5 ns -> 40 MHz    
//  forever #15 WB_CLK_I = ~WB_CLK_I;  // 2*10 ns -> 33.3 MHz    
//  forever #20 WB_CLK_I = ~WB_CLK_I;  // 2*20 ns -> 25 MHz    
//  forever #25 WB_CLK_I = ~WB_CLK_I;  // 2*25 ns -> 20.0 MHz
//  forever #31.25 WB_CLK_I = ~WB_CLK_I;  // 2*31.25 ns -> 16.0 MHz    
//  forever #50 WB_CLK_I = ~WB_CLK_I;  // 2*50 ns -> 10.0 MHz
//  forever #55 WB_CLK_I = ~WB_CLK_I;  // 2*55 ns ->  9.1 MHz    
end

//TEST Cases
//
//
//

task test_send_cmd;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// test_send_cmd
test_heading("Send CMD");
$display(" ");
$display("test_send_cmd TEST");
fail = 0;

// reset MAC registers
hard_reset;


//////////////////////////////////////////////////////////////////////
////                                                          ////
////  test_send_cmd:                                          ////
////                                                          ////
////                                ////
///   
///   0:  Send CMD3, 48-Bit Response, All Error check   
///                         ////
///   
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin
        
  //////////////////////////////////////////////////////////////////////
  ////                                                          //// 
  //Test 0:  Send CMD, No Response                               ////
  //////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin

    test_name   = "0:  Send CMD, No Response  ";
    `TIME; $display("  TEST 0: 0:  Send CMD, No Response  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'hff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for send finnish
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0] != 1)
         wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
           
         
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD0 in TEST0", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end 
       
                 
   
     
    end
    
 
       
 
       
                 
   
     
    
    
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
  end
endtask








task test_send_rec_data_error_rsp;
input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
    integer        resp_data;
  reg    [31:0]  tx_bd_num; 
  
  
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// access_to_reg
test_heading("access_to_reg");
$display(" ");
$display("access_to_reg TEST");
fail = 0;
resp_data = 0;
// reset MAC registers
hard_reset;


for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin
        
  //////////////////////////////////////////////////////////////////////
  ////                                                          //// 
  //Test 3.0:  Init sequence, With response check  
  //CMD 0. Reset Card
  //CMD 8. Get voltage (Only 2.0 Card response to this)            ////
  //CMD55. Indicate Next Command are Application specific
  //ACMD44. Get Voltage windows
  //CMD2. CID reg
  //CMD3. Get RCA.
  //////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin

    test_name   = "4.0:  Send data ";
    `TIME; $display("  TEST 4.0:   Send data  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h2ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      
      //CMD 0 Reset card
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for send finnish
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0] != 1)
         wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
        if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD0 in TEST4.0", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
        end
       
      //CMD 8. Get voltage (Only 2.0 Card response to this)  
        addr = `SD_BASE + `command ; 
       data = `CMD8 | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);      
     
      //wait for send finnish or timeout
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 8, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);      
       while (tmp_data[0] != 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
          if (tmp_data[15]) begin
             $display("V 1.0 Card, Timeout In TEST 4.0 %h", tmp_data);  
             tmp_data=1;       
          end        
       end
    resp_data[31]=1; //Just to make it to not skip first 
    while (resp_data[31]) begin //Wait until busy is clear in the card
         //Send CMD 55      
       addr = `SD_BASE + `command ; 
       data = `CMD55 |`CICE | `CRCE | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0] != 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);          
          if (tmp_data[15]== 1) begin
             fail = fail + 1;
             addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
             test_fail_num("Error occured when sending CMD55 in TEST 4.0", i_addr);
            `TIME;
             $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
        end
    
        //Send ACMD 41      
         addr = `SD_BASE + `command ; 
         data = `ACMD41 | `RSP_48 ; 
         wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //Argument settings 
        addr = `SD_BASE + `argument  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
        addr = `SD_BASE + `normal_isr   ; 
        wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        while (tmp_data[0] != 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
            wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending ACMD 41  in TEST 4.0", i_addr);
           `TIME;
            $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
          //Read response data
        end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
     end 
        
      //Send CMD 2      
       addr = `SD_BASE + `command ; 
       data = `CMD2 | `CRCE | `RSP_136 ; //CMD index 2, CRC and Index Check, rsp = 136 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD2 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
       
       
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        $display("CID reg 1: %h", resp_data);
        
       //Send CMD 3      
       addr = `SD_BASE + `command ; 
       data = `CMD3 |  `CRCE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD3 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        card_rca= resp_data [31:16];
 
        $display("RCA Response: %h", resp_data);
        $display("RCA Nr for data transfer: %h", card_rca);
        
        //Put in transferstate
        //Send CMD 7      
       addr = `SD_BASE + `command ; 
       data = `CMD7 |  `CRCE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data[31:16] = card_rca; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD7 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD7 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
       
       //Set bus width
       
         //Send CMD 55      
       addr = `SD_BASE + `command ; 
       data = `CMD55 |`CICE | `CRCE | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);          
          if (tmp_data[15]== 1) begin
             fail = fail + 1;
             addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
             test_fail_num("Error occured when sending CMD55 in TEST 4.0", i_addr);
            `TIME;
             $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
        end
    
        //Send ACMD 6     
         addr = `SD_BASE + `command ; 
         data = `ACMD6 |`CICE | `CRCE | `RSP_48 ; 
         wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //Argument settings 
        addr = `SD_BASE + `argument  ; 
        data = 2; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
        addr = `SD_BASE + `normal_isr   ; 
        wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
            wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending ACMD 6  in TEST 4.0", i_addr);
           `TIME;
            $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
          //Read response data
        end
        
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        $display("Card status after Bus width set %h", resp_data);  
       //write data
       sdModelTB0.add_wrong_data_crc<=1;
        addr = `SD_BASE + `BD_TX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        
        addr = `SD_BASE + `BD_TX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        

        addr = `SD_BASE + `BD_ISR  ;         
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        
        	while (  resp_data[0]  !=1   ) begin
			      wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
			      if (resp_data[1] ) begin
			       test_fail_num("Error in TEST 4.0: Data resend When Writing try >N.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Data resend When Writing try >N.  BD_ISR  %h", resp_data); 
			      end
			      if (resp_data[2] ) begin
			         test_fail_num("Error in TEST 4.0: FIFO underflow/overflow When Writing.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: FIFO underflow/overflow When Writing.  BD_ISR  %h", resp_data); 
			      end
            if (resp_data[4] ) begin
			         test_fail_num("Error in TEST 4.0: Command error When Writing.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Command error When Writing.  BD_ISR  %h", resp_data); 
			      end
			      if (resp_data[5] ) begin
			         test_fail_num("Error in TEST 4.0: Data CRC error When Writing.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Data CRC error When Writing.  BD_ISR  %h", resp_data); 
			      end   			        
			      sdModelTB0.add_wrong_data_crc<=0;
			    end  
			    clear_memories;  
sdModelTB0.add_wrong_data_crc<=1;
			     addr = `SD_BASE + `BD_RX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        
        addr = `SD_BASE + `BD_RX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        

        addr = `SD_BASE + `BD_ISR  ;  
        data=0;
        
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);       
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        
        	while (  resp_data[0]  !=1   ) begin
			      wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
			      if (resp_data[1] ) begin
			       test_fail_num("Error in TEST 4.0 When Reading: Data resend try >N.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 When Reading: Data resend try >N.  BD_ISR  %h", resp_data); 
			      end
			       if (resp_data[2] ) begin
			         test_fail_num("Error in TEST 4.0 When Reading: FIFO underflow/overflow.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 When Reading: FIFO underflow/overflow.  BD_ISR  %h", resp_data); 
			      end
            if (resp_data[4] ) begin
			         test_fail_num("Error in TEST 4.0 When Reading: Command error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Command error.  BD_ISR  %h", resp_data); 
			      end
			       if (resp_data[5] ) begin
			         test_fail_num("Error in TEST 4.0: Data CRC error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Data CRC error When Reading.  BD_ISR  %h", resp_data); 
			      end
        			        
			      
			    end  
        
  end
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
 end
endtask


task test_send_rec_data;
input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
    integer        resp_data;
  reg    [31:0]  tx_bd_num; 
  
  
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// access_to_reg

fail = 0;
resp_data = 0;
// reset MAC registers
hard_reset;


for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin
        
  //////////////////////////////////////////////////////////////////////
  ////                                                          //// 
  //Test 3.0:  Init sequence, With response check  
  //CMD 0. Reset Card
  //CMD 8. Get voltage (Only 2.0 Card response to this)            ////
  //CMD55. Indicate Next Command are Application specific
  //ACMD44. Get Voltage windows
  //CMD2. CID reg
  //CMD3. Get RCA.
  //////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin

    test_name   = "4.0:  Send data ";
    `TIME; $display("  TEST 4.0:   Send data  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h2ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      
      //CMD 0 Reset card
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for send finnish
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1)
         wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
        if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD0 in TEST4.0", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
        end
       
      //CMD 8. Get voltage (Only 2.0 Card response to this)  
        addr = `SD_BASE + `command ; 
       data = `CMD8 | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);      
     
      //wait for send finnish or timeout
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 8, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);      
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
          if (tmp_data[15]) begin
             $display("V 1.0 Card, Timeout In TEST 4.0 %h", tmp_data);  
             tmp_data=1;       
          end        
       end
    resp_data[31]=1; //Just to make it to not skip first 
    while (resp_data[31]) begin //Wait until busy is clear in the card
         //Send CMD 55      
       addr = `SD_BASE + `command ; 
       data = `CMD55 |`CICE | `CRCE | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);          
          if (tmp_data[15]== 1) begin
             fail = fail + 1;
             addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
             test_fail_num("Error occured when sending CMD55 in TEST 4.0", i_addr);
            `TIME;
             $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
        end
    
        //Send ACMD 41      
         addr = `SD_BASE + `command ; 
         data = `ACMD41 | `RSP_48 ; 
         wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //Argument settings 
        addr = `SD_BASE + `argument  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
        addr = `SD_BASE + `normal_isr   ; 
        wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
            wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending ACMD 41  in TEST 4.0", i_addr);
           `TIME;
            $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
          //Read response data
        end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
     end 
        
      //Send CMD 2      
       addr = `SD_BASE + `command ; 
       data = `CMD2 | `CRCE | `RSP_136 ; //CMD index 2, CRC and Index Check, rsp = 136 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD2 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
       
       
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        $display("CID reg 1: %h", resp_data);
        
       //Send CMD 3      
       addr = `SD_BASE + `command ; 
       data = `CMD3 |  `CRCE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD3 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        card_rca= resp_data [31:16];
 
        $display("RCA Response: %h", resp_data);
        $display("RCA Nr for data transfer: %h", card_rca);
        
        //Put in transferstate
        //Send CMD 7      
       addr = `SD_BASE + `command ; 
       data = `CMD7 |  `CRCE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data[31:16] = card_rca; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD7 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD7 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
       
       //Set bus width
       
         //Send CMD 55      
       addr = `SD_BASE + `command ; 
       data = `CMD55 |`CICE | `CRCE | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);          
          if (tmp_data[15]== 1) begin
             fail = fail + 1;
             addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
             test_fail_num("Error occured when sending CMD55 in TEST 4.0", i_addr);
            `TIME;
             $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
        end
    
        //Send ACMD 6     
         addr = `SD_BASE + `command ; 
         data = `ACMD6 |`CICE | `CRCE | `RSP_48 ; 
         wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //Argument settings 
        addr = `SD_BASE + `argument  ; 
        data = 2; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
        addr = `SD_BASE + `normal_isr   ; 
        wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
            wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending ACMD 6  in TEST 4.0", i_addr);
           `TIME;
            $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
          //Read response data
        end
        
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        $display("Card status after Bus width set %h", resp_data);  
       //write data
       
        addr = `SD_BASE + `BD_TX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        
        addr = `SD_BASE + `BD_TX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        

        addr = `SD_BASE + `BD_ISR  ;         
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        
        	while (  resp_data[0]  !=1   ) begin
			      wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
			      if (resp_data[1] ) begin
			       test_fail_num("Error in TEST 4.0 when writing: Data resend try >N.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when writing: Data resend try >N.  BD_ISR  %h", resp_data); 
			      end
			      else if (resp_data[2] ) begin
			         test_fail_num("Error in TEST 4.0 when writing :  FIFO underflow/overflow.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when writing: FIFO underflow/overflow.  BD_ISR  %h", resp_data); 
			      end
            else if (resp_data[4] ) begin
			         test_fail_num("Error in TEST 4.0 when writing: Command error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when writing: Command error.  BD_ISR  %h", resp_data); 
			      end
			      else if (resp_data[5] ) begin
			         test_fail_num("Error in TEST 4.0 when writing: Data CRC error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when writing: Data CRC error.  BD_ISR  %h", resp_data); 
			      end   			        
			      
			    end  
			    clear_memories;  

			     addr = `SD_BASE + `BD_RX  ; 
        data = 0; //
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        
        addr = `SD_BASE + `BD_RX  ; 
        data = 0; //C
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        

        addr = `SD_BASE + `BD_ISR  ;  
        data=0;
        
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);       
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        
        	while (  resp_data[0]  !=1   ) begin
			      wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
			      if (resp_data[1] ) begin
			       test_fail_num("Error in TEST 4.0 when reading: Data resend try >N.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when reading: Data resend try >N.  BD_ISR  %h", resp_data); 
			      end
			      else if (resp_data[2] ) begin
			         test_fail_num("Error in TEST 4.0 when reading: FIFO underflow/overflow.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when reading: FIFO underflow/overflow.  BD_ISR  %h", resp_data); 
			      end
            else if (resp_data[4] ) begin
			         test_fail_num("Error in TEST 4.0 when reading: Command error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when reading: Command error.  BD_ISR  %h", resp_data); 
			      end
			      else if (resp_data[5] ) begin
			         test_fail_num("Error in TEST 4.0 when reading: Data CRC error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0 when reading: Data CRC error.  BD_ISR  %h", resp_data); 
			      end
        			        
			      
			    end  
        
  end
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
 end
endtask









task test_send_data;
input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
    integer        resp_data;
  reg    [31:0]  tx_bd_num; 
  
  
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// access_to_reg
test_heading("access_to_reg");
$display(" ");
$display("access_to_reg TEST");
fail = 0;
resp_data = 0;
// reset MAC registers
hard_reset;


for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin
        
  //////////////////////////////////////////////////////////////////////
  ////                                                          //// 
  //Test 3.0:  Init sequence, With response check  
  //CMD 0. Reset Card
  //CMD 8. Get voltage (Only 2.0 Card response to this)            ////
  //CMD55. Indicate Next Command are Application specific
  //ACMD44. Get Voltage windows
  //CMD2. CID reg
  //CMD3. Get RCA.
  //////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin

    test_name   = "4.0:  Send data ";
    `TIME; $display("  TEST 4.0:   Send data  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h2ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      
      //CMD 0 Reset card
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for send finnish
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1)
         wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
        if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD0 in TEST4.0", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
        end
       
      //CMD 8. Get voltage (Only 2.0 Card response to this)  
        addr = `SD_BASE + `command ; 
       data = `CMD8 | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);      
     
      //wait for send finnish or timeout
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 8, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);      
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
          if (tmp_data[15]) begin
             $display("V 1.0 Card, Timeout In TEST 4.0 %h", tmp_data);  
             tmp_data=1;       
          end        
       end
    resp_data[31]=1; //Just to make it to not skip first 
    while (resp_data[31]) begin //Wait until busy is clear in the card
         //Send CMD 55      
       addr = `SD_BASE + `command ; 
       data = `CMD55 |`CICE | `CRCE | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);          
          if (tmp_data[15]== 1) begin
             fail = fail + 1;
             addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
             test_fail_num("Error occured when sending CMD55 in TEST 4.0", i_addr);
            `TIME;
             $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
        end
    
        //Send ACMD 41      
         addr = `SD_BASE + `command ; 
         data = `ACMD41 | `RSP_48 ; 
         wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //Argument settings 
        addr = `SD_BASE + `argument  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
        addr = `SD_BASE + `normal_isr   ; 
        wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
            wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending ACMD 41  in TEST 4.0", i_addr);
           `TIME;
            $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
          //Read response data
        end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
     end 
        
      //Send CMD 2      
       addr = `SD_BASE + `command ; 
       data = `CMD2 | `CRCE | `RSP_136 ; //CMD index 2, CRC and Index Check, rsp = 136 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD2 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
       
       
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        $display("CID reg 1: %h", resp_data);
        
       //Send CMD 3      
       addr = `SD_BASE + `command ; 
       data = `CMD3 |  `CRCE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD3 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        card_rca= resp_data [31:16];
 
        $display("RCA Response: %h", resp_data);
        $display("RCA Nr for data transfer: %h", card_rca);
        
        //Put in transferstate
        //Send CMD 7      
       addr = `SD_BASE + `command ; 
       data = `CMD7 |  `CRCE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data[31:16] = card_rca; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD7 in TEST 4.0", i_addr);
            `TIME;
             $display("CMD7 Error in TEST 4.0 status reg: %h", tmp_data);  
         end     
      end
       
       //Set bus width
       
         //Send CMD 55      
       addr = `SD_BASE + `command ; 
       data = `CMD55 |`CICE | `CRCE | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);          
          if (tmp_data[15]== 1) begin
             fail = fail + 1;
             addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
             test_fail_num("Error occured when sending CMD55 in TEST 4.0", i_addr);
            `TIME;
             $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
        end
    
        //Send ACMD 6     
         addr = `SD_BASE + `command ; 
         data = `ACMD6 |`CICE | `CRCE | `RSP_48 ; 
         wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //Argument settings 
        addr = `SD_BASE + `argument  ; 
        data = 2; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
        addr = `SD_BASE + `normal_isr   ; 
        wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
            wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending ACMD 6  in TEST 4.0", i_addr);
           `TIME;
            $display("Error in TEST 4.0 status reg: %h", tmp_data);  
          end
          //Read response data
        end
        
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        $display("Card status after Bus width set %h", resp_data);  
       //write data
       
        addr = `SD_BASE + `BD_TX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        
        addr = `SD_BASE + `BD_TX  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        

        addr = `SD_BASE + `BD_ISR  ;         
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        
        	while (  resp_data[0]  !=1   ) begin
			      wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
			      if (resp_data[1] ) begin
			       test_fail_num("Error in TEST 4.0: Data resend try >N.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Data resend try >N.  BD_ISR  %h", resp_data); 
			      end
			      else if (resp_data[2] ) begin
			         test_fail_num("Error in TEST 4.0: FIFO underflow/overflow.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: FIFO underflow/overflow.  BD_ISR  %h", resp_data); 
			      end
            else if (resp_data[4] ) begin
			         test_fail_num("Error in TEST 4.0: Command error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Command error.  BD_ISR  %h", resp_data); 
			      end
			      else if (resp_data[5] ) begin
			         test_fail_num("Error in TEST 4.0: Data CRC error.  BD_ISR  %h", resp_data);
            `TIME;
             $display("Error in TEST 4.0: Data CRC error.  BD_ISR  %h", resp_data); 
			      end
        			        
			      
			    end  
        
  end
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
 end
endtask

task test_init_sequnce; //
 input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
    integer        resp_data;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// access_to_reg
test_heading("access_to_reg");
$display(" ");
$display("access_to_reg TEST");
fail = 0;
resp_data = 0;
// reset MAC registers
hard_reset;


for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin
        
  //////////////////////////////////////////////////////////////////////
  ////                                                          //// 
  //Test 3.0:  Init sequence, With response check  
  //CMD 0. Reset Card
  //CMD 8. Get voltage (Only 2.0 Card response to this)            ////
  //CMD55. Indicate Next Command are Application specific
  //ACMD44. Get Voltage windows
  //CMD2. CID reg
  //CMD3. Get RCA.
  //////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin

    test_name   = "3.0:  Init Seq, No Response  ";
    `TIME; $display("  TEST 3.0: 0:  Init Seq, No Response  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h2ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      
      //CMD 0 Reset card
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for send finnish
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1)
         wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
        if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD0 in TEST0", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
        end
       
      //CMD 8. Get voltage (Only 2.0 Card response to this)  
        addr = `SD_BASE + `command ; 
       data = `CMD8 | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);      
     
      //wait for send finnish or timeout
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 8, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);      
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);         
          if (tmp_data[15]) begin
             $display("V 1.0 Card, Timeout In TEST 3.0 %h", tmp_data);  
             tmp_data=1;       
          end        
       end
    resp_data[31]=1; //Just to make it to not skip first 
    while (resp_data[31]) begin //Wait until busy is clear in the card
         //Send CMD 55      
       addr = `SD_BASE + `command ; 
       data = `CMD55 |`CICE | `CRCE | `RSP_48 ; 
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);          
          if (tmp_data[15]== 1) begin
             fail = fail + 1;
             addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
             test_fail_num("Error occured when sending CMD55 in TEST 3.0", i_addr);
            `TIME;
             $display("Error in TEST 3.0 status reg: %h", tmp_data);  
          end
        end
    
        //Send ACMD 41      
         addr = `SD_BASE + `command ; 
         data = `ACMD41 | `RSP_48 ; 
         wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //Argument settings 
        addr = `SD_BASE + `argument  ; 
        data = 0; //CMD index 0, Erro check =0, rsp = 0;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        //wait for response or timeout
        addr = `SD_BASE + `normal_isr   ; 
        wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
            wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending ACMD 41  in TEST 3.0", i_addr);
           `TIME;
            $display("Error in TEST 3.0 status reg: %h", tmp_data);  
          end
          //Read response data
        end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
     end 
        
      //Send CMD 2      
       addr = `SD_BASE + `command ; 
       data = `CMD2 | `CRCE | `RSP_136 ; //CMD index 2, CRC and Index Check, rsp = 136 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 3.0", i_addr);
            `TIME;
             $display("CMD2 Error in TEST 3.0 status reg: %h", tmp_data);  
         end     
      end
       
       
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        $display("CID reg 1: %h", resp_data);
        
       //Send CMD 3      
       addr = `SD_BASE + `command ; 
       data = `CMD3 |  `CRCE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 3.0", i_addr);
            `TIME;
             $display("CMD3 Error in TEST 3.0 status reg: %h", tmp_data);  
         end     
      end
        addr = `SD_BASE + `resp1   ; 
        wbm_read(addr, resp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        card_rca= resp_data [31:16];
 
        $display("RCA Response: %h", resp_data);
        $display("RCA Nr for data transfer: %h", card_rca);
        
  end
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
 end
endtask




task test_access_to_reg;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// access_to_reg
test_heading("access_to_reg");
$display(" ");
$display("access_to_reg TEST");
fail = 0;

// reset MAC registers
hard_reset;


//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_access_to_reg:                                          ////
////                                                              ////
////  0:  Read/Write acces register                               ////
///                                             ////
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test all RW register for:                                    ////
  ////  1: Read access (Correct reset values)                     ////                      
  ////  2: Write/Read                       ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin
    // TEST 0: BYTE SELECTS ON 3 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )
    test_name   = "TEST 0: 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )";
    `TIME; $display("  TEST 0: 3 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )");
    
    data = 0;
    rand_sel = 0;
    sel = 0;
    
    for (i = 1; i <= 19; i = i + 1) // num of registers
    begin
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5; // it is not important for single accesses
      case (i)
      1: begin      
         i_addr = `bd_iser;
         rsp = 0;
         data = 32'h0000_00FF;
       end
      2:begin      
         i_addr = `command;
         rsp = 0;
         data = 32'h0000_FFFF;
       end             
      3:begin      
         i_addr = `timeout;
         rsp = 0;
         data = 32'h0000_FFFF;
       end       
      4: begin      
         i_addr = `normal_iser;
         rsp = 0;
         data = 32'h0000_FFFF;
       end       
      5:begin      
         i_addr = `error_iser;
         rsp = 0;
         data = 32'h0000_FFFF;
       end         
      6: begin      
         i_addr = `clock_d;
         rsp = `RESET_CLK_DIV;
         data = 32'h0000_00FF;
       end       
               
      19: begin      
         i_addr = `argument;
         rsp = 0;
         data = 32'hFFFF_FFFF;
       end      
       
       8: begin      
         i_addr = `status;
         rsp = 0;         
       end
       
      9: begin      
         i_addr = `resp1;
         rsp = 0;         
       end   
       
       10: begin      
         i_addr = `controller;
         rsp = 2;         
       end    
      
       11: begin      
         i_addr = `block;
         rsp = 16'h200;         
       end  
       
        12: begin      
         i_addr = `power;
         rsp = 16'h00F;         
       end   
       
        13: begin      
         i_addr = `software;
         rsp = 16'h000;         
       end  
       
        14: begin      
         i_addr = `timeout;
         rsp = 16'hFFFF;         
       end   
       
        15: begin      
         i_addr = `normal_isr;
         rsp = 16'h0004;         
       end      

         


      17: begin      
         i_addr = `capa;
         rsp = 16'h000;         
       end      
      18: begin      
         i_addr = `bd_status;
         rsp = 16'h0808;         
       end      
       
      default : begin      
         i_addr = `capa;
         rsp = 16'h000;         
       end  
           
     
      endcase
      addr = `SD_BASE + i_addr;
      sel = 4'hF;
      wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
      if (tmp_data !== rsp)
      begin
        fail = fail + 1;
        test_fail_num("Register %h defaultvalue is not RSP ",i_addr);
        `TIME;
        $display("Wrong defaulte value @ addr %h, tmp_data %h, should b %h", addr, tmp_data,rsp);
      end
 
        // set value to 32'hFFFF_FFFF
      if ( (i<=6) || (i==19) ) begin
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        wait (wbm_working == 0);
           wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (tmp_data !== data)
        begin
          fail = fail + 1;
          test_fail_num("Register could not be written to FFFF_FFFF", i_addr);
          `TIME;
          $display("Register could not be written to FFFF_FFFF - addr %h, tmp_data %h", addr, tmp_data);
        end
      end
      end
    end
       // Errors were reported previously
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
  end
endtask

task test_send_cmd_error_rsp;
input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// test_send_cmd
test_heading("Send CMD, With simulated bus error on SD_CMD line");
$display(" ");
$display("test_send_cmd_error_rsp");
fail = 0;

// reset MAC registers
hard_reset;
sdModelTB0.add_wrong_cmd_crc<=1;


//sdModelTB0.add_wrong_cmd_indx<=1;

//////////////////////////////////////////////////////////////////////
////                                                          ////
////  test_send_cmd:                                          ////
////                                                          ////
////  0:  Send CMD0, No Response                               ////
///   1:  Send CMD3, 48-Bit Response, No error check
///   2:  Send CMD3, 48-Bit Response, All Error check   
///   3:  Send CMD2, 136-Bit Response                          ////
///   
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin
        
  //////////////////////////////////////////////////////////////////////
  ////                                                          //// 
  //Test 5:  Send CMD, with a simulated bus error               ////
  //////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin

    test_name   = "0:  Send CMD, No Response  ";
    `TIME; $display("  TEST 5 part 0: Send CMD, No Response  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'hff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
       sdModelTB0.add_wrong_cmd_crc<=1;
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //wait for send finnish
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1)
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
           
         
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD0 in TEST5", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end 
       
                 
   
     
    end
            sdModelTB0.add_wrong_cmd_crc<=1;
            sdModelTB0.add_wrong_cmd_indx<=1;
   //////////////////////////////////////////////////////////////////////
   ////    Prereq: A valid CMD index which responde with 48 bit has to be sent //
   /// Test 1:  Send CMD, 48-Bit Response, No error check             ////
   //////////////////////////////////////////////////////////////////////
    if (test_num == 1) //
    begin
     test_name   = "  TEST 5, part 1:   Send CMD, 48-Bit Response, No error check   ";
    `TIME; $display("  TEST 5, part 1:  Send CMD, 48-Bit Response, No error check   ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h1ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = `CMD3 | `RSP_48 ; //CMD index 3, Erro check =0, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD3 in TEST 5", i_addr);
            `TIME;
             $display("Error status reg: %h", tmp_data);  
        end
       
      end    
         
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD3 in TEST 5", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end
            
    end
     //////////////////////////////////////////////////////////////////////
   ////Prereq: A valid CMD index which responde with 48 bit has to be sent //
   /// Test 2:  Send CMD3, 48-Bit Response, All Error check  enable     ////
   //////////////////////////////////////////////////////////////////////
    if (test_num == 2) //
    begin
     test_name   = " TEST 5, part 2:   Send CMD3, 48-Bit Response, All Error check  enable   ";
    `TIME; $display("  TEST 5, part 2:   Send CMD3, 48-Bit Response, All Error check  enable   ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h1ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = `CMD3 | `CICE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
          
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
         
            `TIME;
             $display("Bus error succesfully catched, Error status register: %h", tmp_data);
             tmp_data[0]=1; 
        end
       
      end   

     
       
       
                 
   
     
    end


     if (test_num == 3) //
    begin
     test_name   = " Test 5 part 4:   Send CMD2, 136-Bit    ";
    `TIME; $display("  Test 5 part 4:  Send CMD2, 136-Bit    ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h1ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = `CMD2 | `RSP_136 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 5", i_addr);
            `TIME;
             $display("Error status reg: %h", tmp_data);  
        end
       
      end    
         
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD2 in TEST3", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end
       
       
                 
   
     
    end
    
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
  end
endtask
////////////////////////////////////////////////////////////////////////////
task IRQ_test_send_cmd;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
  reg [31:0] rsp;
begin
// test_send_cmd
test_heading("IRQ Send CMD");
$display(" ");
$display("IRQ test_send_cmd TEST");
fail = 0;

// reset MAC registers
hard_reset;


//////////////////////////////////////////////////////////////////////
////                                                          ////
////  test_send_cmd:                                          ////
////                                                          ////
////  0:  Send CMD0, No Response                               ////
///   1:  Send CMD3, 48-Bit Response, No error check
///   2:  Send CMD3, 48-Bit Response, All Error check   
///   3:  Send CMD2, 136-Bit Response                          ////
///   
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin
        
  //////////////////////////////////////////////////////////////////////
  ////                                                          //// 
  //Test 0:  Send CMD, No Response                               ////
  //////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin

    test_name   = "0:  Send CMD, No Response  ";
    `TIME; $display("  TEST 0: 0:  Send CMD, No Response  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h80;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      
      //Enable IRQ_A on Normal Interupt register, Sending complete and Send Fail
       addr = `SD_BASE + `normal_iser ;
       data = 16'h8001;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      
      //Setup settings for command
       addr = `SD_BASE + `command ; 
       data = 16'h802; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings for command
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for send finnish
       addr = `SD_BASE + `normal_isr   ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1)
         wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
      
      //When send finnish check if any error
       addr = `SD_BASE + `error_isr   ; 
       data = 0; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
              
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD0", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end 
       
                 
   
     
    end
    
      
   //////////////////////////////////////////////////////////////////////
   ////    Prereq: A valid CMD index which responde with 48 bit has to be sent //
   /// Test 1:  Send CMD, 48-Bit Response, No error check             ////
   //////////////////////////////////////////////////////////////////////
    if (test_num == 1) //
    begin
     test_name   = "  1:  Send CMD, 48-Bit Response, No error check   ";
    `TIME; $display("  TEST 1:  Send CMD, 48-Bit Response, No error check  ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h1ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = `CMD3 | `RSP_48 ; //CMD index 3, Erro check =0, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD3 in TEST 1", i_addr);
            `TIME;
             $display("Error status reg: %h", tmp_data);  
        end
       
      end    
         
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD3 in TEST 1", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end
            
    end
     //////////////////////////////////////////////////////////////////////
   ////Prereq: A valid CMD index which responde with 48 bit has to be sent //
   /// Test 2:  Send CMD3, 48-Bit Response, All Error check  enable     ////
   //////////////////////////////////////////////////////////////////////
    if (test_num == 2) //
    begin
     test_name   = " 2:  Send CMD3, 48-Bit Response, All Error check  enable   ";
    `TIME; $display("  Test 2:  Send CMD3, 48-Bit Response, All Error check  enable   ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h1ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = `CMD3 | `CICE | `CRCE | `RSP_48 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD3 in TEST 2", i_addr);
            `TIME;
             $display("Error status reg: %h", tmp_data);  
        end
       
      end    
         
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD3 in TEST2", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end
       
       
                 
   
     
    end
     if (test_num == 3) //
    begin
     test_name   = " 3:  Send CMD2, 136-Bit    ";
    `TIME; $display("  Test 3:  Send CMD2, 136-Bit    ");
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5;
     data = 0;
     rand_sel = 0;
     sel = 4'hF;
      
      //Reset Core
       addr = `SD_BASE + `software ; 
       data = 1;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Setup timeout reg 
       addr = `SD_BASE + `timeout  ; 
       data = 16'h1ff;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Clock divider /2 
        addr = `SD_BASE + `clock_d   ; 
       data = 16'h0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); 
      //Start Core
       addr = `SD_BASE + `software ; 
       data = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);     
      //Setup settings 
       addr = `SD_BASE + `command ; 
       data = `CMD2 | `RSP_136 ; //CMD index 3, CRC and Index Check, rsp = 48 bit;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //Argument settings 
       addr = `SD_BASE + `argument  ; 
       data = 0; //CMD index 0, Erro check =0, rsp = 0;
       wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      
      //wait for response or timeout
       addr = `SD_BASE + `normal_isr   ; 
       wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
       while (tmp_data[0]!= 1) begin
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data[15]== 1) begin
            fail = fail + 1;
            addr = `SD_BASE + `error_isr ; 
             wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
            test_fail_num("Error occured when sending CMD2 in TEST 3", i_addr);
            `TIME;
             $display("Error status reg: %h", tmp_data);  
        end
       
      end    
         
       if (tmp_data[15]) begin
         fail = fail + 1;
         test_fail_num("Error occured when sending CMD2 in TEST3", i_addr);
         `TIME;
        $display("Normal status register is not 0x1: %h", tmp_data);         
       end
       
       
                 
   
     
    end
    
  end
   if(fail == 0)
      test_ok;
    else
      fail = 0;
  end
endtask














//Tasks
task wbm_write;
  input  [31:0] address_i;
  input  [31:0] data_i;
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


task clear_memories;
  reg    [22:0]  adr_i;
  reg            delta_t;
begin
  for (adr_i = 0; adr_i < 4194304; adr_i = adr_i + 1)
  begin
   
    wb_slave.wb_memory[adr_i[21:2]] = 0;
  end
end
endtask // clear_memories

task hard_reset; //  MAC registers
begin
  // reset MAC registers
  @(posedge wb_clk);
  #2 wb_rst = 1'b1;
  repeat(2) @(posedge wb_clk);
  #2 wb_rst = 1'b0;
end
endtask // hard_reset

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

endmodule
