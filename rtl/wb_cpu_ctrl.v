//////////////////////////////////////////////////////////////////////////////////
// Wishbone Register File
//
// $Id: wb_cpu_ctrl.v,v 1.1 2008-12-01 02:00:10 hharte Exp $
//
// (C) 2007 Howard M. Harte
//
//////////////////////////////////////////////////////////////////////////////////

module wb_cpu_ctrl (clk_i, nrst_i, wb_adr_i, wb_dat_o, wb_dat_i, wb_sel_i, wb_we_i,
						 wb_stb_i, wb_cyc_i, wb_ack_o, datareg0, datareg1);

	input		clk_i;
	input 	nrst_i;
	input 	[2:0] wb_adr_i;
	output reg [31:0] wb_dat_o;
  	input 	[31:0] wb_dat_i;
	input 	[3:0] wb_sel_i;
  	input 	wb_we_i;
	input 	wb_stb_i;
	input 	wb_cyc_i;
	output reg wb_ack_o;
	output	[31:0] datareg0;
	output	[31:0] datareg1;

	//
	// generate wishbone register bank writes
	wire wb_acc = wb_cyc_i & wb_stb_i;    // WISHBONE access
	wire wb_wr  = wb_acc & wb_we_i;       // WISHBONE write access

	reg	[31:0]	datareg0;
	reg	[31:0]	datareg1;

	always @(posedge clk_i or negedge nrst_i)
		if (~nrst_i)				// reset registers
			begin
				datareg0 <= 32'h87654321;
				datareg1 <= 32'h12345678;
			end
		else if(wb_wr)          // wishbone write cycle
			case (wb_adr_i) 		// synopsys full_case parallel_case
				3'b000:	datareg0 <= wb_dat_i;
				3'b001:	datareg1 <= wb_dat_i;
			endcase

	//
   // generate dat_o
	always @(posedge clk_i)
		case (wb_adr_i) 	// synopsys full_case parallel_case
			3'b000:	wb_dat_o <= datareg0;
			3'b001:	wb_dat_o <= datareg1;
		endcase

   //
   // generate ack_o
   always @(posedge clk_i)
		wb_ack_o <= #1 wb_acc & !wb_ack_o;

endmodule
