//-------------------------------------------------------------------------
//
// File name    :  ldpc_iocontrol.v
// Title        :
//              :
// Purpose      : Variable node holder/message calculator.  Loads llr
//              : data serially
//
// ----------------------------------------------------------------------
// Revision History :
// ----------------------------------------------------------------------
//   Ver  :| Author   :| Mod. Date   :| Changes Made:
//   v1.0  | JTC      :| 2008/07/02  :|
// ----------------------------------------------------------------------
`timescale 1ns/10ps

module ldpc_iocontrol #(
  parameter FOLDFACTOR     = 4,
  parameter LOG2FOLDFACTOR = 2,
  parameter LASTSHIFTWIDTH = 3,
  parameter NUMINSTANCES   = 180
)(
  input clk,
  input rst,

  // start command, completion indicator
  input      start,
  input[4:0] mode,
  input[5:0] iter_limit,
  output     done,

  // common control outputs
  output iteration,
  output first_iteration,
  output disable_vn,
  output disable_cn,

  // control VN's
  output                     we_vnmsg,
  output[7:0]                addr_vn,
  output[LOG2FOLDFACTOR-1:0] addr_vn_lo,

  // control shuffler
  output                     first_half,
  output[1:0]                shift0,
  output[2:0]                shift1,
  output[LASTSHIFTWIDTH-1:0] shift2,

  // control CN's
  output                     cn_we,
  output                     cn_rd,
  output[7:0]                addr_cn,
  output[LOG2FOLDFACTOR-1:0] addr_cn_lo,

  // ROM
  output[12:0]                  romaddr,
  input[8+5+LASTSHIFTWIDTH-1:0] romdata
);

localparam DONT_SHIFT = 0; // useful for debugging

/*********************************
 * State Machine 1               *
 * Controls the decoding process *
 *********************************/
localparam S_IDLE            = 0;
localparam S_PREPDECODE0     = 1;
localparam S_PREPDECODE1     = 2;
localparam S_FETCHCMD0       = 3;
localparam S_FETCHCMD1       = 4;
localparam S_STOREMSG        = 5;
localparam S_STOREPARITYMSG  = 6;
localparam S_STORESHIFTEDPARITY = 7;
localparam S_FINISHPIPE0     = 8;
localparam S_FINISHPIPE1     = 9;
localparam S_FINISHPIPE2     = 10;
localparam S_FINISHPIPE3     = 11;
localparam S_FINISHPIPE4     = 12;
localparam S_FINISHPIPE5     = 13;
localparam S_FINISHPIPE6     = 14;
localparam S_RESTART         = 15;

localparam TURNAROUND_WAITSTATES = 11;

reg[3:0] state;

reg[7:0] cn_count;
reg[7:0] vn_count;
reg[7:0] ta_count;

reg[12:0] romaddr_int;
reg[12:0] start_addr;
reg[12:0] turnaround_addr;
reg[4:0]  group_depth;
reg       turnaround;
reg       turnaround_next;
reg       last_group;
reg       first_group;
reg       last_group_next;
reg       n64k;
reg[7:0]  q;
reg[4:0]  count;
reg[5:0]  iter_count;
reg       done_int;
reg       first_iteration_int;
reg       iteration_int;

reg first_half_int;

reg[3:0] wait_count;

assign romaddr           = romaddr_int;
assign first_iteration   = first_iteration_int;
assign done              = done_int;
assign first_half        = first_half_int;
assign iteration         = iteration_int;

// synchronous state machine
always @( posedge rst, posedge clk )
  if( rst )
  begin
    state               <= S_IDLE;
    done_int            <= 0;
    iter_count          <= 0;
    romaddr_int         <= 0;
    first_iteration_int <= 0;
    iteration_int       <= 0;
    count               <= 0;
    cn_count            <= 0;
    vn_count            <= 0;
    first_half_int      <= 0;
    romaddr_int         <= 0;
    start_addr          <= 0;
    turnaround_addr     <= 0;
    q                   <= 0;
    turnaround          <= 0;
    turnaround_next     <= 0;
    last_group          <= 0;
    first_group         <= 0;
    n64k                <= 0;
    last_group_next     <= 0;
    group_depth         <= 0;
    wait_count          <= 0;
  end
  else
  begin
    // defaults
    done_int <= 0;

    case( state )
    // wait for start to prepare jump to offset, "mode"
    S_IDLE:
    begin
      if( start )
        state <= S_PREPDECODE0;

      romaddr_int      <= 0;
      romaddr_int[4:0] <= mode;

      iter_count    <= iter_limit;
      iteration_int <= 0;

      first_iteration_int <= 1;
      first_half_int      <= 1;
      cn_count            <= 0;
      vn_count            <= 0;
      ta_count            <= 0;

      first_group <= 1;

      done_int <= 1;
    end

    // "mode" is a pointer to a pointer - jump to mode**
    S_PREPDECODE0:
      state <= S_PREPDECODE1;

    S_PREPDECODE1:
    begin
      state <= S_FETCHCMD0;

      n64k <= romdata[16];

      romaddr_int     <= romdata[12:0];
      start_addr      <= romdata[12:0];
      turnaround_addr <= romdata[12:0];
    end

    // interpret code from ROM
    S_FETCHCMD0:
    begin
      state <= S_FETCHCMD1;

      if( n64k )
        vn_count <= 179;
      else
        vn_count <= 44;
    end

    S_FETCHCMD1:
    begin
      state <= S_STORESHIFTEDPARITY;

      romaddr_int <= romaddr_int + 1;

      turnaround  <= romdata[14];
      last_group  <= romdata[13];
      group_depth <= romdata[12:8];
      q           <= romdata[7:0];
      count       <= 0;
    end

    // write shifted set of parity bits
    S_STORESHIFTEDPARITY:
    begin
      state <= S_STOREMSG;

      romaddr_int <= romaddr_int + 1;
      wait_count  <= TURNAROUND_WAITSTATES;
      first_group <= 0;
    end

    // Write messages
    S_STOREMSG:
    begin
      if( count==group_depth )
        state <= S_STOREPARITYMSG;

      romaddr_int <= romaddr_int + (count!=group_depth);

      count    <= count + 1;
      vn_count <= q + cn_count;
    end

    // write parity bits to CN
    S_STOREPARITYMSG:
    begin
      if( last_group || turnaround )
        state <= S_FINISHPIPE0;
      else
        state <= S_STORESHIFTEDPARITY;

      if( !last_group && !turnaround )
      begin
        cn_count    <= cn_count + 1;
        romaddr_int <= romaddr_int + 1;

        turnaround  <= romdata[14];
        last_group  <= romdata[13];
        group_depth <= romdata[12:8];
        q           <= romdata[7:0];
        count       <= 0;
      end
    end

    // need waitstates between phases to let the pipeline clear out
    S_FINISHPIPE0:
    begin
      if( wait_count==0 )
      begin
        if( last_group && (iter_count==0) && !first_half_int )
        begin
          state    <= S_IDLE;
          done_int <= 1;
        end
        else
          state <= S_RESTART;
      end

      wait_count  <= wait_count - 1;

      if( wait_count==0 )
      begin
        turnaround  <= romdata[14];
        last_group  <= romdata[13];
        group_depth <= romdata[12:8];
        q           <= romdata[7:0];
        count       <= 0;

        cn_count    <= ta_count;
        romaddr_int <= turnaround_addr;

        ta_count        <= cn_count    + 1;
        turnaround_addr <= romaddr_int;

        if( last_group && !first_half_int )
        begin
          cn_count            <= 0;
          iteration_int       <= iteration_int ^ ~first_half_int;
          first_iteration_int <= 0;
          romaddr_int         <= start_addr;
          iter_count          <= iter_count - 1;

          ta_count        <= 0;
          turnaround_addr <= start_addr;
        end
      end
    end

    S_RESTART:
    begin
      state <= S_FETCHCMD1;

      if( cn_count==0 )
      begin
        first_group <= 1;
        if( n64k )
          vn_count <= 179;
        else
          vn_count <= 44;
      end

      first_half_int <= ~first_half_int;
    end

    default: ;
    endcase
  end

  // asynchronous portion of state machine
  reg we;
  reg matchpar;
  reg last_step;

  always @( * )
  begin
    // defaults
    we        <= 0;
    matchpar  <= 0;
    last_step <= 0;

    case( state )
      // Write messages
      S_STOREMSG:
        we <= 1;

      // write parity bits to CN's
      S_STOREPARITYMSG:
      begin
        we       <= 1;
        matchpar <= 1;
      end

      // write parity bits to next CN location
      S_STORESHIFTEDPARITY:
      begin
        we <= 1;

        if( first_group )
          last_step <= 1;
        else
          matchpar  <= 1;
      end

      default: ;
    endcase
  end

/********************************
 * State Machine Helper         *
 * Adds delays to we and to the *
 * addresses for vn and cn      *
 ********************************/
// determine undelayed controls
wire[7:0]                  orig_cn_addr;
wire[7:0]                  orig_vn_addr;
wire[5+LASTSHIFTWIDTH-1:0] orig_shiftval;
wire                       orig_we_vnmsg;
wire                       orig_cn_we;
wire                       orig_cn_rd;
wire                       orig_disable;

assign orig_vn_addr  = ( matchpar || last_step ) ? vn_count
                       : romdata[8+5+LASTSHIFTWIDTH-1:5+LASTSHIFTWIDTH];
assign orig_cn_addr  = cn_count;
assign orig_shiftval = DONT_SHIFT                     ? 0 :
                       matchpar                       ? 0 :
                       (first_half_int && last_step)  ? 1 :
                       (~first_half_int && last_step) ? NUMINSTANCES-1 :
                       first_half_int                 ? romdata[5+LASTSHIFTWIDTH-1:0] :
                                                        NUMINSTANCES - romdata[5+LASTSHIFTWIDTH-1:0];
assign orig_we_vnmsg = we & ~first_half_int;
assign orig_cn_we    = we & first_half_int;
assign orig_cn_rd    = we & ~first_half_int;
assign orig_disable  = last_step;

// add delays to compensate for latencies in external modules
localparam LOCAL_DELAY   = 1;  // Local register delays everything by 1
localparam RAM_LATENCY   = 2;  // RAM registers address in and data out
localparam VN_PIPES      = 3;
localparam SHUFFLE_PIPES = 3;
localparam CN_PIPES      = 2;
localparam MAX_PIPES     = VN_PIPES > CN_PIPES ? VN_PIPES : CN_PIPES;

localparam SHUFFLE_PREPSTAGES = 1; // we'll use 1 pipe locally to calculate shift addresses
localparam DISABLE_PREPSTAGES = 1; // disable needs 1 local pipe to sort out upstream/downstream

localparam LATENCY_VN_DEST  = LOCAL_DELAY + RAM_LATENCY + SHUFFLE_PIPES + CN_PIPES;
localparam LATENCY_CN_DEST  = LOCAL_DELAY + RAM_LATENCY + SHUFFLE_PIPES + VN_PIPES;
localparam LATENCY_CNVN_MAX = LOCAL_DELAY + RAM_LATENCY + SHUFFLE_PIPES + MAX_PIPES;

localparam LATENCY_DISABLE_DL = LATENCY_CN_DEST - DISABLE_PREPSTAGES;
localparam LATENCY_DISABLE_UL = LATENCY_VN_DEST - DISABLE_PREPSTAGES;

localparam LATENCY_SHIFTVALS_DL  = LOCAL_DELAY + RAM_LATENCY + VN_PIPES - SHUFFLE_PREPSTAGES;
localparam LATENCY_SHIFTVALS_UL  = LOCAL_DELAY + RAM_LATENCY + CN_PIPES - SHUFFLE_PREPSTAGES;
localparam LATENCY_SHIFTVALS_MAX = LOCAL_DELAY + RAM_LATENCY + MAX_PIPES - SHUFFLE_PREPSTAGES;

// for code neatness, all shift registers are the same length.  Rely on synthesizer to
// remove unused registers
reg[7:0]                  cn_addr_del[0:LATENCY_CNVN_MAX-1];
reg[7:0]                  vn_addr_del[0:LATENCY_CNVN_MAX-1];
reg[5+LASTSHIFTWIDTH-1:0] shiftval_del[0:LATENCY_CNVN_MAX-1];
reg                       we_vnmsg_del[0:LATENCY_CNVN_MAX-1];
reg                       cn_we_del[0:LATENCY_CNVN_MAX-1];
reg                       cn_rd_del[0:LATENCY_CNVN_MAX-1];
reg                       disable_vn_del[0:LATENCY_CNVN_MAX-1];
reg                       disable_cn_del[0:LATENCY_CNVN_MAX-1];

wire[5+LASTSHIFTWIDTH-1:0] shiftval_int;

integer loopvar;

assign we_vnmsg   = we_vnmsg_del[LATENCY_VN_DEST-1];
assign cn_we      = cn_we_del[LATENCY_CN_DEST-1];
assign cn_rd      = cn_rd_del[LATENCY_CN_DEST-1];
assign addr_vn    = vn_addr_del[LATENCY_VN_DEST-1];
assign addr_cn    = cn_addr_del[LATENCY_CN_DEST-1];
assign disable_vn = disable_vn_del[LATENCY_VN_DEST-1];
assign disable_cn = disable_cn_del[LATENCY_CN_DEST-1];

assign shiftval_int = shiftval_del[LATENCY_SHIFTVALS_MAX-1];

always @( posedge rst, posedge clk )
  if( rst )
    for( loopvar=0; loopvar<LATENCY_CNVN_MAX; loopvar=loopvar+1 )
    begin
      cn_addr_del[loopvar]    <= 0;
      vn_addr_del[loopvar]    <= 0;
      shiftval_del[loopvar]   <= 0;
      we_vnmsg_del[loopvar]   <= 0;
      cn_we_del[loopvar]      <= 0;
      cn_rd_del[loopvar]      <= 0;
      disable_vn_del[loopvar] <= 0;
      disable_cn_del[loopvar] <= 0;
    end
  else
  begin
    cn_addr_del[0]    <= orig_cn_addr;
    vn_addr_del[0]    <= orig_vn_addr;
    shiftval_del[0]   <= orig_shiftval;
    we_vnmsg_del[0]   <= orig_we_vnmsg;
    cn_we_del[0]      <= orig_cn_we;
    cn_rd_del[0]      <= orig_cn_rd;
    disable_vn_del[0] <= orig_disable;
    disable_cn_del[0] <= orig_disable;

    for( loopvar=1; loopvar<LATENCY_CNVN_MAX; loopvar=loopvar+1 )
    begin
      cn_addr_del[loopvar]    <= cn_addr_del[loopvar-1];
      vn_addr_del[loopvar]    <= vn_addr_del[loopvar-1];
      shiftval_del[loopvar]   <= shiftval_del[loopvar-1];
      we_vnmsg_del[loopvar]   <= we_vnmsg_del[loopvar-1];
      cn_we_del[loopvar]      <= cn_we_del[loopvar-1];
      cn_rd_del[loopvar]      <= cn_rd_del[loopvar-1];
      disable_vn_del[loopvar] <= disable_vn_del[loopvar-1];
      disable_cn_del[loopvar] <= disable_cn_del[loopvar-1];
    end

    // need some muxes in the middle of the shift registers because of different
    // latencies for upstream and downstream messages
    if( first_half )
    begin
      vn_addr_del[LATENCY_VN_DEST-1]    <= orig_vn_addr;
      we_vnmsg_del[LATENCY_VN_DEST-1]   <= orig_we_vnmsg;
      disable_vn_del[LATENCY_VN_DEST-1] <= orig_disable;
    end
    if( !first_half )
    begin
      cn_addr_del[LATENCY_CN_DEST-1]    <= orig_cn_addr;
      cn_we_del[LATENCY_CN_DEST-1]      <= orig_cn_we;
      cn_rd_del[LATENCY_CN_DEST-1]      <= orig_cn_rd;
      disable_cn_del[LATENCY_CN_DEST-1] <= orig_disable;
    end
    
    if( first_half )
      shiftval_del[LATENCY_SHIFTVALS_MAX-1] <= shiftval_del[LATENCY_SHIFTVALS_DL-2];
    if( !first_half )
      shiftval_del[LATENCY_SHIFTVALS_MAX-1] <= shiftval_del[LATENCY_SHIFTVALS_UL-2];
  end

wire[1:0]               shift0_int;
reg[1:0]                shift0_reg;
wire[2:0]               shift1_int;
reg[2:0]                shift1_reg;
reg[LASTSHIFTWIDTH-1:0] shift2_reg;

assign shift0 = shift0_reg;
assign shift1 = shift1_reg;
assign shift2 = shift2_reg;

reg[8:0]                rem0;
reg[LASTSHIFTWIDTH-1:0] rem1;

generate
  if( FOLDFACTOR==1 )
  begin: case360
    assign shift0_int = shiftval_int > 269 ? 3
                      : shiftval_int > 179 ? 2
                      : shiftval_int > 89  ? 1
                      :                      0;

    assign shift1_int = rem0 > 83 ? 7
                      : rem0 > 71 ? 6
                      : rem0 > 59 ? 5
                      : rem0 > 47 ? 4
                      : rem0 > 35 ? 3
                      : rem0 > 23 ? 2
                      : rem0 > 11 ? 1
                      :             0;
  end
  if( FOLDFACTOR==2 )
  begin: case180
    assign shift0_int = shiftval_int > 134 ? 3
                      : shiftval_int > 89  ? 2
                      : shiftval_int > 44  ? 1
                      :                      0;


    assign shift1_int = rem0 > 41 ? 7
                      : rem0 > 35 ? 6
                      : rem0 > 29 ? 5
                      : rem0 > 23 ? 4
                      : rem0 > 17 ? 3
                      : rem0 > 11 ? 2
                      : rem0 > 5  ? 1
                      :             0;
  end
  if( FOLDFACTOR==3 )
  begin: case120
    assign shift0_int = shiftval_int > 89 ? 3
                      : shiftval_int > 59 ? 2
                      : shiftval_int > 29 ? 1
                      :                     0;

    assign shift1_int = rem0 > 26 ? 7
                      : rem0 > 22 ? 6
                      : rem0 > 18 ? 5
                      : rem0 > 15 ? 4
                      : rem0 > 11 ? 3
                      : rem0 > 7  ? 2
                      : rem0 > 3  ? 1
                      :             0;
  end
  if( FOLDFACTOR==4 )
  begin: case90
    assign shift0_int = shiftval_int > 66 ? 3
                      : shiftval_int > 44 ? 2
                      : shiftval_int > 22 ? 1
                      :                     0;

    assign shift1_int = rem0 > 20 ? 7
                      : rem0 > 17 ? 6
                      : rem0 > 14 ? 5
                      : rem0 > 11 ? 4
                      : rem0 > 8  ? 3
                      : rem0 > 5  ? 2
                      : rem0 > 2  ? 1
                      :             0;
  end
endgenerate

always @( posedge rst, posedge clk )
  if( rst )
  begin
    shift0_reg            <= 0;
    shift1_reg            <= 0;
    shift2_reg            <= 0;
    rem0                  <= 0;
    rem1                  <= 0;
  end
  else
  begin
    // shift0 needs to be inverted (this arithmetic should be optimized out)
    shift0_reg <= shift0_int;
    shift1_reg <= shift1_int;
    shift2_reg <= rem1;

    // calculate remainders after first two shifts
    if( FOLDFACTOR==1 )
      rem0 <= shift0_int==3 ? shiftval_int-270
            : shift0_int==2 ? shiftval_int-180
            : shift0_int==1 ? shiftval_int-90
            :                 shiftval_int;
    if( FOLDFACTOR==2 )
      rem0 <= shift0_int==3 ? shiftval_int-135
            : shift0_int==2 ? shiftval_int-90
            : shift0_int==1 ? shiftval_int-45
            :                 shiftval_int;
    if( FOLDFACTOR==3 )
      rem0 <= shift0_int==3 ? shiftval_int-90
            : shift0_int==2 ? shiftval_int-60
            : shift0_int==1 ? shiftval_int-30
            :                 shiftval_int;
    if( FOLDFACTOR==4 )
      rem0 <= shift0_int==3 ? shiftval_int-67
            : shift0_int==2 ? shiftval_int-45
            : shift0_int==1 ? shiftval_int-23
            :                 shiftval_int;

    if( FOLDFACTOR==1 )
      rem1 <= shift1_int==7 ? rem0-84
            : shift1_int==6 ? rem0-72
            : shift1_int==5 ? rem0-60
            : shift1_int==4 ? rem0-48
            : shift1_int==3 ? rem0-36
            : shift1_int==2 ? rem0-24
            : shift1_int==1 ? rem0-12
            :                 rem0;
    if( FOLDFACTOR==3 )
      rem1 <= shift1_int==7 ? rem0-52
            : shift1_int==6 ? rem0-45
            : shift1_int==5 ? rem0-37
            : shift1_int==4 ? rem0-30
            : shift1_int==3 ? rem0-22
            : shift1_int==2 ? rem0-15
            : shift1_int==1 ? rem0-7
            :                 rem0;
    if( FOLDFACTOR==4 )
      rem1 <= shift1_int==7 ? rem0-21
            : shift1_int==6 ? rem0-18
            : shift1_int==5 ? rem0-15
            : shift1_int==4 ? rem0-12
            : shift1_int==3 ? rem0-9
            : shift1_int==2 ? rem0-6
            : shift1_int==1 ? rem0-3
            :                 rem0;
  end
endmodule
