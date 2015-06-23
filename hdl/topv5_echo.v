// Top Module

module top
(
   // SGMII Interface - EMAC0
   TXP_0,
   TXN_0,
   RXP_0,
   RXN_0,

   // SGMII MGT Clock buffer inputs 
   MGTCLK_N,
   MGTCLK_P, 

   // reset for ethernet phy
   PHY_RESET_0,

   // GTP link status
   GTP_READY,

   // Asynchronous Reset
   RESET,

	// LED Status
	LEDS,
	
	// DIP Switch
	DIP,
	
	// CPU RESET
	RESET_CPU
);

//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------

   // SGMII Interface - EMAC0
   output          TXP_0;
   output          TXN_0;
   input           RXP_0;
   input           RXN_0;
   
   // SGMII MGT Clock buffer inputs 
   input           MGTCLK_N;
   input           MGTCLK_P;

   // reset for ethernet phy
   output          PHY_RESET_0; 

   // GTP link status
   output          GTP_READY;

   // Asynchronous Reset
   input           RESET;

	// LED Status
	output	[7:0]		LEDS;
	
	// DIP Switches
	input	[7:0]		DIP;
	
	// CPU RESET
	input 				RESET_CPU;
	
//-----------------------------------------------------------------------------


//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                                       User Signals
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

reg [7:0] DIP_r;
wire reset_cpu_p;
wire reset_cpu_i;
reg [7:0] LEDr;

IBUF cpu_reset_ibuf (.I(RESET_CPU), .O(reset_cpu_i));
	
assign reset_cpu_p = ~reset_cpu_i;


//-----------------------------------------------------------------------------
// Ethernet Platform Instance
//-----------------------------------------------------------------------------

wire in_src_rdy_usr;
wire out_dst_rdy_usr;
wire [7:0] in_data_usr;
wire in_sof_usr;
wire in_eof_usr;
wire in_dst_rdy_usr;
wire out_src_rdy_usr;
wire [7:0] out_data_usr;
wire out_sof_usr;
wire out_eof_usr;
wire [3:0] outport_usr;
wire [3:0] inport_usr;
wire clk_local;
wire rst_local;


enetplatform enet_inst
(
   .TXP_0(TXP_0),
   .TXN_0(TXN_0),
   .RXP_0(RXP_0),
   .RXN_0(RXN_0),
   .MGTCLK_N(MGTCLK_N),
   .MGTCLK_P(MGTCLK_P), 
   .PHY_RESET_0(PHY_RESET_0),
   .GTP_READY(GTP_READY),
   .RESET(RESET),
	.RESET_CPU(reset_cpu_p),
	.in_src_rdy_usr(in_src_rdy_usr),
	.out_dst_rdy_usr(out_dst_rdy_usr),
	.in_data_usr(in_data_usr),
	.in_sof_usr(in_sof_usr),
	.in_eof_usr(in_eof_usr),
	.in_dst_rdy_usr(in_dst_rdy_usr),
	.out_src_rdy_usr(out_src_rdy_usr),
	.out_data_usr(out_data_usr),
	.out_sof_usr(out_sof_usr),
	.out_eof_usr(out_eof_usr),
	.outport_usr(outport_usr),
	.inport_usr(inport_usr),
	.clk_local(clk_local),
	.rst_local(rst_local)
);

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------




//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                                       Channel Routing
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

wire ch1_in_sof;
wire ch1_in_eof;
wire ch1_in_src_rdy;
wire ch1_in_dst_rdy;
wire [7:0] ch1_in_data;
wire ch1_out_sof;
wire ch1_out_eof;
wire ch1_out_src_rdy;
wire ch1_out_dst_rdy;
wire [7:0] ch1_out_data;
wire ch1_wen;
wire ch1_ren;

wire ch2_in_sof;
wire ch2_in_eof;
wire ch2_in_src_rdy;
wire ch2_in_dst_rdy;
wire [7:0] ch2_in_data;
wire ch2_out_sof;
wire ch2_out_eof;
wire ch2_out_src_rdy;
wire ch2_out_dst_rdy;
wire [7:0] ch2_out_data;
wire ch2_wen;
wire ch2_ren;

