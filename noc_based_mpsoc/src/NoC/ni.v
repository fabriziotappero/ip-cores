/**********************************************************************
	File: ni.v 
	
	Copyright (C) 2013  Alireza Monemi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	
	Purpose:
	A DMA based NI for connecting the NoC router to a processor. The NI has 3 
	memory mapped registers:
		1- Read packet register: contain the pointer and maximum size of the pointer 
										 which has been dedicated by cpu to store the received 
										 packet 
		2- write packet register: contain the pointer and maximum size of the pointer 
										  of the packet which must be sent. The destination address 
										 must be updated by cpu in the first word of the packet 
		3-status register: provide information about the current status of the router 
	
		status_reg		 =	{ni_isr,all_vcs_full,any_vc_has_data,rd_no_pck_err,rd_ovr_size_err,rd_done,wr_done};
		RD/WR registers ={pck_size_next,memory_ptr_next}
	
	Info: monemi@fkegraduate.utm.my
	*************************************************************************/

`include "../define.v"
`timescale 1ns/1ps



module ni #(
	parameter TOPOLOGY				=	"TORUS", // "MESH" or "TORUS"  
	parameter ROUTE_ALGRMT			=	"XY",		//"XY" or "MINIMAL"
	parameter VC_NUM_PER_PORT 		=	2,
	parameter PYLD_WIDTH 			=	32,
	parameter BUFFER_NUM_PER_VC	=	16,
	parameter FLIT_TYPE_WIDTH		=	2,
	parameter PORT_NUM				=	5,
	parameter X_NODE_NUM				=	4,
	parameter Y_NODE_NUM				=	3,
	parameter SW_X_ADDR				=	2,
	parameter SW_Y_ADDR				=	1,
	parameter NIC_CONNECT_PORT		=	0, // 0:Local  1:East, 2:North, 3:West, 4:South 
	parameter FIFO_FULL_SIG_WIDTH	=	VC_NUM_PER_PORT*2,
	parameter VC_ID_WIDTH			=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH				=	PYLD_WIDTH+FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter CAND_VC_SEL_MODE		=	0,	// 0: use arbieration between not full vcs, 1: select the vc with moast availble free space
	parameter CONGESTION_WIDTH		=	8,
	
	//wishbone port parameters
	parameter RAM_WIDTH_IN_WORD		=	13,
	parameter W_DATA_WIDTH				=	32,
	parameter WS_ADDR_WIDTH				=	3,
	parameter WM_ADDR_WIDTH				=	RAM_WIDTH_IN_WORD,
	parameter W_CTI_WIDTH				=	3,
	parameter SEL_WIDTH					=	4
	
	
	)
	(
	
	input 												reset,
	input													clk,
	
	
	// NOC interfaces
	output	[FLIT_WIDTH-1					:0] 	flit_out,     
	output 	reg    			   					flit_out_wr,   
	input 	[VC_NUM_PER_PORT-1			:0]	credit_in,
	
	input		[FLIT_WIDTH-1					:0] 	flit_in,   
	input 	    			   						flit_in_wr,   
	output reg	[VC_NUM_PER_PORT-1		:0]	credit_out,		
	input 	[CONGESTION_WIDTH-1			:0]	congestion_cmp_i,

	//wishbone slave interface signals
	input		[W_DATA_WIDTH-1			:	0]		s_dat_i,
	input		[WS_ADDR_WIDTH-1			:	0] 	s_addr_i,
	input													s_stb_i,
	input													s_we_i,

	output	[W_DATA_WIDTH-1			:	0]		s_dat_o,
	output	reg										s_ack_o,

	
	
	//wishbone master interface signals
	output	[SEL_WIDTH-1					:	0]	m_sel_o,
	output	[W_DATA_WIDTH-1				:	0]	m_dat_o,
	output	[WM_ADDR_WIDTH-1				:	0] m_addr_o,
	output	[W_CTI_WIDTH-1					:	0]	m_cti_o,
	output												m_stb_o,
	output												m_cyc_o,
	output												m_we_o,

	input		[W_DATA_WIDTH-1				:	0]	m_dat_i,
	input													m_ack_i,	
	
	//intruupt interface
	output 									  			irq
	
	
); 
 
