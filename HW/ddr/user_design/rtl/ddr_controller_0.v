//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2005, 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor		    : Xilinx
// \   \   \/    Version            : 3.6.1
//  \   \        Application	    : MIG
//  /   /        Filename	    : ddr_controller_0.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:41 $
// \   \  /  \   Date Created	    : Mon May 2 2005
//  \___\/\___\
// Device	: Spartan-3/3A/3A-DSP
// Design Name	: DDR2 SDRAM
// Purpose	: This is main controller block. This includes the following
//                features:
//                - The controller state machine that controls the
//                initialization process upon power up, as well as the
//                read, write, and refresh commands.
//                - Accepts and decodes the user commands.
//                - Generates the address and Bank address and control signals
//                   to the memory    
//                - Generates control signals for other modules.
//*****************************************************************************
`timescale 1ns/100ps
`include "../rtl/ddr_parameters_0.v"

module ddr_controller_0
  (
   input                           clk/* synthesis syn_keep=1 */,
   input                           rst0,
   input                           rst180,
   input [((`ROW_ADDRESS 
	    + `COLUMN_ADDRESS)-1):0] address,
   input [`BANK_ADDRESS-1:0]       bank_address,
   input [2:0]                     command_register,
   input                           burst_done,
   output                          ddr_rasb_cntrl,
   output                          ddr_casb_cntrl,
   output [`BANK_ADDRESS-1:0]      ddr_ba_cntrl,
   output [`ROW_ADDRESS-1:0]       ddr_address_cntrl,
   output                          ddr_csb_cntrl,
   output                          dqs_enable,
   output                          dqs_reset /* synthesis syn_keep=1 */,
   output                          rst_dqs_div_int,
   output                          cmd_ack,
   output                          init,
   output			   ddr_web_cntrl,
   output                          ddr_cke_cntrl,
   output reg                      write_enable,
   output reg                      rst_calib,
   output reg                      ddr_odt_cntrl,
   output reg                      ar_done,
   input                           wait_200us,
   output                          auto_ref_req,
   output reg                      read_fifo_rden // Read Enable signal for read fifo(to data_read module)
   );

   localparam IDLE		      = 4'b0000;
   localparam PRECHARGE		      = 4'b0001;
   localparam AUTO_REFRESH	      = 4'b0010;
   localparam ACTIVE		      = 4'b0011;
   localparam FIRST_WRITE	      = 4'b0100;
   localparam WRITE_WAIT	      = 4'b0101;
   localparam BURST_WRITE	      = 4'b0110;
   localparam PRECHARGE_AFTER_WRITE   = 4'b0111;
   localparam PRECHARGE_AFTER_WRITE_2 = 4'b1000;
   localparam READ_WAIT		      = 4'b1001;
   localparam BURST_READ	      = 4'b1010;
   localparam ACTIVE_WAIT	      = 4'b1011;

   localparam INIT_IDLE	         = 2'b00;
   localparam INIT_PRECHARGE	 = 2'b01;
   localparam INIT_LOAD_MODE_REG = 2'b10;
   localparam INIT_AUTO_REFRESH  = 2'b11;

   parameter COL_WIDTH          = `COLUMN_ADDRESS;
   parameter ROW_WIDTH          = `ROW_ADDRESS;


   reg [3:0]                     current_state;
   reg [3:0]                     next_state;
   reg [1:0]                     init_current_state;
   reg [1:0]                     init_next_state;
   reg [((`ROW_ADDRESS           
	  + `COLUMN_ADDRESS)-1):0] address_reg;
   reg                           auto_ref;
   reg                           auto_ref1;
   reg                           autoref_value;
   reg                           auto_ref_detect1;
   reg [(`MAX_REF_WIDTH-1):0]    autoref_count;
   reg                           auto_ref_issued;
   reg [`BANK_ADDRESS-1:0]       ba_address_reg1;
   reg [`BANK_ADDRESS-1:0]       ba_address_reg2;
   reg [2:0]                     burst_length;
   reg [2:0]                     cas_count;
   reg [4:0]                     ras_count; 

   reg [`ROW_ADDRESS-1:0]        column_address_reg;
   reg [`ROW_ADDRESS-1:0]        column_address_reg1;
   reg [2:0]                     wr;
   reg                           ddr_rasb2;
   reg                           ddr_casb2;
   reg                           ddr_web2;
   reg [`BANK_ADDRESS-1:0]       ddr_ba1;
   reg [`ROW_ADDRESS-1:0]        ddr_address1;
   reg [3:0]                     init_count;
   reg                           init_done;
   reg                           init_done_r1;
   reg                           init_memory;
   reg                           init_mem;
   reg [6:0]                     init_pre_count;
   reg [7:0]                     dll_rst_count;
   reg [(`MAX_REF_WIDTH-1):0]    ref_freq_cnt;
   reg                           read_cmd1;
   reg                           read_cmd2;
   reg                           read_cmd3;
   reg [2:0]                     rcd_count;
   reg [7:0]                     rfc_counter_value;
   reg [7:0]                     rfc_count;
   reg                           rfc_count_reg;
   reg                           ar_done_reg;
   reg                           rdburst_end_1;
   reg                           rdburst_end_2;
   reg [`ROW_ADDRESS-1:0]        row_address_reg;
   reg                           rst_dqs_div_r;
   reg                           rst_dqs_div_r1; //For Reg Dimm
   reg [2:0]                     wrburst_end_cnt;
   reg                           wrburst_end_1;
   reg                           wrburst_end_2;
   reg                           wrburst_end_3;
   reg [2:0]                     wr_count;
   reg                           write_cmd1;
   reg                           write_cmd2;
   reg                           write_cmd3;
   reg [2:0]                     dqs_div_cascount;
   reg [2:0]                     dqs_div_rdburstcount;
   reg                           dqs_enable1;
   reg                           dqs_enable2;
   reg                           dqs_enable3;
   reg                           dqs_reset1_clk0;
   reg                           dqs_reset2_clk0;
   reg                           dqs_reset3_clk0;
   reg                           dqs_enable_int;
   reg                           dqs_reset_int;
   reg                           rst180_r;
   reg                           rst0_r;
   reg                           ddr_odt2;
   reg                           go_to_active;
   reg                           accept_cmd_in;
   reg  			 odt_deassert;
   reg [2:0]                     rp_count;
   reg                           auto_ref_wait;
   reg                           auto_ref_wait1;
   reg                           auto_ref_wait2;
   reg [7:0]                     count6;


   wire [`ROW_ADDRESS - 1:0]     lmr;
   wire [`ROW_ADDRESS - 1:0]     emr;
   wire [`ROW_ADDRESS - 1:0]     lmr_dll_rst;
   wire [`ROW_ADDRESS - 1:0]     lmr_dll_set;
   wire [`ROW_ADDRESS-1:0]       column_address;

   wire                          write_cmd_in;
   wire                          read_cmd_in;
   wire                          init_cmd_in;
   wire                          wrburst_end;
   wire [`ROW_ADDRESS-1:0]       row_address;
   wire                          rdburst_end;
   wire                          init_done_value;
   wire                          ddr_rasb1;
   wire                          ddr_casb1;
   wire                          ddr_web1;
   wire                          ack_reg;
   wire                          ack_o;
   wire                          auto_ref_issued_p;
   wire                          ar_done_p;
   wire                          go_to_active_value;
   wire                          ddr_odt1;
   wire                          rst_dqs_div_int1;
   wire [2:0]                    burst_cnt_max;


   // Input : COMMAND REGISTER FORMAT
   //          000  - NOP
   //          010  - Initialize memory
   //          100  - Write Request
   //          110  - Read request

   // Input : Address format
   //   row address  = address((`ROW_ADDRESS+ `COLUMN_ADDRESS) -1 : `COLUMN_ADDRESS)
   //   column addres = address( `COLUMN_ADDRESS-1 : 0)

   assign    ddr_csb_cntrl       = 1'b0;
   assign    row_address         = address_reg[((`ROW_ADDRESS +
                                                 `COLUMN_ADDRESS)-1):
                                               `COLUMN_ADDRESS];
   assign    init                = init_done;
   assign    ddr_rasb_cntrl      = ddr_rasb2;
   assign    ddr_casb_cntrl      = ddr_casb2;
   assign    ddr_web_cntrl       = ddr_web2;
   assign    ddr_address_cntrl   = ddr_address1;
   assign    ddr_ba_cntrl        = ddr_ba1;
   assign    rst_dqs_div_int     = rst_dqs_div_int1;
   assign    emr                 = `EXT_LOAD_MODE_REGISTER;
   assign    lmr                 = `LOAD_MODE_REGISTER;
   assign    lmr_dll_rst         = {lmr[`ROW_ADDRESS - 1 : 9],1'b1,lmr[7:0]};
   assign    lmr_dll_set         = {lmr[`ROW_ADDRESS - 1 : 9],1'b0,lmr[7:0]};
   assign    ddr_cke_cntrl       = ~wait_200us;

// turn off auto-precharge when issuing read/write commands (A10 = 0)
// mapping the column  address for linear addressing.
  generate
    if (COL_WIDTH == ROW_WIDTH-1) begin: gen_ddr_addr_col_0
      assign column_address = {address_reg[COL_WIDTH-1:10], 1'b0,
                             address_reg[9:0]};
    end else begin
      if (COL_WIDTH > 10) begin: gen_ddr_addr_col_1
        assign column_address = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}},
                               address_reg[COL_WIDTH-1:10], 1'b0,
                               address_reg[9:0]};
      end else begin: gen_ddr_addr_col_2
        assign column_address = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}}, 1'b0,
                               address_reg[COL_WIDTH-1:0]};
      end
    end
  endgenerate

   always @ (negedge clk)
     rst180_r <= rst180;

   always @ (posedge clk)
     rst0_r <= rst0;

//******************************************************************************
// Register user address 
//******************************************************************************

   always @ (negedge clk) begin
      row_address_reg    <= row_address;
      column_address_reg <= column_address;
      ba_address_reg1    <= bank_address;
      ba_address_reg2    <= ba_address_reg1;
      address_reg        <= address;
   end

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         burst_length <= 3'b000;
         wr           <= 3'd0;
      end
      else begin
         burst_length  <= lmr[2:0];
         wr            <= `TWR_COUNT_VALUE;
      end
   end

   always @( negedge clk ) begin
      if ( rst180_r )
        accept_cmd_in <= 1'b0;
      else if ( current_state == IDLE && ((rp_count == 3'd0 && rfc_count_reg &&
                                           !auto_ref_wait && !auto_ref_issued)))
        accept_cmd_in <= 1'b1;
      else
        accept_cmd_in <= 1'b0;
   end


//******************************************************************************
// Commands from user.
//******************************************************************************
   assign init_cmd_in       = (command_register == 3'b010);
   assign write_cmd_in      = (command_register == 3'b100 &&
                               accept_cmd_in == 1'b1) ;
   assign read_cmd_in       = (command_register == 3'b110 &&
                               accept_cmd_in == 1'b1) ;

//******************************************************************************
// write_cmd1 is asserted when user issued write command and the controller s/m 
// is in idle state and AUTO_REF is not asserted.
//******************************************************************************

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         write_cmd1  <= 1'b0;
         write_cmd2  <= 1'b0;
         write_cmd3  <= 1'b0;
      end
      else begin
         if (accept_cmd_in)
           write_cmd1 <= write_cmd_in;
         write_cmd2 <= write_cmd1;
         write_cmd3 <= write_cmd2;
      end
   end
   
//******************************************************************************
// read_cmd1 is asserted when user issued read command and the controller s/m 
// is in idle state and AUTO_REF is not asserted.
//******************************************************************************
  
   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         read_cmd1      <= 1'b0;
         read_cmd2      <= 1'b0;
         read_cmd3      <= 1'b0;
      end
      else begin
         if (accept_cmd_in)
           read_cmd1       <= read_cmd_in;
         read_cmd2       <= read_cmd1;
         read_cmd3       <= read_cmd2;
      end
   end
  
//******************************************************************************
// ras_count- Active to Precharge time
// Controller is giving tras violation when user issues a single read command for 
// BL=4 and tRAS is more then 42ns.It uses a fixed clk count of 7 clocks which is 
// 7*6(@166) = 42ns. Addded ras_count counter which will take care of tras timeout. 
// RAS_COUNT_VALUE parameter is used to load the counter and it depends on the 
// selected memory and frequency
//******************************************************************************
   always @( negedge clk ) begin
      if ( rst180_r )
	ras_count <= 5'd0;
      else if ( current_state == ACTIVE )
	ras_count <= `RAS_COUNT_VALUE-1;
      else if ( ras_count != 5'b00000 )
	ras_count <= ras_count - 1'b1;
   end
//******************************************************************************
// rfc_count
// An executable command can be issued only after Trfc period after a AUTOREFRESH 
// command is issued. rfc_count_value is set in the parameter file depending on 
// the memory device speed grade and the selected frequency.For example for 5B 
// speed grade, trfc= 75 at 133Mhz, rfc_counter_value = 8'b00001010. 
// ( Trfc/clk_period= 75/7.5= 10)
//******************************************************************************

   always @( negedge clk ) begin
      if (rst180_r == 1'b1)
        rfc_count <= 8'd0;
      else if(current_state == AUTO_REFRESH)
	rfc_count <= rfc_counter_value;
      else if(rfc_count != 8'd0)
	rfc_count <= rfc_count - 1'b1;
   end
   
//******************************************************************************
// rp_count
// An executable command can be issued only after Trp period after a PRECHARGE 
// command is issued. 
//******************************************************************************

   always @( negedge clk ) begin
     if ( rst180_r )
       rp_count <= 3'b000;
     else if ( current_state == PRECHARGE )
       rp_count <= `RP_COUNT_VALUE; 
     else if ( rp_count != 3'b000 )
       rp_count <= rp_count - 1'b1;
   end
//******************************************************************************
// rcd_count
// ACTIVE to READ/WRITE delay - Minimum interval between ACTIVE and READ/WRITE command. 
//******************************************************************************

   always @( negedge clk ) begin
      if ( rst180_r )
        rcd_count <= 3'b000;
      else if ( current_state == ACTIVE )
        rcd_count <= 3'b001; 
      else if ( rcd_count != 3'b000 )
        rcd_count <= rcd_count - 1'b1;
   end


//******************************************************************************
// WR Counter a PRECHARGE command can be applied only after 3 cycles after a 
// WRITE command has finished executing
//******************************************************************************

   always @(negedge clk) begin
      if (rst180_r)
        wr_count <= 3'b000;
      else
        if (dqs_enable_int)
          wr_count <=  wr ;
        else if (wr_count != 3'b000)
          wr_count <= wr_count - 3'b001;
   end

//******************************************************************************
// autoref_count - This counter is used to issue AUTO REFRESH command to 
// the memory for every 7.8125us.
// (Auto Refresh Request is raised for every 7.7 us to allow for termination 
// of any ongoing bus transfer).For example at 166MHz frequency
// autoref_count = refresh_time_period/clock_period =  7.7us/6.02ns = 1279
//******************************************************************************

   always @ (negedge clk) begin
      if (rst180_r == 1'b1)  begin
         rfc_counter_value <= `RFC_COUNT_VALUE;
         ref_freq_cnt      <= `MAX_REF_CNT;
	 autoref_value     <= 1'b0;
      end
      else begin
         rfc_counter_value <= `RFC_COUNT_VALUE;
         ref_freq_cnt      <= `MAX_REF_CNT;
         autoref_value   <= (autoref_count == ref_freq_cnt);
      end
   end

   always @(negedge clk) begin
      if(rst180_r)
        autoref_count <= `MAX_REF_WIDTH'b0;
      else if(autoref_value)
        autoref_count <= `MAX_REF_WIDTH'b0;
      else
        autoref_count <= autoref_count + 1'b1;
   end
   
   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         auto_ref_detect1   <= 1'b0;
         auto_ref1          <= 1'b0;
      end
      else begin
         auto_ref_detect1   <= autoref_value && init_done;
         auto_ref1          <= auto_ref_detect1;
      end
   end

   assign ar_done_p = (ar_done_reg == 1'b1) ? 1'b1 : 1'b0;

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         auto_ref_wait <= 1'b0;
         ar_done  <= 1'b0;
         auto_ref_issued <= 1'b0;
      end
      else begin
         if (auto_ref1 && !auto_ref_wait)
           auto_ref_wait <= 1'b1;
         else if (auto_ref_issued_p)
           auto_ref_wait <= 1'b0;
         else
           auto_ref_wait <= auto_ref_wait;

         ar_done         <= ar_done_p;
         auto_ref_issued <= auto_ref_issued_p;
      end
   end

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         auto_ref_wait1 <= 1'b0;
         auto_ref_wait2 <= 1'b0;
         auto_ref       <= 1'b0;
      end
      else begin
         if (auto_ref_issued_p) begin
            auto_ref_wait1 <= 1'b0;
            auto_ref_wait2 <= 1'b0;
            auto_ref       <= 1'b0;
         end
         else begin
            auto_ref_wait1  <= auto_ref_wait;
            auto_ref_wait2  <= auto_ref_wait1;
            auto_ref        <= auto_ref_wait2;
         end
      end
   end

   assign auto_ref_req = auto_ref_wait;
   assign auto_ref_issued_p = (current_state == AUTO_REFRESH);
   
//******************************************************************************
// Common counter for the Initialization sequence
//******************************************************************************
   always @(negedge clk) begin
      if(rst180_r)
        count6 <= 8'd0;
      else if(init_current_state == INIT_AUTO_REFRESH || init_current_state ==
              INIT_PRECHARGE || init_current_state == INIT_LOAD_MODE_REG)
        count6 <= `RFC_COUNT_VALUE; 
      else if(count6 != 8'd0)
        count6 <= count6 - 1'b1;
      else
        count6 <= 8'd0;
   end

//******************************************************************************
// While doing consecutive READs or WRITEs, the burst_cnt_max value determines
// when the next READ or WRITE command should be issued. burst_cnt_max shows the
// number of clock cycles for each burst. 
// e.g burst_cnt_max = 2 for a burst length of 4
//                   = 4 for a burst length of 8
//******************************************************************************
   assign burst_cnt_max = (burst_length == 3'b010) ? 3'b010 :
                          (burst_length == 3'b011) ? 3'b100 :
                          3'b000;

   always @( negedge clk) begin
      if(rst180_r)
        cas_count <= 3'b000;
      else if(current_state == BURST_READ)
        cas_count <= burst_cnt_max - 1'b1;
      else if(cas_count != 3'b000)
        cas_count <= cas_count - 1'b1;
   end


   always @( negedge clk ) begin
      if(rst180_r)
        wrburst_end_cnt <= 3'b000;
      else if((current_state == FIRST_WRITE) || (current_state == BURST_WRITE))
        wrburst_end_cnt <= burst_cnt_max;
      else if(wrburst_end_cnt != 3'b000)
        wrburst_end_cnt <= wrburst_end_cnt - 1'b1;
   end


   always @ (negedge clk) begin
      if (rst180_r == 1'b1) 
        rdburst_end_1 <= 1'b0;
      else begin
         rdburst_end_2 <= rdburst_end_1;
         if (burst_done == 1'b1) 
           rdburst_end_1 <= 1'b1;
         else
           rdburst_end_1 <= 1'b0;
      end
   end

   assign rdburst_end   = rdburst_end_1 || rdburst_end_2 ;
   
   always @ (negedge clk) begin
      if (rst180_r == 1'b1) 
        wrburst_end_1 <= 1'b0;
      else begin
         wrburst_end_2  <= wrburst_end_1;
         wrburst_end_3  <= wrburst_end_2;
         if  (burst_done == 1'b1)  
           wrburst_end_1 <= 1'b1;
         else
           wrburst_end_1 <= 1'b0;
      end
   end

   assign wrburst_end = wrburst_end_1 || wrburst_end_2 || wrburst_end_3;

//******************************************************************************
// dqs_enable and dqs_reset signals are used to generate DQS signal during write
// data.
//******************************************************************************

   

   assign dqs_enable     = dqs_enable2;
   assign dqs_reset      = dqs_reset2_clk0;

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         dqs_enable_int <= 1'b0;
         dqs_reset_int  <= 1'b0;
      end
      else begin
         dqs_enable_int <= ((current_state == FIRST_WRITE) ||
                            (current_state == BURST_WRITE) ||
                            (wrburst_end_cnt != 3'b000));
         dqs_reset_int  <= (current_state == FIRST_WRITE);
      end
   end

   always @ (posedge clk) begin
      if (rst0_r == 1'b1) begin
         dqs_enable1     <= 1'b0;
         dqs_enable2     <= 1'b0;
         dqs_enable3     <= 1'b0;
         dqs_reset1_clk0 <= 1'b0;
         dqs_reset2_clk0 <= 1'b0;
         dqs_reset3_clk0 <= 1'b0;
      end
      else begin
         dqs_enable1     <= dqs_enable_int;
         dqs_enable2     <= dqs_enable1;
         dqs_enable3     <= dqs_enable2;
         dqs_reset1_clk0 <= dqs_reset_int;
         dqs_reset2_clk0 <= dqs_reset1_clk0;
         dqs_reset3_clk0 <= dqs_reset2_clk0;
      end
   end

//******************************************************************************
//Write Enable signal to the datapath
//******************************************************************************



   always @ (negedge clk) begin
      if (rst180_r == 1'b1)
         write_enable <= 1'b0;
      else if(wrburst_end_cnt != 3'b000)
         write_enable <= 1'b1;
      else
         write_enable <= 1'b0;
   end

   assign cmd_ack = ack_reg;

   FD ack_reg_inst1
     (
      .Q (ack_reg),
      .D (ack_o),
      .C (~clk)
      );


   assign ack_o = ((write_cmd_in == 1'b1) || (write_cmd1 == 1'b1) ||
                   (read_cmd_in == 1'b1) || (read_cmd1 == 1'b1));
   
//******************************************************************************
//  init_done will be asserted when initialization sequence is complete
//******************************************************************************

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         init_memory <= 1'b0;
         init_done   <= 1'b0;
         init_done_r1   <= 1'b0;
      end
      else begin
         init_memory <= init_mem;
         init_done   <= init_done_value && (init_count == 4'b1011);
         init_done_r1   <= init_done;
      end
   end

   //synthesis translate_off 
   always @ (negedge clk) begin
      if (rst180_r == 1'b0)
        if (init_done == 1'b1 && init_done_r1 == 1'b0)
	  $display ("INITIALIZATION_DONE");
   end 
   //synthesis translate_on

   always @ (negedge clk) begin
      if (init_cmd_in) 
         init_pre_count <= 7'b101_0000;
      else 
         init_pre_count <= init_pre_count - 7'h1;
   end

   always @( negedge clk ) begin
      if ( rst180_r )
        init_mem <= 1'b0;
      else if ( init_cmd_in )
        init_mem <= 1'b1;
      else if ( (init_count == 4'b1011) && (count6 == 8'd0 ))
        init_mem <= 1'b0;
      else
        init_mem <= init_mem;
   end

 always @( negedge clk ) begin
      if ( rst180_r )
        init_count  <= 4'b0;
      else if (((init_current_state == INIT_PRECHARGE) || 
		(init_current_state == INIT_LOAD_MODE_REG)
                || (init_current_state == INIT_AUTO_REFRESH))
	       && init_memory == 1'b1)
        init_count    <= init_count + 1'b1;
      else
        init_count    <= init_count;
   end

   assign init_done_value =  (dll_rst_count == 8'b0000_0001) ;


//Counter to count 200 clock cycles When DLL reset is issued during 
//initialization.

   always @( negedge clk ) begin
     if( rst180_r )
       dll_rst_count  <= 8'd0;
     else if(init_count == 4'b0100)
       dll_rst_count  <= 8'd200;
     else if(dll_rst_count != 8'b0000_0001)
       dll_rst_count    <= dll_rst_count - 8'b0000_0001;
     else
       dll_rst_count    <= dll_rst_count;
   end



   assign go_to_active_value =((write_cmd_in == 1'b1) && (accept_cmd_in == 1'b1))
          || ((read_cmd_in == 1'b1) && (accept_cmd_in == 1'b1))
          ? 1'b1 : 1'b0;

   always @ (negedge clk) begin
     if (rst180_r == 1'b1) 
       go_to_active <= 1'b0;
     else 
       go_to_active <= go_to_active_value;
   end


   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         rfc_count_reg   <= 1'b0;
         ar_done_reg     <= 1'b0;
      end
      else begin
         if(rfc_count == 8'd2) 
           ar_done_reg <= 1'b1;
         else
           ar_done_reg <= 1'b0;
         if(ar_done_reg == 1'b1)
           rfc_count_reg <= 1'b1;
         else if(init_done == 1'b1 && init_mem == 1'b0 &&
                 rfc_count == 8'd0)
           rfc_count_reg <= 1'b1;
         else if (auto_ref_issued  == 1'b1)
           rfc_count_reg <= 1'b0;
         else
           rfc_count_reg <= rfc_count_reg;
      end
   end

  

//******************************************************************************
// Initialization state machine
//******************************************************************************

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) 
         init_current_state    <= INIT_IDLE;
      else 
         init_current_state    <= init_next_state;
   end

   always @ (*) begin
      if (rst180_r == 1'b1)
        init_next_state = INIT_IDLE;
      else begin
         case (init_current_state)
           INIT_IDLE : begin
              if (init_memory == 1'b1) begin
                 case (init_count)
                   4'b0000 : begin
                      if(init_pre_count == 7'b000_0001)
                        init_next_state = INIT_PRECHARGE;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b0001 : begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_LOAD_MODE_REG;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b0010 : begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_LOAD_MODE_REG;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b0011 : begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_LOAD_MODE_REG;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b0100 : begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_LOAD_MODE_REG;                      
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b0101 : begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_PRECHARGE;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b0110 : begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_AUTO_REFRESH;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b0111: begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_AUTO_REFRESH;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b1000: begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_LOAD_MODE_REG;
                      else
                        init_next_state = INIT_IDLE;
                   end
                   4'b1001: begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_LOAD_MODE_REG;
                      else
                        init_next_state = init_current_state;
                   end
                   4'b1010: begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_LOAD_MODE_REG;
                      else
                        init_next_state = init_current_state;
                   end
                   4'b1011: begin
                      if (count6 == 8'd0)
                        init_next_state = INIT_IDLE;
                      else
                        init_next_state = init_current_state;
                   end
                   default :
                     init_next_state = INIT_IDLE;
                 endcase
              end
              else
                init_next_state = INIT_IDLE;
           end
           INIT_PRECHARGE :
             init_next_state = INIT_IDLE;
           
           INIT_LOAD_MODE_REG :
             init_next_state = INIT_IDLE;
           
           INIT_AUTO_REFRESH :
             init_next_state = INIT_IDLE;
           
           default :
             init_next_state = INIT_IDLE;
         endcase
      end
   end

//******************************************************************************
// Main state machine
//******************************************************************************

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) 
        current_state    <= IDLE;
      else 
        current_state    <= next_state;
   end


   always @ (*) begin
      if (rst180_r == 1'b1)
        next_state = IDLE;
      else begin
         case (current_state)
           IDLE : begin
              if(~init_mem) begin
                 if ( auto_ref == 1'b1  && rfc_count_reg == 1'b1 
                      && rp_count == 3'd0 )
                   next_state = AUTO_REFRESH;
                 else if (go_to_active == 1'b1)
                   next_state = ACTIVE;
                 else
                   next_state = IDLE;
              end
              else
                next_state = IDLE;
           end
           
           PRECHARGE :
             next_state = IDLE;
           
           AUTO_REFRESH :
             next_state = IDLE;
           
           ACTIVE :
             next_state = ACTIVE_WAIT;
           
           ACTIVE_WAIT : begin
              if(rcd_count == 3'b000  && write_cmd1)
                next_state = FIRST_WRITE;
              else if (rcd_count == 3'b000 && read_cmd3)
                next_state = BURST_READ;
              else
                next_state = ACTIVE_WAIT;
           end
           
           FIRST_WRITE : begin
              next_state = WRITE_WAIT;
           end
           
           WRITE_WAIT : begin
              case(wrburst_end)
                1'b1 :
                  next_state = PRECHARGE_AFTER_WRITE;
                1'b0 : begin
                   if (wrburst_end_cnt == 3'b010)
                     next_state = BURST_WRITE;
                   else
                     next_state = WRITE_WAIT;
                end
                default :
                  next_state = WRITE_WAIT;
              endcase
           end
           BURST_WRITE : begin
              next_state = WRITE_WAIT;
           end
           PRECHARGE_AFTER_WRITE : begin
              next_state = PRECHARGE_AFTER_WRITE_2;
           end
           PRECHARGE_AFTER_WRITE_2 : begin
              if(wr_count == 3'd0 && ras_count == 5'd0)   
                next_state = PRECHARGE;
              else
                next_state = PRECHARGE_AFTER_WRITE_2;
           end
           READ_WAIT : begin
              case(rdburst_end)
                1'b1 :
                  next_state = PRECHARGE_AFTER_WRITE;
                1'b0 : begin
                   if (cas_count == 3'b001)
                     next_state = BURST_READ;
                   else
                     next_state = READ_WAIT;
                end
                default :
                  next_state = READ_WAIT;
              endcase
           end
           BURST_READ : begin
              next_state = READ_WAIT;
           end
           default :
             next_state = IDLE;
         endcase
      end
   end

//******************************************************************************
// Address generation logic
//******************************************************************************
   always @( negedge clk ) begin
      if(rst180_r)
        ddr_address1 <= {`ROW_ADDRESS{1'b0}};
      else if(init_mem)
        case ( init_count )
          4'b0000, 4'b0101 : ddr_address1 <= {`ROW_ADDRESS{1'b0}} |
                                             12'h400;
          4'b0001 : ddr_address1 <= {`ROW_ADDRESS{1'b0}}; 
          4'b0010 : ddr_address1 <= {`ROW_ADDRESS{1'b0}}; 
          4'b0011 : ddr_address1 <= emr; 
          4'b0100 : ddr_address1 <= lmr_dll_rst;
          4'b1000 : ddr_address1 <= lmr_dll_set; 
          4'b1001 : ddr_address1 <= emr | 12'h380; 
          4'b1010 : ddr_address1 <= emr & 12'hc7f;
          default : ddr_address1 <= {`ROW_ADDRESS{1'b0}};
        endcase
      else if ( current_state == PRECHARGE ||
		init_current_state == INIT_PRECHARGE )
        ddr_address1 <= {`ROW_ADDRESS{1'b0}} | 12'h400;
      else if ( current_state == ACTIVE )
        ddr_address1 <= row_address_reg;
      else if ( current_state == BURST_WRITE || current_state == FIRST_WRITE ||
                current_state == BURST_READ )
        ddr_address1 <= column_address_reg1;
      else
        ddr_address1 <= `ROW_ADDRESS'b0;
   end

   always @( negedge clk ) begin
      if ( rst180_r )
        ddr_ba1 <= {{`BANK_ADDRESS-1{1'b0}},1'b0};
      else if ( init_mem )
        case ( init_count )
          4'b0001 : ddr_ba1 <= (`BANK_ADDRESS'b10);
          4'b0010 : ddr_ba1 <= (`BANK_ADDRESS'b11);
          4'b0011 , 4'b1001 , 4'b1010 : ddr_ba1 <= (`BANK_ADDRESS'b01);
          default : ddr_ba1 <= {{`BANK_ADDRESS-1{1'b0}},1'b0};
        endcase
      else if ( current_state == ACTIVE || current_state == FIRST_WRITE ||
                current_state == BURST_WRITE || current_state == BURST_READ)
        ddr_ba1 <= ba_address_reg2;
      else
        ddr_ba1 <= `BANK_ADDRESS'b0;
   end


   always @( negedge clk ) begin
      if ( rst180_r )
        odt_deassert <= 1'b0;
      else if (wrburst_end_3) 
        odt_deassert <= 1'b1;
      else if(!write_cmd3)
        odt_deassert <= 1'b0;
      else
        odt_deassert <= odt_deassert;
   end
   
   assign ddr_odt1 = ( write_cmd3 == 1'b1  && (emr[6]|emr[2]) && !odt_deassert )
			? 1'b1 : 1'b0;  
   
//******************************************************************************
//  Register column address
//******************************************************************************
   always @ (negedge clk) 
      column_address_reg1 <= column_address_reg;

//******************************************************************************
//Pipeline stages for ddr_address and ddr_ba
//******************************************************************************

   always @ (negedge clk) begin
      if (rst180_r == 1'b1) begin
         ddr_odt2  <= 1'b0;
         ddr_rasb2 <= 1'b1;
         ddr_casb2 <= 1'b1;
         ddr_web2  <= 1'b1;
      end
      else begin
         ddr_odt2  <= ddr_odt1;
         ddr_rasb2 <= ddr_rasb1;
         ddr_casb2 <= ddr_casb1;
         ddr_web2  <= ddr_web1;
      end
   end
   
   always @ (negedge clk) begin
      if (rst180_r == 1'b1) 
        ddr_odt_cntrl   <= 1'b0;
      else 
        ddr_odt_cntrl   <= ddr_odt2;
   end

//******************************************************************************
// Control signals to the Memory
//******************************************************************************

   assign ddr_rasb1 = ~((current_state == ACTIVE) || 
			(current_state == PRECHARGE) ||
			(current_state == AUTO_REFRESH) || 
			(init_current_state ==  INIT_PRECHARGE) || 
			(init_current_state == INIT_AUTO_REFRESH)  ||
			(init_current_state == INIT_LOAD_MODE_REG));
   
   assign ddr_casb1 = ~((current_state == BURST_READ) || 
			(current_state == BURST_WRITE)
                        || (current_state == FIRST_WRITE) ||
                        (current_state == AUTO_REFRESH) ||
                        (init_current_state == INIT_AUTO_REFRESH) ||
                        (init_current_state == INIT_LOAD_MODE_REG));
   
   assign ddr_web1  = ~((current_state == BURST_WRITE) || 
			(current_state == FIRST_WRITE) || 
			(current_state == PRECHARGE) ||
			(init_current_state == INIT_PRECHARGE) || 
                        (init_current_state == INIT_LOAD_MODE_REG));

//******************************************************************************
// Register CONTROL SIGNALS outputs
//******************************************************************************

   always @ (negedge clk) begin
      if (rst180_r == 1'b1)
        dqs_div_cascount <= 3'b0;
      else if ((ddr_rasb2 == 1'b1) && (ddr_casb2 == 1'b0) && (ddr_web2 == 1'b1))
	dqs_div_cascount <= burst_cnt_max ;
      else if (dqs_div_cascount != 3'b000)
	dqs_div_cascount <= dqs_div_cascount - 1'b1;
      else
	dqs_div_cascount <= dqs_div_cascount;
   end
   
   always @ (negedge clk) begin
      if (rst180_r == 1'b1)
        dqs_div_rdburstcount <= 3'b000;
      else begin
         if ((dqs_div_cascount == 3'b001) && (burst_length== 3'b010))
           dqs_div_rdburstcount <= 3'b010;
         else if ((dqs_div_cascount == 3'b011) && (burst_length== 3'b011))
           dqs_div_rdburstcount <= 3'b100;
         else begin
            if (dqs_div_rdburstcount != 3'b000)
              dqs_div_rdburstcount <= dqs_div_rdburstcount - 1'b1;
            else
              dqs_div_rdburstcount <= dqs_div_rdburstcount;
         end
      end
   end

   always @ (negedge clk) begin
      if (rst180_r == 1'b1)
        rst_dqs_div_r <= 1'b0;
      else begin
         if (dqs_div_cascount == 3'b001  && burst_length == 3'b010)
           rst_dqs_div_r <= 1'b1;
         else if (dqs_div_cascount == 3'b011  && burst_length == 3'b011)
           rst_dqs_div_r <= 1'b1;
         else if (dqs_div_rdburstcount == 3'b001 && dqs_div_cascount == 3'b000)
           rst_dqs_div_r <= 1'b0;
         else
           rst_dqs_div_r <= rst_dqs_div_r;
      end
   end // always @ (negedge clk)
   
   always @ (negedge clk) 
     rst_dqs_div_r1 <= rst_dqs_div_r;

   always @( negedge clk ) begin
      if(dqs_div_cascount != 3'b0 || dqs_div_rdburstcount != 3'b0 )
        rst_calib <= 1'b1;
      else
        rst_calib <= 1'b0;
   end

   (* IOB = "FORCE" *) FD  rst_iob_out
	    (
	     .Q(rst_dqs_div_int1),
	          .D(rst_dqs_div_r),
	     .C(clk)
	     );


//Read fifo read enable logic, this signal is same as rst_dqs_div_int signal for RDIMM 
//and one clock ahead of rst_dqs_div_int for component or UDIMM OR SODIMM. 

   always @(negedge clk)  
     read_fifo_rden <= rst_dqs_div_r1;

endmodule
