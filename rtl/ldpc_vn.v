//-------------------------------------------------------------------------
//
// File name    :  ldpc_vn.v
// Title        :
//              :
// Purpose      : Variable node holder/message calculator.  Loads llr
//              : data serially, and controls RAM's.  This module is
//              : written to be as compact as possible, since it is
//              : instantiated a large number of times.  Some outputs,
//              : especially RAM controls, are not registered.
//
// ----------------------------------------------------------------------
// Revision History :
// ----------------------------------------------------------------------
//   Ver  :| Author   :| Mod. Date   :| Changes Made:
//   v1.0  | JTC      :| 2008/07/02  :|
// ----------------------------------------------------------------------
`timescale 1ns/10ps

module ldpc_vn #(
  parameter FOLDFACTOR     = 1,
  parameter LLRWIDTH       = 6
)(
  input clk,
  input rst,

  // LLR I/O
  input                   llr_access,
  input[7+FOLDFACTOR-1:0] llr_addr,
  input                   llr_din_we,
  input[LLRWIDTH-1:0]     llr_din,
  output[LLRWIDTH-1:0]    llr_dout,

  // message control
  input                   iteration,
  input                   first_half,
  input                   first_iteration,  // ignore upmsgs
  input                   we_vnmsg,
  input                   disable_vn,
  input[7+FOLDFACTOR-1:0] addr_vn,

  // message I/O
  input[LLRWIDTH-1:0]  sh_msg,
  output[LLRWIDTH-1:0] vn_msg,

  // Attached RAM, holds iteration number, original LLR and message sum
  output[7+FOLDFACTOR-1:0] vnram_wraddr,
  output[7+FOLDFACTOR-1:0] vnram_rdaddr,
  output                   upmsg_we,
  output[2*LLRWIDTH+4:0]   upmsg_din,
  input[2*LLRWIDTH+4:0]    upmsg_dout
);

// Split RAM outputs
wire[LLRWIDTH-1:0] llr_orig;
wire[LLRWIDTH+3:0] stored_msg_sum;
wire               stored_iteration;

assign llr_orig         = upmsg_dout[LLRWIDTH-1:0];
assign stored_msg_sum   = upmsg_dout[2*LLRWIDTH+3:LLRWIDTH];
assign stored_iteration = upmsg_dout[2*LLRWIDTH+4];

/************************************************************
 * Add 1's complement numbers, assume overflow not possible *
 ************************************************************/
function[LLRWIDTH+3:0] AddNewMsg( input[LLRWIDTH+3:0] a,
                                  input[LLRWIDTH-1:0] b );
  reg               signa;
  reg               signb;
  reg[LLRWIDTH+2:0] maga;
  reg[LLRWIDTH+2:0] magb;
  
  reg[LLRWIDTH+2:0] sum;
  reg[LLRWIDTH+2:0] diffa;
  reg[LLRWIDTH+2:0] diffb;
  
  reg               add;
  reg               b_big;
  reg               sign;
  reg[LLRWIDTH+3:0] result;
  
begin
  // strip out magnitude and sign bits
  signa = a[LLRWIDTH+3];
  signb = b[LLRWIDTH-1];
  maga  = a[LLRWIDTH+2:0];
  magb  = { 4'b0000, b[LLRWIDTH-2:0] };

  // basic calculations
  sum   = maga + magb;
  diffa = maga - magb;
  diffb = magb - maga;
  
  // control bits
  add   = signa==signb;
  b_big = maga<magb;
  sign  = b_big ? signb : signa;

  if( add )
    result = { sign, sum };
  else if( b_big )
    result = { sign, diffb };
  else
    result = { sign, diffa };

  AddNewMsg = result;
end
endfunction

/*************************************************
 * Saturate message to fewer bits before passing *
 *************************************************/
function[LLRWIDTH-1:0] SaturateMsg( input[LLRWIDTH+3:0] a );
begin
  if( a[LLRWIDTH+2:LLRWIDTH-1] != 4'b0000 )
    SaturateMsg[LLRWIDTH-2:0] = { (LLRWIDTH-1){1'b1} };
  else
    SaturateMsg[LLRWIDTH-2:0] = a[LLRWIDTH-2:0];
  
  SaturateMsg[LLRWIDTH-1] = a[LLRWIDTH+3];
end
endfunction

/********************************************
 * Delays to align controls with RAM output *
 ********************************************/
localparam RAM_LATENCY = 2;

integer loopvar1;

reg[7+FOLDFACTOR-1:0] vnram_rdaddr_int;

reg[LLRWIDTH-1:0]     sh_msg_del[0:RAM_LATENCY-1];
reg                   we_vnmsg_del[0:RAM_LATENCY-1];
reg[7+FOLDFACTOR-1:0] vnram_rdaddr_del[0:RAM_LATENCY-1];
reg                   disable_del[0:RAM_LATENCY-1];    

wire[LLRWIDTH-1:0]     sh_msg_aligned_ram;
wire                   we_vnmsg_aligned_ram;
wire[7+FOLDFACTOR-1:0] vnram_rdaddr_aligned_ram;
wire                   disable_aligned_ram;

reg recycle_result;

// mux in alternative address for final read-out
assign vnram_rdaddr = vnram_rdaddr_int;
always @( * ) vnram_rdaddr_int <= #1 llr_access ? llr_addr : addr_vn;

assign sh_msg_aligned_ram       = sh_msg_del[RAM_LATENCY-1];
assign we_vnmsg_aligned_ram     = we_vnmsg_del[RAM_LATENCY-1];
assign vnram_rdaddr_aligned_ram = vnram_rdaddr_del[RAM_LATENCY-1];
assign disable_aligned_ram      = disable_del[RAM_LATENCY-1];    

always @( posedge rst, posedge clk )
  if( rst )
  begin
    for( loopvar1=0; loopvar1<RAM_LATENCY; loopvar1=loopvar1+1 )
    begin
      sh_msg_del[loopvar1]       <= 0;
      we_vnmsg_del[loopvar1]     <= 0;
      vnram_rdaddr_del[loopvar1] <= 0;
      disable_del[loopvar1]      <= 0;
    end
    recycle_result <= 0;
  end
  else
  begin
    sh_msg_del[0]        <= sh_msg;
    we_vnmsg_del[0]      <= we_vnmsg;
    vnram_rdaddr_del[0]  <= vnram_rdaddr_int; 
    disable_del[0]       <= disable_vn;

    for( loopvar1=1; loopvar1<RAM_LATENCY; loopvar1=loopvar1+1 )
    begin
      sh_msg_del[loopvar1]       <= sh_msg_del[loopvar1 -1];
      we_vnmsg_del[loopvar1]     <= we_vnmsg_del[loopvar1 -1];
      vnram_rdaddr_del[loopvar1] <= vnram_rdaddr_del[loopvar1 -1];
      disable_del[loopvar1]      <= disable_del[loopvar1 -1];
    end
    
    // Use previous result rather than the RAM contents for two adjacent
    // writes to the same address
    recycle_result <= (vnram_rdaddr_aligned_ram==vnram_rdaddr_del[RAM_LATENCY-2]) &
                      we_vnmsg_aligned_ram & we_vnmsg_del[RAM_LATENCY-2];
  end

/************************
 * Message calculations *
 ************************/
// Add initial LLR to message offset (except for first iteration)
reg[LLRWIDTH+3:0]  msg0_norst;
wire[LLRWIDTH+3:0] msg0;
reg[LLRWIDTH-1:0]  msg1;

wire start_new_upmsg;
reg  rst_msg0;

wire[LLRWIDTH+3:0] msg_sum;

reg[LLRWIDTH+3:0] msg_sum_reg;

// Add upmsg to the result, except:
// - during first iteration, since no upmsg exists
// - first message of each new iteration, where upmsg needs to be reset
assign start_new_upmsg = (stored_iteration!=iteration) & we_vnmsg_aligned_ram;

assign msg0 = rst_msg0 ? 0 : msg0_norst;

always @( posedge clk, posedge rst )
  if( rst )
  begin
    msg0_norst  <= 0;
    rst_msg0    <= 0;
    msg1        <= 0;
    msg_sum_reg <= 0;
  end
  else
  begin
    // msg0 = sum of received upstream messages
    // clear msg0 when beginning a new set of upstream messages
    msg0_norst <= recycle_result ? msg_sum : stored_msg_sum;
    rst_msg0   <= start_new_upmsg & ~recycle_result;
    
    msg1 <= (llr_access || first_half) ? llr_orig : sh_msg_aligned_ram;
    
    msg_sum_reg <= msg_sum;
  end

// When creating downstream messages, or preparing final result:
//      msg_sum = llr + sum of messages
// When receiving upstream messages:
//      msg_sum = new message + sum of messages
assign msg_sum = AddNewMsg( msg0, msg1 );

/****************************************
 * Delay controls to align with msg_sum *
 ****************************************/
localparam CALC_LATENCY = 2;

integer loopvar2;

reg                   we_vnmsg_del2[0:RAM_LATENCY-1];
reg[7+FOLDFACTOR-1:0] vnram_rdaddr_del2[0:RAM_LATENCY-1];
reg[LLRWIDTH-1:0]     llrram_dout_del2[0:RAM_LATENCY-1];
reg                   disable_del2[0:RAM_LATENCY-1];    

wire                   we_vnmsg_aligned_msg;
wire[7+FOLDFACTOR-1:0] vnram_rdaddr_aligned_msg;
wire[LLRWIDTH-1:0]     llrram_dout_aligned_msg;
wire                   disable_aligned_msg;

assign we_vnmsg_aligned_msg     = we_vnmsg_del2[RAM_LATENCY-1];
assign vnram_rdaddr_aligned_msg = vnram_rdaddr_del2[RAM_LATENCY-1];
assign llrram_dout_aligned_msg  = llrram_dout_del2[RAM_LATENCY-1];
assign disable_aligned_msg      = disable_del2[RAM_LATENCY-1];    

always @( posedge rst, posedge clk )
  if( rst )
  begin
    for( loopvar2=0; loopvar2<RAM_LATENCY; loopvar2=loopvar2+1 )
    begin
      we_vnmsg_del2[loopvar2]     <= 0;
      vnram_rdaddr_del2[loopvar2] <= 0;
      llrram_dout_del2[loopvar2]  <= 0;
      disable_del2[loopvar2]      <= 0;
    end
  end
  else
  begin
    we_vnmsg_del2[0]      <= we_vnmsg_aligned_ram;
    vnram_rdaddr_del2[0]  <= vnram_rdaddr_aligned_ram; 
    llrram_dout_del2[0]   <= llr_orig;
    disable_del2[0]       <= disable_aligned_ram;

    for( loopvar2=1; loopvar2<RAM_LATENCY; loopvar2=loopvar2+1 )
    begin
      we_vnmsg_del2[loopvar2]     <= we_vnmsg_del2[loopvar2 -1];
      vnram_rdaddr_del2[loopvar2] <= vnram_rdaddr_del2[loopvar2 -1];
      llrram_dout_del2[loopvar2]  <= llrram_dout_del2[loopvar2 -1];
      disable_del2[loopvar2]      <= disable_del2[loopvar2 -1];
    end
  end

/*******************************
 * Write message totals to RAM *
 *******************************/
reg[7+FOLDFACTOR-1:0] vnram_wraddr_int;
reg[LLRWIDTH-1:0]     new_llr;
reg                   new_iteration;
reg[LLRWIDTH+3:0]     new_msg_sum;
reg                   upmsg_we_int;

assign vnram_wraddr = vnram_wraddr_int;
assign upmsg_din    = { new_iteration, new_msg_sum, new_llr };
assign upmsg_we     = upmsg_we_int;

always @( posedge rst, posedge clk )
  if( rst )
  begin
    vnram_wraddr_int <= 0;
    new_llr          <= 0;
    new_msg_sum      <= 0;
    new_iteration    <= 0;
    upmsg_we_int     <= 1;
  end
  else
  begin
    // mux and register outputs
    vnram_wraddr_int <= #1 llr_access ? llr_addr : vnram_rdaddr_aligned_msg;
    new_llr          <= #1 llr_access ? llr_din  : llrram_dout_aligned_msg;
    new_msg_sum      <= #1 llr_access ? 0        : msg_sum_reg;
    
    new_iteration    <= #1 llr_access | iteration;
    
    upmsg_we_int     <= #1 ~(llr_din_we | (we_vnmsg_aligned_msg & ~disable_aligned_msg));
  end

/*****************************************************************
 * Saturate message to fewer bits for message passing and output *
 *****************************************************************/
reg[LLRWIDTH-1:0] vn_msg_int;

assign llr_dout = vn_msg_int;
assign vn_msg   = vn_msg_int;

always @( posedge rst, posedge clk )
  if( rst )
    vn_msg_int <= 0;
  else
    vn_msg_int <= SaturateMsg(msg_sum_reg);

endmodule

