/*
	SQmusic
	logarithmic PWM controller to use with SQMUSIC
  Version 0.1, tested on simulation only with Capcom's 1942

  (c) Jose Tejada Gomez, 11th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/
`timescale 1ns / 1ps
module SQM_PWM(
  input clk, // VHF clock (>33 MHz)
  input reset_n,
 	input [3:0]A, input [3:0]B, input [3:0]C, // input channels
	output Y
);


SQM_PWM_1 apwm( .clk(clk), .reset_n(reset_n), .din(A), .pwm(y_a) );
SQM_PWM_1 bpwm( .clk(clk), .reset_n(reset_n), .din(B), .pwm(y_b) );
SQM_PWM_1 cpwm( .clk(clk), .reset_n(reset_n), .din(C), .pwm(y_c) );

assign Y=y_a | y_b | y_c;
endmodule

////////////////////////////////////////////////////
// 1 channel only
module SQM_PWM_1(
  input clk, // VHF clock (>33 MHz)
  input reset_n,
  input [3:0]din,
  output reg pwm
);

reg [7:0] count, last0, last1;
wire [7:0]rep0, rep1;

SQM_PWM_LOG dec( .din(din), .rep0(rep0), .rep1(rep1), .zero(zero) );

always @(posedge clk or negedge reset_n) begin
  if( !reset_n ) begin
    count<=0;
    last0<=0;
    last1<=1;
  end 
  else
    if( zero ) begin
      pwm  <=0;
      count<=0;
    end
    else if( last0!=rep0 || last1!=rep1 ) begin
      last0 <= rep0;
      last1 <= rep1;
      count <= 0;
      pwm   <=0;
    end
    else if( last0==1 && last1==1 ) begin
      pwm  <=clk;
      count<=0;
    end
    else begin
      if( pwm && count==last1-1 ) begin
        count<=0;
        pwm  <=0;
      end
      else if( !pwm && count==last0-1 ) begin
        count<=0;
        pwm  <=1;
      end
      else begin
        count<=count+1;
        pwm  <=pwm;
      end
    end
end
endmodule

module SQM_PWM_LOG(
	input [3:0]din,
	output reg [7:0] rep0, // "L" repetition
	output reg [7:0] rep1, // "H" repetition
	output zero
);

assign zero = din==0;

always @(din)
	case (din)
		1: begin
		  rep0=64;
		  rep1=1;
		end
		2: begin
		  rep0=61;
		  rep1=1;
		end
		3: begin
		  rep0=32;
		  rep1=1;
		end
		4: begin
		  rep0=61;
		  rep1=2;
		end
		5: begin
		  rep0=16;
		  rep1=1;
		end
		6: begin
		  rep0=61;
		  rep1=4;
		end
		7: begin
		  rep0=8;
		  rep1=1;
		end
		8: begin
		  rep0=61;
		  rep1=8;
		end
		9: begin
		  rep0=61;
		  rep1=16;
		end
	 10: begin
		  rep0=61;
		  rep1=8;
		end
	 11: begin
		  rep0=2;
		  rep1=1;
		end
	 12: begin
		  rep0=61;
		  rep1=32;
		end
	 13: begin
		  rep0=1;
		  rep1=1;
		end
	 14: begin
		  rep0=61;
		  rep1=64;
		end
	 15: begin
		  rep0=1;
		  rep1=1;
		end
default: begin
		  rep0=1;
		  rep1=1;
		end 
	endcase	
endmodule
