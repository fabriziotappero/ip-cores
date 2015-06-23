`include "Codeword.sv"
`timescale 1ns/10ps

module tb_ldpc();

localparam CLK_PERIOD = 5ns;
localparam HOLD       = 1ns;

localparam SYMS_PER_EBN0 = 10;
localparam EBN0_MIN      = 3.8;
localparam EBN0_MAX      = 4.0;
localparam EBN0_STEP     = 0.2;
localparam CODE_TYPE     = "1_2";

localparam LLRWIDTH = 6;

//////////
// Clocks
//////////
logic clk;
logic rst;

initial
begin
  clk <= 1'b0;
  forever
    #(CLK_PERIOD /2) clk <= ~clk;
end

initial
begin
  rst <= 1'b1;

  repeat(3) @(posedge clk);
  rst <= #HOLD 1'b0;
end

/////////////
// Generator
/////////////
int    packet_number;
int    debug_level;
int    log_level;
string logfilename;
string name;

/* VCS doesn't support parameterized mailboxes, just use one Codeword
   throughout the testbench and one big initial block instead.
Codeword datapath_orig;
Codeword checkpath_orig;

mailbox #(Codeword) data_source;
mailbox #(Codeword) check_source;
semaphore check;
*/
Codeword  check_word;

//////////////
// Transactors
//////////////
// Load data into LLR
// LLR I/O
logic      llr_access;
logic[7:0] llr_addr;
logic      llr_din_we;
logic[360*LLRWIDTH-1:0]      llr_din;
bit signed[360*LLRWIDTH-1:0] llr_dout;

// start command; completion indicator
logic      start;
logic[4:0] mode;
logic[5:0] iter_limit;
bit        done;

localparam READ_LATENCY = 5;

