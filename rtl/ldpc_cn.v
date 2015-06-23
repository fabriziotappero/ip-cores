//-------------------------------------------------------------------------
//
// File name    :  ldpc_cn.v
// Title        :
//              :
// Purpose      : Check node holder/message calculator.  Stores the sign
//              : of each received message, along with
//
// ----------------------------------------------------------------------
// Revision History :
// ----------------------------------------------------------------------
//   Ver  :| Author   :| Mod. Date   :| Changes Made:
//   v1.0  | JTC      :| 2008/07/02  :|
// ----------------------------------------------------------------------
`timescale 1ns/10ps

module ldpc_cn #(
  parameter FOLDFACTOR     = 1,
  parameter LLRWIDTH       = 6
)(
  input clk,
  input rst,

  // clear RAM iteration count at start-up
  input      llr_access,
  input[7:0] llr_addr,
  input      llr_din_we,

  // message I/O
  input                   iteration,         // toggle each iteration
  input                   first_half,
  input                   first_iteration,   // don't need to subtract-off previous message!
  input                   cn_we,
  input                   cn_rd,
  input                   disable_cn, // parity mix disables one node
  input[7+FOLDFACTOR-1:0] addr_cn,
  input[LLRWIDTH-1:0]     sh_msg,
  output[LLRWIDTH-1:0]    cn_msg,

  // Attached MSG RAM, 135xMSG_WIDTH
  output                         dnmsg_we,
  output[7+FOLDFACTOR-1:0]       dnmsg_wraddr,
  output[7+FOLDFACTOR-1:0]       dnmsg_rdaddr,
  output[17+4*(LLRWIDTH-1)+31:0] dnmsg_din,
  input[17+4*(LLRWIDTH-1)+31:0]  dnmsg_dout
);

// Detect illegal writes
// synthesis translate_off
integer accesses[0:5];
reg     a_run;
integer temp_loopvar;

always @( posedge rst, posedge clk )
  if( rst )
    for( temp_loopvar=0; temp_loopvar<6; temp_loopvar=temp_loopvar+1 )
      accesses[temp_loopvar] = -1;
  else
  begin
    for( temp_loopvar=5; temp_loopvar>0; temp_loopvar=temp_loopvar-1 )
    begin
      accesses[temp_loopvar] = accesses[temp_loopvar-1];
      if( !(cn_we|cn_rd) )
        accesses[0] = -1;
      else
        accesses[0] = addr_cn;
    end
    
    a_run = 1;
    
    for( temp_loopvar=1; temp_loopvar<6; temp_loopvar=temp_loopvar+1 )
    begin
      a_run = a_run & (accesses[temp_loopvar]==addr_cn);
      if( !a_run && (cn_we|cn_rd) && (accesses[temp_loopvar]==addr_cn) )
        $display( "%0t: Bad access, addresses %0d", $time(), addr_cn );
     end
  end
// synthesis translate_on

assign dnmsg_rdaddr = llr_access ? llr_addr : addr_cn;

/***********************************
 * Calc message/update message RAM *
 * Combine 1's complement numbers  *
 * Saturate to one bit fewer than  *
 * input width                     *
 ***********************************/
function[LLRWIDTH-1:0] SubSaturate( input[LLRWIDTH-1:0] a,
                                    input[LLRWIDTH-1:0] b );
  reg[LLRWIDTH-1:0] sum;
  reg[LLRWIDTH-2:0] diffa;
  reg[LLRWIDTH-2:0] diffb;
  reg[LLRWIDTH-3:0] sat_sum;
  reg[LLRWIDTH-3:0] sat_diffa;
  reg[LLRWIDTH-3:0] sat_diffb;
  reg               add;
  reg               b_big;
  reg               sign;
  reg[LLRWIDTH-1:0] result;
begin
  // basic calculations
  sum   = {1'b0, a[LLRWIDTH-2:0]} + {1'b0, b[LLRWIDTH-2:0]};
  diffa = a[LLRWIDTH-2:0] - b[LLRWIDTH-2:0];
  diffb = b[LLRWIDTH-2:0] - a[LLRWIDTH-2:0];

  // saturate
  if( sum[LLRWIDTH-1:LLRWIDTH-2]!=2'b00  )
    sat_sum = { (LLRWIDTH-2){1'b1} };
  else
    sat_sum = sum[LLRWIDTH-3:0];

  if( diffa[LLRWIDTH-2]  )
    sat_diffa = { (LLRWIDTH-2){1'b1} };
  else
    sat_diffa = diffa[LLRWIDTH-3:0];

  if( diffb[LLRWIDTH-2]  )
    sat_diffb = { (LLRWIDTH-2){1'b1} };
  else
    sat_diffb = diffb[LLRWIDTH-3:0];

  // control bits
  add   = a[LLRWIDTH-1]!=b[LLRWIDTH-1];
  b_big = a[LLRWIDTH-2:0]<b[LLRWIDTH-2:0];
  sign  = b_big ? ~b[LLRWIDTH-1] : a[LLRWIDTH-1];

  if( add )
    result = { sign, 1'b0, sat_sum };
  else if( b_big )
    result = { sign, 1'b0, sat_diffb };
  else
    result = { sign, 1'b0, sat_diffa };

  SubSaturate = result;
end
endfunction

/**************************************
 * Align some signals with RAM output *
 **************************************/
localparam RAM_LATENCY = 2;

integer loopvar1;

reg                   cn_rd_del[0:RAM_LATENCY-1];
reg                   cn_we_del[0:RAM_LATENCY-1];
reg[LLRWIDTH-1:0]     sh_msg_del[0:RAM_LATENCY-1];
reg[7+FOLDFACTOR-1:0] addr_cn_del[0:RAM_LATENCY-1];

reg repeat_access;

wire                   cn_rd_aligned_ram;
wire                   cn_we_aligned_ram;
wire[LLRWIDTH-1:0]     sh_msg_aligned_ram;
wire[7+FOLDFACTOR-1:0] addr_cn_aligned_ram;

assign cn_rd_aligned_ram   = cn_rd_del[RAM_LATENCY-1];
assign cn_we_aligned_ram   = cn_we_del[RAM_LATENCY-1];
assign sh_msg_aligned_ram  = sh_msg_del[RAM_LATENCY-1];
assign addr_cn_aligned_ram = addr_cn_del[RAM_LATENCY-1];

always @( posedge rst, posedge clk )
  if( rst )
  begin
    for( loopvar1=0; loopvar1<RAM_LATENCY; loopvar1=loopvar1+1 )
    begin
      cn_rd_del[loopvar1]   <= 0;
      cn_we_del[loopvar1]   <= 0;
      sh_msg_del[loopvar1]  <= 0;
      addr_cn_del[loopvar1] <= 0;
    end
    repeat_access <= 0;
  end
  else
  begin
    cn_rd_del[0]   <= cn_rd & ~disable_cn;
    cn_we_del[0]   <= cn_we & ~disable_cn;
    sh_msg_del[0]  <= sh_msg;
    addr_cn_del[0] <= addr_cn;

    for( loopvar1=1; loopvar1<RAM_LATENCY; loopvar1=loopvar1+1 )
    begin
      cn_rd_del[loopvar1]   <= cn_rd_del[loopvar1 -1];
      cn_we_del[loopvar1]   <= cn_we_del[loopvar1 -1];
      sh_msg_del[loopvar1]  <= sh_msg_del[loopvar1 -1];
      addr_cn_del[loopvar1] <= addr_cn_del[loopvar1 -1];
    end

    repeat_access <= (addr_cn_del[RAM_LATENCY-1]==addr_cn_del[RAM_LATENCY-2]) &&
                     ((cn_we_del[RAM_LATENCY-1] && cn_we_del[RAM_LATENCY-2]) ||
                      (cn_rd_del[RAM_LATENCY-1] && cn_rd_del[RAM_LATENCY-2]));
  end

/****************************
 * Pipe stage 0:            *
 * Register bits out of RAM *
 ****************************/
wire start_over;
wire switch_up;

reg[4:0]          old_leastpos;
reg[4:0]          old_last_leastpos;
reg               old_sign_result;
reg[4:0]          old_count;
reg[LLRWIDTH-2:0] old_least_llr;
reg[LLRWIDTH-2:0] old_nextleast_llr;
reg[LLRWIDTH-2:0] old_last_least_llr;
reg[LLRWIDTH-2:0] old_last_nextleast_llr;
reg               old_last_sign_result;
reg[29:0]         old_signs;

reg[LLRWIDTH-1:0] sh_msg_aligned_old;
reg               start_over_aligned_old;
reg               repeat_access_aligned_old;
reg               cn_we_aligned_old;

// restart calculations and count if RAM's iteration != controller's iteration
assign start_over = (iteration!=dnmsg_dout[0]) & !repeat_access;

// restart count when switching from downstream to upstream messages
assign switch_up  = ~first_half & ~dnmsg_dout[1] & !repeat_access;

always @( posedge clk, posedge rst )
  if( rst )
  begin
    old_count                 <= 0;
    old_leastpos              <= 0;
    old_last_leastpos         <= 0;
    old_sign_result           <= 0;
    old_least_llr             <= 0;
    old_nextleast_llr         <= 0;
    old_last_least_llr        <= 0;
    old_last_nextleast_llr    <= 0;
    old_last_sign_result      <= 0;
    old_signs                 <= 0;
    sh_msg_aligned_old        <= 0;
    start_over_aligned_old    <= 0;
    cn_we_aligned_old         <= 0;
    repeat_access_aligned_old <= 0;
  end
  else
  begin
    if( repeat_access )
      old_count <= old_count + 1;
    else
      old_count <= (start_over | switch_up) ? 0 : dnmsg_dout[16:12];

    old_leastpos           <= dnmsg_dout[6:2];
    old_last_leastpos      <= dnmsg_dout[11:7];
    old_least_llr          <= dnmsg_dout[16 +1*(LLRWIDTH-1) -: LLRWIDTH-1];
    old_nextleast_llr      <= dnmsg_dout[16 +2*(LLRWIDTH-1) -: LLRWIDTH-1];
    old_last_least_llr     <= dnmsg_dout[16 +3*(LLRWIDTH-1) -: LLRWIDTH-1];
    old_last_nextleast_llr <= dnmsg_dout[16 +4*(LLRWIDTH-1) -: LLRWIDTH-1];
    old_sign_result        <= dnmsg_dout[16 +4*(LLRWIDTH-1)+1];
    old_last_sign_result   <= dnmsg_dout[16 +4*(LLRWIDTH-1)+2];
    old_signs              <= dnmsg_dout[16 +4*(LLRWIDTH-1)+32 -: 30];

    sh_msg_aligned_old        <= sh_msg_aligned_ram;
    start_over_aligned_old    <= start_over;
    cn_we_aligned_old         <= cn_we_aligned_ram;
    repeat_access_aligned_old <= repeat_access;
  end

/***************************
 * Pipe 1a:                *
 * Create outgoing message *
 ***************************/
reg[LLRWIDTH-1:0] cn_msg_int;

assign cn_msg = cn_msg_int;

always @( posedge rst, posedge clk )
  if( rst )
    cn_msg_int <= 0;
  else
  begin
    // sign val
    cn_msg_int[LLRWIDTH-1] <= old_sign_result ^ old_signs[old_count];

    // min result
    if( old_count==old_leastpos )
      cn_msg_int[LLRWIDTH-2:0] <= old_nextleast_llr;
    else
      cn_msg_int[LLRWIDTH-2:0] <= old_least_llr;
  end

/****************************************************************
 * Pipe stage 1b:                                               *
 * Calculate fixed_msg = downlink message - last uplink message *
 ****************************************************************/
wire[LLRWIDTH-1:0] offset_val;
reg[LLRWIDTH-1:0]  fixed_msg;

reg[LLRWIDTH-2:0] old_least_llr_del;
reg[LLRWIDTH-2:0] old_nextleast_llr_del;
reg[4:0]          old_count_del;
reg[4:0]          old_leastpos_del;
reg[29:0]         old_signs_del;
reg               old_sign_result_del;
reg               old_last_sign_result_del;
reg[4:0]          old_last_leastpos_del;
reg[LLRWIDTH-2:0] old_last_least_llr_del;
reg[LLRWIDTH-2:0] old_last_nextleast_llr_del;

reg start_over_aligned_msg;
reg cn_we_aligned_msg;
reg repeat_access_aligned_msg;

assign offset_val = first_iteration ? 0
                      : (old_count==old_last_leastpos) ? { old_last_sign_result^old_signs[old_count], old_last_nextleast_llr }
                        : { old_last_sign_result^old_signs[old_count], old_last_least_llr };

always @( posedge rst, posedge clk )
  if( rst )
  begin
    fixed_msg                  <= 0;
    old_least_llr_del          <= 0;
    old_nextleast_llr_del      <= 0;
    old_count_del              <= 0;
    old_leastpos_del           <= 0;
    old_signs_del              <= 0;
    old_sign_result_del        <= 0;
    old_last_sign_result_del   <= 0;
    old_last_leastpos_del      <= 0;
    old_last_least_llr_del     <= 0;
    old_last_nextleast_llr_del <= 0;
    start_over_aligned_msg     <= 0;
    cn_we_aligned_msg          <= 0;
    repeat_access_aligned_msg  <= 0;
  end
  else
  begin
    fixed_msg <= SubSaturate( sh_msg_aligned_old, offset_val );

    old_least_llr_del     <= old_least_llr;
    old_nextleast_llr_del <= old_nextleast_llr;
    old_leastpos_del      <= old_leastpos;
    old_signs_del         <= old_signs;
    old_sign_result_del   <= old_sign_result;
    
    old_last_sign_result_del   <= old_last_sign_result;
    old_last_leastpos_del      <= old_last_leastpos;
    old_last_least_llr_del     <= old_last_least_llr;
    old_last_nextleast_llr_del <= old_last_nextleast_llr;

    old_count_del <= old_count;

    start_over_aligned_msg    <= start_over_aligned_old;
    cn_we_aligned_msg         <= cn_we_aligned_old;
    repeat_access_aligned_msg <= repeat_access_aligned_old;
  end

/*******************************************
 * Pipe stage 2:                           *
 * Calculate new values for RAM write-back *
 *******************************************/
reg               new_iteration;
reg               new_up;
reg[4:0]          new_leastpos;
reg               new_last_sign_result;
reg[4:0]          new_last_leastpos;
reg[29:0]         new_signs;
reg               new_sign_result;
reg[4:0]          new_count;
reg[LLRWIDTH-2:0] new_least_llr;
reg[LLRWIDTH-2:0] new_nextleast_llr;
reg[LLRWIDTH-2:0] new_last_least_llr;
reg[LLRWIDTH-2:0] new_last_nextleast_llr;

wire[LLRWIDTH-2:0] muxed_least_llr;
wire[LLRWIDTH-2:0] muxed_nextleast_llr;
wire new_winner;
wire new_2nd;

assign muxed_least_llr     = repeat_access_aligned_msg ? new_least_llr[LLRWIDTH-2:0]
                                                       : old_least_llr_del[LLRWIDTH-2:0];
assign muxed_nextleast_llr = repeat_access_aligned_msg ? new_nextleast_llr[LLRWIDTH-2:0]
                                                       : old_nextleast_llr_del[LLRWIDTH-2:0];

assign new_winner = (fixed_msg[LLRWIDTH-2:0] < muxed_least_llr[LLRWIDTH-2:0]);
assign new_2nd    = ((fixed_msg[LLRWIDTH-2:0] <= muxed_nextleast_llr[LLRWIDTH-2:0])
                      & ~new_winner);

always @( posedge rst, posedge clk )
  if( rst )
  begin
    new_iteration          <= 0;
    new_up                 <= 0;
    new_count              <= 0;
    new_leastpos           <= 0;
    new_least_llr          <= 0;
    new_nextleast_llr      <= 0;
    new_signs              <= 0;
    new_sign_result        <= 0;
    new_last_sign_result   <= 0;
    new_last_leastpos      <= 0;
    new_last_least_llr     <= 0;
    new_last_nextleast_llr <= 0;
  end
  else
  begin
    new_iteration <= iteration | llr_din_we;
    new_up        <= ~first_half;
    new_count     <= old_count_del + 1;

    // assign new smallest LLR
    if( !repeat_access_aligned_msg )
    begin
      new_signs         <= old_signs_del;
      new_leastpos      <= old_leastpos_del;
      new_least_llr     <= old_least_llr_del;
      new_nextleast_llr <= old_nextleast_llr_del;
      new_sign_result   <= old_sign_result_del;
    end

    if( cn_we_aligned_msg )
    begin
      // note: only assigning one bit - others stay at old value
      new_signs[old_count_del] <= fixed_msg[LLRWIDTH-1];

      if( new_winner | start_over_aligned_msg )
      begin
        new_leastpos  <= old_count_del;
        new_least_llr <= fixed_msg[LLRWIDTH-2:0];
      end

      if( start_over_aligned_msg )
        new_nextleast_llr <= { (LLRWIDTH-1){1'b1} };
      else if( new_winner && repeat_access_aligned_msg )
        new_nextleast_llr <= new_least_llr;
      else if( new_winner )
        new_nextleast_llr <= old_least_llr_del;
      else if( new_2nd )
        new_nextleast_llr <= fixed_msg[LLRWIDTH-2:0];

      if( start_over_aligned_msg )
        new_sign_result <= fixed_msg[LLRWIDTH-1];
      else if( repeat_access_aligned_msg )
        new_sign_result <= new_sign_result ^ fixed_msg[LLRWIDTH-1];
      else
        new_sign_result <= old_sign_result_del ^ fixed_msg[LLRWIDTH-1];
    end

    // store old downstream results during upstream messages
    new_last_sign_result   <= first_half ? old_last_sign_result_del   : old_sign_result_del;
    new_last_leastpos      <= first_half ? old_last_leastpos_del      : old_leastpos_del;
    new_last_least_llr     <= first_half ? old_last_least_llr_del     : old_least_llr_del;
    new_last_nextleast_llr <= first_half ? old_last_nextleast_llr_del : old_nextleast_llr_del;
  end

assign dnmsg_din[0]                                = new_iteration;
assign dnmsg_din[1]                                = new_up;
assign dnmsg_din[6:2]                              = new_leastpos;
assign dnmsg_din[11:7]                             = new_last_leastpos;
assign dnmsg_din[16:12]                            = new_count;
assign dnmsg_din[16+ 1*(LLRWIDTH-1) -: LLRWIDTH-1] = new_least_llr;
assign dnmsg_din[16+ 2*(LLRWIDTH-1) -: LLRWIDTH-1] = new_nextleast_llr;
assign dnmsg_din[16+ 3*(LLRWIDTH-1) -: LLRWIDTH-1] = new_last_least_llr;
assign dnmsg_din[16+ 4*(LLRWIDTH-1) -: LLRWIDTH-1] = new_last_nextleast_llr;
assign dnmsg_din[16+ 4*(LLRWIDTH-1) +1]            = new_sign_result;
assign dnmsg_din[16+ 4*(LLRWIDTH-1) +2]            = new_last_sign_result;
assign dnmsg_din[16+ 4*(LLRWIDTH-1) +32 -: 30]     = new_signs;

/******************************************
 * Align some signals with new RAM inputs *
 ******************************************/
localparam CALC_LATENCY = 3;

integer loopvar2;

reg                   we_del2[0:CALC_LATENCY-1];
reg[7+FOLDFACTOR-1:0] addr_del2[0:CALC_LATENCY-1];

assign dnmsg_we     = ~we_del2[CALC_LATENCY -1];
assign dnmsg_wraddr = addr_del2[CALC_LATENCY -1];

always @( posedge clk, posedge rst )
  if( rst )
    for( loopvar2=0; loopvar2<CALC_LATENCY; loopvar2=loopvar2+1 )
    begin
      we_del2[loopvar2]   <= 0;
      addr_del2[loopvar2] <= 0;
    end
  else
  begin
    we_del2[0]   <= cn_we_aligned_ram | cn_rd_aligned_ram;
    addr_del2[0] <= addr_cn_aligned_ram;

    for( loopvar2=1; loopvar2<CALC_LATENCY; loopvar2=loopvar2+1 )
    begin
      we_del2[loopvar2]   <= we_del2[loopvar2 -1];
      addr_del2[loopvar2] <= addr_del2[loopvar2 -1];
    end

    // last stage - mux in LLR values (if CALC_LATENCY=2, this stage
    // supercedes the entire for-loop, above)
    we_del2[CALC_LATENCY-1] <= llr_din_we | we_del2[CALC_LATENCY-2];

    if( llr_din_we )
      addr_del2[CALC_LATENCY-1] <= llr_addr;
    else
      addr_del2[CALC_LATENCY-1] <= addr_del2[CALC_LATENCY-2];
  end

endmodule
