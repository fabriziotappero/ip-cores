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
   output reg     d_o;
   
   reg            mem   [1023:0];


   always @ (posedge clk)
   begin
      if(wr)
         mem[addr]   <= d_i;
      d_o  <=  mem[addr];
  end
endmodule
