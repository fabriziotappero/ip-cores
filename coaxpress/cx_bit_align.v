//
//
//


module
  cx_bit_align
  (
    input               data_in,
    output reg  [9:0]   data_out,
    output              clock,
    output              strobe,
    input               data_sent_lsb,
    input               reset
  );

  // using big endian as presented in US4,486,739
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

//  wire clock_n;
//  assign  clock = clock_n;

  // --------------------------------------------------------------------
  //
  recover_clock
    i_recover_clock
    (
      .in(data_in),
      .clock(clock)
    );


  // --------------------------------------------------------------------
  // four word shift register
  reg [39:0] data_in_r;

  always @( negedge clock )
    if( data_sent_lsb )
      data_in_r <= { data_in_r[38:0], data_in };
    else
      data_in_r <= { data_in, data_in_r[39:1] };


  // --------------------------------------------------------------------
  //
  integer bit_count = 0;

  always @( negedge clock )
    if( bit_count == 9 )
      bit_count <= 0;
    else
      bit_count <= bit_count + 1;


  // --------------------------------------------------------------------
  //
  wire p3_is_D21_5_msb = (data_in_r[39:30] == D21_5_10b) | (data_in_r[39:30]  == ~D21_5_10b);
  wire p2_is_K28_1_msb = (data_in_r[29:20] == K28_1_10b) | (data_in_r[29:20]  == ~K28_1_10b);
  wire p1_is_K28_1_msb = (data_in_r[19:10] == K28_1_10b) | (data_in_r[19:10]  == ~K28_1_10b);
  wire p0_is_K28_5_msb = (data_in_r[9:0]   == K28_5_10b) | (data_in_r[9:0]    == ~K28_5_10b);

  wire p3_is_D21_5_lsb = (data_in_r[9:0]    == D21_5_10b) | (data_in_r[9:0]    == ~D21_5_10b);
  wire p2_is_K28_1_lsb = (data_in_r[19:10]  == K28_1_10b) | (data_in_r[19:10]  == ~K28_1_10b);
  wire p1_is_K28_1_lsb = (data_in_r[29:20]  == K28_1_10b) | (data_in_r[29:20]  == ~K28_1_10b);
  wire p0_is_K28_5_lsb = (data_in_r[39:30]  == K28_5_10b) | (data_in_r[39:30]  == ~K28_5_10b);

  wire found_idle_word = data_sent_lsb ?  (p0_is_K28_5_lsb & p1_is_K28_1_lsb & p2_is_K28_1_lsb & p3_is_D21_5_lsb) :
                                          (p0_is_K28_5_msb & p1_is_K28_1_msb & p2_is_K28_1_msb & p3_is_D21_5_msb);

  integer bit_select = 'hx;

  always @( posedge clock )
    if( reset )
      bit_select <= 'hx;
    else if( found_idle_word )
      bit_select <= bit_count;


  // --------------------------------------------------------------------
  //  register parallel outputs in litle endian bit order
  integer i;
  
  always @( posedge clock )
    if( bit_count == bit_select )
      for( i = 0; i < 10; i = i + 1 )
        data_out[i] <= data_in_r[9-i];


  // --------------------------------------------------------------------
  // debug  --  look for control codes
`ifdef DEBUG_COAXPRESS
  wire dbg_p0_is_K27_7 = (data_in_r[9:0]   == K27_7_10b) | (data_in_r[9:0]    == ~K27_7_10b);
  wire dbg_p0_is_K28_0 = (data_in_r[9:0]   == K28_0_10b) | (data_in_r[9:0]    == ~K28_0_10b);
  wire dbg_p0_is_K28_6 = (data_in_r[9:0]   == K28_6_10b) | (data_in_r[9:0]    == ~K28_6_10b);
  wire dbg_p0_is_K28_1 = (data_in_r[9:0]   == K28_1_10b) | (data_in_r[9:0]    == ~K28_1_10b);
  wire dbg_p0_is_K28_2 = (data_in_r[9:0]   == K28_2_10b) | (data_in_r[9:0]    == ~K28_2_10b);
  wire dbg_p0_is_K28_3 = (data_in_r[9:0]   == K28_3_10b) | (data_in_r[9:0]    == ~K28_3_10b);
  wire dbg_p0_is_K28_4 = (data_in_r[9:0]   == K28_4_10b) | (data_in_r[9:0]    == ~K28_4_10b);
  wire dbg_p0_is_K28_5 = (data_in_r[9:0]   == K28_5_10b) | (data_in_r[9:0]    == ~K28_5_10b);
  wire dbg_p0_is_K28_7 = (data_in_r[9:0]   == K28_7_10b) | (data_in_r[9:0]    == ~K28_7_10b);
  wire dbg_p0_is_D21_5 = (data_in_r[9:0]   == D21_5_10b) | (data_in_r[9:0]    == ~D21_5_10b);

  // debug  --  four word shift register, reverse bit order
  reg [39:0] dbg_data_in_n_r;

  always @( negedge clock )
    dbg_data_in_n_r <= { data_in, dbg_data_in_n_r[39:1] };

  wire dbg_p0_is_K27_7_n = (dbg_data_in_n_r[9:0]   == K27_7_10b) | (dbg_data_in_n_r[9:0]    == ~K27_7_10b);
  wire dbg_p0_is_K28_0_n = (dbg_data_in_n_r[9:0]   == K28_0_10b) | (dbg_data_in_n_r[9:0]    == ~K28_0_10b);
  wire dbg_p0_is_K28_6_n = (dbg_data_in_n_r[9:0]   == K28_6_10b) | (dbg_data_in_n_r[9:0]    == ~K28_6_10b);
  wire dbg_p0_is_K28_1_n = (dbg_data_in_n_r[9:0]   == K28_1_10b) | (dbg_data_in_n_r[9:0]    == ~K28_1_10b);
  wire dbg_p0_is_K28_2_n = (dbg_data_in_n_r[9:0]   == K28_2_10b) | (dbg_data_in_n_r[9:0]    == ~K28_2_10b);
  wire dbg_p0_is_K28_3_n = (dbg_data_in_n_r[9:0]   == K28_3_10b) | (dbg_data_in_n_r[9:0]    == ~K28_3_10b);
  wire dbg_p0_is_K28_4_n = (dbg_data_in_n_r[9:0]   == K28_4_10b) | (dbg_data_in_n_r[9:0]    == ~K28_4_10b);
  wire dbg_p0_is_K28_5_n = (dbg_data_in_n_r[9:0]   == K28_5_10b) | (dbg_data_in_n_r[9:0]    == ~K28_5_10b);
  wire dbg_p0_is_K28_7_n = (dbg_data_in_n_r[9:0]   == K28_7_10b) | (dbg_data_in_n_r[9:0]    == ~K28_7_10b);

  // debug  --  assume bit select
  reg [9:0] dbg_data_out;

  always @( posedge clock )
    if( bit_count == 2 )
      dbg_data_out <= data_in_r[9:0];

  wire dbg_data_out_K28_5 = (dbg_data_out   == K28_5_10b) | (dbg_data_out    == ~K28_5_10b);
  wire dbg_data_out_K28_1 = (dbg_data_out   == K28_1_10b) | (dbg_data_out    == ~K28_1_10b);
  wire dbg_data_out_D21_5 = (dbg_data_out   == D21_5_10b) | (dbg_data_out    == ~D21_5_10b);
`endif


  // --------------------------------------------------------------------
  //  register parallel outputs in litle endian bit order
  assign strobe = (bit_count === bit_select);

endmodule



