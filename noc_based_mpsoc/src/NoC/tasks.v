// synthesis translate_off
task automatic cpu_write_data	(
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_y_addr,
	input	[CPU_ADR_WIDTH-1			:	0] addr_i,
	input [31							:	0]	data_i
);
	
	begin : write_data
		cpu_adr_i		[`CORE_NUM(src_x_addr,src_y_addr)] 						= {2'b00,addr_i}; 
		cpu_dat_i		[`CORE_NUM(src_x_addr,src_y_addr)]						= data_i; 
		cpu_stb_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b1;
		cpu_cyc_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b1;
		cpu_wre_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b1;
		@ (posedge cpu_ack_o		[`CORE_NUM(src_x_addr,src_y_addr)]) 
		@ (posedge clk) # 1	
		cpu_stb_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b0;
		cpu_cyc_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b0;
		cpu_wre_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b0;
		cpu_dat_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	0;
		@ (posedge clk) # 1	cpu_dat_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	0;
	end
endtask

task automatic cpu_read_data	(
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_y_addr,
	input	[CPU_ADR_WIDTH-1			  :	0] addr_i,
	output[31                  : 0] data_o
	
);
	
	begin : read_data
		cpu_adr_i		[`CORE_NUM(src_x_addr,src_y_addr)] 						= {2'b00,addr_i}; 
		cpu_stb_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b1;
		cpu_cyc_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b1;
		cpu_wre_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b0;
		@ (posedge cpu_ack_o		[`CORE_NUM(src_x_addr,src_y_addr)]) # 1	
		@ (posedge clk) # 1	
		data_o	=	cpu_dat_o[`CORE_NUM(src_x_addr,src_y_addr)];
		cpu_stb_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b0;
		cpu_cyc_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b0;
		@ (posedge clk) # 1	cpu_cyc_i		[`CORE_NUM(src_x_addr,src_y_addr)]						=	1'b0;
	end
endtask

				
task automatic send_pck(
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_y_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] des_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] des_y_addr,
	input [`NI_PCK_SIZE_WIDTH-1	:	0]	pck_size,
	input [`NI_PTR_WIDTH-1			:	0]	pck_ptr


);
  
	reg  [31:    0]               read_data;
	reg  [CPU_ADR_WIDTH-1	:	0] addr_i;
	begin: send_pck1
	   
		write_hdr ( src_x_addr,src_y_addr,des_x_addr,des_y_addr,pck_ptr);
		#20
		send_pck_cmd (src_x_addr, src_y_addr,pck_size,pck_ptr);
		read_data = 0;
		while (!	read_data[`NI_WR_DONE_LOC] )  cpu_read_data	(src_x_addr, src_y_addr, (NI_BASE_ADDR+`NI_STATUS_ADDR)>>2, read_data);
	end
endtask


//////////////////////////////////



task automatic send_pck_cmd (
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1		:	0] src_y_addr,
	input [`NI_PCK_SIZE_WIDTH-1	:	0]	pck_size,
	input [`NI_PTR_WIDTH-1			: 	0]	pck_ptr
	
);
	reg	[CPU_ADR_WIDTH-1			:	0] addr_i;
	reg 	[31							:	0]	data_i;
	begin : send_pck_cmd1
		addr_i	=		(NI_BASE_ADDR+ `NI_WR_PCK_ADDR)>>2;
		data_i	=		{pck_size,pck_ptr};
		cpu_write_data	( src_x_addr, src_y_addr, addr_i,data_i);
	end
endtask

////////////////////////////////////

task automatic write_hdr (
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_y_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_y_addr,
	input [`NI_PTR_WIDTH-1		:	0]	pck_ptr


);
	
	reg	[CPU_ADR_WIDTH-1		:	0] addr_i;
	reg 	[31						:	0]	data_i;
	
	begin : hdr1
		addr_i = pck_ptr>>2;
		data_i = {{PORT_NUM_BCD_WIDTH{1'b0}},des_x_addr,des_y_addr,{(32-PORT_NUM_BCD_WIDTH-`X_Y_ADDR_WIDTH_IN_HDR-`X_Y_ADDR_WIDTH_IN_HDR){1'b0}}};	
		cpu_write_data	( src_x_addr, src_y_addr, addr_i,data_i);
		
	end
endtask

///////////////////////////////////