`LOG2

	localparam	COUNTER_WIDTH		=	 WM_ADDR_WIDTH-1;
	localparam	PTR_WIDTH			=	`NI_PTR_WIDTH-2;
	localparam	PCK_SIZE_WIDTH		=	`NI_PCK_SIZE_WIDTH;
	localparam	HDR_FLIT				=	2'b10;
	localparam	BDY_FLIT				=	2'b00;
	localparam	TAIL_FLIT			=	2'b01;
	localparam	SLAVE_RD_PCK_ADDR	=	0;
	localparam	SLAVE_WR_PCK_ADDR	=	1;
	localparam	SLAVE_STATUS_ADDR	=	2;
	
	localparam	NUMBER_OF_STATUS	=	7;
	localparam  IDEAL					=	1;
	localparam	READ_MEM_PCK_HDR	=	2;
	localparam 	ASSIGN_PORT_VC		=	4;
	localparam  SEND_HDR				=	8;
	localparam	WR_ON_FIFO			=	16;
	localparam	WR_ON_RAM			=	32;
	localparam	PROG_WR				=	64;
	localparam  PORT_NUM_BCD_WIDTH	=	log2(PORT_NUM);
	
	
	
	localparam X_NODE_NUM_WIDTH	=	log2(X_NODE_NUM);
	localparam Y_NODE_NUM_WIDTH	=	log2(Y_NODE_NUM);
	
	
	
	
	
	
	
	//avalon slave interface signals
	wire									s_chipselect, s_write,s_read, s_waitrequest;
	wire	[WS_ADDR_WIDTH-1	:0]	s_address;
	wire  [W_DATA_WIDTH-1	:0] 	s_writedata, s_readdata;
	
	
	//avalon master interface
	wire									m_chipselect, m_write,	m_read;
	wire unsigned m_waitrequest;
	wire unsigned [WM_ADDR_WIDTH-1	:0]	m_address;
	wire	[W_DATA_WIDTH-1	:0] 	m_writedata, 	m_readdata;
	
	wire 									s_ack_o_next;
	reg									last_rw;
	reg									m_ack_i_delayed;								
	//avalon to wishbone 
	assign	s_writedata		=	s_dat_i;
	assign	s_address		=	s_addr_i;
	assign	s_chipselect	=	s_stb_i;
	assign	s_write			=	s_we_i;
	//assign	s_read			=	~s_we_i;
	assign	s_dat_o			=	s_readdata;

	assign	m_sel_o			=	4'b1111;
	assign 	m_dat_o			=	m_writedata;
	assign	m_addr_o			=	m_address;
	assign	m_stb_o			=	m_chipselect;
	assign	m_cyc_o			=	m_write | m_read;
	assign	m_we_o			=	m_write;
	assign	m_readdata		=	m_dat_i;
	
	assign  	m_waitrequest	=	~		m_ack_i_delayed	; //in busrt mode  the ack is regisered inside the ni insted of ram to avoid combinational loop
	
	assign 	s_ack_o_next	=	s_chipselect & (~s_ack_o);
	assign	m_cti_o			=	(m_stb_o)	?	((last_rw)? 3'b111 :	3'b010) : 3'b000;
	
	reg 										ni_isr,ni_isr_next;
	
		
	reg [NUMBER_OF_STATUS-1	:	0]		ps,ns;
	reg [COUNTER_WIDTH-1		:	0]		counter,counter_next;
	reg 										counter_reset;
	reg 										counter_increase;
	
	// memory mapped registers
	wire [31						:	0]		status_reg;
	wire[31						:	0]		m_pyld;
	
	reg [PTR_WIDTH-1			:	0]		memory_ptr,memory_ptr_next;
	reg [PCK_SIZE_WIDTH-1	:	0]		pck_size,pck_size_next;
	wire										pck_eq_counter;

	reg 										wr_done_next, wr_done;
	reg										rd_done_next, rd_done;
	reg										rd_no_pck_err_next,	rd_no_pck_err;
	reg										rd_ovr_size_err_next, rd_ovr_size_err;
	reg										wr_mem_en_next,wr_mem_en;
	reg										rd_mem_en;
	
	
	
	reg										cand_wr_vc_en;
	wire										cand_wr_vc_full;
	reg [VC_NUM_PER_PORT-1	:	0]		cand_rd_vc,cand_rd_vc_next;
	wire 										no_rd_vc_is_cand;
	reg										cand_rd_vc_en,cand_rd_vc_rst;
	wire										cand_rd_vc_not_empty;
	reg										any_vc_has_data;
	
		
	
	wire [VC_NUM_PER_PORT-1	:	0]		rd_vc_arbiter_in ,rd_vc_arbiter_out; 
	reg       	   						ififo_rd_en; 
	
	
	
	wire										all_vcs_full;
	reg [FLIT_TYPE_WIDTH-1	:	0]		wr_flit_type;
	
	
	
	
	wire 	[FLIT_WIDTH-1			:0]	ififo_dout;   
	wire	[VC_NUM_PER_PORT-1	:0]	ififo_vc_not_empty;
	wire 										flit_in_hdr_flg;//if set flit is header
	wire										ififo_hdr_flg;
	wire 										ififo_tail_flg;//if set flit is tail
	wire 	[VC_NUM_PER_PORT-1	:0]	flit_in_vc_num;
	
	wire [X_NODE_NUM_WIDTH-1: 0]		dest_x_addr;
	wire [Y_NODE_NUM_WIDTH-1: 0]		dest_y_addr;
	wire [PORT_NUM_BCD_WIDTH-1	: 0]	port_num;
	reg  [PORT_NUM_BCD_WIDTH-1	: 0]	port_num_reg,port_num_reg_next;
	reg										port_num_en;
	//reg										flit_out_wr_next;
	reg										prog_mode_en,prog_mode_en_delay;
	wire										prog_mode_en_next;
	
	reg										hdr_write;
	reg										read_burst;
	
	
	wire 	[VC_NUM_PER_PORT-1	:0]	full_vc;
	wire 	[VC_NUM_PER_PORT-1	:0]	cand_wr_vc;
	
	assign	irq							= ni_isr;
	
	assign	all_vcs_full  				=	& full_vc;
	assign	cand_wr_vc_full			=	| ( full_vc & cand_wr_vc);
			
	
	assign 	no_rd_vc_is_cand			=	~(| cand_rd_vc);
	assign 	rd_vc_arbiter_in			=	(cand_rd_vc_en)?  ififo_vc_not_empty : {VC_NUM_PER_PORT{1'b0}} ;
   assign 	cand_rd_vc_not_empty		=	|(ififo_vc_not_empty & cand_rd_vc) ;
	
	
	
	assign 	m_chipselect				=	wr_mem_en | rd_mem_en;
	assign 	m_write						=	wr_mem_en;
	assign	m_read						=	rd_mem_en;
	
	assign	m_writedata					=	{ififo_dout[31:0]};
	
	assign	flit_out						=	{wr_flit_type,cand_wr_vc,m_pyld};
	
	//assign 	s_waitrequest				=	s_write & (ps!= IDEAL ) & (s_address==SLAVE_RD_PCK_ADDR | s_address==SLAVE_WR_PCK_ADDR );	
	assign	dest_x_addr					=	m_readdata[`DES_X_ADDR_LOC ];
	assign	dest_y_addr					=	m_readdata[`DES_Y_ADDR_LOC ];
	assign	m_pyld						=	(hdr_write)? {port_num_reg,m_readdata[`FLIT_IN_DES_LOC],SW_X_ADDR[`X_Y_ADDR_WIDTH_IN_HDR-1:0],
	SW_Y_ADDR[`X_Y_ADDR_WIDTH_IN_HDR-1:0],m_readdata[32-PORT_NUM_BCD_WIDTH-(4*`X_Y_ADDR_WIDTH_IN_HDR)-1:	0]}	:	m_readdata;
	
	
	assign flit_in_hdr_flg				=	flit_in	 	[`FLIT_HDR_FLG_LOC	];
//	assign prog_hdr_seq 					=  flit_in 		[`PROG_SEQ_LOC			];
	assign ififo_tail_flg				=	ififo_dout	[`FLIT_TAIL_FLAG_LOC	];
	assign ififo_hdr_flg					=	ififo_dout	[`FLIT_HDR_FLG_LOC	];
	assign flit_in_vc_num				=  flit_in	 	[`FLIT_IN_VC_LOC		];
	
	
	//status register
	assign	status_reg					=	{ni_isr,all_vcs_full,any_vc_has_data,rd_no_pck_err,rd_ovr_size_err,rd_done,wr_done};
	assign 	s_readdata					=   status_reg;
	assign	prog_mode_en_next 		= 	flit_in_hdr_flg & (flit_in [`FLIT_IN_WR_RAM_LOC]== 1'b1);
	
	generate 
		if(WM_ADDR_WIDTH		>	 PTR_WIDTH) 		assign	m_address					=	memory_ptr+counter+(~m_waitrequest & read_burst);
		else 												   assign	m_address					=	memory_ptr[WM_ADDR_WIDTH-1	:0 ] + counter + (~m_waitrequest & read_burst);
	
		if(COUNTER_WIDTH	> 	PCK_SIZE_WIDTH )  assign 	pck_eq_counter				= ( counter[PCK_SIZE_WIDTH-1:	0] == pck_size);
		else 												assign 	pck_eq_counter				= ( counter == (pck_size[COUNTER_WIDTH-1	:0]));
		
	endgenerate																					
	
		
						
	
	//status
	
	
	
	// avalon slave addr 
	
	
	
	
	
	always@(posedge clk or posedge reset)begin
		if(reset)begin
			ps						<=	IDEAL;
			memory_ptr			<=	{PTR_WIDTH{1'b0}};
			pck_size				<=	{PCK_SIZE_WIDTH{1'b0}};
			counter				<=	{COUNTER_WIDTH{1'b0}};
			cand_rd_vc			<=	{VC_NUM_PER_PORT{1'b0}};
			port_num_reg		<= {PORT_NUM_BCD_WIDTH{1'b0}};
			wr_done				<=	1'b0;
			rd_done				<=	1'b0;
			rd_no_pck_err		<=	1'b0;
			rd_ovr_size_err	<= 1'b0;
		//	wr_mem_en			<= 1'b0;
		//	port_num_en_del	<=	1'b0;
		//	flit_out_wr			<= 1'b0;
			any_vc_has_data	<= 1'b0;
			prog_mode_en		<= 1'b0;
			prog_mode_en_delay<= 1'b0;
			//hdr_write			<= 1'b0;
			m_ack_i_delayed	<=	1'b0;
			s_ack_o				<= 1'b0;
			ni_isr				<= 1'b0;
			
		end else begin //if reset
			ps						<=	ns;
			memory_ptr			<=	memory_ptr_next;
			pck_size				<=	pck_size_next;
			counter				<=	counter_next;
			cand_rd_vc			<=	cand_rd_vc_next;
			port_num_reg		<= port_num_reg_next;
			wr_done				<=	wr_done_next;
			rd_done				<=	rd_done_next;
			rd_no_pck_err		<=	rd_no_pck_err_next;
			rd_ovr_size_err	<= rd_ovr_size_err_next;
		//	wr_mem_en			<= wr_mem_en_next;
		//	port_num_en_del	<= port_num_en;
		//	flit_out_wr			<= flit_out_wr_next;
			any_vc_has_data	<= | ififo_vc_not_empty;
			prog_mode_en		<= prog_mode_en_next;
			prog_mode_en_delay<= prog_mode_en;
			//hdr_write			<= hdr_write_next;
			m_ack_i_delayed	<=	m_ack_i;
			s_ack_o				<= s_ack_o_next;
			ni_isr				<= ni_isr_next;			
		end//els reset
	end//always
	
	
	always@(*)begin
	counter_next 		= counter;	
	cand_rd_vc_next	= cand_rd_vc;
	port_num_reg_next	= port_num_reg;
	
	
		if			(counter_reset)				counter_next	=	{COUNTER_WIDTH{1'b0}};
		else if	(counter_increase) 			counter_next	=  counter +1'b1;
				
		//if(cand_wr_vc_en) cand_wr_vc_next = flit_out_vc_full[FIFO_FULL_SIG_WIDTH-1	:	VC_NUM_PER_PORT];
		
		if	(cand_rd_vc_rst) 			cand_rd_vc_next =	{VC_NUM_PER_PORT{1'b0}};
		else if(cand_rd_vc_en)		cand_rd_vc_next =	rd_vc_arbiter_out;
		
		if(port_num_en)	port_num_reg_next	= port_num;
		
	
		
	end//always
	
	
	
	always@(*) begin
		ns							= ps;
		counter_reset 			= 1'b0;
	   counter_increase 		= 1'b0;
		cand_rd_vc_rst			= 1'b0;
		cand_rd_vc_en			= 1'b0;
		cand_rd_vc_rst			= 1'b0;
		ififo_rd_en				= 1'b0;  
		wr_mem_en				= 1'b0;
		credit_out				= {VC_NUM_PER_PORT{1'b0}};
		rd_mem_en				= 1'b0;
	//	flit_out_wr_next		= 1'b0;
		flit_out_wr				= 1'b0;
		cand_wr_vc_en			= 1'b0;
		port_num_en				= 1'b0;
		wr_done_next			= wr_done;
		rd_done_next			= rd_done;
		rd_no_pck_err_next	= rd_no_pck_err;
		rd_ovr_size_err_next	= rd_ovr_size_err;
		memory_ptr_next		= memory_ptr;
		pck_size_next			= pck_size;
		wr_flit_type			= BDY_FLIT;	
		hdr_write				= 1'b0;
		last_rw					= 1'b0;
		read_burst				= 1'b0;
		case(ps)
			
			IDEAL	:	begin 
				counter_reset =1;
				cand_rd_vc_en	=	(no_rd_vc_is_cand)? 1'b1	:	1'b0;
				if	(prog_mode_en_delay)	begin
					ns						=	PROG_WR;
					memory_ptr_next	=	{PTR_WIDTH{1'b0}};
					ififo_rd_en			= 	1'b1;
					credit_out			=	cand_rd_vc;
				end
			   if(s_chipselect & 	s_write )	begin 
					{pck_size_next,memory_ptr_next}	= s_writedata[31:2];
					case (s_address) 
						SLAVE_RD_PCK_ADDR:	begin	
														rd_done_next		= 1'b0;
														rd_ovr_size_err_next=1'b0;
														if(any_vc_has_data)	begin 
																//synthesis translate_off
																$display ("%d,\t   core (%d,%d) has recived a packet",$time,SW_X_ADDR,SW_Y_ADDR,);
																//synthesis translate_on
																
																ns=	WR_ON_RAM;
																rd_no_pck_err_next= 1'b0;
																ififo_rd_en			= 1'b1; 
																credit_out			=	cand_rd_vc;
																//wr_mem_en_next		= 1'b1;
																
														end else	begin
																ns=	IDEAL;
																rd_no_pck_err_next= 1'b1;
														end
													end   //SLAVE_RD_PCK_ADDR:
						SLAVE_WR_PCK_ADDR:	begin 			
														ns					= READ_MEM_PCK_HDR;
														wr_done_next	=1'b0;
														
													end	//SLAVE_WR_PCK_ADDR
						default:						ns=	IDEAL;
					endcase
				end
			end
			
			READ_MEM_PCK_HDR:	begin
				if(~all_vcs_full)	begin
						ns						=	ASSIGN_PORT_VC;
						rd_mem_en			= 	1'b1;
						
				end 
				
			end //READ_MEM_PCK_HDR:
			ASSIGN_PORT_VC	: begin
				if(~m_waitrequest) begin 
						ns						=	SEND_HDR;
						rd_mem_en			= 	1'b1;
						counter_increase	=	1'b1;
						cand_wr_vc_en		=	1'b1;
						port_num_en			=	1'b1;
				end else rd_mem_en		=  1'b1;
			end
			SEND_HDR: begin 
						ns						=	WR_ON_FIFO;
						wr_flit_type		= 	HDR_FLIT;
						hdr_write			=	1'b1;
						flit_out_wr			=	1'b1;
			end 			
			WR_ON_FIFO:	begin 
					read_burst			=	1'b1;
					if(!m_waitrequest) begin 
						if(pck_eq_counter) begin
							flit_out_wr		=	1'b1;
							ns					=	IDEAL;
							wr_done_next	=	1'b1;
							wr_flit_type	= TAIL_FLIT;	
							last_rw			=	1'b1;
						end else if(!cand_wr_vc_full) begin 
							flit_out_wr			=1'b1;
							counter_increase	= 1'b1;
							rd_mem_en			= 1'b1;
						end 
					end else if(!cand_wr_vc_full)   rd_mem_en			= 1'b1; 
				//end
			end//WR_ON_FIFO
			
			
			WR_ON_RAM:	begin
				rd_no_pck_err_next= 1'b0;
				if(ififo_tail_flg) begin
					if(~m_waitrequest) begin 
							ns							=	IDEAL;
							last_rw					=	1'b1;
							rd_done_next			=	1'b1;
							cand_rd_vc_rst			=	1'b1;
							wr_mem_en				=	1'b1;
					end else  wr_mem_en			=	1'b1;
				end //ififo_tail_flg
				else if(~m_waitrequest) begin 
						if(cand_rd_vc_not_empty ) begin
							ififo_rd_en				= 1'b1; 
							credit_out				=	cand_rd_vc;
							counter_increase		= 1'b1;
							if( pck_eq_counter )	rd_ovr_size_err_next	=	1'b1;
							else 						wr_mem_en	=	1'b1;
						end// cand_rd_vc_not_empty
				end //m_waitrequest
				else	if(cand_rd_vc_not_empty ) wr_mem_en	=	1'b1;
			end //WR_ON_RAM
			
			PROG_WR	:	begin
				if(ififo_tail_flg) begin
					if(~m_waitrequest) begin 
							ns							=	IDEAL;
							last_rw					=	1'b1;
							rd_done_next			=	1'b1;
							cand_rd_vc_rst			=	1'b1;
							wr_mem_en				=	1'b1;
					end else  wr_mem_en			=	1'b1;
				end //ififo_tail_flg
				else if(~m_waitrequest) begin 
					if(cand_rd_vc_not_empty ) begin
							ififo_rd_en				= 1'b1; 
							credit_out				= cand_rd_vc;
							if(! ififo_hdr_flg)  counter_increase		= 1'b1;
							wr_mem_en				= 1'b1;
					end// if(cand_prog_vc_not_empty )
				end else 	if(cand_rd_vc_not_empty ) wr_mem_en	=	1'b1;
			end//PROG_WR		
			
			default : ns=IDEAL;
		
		endcase
	end
	
	
	//isr_register handeling
	always @(*) begin
		ni_isr_next	= ni_isr;
		if(any_vc_has_data) ni_isr_next = 1'b1;
		if(s_chipselect & 	s_write & (s_address == SLAVE_STATUS_ADDR) & s_writedata[`NI_ISR_LOC]) ni_isr_next = 1'b0;
	end


	
	
 fifo_buffer #(
	.VC_NUM_PER_PORT			(VC_NUM_PER_PORT),
	.FLIT_WIDTH					(FLIT_WIDTH ),
	.BUFFER_NUM_PER_VC		(BUFFER_NUM_PER_VC),
	.ENABLE_MIN_DEPTH_OUT	(0) // if 1 then the VC with minimum depth is merged with vc_nearly_full as output
	
	
	)	
	the_ififo
	(
	.din						(flit_in),     // Data in
	.vc_num_wr				(flit_in_vc_num),//write vertual channel 	
	.wr_en					(flit_in_wr),   // Write enable
	.vc_num_rd				(cand_rd_vc),//read vertual channel 	
	.rd_en					(ififo_rd_en),   // Read the next word
	.dout						(ififo_dout),    // Data out
	.vc_nearly_full		(),
	.vc_not_empty			(ififo_vc_not_empty),
	
		
	.reset					(reset),
	.clk						(clk)
	);

	
	
	arbiter #(
		.ARBITER_WIDTH (VC_NUM_PER_PORT),
		.CHOISE			(1)  // 0 blind round-robin and 1 true round robin
)
rd_vc_arbiter
(	
	.clk			(clk), 
   .reset 		(reset), 
   .request	 	(rd_vc_arbiter_in), 
   .grant		(rd_vc_arbiter_out), 
   .anyGrant	()
);



 route_compute  #(
	.TOPOLOGY					(TOPOLOGY),
	.ROUTE_ALGRMT				(ROUTE_ALGRMT),
	.PORT_NUM					(PORT_NUM),
	.X_NODE_NUM					(X_NODE_NUM),
	.Y_NODE_NUM					(Y_NODE_NUM),
	.SW_X_ADDR					(SW_X_ADDR),
	.SW_Y_ADDR					(SW_Y_ADDR)
	)
	the_normal_routting
	(
	.congestion_cmp_i			(congestion_cmp_i),
	.dest_x_node_in			(dest_x_addr),
	.dest_y_node_in			(dest_y_addr),
	.in_port_num_i				({PORT_NUM_BCD_WIDTH{1'b0}}), //conventional routing
	.port_num_out				(port_num)
	);
	
	wire [VC_NUM_PER_PORT-1			:0]		ovc_wr_in;
	assign ovc_wr_in	= (flit_out_wr ) ?  cand_wr_vc : {VC_NUM_PER_PORT{1'b0}};
	
	output_vc_status #(
		.VC_NUM_PER_PORT		(VC_NUM_PER_PORT),
		.BUFFER_NUM_PER_VC	(BUFFER_NUM_PER_VC),
		.CAND_VC_SEL_MODE		(CAND_VC_SEL_MODE)	// 0: use arbieration between not full vcs, 1: select the vc with moast availble free space
	)
	nic_ovc_status
	(
	.wr_in						(ovc_wr_in),   
	.credit_in					(credit_in),
	.full_vc						(full_vc),
	.cand_vc						(cand_wr_vc),
	.cand_wr_vc_en				(cand_wr_vc_en),
	.clk							(clk),
	.reset						(reset)
	);
	
	

	//synthesis translate_off
always @(*) begin
	if(flit_in_wr && (flit_in[`FLIT_IN_VC_LOC]=={VC_NUM_PER_PORT{1'b0}})) $display ("%d,\t   Error: a packet has been recived by x[%d] , y[%d] with no assigned VC",$time,SW_X_ADDR,SW_Y_ADDR);
end


//synthesis translate_on

endmodule




module output_vc_status #(
	parameter VC_NUM_PER_PORT		= 	4,
	parameter BUFFER_NUM_PER_VC	=	16,
	parameter CAND_VC_SEL_MODE		=	0	// 0: use arbieration between not full vcs, 1: select the vc with most availble free space

)

(
	input		[VC_NUM_PER_PORT-1			:0]	wr_in,   
	input 	[VC_NUM_PER_PORT-1			:0]	credit_in,
	output	[VC_NUM_PER_PORT-1			:0]	full_vc,
	output reg [VC_NUM_PER_PORT-1			:0]	cand_vc,
	input 												cand_wr_vc_en,
	input													clk,
	input													reset
);

`LOG2
	localparam 	BUFF_WIDTH	=	log2(BUFFER_NUM_PER_VC);
	localparam  DEPTH_WIDTH	=	BUFF_WIDTH+1;
	reg 	[DEPTH_WIDTH-1			:	0]	depth 		[VC_NUM_PER_PORT-1	:	0];
	wire  [VC_NUM_PER_PORT-1	: 	0]	cand_vc_next;
	genvar i;
	generate 
		for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin : vc_loop
			always@(posedge clk)begin
					if(reset)begin
						depth[i]<={DEPTH_WIDTH{1'b0}};
					end else begin
						if(  wr_in[i]	&& ~credit_in[i])	depth[i] <= depth[i]+1'b1;
						if( ~wr_in[i]	&&  credit_in[i])	depth[i] <= depth[i]-1'b1;
					end //reset
			end//always
			
			assign 	full_vc[i]		 = (depth[i] >= BUFFER_NUM_PER_VC-1);
			
			
			
		end//for
		if(CAND_VC_SEL_MODE==0) begin : nic_arbiter
			wire  [VC_NUM_PER_PORT-1			:0] request;
			for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin :req_loop
				assign	request[i]		 = ~ full_vc[i]	& cand_wr_vc_en;
			end //for
			
		
			arbiter #(
				.ARBITER_WIDTH		(VC_NUM_PER_PORT)
				)
				the_nic_arbiter
				(
					.clk				(clk), 
					.reset			(reset), 
					.request			(request), 
					.grant			(cand_vc_next),
					.anyGrant		()
				);
			
		end else begin : min_depth_select
		
		wire [(VC_NUM_PER_PORT*DEPTH_WIDTH)-1	:	0]depth_array;
		for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin :depth_loop
			assign depth_array[((i+1)*(DEPTH_WIDTH))-1		: i*DEPTH_WIDTH]=depth[i];
		end //for
	
		fast_minimum_number#(
			.NUM_OF_INPUTS		(VC_NUM_PER_PORT),
			.DATA_WIDTH			(DEPTH_WIDTH)
			
		)
		the_min_depth
		(
			.in_array			(depth_array),
			.min_out				(cand_vc_next)
		);
		
		end //else
		
		always @(posedge clk )begin
			if			(reset)			 cand_vc	<= {VC_NUM_PER_PORT{1'b0}};
			else	if(cand_wr_vc_en)	 cand_vc	<=	cand_vc_next;
		end
		
	endgenerate
endmodule
