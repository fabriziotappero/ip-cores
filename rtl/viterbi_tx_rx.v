module viterbi_tx_rx(
   clk,
   rst,
   encoder_i,
   enable_encoder_i,
   decoder_o
);
   input    clk;
   input    rst;
   input    encoder_i;
   input    enable_encoder_i;
   output   decoder_o;

   wire  [1:0] encoder_o;


   reg   [3:0] error_counter;
   reg   [1:0] encoder_o_reg;
   
   reg         enable_decoder_in;
   wire        valid_encoder_o;



   always @ (posedge clk or negedge rst)
   begin
      if(rst==1'b0)
      begin  
         error_counter  <= 4'd0;
         encoder_o_reg  <= 2'b00;
         enable_decoder_in <= 1'b0;
      end
      else
      begin   
         enable_decoder_in <= valid_encoder_o; 
         encoder_o_reg  <= 2'b00;
         error_counter  <= error_counter + 4'd1;
         if(error_counter==4'b1111)
            encoder_o_reg  <= {~encoder_o[1],encoder_o[0]};
         else
            encoder_o_reg  <= {encoder_o[1],encoder_o[0]};
      end   
   end


   encoder encoder1
   (
      .clk(clk),
      .rst(rst),
      .enable_i(enable_encoder_i),
      .d_in(encoder_i),
      .valid_o(valid_encoder_o),
      .d_out(encoder_o)
   );

   decoder decoder1
   (
      .clk(clk),
      .rst(rst),
      .enable(enable_decoder_in),
      .d_in(encoder_o_reg),
      .d_out(decoder_o)
   );
endmodule
