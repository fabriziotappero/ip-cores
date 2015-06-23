module viterbi_tx_rx_tb();
   reg clk;
   reg rst;
   reg encoder_i;
   reg enable_encoder_i;
   wire decoder_o;

   viterbi_tx_rx vtr(
      .clk(clk),
      .rst(rst),
      .encoder_i(encoder_i),
      .enable_encoder_i(enable_encoder_i),
      .decoder_o(decoder_o)
   );

   always
      #50   clk   =  ~clk;


   initial
   begin
      clk      =  1'b1;
      rst      =  1'b0;
      encoder_i=  1'b0;   
      enable_encoder_i  =  1'b0;
      #1000
      rst   =  1'b1;
      encoder_i=  1'b0;  
      enable_encoder_i  =  1'b1;
      #100
      encoder_i=  1'b1; 
      #100
      encoder_i=  1'b0;   
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      
      #100
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;       
      #100
      encoder_i=  1'b0;   
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b0;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1;  
      #100
      encoder_i=  1'b1; 


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #1000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;

      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;

      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;

      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;

      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;

      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;

      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


      #10000
      encoder_i=  1'b0;
      #100
      encoder_i=  1'b1;


 


      #1000000
      $finish();
   end

   
endmodule
