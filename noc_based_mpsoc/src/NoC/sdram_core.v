`include "../define.v"
module sdram_core #(
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
	parameter SDRAM_ADDR_WIDTH		=	25,
	parameter CAND_VC_SEL_MODE		=	0,
	parameter CONGESTION_WIDTH		=	8,
	parameter VC_ID_WIDTH			=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH				=	PYLD_WIDTH+FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter CORE_NUMBER			=	`CORE_NUM(SW_X_ADDR,SW_Y_ADDR)
	)
	(
		input					 							clk,                
		input  				 							reset,   
				
		// NOC interfaces
		output	[FLIT_WIDTH-1				:0] 	flit_out,     
		output 			  			   				flit_out_wr,   
		input 	[VC_NUM_PER_PORT-1		:0]	credit_in,
		input 	[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
		
		input		[FLIT_WIDTH-1				:0] 	flit_in,     
		input 	    			   					flit_in_wr,   
		output 	[VC_NUM_PER_PORT-1		:0]	credit_out,
		
		
		output  [12:0] sdram_addr,        // sdram_wire.addr
		output  [1:0]  sdram_ba,          //           .ba
		output         sdram_cas_n,       //           .cas_n
		output         sdram_cke,         //           .cke
		output         sdram_cs_n,        //           .cs_n
		inout   [31:0] sdram_dq,          //           .dq
		output  [3:0]  sdram_dqm,         //           .dqm
		output         sdram_ras_n,       //           .ras_n
		output         sdram_we_n,        //           .we_n
		output         sdram_clk		    //  sdram_clk.clk
	);

	
	
	

// sdram controller interface
		wire [SDRAM_ADDR_WIDTH-1		:	0] 	sdram_s1_address;       
		wire [3								:	0]		sdram_s1_byteenable_n;  
		wire												sdram_s1_chipselect;
		wire [31								:	0]		sdram_s1_writedata;
		wire  											sdram_s1_read_n;
		wire												sdram_s1_write_n;
		wire	[31							:	0]		sdram_s1_readdata;
		wire												sdram_s1_readdatavalid;
		wire	 											sdram_s1_waitrequest;

sdram sdram_inst
(
	.clk_clk							(clk) ,	// reg  clk_clk
	.reset_reset_n					(~reset) ,	// reg  reset_reset_n
	.sdram_s1_address				(sdram_s1_address) ,	// reg [24:0] sdram_s1_address
	.sdram_s1_byteenable_n		(sdram_s1_byteenable_n) ,	// reg [3:0] sdram_s1_byteenable_n
	.sdram_s1_chipselect			(sdram_s1_chipselect) ,	// reg  sdram_s1_chipselect
	.sdram_s1_writedata			(sdram_s1_writedata) ,	// reg [31:0] sdram_s1_writedata
	.sdram_s1_read_n				(sdram_s1_read_n) ,	// reg  sdram_s1_read_n
	.sdram_s1_write_n				(sdram_s1_write_n) ,	// reg  sdram_s1_write_n
	.sdram_s1_readdata			(sdram_s1_readdata) ,	//  [31:0] sdram_s1_readdata
	.sdram_s1_readdatavalid		(sdram_s1_readdatavalid) ,	//   sdram_s1_readdatavalid
	.sdram_s1_waitrequest		(sdram_s1_waitrequest) ,	//   sdram_s1_waitrequest
	.sdram_wire_addr				(sdram_addr) ,	//  [12:0] sdram__addr
	.sdram_wire_ba					(sdram_ba) ,	//  [1:0] sdram__ba
	.sdram_wire_cas_n				(sdram_cas_n) ,	//   sdram__cas_n
	.sdram_wire_cke				(sdram_cke) ,	//   sdram__cke
	.sdram_wire_cs_n				(sdram_cs_n) ,	//   sdram__cs_n
	.sdram_wire_dq					(sdram_dq) ,	// inout [31:0] sdram__dq
	.sdram_wire_dqm				(sdram_dqm) ,	//  [3:0] sdram__dqm
	.sdram_wire_ras_n				(sdram_ras_n) ,	//   sdram__ras_n
	.sdram_wire_we_n				(sdram_we_n) ,	//   sdram__we_n
	.sdram_clk_clk					(sdram_clk) 	//   sdram_clk_clk
);



ext_ram_nic #(
	.TOPOLOGY				(TOPOLOGY),
	.ROUTE_ALGRMT			(ROUTE_ALGRMT),
	.VC_NUM_PER_PORT 		(VC_NUM_PER_PORT ),
	.PYLD_WIDTH 			(PYLD_WIDTH),
	.BUFFER_NUM_PER_VC	(BUFFER_NUM_PER_VC),
	.FLIT_TYPE_WIDTH		(FLIT_TYPE_WIDTH),
	.PORT_NUM				(PORT_NUM),
	.X_NODE_NUM				(X_NODE_NUM	),
	.Y_NODE_NUM				(Y_NODE_NUM	),
	.SW_X_ADDR				(SW_X_ADDR),
	.SW_Y_ADDR				(SW_Y_ADDR),
	.NIC_CONNECT_PORT		(NIC_CONNECT_PORT	), // 0:Local  1:East, 2:North, 3:West, 4:South 
	.RAM_ADDR_WIDTH		(SDRAM_ADDR_WIDTH),
	.CAND_VC_SEL_MODE		(CAND_VC_SEL_MODE)
	
	)
	the_sdram_nic
	(
		.clk							(clk),                
		.reset						(reset),   
				
		// NOC interfaces
		.flit_out					(flit_out),     
		.flit_out_wr				(flit_out_wr),   
		.credit_in					(credit_in),
		.congestion_cmp_i			(congestion_cmp_i),
		.flit_in						(flit_in),     
		.flit_in_wr					(flit_in_wr),   
		.credit_out					(credit_out),
		
		// sdram controller interface
		.ram_address				(sdram_s1_address),       
		.ram_byteenable_n			(sdram_s1_byteenable_n),  
		.ram_chipselect			(sdram_s1_chipselect),
		.ram_writedata				(sdram_s1_writedata),
		.ram_read_n					(sdram_s1_read_n),
		.ram_write_n				(sdram_s1_write_n),
		.ram_readdata				(sdram_s1_readdata),
		.ram_readdatavalid		(sdram_s1_readdatavalid),
		.ram_waitrequest			(sdram_s1_waitrequest)
		
	);


endmodule
