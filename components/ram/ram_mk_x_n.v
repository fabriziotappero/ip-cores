module ram_mk_x_n (clk, reset, enable, rw_mask, rd, wr, address, data_in, data_out);
  
  parameter Mk  =  1;
  parameter N   = 16;
   
  input                     clk         ;
  input                     reset       ;
  input                     enable      ;
  input       [N-1:0]       rw_mask     ;
  input       [(Mk*10-1):0] address     ;
  input                     rd          ;
  input                     wr          ;
  input       [N-1:0]       data_in     ;
  output      [N-1:0]       data_out    ;

  reg         [N-1:0]       data_out_reg;

  reg [N-1:0] mem [((Mk*1024)-1):0]  ;
  
  assign data_out = data_out_reg;
  // read
  always @(posedge clk)
    if (!reset & rd)
      data_out_reg <= mem[address];
  // write    
  always @(posedge clk)
    if (!reset & wr)
      mem[address] <= data_in;
      
      
  

endmodule
