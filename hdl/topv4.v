// Top Module

module top
(
   // MII Interface - EMAC0
    MII_COL_0,
    MII_CRS_0,
    MII_TXD_0,
    MII_TX_EN_0,
    MII_TX_ER_0,
    MII_TX_CLK_0,
    MII_RXD_0,
    MII_RX_DV_0,
    MII_RX_ER_0,
    MII_RX_CLK_0,

    // Preserved Tie-Off Pins for EMAC0
    //SPEED_VECTOR_IN_0,
    HOSTCLK,
	 PHY_RESET_0,
    // Asynchronous Reset
    RESET
);

//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------

   // MII Interface - EMAC0
    input           MII_COL_0;
    input           MII_CRS_0;
    output   [3:0]  MII_TXD_0;
    output          MII_TX_EN_0;
    output          MII_TX_ER_0;
    input           MII_TX_CLK_0;
    input    [3:0]  MII_RXD_0;
    input           MII_RX_DV_0;
    input           MII_RX_ER_0;
    input           MII_RX_CLK_0;

    // Preserved Tie-Off Pins for EMAC0
    //input    [1:0]  SPEED_VECTOR_IN_0;
    input           HOSTCLK;
	 output				PHY_RESET_0;
   
    // Asynchronous Reset
    input           RESET;
	
//-----------------------------------------------------------------------------


//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                                       User Signals
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

//reg [7:0] DIP_r;
wire reset_i_n, reset_i;
//reg [7:0] LEDr;


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


enetplatform enet_inst
(
   .MII_COL_0(MII_COL_0),
	.MII_CRS_0(MII_CRS_0),
	.MII_TXD_0(MII_TXD_0),
	.MII_TX_EN_0(MII_TX_EN_0),
	.MII_TX_ER_0(MII_TX_ER_0),
	.MII_TX_CLK_0(MII_TX_CLK_0),
	.MII_RXD_0(MII_RXD_0),
	.MII_RX_DV_0(MII_RX_DV_0),
	.MII_RX_ER_0(MII_RX_ER_0),
	.MII_RX_CLK_0(MII_RX_CLK_0),
	.HOSTCLK(HOSTCLK),
	.PHY_RESET_0(PHY_RESET_0),
	.RESET(reset_i),
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
	.clk_local(clk_local)
);

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

   IBUF reset_ibuf (.I(RESET), .O(reset_i_n));
	assign reset_i = ~reset_i_n;

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                                       ICAP Logic
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

wire icap_en_wr;
wire icap_en_rd;
wire icap_out_src_rdy;
wire icap_in_dst_rdy;
wire icap_sofout;
wire icap_eofout;
wire [7:0] icap_dataout;

port_icap_buf the_picap
(
	.clk(clk_local),
	.rst(reset_i),
	.en_wr(icap_en_wr),
	.en_rd(icap_en_rd),
	.in_data(out_data_usr),
	.in_sof(out_sof_usr),
	.in_eof(out_eof_usr),
	.in_src_rdy(out_src_rdy_usr),
	.out_dst_rdy(in_dst_rdy_usr),
	.out_data(icap_dataout),
	.out_sof(icap_sofout),
	.out_eof(icap_eofout),
	.out_src_rdy(icap_out_src_rdy),
	.in_dst_rdy(icap_in_dst_rdy)
);

assign icap_en_wr = ((outport_usr == 3 && out_src_rdy_usr == 1) || (inport_usr == 3 && in_dst_rdy_usr == 1)) ? 1 : 0;
assign icap_en_rd = ((outport_usr == 4 && out_src_rdy_usr == 1) || (inport_usr == 4 && in_dst_rdy_usr == 1)) ? 1 : 0;
assign in_src_rdy_usr =	(inport_usr == 3 || inport_usr == 4) ? icap_out_src_rdy : 1;
assign out_dst_rdy_usr = (outport_usr == 3 || outport_usr == 4) ? icap_in_dst_rdy : 1;
assign in_sof_usr = (inport_usr == 3 || inport_usr == 4) ? icap_sofout : 1;
assign in_eof_usr = (inport_usr == 3 || inport_usr == 4) ? icap_eofout : 1;
assign in_data_usr = (inport_usr == 3 || inport_usr == 4) ? icap_dataout : 0;//DIP_r;


//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                                       User Logic
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------


//assign LEDS = LEDr;
	
/*always @(posedge clk_local)
begin
	DIP_r <= DIP;
end

always @(posedge clk_local)
begin
	if (reset_cpu_p)
		LEDr <= 0;
	else if (outport_usr == 1 && out_src_rdy_usr == 1)
		LEDr <= out_data_usr;
end*/

// LED Status
//moving_led pr_mod_inst (
//	.clk(clk_local),
//	.rst(reset_cpu_p),
//	.leds(LEDS)
//);

endmodule
