
`timescale 1ps/1ps

module tessera_mem_core (
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
	mem_cs2_n,
	mem_cs2_g_n,
	mem_cs2_dir,
	mem_cs2_rstdrv,
	mem_cs2_int,
	mem_cs2_iochrdy,
	mem_cs1_n,
	mem_cs1_rst_n,
	mem_cs1_rdy,
	mem_cs0_n,
	mem_we_n,
	mem_oe_n,
	mem_a,
	mem_d_o,
	mem_d_oe,
	mem_d_i
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
	//
	output		mem_cs2_n;
	output		mem_cs2_g_n;
	output		mem_cs2_dir;
	output		mem_cs2_rstdrv;
	input		mem_cs2_int;
	input		mem_cs2_iochrdy;
	// for FLASH(big)
	output		mem_cs1_n;
	output		mem_cs1_rst_n;
	input		mem_cs1_rdy;
	// for FLASH(small)
	output		mem_cs0_n;
	// misc
	output		mem_we_n;
	output		mem_oe_n;
	output	[22:0]	mem_a;
	output	[7:0]	mem_d_o;
	output	[7:0]	mem_d_oe;
	input	[7:0]	mem_d_i;

//
// request control(no-ff)
//
	wire		cs0_write_req;
	wire		cs0_read_req;
	wire		cs1_write_req;
	wire		cs1_read_req;
	wire		cs2_write_req;
	wire		cs2_read_req;
	wire		write_fin;
	wire		read_fin;
	reg		write_ack;
	reg		read_ack;
	assign cs0_write_req	= write_req			&& !write_ack	&& (write_address[23:22]==2'b00);	// BASE + 0x000x_xxxx
	assign cs0_read_req	= (read_req&&!write_req)	&& !read_ack	&& ( read_address[23:22]==2'b00);	// BASE + 0x000x_xxxx
	
	assign cs2_write_req	= write_req			&& !write_ack	&& (write_address[23:22]==2'b01);	// BASE + 0x004x_xxxx
	assign cs2_read_req	= (read_req&&!write_req)	&& !read_ack	&& ( read_address[23:22]==2'b01);	// BASE + 0x004x_xxxx

	assign cs1_write_req	= write_req			&& !write_ack	&& (write_address[23]   ==1'b1);	// BASE + 0x008x_xxxx
	assign cs1_read_req	= (read_req&&!write_req)	&& !read_ack	&& ( read_address[23]   ==1'b1);	// BASE + 0x008x_xxxx
//
// cs0
//
	wire		cs0_write_count_full;
	wire		cs0_write_byte_full;
	wire		cs0_write_cs;
	wire		cs0_write_strobe;
	wire	[3:0]	cs0_write_load;
	wire	[22:0]	cs0_write_addr;
	wire		cs0_write_fin;
	reg	[2:0]	cs0_write_count;
	reg	[1:0]	cs0_write_byte;
	assign cs0_write_count_full		= (3'd7==cs0_write_count);
	assign cs0_write_byte_full		= (2'd3==cs0_write_byte);
	assign cs0_write_cs			= cs0_write_req                           && (3'd0!=cs0_write_count)                                                       && (3'd7!=cs0_write_count);
	assign cs0_write_strobe			= cs0_write_req                           && (3'd0!=cs0_write_count) && (3'd1!=cs0_write_count) && (3'd6!=cs0_write_count) && (3'd7!=cs0_write_count)
						&& (
							( (2'd0==cs0_write_byte) && write_byte[3] )
							||
							( (2'd1==cs0_write_byte) && write_byte[2] )
							||
							( (2'd2==cs0_write_byte) && write_byte[1] )
							||
							( (2'd3==cs0_write_byte) && write_byte[0] )
						);
	assign cs0_write_load[0]		= cs0_write_req && (2'd3==cs0_write_byte) && (3'd0==cs0_write_count);
	assign cs0_write_load[1]		= cs0_write_req && (2'd2==cs0_write_byte) && (3'd0==cs0_write_count);
	assign cs0_write_load[2]		= cs0_write_req && (2'd1==cs0_write_byte) && (3'd0==cs0_write_count);
	assign cs0_write_load[3]		= cs0_write_req && (2'd0==cs0_write_byte) && (3'd0==cs0_write_count);
	assign cs0_write_addr			= (cs0_write_req) ? {write_address[22:2],cs0_write_byte[1:0]}: 23'd0;
	assign cs0_write_fin			= cs0_write_req && (2'd3==cs0_write_byte) && (3'd7==cs0_write_count);
	always @(posedge clk or posedge res)
		if (res) 			cs0_write_count	<= 3'd0;
		else if (!cs0_write_req)	cs0_write_count	<= 3'd0;
		else				cs0_write_count	<= (cs0_write_count_full) ? 3'd0: {cs0_write_count + 3'd1};	
	always @(posedge clk or posedge res)
		if (res)			cs0_write_byte	<= 2'd0;
		else if (!cs0_write_req)	cs0_write_byte	<= 2'd0;
		else if (cs0_write_count_full)	cs0_write_byte	<= (cs0_write_byte_full) ? 2'd0: {cs0_write_byte + 2'd1};
	wire		cs0_read_count_full;
	wire		cs0_read_byte_full;
	wire		cs0_read_cs;
	wire		cs0_read_strobe;
	wire	[3:0]	cs0_read_load;
	wire	[22:0]	cs0_read_addr;
	wire		cs0_read_fin;
	reg	[2:0]	cs0_read_count;
	reg	[1:0]	cs0_read_byte;
	//assign cs0_read_count_full		= (3'd7==cs0_read_count);
	//assign cs0_read_byte_full		= (2'd3==cs0_read_byte);
	//assign cs0_read_cs			= cs0_read_req                          && (3'd0!=cs0_read_count)                                                     && (3'd7!=cs0_read_count);
	//assign cs0_read_strobe			= cs0_read_req                          && (3'd0!=cs0_read_count) && (3'd1!=cs0_read_count) && (3'd6!=cs0_read_count) && (3'd7!=cs0_read_count);
	//assign cs0_read_load[0]			= cs0_read_req && (2'd3==cs0_read_byte) && (3'd7==cs0_read_count);
	//assign cs0_read_load[1]			= cs0_read_req && (2'd2==cs0_read_byte) && (3'd7==cs0_read_count);
	//assign cs0_read_load[2]			= cs0_read_req && (2'd1==cs0_read_byte) && (3'd7==cs0_read_count);
	//assign cs0_read_load[3]			= cs0_read_req && (2'd0==cs0_read_byte) && (3'd7==cs0_read_count);
	//assign cs0_read_addr			= (cs0_read_req) ? {read_address[22:2],cs0_read_byte[1:0]}: 23'd0;
	//assign cs0_read_fin			= cs0_read_req && (2'd3==cs0_read_byte) && (3'd7==cs0_read_count);
	assign cs0_read_count_full		= (3'd7==cs0_read_count);
	assign cs0_read_byte_full		= (2'd3==cs0_read_byte);
	assign cs0_read_cs			= cs0_read_req                          && (3'd0!=cs0_read_count)                                                     && (3'd7!=cs0_read_count);
	assign cs0_read_strobe			= cs0_read_req                          && (3'd0!=cs0_read_count) && (3'd1!=cs0_read_count) && (3'd6!=cs0_read_count) && (3'd7!=cs0_read_count)
						&& (
							( (2'd0==cs0_read_byte) && read_byte[3] )
							||
							( (2'd1==cs0_read_byte) && read_byte[2] )
							||
							( (2'd2==cs0_read_byte) && read_byte[1] )
							||
							( (2'd3==cs0_read_byte) && read_byte[0] )
						);	
	assign cs0_read_load[0]			= cs0_read_req && (2'd3==cs0_read_byte) && (3'd7==cs0_read_count); // test 7->6 
	assign cs0_read_load[1]			= cs0_read_req && (2'd2==cs0_read_byte) && (3'd7==cs0_read_count); // test 7->6
	assign cs0_read_load[2]			= cs0_read_req && (2'd1==cs0_read_byte) && (3'd7==cs0_read_count); // test 7->6
	assign cs0_read_load[3]			= cs0_read_req && (2'd0==cs0_read_byte) && (3'd7==cs0_read_count); // test 7->6
	assign cs0_read_addr			= (cs0_read_req) ? {read_address[22:2],cs0_read_byte[1:0]}: 23'd0;
	assign cs0_read_fin			= cs0_read_req && (2'd3==cs0_read_byte) && (3'd7==cs0_read_count);
	always @(posedge clk or posedge res)
		if (res) 			cs0_read_count	<= 3'd0;
		else if (!cs0_read_req)		cs0_read_count	<= 3'd0;
		else				cs0_read_count	<= (cs0_read_count_full) ? 3'd0: {cs0_read_count + 3'd1};	
	always @(posedge clk or posedge res)
		if (res)			cs0_read_byte	<= 2'd0;
		else if (!cs0_read_req)		cs0_read_byte	<= 2'd0;
		else if (cs0_read_count_full)	cs0_read_byte	<= (cs0_read_byte_full) ? 2'd0: {cs0_read_byte + 2'd1};
	//
	// cs0 outputs
	//
	reg		mem_cs0_n;
	always @(posedge clk or posedge res)
		if (res)			mem_cs0_n	<= 1'b1;
		else				mem_cs0_n	<= !(cs0_write_cs||cs0_read_cs);
//
// cs1
//
	wire		cs1_write_count_full;
	wire		cs1_write_byte_full;
	wire		cs1_write_cs;
	wire		cs1_write_strobe;
	wire	[3:0]	cs1_write_load;
	wire	[22:0]	cs1_write_addr;
	wire		cs1_write_fin;
	reg	[2:0]	cs1_write_count;
	reg	[1:0]	cs1_write_byte;
	assign cs1_write_count_full		= (3'd7==cs1_write_count);
	assign cs1_write_byte_full		= (2'd3==cs1_write_byte);
	assign cs1_write_cs			= cs1_write_req                           && (3'd0!=cs1_write_count)                                                       && (3'd7!=cs1_write_count);
	assign cs1_write_strobe			= cs1_write_req                           && (3'd0!=cs1_write_count) && (3'd1!=cs1_write_count) && (3'd6!=cs1_write_count) && (3'd7!=cs1_write_count)
						&& (
							( (2'd0==cs1_write_byte) && write_byte[3] )
							||
							( (2'd1==cs1_write_byte) && write_byte[2] )
							||
							( (2'd2==cs1_write_byte) && write_byte[1] )
							||
							( (2'd3==cs1_write_byte) && write_byte[0] )
						);
	assign cs1_write_load[0]		= cs1_write_req && (2'd3==cs1_write_byte) && (3'd0==cs1_write_count);
	assign cs1_write_load[1]		= cs1_write_req && (2'd2==cs1_write_byte) && (3'd0==cs1_write_count);
	assign cs1_write_load[2]		= cs1_write_req && (2'd1==cs1_write_byte) && (3'd0==cs1_write_count);
	assign cs1_write_load[3]		= cs1_write_req && (2'd0==cs1_write_byte) && (3'd0==cs1_write_count);
	assign cs1_write_addr			= (cs1_write_req) ? {write_address[22:2],cs1_write_byte[1:0]}: 23'd0;
	assign cs1_write_fin			= cs1_write_req && (2'd3==cs1_write_byte) && (3'd7==cs1_write_count);
	always @(posedge clk or posedge res)
		if (res) 			cs1_write_count	<= 3'd0;
		else if (!cs1_write_req)	cs1_write_count	<= 3'd0;
		else				cs1_write_count	<= (cs1_write_count_full) ? 3'd0: {cs1_write_count + 3'd1};	
	always @(posedge clk or posedge res)
		if (res)			cs1_write_byte	<= 2'd0;
		else if (!cs1_write_req)	cs1_write_byte	<= 2'd0;
		else if (cs1_write_count_full)	cs1_write_byte	<= (cs1_write_byte_full) ? 2'd0: {cs1_write_byte + 2'd1};
	wire		cs1_read_count_full;
	wire		cs1_read_byte_full;
	wire		cs1_read_cs;
	wire		cs1_read_strobe;
	wire	[3:0]	cs1_read_load;
	wire	[22:0]	cs1_read_addr;
	wire		cs1_read_fin;
	reg	[2:0]	cs1_read_count;
	reg	[1:0]	cs1_read_byte;
	assign cs1_read_count_full		= (3'd7==cs1_read_count);
	assign cs1_read_byte_full		= (2'd3==cs1_read_byte);
	assign cs1_read_cs			= cs1_read_req                          && (3'd0!=cs1_read_count)                                                     && (3'd7!=cs1_read_count);
	assign cs1_read_strobe			= cs1_read_req                          && (3'd0!=cs1_read_count) && (3'd1!=cs1_read_count) && (3'd6!=cs1_read_count) && (3'd7!=cs1_read_count)
						&& (
							( (2'd0==cs1_read_byte) && read_byte[3] )
							||
							( (2'd1==cs1_read_byte) && read_byte[2] )
							||
							( (2'd2==cs1_read_byte) && read_byte[1] )
							||
							( (2'd3==cs1_read_byte) && read_byte[0] )
						);	
	assign cs1_read_load[0]			= cs1_read_req && (2'd3==cs1_read_byte) && (3'd7==cs1_read_count);
	assign cs1_read_load[1]			= cs1_read_req && (2'd2==cs1_read_byte) && (3'd7==cs1_read_count);
	assign cs1_read_load[2]			= cs1_read_req && (2'd1==cs1_read_byte) && (3'd7==cs1_read_count);
	assign cs1_read_load[3]			= cs1_read_req && (2'd0==cs1_read_byte) && (3'd7==cs1_read_count);
	assign cs1_read_addr			= (cs1_read_req) ? {read_address[22:2],cs1_read_byte[1:0]}: 23'd0;
	assign cs1_read_fin			= cs1_read_req && (2'd3==cs1_read_byte) && (3'd7==cs1_read_count);
	always @(posedge clk or posedge res)
		if (res) 			cs1_read_count	<= 3'd0;
		else if (!cs1_read_req)		cs1_read_count	<= 3'd0;
		else				cs1_read_count	<= (cs1_read_count_full) ? 3'd0: {cs1_read_count + 3'd1};	
	always @(posedge clk or posedge res)
		if (res)			cs1_read_byte	<= 2'd0;
		else if (!cs1_read_req)		cs1_read_byte	<= 2'd0;
		else if (cs1_read_count_full)	cs1_read_byte	<= (cs1_read_byte_full) ? 2'd0: {cs1_read_byte + 2'd1};
	//
	// cs1 outputs
	//
	reg		mem_cs1_n;
	reg		mem_cs1_rst_n;
	always @(posedge clk or posedge res)
		if (res)			mem_cs1_n	<= 1'b1;
		else				mem_cs1_n	<= !(cs1_write_cs||cs1_read_cs);
	always @(posedge clk or posedge res)
		if (res)			mem_cs1_rst_n	<= 1'b0;
		else				mem_cs1_rst_n	<= 1'b1;
//
// cs2
//
	wire		cs2_write_count_full;
	wire		cs2_write_byte_full;
	wire		cs2_write_cs;
	wire		cs2_write_strobe;
	wire	[3:0]	cs2_write_load;
	wire	[22:0]	cs2_write_addr;
	wire		cs2_write_fin;
	reg	[2:0]	cs2_write_count;
	reg	[1:0]	cs2_write_byte;
	assign cs2_write_count_full		= (3'd7==cs2_write_count);
	assign cs2_write_byte_full		= (2'd3==cs2_write_byte);
	assign cs2_write_cs			= cs2_write_req                           && (3'd0!=cs2_write_count)                                                       && (3'd7!=cs2_write_count);
	assign cs2_write_strobe			= cs2_write_req                           && (3'd0!=cs2_write_count) && (3'd1!=cs2_write_count) && (3'd6!=cs2_write_count) && (3'd7!=cs2_write_count)
						&& (
							( (2'd0==cs2_write_byte) && write_byte[3] )
							||
							( (2'd1==cs2_write_byte) && write_byte[2] )
							||
							( (2'd2==cs2_write_byte) && write_byte[1] )
							||
							( (2'd3==cs2_write_byte) && write_byte[0] )
						);
	assign cs2_write_load[0]		= cs2_write_req && (2'd3==cs2_write_byte) && (3'd0==cs2_write_count);
	assign cs2_write_load[1]		= cs2_write_req && (2'd2==cs2_write_byte) && (3'd0==cs2_write_count);
	assign cs2_write_load[2]		= cs2_write_req && (2'd1==cs2_write_byte) && (3'd0==cs2_write_count);
	assign cs2_write_load[3]		= cs2_write_req && (2'd0==cs2_write_byte) && (3'd0==cs2_write_count);
	assign cs2_write_addr			= (cs2_write_req) ? {write_address[22:2],cs2_write_byte[1:0]}: 23'd0;
	assign cs2_write_fin			= cs2_write_req && (2'd3==cs2_write_byte) && (3'd7==cs2_write_count);
	always @(posedge clk or posedge res)
		if (res) 			cs2_write_count	<= 3'd0;
		else if (!cs2_write_req)	cs2_write_count	<= 3'd0;
		else				cs2_write_count	<= (cs2_write_count_full) ? 3'd0: {cs2_write_count + 3'd1};	
	always @(posedge clk or posedge res)
		if (res)			cs2_write_byte	<= 2'd0;
		else if (!cs2_write_req)	cs2_write_byte	<= 2'd0;
		else if (cs2_write_count_full)	cs2_write_byte	<= (cs2_write_byte_full) ? 2'd0: {cs2_write_byte + 2'd1};
	wire		cs2_read_count_full;
	wire		cs2_read_byte_full;
	wire		cs2_read_cs;
	wire		cs2_read_strobe;
	wire	[3:0]	cs2_read_load;
	wire	[22:0]	cs2_read_addr;
	wire		cs2_read_fin;
	reg	[2:0]	cs2_read_count;
	reg	[1:0]	cs2_read_byte;
	assign cs2_read_count_full		= (3'd7==cs2_read_count);
	assign cs2_read_byte_full		= (2'd3==cs2_read_byte);
	assign cs2_read_cs			= cs2_read_req                          && (3'd0!=cs2_read_count)                                                     && (3'd7!=cs2_read_count);
	assign cs2_read_strobe			= cs2_read_req                          && (3'd0!=cs2_read_count) && (3'd1!=cs2_read_count) && (3'd6!=cs2_read_count) && (3'd7!=cs2_read_count)
						&& (
							( (2'd0==cs2_read_byte) && read_byte[3] )
							||
							( (2'd1==cs2_read_byte) && read_byte[2] )
							||
							( (2'd2==cs2_read_byte) && read_byte[1] )
							||
							( (2'd3==cs2_read_byte) && read_byte[0] )
						);	
	assign cs2_read_load[0]			= cs2_read_req && (2'd3==cs2_read_byte) && (3'd7==cs2_read_count);
	assign cs2_read_load[1]			= cs2_read_req && (2'd2==cs2_read_byte) && (3'd7==cs2_read_count);
	assign cs2_read_load[2]			= cs2_read_req && (2'd1==cs2_read_byte) && (3'd7==cs2_read_count);
	assign cs2_read_load[3]			= cs2_read_req && (2'd0==cs2_read_byte) && (3'd7==cs2_read_count);
	assign cs2_read_fin			= cs2_read_req && (2'd3==cs2_read_byte) && (3'd7==cs2_read_count);
	assign cs2_read_addr			= (cs2_read_req) ? {read_address[22:2],cs2_read_byte[1:0]}: 23'd0;
	always @(posedge clk or posedge res)
		if (res) 			cs2_read_count	<= 3'd0;
		else if (!cs2_read_req)		cs2_read_count	<= 3'd0;
		else				cs2_read_count	<= (cs2_read_count_full) ? 3'd0: {cs2_read_count + 3'd1};	
	always @(posedge clk or posedge res)
		if (res)			cs2_read_byte	<= 2'd0;
		else if (!cs2_read_req)		cs2_read_byte	<= 2'd0;
		else if (cs2_read_count_full)	cs2_read_byte	<= (cs2_read_byte_full) ? 2'd0: {cs2_read_byte + 2'd1};
	//
	// cs2 outputs
	//
	reg		mem_cs2_n;
	reg		mem_cs2_g_n;
	reg		mem_cs2_dir;
	reg		mem_cs2_rstdrv;
	always @(posedge clk or posedge res)
		if (res)			mem_cs2_n	<= 1'b1;
		else				mem_cs2_n	<= !(cs2_write_cs||cs2_read_cs);
	always @(posedge clk or posedge res)
		if (res)			mem_cs2_g_n	<= 1'b1;
		else				mem_cs2_g_n	<= !(cs2_write_cs||cs2_read_strobe);
	always @(posedge clk or posedge res)
		if (res)			mem_cs2_dir	<= 1'b1;
		else				mem_cs2_dir	<= (cs2_write_req) ? 1'b1: (cs2_read_req) ? 1'b0: mem_cs2_dir;
	always @(posedge clk or posedge res)
		if (res)			mem_cs2_rstdrv	<= 1'b1;
		else				mem_cs2_rstdrv	<= 1'b0;
//
//
//
	wire		write_strobe;
	wire		read_strobe;

	wire	[3:0]	write_load;
	wire	[3:0]	read_load;

	wire	[22:0]	write_addr;
	wire	[22:0]	read_addr;


	assign write_strobe	= cs2_write_strobe || cs1_write_strobe || cs0_write_strobe;
	assign read_strobe	= cs2_read_strobe || cs1_read_strobe || cs0_read_strobe;

	assign write_load	= cs2_write_load|cs1_write_load|cs0_write_load;
	assign read_load	= cs2_read_load |cs1_read_load |cs0_read_load;
	
	assign write_addr	= cs2_write_addr|cs1_write_addr|cs0_write_addr;
	assign read_addr	= cs2_read_addr |cs1_read_addr |cs0_read_addr;

//
// outputs(common)
//
	reg		mem_we_n;
	reg		mem_oe_n;
	reg	[22:0]	mem_a;
	reg	[7:0]	mem_d_oe;
	always @(posedge clk or posedge res)
		if (res)			mem_we_n	<= 1'b1;
		else				mem_we_n	<= !write_strobe;
	always @(posedge clk or posedge res)
		if (res)			mem_oe_n	<= 1'b1;
		else				mem_oe_n	<= !read_strobe;
	always @(posedge clk or posedge res)
		if (res)			mem_a		<= 23'h00_0000;
		else				mem_a		<= write_addr|read_addr;
	always @(posedge clk or posedge res)
		if (res)			mem_d_oe	<= 8'h00;
       		else				mem_d_oe	<= {8{cs2_write_cs||cs1_write_cs||cs0_write_cs}}; // only write
//
// inputs(common)
//
	//
	// int->ext
	//
	reg	[7:0]	pre_mem_d_o;
	always @(posedge clk or posedge res)
		if (res)			pre_mem_d_o	<= 32'h0000_0000;
		else begin
			if (write_load[3])	pre_mem_d_o	<= write_data[31:24];
			if (write_load[2])	pre_mem_d_o	<= write_data[23:16];
			if (write_load[1])	pre_mem_d_o	<= write_data[15: 8];
			if (write_load[0])	pre_mem_d_o	<= write_data[ 7: 0];
		end
	//
	reg	[7:0]	mem_d_o; // IOB
	always @(posedge clk or posedge res)
		if (res)			mem_d_o		<= 8'h00;
		else				mem_d_o		<= pre_mem_d_o;

	//
	// ext->int
	//
	reg	[7:0]	pre_mem_d_i; // IOB
	always @(posedge clk or posedge res)
		if (res)			pre_mem_d_i	<= 8'h00;
		else				pre_mem_d_i	<= mem_d_i;
	//
	reg	[31:0]	read_data;
	always @(posedge clk or posedge res)
		if (res)			read_data	<= 32'h0000_0000;
		else begin
			if (read_load[3])	read_data[31:24] <= pre_mem_d_i;
			if (read_load[2])	read_data[23:16] <= pre_mem_d_i;
			if (read_load[1])	read_data[15: 8] <= pre_mem_d_i;
			if (read_load[0])	read_data[ 7: 0] <= pre_mem_d_i;
		end
//
// ack
//
	assign write_fin	= cs2_write_fin || cs1_write_fin || cs0_write_fin;
	always @(posedge clk or posedge res)
		if (res)		write_ack <= 1'b0;
		else if (!write_req)	write_ack <= 1'b0;
		else if (write_fin)	write_ack <= 1'b1;
	assign read_fin		= cs2_read_fin || cs1_read_fin || cs0_read_fin;
	always @(posedge clk or posedge res)
		if (res)		read_ack <= 1'b0;
		else if (!read_req)	read_ack <= 1'b0;
		else if (read_fin)	read_ack <= 1'b1;
endmodule

module tessera_mem_wbif (
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
			write_address	<= {8'd0,wb_adr_i[23:0]};
			write_data	<= wb_dat_i;
			//
			read_byte	<= wb_sel_i;
			read_address	<= {8'd0,wb_adr_i[23:0]};
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
		else if (wb_cyc_i && wb_stb_i && !wb_ack_o && !read_ack_z && !wb_we_i)		read_req <= 1'b1; // wait ack low

endmodule

module tessera_mem (
	//
	sys_wb_res,
	sys_wb_clk,
	//
	sys_mem_res,
	sys_mem_clk,
	//
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
	//
	mem_cs2_n,
	mem_cs2_g_n,
	mem_cs2_dir,
	mem_cs2_rstdrv,
	mem_cs2_int,
	mem_cs2_iochrdy,
	//
	mem_cs1_n,
	mem_cs1_rst_n,
	mem_cs1_rdy,
	//
	mem_cs0_n,
	//
	mem_we_n,
	mem_oe_n,
	mem_a,
	mem_d_o,
	mem_d_oe,
	mem_d_i
);
	// System
	input		sys_wb_res;
	input		sys_wb_clk;
	input		sys_mem_res;
	input		sys_mem_clk;
	// WishBone
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
	// for MAC-PHY
	output		mem_cs2_n;
	output		mem_cs2_g_n;
	output		mem_cs2_dir;
	output		mem_cs2_rstdrv;
	input		mem_cs2_int;
	input		mem_cs2_iochrdy;
	// for FLASH(big)
	output		mem_cs1_n;
	output		mem_cs1_rst_n;
	input		mem_cs1_rdy;
	// for FLASH(small)
	output		mem_cs0_n;
	// misc
	output		mem_we_n;
	output		mem_oe_n;
	output	[22:0]	mem_a;
	output	[7:0]	mem_d_o;
	output	[7:0]	mem_d_oe;
	input	[7:0]	mem_d_i;

// mem_wbif
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

	// me,_core
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
// WishBone Clock domain
	tessera_mem_wbif i_tessera_mem_wbif (
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
		.write_req(	wbif_write_req),
		.write_byte(	wbif_write_byte),
		.write_address(	wbif_write_address),
		.write_data(	wbif_write_data),
		.write_ack(	wbif_write_ack),
		.read_req(	wbif_read_req),
		.read_byte(	wbif_read_byte),
		.read_address(	wbif_read_address),
		.read_data(	wbif_read_data),
		.read_ack(	wbif_read_ack)
	);
// no-mt1-mt2(TYPE A:same clock)
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
// only startpoint(TYPE B:same clock,pos<->neg,timeing is safety)
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
	always @(posedge sys_mem_clk or posedge sys_mem_res)
		if (sys_mem_res) begin
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
// mt1 mt2(TYPE C:other clock)
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
	always @(posedge sys_mem_clk or posedge sys_mem_res)
		if (sys_mem_res) begin
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
	always @(posedge sys_mem_clk or posedge sys_mem_res)
		if (sys_mem_res) begin
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

// mem to wb
	//assign wbif_write_ack		= mt2_write_ack;
	//assign wbif_read_ack		= mt2_read_ack;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res) begin
			wbif_write_ack	<= 1'b0;
			wbif_read_ack	<= 1'b0;
		end
		else begin
			wbif_write_ack	<= mt2_write_ack;	// can not load xxxxx, so must +1delay
			wbif_read_ack	<= mt2_read_ack;	// can not load xxxxx, so must +1delay
		end
	assign wbif_read_data		= mt2_read_data;

// wb to mem
	//assign core_write_req		= mt2_write_req;
	//assign core_read_req		= mt2_read_req;
	always @(posedge sys_mem_clk or posedge sys_mem_res)
		if (sys_mem_res) begin
			core_write_req	<= 1'b0;
			core_read_req	<= 1'b0;
		end
		else begin
			core_write_req	<= mt2_write_req;	// can not load xxxxx, so must +1delay
			core_read_req	<= mt2_read_req;	// can not load xxxxx, so must +1delay
		end
	assign core_write_byte		= mt2_write_byte;
	assign core_write_address	= mt2_write_address;
	assign core_write_data		= mt2_write_data;
	assign core_read_byte		= mt2_read_byte;
	assign core_read_address	= mt2_read_address;

// MEM Clock domain
	tessera_mem_core i_tessera_mem_core (
		.res(			sys_mem_res),
		.clk(			sys_mem_clk),
		.write_req(		core_write_req),
		.write_byte(		core_write_byte),
		.write_address(		core_write_address),
		.write_data(		core_write_data),
		.write_ack(		core_write_ack),
		.read_req(		core_read_req),
		.read_byte(		core_read_byte),
		.read_address(		core_read_address),
		.read_data(		core_read_data),
		.read_ack(		core_read_ack),
		.mem_cs2_n(		mem_cs2_n),
		.mem_cs2_g_n(		mem_cs2_g_n),
		.mem_cs2_dir(		mem_cs2_dir),
		.mem_cs2_rstdrv(	mem_cs2_rstdrv),
		.mem_cs2_int(		mem_cs2_int),
		.mem_cs2_iochrdy(	mem_cs2_iochrdy),
		.mem_cs1_n(		mem_cs1_n),
		.mem_cs1_rst_n(		mem_cs1_rst_n),
		.mem_cs1_rdy(		mem_cs1_rdy),
		.mem_cs0_n(		mem_cs0_n),
		.mem_we_n(		mem_we_n),
		.mem_oe_n(		mem_oe_n),
		.mem_a(			mem_a),
		.mem_d_o(		mem_d_o),
		.mem_d_oe(		mem_d_oe),
		.mem_d_i(		mem_d_i)
	);

endmodule
	
