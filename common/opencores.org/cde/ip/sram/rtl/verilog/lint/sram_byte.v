 module 
  cde_sram_byte 
    #( parameter 
      ADDR=10,
      WORDS=1024,
      WRITETHRU=0
      )
     (
 input wire 		  clk,
 input wire 		  cs,
 input wire 		  be,
 input wire 		  rd,
 input wire 		  wr,
 input wire [ ADDR-1 : 0] addr,
 input wire [ 7 : 0] 	  wdata,
 output reg [ 7 : 0] 	  rdata);
  // Simple loop back for linting and code coverage
  always@(posedge clk)
        if( rd && cs ) rdata             <= wdata;
        else           rdata             <= 8'hff;
  endmodule
