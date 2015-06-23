//
//
//


module
  cx_decoder
  #(
    parameter LOG_LEVEL      = 3
  )
  (
    input data_in
  );

  // --------------------------------------------------------------------
  //
  wire  [9:0] data_out;
  wire        clock;
  wire        strobe;

  cx_bit_align
    i_cx_bit_align
    (
      .data_in(data_in),
      .data_out(data_out),
      .clock(clock),
      .strobe(strobe),
      .data_sent_lsb( 1'b1 ),
      .reset( 1'b0 )
    );
    

  // --------------------------------------------------------------------
  //
  reg         dispin = 0;
  wire  [8:0] dataout;
  reg   [7:0] dataout_r;
  reg         k_code;
  wire        dispout;
  wire        code_err;
  reg         code_err_r;
  wire        disp_err;
  reg         disp_err_r;

  decode_8b10b
    i_decode_8b10b
    (
      .datain(data_out),
      .dispin(dispin),
      .dataout(dataout),
      .dispout(dispout),
      .code_err(code_err),
      .disp_err(disp_err)
    ) ;


  // --------------------------------------------------------------------
  //
  always @( negedge strobe )
    begin
      dispin              <= dispout;
      {k_code, dataout_r} <= dataout;
      code_err_r          <= code_err;
      disp_err_r          <= disp_err;      
    end  
    
    
  // --------------------------------------------------------------------
  //
  wire [4:0]  code_5b_6b  = dataout_r[4:0];
  wire [2:0]  code_3b_4b  = dataout_r[7:5];

  wire [7:0]  data_8b     = k_code ? 8'hxx : dataout_r;
  
  always @( negedge strobe )
    if( LOG_LEVEL >= 4 & k_code )
      $display( "#|# %15.t | cx_decoder: K code - K.%d.%d", $time, code_5b_6b, code_3b_4b );
  
  always @( negedge strobe )
    if( LOG_LEVEL >= 4 & ~k_code )
      $display( "#|# %15.t | cx_decoder: D code - D.%d.%d", $time, code_5b_6b, code_3b_4b );
  
  
endmodule



