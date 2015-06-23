// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module
  sync_fifo
  (
    input       [12:0]  fifo_wr_data,
    output reg  [12:0]  fifo_rd_data,
    input               fifo_wr_en,
    input               fifo_rd_en,

    output reg          fifo_full,
    output reg          fifo_empty,

    input               fifo_clock,
    input               fifo_reset
  );

  // -----------------------------
  //
  wire      wr_en = fifo_wr_en & ~fifo_full;
  reg [2:0] wr_ptr;

  always @( posedge fifo_clock )
    if( fifo_reset )
      wr_ptr <= 0;
    else if( wr_en )
      wr_ptr <= wr_ptr + 1;

  wire      rd_en = fifo_rd_en & ~fifo_empty;
  reg [2:0] rd_ptr;

  always @( posedge fifo_clock )
    if( fifo_reset )
      rd_ptr <= 0;
    else if( rd_en )
      rd_ptr <= rd_ptr + 1;


  // -----------------------------
  //
  wire ptr_are_equal      = wr_ptr[1:0] == rd_ptr[1:0];
  wire ptr_msb_are_equal  = ~(wr_ptr[2] ^ rd_ptr[2]);

  always @( posedge fifo_clock )
    if( fifo_reset )
      fifo_full <= 0;
    else
      fifo_full <= ptr_are_equal & ~ptr_msb_are_equal ;

  always @( posedge fifo_clock )
    if( fifo_reset )
      fifo_empty <= 1;
    else
      fifo_empty <= ptr_are_equal & ptr_msb_are_equal ;


  // -----------------------------
  //
  reg [12:0] reg_file[3:0];

  always @( posedge fifo_clock )
    if( wr_en )
      reg_file[wr_ptr[1:0]] <= fifo_wr_data;

//  always @( posedge fifo_clock )
//    if( rd_en )
//      fifo_rd_data <= reg_file[rd_ptr[1:0]];

  always @( * )
    fifo_rd_data <= reg_file[rd_ptr[1:0]];


endmodule


