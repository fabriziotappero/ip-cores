//  Copyright (C) 2005 Peio Azkarate, peio@opencores.org
//  Copyright (C) 2006 Jeff Carr, jcarr@opencores.org
//	Copyleft GPL v2

module pcidec_new (clk_i, nrst_i, ad_i, cbe_i, idsel_i, bar0_i, memEN_i,
	pciadrLD_i, adrcfg_o, adrmem_o, adr_o, cmd_o);

   	// General 
	input clk_i;
   	input nrst_i;
	// pci 
	input [31:0] ad_i;
	input [3:0] cbe_i;
	input idsel_i;
	// control
	input [31:25] bar0_i;
	input memEN_i;
	input pciadrLD_i;
	output adrcfg_o;
	output adrmem_o;
	output [24:1] adr_o;
	output [3:0] cmd_o;

  	reg [31:0] adr;
  	reg [3:0] cmd;
  	reg idsel_s;
	wire a1;

	//+-------------------------------------------------------------------------+
	//|  Load PCI Signals														|
	//+-------------------------------------------------------------------------+

	always @( negedge nrst_i or posedge clk_i )
	begin
		if( nrst_i == 0 )
		begin
			adr <= 23'b1111_1111_1111_1111_1111_111;
			cmd <= 3'b111;
			idsel_s <= 1'b0;
		end
		else
			if ( pciadrLD_i == 1 )
			begin
				adr <= ad_i;
				cmd <= cbe_i;
				idsel_s <= idsel_i;
			end
	end

	assign adrmem_o = (
		( memEN_i == 1'b1 ) &&
		( adr [31:25] == bar0_i ) &&
		( adr [1:0] == 2'b00 ) &&
		( cmd [3:1] == 3'b011 )
	) ? 1'b1 : 1'b0;

	assign adrcfg_o = (
		( idsel_s == 1'b1 ) &&
		( adr [1:0] == 2'b00 ) &&
		( cmd [3:1] == 3'b101 )
	) ? 1'b1 : 1'b0;

	assign a1 = ~ ( cbe_i [3] && cbe_i [2] );
	assign adr_o = {adr [24:2], a1};
	assign cmd_o = cmd;

endmodule