channelif2 channelif_inst
(
	.in_sof(out_sof_usr),
	.in_eof(out_eof_usr),
	.in_src_rdy(out_src_rdy_usr),
	.in_dst_rdy(out_dst_rdy_usr),
	.in_data(out_data_usr),
	.inport_addr(outport_usr),
	.out_sof(in_sof_usr),
	.out_eof(in_eof_usr),
	.out_src_rdy(in_src_rdy_usr),
	.out_dst_rdy(in_dst_rdy_usr),
	.out_data(in_data_usr),
	.outport_addr(inport_usr),
	.wenables(),
	.renables(),
	
	.ch1_in_sof(ch1_in_sof),
	.ch1_in_eof(ch1_in_eof),
	.ch1_in_src_rdy(ch1_in_src_rdy),
	.ch1_in_dst_rdy(ch1_in_dst_rdy),
	.ch1_in_data(ch1_in_data),
	.ch1_out_sof(ch1_out_sof),
	.ch1_out_eof(ch1_out_eof),
	.ch1_out_src_rdy(ch1_out_src_rdy),
	.ch1_out_dst_rdy(ch1_out_dst_rdy),
	.ch1_out_data(ch1_out_data),
	.ch1_wen(ch1_wen),
	.ch1_ren(ch1_ren),
	
	.ch2_in_sof(ch2_in_sof),
	.ch2_in_eof(ch2_in_eof),
	.ch2_in_src_rdy(ch2_in_src_rdy),
	.ch2_in_dst_rdy(ch2_in_dst_rdy),
	.ch2_in_data(ch2_in_data),
	.ch2_out_sof(ch2_out_sof),
	.ch2_out_eof(ch2_out_eof),
	.ch2_out_src_rdy(ch2_out_src_rdy),
	.ch2_out_dst_rdy(ch2_out_dst_rdy),
	.ch2_out_data(ch2_out_data),
	.ch2_wen(ch2_wen),
	.ch2_ren(ch2_ren)
);


//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                                       User Logic
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

wire ch2_out_dst_rdy_l;
reg [19:0] counter;
wire [19:0] new_counter;

always @(posedge clk_local or posedge rst_local)
begin
	if (rst_local)
	begin
		counter <= 0;
	end
	else if (ch2_out_sof)
	begin
		counter <= 20'hfffff;
	end
	else if (counter > 0)
	begin
		counter <= new_counter;
	end
end

assign new_counter = counter - 1;

assign ch2_out_dst_rdy = (counter > 0) & (counter < 1048500) & ch2_out_dst_rdy_l;

port_fifo pf_channel_2 (
	.rst(rst_local),
	.in_clk(clk_local),
	.out_clk(clk_local),
	.in_data ( ch2_out_data ),	// Inport
	.in_sof ( ch2_out_sof ),	// Inport
	.in_eof ( ch2_out_eof ),	// Inport
	.in_src_rdy ( ch2_out_src_rdy ),	// Inport
	.in_dst_rdy ( ch2_out_dst_rdy_l ),	// Inport

	// Outputs:
	.out_data ( ch2_in_data ),	// Outport
	.out_sof ( ch2_in_sof ),	// Outport
	.out_eof ( ch2_in_eof ),	// Outport
	.out_src_rdy ( ch2_in_src_rdy ),	// Outport
	.out_dst_rdy ( ch2_in_dst_rdy )	// Outport
);

wire [7:0] LEDnext;

assign LEDS = LEDr;
	
always @(posedge clk_local)
begin
	DIP_r <= DIP;
end

always @(posedge clk_local)
begin
	if (rst_local)
		LEDr <= 0;
	else if (ch1_wen & ch1_out_src_rdy)
		LEDr <= LEDnext;
end


//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                                       Channel Assignments
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

assign ch1_in_sof = 1;
assign ch1_in_eof = 1;
assign ch1_in_src_rdy = 1;
assign ch1_out_dst_rdy = 1;
assign ch1_in_data = DIP_r;
assign LEDnext = ch1_out_data;




endmodule
