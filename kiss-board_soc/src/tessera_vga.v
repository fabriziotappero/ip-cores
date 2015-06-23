
`timescale 1ps/1ps

module tessera_vga_wbif (
	res,
	clk,
	wb_cyc_i,
	wb_stb_i,
	wb_adr_i,
	wb_sel_i,
	wb_we_i,
	wb_dat_i,
	wb_cab_i,
	wb_dat_o,
	wb_ack_o,
	wb_err_o,
	enable,
	base
);
	input		res;
	input		clk;
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
	output		enable;
	output	[23:11]	base;
	reg	[31:0]	reg1;		// bit0 scan_enable
	reg	[31:0]	reg0;		// bit23-11 base_address on VRAM
	assign wb_err_o = 1'b0;
	wire		active;
	wire		write;
	wire		read;
	assign active	= wb_cyc_i&&wb_stb_i;
	assign write	= active &&  wb_we_i;
	assign read	= active && !wb_we_i;
	// write
	always @(posedge clk or posedge res)
		if (res) begin
			reg0 <= 32'h0000_0000;
			reg1 <= 32'h0000_0000;
		end
		else if (write) begin
			if (wb_adr_i[2]==1'd1) begin
				if (wb_sel_i[3]) reg1[31:24] <= wb_dat_i[31:24];
				if (wb_sel_i[2]) reg1[23:16] <= wb_dat_i[23:16];
				if (wb_sel_i[1]) reg1[15: 8] <= wb_dat_i[15: 8];
				if (wb_sel_i[0]) reg1[ 7: 0] <= wb_dat_i[ 7: 0];
			end 
			else if (wb_adr_i[2]==1'd0) begin
				if (wb_sel_i[3]) reg0[31:24] <= wb_dat_i[31:24];
				if (wb_sel_i[2]) reg0[23:16] <= wb_dat_i[23:16];
				if (wb_sel_i[1]) reg0[15: 8] <= wb_dat_i[15: 8];
				if (wb_sel_i[0]) reg0[ 7: 0] <= wb_dat_i[ 7: 0];
			end
		end
	// read
	assign wb_dat_o = (read) ? (
				(wb_adr_i[2]==1'd0) ? reg0:
				(wb_adr_i[2]==1'd1) ? reg1:
				32'h0000_0000
			):  32'h0000_0000;
	// ack
	assign wb_ack_o = active;
	// reg
	assign enable = reg1[0];
	assign base = reg0[23:11];
endmodule

module tessera_vga_ctrl (
	res,
	clk,
	enable,
	base,
	req,
	ack,
	address,
	hsync,
	vsync,
	hava,
	init,
	busy
);
	input		res;
	input		clk;
	input		enable;
	input	[23:11]	base;
	output		req;
	input		ack;
	output	[31:0]	address;
	output		hsync;
	output		vsync;
	output		hava;
	output		init;
	output		busy;
	//
	// hcount(stage0)
	//
	reg	[10:0]	hcount;
	wire		hcount_full_expire;
	wire		hcount_hsync1_expire;
	wire		hcount_hsync0_expire;
	wire		hcount_vsync1_expire;
	wire		hcount_vsync0_expire;
	wire		hcount_hhava1_expire;
	wire		hcount_hhava0_expire;
	wire		hcount_vhava1_expire;
	wire		hcount_vhava0_expire;
	wire		hcount_load_expire;
	reg		hcount_full;
	reg		hcount_hsync1;
	reg		hcount_hsync0;
	reg		hcount_vsync1;
	reg		hcount_vsync0;
	reg		hcount_hhava1;
	reg		hcount_hhava0;
	reg		hcount_vhava1;
	reg		hcount_vhava0;
	reg		hcount_load;
	//
	// vcount(stage1)
	//
	wire		vcount_full_expire;
	wire		vcount_hsync1_expire;
	wire		vcount_hsync0_expire;
	wire		vcount_vsync1_expire;
	wire		vcount_vsync0_expire;
	wire		vcount_hhava1_expire;
	wire		vcount_hhava0_expire;
	wire		vcount_vhava1_expire;
	wire		vcount_vhava0_expire;
	wire		vcount_load_expire;
	reg	[10:0]	vcount;
	reg		vcount_full;
	reg		vcount_hsync1;
	reg		vcount_hsync0;
	reg		vcount_vsync1;
	reg		vcount_vsync0;
	reg		vcount_hhava1;
	reg		vcount_hhava0;
	reg		vcount_vhava1;
	reg		vcount_vhava0;
	reg		vcount_hload;
	reg		vcount_vload;
/////////////////////////////////////////////////////////////////////////////////////////////////
// VESA 832x520(640x480 70Hz 31.500MHz)
/////////////////////////////////////////////////////////////////////////////////////////////////
/*
	//
	// stage0 on h
	//
	// h size
	assign hcount_full_expire	= (hcount==11'd831);		// VESA 832
	// hsync toggle point
	assign hcount_hsync0_expire	= (hcount==11'd15);		// VESA 664-640 = 24
	assign hcount_hsync1_expire	= (hcount==11'd15+11'd48);	// 704-640	= 64
	// vsync toggle point
	//assign hcount_vsync0_expire	= (hcount==11'd4); // always
	//assign hcount_vsync1_expire	= (hcount==11'd4); // always
	assign hcount_vsync0_expire	= (hcount==11'd15); // always
	assign hcount_vsync1_expire	= (hcount==11'd15+11'd48); // always
	// hava active area
	assign hcount_hhava1_expire	= (hcount==11'd191);		// VESA 24+(64-24)+128 = 192
	assign hcount_hhava0_expire	= (hcount==11'd191+11'd640);
	// vhava toggle point
	assign hcount_vhava1_expire	= (hcount==11'd0); // always
	assign hcount_vhava0_expire	= (hcount==11'd0); // always
	// job start point
	assign hcount_load_expire	= (hcount==11'd0); // first

	//
	// stage1 on v
	//
	// v size
	assign vcount_full_expire	= (vcount==11'd519);		// VESA = 520
	// hsync active area
	assign vcount_hsync1_expire	= 1'b1; // always
	assign vcount_hsync0_expire	= 1'b1; // always
	// vsync toggle point
	assign vcount_vsync0_expire	= (vcount==11'd8);		// VESA = 489 - 480 = 9
	assign vcount_vsync1_expire	= (vcount==11'd8+11'd3);	// VESA = 492 - 480 = 12
	// hhava area
	assign vcount_hhava1_expire	= 1'b1; // always
	assign vcount_hhava0_expire	= 1'b1; // always
	// vhava
	assign vcount_vhava1_expire	= (vcount==11'd39);		// VESA = 520 - 480 = 40
	assign vcount_vhava0_expire	= (vcount==11'd39+11'd480);	//
	// job start point
	assign vcount_load_expire	= (vcount==11'd0); // first
*/

/////////////////////////////////////////////////////////////////////////////////////////////////
// VESA 800x525(,521)(640x480 60Hz at 25.175MHz)
// ModeLine "640x480" 25.175 640 648 752 800  480 490 492 525 -HSync -VSync
// Modeline "640x480" 25.175 640 656 752 800  480 490 492 525 -HSync -VSync(web:org)
// Modeline "640x480" 25     640 656 752 800  480 490 492 521 -HSync -VSync(web:-4line) 25MHz->60Hz
//
/////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// stage0 on h
	//
	// h size
	assign hcount_full_expire	= (hcount==11'd799);
	// hsync toggle point
	assign hcount_hsync0_expire	= (hcount==11'd7		+11'd8); // 25MHz,so 8pix
	assign hcount_hsync1_expire	= (hcount==11'd7+11'd104);
	// vsync toggle point
	//assign hcount_vsync0_expire	= (hcount==11'd4); // always
	//assign hcount_vsync1_expire	= (hcount==11'd4); // always
	assign hcount_vsync0_expire	= (hcount==11'd7		+11'd8); // always,so 8pix
	assign hcount_vsync1_expire	= (hcount==11'd7+11'd104); // always
	// hava active area
	assign hcount_hhava1_expire	= (hcount==11'd159);
	assign hcount_hhava0_expire	= (hcount==11'd159+11'd640);
	// vhava toggle point
	assign hcount_vhava1_expire	= (hcount==11'd0); // always
	assign hcount_vhava0_expire	= (hcount==11'd0); // always
	// job start point
	assign hcount_load_expire	= (hcount==11'd0); // first

	//
	// stage1 on v
	//
	// v size
	assign vcount_full_expire	= (vcount==11'd524		-11'd4); // 25MHz,so -4line
	// hsync active area
	assign vcount_hsync1_expire	= 1'b1; // always
	assign vcount_hsync0_expire	= 1'b1; // always
	// vsync toggle point
	assign vcount_vsync0_expire	= (vcount==11'd9		-11'd4); // 25MHz,so -4line
	assign vcount_vsync1_expire	= (vcount==11'd9+11'd2		-11'd4); // 25MHz,so -4line
	// hhava area
	assign vcount_hhava1_expire	= 1'b1; // always
	assign vcount_hhava0_expire	= 1'b1; // always
	// vhava
	assign vcount_vhava1_expire	= (vcount==11'd44-11'd4);
	assign vcount_vhava0_expire	= (vcount==11'd44+11'd480	-11'd4); // 25MHz,so -4line
	// job start point
	assign vcount_load_expire	= (vcount==11'd0); // first

	
/////////////////////////////////////////////////////////////////////////////////////////////////
// illegal (800+480    )x521 (59Hz at 40MHz) from +480
// illegal (800+480-32 )x521 (61Hz at 40MHz) from +480-32
// illegal (800+480-192)x521 (61Hz at 35MHz) from +480-192
 
/////////////////////////////////////////////////////////////////////////////////////////////////
/*
	//
	// stage0 on h
	//
	// h size
	assign hcount_full_expire	= (hcount==11'd799			+11'd480-11'd192);
	// hsync toggle point
	assign hcount_hsync0_expire	= (hcount==11'd7		+11'd8	+11'd480-11'd192); // 25MHz,so 8pix
	assign hcount_hsync1_expire	= (hcount==11'd7+11'd104		+11'd480-11'd192);
	// vsync toggle point
	//assign hcount_vsync0_expire	= (hcount==11'd4); // always
	//assign hcount_vsync1_expire	= (hcount==11'd4); // always
	assign hcount_vsync0_expire	= (hcount==11'd7		+11'd8	+11'd480-11'd192); // always,so 8pix
	assign hcount_vsync1_expire	= (hcount==11'd7+11'd104		+11'd480-11'd192); // always
	// hava active area
	assign hcount_hhava1_expire	= (hcount==11'd159			+11'd480-11'd192);
	assign hcount_hhava0_expire	= (hcount==11'd159+11'd640		+11'd480-11'd192);
	// vhava toggle point
	assign hcount_vhava1_expire	= (hcount==11'd0); // always
	assign hcount_vhava0_expire	= (hcount==11'd0); // always
	// job start point
	assign hcount_load_expire	= (hcount==11'd0); // first

	//
	// stage1 on v
	//
	// v size
	assign vcount_full_expire	= (vcount==11'd524		-11'd4); // 25MHz,so -4line
	// hsync active area
	assign vcount_hsync1_expire	= 1'b1; // always
	assign vcount_hsync0_expire	= 1'b1; // always
	// vsync toggle point
	assign vcount_vsync0_expire	= (vcount==11'd9		-11'd4); // 25MHz,so -4line
	assign vcount_vsync1_expire	= (vcount==11'd9+11'd2		-11'd4); // 25MHz,so -4line
	// hhava area
	assign vcount_hhava1_expire	= 1'b1; // always
	assign vcount_hhava0_expire	= 1'b1; // always
	// vhava
	assign vcount_vhava1_expire	= (vcount==11'd44-11'd4);
	assign vcount_vhava0_expire	= (vcount==11'd44+11'd480	-11'd4); // 25MHz,so -4line
	// job start point
	assign vcount_load_expire	= (vcount==11'd0); // first
*/

/////////////////////////////////////////////////////////////////////////////////////////////////
// VESA 1688x1066(1240x1028 60Hz at 108MHz)
// ModeLine "1280x1024"  108.000  1280 1320 1440 1688 1024 1025 1028 1066 +HSync +VSync
/////////////////////////////////////////////////////////////////////////////////////////////////
//	//
//	// stage0 on h
//	//
//	// h size
//	assign hcount_full_expire	= (hcount==11'd1687);
//	// hsync toggle point
//	assign hcount_hsync0_expire	= (hcount==11'd39);
//	assign hcount_hsync1_expire	= (hcount==11'd39+11'd120);
//	// vsync toggle point
//	assign hcount_vsync0_expire	= (hcount==11'd4); // always
//	assign hcount_vsync1_expire	= (hcount==11'd4); // always
//	// hava active area
//	assign hcount_hhava1_expire	= (hcount==11'd407);
//	assign hcount_hhava0_expire	= (hcount==11'd407+11'd1280);
//	// vhava toggle point
//	assign hcount_vhava1_expire	= (hcount==11'd0); // always
//	assign hcount_vhava0_expire	= (hcount==11'd0); // always
//	// job start point
//	assign hcount_load_expire	= (hcount==11'd0); // first
//	//
//	// stage1 on v
//	//
//	// v size
//	assign vcount_full_expire	= (vcount==11'd1065);
//	// hsync active area
//	assign vcount_hsync1_expire	= 1'b1; // always
//	assign vcount_hsync0_expire	= 1'b1; // always
//	// vsync toggle point
//	assign vcount_vsync0_expire	= (vcount==11'd0);
//	assign vcount_vsync1_expire	= (vcount==11'd0+11'd3);
//	// hhava area
//	assign vcount_hhava1_expire	= 1'b1; // always
//	assign vcount_hhava0_expire	= 1'b1; // always
//	// vhava
//	assign vcount_vhava1_expire	= (vcount==11'd41);
//	assign vcount_vhava0_expire	= (vcount==11'd41+11'd1024);
//	// job start point
//	assign vcount_load_expire	= (vcount==11'd0); // first

	always @(posedge clk or posedge res)
		if (res) begin
			hcount		<= 11'd0;
			hcount_full	<= 1'b0;
			hcount_hsync1	<= 1'b0;
			hcount_hsync0	<= 1'b0;
			hcount_vsync1	<= 1'b0;
			hcount_vsync0	<= 1'b0;
			hcount_hhava1	<= 1'b0;
			hcount_hhava0	<= 1'b0;
			hcount_vhava1	<= 1'b0;
			hcount_vhava0	<= 1'b0;
			hcount_load	<= 1'b0;
		end
		else begin
			hcount		<= (hcount_full_expire) ? 11'd0: (hcount + 11'd1);
			hcount_full	<= hcount_full_expire;
			hcount_hsync1	<= hcount_hsync1_expire;
			hcount_hsync0	<= hcount_hsync0_expire;
			hcount_vsync1	<= hcount_vsync1_expire;
			hcount_vsync0	<= hcount_vsync0_expire;
			hcount_hhava1	<= hcount_hhava1_expire;
			hcount_hhava0	<= hcount_hhava0_expire;
			hcount_vhava1	<= hcount_vhava1_expire;
			hcount_vhava0	<= hcount_vhava0_expire;
			hcount_load	<= hcount_load_expire;
		end
	always @(posedge clk or posedge res)
		if (res) begin
			vcount		<= 11'd0;
			vcount_full	<= 1'b0;
			vcount_hsync1	<= 1'b0;
			vcount_hsync0	<= 1'b0;
			vcount_vsync1	<= 1'b0;
			vcount_vsync0	<= 1'b0;
			vcount_hhava1	<= 1'b0;
			vcount_hhava0	<= 1'b0;
			vcount_vhava1	<= 1'b0;
			vcount_vhava0	<= 1'b0;
			//
			vcount_hload	<= 1'b0;
			vcount_vload	<= 1'b0;
		end
		else begin
			vcount		<= (hcount_full) ? ((vcount_full_expire) ? 11'd0: (vcount + 11'd1)): vcount; 
			vcount_full	<= hcount_full   && vcount_full_expire;
			vcount_hsync1	<= hcount_hsync1 && vcount_hsync1_expire;
			vcount_hsync0	<= hcount_hsync0 && vcount_hsync0_expire;
			vcount_vsync1	<= hcount_vsync1 && vcount_vsync1_expire;
			vcount_vsync0	<= hcount_vsync0 && vcount_vsync0_expire;
			vcount_hhava1	<= hcount_hhava1 && vcount_hhava1_expire;
			vcount_hhava0	<= hcount_hhava0 && vcount_hhava0_expire;
			vcount_vhava1	<= hcount_vhava1 && vcount_vhava1_expire;
			vcount_vhava0	<= hcount_vhava0 && vcount_vhava0_expire;
			//
			vcount_hload	<= hcount_load;
			vcount_vload	<= hcount_load && vcount_load_expire;
		end
	//
	// vga(stage2)
	//
	reg		vga_hsync;
	reg		vga_vsync;
	reg		vga_hhava;
	reg		vga_vhava;
	reg		vga_hload;
	reg		vga_vload;
	wire		vga_hava;
	wire		vga_init;
	wire		vga_dreq;
	always @(posedge clk or posedge res)
		if (res)		vga_hsync <= 1'b1;
		else if (vcount_hsync1)	vga_hsync <= 1'b1;
	       	else if (vcount_hsync0)	vga_hsync <= 1'b0;
	always @(posedge clk or posedge res)
		if (res)		vga_vsync <= 1'b1;
		else if (vcount_vsync1)	vga_vsync <= 1'b1;
	       	else if (vcount_vsync0)	vga_vsync <= 1'b0;
	always @(posedge clk or posedge res)
		if (res)		vga_hhava <= 1'b0;
		else if (vcount_hhava1)	vga_hhava <= 1'b1;
	       	else if (vcount_hhava0)	vga_hhava <= 1'b0;
	always @(posedge clk or posedge res)
		if (res)		vga_vhava <= 1'b0;
		else if (vcount_vhava1)	vga_vhava <= 1'b1;
	       	else if (vcount_vhava0)	vga_vhava <= 1'b0;
	always @(posedge clk or posedge res)
		if (res)		vga_hload <= 1'b0;
		else			vga_hload <= vcount_hload;
	always @(posedge clk or posedge res)
		if (res)		vga_vload <= 1'b0;
		else			vga_vload <= vcount_vload;
	assign hsync	= vga_hsync;
	assign vsync	= vga_vsync;
	assign init	= vga_hload;
	assign hava	= vga_hhava&&vga_vhava;
	assign vga_init	= vga_vload;
	assign vga_dreq	= vga_hload&&vga_vhava;
	//
	// req(stage3)
	//
	wire		req_laddress_full;
	reg		req_hdreq;
	wire		req_hack;
	reg		req_ldreq;
	wire		req_lack;
	reg	[23:11]	req_haddress;	// 1024line
	reg	[10:6]	req_laddress;	// 1024pix
	//assign req_laddress_full = (req_laddress[11:6]==6'd39); // dma_count=40
       	// 1024x768:64dma x 8timex2burst x 2byte = 2048data
	// 640x480 :40dma x 8timex2burst x 2byte = 1280data 

	assign req_laddress_full = (req_laddress[10:6]==5'd19); // dma_count=20
       	// 1024x768:32dma x 16timex2burst x 2byte = 2048data
	// 640x480 :20dma x 16timex2burst x 2byte = 1280data 
	assign req_hack = req_lack&&req_laddress_full;
	assign req_lack = ack&&req_ldreq;
	always @(posedge clk or posedge res)
		if (res)		req_hdreq <= 1'b0;
		else if (vga_dreq)	req_hdreq <= 1'b1;
		else if (req_hack)	req_hdreq <= 1'b0;
	always @(posedge clk or posedge res)
		if (res)		req_ldreq <= 1'b0;
		else			req_ldreq <= !ack&&req_hdreq;
	always @(posedge clk or posedge res)
		if (res)		req_haddress <= 13'd0;
		else if (vga_init)	req_haddress <= base[23:11]; // base[23:11] 8192=line(when Y=1024,so 8pages)
		else if (req_hack)	req_haddress <= req_haddress + 13'd1;
	always @(posedge clk or posedge res)
		if (res)		req_laddress <= 5'd0;
		else if (vga_init)	req_laddress <= 5'd0;
		else if (req_hack)	req_laddress <= 5'd0; // 16times:base[10:6] 8times:base[10:5] 
		else if	(req_lack)	req_laddress <= req_laddress + 5'd1;
		
	assign req = req_ldreq;
	//assign address = {8'd0,req_haddress[23:11],req_laddress[10:5],5'b0_0000}; // 8times:1time_start_address
	assign address = {8'd0,req_haddress[23:11],req_laddress[10:6],6'b00_0000}; // 16times:1t8times:ime_start_address
	assign busy = req_hdreq;
//	reg		sub_req;
//	reg	[11:2]	sub_address;
//	reg		sub_ack;
//	always @(posedge clk or posedge res)
//		if (res)		sub_req <= 1'b0;
//		else if (main_req)	sub_req <= 1'b1;
//		else if (ack)		sub_req <= 1'b0;
//	always @(posedge clk or posedge res)
//		if (res)		sub_address <= 10'd0;
//		else if (req_load)	sub_address <= sub_address + 10'd1;
endmodule
module tessera_vga_core (
	res,
	clk,
	enable,
	base,
	req,
	ack,
	address,
	clear,
	init,
	exist,
	data,
	hsync,
	vsync,
	blank,
	rgb,
	busy
);
	input		res;
	input		clk;
	input		enable;
	input	[23:11]	base;
	output		req;
	input		ack;
	output	[31:0]	address;
	output		clear;
	output		init;
	input		exist;
	input	[15:0]	data;
	output		hsync;
	output		vsync;
	output		blank;
	output	[23:0]	rgb;	// RGB565
	output		busy;

	wire		ctrl_hava;
	wire		ctrl_hsync;
	wire		ctrl_vsync;
	
	tessera_vga_ctrl i_tessera_vga_ctrl (
		.res(		res),
		.clk(		clk),
		.enable(	enable), // not-fix
		.base(		base),
		.req(		req),
		.ack(		ack),
		.address(	address),
		.hsync(		ctrl_hsync),
		.vsync(		ctrl_vsync),
		.init(		init),
		.hava(		ctrl_hava),
		.busy(		busy)
	);

	assign clear = ctrl_hava;

	reg	[23:0]	rgb;
	reg		blank;
	reg		vsync;
	reg		hsync;
	always @(posedge clk or posedge res)
		if (res)
			rgb <= 24'h00_00_00;
		else
			rgb <= (ctrl_hava) ? {
				data[15:11],3'b000, //R5
				data[10:5] ,2'b00 , //G6
				data[4:0]  ,3'b000  //B5
			}: 24'h000000;
	always @(posedge clk or posedge res)
		if (res) begin
			blank <= 1'b1;
			vsync <= 1'b1;
			hsync <= 1'b1;
		end
		else begin
		   	blank <= ctrl_hava;
			vsync <= ctrl_vsync;
			hsync <= ctrl_hsync;
		end

endmodule
module tessera_vga_fifo (
	write_clk,
	write_res,
	read_clk,
	read_res,
	write_exist,
	write_data,
	read_init,
	read_clear,
	read_exist,
	read_data
);
	input		write_clk;
	input		write_res;
	input		read_clk;
	input		read_res;
	input		write_exist;
	input	[15:0]	write_data;
	input		read_init;
	//output	read_clear; // !<- koreda....humhum
	input		read_clear; // 
	output		read_exist;
	output	[15:0]	read_data;

	wire		rdempty;

	// test(in)
	//reg	[5:0]	count;
	//wire	[15:0]	data;
	//always @(posedge write_clk or posedge read_init)
	//	if (read_init)		count <= 6'd0;
	//	else if (write_exist)	count <= count + 6'd1;
	//assign data = (count[5]) ? 16'hffff: 16'h0000;

	FIFO_LINE i_FIFO_LINE (
		.data(		write_data),
		.wrreq(		write_exist),
		.rdreq(		read_clear),
		.rdclk(		read_clk),
		.wrclk(		write_clk),
		.aclr(		read_init), // ansync clear port
		.q(		read_data),
		.rdempty(	rdempty)
	);
	assign read_exist = !rdempty;

	// test(out)
	//reg	[9:0]	hcount;
	//wire	[15:0]	read_data;
	//always @(posedge read_clk)
	//	if (read_init)		hcount <= 10'd0;
	//	else if (read_clear)	hcount <= hcount + 10'd1;
	//assign read_data = (hcount[9]) ? 16'hffff: 16'h0000;

endmodule
module tessera_vga (
	// System
	sys_wb_res,
	sys_wb_clk,
	sys_dma_res,
	sys_dma_clk,
	sys_vga_res,
	sys_vga_clk,
	// WishBone
	wb_cyc_i,
	wb_stb_i,
	wb_adr_i,
	wb_sel_i,
	wb_we_i,
	wb_dat_i,
	wb_cab_i,
	wb_dat_o,
	wb_ack_o,
	wb_err_o,
	wb_busy, // option
	// dma
	dma_req,
	dma_address,
	dma_ack,
	dma_exist,
	dma_data,
	// vga
	vga_clk,
	vga_hsync,
	vga_vsync,
	vga_blank,
	vga_rgb
);
	// System
	input		sys_wb_res;
	input		sys_wb_clk;
	input		sys_dma_res;
	input		sys_dma_clk;
	input		sys_vga_res;
	input		sys_vga_clk;
	// WinsBone
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
	output		wb_busy;
	// dma
	output		dma_req;
	output	[31:0]	dma_address;
	input		dma_ack;
	input		dma_exist;
	input	[15:0]	dma_data;
	// vga
	output		vga_clk;
	output		vga_hsync;
	output		vga_vsync;
	output		vga_blank;
	output	[23:0]	vga_rgb;
	//
	wire		wbif_enable;
	wire	[23:11]	wbif_base;
	//
	//wire		vga_enable;
	reg		vga_enable;
	wire	[23:11]	vga_base;
	wire		vga_req;
	wire	[31:0]	vga_address;
	wire		vga_ack;
	wire		vga_clear;
	wire		vga_init;
	wire		vga_exist;
	wire	[15:0]	vga_data;
	wire		vga_busy;

	assign vga_clk = sys_vga_clk; // output
	
	tessera_vga_wbif i_tessera_vga_wbif (
		//
		.res(		sys_wb_res),
		.clk(		sys_wb_clk),
		//
		.wb_cyc_i(	wb_cyc_i),
		.wb_stb_i(	wb_stb_i),
		.wb_adr_i(	wb_adr_i),
		.wb_sel_i(	wb_sel_i),
		.wb_we_i(	wb_we_i),
		.wb_dat_i(	wb_dat_i),
		.wb_cab_i(	wb_cab_i),
		.wb_dat_o(	wb_dat_o),
		.wb_ack_o(	wb_ack_o),
		.wb_err_o(	wb_err_o),
		//
		.enable(	wbif_enable),
		.base(		wbif_base)
	);

//
// mt sync same-phase
//
/*
	assign vga_enable		= wbif_enable;			// to vga
	assign vga_base			= wbif_base;			// to vga
*/

//
// mt sync pos<->neg,fast path,is safety
//
/*
	reg		mt_enable;
	reg	[23:11]	mt_base;
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res) begin
			mt_enable	<= 1'b0;
			mt_base		<= 13'd0;
		end
		else begin
			mt_enable	<= wbif_enable;
			mt_base		<= wbif_base;
		end
	assign vga_enable		= mt_enable;			// to vga
	assign vga_base			= mt_base;			// to vga
*/

//
// mt1,2 no-sync
//
	reg		mt1_enable;
	reg	[23:11]	mt1_base;
	reg		mt2_enable;
	reg	[23:11]	mt2_base;
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res) begin
			mt1_enable	<= 1'b0;
			mt1_base	<= 13'd0;
		end
		else begin
			mt1_enable	<= wbif_enable;
			mt1_base	<= wbif_base;
		end
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res) begin
			mt2_enable	<= 1'b0;
			mt2_base	<= 13'd0;
		end
		else begin
			mt2_enable	<= mt1_enable;
			mt2_base	<= mt1_base;
		end
	//assign vga_enable		= mt2_enable; // to vga
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res) 	vga_enable <= 1'b0;
		else			vga_enable <= mt2_enable; // can not load vga_base, so must +1delay
	assign vga_base			= mt2_base;


	// VGA
	tessera_vga_core i_tessera_vga_core (
		//
		.res(		sys_vga_res),
		.clk(		sys_vga_clk),
		//
		.enable(	vga_enable),
		.base(		vga_base),
		//
		.req(		vga_req),
		.address(	vga_address),
		.ack(		vga_ack),
		.clear(		vga_clear),
		.init(		vga_init),
		.exist(		vga_exist),
		.data(		vga_data),
		//
		.hsync(		vga_hsync),
		.vsync(		vga_vsync),
		.blank(		vga_blank),
		.rgb(		vga_rgb),
		.busy(		vga_busy)
	);

//
// mt(TYPE A) sync, same-phase
//
/*
	// VGA->SDRAM
	assign dma_req		= vga_req;	// to dma
	assign dma_address	= vga_address;	// to dma
	// SDRAM->VGA
	assign vga_ack		= dma_ack;	// to vga
	// VGA->WB
	assign wb_busy		= vga_busy;	// to wb
*/

//
// mt(TYPE B) sync, pos<->neg,fast path,is safety
//
/*
	// VGA->SDRAM
	reg		mt_req;
	reg	[31:0]	mt_address;
	always @(posedge sys_dma_clk or posedge sys_dma_res)
		if (sys_dma_res) begin
			mt_req		<= 1'b0;
			mt_address	<= 22'd0;
		end
		else begin
			mt_req		<= vga_req;
			mt_address	<= vga_address;
		end
	assign dma_req = mt_req; // to dma
	assign dma_address = mt_address; // to dma
	// SDRAM->VGA
	reg		mt_ack;
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res)	mt_ack <= 1'b0;
		else			mt_ack <= dma_ack;
	assign vga_ack = mt_ack; // to vga
	// VGA->WB
	reg		mt_busy;
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res)	mt_busy <= 1'b0;
		else			mt_busy	<= vga_busy;
	assign wb_busy = mt_busy; // to wbif
*/

//
// mt1,2(TYPE C) no-sync
//
// VGA->SDRAM
	reg		mt1_req;
	reg	[31:0]	mt1_address;
	reg		mt2_req;
	reg	[31:0]	mt2_address;
	always @(posedge sys_dma_clk or posedge sys_dma_res)
		if (sys_dma_res) begin
			mt1_req		<= 1'b0;
			mt1_address	<= 32'd0;
		end
		else begin
			mt1_req		<= vga_req;
			mt1_address	<= vga_address;
		end
	always @(posedge sys_dma_clk or posedge sys_dma_res)
		if (sys_dma_res) begin
			mt2_req		<= 1'b0;
			mt2_address	<= 32'd0;
		end
		else begin
			mt2_req		<= mt1_req;
			mt2_address	<= mt1_address;
		end
	//assign dma_req = mt2_req;
	reg		dma_req;
	always @(posedge sys_dma_clk or posedge sys_dma_res)
		if (sys_dma_res) 	dma_req <= 1'b0;
		else			dma_req <= mt2_req;	// can not load dma_address, so must +1delay
	assign dma_address = mt2_address;

// SDRAM->VGA
	reg		mt1_ack;
	reg		mt2_ack;
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res)	mt1_ack <= 1'b0;
		else			mt1_ack <= dma_ack;
	always @(posedge sys_vga_clk or posedge sys_vga_res)
		if (sys_vga_res)	mt2_ack	<= 1'b0;
		else			mt2_ack	<= mt1_ack;
	assign vga_ack = mt2_ack; // to vga

// VGA->WB
	reg		mt1_busy;
	reg		mt2_busy;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res) 	mt1_busy <= 1'b0;
		else			mt1_busy <= vga_busy;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res)		mt2_busy <= 1'b0;
		else			mt2_busy <= mt1_busy;
	assign wb_busy = mt2_busy; // to wbif

	
// Line-Buffer
	tessera_vga_fifo i_tessera_vga_fifo (
		//
		.write_clk(	sys_dma_clk),
		.write_res(	sys_dma_res),
		.read_clk(	sys_vga_clk),
		.read_res(	sys_vga_res),
		//
		.write_exist(	dma_exist),
		.write_data(	dma_data),
		//
		.read_init(	vga_init),
		.read_clear(	vga_clear),
		.read_exist(	vga_exist),
		.read_data(	vga_data)
		//
	);

endmodule
