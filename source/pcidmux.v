// Copyright (C) 2005 Peio Azkarate, peio@opencores.org
// Copyright (C) 2006 Jeff Carr, jcarr@opencores.org
//
// I think what this does is handle 16 vs 32 bit pci accesses

module pcidmux ( clk_i, nrst_i, d_io, pcidatout_o, pcidOE_i, wbdatLD_i, wbrgdMX_i,
	wbd16MX_i, wb_dat_i, wb_dat_o, rg_dat_i, rg_dat_o);

	input clk_i;
	input nrst_i;

	// d_io			: inout std_logic_vector(31 downto 0);
	inout [31:0] d_io;
	output [31:0] pcidatout_o;

	input pcidOE_i;
	input wbdatLD_i;
	input wbrgdMX_i;
	input wbd16MX_i;

	input [15:0] wb_dat_i;
	output [15:0] wb_dat_o;
	input [31:0] rg_dat_i;
	output [31:0] rg_dat_o;

  	wire [31:0] pcidatin;
  	wire [31:0] pcidatout;

  	reg [15:0] wb_dat_is;

	// always @(negedge nrst_i or posedge clk_i or posedge wbdatLD_i or posedge wb_dat_i)
	always @(negedge nrst_i or posedge clk_i)
	begin
		if ( nrst_i == 0 )
			wb_dat_is <= 16'b1111_1111_1111_1111;
		else
			if ( wbdatLD_i == 1 )
				wb_dat_is <= wb_dat_i;
	end

	assign pcidatin = d_io;
	assign d_io = (pcidOE_i == 1'b1 ) ? pcidatout : 32'bZ;

	assign pcidatout [31:24] = (wbrgdMX_i == 1'b1) ? wb_dat_is [7:0]  : rg_dat_i [31:24];
	assign pcidatout [23:16] = (wbrgdMX_i == 1'b1) ? wb_dat_is [15:8] : rg_dat_i [23:16];
	assign pcidatout [15:8]  = (wbrgdMX_i == 1'b1) ? wb_dat_is [7:0]  : rg_dat_i [15:8];
	assign pcidatout [7:0]   = (wbrgdMX_i == 1'b1) ? wb_dat_is [15:8] : rg_dat_i [7:0];

	assign pcidatout_o = pcidatout;
	assign rg_dat_o = pcidatin;

	assign wb_dat_o [15:8] = (wbd16MX_i == 1'b1) ? pcidatin [23:16] : pcidatin [7:0];
	assign wb_dat_o [7:0]  = (wbd16MX_i == 1'b1) ? pcidatin [31:24] : pcidatin [15:8];

endmodule 
