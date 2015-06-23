module mem_disp
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
   input          d_i;
   output         d_o;
   
   reg            mem   [1023:0];

   assign d_o  =  mem[addr];

   always @ (posedge clk)
   begin
      if(wr)
         mem[addr]   <= d_i;
          
   end
endmodule
