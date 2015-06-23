
module hex2seg(
          input      [3:0] hex
        , output reg [7:0] seg
        );


        always @(hex)
                case (hex)        // hgfedcba
                        4'h0:seg<=~8'b00111111;
                        4'h1:seg<=~8'b00000110;
                        4'h2:seg<=~8'b01011011;
                        4'h3:seg<=~8'b01001111;
                        4'h4:seg<=~8'b01100110;
                        4'h5:seg<=~8'b01101101;
                        4'h6:seg<=~8'b01111101;
                        4'h7:seg<=~8'b00000111;
                        4'h8:seg<=~8'b01111111;
                        4'h9:seg<=~8'b01101111;
                        4'ha:seg<=~8'b01110111;
                        4'hb:seg<=~8'b01111100;
                        4'hc:seg<=~8'b00111001;
                        4'hd:seg<=~8'b01011110;
                        4'he:seg<=~8'b01111001;
                        4'hf:seg<=~8'b01110001;
                endcase
endmodule
