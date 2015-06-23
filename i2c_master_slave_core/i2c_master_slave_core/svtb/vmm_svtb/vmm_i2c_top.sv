//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements I2C M/S Core's Top Module.								//
//	Top Module instantiates program block and DUT and connects them with each other.	//
//	sda and scl lines are anded with scl and sda lines from both sides (DUT as well as	//
//  Environment). Both sda and scl lines are pulled up by verilog pullup construct.		// 		
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm_clkgen.sv"
`include "vmm_program_test.sv"


module top;

	i2c_pin_if pif();					// Interface 
	clkgen c_gen(pif);					// Clock Generator
	program_test p_test(pif);			// Program Block

	wire dut_sda_o;
	wire dut_sda_oe;
	wire dut_sda_in;
	wire dut_scl_o;
	wire dut_scl_oe;
	wire dut_scl_in;
	wire temp_sda;
	wire temp_scl;
    
	assign dut_sda_o = 1'b0;
	assign temp_sda = pif.sda_oe & dut_sda_oe;
	assign temp_scl = pif.scl_oe & dut_scl_oe;
	assign pif.sda = temp_sda ? 1'bz : 1'b0;
	assign pif.scl = temp_scl ? 1'bz : 1'b0;
    pullup p1_if(pif.sda);				// Pull up sda line
    pullup p2_if(pif.scl);				// Pull up scl line

// I2C Core (DUT)	
block i2c_core( .scl_in(pif.scl),
				.scl_o(dut_scl_o),
				.scl_oe(dut_scl_oe),
				.sda_in(pif.sda),
				.sda_o(dut_sda_o),
				.sda_oe(dut_sda_oe),
				.wb_add_i(pif.addr_in),
				.wb_data_i(pif.data_in),
				.wb_data_o(pif.data_out),
				.wb_stb_i(pif.wb_stb_i),
				.wb_cyc_i(pif.wb_cyc_i),
				.wb_we_i(pif.we),
				.wb_ack_o(pif.ack_o),
				.irq(pif.irq),
				.trans_comp(pif.trans_comp),
				.wb_clk_i(pif.clk),
				.wb_rst_i(pif.rst)
				);

endmodule
