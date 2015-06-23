`include "define.h"
//Feb.25.2005 Verilog2001 Style
//Jan.20.2005 implict event list
//Jun.14.2004 Initial Version
//Jul.4.2004 sensibity list bug fix
//Jul.5.2004 less area version

module alu (input [31:0] a,b,
		     output reg [31:0] alu_out,
		     input [3:0]	alu_func);

parameter   [3:0] ALU_NOTHING		 	   =4'b0000,
			      ALU_ADD     			   =4'b0001,
				ALU_SUBTRACT  		   =4'b0010,
			      ALU_LESS_THAN_UNSIGNED =4'b0101, //Jul.5.2004
				ALU_LESS_THAN_SIGNED     =4'b0100, //Jul.5.2004
				ALU_OR  				   =4'b0011,
			      ALU_AND 				   =4'b0110,
				ALU_XOR 				   =4'b0111,
				ALU_NOR 				   =4'b1000;
  
        reg [32:0] sum;

        always @* begin //
                case (alu_func)
                        ALU_NOTHING    : alu_out=32'h0000;
                        ALU_ADD        : alu_out=a+b;
                        ALU_SUBTRACT   : alu_out=a+~b+1'b1;//a-b;
                        ALU_OR         : alu_out=a | b;
                        ALU_AND        : alu_out=a & b;
                        ALU_XOR        : alu_out=a ^ b;
                        ALU_NOR        : alu_out=~(a | b);
                        ALU_LESS_THAN_UNSIGNED : alu_out=a < b;//Jun.29.2004
                        ALU_LESS_THAN_SIGNED: begin 
                                                 sum={a[31],a}+~{b[31],b}+1'b1;//a-b                                                                      $signed(a) > $signed(b);
                                                 alu_out={31'h0000_0000,sum[32]}; 
                                               end                      
                        default : alu_out=32'h0000_0000;


                endcase
        end
endmodule



