`include "sd_defines.v"
//////////////////////////////////////////////////////////////////////
////                                                                    ////
////  sd_controller.v                                                   ////
////                                                                          ////
////  This file is part of the SD Card IP core project                        ////
////  http://www.opencores.org/?do=project&who=sdcard_mass_storage_controller  ////
////                                                                           ////
////  Author(s):                                                            ////
////      - Adam Edvardsson (adam.edvardsson@orsoc.se)                       ////
////                                                                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors                                   ////
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




module sdc_controller(
  
  // WISHBONE common
  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 

  // WISHBONE slave
  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o, 

  // WISHBONE master
  m_wb_adr_o, m_wb_sel_o, m_wb_we_o, 
  m_wb_dat_o, m_wb_dat_i, m_wb_cyc_o, 
  m_wb_stb_o, m_wb_ack_i, 
  m_wb_cti_o, m_wb_bte_o,
  //SD BUS
  
  sd_cmd_dat_i,sd_cmd_out_o,  sd_cmd_oe_o, card_detect,
  sd_dat_dat_i, sd_dat_out_o , sd_dat_oe_o, sd_clk_o_pad
  `ifdef SDC_CLK_SEP
   ,sd_clk_i_pad
  `endif
  `ifdef SDC_IRQ_ENABLE
   ,int_a, int_b, int_c  
  `endif
);



// WISHBONE common
input           wb_clk_i;     // WISHBONE clock
input           wb_rst_i;     // WISHBONE reset
input   [31:0]  wb_dat_i;     // WISHBONE data input
output  [31:0]  wb_dat_o;     // WISHBONE data output
     // WISHBONE error output
input 			card_detect;
// WISHBONE slave
input   [7:0]  wb_adr_i;     // WISHBONE address input
input   [3:0]  wb_sel_i;     // WISHBONE byte select input
input          wb_we_i;      // WISHBONE write enable input
input          wb_cyc_i;     // WISHBONE cycle input
input          wb_stb_i;     // WISHBONE strobe input

output          wb_ack_o;     // WISHBONE acknowledge output

// WISHBONE master
output  [31:0]  m_wb_adr_o;
output  [3:0]   m_wb_sel_o;
output          m_wb_we_o;

input   [31:0]  m_wb_dat_i;
output  [31:0]  m_wb_dat_o;
output          m_wb_cyc_o;
output          m_wb_stb_o;
input           m_wb_ack_i;
output  [2:0]   m_wb_cti_o;
output	[1:0]	m_wb_bte_o;
//SD port

input  wire [3:0] sd_dat_dat_i;   //Data in from SDcard
output wire [3:0] sd_dat_out_o; //Data out to SDcard
output wire sd_dat_oe_o; //SD Card tristate Data Output enable (Connects on the SoC TopLevel)

input  wire sd_cmd_dat_i; //Command in from SDcard
output wire sd_cmd_out_o; //Command out to SDcard
output wire sd_cmd_oe_o; //SD Card tristate CMD Output enable (Connects on the SoC TopLevel)
output sd_clk_o_pad;
  `ifdef SDC_CLK_SEP
   input wire sd_clk_i_pad;
  `endif
//IRQ
`ifdef SDC_IRQ_ENABLE
   output int_a, int_b, int_c ; 
  `endif
  
wire int_busy;



//Wires from SD_CMD_MASTER Module 
wire [15:0] status_reg_w;
wire [31:0] cmd_resp_1_w;
wire [15:0]normal_int_status_reg_w;
wire [4:0]error_int_status_reg_w; 
 

wire[31:0]  argument_reg;
wire[15:0]  cmd_setting_reg;
reg[15:0]   status_reg;
reg[31:0]   cmd_resp_1;
wire[7:0]   software_reset_reg; 
wire[15:0]  time_out_reg;   
reg[15:0]   normal_int_status_reg; 
reg[15:0]   error_int_status_reg;
wire[15:0]  normal_int_signal_enable_reg;
wire[15:0]  error_int_signal_enable_reg;
wire[7:0]   clock_divider;
reg[15:0]   Bd_Status_reg;   
reg[7:0]    Bd_isr_reg;
wire[7:0]   Bd_isr_enable_reg;

 
//Rx Buffer  Descriptor internal signals



wire [`BD_WIDTH-1 :0] free_bd_rx_bd; //NO free Rx_bd
wire new_rx_bd;  // New Bd writen
wire [`RAM_MEM_WIDTH-1:0] dat_out_s_rx_bd; //Data out from Rx_bd to Slave

//Tx Buffer Descriptor internal signals
wire [`RAM_MEM_WIDTH-1:0] dat_in_m_rx_bd; //Data in to Rx_bd from Master
wire [`RAM_MEM_WIDTH-1:0] dat_in_m_tx_bd;
wire [`BD_WIDTH-1 :0] free_bd_tx_bd;
wire new_tx_bd;
wire [`RAM_MEM_WIDTH-1:0] dat_out_s_tx_bd;
wire [7:0] bd_int_st_w; //Wire to BD status register

//Wires for connecting Bd registers with the SD_Data_master module
wire re_s_tx_bd_w;
wire a_cmp_tx_bd_w;
wire re_s_rx_bd_w;
wire a_cmp_rx_bd_w;
wire write_req_s; //SD_Data_master want acces to the CMD line.
wire cmd_busy; //CMD line busy no access granted

wire [31:0] cmd_arg_s; //SD_Data_master CMD Argument
wire [15:0] cmd_set_s; //SD_Data_master Settings Argument
wire [31:0] sys_adr; //System addres the DMA whil Read/Write to/from
wire [1:0]start_dat_t; //Start data transfer

//Signals to Syncronize busy signaling betwen Wishbone access and SD_Data_master access to the CMD line (Also manage the status reg uppdate)

assign cmd_busy = int_busy | status_reg[0];
wire status_reg_busy;


//Wires from SD_DATA_SERIAL_HOST_1 to the FIFO
wire [`SD_BUS_W -1 : 0 ]data_in_rx_fifo;
wire [31: 0 ] data_fout_tx_fifo;
wire [31:0] m_wb_dat_o_rx;
wire [3:0] m_wb_sel_o_tx;
wire [31:0] m_wb_adr_o_tx;
wire [31:0] m_wb_adr_o_rx;

