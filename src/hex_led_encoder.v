// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module 
  hex_led_encoder(
                    output  [6:0] encoder,
                    input   [3:0] nibble
                  );
                  

  //---------------------------------------------------
  // hex encoder
  reg [6:0] hex_led_encoder_r;
                  
  always @(*)
    case( nibble )
      4'b0000:  hex_led_encoder_r = 7'h3f;
      4'b0001:  hex_led_encoder_r = 7'h06;
      4'b0010:  hex_led_encoder_r = 7'h5b;
      4'b0011:  hex_led_encoder_r = 7'h4f;
      4'b0100:  hex_led_encoder_r = 7'h66;
      4'b0101:  hex_led_encoder_r = 7'h6d;
      4'b0110:  hex_led_encoder_r = 7'h7d;
      4'b0111:  hex_led_encoder_r = 7'h07;
      4'b1000:  hex_led_encoder_r = 7'h7f;
      4'b1001:  hex_led_encoder_r = 7'h6f;
      4'b1010:  hex_led_encoder_r = 7'h77;
      4'b1011:  hex_led_encoder_r = 7'h7c;
      4'b1100:  hex_led_encoder_r = 7'h39;
      4'b1101:  hex_led_encoder_r = 7'h5e;
      4'b1110:  hex_led_encoder_r = 7'h79;
      4'b1111:  hex_led_encoder_r = 7'h71;
      default:  hex_led_encoder_r = 7'h7f;
    endcase
    
    
  //---------------------------------------------------
  // outputs
  assign encoder = ~hex_led_encoder_r;
  
                  
endmodule
                  
                  