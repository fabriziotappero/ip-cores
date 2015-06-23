
// Copyright 2004-2005 Openchip
// http://www.openchip.org

`include "virtex_bitstream_const.v"

module xilinx_fpga_config_int(
  // Power on reset (simulat power on reset)
  por,
  sys_clk100,
  // Xilinx Config Interface

  cclk_I, cclk_T, cclk_O,
  init_I, init_T, init_O,

  din,
  prog_b,
  done,
  rdwr_b,
  cs_b,

  // internal registers
  CMD, COR, FAR,
  
  // config input
  M0, M1, M2,
  // JTAG port
  tclk, tdi, tdo, tms,



  //
  trace1,
  trace2
  );


input por;
input sys_clk100;

input  cclk_I;
output cclk_O;
output cclk_T;

input init_I;
output init_T;
output init_O;

input din;
input prog_b;
input rdwr_b;
input cs_b;

output done;




output [3:0] CMD;
output [31:0] COR;
output [31:0] FAR;
input  M0;
input  M1;
input  M2;
input  tclk;
input  tdi;
output tdo;
input  tms;


//
output trace1;
output trace2;


wire init;
assign init = init_I & init_O;

//
// internal reset is high when init and prog are both low
// or on Power On Reset
//
wire internal_reset;
assign internal_reset = !prog_b | !por; 



//
// Clear Int memory, as long as prog_b is low, and some time after it (delay)
//
reg config_memory_cleared;
reg [7:0] config_clear_cnt;

always @(posedge sys_clk100) 
  if (internal_reset)
    config_clear_cnt <= 8'b00000000;
  else
    config_clear_cnt <= config_clear_cnt + 8'b00000001;

always @(posedge sys_clk100) 
  if (internal_reset)
    config_memory_cleared <= 1'b0;
  else
    if (config_clear_cnt[7])
      config_memory_cleared <= 1'b1;

//
// Latch M0, M1, M2
//
reg M_latched;
reg [2:0] M_r;

// have we latched M0, M1, M2 ?
always @(posedge sys_clk100) 
  if (internal_reset)
    M_latched <= 1'b0;
  else
    if (config_memory_cleared)
       M_latched <= 1'b1;

// Latch M0, M1, M2
always @(posedge sys_clk100) 
  if (internal_reset)
    M_r <= 3'b0;
  else
    if (!M_latched & config_memory_cleared)
      M_r <= {M2, M1, M0};


// 
assign init_0 = M_latched;
assign init_T = !M_latched;


//
// Start Master mode CCLK !
//

reg enable_internal_cclk;

always @(posedge sys_clk100) 
  if (internal_reset)
    enable_internal_cclk <= 1'b0;
  else
    if (M_latched)
      enable_internal_cclk <= 1'b1;
//
//
//
wire mode_master_serial;
wire mode_slave_serial;
wire mode_master_parallel;
wire mode_slave_parallel;
wire mode_jtag;

assign mode_master_serial   = (M_r == 3'b000) & M_latched;
assign mode_slave_serial    = (M_r == 3'b000) & M_latched;
assign mode_master_parallel = (M_r == 3'b000) & M_latched;
assign mode_slave_parallel  = (M_r == 3'b000) & M_latched;
assign mode_jtag            = (M_r == 3'b000) & M_latched;







//
// Master CCLK prescaler
//
reg [7:0] prescaler;
wire cclk_master;

always @(posedge sys_clk100) 
  prescaler <= prescaler + 8'b00000001;

assign cclk_master = prescaler[2];


//
// Master or Slave Clock select
//
wire master_clock;
assign master_clock = 1'b1;

assign cclk = master_clock ? cclk_master : cclk_I;


//
// only when running!! before memory clear no CCLK out !
//
assign cclk_O = enable_internal_cclk ? cclk_master : 1'b0;
assign cclk_T = enable_internal_cclk;




    





//
// 32 bit shift register to
// 
reg [31:0] sr;

always @(posedge cclk or posedge internal_reset)
  if (internal_reset)
    sr <= 32'h00000000;
  else 
    begin
      sr[0] <= din; 	
	 sr[1] <= sr[0];
	 sr[2] <= sr[1];	
	 sr[3] <= sr[2];
	 sr[4] <= sr[3];	
	 sr[5] <= sr[4];
	 sr[6] <= sr[5];	
	 sr[7] <= sr[6];
	 sr[8] <= sr[7];	
	 sr[9] <= sr[8];
	 sr[10] <= sr[9];	
	 sr[11] <= sr[10];
	 sr[12] <= sr[11];	
	 sr[13] <= sr[12];
	 sr[14] <= sr[13];	
	 sr[15] <= sr[14];
	 sr[16] <= sr[15];
	 sr[17] <= sr[16];	
	 sr[18] <= sr[17];
	 sr[19] <= sr[18];	
	 sr[20] <= sr[19];
	 sr[21] <= sr[20];	
	 sr[22] <= sr[21];
	 sr[23] <= sr[22];	
	 sr[24] <= sr[23];
	 sr[25] <= sr[24];	
	 sr[26] <= sr[25];
	 sr[27] <= sr[26];	
	 sr[28] <= sr[27];
	 sr[29] <= sr[28];	
	 sr[30] <= sr[29];
      sr[31] <= sr[30];	
    end

//
// Detect Align SYNC
//
wire sync_det;

assign syn_det = sr[31:0] == 32'hAA995566;

reg syn_det_ok;

always @(posedge cclk or posedge internal_reset)
  if (internal_reset)
    syn_det_ok <= 1'b0;
  else 
    if (syn_det)
      syn_det_ok <= 1'b1;


//
// count 32 bits for each word
//
reg [4:0] shift_cnt32;

always @(posedge cclk)
  if (!syn_det_ok)
    shift_cnt32 <= 5'b00000;
  else 
    shift_cnt32 <= shift_cnt32 + 5'b00001;

//
// strobe 32 bit words
//
wire word_stb;

assign word_stb = shift_cnt32 == 5'b11111;

//
//
//
reg [31:0] header;
//
// Statemachine to track latches to the header
//
always @(posedge cclk)
  if (!syn_det_ok)
    header <= 32'h00000000;
  else if (word_stb)
    header <= sr;


//
// Operation Read or Write
//
wire header_op_write;
wire header_op_read;

assign header_op_write = header[28:27] == `VIRTEX_CFG_OP_WRITE;
assign header_op_read =  header[28:27] == `VIRTEX_CFG_OP_READ;


// Command header field
wire header_type_command;
wire header_type_large_block;

assign header_type_command = header[31:29] == 3'b001;
assign header_type_large_block = header[31:29] == 3'b010;

wire command_header_stb;
assign command_header_stb = header_type_command & word_stb;

//
// Word Counter
//
reg [19:0] WC;



//
// write to config register
//
wire cfg_write_stb;
assign cfg_write_stb = header_type_command & header_op_write & word_stb;


//
// Write strobes to registers
//


// CMD Register is target
wire write_CMD;
assign write_CMD = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_CMD);


// COR Option Register is target
wire write_COR;
assign write_COR = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_COR);

// FAR Register is target
wire write_FAR;
assign write_FAR = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_FAR);

wire write_FLR;
assign write_FLR = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_FLR);

wire write_CRC;
assign write_CRC = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_CRC);

wire write_CTL;
assign write_CTL = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_CTL);

wire write_MASK;
assign write_MASK = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_MASK);

wire write_STAT;
assign write_STAT = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_STAT);

wire write_FDRI;
assign write_FDRI = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_FDRI);


wire write_RES_E;
assign write_RES_E = cfg_write_stb & (header[16:13]==`VIRTEX_CFG_REG_RES_E);

