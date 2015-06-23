module mem
(
   clk,
   wr,
   addr,
   d_i,
   d_o
);

   input                clk;
   input                wr;
   input       [9:0]    addr;
   input       [7:0]    d_i;
   output reg  [7:0]    d_o;
   
   reg         [7:0]    mem   [1023:0];



   always @ (posedge clk)
   begin
      if(wr)
         mem[addr]   <= d_i;
      d_o  <=  mem[addr];
          
   end
endmodule