//SD clock 
wire sd_clk_i; //Sd_clk provided to the system
wire sd_clk_o; //Sd_clk used in the system 


//sd_clk_o to be used i set here
`ifdef SDC_CLK_BUS_CLK
  assign sd_clk_i = wb_clk_i;
`endif 
`ifdef SDC_CLK_SEP
   assign sd_clk_i = sd_clk_i_pad;
  `endif

`ifdef SDC_CLK_STATIC
   assign sd_clk_o = sd_clk_i;
`endif
   
`ifdef SDC_CLK_DYNAMIC
  sd_clock_divider clock_divider_1 (
 .CLK (sd_clk_i),
 .DIVIDER (clock_divider),
 .RST  (wb_rst_i | software_reset_reg[0]),
 .SD_CLK  (sd_clk_o)  
);
`endif
assign sd_clk_o_pad  = sd_clk_o ;

wire [15:0] settings;
wire [7:0] serial_status;
wire [39:0] cmd_out_master;
wire [39:0] cmd_in_host;

sd_cmd_master cmd_master_1
(
    .CLK_PAD_IO     (wb_clk_i),
    .RST_PAD_I      (wb_rst_i | software_reset_reg[0]),
    .New_CMD        (new_cmd),
    .data_write     (d_write),
    .data_read      (d_read),
    .ARG_REG        (argument_reg),
    .CMD_SET_REG    (cmd_setting_reg[13:0]),
    .STATUS_REG     (status_reg_w),
    .TIMEOUT_REG    (time_out_reg),
    .RESP_1_REG     (cmd_resp_1_w),
    .ERR_INT_REG    (error_int_status_reg_w),
    .NORMAL_INT_REG (normal_int_status_reg_w),
    .ERR_INT_RST    (error_isr_reset),
    .NORMAL_INT_RST (normal_isr_reset),
    .settings       (settings),
    .go_idle_o      (go_idle),
    .cmd_out        (cmd_out_master ),
    .req_out        (req_out_master ),
    .ack_out        (ack_out_master ),
    .req_in         (req_in_host),
    .ack_in         (ack_in_host),
    .cmd_in         (cmd_in_host),
    .serial_status (serial_status),
    .card_detect (card_detect)

);


sd_cmd_serial_host cmd_serial_host_1(
    .SD_CLK_IN  (sd_clk_o), 
    .RST_IN     (wb_rst_i | software_reset_reg[0] | go_idle),
    .SETTING_IN (settings),
    .CMD_IN     (cmd_out_master),
    .REQ_IN     (req_out_master),
    .ACK_IN     (ack_out_master),
    .REQ_OUT    (req_in_host), 
    .ACK_OUT    (ack_in_host),
    .CMD_OUT    (cmd_in_host),
    .STATUS     (serial_status),
    .cmd_dat_i  (sd_cmd_dat_i),
    .cmd_out_o  (sd_cmd_out_o),
    .cmd_oe_o   ( sd_cmd_oe_o),
    .st_dat_t   (start_dat_t)
);


