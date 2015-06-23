//*****************************************************************************
// Company: UPT
// Engineer: Oana Boncalo & Alexandru Amaricai
// 
// Create Date:    10:23:39 11/26/2012 
// Design Name: 
// Module Name:    DDR2 user IF address and data generation
// Project Name: 
// Target Devices: 
// Tool versions: 
//Device: Virtex-5
//Purpose:
//   This module instantiates the addr_gen and the data_gen modules. It takes
//   the user data stored in internal FIFOs and gives the data that is to be
//   compared with the read data
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_adr_data_gen #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter COL_WIDTH     = 10,
   parameter DM_WIDTH      = 9,
   parameter DQ_WIDTH      = 72,
   parameter APPDATA_WIDTH = 144,
   parameter ECC_ENABLE    = 0,
   parameter ROW_WIDTH     = 14
   )
  (
   input                                  clk,
   input                                  rst,
   input                                  wr_addr_en,
   input                                  wr_data_en,
	input 											rd_op,
   input                                  rd_data_valid,
	input  [30:0]									bus_if_addr,
   input  [APPDATA_WIDTH-1:0]             bus_if_wr_data,
   input  [(APPDATA_WIDTH/8)-1:0]         bus_if_wr_mask_data,
   output reg                             app_af_wren,
   output [2:0]                           app_af_cmd,
   output [30:0]                          app_af_addr,
   output                                 app_wdf_wren,
   output [APPDATA_WIDTH-1:0]             app_wdf_data,
   output [(APPDATA_WIDTH/8)-1:0]         app_wdf_mask_data
   );
  
  //data
  localparam RD_IDLE_FIRST_DATA = 2'b00;
  localparam RD_SECOND_DATA     = 2'b01;
  localparam RD_THIRD_DATA      = 2'b10;
  localparam RD_FOURTH_DATA     = 2'b11;
  
  //address
  reg             wr_addr_en_r1;
  reg [2:0]       af_cmd_r;//, af_cmd_r0, af_cmd_r1;
  reg             af_wren_r;
  reg             rst_r
                  /* synthesis syn_preserve = 1 */;
  reg             rst_r1
                  /* synthesis syn_maxfan = 10 */;
  reg [5:0]       wr_addr_r;
  reg             wr_addr_en_r0;
  
  //data
  reg [APPDATA_WIDTH-1:0]              app_wdf_data_r;
  reg [(APPDATA_WIDTH/8)-1:0]          app_wdf_mask_data_r;
  wire                                 app_wdf_wren_r;
  reg [(APPDATA_WIDTH/2)-1:0]          rd_data_pat_fall;
  reg [(APPDATA_WIDTH/2)-1:0]          rd_data_pat_rise;
  reg [1:0]                            rd_state;
  wire [APPDATA_WIDTH-1:0]             wr_data;
  reg                                  wr_data_en_r;
  reg [(APPDATA_WIDTH/2)-1:0]          wr_data_fall
                                       /* synthesis syn_maxfan = 2 */;
  reg [(APPDATA_WIDTH/2)-1:0]          wr_data_rise
                                        /* synthesis syn_maxfan = 2 */;
  wire [(APPDATA_WIDTH/8)-1:0]         wr_mask_data;

  //***************************************************************************
	
  // local reset "tree" for controller logic only. Create this to ease timing
  // on reset path. Prohibit equivalent register removal on RST_R to prevent
  // "sharing" with other local reset trees (caution: make sure global fanout
  // limit is set to larger than fanout on RST_R, otherwise SLICES will be
  // used for fanout control on RST_R.
  always @(posedge clk) begin
    rst_r  <= rst;
    rst_r1 <= rst_r;
  end
// register backend enables / FIFO enables
  // write enable for Command/Address FIFO is generated 1 CC after WR_ADDR_EN
  always @(posedge clk)
    if (rst_r1) begin
      app_af_wren   <= 1'b0;
    end else begin
      app_af_wren   <= wr_addr_en;
    end

  always @ (posedge clk)
    if (rst_r1)
      wr_addr_r <= 0;
    else if (wr_addr_en && (rd_op == 1'b0))
      wr_addr_r <= bus_if_addr;  

	assign app_af_addr = wr_addr_r;
	assign app_af_cmd = af_cmd_r;
	
	always @ (posedge clk)
	begin
		af_cmd_r  <= 0;
		if (rd_op)
			af_cmd_r <= 3'b001;
	end


	//data
  assign app_wdf_data        = wr_data;
  assign app_wdf_mask_data   = wr_mask_data;
  // inst ff for timing
  FDRSE ff_wdf_wren
    (
     .Q   (app_wdf_wren),
     .C   (clk),
     .CE  (1'b1),
     .D   (wr_data_en), 
     .R   (1'b0),
     .S   (1'b0)
     );

  assign wr_data      = {wr_data_fall, wr_data_rise};
  assign wr_mask_data = bus_if_wr_mask_data;
  
  //data latching
  //synthesis attribute max_fanout of wr_data_fall is 2
  //synthesis attribute max_fanout of wr_data_rise is 2
  always @(posedge clk) 
  begin
    if (rst_r1) 
		 begin
			wr_data_rise <= {(APPDATA_WIDTH/2){1'bx}};
			wr_data_fall <= {(APPDATA_WIDTH/2){1'bx}};
		 end 
	 else 
		 if (wr_data_en) 
		 begin
			wr_data_rise <= bus_if_wr_data[(APPDATA_WIDTH/2)-1:0]; 
			wr_data_fall <= bus_if_wr_data[APPDATA_WIDTH-1:(APPDATA_WIDTH/2)];
		 end
	end
	

endmodule
