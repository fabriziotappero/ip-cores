
`timescale 1ps/1ps

// {cke,cs_n,ras_n,cas_n,we_n}
`define COMMAND_RES 5'b01000
`define COMMAND_NOP 5'b11000
`define COMMAND_DES 5'b10000
`define COMMAND_PAL 5'b11101
`define COMMAND_MRS 5'b11111
`define COMMAND_REF 5'b11110
`define COMMAND_ACT 5'b11100
`define COMMAND_WRI 5'b11011
`define COMMAND_REA 5'b11010

// state
`define S0 'd0
`define S1 'd1
`define S2 'd2
`define S3 'd3
`define S4 'd4
`define S5 'd5
`define S6 'd6
`define S7 'd7
`define S8 'd8
`define S9 'd9
`define S10 'd10
`define S11 'd11
`define S12 'd12
`define S13 'd13
`define S14 'd14
`define S15 'd15

module tessera_sdram_ctrl (
	res,
	clk,
	init_req,
	init_enter,
	init_exit,
	refresh_req,
	refresh_enter,
	refresh_exit,
	write_req,
	write_enter,
	write_valid,
	write_exit,
	write_address,
	read_req,
	read_enter,
	read_valid,
	read_exit,
	read_address,
	dma_req,
	dma_enter,
	dma_valid,
	dma_exit,
	dma_address,
	ctrl_cmd,
	ctrl_cs,
	ctrl_ba,
	ctrl_a,
	option
);
	input		res;
	input		clk;
	input		init_req;
	output		init_enter;
	output		init_exit;
	input		refresh_req;
	output		refresh_enter;
	output		refresh_exit;
	input		write_req;
	output		write_enter;
	output		write_valid;
	output		write_exit;
	input	[31:0]	write_address;
	input		read_req;
	output		read_enter;
	output		read_valid;
	output		read_exit;
	input	[31:0]	read_address;
	input		dma_req;
	output		dma_enter;
	output		dma_valid;
	output		dma_exit;
	input	[31:0]	dma_address;
	output	[4:0]	ctrl_cmd;
	output	[1:0]	ctrl_cs;
	output	[1:0]	ctrl_ba;
	output	[12:0]	ctrl_a;
	input		option;

	//
	// address
	//
	wire	[31:0]	next_wri_adr;
	wire	[31:0]	next_rea_adr;
	wire	[31:0]	next_dma_adr;
	//
	wire	[11:0]	next_wri_adr_col;
	wire	[11:0]	next_rea_adr_col;
	wire	[11:0]	next_dma_adr_col;
	//
	wire	[12:0]	next_wri_adr_row;
	wire	[12:0]	next_rea_adr_row;
	wire	[12:0]	next_dma_adr_row;
	//
	wire	[1:0]	next_wri_ba;
	wire	[1:0]	next_rea_ba;
	wire	[1:0]	next_dma_ba;
	//
	wire	[1:0]	next_wri_cs;
	wire	[1:0]	next_rea_cs;
	wire	[1:0]	next_dma_cs;
	//
	//assign next_wri_adr = {8'h00,write_address[23:0]}; // limit,so wishbone arbiter is pass_through uper bit
	//assign next_rea_adr = {8'h00, read_address[23:0]}; // limit,so wishbone arbiter is pass_through uper bit
	//assign next_dma_adr = {8'h00,  dma_address[23:0]}; // limit,so wishbone arbiter is pass_through uper bit

	reg		pre_option;
	always @(posedge clk) pre_option <= option;
	assign next_wri_adr = {7'h00,pre_option,write_address[23:0]};	// limit,so wishbone arbiter is pass_through uper bit
	assign next_rea_adr = {7'h00,pre_option,read_address[23:0]};	// limit,so wishbone arbiter is pass_through uper bit
	assign next_dma_adr = {7'h00,pre_option,dma_address[23:0]};	// limit,so wishbone arbiter is pass_through uper bit

	
// 64MBit: x16 SDRAM
// 12bit(A12-A11,A9-A0)	->col 8it(3bit not use)
// 13bit(A12-A0)	->row 12bit(1bit not use)
// 2bit			->ba
// 2bit			->cs
//	assign next_wri_adr_col		= {4'b0000,next_wri_adr[8:2],1'b0};
//	assign next_rea_adr_col		= {4'b0000,next_rea_adr[8:2],1'b0};
//	assign next_dma_adr_col		= {4'b0000,next_dma_adr[8:2],1'b0};
//	//
//	assign next_wri_adr_row		= {1'b0,next_wri_adr[20:9]};
//	assign next_rea_adr_row		= {1'b0,next_rea_adr[20:9]};
//	assign next_dma_adr_row		= {1'b0,next_dma_adr[20:9]};
//	//	
//	assign next_wri_ba		= next_wri_adr[22:21];
//	assign next_rea_ba		= next_rea_adr[22:21];
//	assign next_dma_ba		= next_dma_adr[22:21];
//	//
//	assign next_wri_cs		= {next_wri_adr[23],!next_wri_adr[23]};
//	assign next_rea_cs		= {next_rea_adr[23],!next_rea_adr[23]};
//	assign next_dma_cs		= {next_dma_adr[23],!next_dma_adr[23]};


// 128MBit: x16 SDRAM
// 12bit(A12-A11,A9-A0)	->col 9it(3bit not use)
// 13bit(A12-A0)	->row 12bit(1bit not use)
// 2bit			->ba
// 2bit			->cs
 	assign next_wri_adr_col		= {3'b000,next_wri_adr[9:2],1'b0};
	assign next_rea_adr_col		= {3'b000,next_rea_adr[9:2],1'b0};
	assign next_dma_adr_col		= {3'b000,next_dma_adr[9:2],1'b0};
	//
	assign next_wri_adr_row		= {1'b0,next_wri_adr[21:10]};
	assign next_rea_adr_row		= {1'b0,next_rea_adr[21:10]};
	assign next_dma_adr_row		= {1'b0,next_dma_adr[21:10]};
	//	
	assign next_wri_ba		= next_wri_adr[23:22];
	assign next_rea_ba		= next_rea_adr[23:22];
	assign next_dma_ba		= next_dma_adr[23:22];
	//
	assign next_wri_cs		= {next_wri_adr[24],!next_wri_adr[24]};
	assign next_rea_cs		= {next_rea_adr[24],!next_rea_adr[24]};
	assign next_dma_cs		= {next_dma_adr[24],!next_dma_adr[24]};

// 256MBit: x16 SDRAM
// 12bit(A12-A11,A9-A0)	->col 9it(3bit not use)
// 13bit(A12-A0)	->row 13bit
// 2bit			->ba
// 2bit			->cs
// 	assign next_wri_adr_col		= {3'b000,next_wri_adr[9:2],1'b0};
//	assign next_rea_adr_col		= {3'b000,next_rea_adr[9:2],1'b0};
//	assign next_dma_adr_col		= {3'b000,next_dma_adr[9:2],1'b0};
//	//
//	assign next_wri_adr_row		= next_wri_adr[22:10];
//	assign next_rea_adr_row		= next_rea_adr[22:10];
//	assign next_dma_adr_row		= next_dma_adr[22:10];
//	//	
//	assign next_wri_ba		= next_wri_adr[24:23];
//	assign next_rea_ba		= next_rea_adr[24:23];
//	assign next_dma_ba		= next_dma_adr[24:23];
//	//
//	assign next_wri_cs		= {next_wri_adr[25],!next_wri_adr[25]};
//	assign next_rea_cs		= {next_rea_adr[25],!next_rea_adr[25]};
//	assign next_dma_cs		= {next_dma_adr[25],!next_dma_adr[25]};

	//
	// gnt execute
	//
	wire		init_eve;
	wire		write_eve;
	wire		dma_eve;
	wire		refresh_eve;
	wire		read_eve;
	wire	[4:0]	next_execute;
	reg	[4:0]	gnt_execute;
	wire		init_syn;
	wire		refresh_syn;
	wire		dma_syn;
	wire		write_syn;
	wire		read_syn;
	wire		init_fin;
	wire		refresh_fin;
	wire		dma_fin;
	wire		write_fin;
	wire		read_fin;
	//
	// initilize(0)
	//
	reg	[4:0]	ini_cmd;
	reg	[1:0]	ini_cs;
	reg	[1:0]	ini_ba;
	reg	[12:0]	ini_adr;
	reg	[3:0]	ini_sta;
	reg	[3:0]	ini_sub;
	reg		timer_enable;
	reg	[15:0]	timer;
	reg		timer_expire;
	//
	// refresh(1)
	//
	reg	[4:0]	ref_cmd;
	reg	[1:0]	ref_cs;
	reg	[1:0]	ref_ba;
	reg	[12:0]	ref_adr;
	reg	[3:0]	ref_sta;
	//
	// dma(2)
	//
	reg	[4:0]	dma_cmd;
	reg	[1:0]	dma_cs;
	reg	[1:0]	dma_ba;
	reg	[12:0]	dma_adr;
	reg	[3:0]	dma_sta;
	reg	[3:0]	dma_sub;
	reg		dma_val;
	//
	// write(3)
	//
	reg	[4:0]	wri_cmd;
	reg	[1:0]	wri_cs;
	reg	[1:0]	wri_ba;
	reg	[12:0]	wri_adr;
	reg	[3:0]	wri_sta;
	reg	[3:0]	wri_sub;
	reg		wri_val;
	//
	// read(4)
	//
	reg	[4:0]	rea_cmd;
	reg	[1:0]	rea_cs;
	reg	[1:0]	rea_ba;
	reg	[12:0]	rea_adr;
	reg	[3:0]	rea_sta;
	reg	[3:0]	rea_sub;
	reg		rea_val;
	//
	// output signal
	//
	reg		init_enter;
	reg		refresh_enter;
	reg		dma_enter;
	reg		write_enter;
	reg		read_enter;
	//
	reg		init_exit;
	reg		refresh_exit;
	reg		dma_exit;		
	reg		write_exit;
	reg		read_exit;
//
// bus arbitor
//
	//
	// external bus fast release
	//
	assign    init_eve	=    init_req && !(   init_exit||   init_fin);
	assign   write_eve	=   write_req && !(  write_exit||  write_fin);
	assign     dma_eve	=     dma_req && !(    dma_exit||    dma_fin);
	assign refresh_eve	= refresh_req && !(refresh_exit||refresh_fin);
	assign    read_eve	=    read_req && !(   read_exit||   read_fin);
	assign next_execute = {
		 !(init_eve||refresh_eve||dma_eve||write_eve) &&    read_eve,	// low priority
		 !(init_eve||refresh_eve||dma_eve)            &&   write_eve,
		 !(init_eve||refresh_eve)                     &&     dma_eve,
		 !(init_eve)                                  && refresh_eve,
		                                                    init_eve	// high priority
	};
	always @(posedge clk or posedge res)
		if (res) gnt_execute <= 5'b00000;
		else if (
			!(
				|(gnt_execute[4:0]&{read_eve,write_eve,dma_eve,refresh_eve,init_eve})
			)
		) gnt_execute <= next_execute;
	//
	// external bus slow release
	//
	//assign next_execute = {
	//	 !(init_req||refresh_req||dma_req||write_req) && read_req,	// low priority
	//	 !(init_req||refresh_req||dma_req)            && write_req,
	//	 !(init_req||refresh_req)                     && dma_req,
	//	 !(init_req)                                  && refresh_req,
	//	                                                 init_req	// high priority
	//};
	//always @(posedge clk or posedge res)
	//	if (res) gnt_execute <= 5'b00000;
	//	else if (
	//		!(
	//			|(gnt_execute[4:0]&{read_req,write_req,dma_req,refresh_req,init_req})
	//		)
	//	) gnt_execute <= next_execute;
//
// output signal
//
	assign    init_syn	= (gnt_execute[0]&&(ini_sta==`S0));
	assign refresh_syn	= (gnt_execute[1]&&(ref_sta==`S0));
	assign     dma_syn	= (gnt_execute[2]&&(dma_sta==`S0));
	assign   write_syn	= (gnt_execute[3]&&(wri_sta==`S0));
	assign    read_syn	= (gnt_execute[4]&&(rea_sta==`S0));

	assign    init_fin	= (gnt_execute[0]&&(ini_sta==`S15));
	assign refresh_fin	= (gnt_execute[1]&&(ref_sta==`S6));
	assign     dma_fin	= (gnt_execute[2]&&(dma_sta==`S6));
	assign   write_fin	= (gnt_execute[3]&&(wri_sta==`S6));
	assign    read_fin	= (gnt_execute[4]&&(rea_sta==`S6));

	always @(posedge clk or posedge res)
		if (res) begin
			init_enter	<= 1'b0;
			refresh_enter	<= 1'b0;
			dma_enter	<= 1'b0;
			write_enter	<= 1'b0;
			read_enter	<= 1'b0;
			//
			init_exit	<= 1'b0;
			refresh_exit	<= 1'b0;
			dma_exit	<= 1'b0;
			write_exit	<= 1'b0;
			read_exit	<= 1'b0;
		end
		else begin
			init_enter	<=    init_syn;
			refresh_enter	<= refresh_syn;
			dma_enter	<=     dma_syn;
			write_enter	<=   write_syn;
			read_enter	<=    read_syn;
			//
			//init_exit	<=    init_fin;								//external bus slow release
			//refresh_exit	<= refresh_fin;								//external bus slow release
			//dma_exit	<=     dma_fin;								//external bus slow release
			//write_exit	<=   write_fin;								//external bus slow release
			//read_exit	<=    read_fin;								//external bus slow release
			init_exit	<= (!   init_req) ? 1'b0: (   init_fin) ? 1'b1:    init_exit;		//external bus fast release
			refresh_exit	<= (!refresh_req) ? 1'b0: (refresh_fin) ? 1'b1: refresh_exit;		//external bus fast release
			dma_exit	<= (!    dma_req) ? 1'b0: (    dma_fin) ? 1'b1:     dma_exit;		//external bus fast release
			write_exit	<= (!  write_req) ? 1'b0: (  write_fin) ? 1'b1:   write_exit;		//external bus fast release
			read_exit	<= (!   read_req) ? 1'b0: (   read_fin) ? 1'b1:    read_exit;		//external bus fast release
		end
	assign ctrl_cmd		= ini_cmd | ref_cmd | dma_cmd | wri_cmd | rea_cmd;
	assign ctrl_cs		= ini_cs  | ref_cs  | dma_cs  | wri_cs  | rea_cs;
	assign ctrl_ba		= ini_ba  | ref_ba  | dma_ba  | wri_ba  | rea_ba;
	assign ctrl_a		= ini_adr | ref_adr | dma_adr | wri_adr | rea_adr;
	assign dma_valid	= dma_val;
	assign read_valid	= rea_val;
	assign write_valid	= wri_val;
//
// initilize(0)
//
	always @(posedge clk or posedge res)
		if (res)  timer_enable <= 1'b0;
		else      timer_enable <= (ini_sta==`S1)||(ini_sta==`S14);
	always @(posedge clk or posedge res)
		if (res) 		timer <= 16'd0;
		else if (!timer_enable)	timer <= 16'd0;
		else			timer <= timer + 16'd1;
	always @(posedge clk or posedge res)
		if (res)		timer_expire <= 1'b0;
		else if (!timer_enable)	timer_expire <= 1'b0;
		else 			timer_expire <= (timer==16'd16384);
	always @(posedge clk or posedge res)
		if (res) begin
			ini_cmd	<= `COMMAND_RES;
			ini_cs	<= 2'b11;		// all cs
			ini_ba	<= 2'b00;
			ini_adr	<= 13'd0;
			ini_sta	<= `S0;
			ini_sub <= `S0;
		end
		else if (!gnt_execute[0]) begin
			ini_cmd	<= `COMMAND_DES;
			ini_cs	<= 2'b00;
			ini_ba	<= 2'b00;
			ini_adr	<= 13'd0;
			ini_sta	<= `S0;
			ini_sub <= `S0;
		end
		else case (ini_sta[3:0])
			`S0: begin							// power on
				ini_cmd	<= `COMMAND_DES;
				ini_cs	<= 2'b11; // all cs
				ini_ba	<= 2'b00;
				ini_adr	<= 13'd0;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S1: begin
				ini_cmd	<= `COMMAND_DES;
				if (timer_expire) ini_sta <= ini_sta + 4'd1;		// wait
			end
			`S2: begin							// init sequence
				ini_cmd	<= `COMMAND_PAL;
				ini_adr[10] <= 1'b1;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S3: begin
				ini_cmd	<= `COMMAND_DES;
				//ini_adr[10] <= 1'b0;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S4: begin
				ini_cmd	<= `COMMAND_REF;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S5: begin
				ini_cmd	<= `COMMAND_DES;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S6,`S7,`S8: begin
				ini_cmd	<= `COMMAND_DES;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S9: begin
				ini_cmd	<= `COMMAND_DES;
				if (ini_sub==`S7) begin
					ini_sub <= `S0;
					ini_sta	<= ini_sta + 4'd1;
				end
				else begin
					ini_sub <= ini_sub + 3'd1;
					ini_sta	<= `S4;
				end
			end
			`S10: begin
				ini_cmd	<= `COMMAND_MRS;
				ini_ba	<= 2'b00;		//Reserved
                                ini_adr <= {
				       5'b0_0000,		//Reserved
				       1'b0,			//Reserved(0)
				       //3'b010,		//CL(2)
				       3'b011,			//CL(3)
				       1'b0,			//BurstType,
				       3'b001			//RDModeBurstLength
				};
				ini_sta	<= ini_sta + 4'd1;
			end
			`S11: begin
				ini_cmd	<= `COMMAND_DES;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S12,`S13: begin
				ini_cmd	<= `COMMAND_DES;
				ini_sta	<= ini_sta + 4'd1;
			end
			`S14: begin
				ini_cmd	<= `COMMAND_DES;
				if (timer_expire) ini_sta <= ini_sta + 4'd1;		// wait
			end
			`S15: begin
				ini_cmd	<= `COMMAND_DES;
				ini_sta <= `S0;				//external bus fast releas
				//if (!init_req) ini_sta <= `S0;	//external bus slow release
			end
			default: begin
				ini_cmd	<= `COMMAND_DES;
				ini_cs	<= 2'b00;
				ini_ba	<= 2'b00;
				ini_adr	<= 13'd0;
				ini_sta	<= `S0;
			end
		endcase
//
// refresh(1)
//
	always @(posedge clk or posedge res)
		if (res) begin
			ref_cmd	<= `COMMAND_RES;
			ref_cs	<= 2'b11; // all cs
			ref_ba	<= 2'b00;
			ref_adr	<= 13'd0;
			ref_sta	<= `S0;
		end
		else if (!gnt_execute[1]) begin
			ref_cmd	<= `COMMAND_DES;
			ref_cs	<= 2'b00;
			ref_ba	<= 2'b00;
			ref_adr	<= 13'd0;
			ref_sta	<= `S0;
		end
		else case (ref_sta[3:0])
			`S0: begin
				ref_cmd	<= `COMMAND_PAL;
				ref_cs	<= 2'b11;				// all cs
				//ref_ba	<= 2'b00;
				ref_adr	<= {2'b00,1'b1,10'b00_0000_0000};	// all bank
				ref_sta	<= ref_sta + 4'd1;
			end
			`S1: begin
				ref_cmd	<= `COMMAND_DES; // tRP
				ref_sta	<= ref_sta + 4'd1;
			end
			`S2: begin
				ref_cmd	<= `COMMAND_REF;
				ref_sta	<= ref_sta + 4'd1;
			end
			`S3,`S4,`S5: begin // tRC
				ref_cmd	<= `COMMAND_DES;
				ref_sta	<= ref_sta + 4'd1;
			end
			`S6: begin
				ref_cmd	<= `COMMAND_DES;
				ref_sta <= `S0;				//external bus fast releas
				//if (!refresh_req) ref_sta <= `S0;	//external bus slow release
			end
			default: begin
				ref_cmd	<= `COMMAND_DES;
				ref_cs	<= 2'b00;
				ref_ba	<= 2'b00;
				ref_adr	<= 13'd0;
				ref_sta	<= `S0;
			end
		endcase
//
// dma(2)
//
	always @(posedge clk or posedge res)
		if (res) begin
			dma_cmd	<= `COMMAND_RES;
			dma_cs	<= 2'b11; // all cs
			dma_ba	<= 2'b00;
			dma_adr	<= 13'd0;
			dma_sta	<= `S0;
			dma_sub <= `S0;
			dma_val <= 1'b0;
		end
		else if (!gnt_execute[2]) begin
			dma_cmd	<= `COMMAND_DES;
			dma_cs	<= 2'b00;
			dma_ba	<= 2'b00;
			dma_adr	<= 13'd0;
			dma_sta <= `S0;
			dma_sub <= `S0;
			dma_val <= 1'b0;
		end
		else case (dma_sta[3:0])
			`S0: begin
				dma_cmd	<= `COMMAND_ACT;
				dma_cs	<= next_dma_cs;	 // only target cs
				dma_ba	<= next_dma_ba;
				dma_adr	<= next_dma_adr_row;
				dma_sta	<= dma_sta + 4'd1;
			end
			`S1: begin
				dma_cmd	<= `COMMAND_DES; // tRCD
				dma_sta	<= dma_sta + 4'd1;
				dma_val <= 1'b1;
			end
			`S2: begin // r1
				dma_cmd	<= `COMMAND_REA;
				//dma_adr <= {next_dma_adr_col[11:10],(dma_sub==`S7),next_dma_adr_col[9:4],dma_sub[2:0],1'b0}; // 8times&auto-precharge(last)
				dma_adr <= {next_dma_adr_col[11:10],(dma_sub==`S15),next_dma_adr_col[9:5],dma_sub[3:0],1'b0}; // 16times&auto-precharge(last)
				dma_sta	<= dma_sta + 4'd1;
			end
			`S3: begin
				dma_cmd	<= `COMMAND_DES;
				//if (dma_sub==`S7) begin
				if (dma_sub==`S15) begin
					dma_sub <= `S0;
					dma_sta <= dma_sta + 4'd1;
					dma_val <= 1'b0;
				end
				else begin
					dma_sub <= dma_sub + 4'd1;
					dma_sta <= `S2;
				end
			end
			`S4,`S5: begin
				dma_cmd	<= `COMMAND_DES;
				dma_sta	<= dma_sta + 4'd1;
			end
			`S6: begin
				dma_cmd	<= `COMMAND_DES;
				dma_sta <= `S0;				//external bus fast releas
				//if (!dma_req) dma_sta <= `S0;		//external bus slow release
			end
			default: begin
				dma_cmd	<= `COMMAND_DES;
				dma_cs	<= 2'b00;
				dma_ba	<= 2'b00;
				dma_adr	<= 13'd0;
				dma_sta <= `S0;
				dma_sub <= `S0;
				dma_val <= 1'b0;
			end
		endcase
//
// write(3)
//
	always @(posedge clk or posedge res)
		if (res) begin
			wri_cmd	<= `COMMAND_RES;
			wri_cs	<= 2'b11; // all cs
			wri_ba	<= 2'b00;
			wri_adr	<= 13'd0;
			wri_sta	<= `S0;
			wri_sub <= `S0;
			wri_val <= 1'b0;
		end
		else if (!gnt_execute[3]) begin
			wri_cmd	<= `COMMAND_DES;
			wri_cs	<= 2'b00;
			wri_ba	<= 2'b00;
			wri_adr	<= 13'd0;
			wri_sta	<= `S0;
			wri_sub <= `S0;
			wri_val <= 1'b0;
		end
		else case (wri_sta[3:0])
			`S0: begin
				wri_cmd	<= `COMMAND_ACT;
				wri_cs	<= next_wri_cs;	// only target cs
				wri_ba	<= next_wri_ba;
				wri_adr	<= next_wri_adr_row;
				wri_sta	<= wri_sta + 4'd1;
			end
			`S1: begin
				wri_cmd	<= `COMMAND_DES; // tRCD
				wri_sta	<= wri_sta + 4'd1;
				wri_val <= 1'b1;
			end
			`S2: begin
				wri_cmd	<= `COMMAND_WRI;
				//wri_adr <= {next_wri_adr_col[11:10],1'b1,next_wri_adr_col[9:2],2'b00};
				wri_adr <= {next_wri_adr_col[11:10],1'b1,next_wri_adr_col[9:0]};
				wri_sta	<= wri_sta + 4'd1;
			end
			`S3: begin
				wri_cmd	<= `COMMAND_DES;
				if (wri_sub==`S0) begin
					wri_sub <= `S0;
					wri_sta <= wri_sta + 4'd1;
					wri_val <= 1'b0;
				end
				else begin
					wri_sub <= wri_sub + 4'd1;
					wri_sta <= `S2;
				end
			end
			`S4,`S5: begin
				wri_cmd	<= `COMMAND_DES;
				wri_sta	<= wri_sta + 4'd1;
			end
			`S6: begin
				wri_cmd	<= `COMMAND_DES;
				wri_sta <= `S0;				//external bus fast releas
				//if (!write_req) wri_sta <= `S0;	//external bus slow release
			end
			default: begin
				wri_cmd	<= `COMMAND_DES;
				wri_cs	<= 2'b00;
				wri_ba	<= 2'b00;
				wri_adr	<= 13'd0;
				wri_sta	<= `S0;
				wri_sub <= `S0;
				wri_val <= 1'b0;
			end
		endcase
//
// read(4)
//
	always @(posedge clk or posedge res)
		if (res) begin
			rea_cmd	<= `COMMAND_RES;
			rea_cs	<= 2'b11;		// all cs
			rea_ba	<= 2'b00;
			rea_adr	<= 13'd0;
			rea_sta	<= `S0;
			rea_sub <= `S0;
			rea_val <= 1'b0;
		end
		else if (!gnt_execute[4]) begin
			rea_cmd	<= `COMMAND_DES;
			rea_cs	<= 2'b00;
			rea_ba	<= 2'b00;
			rea_adr	<= 13'd0;
			rea_sta <= `S0;
			rea_sub <= `S0;
			rea_val <= 1'b0;
		end
		else case (rea_sta[3:0])
			`S0: begin
				rea_cmd	<= `COMMAND_ACT;
				rea_cs	<= next_rea_cs;		// only target cs
				rea_ba	<= next_rea_ba;
				rea_adr	<= next_rea_adr_row;
				rea_sta	<= rea_sta + 4'd1;
			end
			`S1: begin
				rea_cmd	<= `COMMAND_DES; // tRCD
				rea_sta	<= rea_sta + 4'd1;
				rea_val <= 1'b1;
			end
			`S2: begin
				rea_cmd	<= `COMMAND_REA;
				//rea_adr <= {next_rea_adr_col[11:10],1'b1,next_rea_adr_col[9:2],2'b00};
				rea_adr <= {next_rea_adr_col[11:10],1'b1,next_rea_adr_col[9:0]};
				rea_sta	<= rea_sta + 4'd1;
			end
			`S3: begin
				rea_cmd	<= `COMMAND_DES;
				if (rea_sub==`S0) begin
					rea_sub <= `S0;
					rea_sta <= rea_sta + 4'd1;
					rea_val <= 1'b0;
				end
				else begin
					rea_sub <= rea_sub + 4'd1;
					rea_sta <= `S2;
				end
			end
			`S4,`S5: begin
				rea_cmd	<= `COMMAND_DES;
				rea_sta	<= rea_sta + 4'd1;
			end
			`S6: begin
				rea_cmd	<= `COMMAND_DES;
				rea_sta <= `S0;				//external bus fast release
				//if (!read_req) rea_sta <= `S0;	//external bus slow release
			end
			default: begin
				rea_cmd	<= `COMMAND_DES;
				rea_cs	<= 2'b00;
				rea_ba	<= 2'b00;
				rea_adr	<= 13'd0;
				rea_sta <= `S0;
				rea_sub <= `S0;
				rea_val <= 1'b0;
			end
		endcase

endmodule

module tessera_sdram_core (
	res,
	clk,
	write_req,
	write_byte,
	write_address,
	write_data,
	write_ack,
	read_req,
	read_byte,
	read_address,
	read_data,
	read_ack,
	dma_req,
	dma_address,
	dma_ack,
	dma_exist,
	dma_data,
	sdram_clk,
	sdram_cke,
	sdram_cs_n,
	sdram_ras_n,
	sdram_cas_n,
	sdram_we_n,
	sdram_dqm,
	sdram_ba,
	sdram_adr,
	sdram_d_i,
	sdram_d_oe,
	sdram_d_o,
	//
	option
);
	input		res;
	input		clk;
	input		write_req;
	input	[3:0]	write_byte;
	input	[31:0]	write_address;
	input	[31:0]	write_data;
	output		write_ack;
	input		read_req;
	input	[3:0]	read_byte;
	input	[31:0]	read_address;
	output	[31:0]	read_data;
	output		read_ack;
	input		dma_req;
	input	[31:0]	dma_address;
	output		dma_ack;
	output		dma_exist;
	output	[15:0]	dma_data;
	output		sdram_clk;
	output		sdram_cke;
	output	[1:0]	sdram_cs_n;
	output		sdram_ras_n;
	output		sdram_cas_n;
	output		sdram_we_n;
	output	[1:0]	sdram_dqm;
	output	[1:0]	sdram_ba;
	output	[12:0]	sdram_adr;
	input	[15:0]	sdram_d_i;
	output	[15:0]	sdram_d_oe;
	output	[15:0]	sdram_d_o;
	input		option;

	// init requester
	reg		init_req;
	wire		init_exit;
	always @(posedge clk or posedge res)
		if (res)		init_req <= 1'b1;
		else if (init_exit)	init_req <= 1'b0;

	// refresh requester
	reg	[7:0]	refresh_timer;
	wire		refresh_timer_expire;
	reg		refresh_req;
	wire		refresh_exit;
	assign refresh_timer_expire = (refresh_timer==8'd255);
	//assign refresh_timer_expire = (refresh_timer==8'd127);
	//assign refresh_timer_expire = (refresh_timer==8'd64);

	always @(posedge clk or posedge res)
		if (res)			refresh_timer <= 8'd0;
		else if (refresh_timer_expire)	refresh_timer <= 8'd0;
		else				refresh_timer <= refresh_timer + 8'd1;
	always @(posedge clk or posedge res)
		if (res)			refresh_req <= 1'b1;
		else if (refresh_exit)		refresh_req <= 1'b0;
		else if (refresh_timer_expire)	refresh_req <= 1'b1; // test is 0

	// input pre_rgiter(must include IOB)
	reg	[15:0]	ctrl_rd;
	always @(posedge clk or posedge res)
		if (res) begin
			ctrl_rd <= {2{8'h00}};
		end
		else begin
			ctrl_rd <= sdram_d_i;
		end
	
	// sdram_ctrl
	wire		write_enter;
	wire		write_exit;
	wire		write_valid;
	wire		read_enter;
	wire		read_valid;
	wire		read_exit;
	wire		dma_enter;
	wire		dma_exit;
	wire		dma_valid;
	wire	[4:0]	ctrl_cmd;
	wire	[1:0]	ctrl_cs;
	wire	[1:0]	ctrl_ba;
	wire	[12:0]	ctrl_a;
	tessera_sdram_ctrl i_tessera_sdram_ctrl (
		.res(		res),
		.clk(		clk),
		.init_req(	init_req),
		.init_enter(	/* not used */),
		.init_exit(	init_exit),
		.refresh_req(	refresh_req),
		.refresh_enter(	/* not used */),
		.refresh_exit(	refresh_exit),
		.write_req(	write_req),
		.write_enter(	write_enter),
		.write_valid(	/* not used */),
		.write_exit(	write_exit),
		.write_address(	write_address),
		.read_req(	read_req),
		.read_enter(	read_enter),
		.read_valid(	read_valid),
		.read_exit(	read_exit),
		.read_address(	read_address),
		.dma_req(	dma_req),
		.dma_enter(	dma_enter),
		.dma_exit(	dma_exit),
		.dma_valid(	dma_valid),
		.dma_address(	dma_address),
		.ctrl_cmd(	ctrl_cmd),
		.ctrl_cs(	ctrl_cs),
		.ctrl_ba(	ctrl_ba),
		.ctrl_a(	ctrl_a),
		.option(	option)
	);

	reg	[3:0]	read_exit_z;
	always @(posedge clk or posedge res)
		if (res) read_exit_z <= 4'b0000;
		else     read_exit_z <= {read_exit_z[2:0],read_exit};
	//assign read_ack	= read_exit_z[2]; // when latency 2 data&ack just
	assign read_ack		= read_exit_z[3]; // when latency 3 data&ack just
	assign write_ack	= write_exit;	// is ff_signal
	assign dma_ack		= dma_exit;	// is ff_signal

	// input valiad signal
	reg	[5:0]	dma_valid_z;
	reg	[5:0]	read_valid_z;
	always @(posedge clk or posedge res)
		if (res) begin
			dma_valid_z <= 6'b0_0000;
			read_valid_z <= 6'b0_0000;
		end
		else begin
			dma_valid_z <= {dma_valid_z[4:0],dma_valid};
			read_valid_z <= {read_valid_z[4:0],read_valid};
		end
	
	// enter signals
	reg		write_enter_z;
	reg	[8:0]	read_enter_z;
	reg	[8:0]	dma_enter_z;
	always @(posedge clk or posedge res)
		if (res) begin
			write_enter_z	<= 1'b0;
			read_enter_z	<= {9{1'b0}};
			dma_enter_z	<= {9{1'b0}};
		end
		else begin
			write_enter_z	<= write_enter;
			read_enter_z	<= {read_enter_z[7:0],read_enter};
			dma_enter_z	<= {dma_enter_z[7:0],dma_enter};
		end
		
	// WRITE BUFFER(LongAccess)
	reg	[3:0]	write_byte_temp;
	reg	[31:0]	write_data_temp;
	always @(posedge clk or posedge res)
		if (res) begin
			write_byte_temp <= {4{1'b0}};
			write_data_temp <= {4{8'h00}};
		end
		else begin
			write_byte_temp <= (write_enter_z) ? write_byte: {write_byte_temp[1:0],2'b00};				// write_dqm is none-latehcy(always)
			write_data_temp <= (write_enter_z) ? write_data: {write_data_temp[15:0],16'h00_00};
		end

	// READ BUFFER(LongAccess)
	reg	[3:0]	read_byte_temp;
	reg	[31:0]	read_data_temp;
	always @(posedge clk or posedge res)
		if (res) begin
			read_byte_temp <= {4{1'b0}};
			read_data_temp <= {4{8'h00}};
		end
		else begin
			//read_byte_temp <= (read_enter_z[0]) ? read_byte: {read_byte_temp[1:0],2'b00};				// read_dqm is 2latency
			read_byte_temp <= (read_enter_z[1]) ? read_byte: {read_byte_temp[1:0],2'b00};				// read_dqm is 3latency
			//read_data_temp <= (read_valid_z[4]) ? {read_data_temp[15:0],ctrl_rd}: read_data_temp;			// latch data(2latency)
			read_data_temp <= (read_valid_z[5]) ? {read_data_temp[15:0],ctrl_rd}: read_data_temp;			// latch data(3latency)
		end
	assign read_data = read_data_temp;

	// DMA BUFFER(8 x LongInt)
	reg	[63:0]	dma_byte_temp;
	reg	[15:0]	dma_data_temp;
	reg		dma_exist_temp;
	always @(posedge clk or posedge res)
		if (res) begin
			dma_byte_temp <= {64{1'b0}};
			dma_data_temp <= {2{8'h00}};
			dma_exist_temp <= 1'b0;
		end
		else begin
			//dma_byte_temp <= (dma_enter_z[0]) ? 64'hffff_ffff_ffff_ffff: {dma_byte_temp[61:0],2'b00};		// read_dqm is 2latency
			dma_byte_temp <= (dma_enter_z[1]) ? 64'hffff_ffff_ffff_ffff: {dma_byte_temp[61:0],2'b00};		// read_dqm is 3latency
			//dma_data_temp <= (dma_valid_z[4]) ? ctrl_rd: dma_data_temp;						// latch data(2latency)
			//dma_exist_temp <= dma_valid_z[4];									// flag(2latency)
			dma_data_temp <= (dma_valid_z[5]) ? ctrl_rd: dma_data_temp;						// latch data(3latency)
			dma_exist_temp <= dma_valid_z[5];									// flag(3latency)
		end
	assign dma_exist = dma_exist_temp;
	assign dma_data  = dma_data_temp;

	// output final regiter(must include IOB)
	reg		sdram_cke;
	reg	[1:0]	sdram_cs_n;
	reg		sdram_ras_n;
	reg		sdram_cas_n;
	reg		sdram_we_n;
	reg	[1:0]	sdram_dqm;
	reg	[1:0]	sdram_ba;
	reg	[12:0]	sdram_adr;
	reg	[15:0]	sdram_d_oe;
	reg	[15:0]	sdram_d_o;
	assign sdram_clk = clk;
	always @(posedge clk or posedge res)
		if (res) begin
			sdram_cke	<= 1'b0;
			sdram_cs_n	<= 1'b0;
			sdram_ras_n	<= 1'b1;
			sdram_cas_n	<= 1'b1;
			sdram_we_n	<= 1'b1;
			sdram_dqm	<= {2{1'b1}};
			sdram_ba	<= 2'b00;
			sdram_adr	<= 13'd0;
			sdram_d_oe	<= {2{8'h00}};
			sdram_d_o	<= {2{8'h00}};
		end
		else begin
			sdram_cke	<= ctrl_cmd[4];
			sdram_cs_n	<= ~(ctrl_cs&{2{ctrl_cmd[3]}});
			sdram_ras_n	<= !ctrl_cmd[2];
			sdram_cas_n	<= !ctrl_cmd[1];
			sdram_we_n	<= !ctrl_cmd[0];
			sdram_dqm	<= ~( {(write_byte_temp[3]||read_byte_temp[3]||dma_byte_temp[63]),(write_byte_temp[2]||read_byte_temp[2]||dma_byte_temp[62])} );
			sdram_ba	<= ctrl_ba&{2{ctrl_cmd[3]}};
			sdram_adr	<= ctrl_a&{13{ctrl_cmd[3]}};
			sdram_d_oe	<= { {8{write_byte_temp[3]}},{8{write_byte_temp[2]}} };
			sdram_d_o	<= write_data_temp[31:16];
		end
endmodule

module tessera_sdram_wbif (
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
	write_req,
	write_byte,
	write_address,
	write_data,
	write_ack,
	read_req,
	read_byte,
	read_address,
	read_data,
	read_ack
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
	output		write_req;
	output	[3:0]	write_byte;
	output	[31:0]	write_address;
	output	[31:0]	write_data;
	input		write_ack;
	output		read_req;
	output	[3:0]	read_byte;
	output	[31:0]	read_address;
	input	[31:0]	read_data;
	input		read_ack;
	//
	//
	//
	assign wb_err_o = 1'b0;
	//
	//
	//
	reg		write_ack_z;
	reg		read_ack_z;
	reg		wb_ack;
	always @(posedge clk or posedge res)
		if (res)	write_ack_z <= 1'b0;
		else		write_ack_z <= write_ack;
	always @(posedge clk or posedge res)
		if (res)	read_ack_z <= 1'b0;
		else		read_ack_z <= read_ack;
	always @(posedge clk or posedge res)
		if (res)	wb_ack <= 1'b0;
		//else		wb_ack <= (write_ack_z&&!write_ack)||(read_ack_z&&!read_ack); // release negedge ack(late)
		else		wb_ack <= (!write_ack_z&&write_ack)||(!read_ack_z&&read_ack); // release posedge ack(fast)
	assign wb_ack_o = (wb_cyc_i&&wb_stb_i) ? wb_ack: 1'b0;
	//
	//
	//
	reg	[31:0]	wb_dat;
	always @(posedge clk or posedge res)
		if (res)	wb_dat <= {4{8'h00}};
		else		wb_dat <= read_data;
	assign wb_dat_o = (wb_cyc_i&&wb_stb_i) ? wb_dat[31:0]: {4{8'h00}};
	//
	//
	//
	reg	[3:0]	write_byte;
	reg	[31:0]	write_address;
	reg	[31:0]	write_data;
	//
	reg	[3:0]	read_byte;
	reg	[31:0]	read_address;
	always @(posedge clk or posedge res)
		if (res) begin
			write_byte	<= {4{1'b0}};
			write_address	<= 32'd0;
			write_data	<= {4{8'h00}};
			//
			read_byte	<= {4{1'b0}};
			read_address	<= 32'd0;
		end
		else begin
			write_byte	<= wb_sel_i;
			write_address	<= wb_adr_i; // masking controler,{8'd0,wb_adr_i[23:0]};
			write_data	<= wb_dat_i;
			//
			read_byte	<= wb_sel_i;
			read_address	<= wb_adr_i; // masking controler,{8'd0,wb_adr_i[23:0]};
		end
	//
	//
	//
	reg		write_req;
	reg		read_req;
	always @(posedge clk or posedge res)
		if (res)									write_req <= 1'b0;
		else if (write_ack)								write_req <= 1'b0;
		else if (wb_cyc_i && wb_stb_i && !wb_ack_o && !write_ack_z && wb_we_i)		write_req <= 1'b1; // wait ack low
		
	always @(posedge clk or posedge res)
		if (res)									read_req <= 1'b0;
		else if (read_ack)								read_req <= 1'b0;
		else if (wb_cyc_i && wb_stb_i && !wb_ack_o && !read_ack_z  && !wb_we_i)		read_req <= 1'b1; // wait ack low

endmodule

module tessera_sdram (
	sys_wb_res,
	sys_wb_clk,
	sys_sdram_res,
	sys_sdram_clk,
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
	dma_req,
	dma_address,
	dma_ack,
	dma_exist,
	dma_data,
	sdram_clk,
	sdram_cke,
	sdram_cs_n,
	sdram_ras_n,
	sdram_cas_n,
	sdram_we_n,
	sdram_dqm,
	sdram_ba,
	sdram_a,
	sdram_d_i,
	sdram_d_oe,
	sdram_d_o,
	//
	option
);
	// system
	input		sys_wb_res;
	input		sys_wb_clk;
	input		sys_sdram_res;
	input		sys_sdram_clk;
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
	// Dma
	input		dma_req;
	input	[31:0]	dma_address;
	output		dma_ack;
	output		dma_exist;
	output	[15:0]	dma_data;
	// External SDRAM
	output		sdram_clk;
	output		sdram_cke;
	output	[1:0]	sdram_cs_n;
	output		sdram_ras_n;
	output		sdram_cas_n;
	output		sdram_we_n;
	output	[1:0]	sdram_dqm;
	output	[1:0]	sdram_ba;
	output	[12:0]	sdram_a;
	input	[15:0]	sdram_d_i;
	output	[15:0]	sdram_d_oe;
	output	[15:0]	sdram_d_o;
	// test
	input		option;

// sdram_wbif
	wire		wbif_write_req;
	wire	[3:0]	wbif_write_byte;
	wire	[31:0]	wbif_write_address;
	wire	[31:0]	wbif_write_data;
	//wire		wbif_write_ack;
	reg		wbif_write_ack;
	wire		wbif_read_req;
	wire	[3:0]	wbif_read_byte;
	wire	[31:0]	wbif_read_address;
	wire	[31:0]	wbif_read_data;
	//wire		wbif_read_ack;
	reg		wbif_read_ack;

// sdram_core
	//wire		core_write_req;
	reg		core_write_req;
	wire	[3:0]	core_write_byte;
	wire	[31:0]	core_write_address;
	wire	[31:0]	core_write_data;
	wire		core_write_ack;
	//wire		core_read_req;
	reg		core_read_req;
	wire	[3:0]	core_read_byte;
	wire	[31:0]	core_read_address;
	wire	[31:0]	core_read_data;
	wire		core_read_ack;

	// sdram_wbif(DOMAIN WinsboneClock)
	tessera_sdram_wbif i_tessera_sdram_wbif (
		.res(		sys_wb_res),
		.clk(		sys_wb_clk),
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
		.write_req(	wbif_write_req),	// is ff
		.write_byte(	wbif_write_byte),	// is ff
		.write_address(	wbif_write_address),	// is ff
		.write_data(	wbif_write_data),	// is ff
		.write_ack(	wbif_write_ack),
		.read_req(	wbif_read_req),		// is ff
		.read_byte(	wbif_read_byte),	// is ff
		.read_address(	wbif_read_address),	// is ff
		.read_data(	wbif_read_data),
		.read_ack(	wbif_read_ack)
	);

//
// no-mt1-mt2(TYPE A:same clock)
// 
// sync (sys_wbif_clk<=>sys_sdram_clk) , small & fastpath , danger
/*
	// sd to wb
	assign wbif_write_ack		= core_write_ack;
	assign wbif_read_data		= core_read_data;
	assign wbif_read_ack		= core_read_ack;
	// wb to sd
	assign core_write_req		= wbif_write_req;
	assign core_write_byte		= wbif_write_byte;
	assign core_write_address	= wbif_write_address;
	assign core_write_data		= wbif_write_data;
	assign core_read_req		= wbif_read_req;
	assign core_read_byte		= wbif_read_byte;
	assign core_read_address	= wbif_read_address;
*/
//
// only startpoint(TYPE B:same clock,pos<->neg,timeing is safety)
//
// sync
// sd to wb
/*
	reg		mt_write_ack;
	reg	[31:0]	mt_read_data;
	reg		mt_read_ack;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res) begin
			mt_write_ack		<= 1'b0;
			mt_read_data		<= {4{8'h00}};
			mt_read_ack		<= 1'b0;
		end
		else begin
			mt_write_ack		<= core_write_ack;
			mt_read_data		<= core_read_data;
			mt_read_ack		<= core_read_ack;
		end
	reg		mt_write_req;
	reg	[3:0]	mt_write_byte;
	reg	[31:0]	mt_write_address;
	reg	[31:0]	mt_write_data;
	reg		mt_read_req;
	reg	[3:0]	mt_read_byte;
	reg	[31:0]	mt_read_address;
	always @(posedge sys_sdram_clk or posedge sys_sdram_res)
		if (sys_sdram_res) begin
			mt_write_req		<= 1'b0;
			mt_write_byte		<= {4{1'b0}};
			mt_write_address	<= 32'd0;
			mt_write_data		<= {4{8'h00}};
			mt_read_req		<= 1'b0;
			mt_read_byte		<= {4{1'b0}};
			mt_read_address		<= 32'd0;
		end
		else begin
			mt_write_req		<= wbif_write_req;
			mt_write_byte		<= wbif_write_byte;
			mt_write_address	<= wbif_write_address;
			mt_write_data		<= wbif_write_data;
			mt_read_req		<= wbif_read_req;
			mt_read_byte		<= wbif_read_byte;
			mt_read_address		<= wbif_read_address;
		end
	// sd to wb
	assign wbif_write_ack		= mt_write_ack;
	assign wbif_read_data		= mt_read_data;
	assign wbif_read_ack		= mt_read_ack;
	// wb to sd
	assign core_write_req		= mt_write_req;
	assign core_write_byte		= mt_write_byte;
	assign core_write_address	= mt_write_address;
	assign core_write_data		= mt_write_data;
	assign core_read_req		= mt_read_req;
	assign core_read_byte		= mt_read_byte;
	assign core_read_address	= mt_read_address;
*/
//
// mt1 mt2(TYPE C:other clock)
//
// not need to sync (sys_wbif_clk<=>sys_sdram_clk)
// sd to wb
	reg		mt1_write_ack;
	reg	[31:0]	mt1_read_data;
	reg		mt1_read_ack;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res) begin
			mt1_write_ack		<= 1'b0;
			mt1_read_data		<= {4{8'h00}};
			mt1_read_ack		<= 1'b0;
		end
		else begin
			mt1_write_ack		<= core_write_ack;
			mt1_read_data		<= core_read_data;
			mt1_read_ack		<= core_read_ack;
		end
	reg		mt2_write_ack;
	reg	[31:0]	mt2_read_data;
	reg		mt2_read_ack;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res) begin
			mt2_write_ack		<= 1'b0;
			mt2_read_data		<= {4{8'h00}};
			mt2_read_ack		<= 1'b0;
		end
		else begin
			mt2_write_ack		<= mt1_write_ack;
			mt2_read_data		<= mt1_read_data;
			mt2_read_ack		<= mt1_read_ack;
		end
	reg		mt1_write_req;
	reg	[3:0]	mt1_write_byte;
	reg	[31:0]	mt1_write_address;
	reg	[31:0]	mt1_write_data;
	reg		mt1_read_req;
	reg	[3:0]	mt1_read_byte;
	reg	[31:0]	mt1_read_address;
	always @(posedge sys_sdram_clk or posedge sys_sdram_res)
		if (sys_sdram_res) begin
			mt1_write_req		<= 1'b0;
			mt1_write_byte		<= {4{1'b0}};
			mt1_write_address	<= 32'd0;
			mt1_write_data		<= {4{8'h00}};
			mt1_read_req		<= 1'b0;
			mt1_read_byte		<= {4{1'b0}};
			mt1_read_address	<= 32'd0;
		end
		else begin
			mt1_write_req		<= wbif_write_req;
			mt1_write_byte		<= wbif_write_byte;
			mt1_write_address	<= wbif_write_address;
			mt1_write_data		<= wbif_write_data;
			mt1_read_req		<= wbif_read_req;
			mt1_read_byte		<= wbif_read_byte;
			mt1_read_address	<= wbif_read_address;
		end
	reg		mt2_write_req;
	reg	[3:0]	mt2_write_byte;
	reg	[31:0]	mt2_write_address;
	reg	[31:0]	mt2_write_data;
	reg		mt2_read_req;
	reg	[3:0]	mt2_read_byte;
	reg	[31:0]	mt2_read_address;
	always @(posedge sys_sdram_clk or posedge sys_sdram_res)
		if (sys_sdram_res) begin
			mt2_write_req		<= 1'b0;
			mt2_write_byte		<= {4{1'b0}};
			mt2_write_address	<= 32'd0;
			mt2_write_data		<= {4{8'h00}};
			mt2_read_req		<= 1'b0;
			mt2_read_byte		<= {4{1'b0}};
			mt2_read_address	<= 32'd0;
		end
		else begin
			mt2_write_req		<= mt1_write_req;
			mt2_write_byte		<= mt1_write_byte;
			mt2_write_address	<= mt1_write_address;
			mt2_write_data		<= mt1_write_data;
			mt2_read_req		<= mt1_read_req;
			mt2_read_byte		<= mt1_read_byte;
			mt2_read_address	<= mt1_read_address;
		end
// sd to wb
	//assign wbif_write_ack		= mt2_write_ack;
	//assign wbif_read_ack		= mt2_read_ack;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res) begin
			wbif_write_ack	<= 1'b0;
			wbif_read_ack	<= 1'b0;
		end
		else begin
			wbif_write_ack	<= mt2_write_ack;	// can not load data, so must +1delay
			wbif_read_ack	<= mt2_read_ack;	// can not load data, so must +1delay
		end
	assign wbif_read_data		= mt2_read_data;

// wb to sd
	//assign core_write_req		= mt2_write_req;
	//assign core_read_req		= mt2_read_req;
	always @(posedge sys_sdram_clk or posedge sys_sdram_res)
		if (sys_sdram_res) begin
			core_write_req	<= 1'b0;
			core_read_req	<= 1'b0;
		end
		else begin
			core_write_req	<= mt2_write_req;	// can not load data, so must +1delay
			core_read_req	<= mt2_read_req;	// can not load data, so must +1delay
		end
	assign core_write_byte		= mt2_write_byte;
	assign core_write_address	= mt2_write_address;
	assign core_write_data		= mt2_write_data;
	assign core_read_byte		= mt2_read_byte;
	assign core_read_address	= mt2_read_address;

// inst
	tessera_sdram_core i_tessera_sdram_core (
		.res(		sys_sdram_res),
		.clk(		sys_sdram_clk),
		.write_req(	core_write_req),
		.write_byte(	core_write_byte),
		.write_address(	core_write_address),
		.write_data(	core_write_data),
		.write_ack(	core_write_ack),	// is ff signal
		.read_req(	core_read_req),
		.read_byte(	core_read_byte),
		.read_address(	core_read_address),
		.read_data(	core_read_data),	// is ff signal
		.read_ack(	core_read_ack),		// is ff signal
		.dma_req(	dma_req),
		.dma_address(	dma_address),
		.dma_ack(	dma_ack),
		.dma_exist(	dma_exist),
		.dma_data(	dma_data),
		.sdram_clk(	sdram_clk),
		.sdram_cke(	sdram_cke),
		.sdram_cs_n(	sdram_cs_n),
		.sdram_ras_n(	sdram_ras_n),
		.sdram_cas_n(	sdram_cas_n),
		.sdram_we_n(	sdram_we_n),
		.sdram_dqm(	sdram_dqm),
		.sdram_ba(	sdram_ba),
		.sdram_adr(	sdram_a),
		.sdram_d_i(	sdram_d_i),
		.sdram_d_oe(	sdram_d_oe),
		.sdram_d_o(	sdram_d_o),
		.option(	option)
	);

endmodule