sd_data_master data_master_1 
(
    .clk            (wb_clk_i),
    .rst            (wb_rst_i | software_reset_reg[0]),
    .dat_in_tx      (dat_out_s_tx_bd),
    .free_tx_bd     (free_bd_tx_bd),
    .ack_i_s_tx     (ack_o_s_tx ),
    .re_s_tx        (re_s_tx_bd_w), 
    .a_cmp_tx       (a_cmp_tx_bd_w),
    .dat_in_rx      (dat_out_s_rx_bd),
    .free_rx_bd     (free_bd_rx_bd),
    .ack_i_s_rx     (ack_o_s_rx),
    .re_s_rx        (re_s_rx_bd_w), 
    .a_cmp_rx       (a_cmp_rx_bd_w),
    .cmd_busy       (cmd_busy),
    .we_req         (write_req_s),
    .we_ack         (we_ack),
    .d_write        (d_write),
    .d_read         (d_read),
    .cmd_arg        (cmd_arg_s),
    .cmd_set        (cmd_set_s),
    .cmd_tsf_err    (normal_int_status_reg[15]) ,
    .card_status    (cmd_resp_1[12:8])   ,
    .start_tx_fifo  (start_tx_fifo),
    .start_rx_fifo  (start_rx_fifo),
    .sys_adr        (sys_adr),
    .tx_empt        (tx_e ),
    .tx_full        (tx_f ),
    .rx_full        (full_rx ),
    .busy_n         (busy_n),
    .transm_complete(trans_complete ),
    .crc_ok         (crc_ok),
    .ack_transfer   (ack_transfer),
    .Dat_Int_Status (bd_int_st_w),
    .Dat_Int_Status_rst (Bd_isr_reset),
    .CIDAT           (cidat_w),
	.transfer_type  (cmd_setting_reg[15:14])
);
 
wire [31:0] data_out_tx_fifo;
sd_data_serial_host sd_data_serial_host_1(
    .sd_clk         (sd_clk_o),
    .rst            (wb_rst_i | software_reset_reg[0]),
    .data_in        (data_out_tx_fifo),
    .rd             (rd), 
    .data_out       (data_in_rx_fifo),
    .we             (we_rx),
    .DAT_oe_o       (sd_dat_oe_o),
    .DAT_dat_o      (sd_dat_out_o),
    .DAT_dat_i      (sd_dat_dat_i),
    .start_dat      (start_dat_t),
    .ack_transfer   (ack_transfer),
    .busy_n         (busy_n),
    .transm_complete(trans_complete ),
    .crc_ok         (crc_ok)
);


sd_bd rx_bd
(
    .clk        (wb_clk_i),
    .rst       (wb_rst_i | software_reset_reg[0]),
    .we_m      (we_m_rx_bd),
    .dat_in_m  (dat_in_m_rx_bd),
    .free_bd   (free_bd_rx_bd),
    .re_s      (re_s_rx_bd_w),
    .ack_o_s   (ack_o_s_rx),
    .a_cmp     (a_cmp_rx_bd_w),
    .dat_out_s (dat_out_s_rx_bd)

);

sd_bd tx_bd
(
    .clk       (wb_clk_i),
    .rst       (wb_rst_i | software_reset_reg[0]),
    .we_m      (we_m_tx_bd),
    .dat_in_m  (dat_in_m_tx_bd),
    .free_bd   (free_bd_tx_bd),
    .ack_o_s   (ack_o_s_tx),
    .re_s      (re_s_tx_bd_w),
    .a_cmp     (a_cmp_tx_bd_w),
    .dat_out_s (dat_out_s_tx_bd)
);


sd_fifo_tx_filler fifo_filer_tx (
    .clk        (wb_clk_i),
    .rst        (wb_rst_i | software_reset_reg[0]),
    .m_wb_adr_o (m_wb_adr_o_tx),
    .m_wb_we_o  (m_wb_we_o_tx),
    .m_wb_dat_i (m_wb_dat_i),
    .m_wb_cyc_o (m_wb_cyc_o_tx),
    .m_wb_stb_o (m_wb_stb_o_tx),
    .m_wb_ack_i (m_wb_ack_i),
    .m_wb_cti_o (m_wb_cti_o_tx),
	.m_wb_bte_o (m_wb_bte_o_tx),
    .en         (start_tx_fifo),
    .adr        (sys_adr),
    .sd_clk     (sd_clk_o),
    .dat_o      (data_out_tx_fifo   ),
    .rd         (rd),
    .empty      (tx_e),
    .fe         (tx_f)
);

sd_fifo_rx_filler fifo_filer_rx (
    .clk        (wb_clk_i),
    .rst        (wb_rst_i | software_reset_reg[0]),
    .m_wb_adr_o (m_wb_adr_o_rx),
    .m_wb_we_o  (m_wb_we_o_rx),
    .m_wb_dat_o (m_wb_dat_o),
    .m_wb_cyc_o (m_wb_cyc_o_rx),
    .m_wb_stb_o (m_wb_stb_o_rx),
    .m_wb_ack_i (m_wb_ack_i),
    .m_wb_cti_o (m_wb_cti_o_rx),
	.m_wb_bte_o (m_wb_bte_o_rx),
    .en         (start_rx_fifo),
    .adr        (sys_adr),
    .sd_clk     (sd_clk_o),
    .dat_i      (data_in_rx_fifo   ),
    .wr         (we_rx),
    .full       (full_rx)
);