task automatic recive_pck(
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_y_addr,
	input [12						:	0]	pck_size,
	input [18						:	0]	pck_ptr

);
 	reg	[CPU_ADR_WIDTH-1		:	0] addr_i;
	reg 	[31						:	0]	data_i;
	reg  [31      : 0] read_data;


	begin: rcv_pck1
	  read_data = 0;
		while (	!read_data[`NI_HAS_PCK_LOC] )  cpu_read_data	(src_x_addr, src_y_addr, (NI_BASE_ADDR+`NI_STATUS_ADDR)>>2, read_data);
		
		#20	
		addr_i = (NI_BASE_ADDR + `NI_RD_PCK_ADDR)>>2;
		data_i = {pck_size,pck_ptr}; 
		cpu_write_data	(src_x_addr, src_y_addr,  addr_i, data_i);
			
	  read_data = 0;
		while (!	read_data[`NI_RD_DONE_LOC] )  cpu_read_data	(src_x_addr, src_y_addr, (NI_BASE_ADDR+`NI_STATUS_ADDR)>>2, read_data);
		$display ("%d,\t a pck has been stored on core (%d,%d)", $time,src_x_addr,src_y_addr );
		
	end
	
endtask	
	
///////////////////////////////////////

/*
	
task automatic write_prog_hdr (
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_y_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_y_addr

);
	begin : hdr2
	ni_s_addr_i	[`CORE_NUM(src_x_addr,src_y_addr)]	= SLAVE_WR_PCK_ADDR; 
	ram_data[`CORE_NUM(src_x_addr,src_y_addr)]= {{PORT_NUM_BCD_WIDTH{1'b0}},des_x_addr,des_y_addr,{(32-PORT_NUM_BCD_WIDTH-`X_Y_ADDR_WIDTH_IN_HDR-`X_Y_ADDR_WIDTH_IN_HDR-1){1'b0}}, 1'b1	};	
	ram_addr[`CORE_NUM(src_x_addr,src_y_addr)]=	0;
	@ (posedge clk) # 1 ram_we[`CORE_NUM(src_x_addr,src_y_addr)] = 1'b1;
	@ (posedge clk) # 1 ram_we[`CORE_NUM(src_x_addr,src_y_addr)] = 1'b0;
		
	end
endtask


///////////////////////////////////////////////

task automatic send_prog_pck(
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] src_y_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_y_addr,
	input [12						:	0]	pck_size,
	input [18						:	0]	pck_ptr


);
	begin: send_pck1
		write_prog_hdr ( src_x_addr,src_y_addr,des_x_addr,des_y_addr);
		#20
		send_pck_cmd (src_x_addr, src_y_addr,	pck_size,pck_ptr);
		wait(	ni_s_dat_o[`CORE_NUM(src_x_addr,src_y_addr)][`NI_WR_DONE_LOC] ) ;
	end
endtask


////////////////////////////////////////////////

task automatic update_cmd_mem (
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_x_addr,
	input [`X_Y_ADDR_WIDTH_IN_HDR-1	:	0] des_y_addr,
	input [31						:	0] jtag_mem_start_addr,
	input [31						:	0] pckt_size,
	input [31						:	0] sdram_start_addr
	);
	begin : update
		@(posedge clk) # 1 cmd_we			=  1'b1;
		cmd_addr = 1;
		cmd_data ={{(32-`X_Y_ADDR_WIDTH_IN_HDR-`X_Y_ADDR_WIDTH_IN_HDR){1'b0}},des_x_addr,des_y_addr}; 
		
		@(posedge clk) # 1 cmd_we			=  1'b1;
		cmd_addr = 2;
		cmd_data = jtag_mem_start_addr;
		
		@(posedge clk) # 1 cmd_we			=  1'b1;
		cmd_addr = 3;
		cmd_data = pckt_size; // transfer size 
	
		@(posedge clk) # 1 cmd_we			=  1'b1;
		cmd_addr= 4;
		cmd_data = sdram_start_addr; //sdram addr
	
		
		@(posedge clk) # 1 cmd_we			=	1'b0;				
		cmd_addr = 0;
	end
endtask

//////////////////////////////////////////////////

task automatic send_cmd (
	input [31			:	0] command
	);
	begin : send_cmdd
		cmd_data		=	command;			
		@(posedge clk) # 1 cmd_we					=  1'b1;
		@(posedge clk) # 1 cmd_we					=	1'b0;			
		wait (cmd_q_b[`JTAG_DONE_LOC] ) ;	
	end
endtask	


/////////////////////////////////////////////////


task automatic write_read_req (
	input [31						:	0] jtag_mem_start_addr,
	input [31						:	0] pckt_size,
	input [31						:	0] sdram_start_addr
	);
	begin : update2
		@(posedge clk) # 1 code_we			=  1'b1;
		code_addr = jtag_mem_start_addr;
		code_data  = sdram_start_addr;
		
		@(posedge clk) # 1 code_we			=  1'b1;
		code_addr = jtag_mem_start_addr+1;
		code_data = pckt_size;
				
		@(posedge clk) # 1 code_we			=	1'b0;				
		code_addr = 0;
		
		//update_cmd_mem (des_x_addr,des_y_addr,jtag_mem_start_addr, pckt_size,sdram_start_addr)
	   update_cmd_mem ( SDRAM_SW_X_ADDR,SDRAM_SW_Y_ADDR,jtag_mem_start_addr,2,0);
		
		
	end
endtask
*/

// synthesis translate_on
	

