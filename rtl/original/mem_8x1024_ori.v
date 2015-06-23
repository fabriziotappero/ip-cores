module mem
(
   clk,
   wr,
   addr,
   d_i,
   d_o
);

   input          clk;
   input          wr;
   input [9:0]    addr;
   input [7:0]    d_i;
   output[7:0]    d_o;
   
   reg   [7:0]    mem   [1023:0];

   assign d_o  =  mem[addr];

   always @ (posedge clk)
   begin
      if(wr)
         mem[addr]   <= d_i;
          
   end
endmodule
