//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements I2C M/S Core's Program Block.							//
//	This Program Block instantiate i2c_env and run the main thread of environment.	 	//
//																						//		
//																						//
//////////////////////////////////////////////////////////////////////////////////////////
`include "vmm_i2c_env.sv"

program program_test(i2c_pin_if pif);

initial begin
	i2c_env env;
	env = new(pif);
	env.run();
end

endprogram


