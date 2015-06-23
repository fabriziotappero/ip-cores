
// ported from university project for an ALU in VHDL
module alu_adder  (
                    x          ,
                    y          ,
                    carry_in   ,
                    ORsel      ,
                    XORsel     ,

                    carry_out  ,
                    xor_result ,
                    or_result  ,
                    and_result ,
                    z          
                  );

  parameter ADDER_WIDTH = 8;

  input       [ADDER_WIDTH - 1 :0] x          ;
  input       [ADDER_WIDTH - 1 :0] y          ;
  input                            carry_in   ;
  input                            ORsel      ;
  input                            XORsel     ;

  output      [ADDER_WIDTH - 1 :0] xor_result ;
  output      [ADDER_WIDTH - 1 :0] or_result  ;
  output      [ADDER_WIDTH - 1 :0] and_result ;
  output      [ADDER_WIDTH     :0] carry_out  ;
  output      [ADDER_WIDTH - 1 :0] z          ;

  reg         [ADDER_WIDTH     :0] carry_out  ;
  reg         [ADDER_WIDTH - 1 :0] z          ;

  wire	      [ADDER_WIDTH - 1 :0] XxorY      ;
  wire        [ADDER_WIDTH - 1 :0] XandY      ;
  wire        [ADDER_WIDTH - 1 :0] XorY       ;

  // loop variable register
  reg   [31:0] i;
  
	////////////////////////////////////////////////////
  // adder
  ////////////////////////////////////////////////////
  assign  xor_result	= XxorY   ;
  assign  or_result	  = XorY    ;
  assign  and_result	= XandY   ;

	assign  XxorY	      =	x ^ y   ;
	assign  XandY	      =	x & y   ;
	assign  XorY	      =	x | y   ;
  

  //  adder
  always  @(x or y or carry_out or XxorY or XandY or XorY or XORsel or ORsel)
  begin
    carry_out[0] <= carry_in;
    for (i = 0; i < ADDER_WIDTH ; i = i+1)
    begin
        z[i]            <=  XxorY[i] ^ ( carry_out[i] & XORsel);
        carry_out[i+1]  <=  XandY[i] | ((carry_out[i] | ORsel) & XorY[i]);
    end
  end
  

endmodule