initial
begin
  packet_number = 0;
  debug_level   = 0;
  log_level     = 1;
  logfilename   = "test_testbench.txt";
  name          = "CodewordSpecial";

  check_word = new( CODE_TYPE, debug_level, log_level, logfilename, packet_number, name );

  llr_access  <= 0;
  llr_addr    <= 0;
  llr_din_we  <= 0;
  llr_din     <= 0;
  start       <= 0;
  mode        <= 0;
  iter_limit  <= 20;

  @( posedge rst );
  repeat( 5 ) @( posedge clk );

  for( real ebn0dB=EBN0_MIN; ebn0dB<EBN0_MAX; ebn0dB+=EBN0_STEP )
    for( int symnum=0; symnum<SYMS_PER_EBN0; symnum++ )
    begin
      // create word
      check_word.create_random_msg();
      check_word.encode();

      check_word.AddNoise( ebn0dB );
      check_word.QuantizeLlr( LLRWIDTH );

      // begin testing DUT
      @(posedge clk);

      // write normal data bits
      for( int i=0; i<check_word.GetK()/360; i++ )
      begin
        int wr_val;
        int abs_wr_val;

        llr_addr   <= i;
        llr_access <= 1;

        for( int j=0; j<360; j++ )
        begin
          wr_val = check_word.GetVal(360*i +j);
          //wr_val = 360*i +j;
          abs_wr_val = wr_val < 0 ? -1*wr_val : wr_val;

          llr_din[(j+1)*LLRWIDTH-1 -: LLRWIDTH]
            <= (wr_val<0) ? { 1'b1, abs_wr_val[LLRWIDTH-2:0] }
                          : { 1'b0, abs_wr_val[LLRWIDTH-2:0] };
        end

        llr_din_we <= 1;
        @( posedge clk );
      end

      // write parity bits
      for( int i=0; i<(check_word.GetN()-check_word.GetK())/360; i++ )
      begin
        int rotate_pos;
        int wr_val;
        int abs_wr_val;

        llr_addr <= check_word.GetK()/360 + i;

        for( int j=0; j<360; j++ )
        begin
          rotate_pos = check_word.GetK() + i + j*check_word.GetQ();
          wr_val     = check_word.GetVal(rotate_pos);
          //wr_val     = rotate_pos;
          abs_wr_val = wr_val < 0 ? -1*wr_val : wr_val;

          llr_din[j*LLRWIDTH+LLRWIDTH-1 -: LLRWIDTH]
            <= (wr_val<0) ? { 1'b1, abs_wr_val[LLRWIDTH-2:0] }
                          : { 1'b0, abs_wr_val[LLRWIDTH-2:0] };
        end

        llr_din_we <= 1;
        @( posedge clk );
      end

      llr_din_we <= 0;
      llr_access <= 0;
      @( posedge clk );

      //controls
      start <= 1;

      case( CODE_TYPE )
        "1_4":    mode <= 0;
        "1_3":    mode <= 1;
        "2_5":    mode <= 2;
        "1_2":    mode <= 3;
        "3_5":    mode <= 4;
        "2_3":    mode <= 5;
        "3_4":    mode <= 6;
        "4_5":    mode <= 7;
        "5_6":    mode <= 8;
        "8_9":    mode <= 9;
        "9_10":   mode <= 10;
        "1_5s":   mode <= 11;
        "1_3s":   mode <= 12;
        "2_5s":   mode <= 13;
        "4_9s":   mode <= 14;
        "3_5s":   mode <= 15;
        "2_3s":   mode <= 16;
        "11_15s": mode <= 17;
        "7_9s":   mode <= 18;
        "37_45s": mode <= 19;
        "8_9s":   mode <= 20;
        default: $stop( "Illegal code type!" );
      endcase
      @( posedge clk );
      start <= 0;
      @( posedge clk );

      // read data out
      @(posedge done);
      @(posedge clk);

      llr_access <= 1;
      llr_addr   <= 0;
      @(posedge clk);

      // read normal data bits
      for( int i=0; i<(check_word.GetK()/360)+READ_LATENCY; i++ )
      begin
        int result;

        llr_addr <= i;
        llr_din  <= { LLRWIDTH{1'bX} };
        @( posedge clk );

        if( i>=READ_LATENCY )
          for( int j=0; j<360; j++ )
          begin
            result = llr_dout[j*LLRWIDTH+LLRWIDTH-1]
              ? -1 * { 1'b0, llr_dout[j*LLRWIDTH+LLRWIDTH-2 -: LLRWIDTH-1] }
              : { 1'b0, llr_dout[j*LLRWIDTH+LLRWIDTH-2 -: LLRWIDTH-1] };

            check_word.SetDecoded( 360*(i-READ_LATENCY) +j, result );
          end
      end

      // read parity bits
      for( int i=0; i<((check_word.GetN()-check_word.GetK())/360)+READ_LATENCY; i++ )
      begin
        int result;
        int rotate_pos;

        llr_addr <= check_word.GetK()/360 + i;
        @(posedge clk);

        if( i>=READ_LATENCY )
          for( int j=0; j<360; j++ )
          begin
            rotate_pos = check_word.GetK() + i-READ_LATENCY + j*check_word.GetQ();

            result = llr_dout[j*LLRWIDTH+LLRWIDTH-1]
              ? -1 * { 1'b0, llr_dout[j*LLRWIDTH+LLRWIDTH-2 -: LLRWIDTH-1] }
              : { 1'b0, llr_dout[j*LLRWIDTH+LLRWIDTH-2 -: LLRWIDTH-1] };

            check_word.SetDecoded( rotate_pos, result );
          end
      end

      llr_access <= 0;
      @( posedge clk );

      $display( "EbN0 = %0fdB", ebn0dB );
      $display( "Orig had    %0d errors", check_word.CountOrigErrs() );
      $display( "Decoded had %0d errors", check_word.CountDecodedErrs() );

      check_word.inc(); // increment packet number
    end

  check_word.delete();
  $stop();
end

///////////
// Checker
///////////

////////////
// Instance
////////////
ldp_top #(
  .FOLDFACTOR  (1),
  .NUMINSTANCES(360),
  .LLRWIDTH    (LLRWIDTH)
) ldp_top_i(
  .clk(clk),
  .rst(rst),

  .llr_access (llr_access),
  .llr_addr   (llr_addr),
  .llr_din_we (llr_din_we),
  .llr_din    (llr_din),
  .llr_dout   (llr_dout),

  .start     (start),
  .mode      (mode),
  .iter_limit(iter_limit),
  .done      (done)
);

endmodule