//
// 4 Bit CMD register
//
reg [3:0] CMD;
//
// Write to CMD latch value written
//
always @(posedge cclk or posedge internal_reset)
  if (internal_reset)
    CMD <= 4'b0000;
  else
    if (write_CMD) 
      CMD <= sr[3:0];
//
// Config states (value in CMD)
//
wire cfg_state_START;
assign cfg_state_START = CMD == `VIRTEX_CFG_CMD_START;

wire cfg_state_RCRC;
assign cfg_state_RCRC = CMD == `VIRTEX_CFG_CMD_RCRC;


//
// 31 Bit COR register
//
reg [31:0] COR;
//
// Write to CMD latch value written
//
always @(posedge cclk or posedge internal_reset)
  if (internal_reset)
    COR <= 31'h00000000;
  else
    if (write_COR) 
      COR <= sr[3:0];

//
// 31 Bit FAR register
//
reg [31:0] FAR;
//
// Write to CMD latch value written
//
always @(posedge cclk or posedge internal_reset)
  if (internal_reset)
    FAR <= 31'h00000000;
  else
    if (write_FAR) 
      FAR <= sr[3:0];





//
// Large Block Count
//


wire write_LBC;
assign write_LBC = header_type_large_block & word_stb;





//
// CRC
//

//
//
// holds CRC as written with WCFG CRC 
reg [15:0] CRC_from_cfg;


always @(posedge cclk or posedge internal_reset)
  if (internal_reset)
    CRC_from_cfg <= 16'h0000;
  else if (write_CRC) 
    CRC_from_cfg[15:0] <= sr[15:0];  


//assign trace_sync_found = sr[15:0] == 16'h55AA;

// Virtex/Spartan SYNC word    
assign trace1 = cfg_state_START;

assign done = cfg_state_START;

assign trace2 = 
  write_LBC |
  write_CMD | 
  write_COR | 
  write_CRC | 
  write_FLR | 
  write_FAR |
  write_CTL | 
  write_STAT | 
  write_FDRI | 

  write_RES_E |
  write_MASK;


endmodule
