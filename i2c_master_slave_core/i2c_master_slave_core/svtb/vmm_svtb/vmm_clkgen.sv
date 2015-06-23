//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code generates clock for the interface.									//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

module clkgen(i2c_pin_if i);

  initial begin
    forever begin
      #5 i.clk = 1;
      #5 i.clk = 0;
    end
  end

endmodule