sd_controller_wb sd_controller_wb0
	(
	 .wb_clk_i          (wb_clk_i),
	 .wb_rst_i          (wb_rst_i),
	 .wb_dat_i          (wb_dat_i),
	 .wb_dat_o          (wb_dat_o),
	 .wb_adr_i          (wb_adr_i[7:0]),
	 .wb_sel_i          (wb_sel_i),
	 .wb_we_i           (wb_we_i),
	 .wb_stb_i          (wb_stb_i),
	 .wb_cyc_i          (wb_cyc_i),
	 .wb_ack_o          (wb_ack_o),
   	 .we_m_tx_bd        (we_m_tx_bd),
     .new_cmd           (new_cmd), 
     .we_m_rx_bd        (we_m_rx_bd),   
    .we_ack             (we_ack),
    .int_ack            (int_ack),
    .cmd_int_busy       (cmd_int_busy),
    .Bd_isr_reset       (Bd_isr_reset),     
    .normal_isr_reset   (normal_isr_reset),
    .error_isr_reset    (error_isr_reset),
    .int_busy           (int_busy),
    .dat_in_m_tx_bd     (dat_in_m_tx_bd),
    .dat_in_m_rx_bd     (dat_in_m_rx_bd),
    .write_req_s        (write_req_s),
    .cmd_set_s          (cmd_set_s),
    .cmd_arg_s          (cmd_arg_s),
    .argument_reg       (argument_reg),
    .cmd_setting_reg    (cmd_setting_reg),
    .status_reg         (status_reg),
    .cmd_resp_1         (cmd_resp_1),
    .software_reset_reg (software_reset_reg ),
    .time_out_reg       (time_out_reg ),
    .normal_int_status_reg  (normal_int_status_reg),
    .error_int_status_reg   (error_int_status_reg ),
    .normal_int_signal_enable_reg   (normal_int_signal_enable_reg),
    .error_int_signal_enable_reg    (error_int_signal_enable_reg),
    .clock_divider                  (clock_divider ),
    .Bd_Status_reg                  (Bd_Status_reg),
    .Bd_isr_reg                     (Bd_isr_reg ),
    .Bd_isr_enable_reg              (Bd_isr_enable_reg)
	 );





//MUX For WB master acces granted to RX or TX FIFO filler
assign m_wb_cyc_o = start_tx_fifo ? m_wb_cyc_o_tx :start_rx_fifo ?m_wb_cyc_o_rx: 0;
assign m_wb_stb_o = start_tx_fifo ? m_wb_stb_o_tx :start_rx_fifo ?m_wb_stb_o_rx: 0;

assign m_wb_cti_o = start_tx_fifo ? m_wb_cti_o_tx :start_rx_fifo ?m_wb_cti_o_rx: 0;
assign m_wb_bte = start_tx_fifo ? m_wb_bte_o_tx :start_rx_fifo ?m_wb_bte_o_rx: 0;
//assign m_wb_dat_o = m_wb_dat_o_rx;
assign m_wb_we_o = start_tx_fifo ? m_wb_we_o_tx :start_rx_fifo ?m_wb_we_o_rx: 0;
assign m_wb_adr_o = start_tx_fifo ? m_wb_adr_o_tx :start_rx_fifo ?m_wb_adr_o_rx: 0;

`ifdef SDC_IRQ_ENABLE
assign int_a =  |(normal_int_status_reg &  normal_int_signal_enable_reg) ;
assign int_b =  |(error_int_status_reg & error_int_signal_enable_reg);
assign int_c =  |(Bd_isr_reg & Bd_isr_enable_reg);
`endif

assign m_wb_sel_o = 4'b1111;

//Set Bd_Status_reg
always @ (posedge wb_clk_i ) begin
  Bd_Status_reg[15:8]=free_bd_rx_bd;
  Bd_Status_reg[7:0]=free_bd_tx_bd;
  cmd_resp_1<= cmd_resp_1_w;
  normal_int_status_reg<= normal_int_status_reg_w  ;
  error_int_status_reg<= error_int_status_reg_w  ;
  status_reg[0]<= status_reg_busy;
  status_reg[15:1]<=  status_reg_w[15:1]; 
  status_reg[1] <= cidat_w; 
  Bd_isr_reg<=bd_int_st_w;

end


 
//cmd_int_busy is set when an internal access to the CMD buss is granted then immidetly uppdate the status busy bit to prevent buss access to cmd
assign status_reg_busy = cmd_int_busy ? 1'b1: status_reg_w[0];





endmodule
