//
//
//

`timescale 10ps/1ps


module
  cx_encoder
  #(
    parameter CLK_PERIOD      = 320
  )
  (
    output data_out
  );

  // --------------------------------------------------------------------
  //
  wire tx_clock;

  tb_clk #( .CLK_PERIOD(CLK_PERIOD) ) i_tx_clock  ( tx_clock );


  // --------------------------------------------------------------------
  //
  wire tx_clock_10x;
  wire clock_good;

  clock_mult
    #( .MULT(10) )
    tx_clock_10x_i
    (
      .clock_in(tx_clock),
      .clock_out(tx_clock_10x),
      .clock_good(clock_good),

      .reset(1'b0)
    );


  // --------------------------------------------------------------------
  //
  reg [9:0] word_10b[3:0];
  reg       word_10b_out;
  integer   word_10b_index = 0;
  integer   bit_index;

  initial
    begin

      repeat(3)
        @(posedge tx_clock);

      forever
        for( word_10b_index = 0; word_10b_index < 4; word_10b_index = word_10b_index + 1)
          for( bit_index = 0; bit_index < 10; bit_index = bit_index + 1)
            @(negedge tx_clock_10x)
              word_10b_out <= word_10b[word_10b_index][bit_index];

    end


  // --------------------------------------------------------------------
  //
  function automatic [8:0] encode_8b_word;
  input [7:0] word_k;
  input [4:0] word_5b;
  input [2:0] word_3b;
    if( (word_k == "k") | (word_k == "K") )
      encode_8b_word = { 1'b1, word_3b, word_5b };
    else
      encode_8b_word = { 1'b0, word_3b, word_5b };
  endfunction

  localparam K27_7 = encode_8b_word( "K", 27, 7 );  //  K27.7 Start of data packet indication
  localparam K28_0 = encode_8b_word( "K", 28, 0 );  //  K28.0 GPIO indication
  localparam K28_1 = encode_8b_word( "K", 28, 1 );  //  K28.1 Used for alignment
  localparam K28_2 = encode_8b_word( "K", 28, 2 );  //  K28.2 Rising trigger indication
  localparam K28_3 = encode_8b_word( "K", 28, 3 );  //  K28.3 Stream marker – see section 7.2
  localparam K28_4 = encode_8b_word( "K", 28, 4 );  //  K28.4 Falling trigger indication
  localparam K28_5 = encode_8b_word( "K", 28, 5 );  //  K28.5 Used for alignment
  localparam K28_6 = encode_8b_word( "K", 28, 6 );  //  K28.6 I/O acknowledgement
  localparam K28_7 = encode_8b_word( "K", 28, 7 );  //  K29.7 End of data packet indication

  localparam D21_5 = encode_8b_word( "D", 21, 5 );


  // --------------------------------------------------------------------
  //
  reg   [8:0] encode_8b10b_datain_mux   = 0;
  reg         encode_8b10b_dispin       = 0;  // 0 = neg disp; 1 = pos disp
  wire  [9:0] encode_8b10b_dataout_mux;
  wire        encode_8b10b_dispout;

  encode_8b10b
    i_encode_8b10b
    (
      .datain(encode_8b10b_datain_mux),
      .dispin(encode_8b10b_dispin),
      .dataout(encode_8b10b_dataout_mux),
      .dispout(encode_8b10b_dispout)
    );


  // --------------------------------------------------------------------
  //
  reg   [8:0] word_8b[3:0];
  reg         word_8b_we = 0;

  initial
    begin
      word_8b[0] = K28_5;
      word_8b[1] = K28_1;
      word_8b[2] = K28_1;
      word_8b[3] = D21_5;
    end

  always @(posedge tx_clock)
    begin
      encode_8b10b_datain_mux   = word_8b[word_10b_index];
      #1;
      word_8b_we = 1;
      encode_8b10b_dispin       = encode_8b10b_dispout;
      word_10b[word_10b_index]  = encode_8b10b_dataout_mux;
      #1;
      word_8b_we = 0;
    end


  // --------------------------------------------------------------------
  //  debug
`ifdef DEBUG_COAXPRESS
  wire [8:0]  dbg_8b_word =     {
                                  i_encode_8b10b.ai,
                                  i_encode_8b10b.bi,
                                  i_encode_8b10b.ci,
                                  i_encode_8b10b.di,
                                  i_encode_8b10b.ei,
                                  i_encode_8b10b.fi,
                                  i_encode_8b10b.gi,
                                  i_encode_8b10b.hi,
                                  i_encode_8b10b.ki
                                };

  wire [5:0]  dbg_5b_6b_word =  {
                                  i_encode_8b10b.ao,
                                  i_encode_8b10b.bo,
                                  i_encode_8b10b.co,
                                  i_encode_8b10b.do,
                                  i_encode_8b10b.eo,
                                  i_encode_8b10b.io
                                };

  wire [3:0]  dbg_3b_4b_word =  {
                                  i_encode_8b10b.fo,
                                  i_encode_8b10b.go,
                                  i_encode_8b10b.ho,
                                  i_encode_8b10b.jo
                                };

  reg [9:0] dbg_serial_ls;
  reg [9:0] dbg_serial_rs;

  always @(posedge tx_clock_10x)
    begin
      dbg_serial_ls = { dbg_serial_ls[8:0], data_out };
      dbg_serial_rs = { data_out, dbg_serial_rs[9:1] };
    end
    
  localparam K27_7_10b = 10'b110110_1000;  //  K27.7 Start of data packet indication
  localparam K28_0_10b = 10'b001111_0100;  //  K28.0 GPIO indication
  localparam K28_6_10b = 10'b001111_0110;  //  K28.6 I/O acknowledgement
  localparam K28_1_10b = 10'b001111_1001;  //  K28.1 Used for alignment
  localparam K28_2_10b = 10'b001111_0101;  //  K28.2 Rising trigger indication
  localparam K28_3_10b = 10'b001111_0011;  //  K28.3 Stream marker – see section 7.2
  localparam K28_4_10b = 10'b001111_0010;  //  K28.4 Falling trigger indication
  localparam K28_5_10b = 10'b001111_1010;  //  K28.5 Used for alignment
  localparam K28_7_10b = 10'b001111_1000;  //  K29.7 End of data packet indication
  
  localparam D21_5_10b = 10'b101010_1010;
  
    
  wire dbg_K28_5_10b_is_ls = (dbg_serial_ls == K28_5_10b) | (dbg_serial_ls == ~K28_5_10b);
  wire dbg_K28_1_10b_is_ls = (dbg_serial_ls == K28_1_10b) | (dbg_serial_ls == ~K28_1_10b);
  wire dbg_D21_5_10b_is_ls = (dbg_serial_ls == D21_5_10b) | (dbg_serial_ls == ~D21_5_10b);
  
  wire dbg_K28_5_10b_is_rs = (dbg_serial_rs == K28_5_10b) | (dbg_serial_rs == ~K28_5_10b);
  wire dbg_K28_1_10b_is_rs = (dbg_serial_rs == K28_1_10b) | (dbg_serial_rs == ~K28_1_10b);
  wire dbg_D21_5_10b_is_rs = (dbg_serial_rs == D21_5_10b) | (dbg_serial_rs == ~D21_5_10b);
`endif


  // --------------------------------------------------------------------
  //
  assign data_out = word_10b_out;


endmodule



