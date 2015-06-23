
`timescale 1ps/1ps

module tessera_ram_tiny (
	sys_wb_res,
	sys_wb_clk,
	wb_cyc_i,
	wb_stb_i,
	wb_adr_i,
	wb_sel_i,
	wb_we_i,
	wb_dat_i,
	wb_cab_i,
	wb_dat_o,
	wb_ack_o,
	wb_err_o
);
	// system
	input		sys_wb_res;
	input		sys_wb_clk;
	// WishBone Slave
	input		wb_cyc_i;
	input		wb_stb_i;
	input	[31:0]	wb_adr_i;
	input	[3:0]	wb_sel_i;
	input		wb_we_i;
	input	[31:0]	wb_dat_i;
	input		wb_cab_i;
	output	[31:0]	wb_dat_o;
	output		wb_ack_o;
	output		wb_err_o;

	wire		active;
	wire		mask;
	wire	[9:2]	address;
	wire	[3:0]	write;
	wire	[3:0]	read;
	wire	[31:0]	q;

// 0x0000_0000 - 0x0000_0fff 4Kbyte For Exception,so only 16inst(64Byte). phy is 1024Byte
	
	assign active	= wb_cyc_i && wb_stb_i;
	assign mask	= !(wb_adr_i[7:6]==2'd0);
	assign address	= {wb_adr_i[11:8],wb_adr_i[5:2]};

	assign write	= {4{(active&& wb_we_i)&&!mask}} & wb_sel_i;
	assign read	= {4{(active&&!wb_we_i)&&!mask}} & wb_sel_i;

	assign wb_err_o = 1'b0;

	//
	// 1wait(safety)
	//
	wire		clk;
	reg		ack;
	assign clk = sys_wb_clk;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res) ack <= 1'b0;
		else		ack <= active && !ack;
	assign wb_ack_o = (active) ? ack: 1'b0;

	//
	// no-wait(fast and risky,data valid timing is negedge)
	//
//	wire		clk;
//	wire		ack;
//	assign ack = active;
//	assign clk = !sys_wb_clk;
//	assign wb_ack_o = active;

	assign wb_dat_o = {
		((read[3]&&ack) ? q[31:24]: 8'h00),
		((read[2]&&ack) ? q[23:16]: 8'h00),
		((read[1]&&ack) ? q[15: 8]: 8'h00),
		((read[0]&&ack) ? q[ 7: 0]: 8'h00)
	};
	
	// sdram_wbif(DOMAIN WinsboneClock)
	RAM_256 i3_RAM_INT (
		.address(	address), //8bit=256byte,all 1024byte
		.clock(		clk),
		.data(		wb_dat_i[31:24]),
		.wren(		write[3]),
		.q(		q[31:24])
	);
	RAM_256 i2_RAM_INT (
		.address(	address),
		.clock(		clk),
		.data(		wb_dat_i[23:16]),
		.wren(		write[2]),
		.q(		q[23:16])
	);
	RAM_256 i1_RAM_INT (
		.address(	address),
		.clock(		clk),
		.data(		wb_dat_i[15:8]),
		.wren(		write[1]),
		.q(		q[15:8])
	);
	RAM_256 i0_RAM_INT (
		.address(	address),
		.clock(		clk),
		.data(		wb_dat_i[7:0]),
		.wren(		write[0]),
		.q(		q[7:0])
	);
endmodule

