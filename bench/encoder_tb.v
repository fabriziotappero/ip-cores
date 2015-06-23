module encoder_tb;

   reg         clk;
   reg         rst;
   reg         d_in;
   wire  [1:0] d_out;

   encoder DUT
   (
      clk,
      rst,
      d_in,
      d_out
   );

   always
      #10   clk   =  ~clk;
   
   initial 
   begin
      clk   =  1'b0;
      rst   =  1'b0;
      d_in  =  1'b0;

      #110
      rst   =  1'b1;
      d_in  =  1'b0;
      
      #20
      d_in  =  1'b1;

      #20
      d_in  =  1'b0;

      #20
      d_in  =  1'b0;

      #20
      d_in  =  1'b0;

      #20
      d_in  =  1'b1;

      #20
      d_in  =  1'b0;

      #20
      d_in  =  1'b0;

      #20
      d_in  =  1'b1;

      #20
      d_in  =  1'b1;
      
      #20
      d_in  =  1'b0;
      
      #20
      d_in  =  1'b0;

      $finish();
      





   end
endmodule
