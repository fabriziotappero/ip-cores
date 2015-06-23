`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:49:28 06/15/2010 
// Design Name: 
// Module Name:    GbMAC_verify 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module GbMAC_verify(
	 input PhyA_RxClk,
	 input PhyA_RxCtl,
	 input [3:0] PhyA_RxD,	 
	 output PhyA_TxClk,
	 output PhyA_TxCtl,
	 output [3:0] PhyA_TxD,
	 
	 
	 
	 output PhyB_TxClk,
	 output PhyB_TxCtl,
	 output [3:0] PhyB_TxD,
	 
	 input PhyC_RxClk,
	 input PhyC_RxCtl,
	 input [3:0] PhyC_RxD,	 
	 
	 output PhyC_TxClk,
	 output PhyC_TxCtl,
	 output [3:0] PhyC_TxD,	 
	 
	 
	 input V4_PCIXClk,
	 
	 output V4_Uart_Tx,
	 input V4_Uart_Rx,
	 
	 input V4_CLK_125M,
    input V4_CLK_Sys,
    input V4_rst_n
);

// OPB BUS
wire [0:0] OPB_CS_n;
wire [11:0] OPB_Addr;
wire OPB_ADS;
wire [1:0] OPB_BE;
wire OPB_RnW;
wire OPB_Rd_n;
wire OPB_Wr_n;
wire OPB_Burst;
reg  OPB_Rdy;
wire [15:0] OPB_Din;
wire [15:0] OPB_Dout;
wire [0:31] OPB_outD;
wire [0:31] OPB_inD;

	//MAC Module signals
	wire [2:0] gEMAC_Speed;
	//user interface RX 
	wire Rx_ra, Rx_pa,Tx_wa, Tx_pa, Rx_sop, Rx_eop, Tx_sop, Tx_eop;
	reg Tx_wr;
	reg Rx_rd;
	wire [31:0] Rx_data, Tx_data;
	wire [1:0] Rx_BE, Tx_BE;
	wire pkt_length_fifo_rd, pkt_length_fifo_ra;
	wire [15:0] pkt_length_fifo_data;
	wire Carrier_Sense, Colision_Detect;

	//host interface
	wire RxClk_MAC;//For MAC Receiver block
	wire MAC_RegSelect;
	wire MAC_RdnWr;
	wire [15:0] MAC_RegDin;
	wire [15:0] MAC_RegDout;
	wire [7:0] MAC_RegAddr;

//RGMII-GMII adaptation module
	wire [7:0] GMII_TxD;
	wire GMII_TxEN, GMII_TxER, GTx_Clk;
	wire [7:0] GMII_RxD;
	wire GMII_RxDV, GMII_RxER, GRx_Clk;
	reg  CE, Sync_Rst;

	wire [3:0] RGMII_RxD;
	wire [3:0] RGMII_TxD;
	wire RGMII_RxCtl, RGMII_RxClk;
	wire RGMII_TxCtl, RGMII_TxClk;

	wire [3:0] RxPhyA_Stat;
	
	wire CLK_125M90;
	wire CLK_125M;
	wire CLK_25M;
	wire V4_rst;
	wire uB_rst;
	reg pwr_on_rst;	
	wire MAC_Sysclk;
	wire MAC_Regclk;
	
	reg one_sec_pulse;
	reg [27:0] one_sec;
	reg [31:0] rx_rate;	
	reg [31:0] rx_rate_reg;
	
	wire [0:0] ila_trig0, ila_trig1, ila_trig2;
	wire [63:0] ila_data_bus;
	wire [35:0] ila_control;
	wire [23:0] MAC_Monitoring;

	wire [35:0] LoopbackFIFO_din,LoopbackFIFO_dout;
	wire LoopbackFIFO_empty;
	wire LoopbackFIFO_full;
	wire LoopbackFIFO_wren;
	reg LoopbackFIFO_rden;
	
	assign PhyA_TxD =  0;//RGMII_TxD;
	assign PhyA_TxClk = 0;//RGMII_TxClk;
	assign PhyA_TxCtl = 0;//RGMII_TxCtl;
	assign PhyB_TxD =  0;//RGMII_TxD;
	assign PhyB_TxClk = 0;//RGMII_TxClk;
	assign PhyB_TxCtl = 0;//RGMII_TxCtl;
	
	assign PhyC_TxD = RGMII_TxD;
	assign PhyC_TxClk = RGMII_TxClk;
	assign PhyC_TxCtl = RGMII_TxCtl;
	
	assign RGMII_RxD  = PhyC_RxD;
	assign RGMII_RxCtl= PhyC_RxCtl;
	assign RGMII_RxClk= PhyC_RxClk;
	
	assign CLK_66M = V4_PCIXClk;
	
		always@(posedge(CLK_125M))
	begin
	  if(!V4_rst_n)
		begin
			Sync_Rst <= 1;
			CE <= 0;
		end
		else
		begin
			Sync_Rst <= 0;		
			CE <= 1;
		end
	end

	assign V4_rst = (~V4_rst_n)|pwr_on_rst;
	assign uB_rst = ~ V4_rst;

Clocks Clockings(.V4_Clk_125M(V4_CLK_125M),.V4_Clk_27M(),.V4_Clk_13M5(),
						.Clk_125M(CLK_125M),.Clk_27M(),.Clk_13M5(),.Clk_25M(CLK_25M),
						.Clk_125M_90(CLK_125M90),
						.rst(0));
						
		reg [3:0] pwr_on_cnt;
		initial 
		begin
		pwr_on_rst <= 1;
		pwr_on_cnt <= 0;
		end
		always@(posedge CLK_125M)
		begin
		if (pwr_on_cnt!=15) pwr_on_cnt <= pwr_on_cnt+1;
		if (pwr_on_cnt<15 && pwr_on_cnt>9)	
					pwr_on_rst <= 1;
					else
					pwr_on_rst <= 0;
		end
	
		assign RxClkPhase = 0;
		RGMII_GMII_Adaptation RGMIIAdp(
									 .Speed(gEMAC_Speed),.RxClkPhase(RxClkPhase),
									 .TxD(GMII_TxD), .TxEN(GMII_TxEN), .TxER(GMII_TxER), .TxClk(GTx_Clk),
									 .RxD(GMII_RxD), .RxDV(GMII_RxDV), .RxER(GMII_RxER), .RxClk(GRx_Clk),
									 .RGMII_TxD(RGMII_TxD),
									 .RGMII_TxCtl(RGMII_TxCtl),
									 .RGMII_TxClk(RGMII_TxClk),
									 .RGMII_RxD(RGMII_RxD),
									 .RGMII_RxCtl(RGMII_RxCtl),
									 .RGMII_RxClk(RGMII_RxClk),
									 .Status(RxPhyA_Stat),
									 .RxClk_MAC(RxClk_MAC),
									 .CE(CE),
									 .rst(V4_rst)
									 );
		
		assign MAC_Sysclk = CLK_125M;
assign MAC_Regclk = CLK_66M;
//MAC Module
MAC_top  gMAC(                //system signals
.Reset(V4_rst),
.Clk_125M(CLK_125M),
.Clk_user(MAC_Sysclk),
.Clk_reg(MAC_Regclk),
.Clk_MACRx(RxClk_MAC),
.Speed(gEMAC_Speed),
//user interface RX 
.Rx_mac_ra(Rx_ra),
.Rx_mac_rd(Rx_rd),
.Rx_mac_data(Rx_data),
.Rx_mac_BE(Rx_BE),
.Rx_mac_pa(Rx_pa),
.Rx_mac_sop(Rx_sop),
.Rx_mac_eop(Rx_eop),
//user interface 
.Tx_mac_wa(Tx_wa),
.Tx_mac_wr(Tx_wr),
.Tx_mac_data(Tx_data),
.Tx_mac_BE(Tx_BE),//big endian
.Tx_mac_sop(Tx_sop),
.Tx_mac_eop(Tx_eop),
//pkg_lgth fifo
.Pkg_lgth_fifo_rd(pkt_length_fifo_rd),
.Pkg_lgth_fifo_ra(pkt_length_fifo_ra),
.Pkg_lgth_fifo_data(pkt_length_fifo_data),
//Phy interface          
//Phy interface         
.Gtx_clk(GTx_Clk),//used only in GMII mode
.Rx_clk(GRx_Clk),
.Tx_clk(CLK_25M),//used only in MII mode
.Tx_er(GMII_TxER),
.Tx_en(GMII_TxEN),
.Txd(GMII_TxD),
.Rx_er(GMII_RxER),
.Rx_dv(GMII_RxDV),
.Rxd(GMII_RxD),
.Crs(Carrier_Sense),
.Col(Colision_Detect),
//host interface
.CSB(MAC_RegSelect),
.WRB(MAC_RdnWr),
.CD_in(MAC_RegDin),
.CD_out(MAC_RegDout),
.CA(MAC_RegAddr),                
.Monitoring(MAC_Monitoring),
//mdx
.Mdo(),                // MII Management Data Output
.MdoEn(),              // MII Management Data Output Enable
.Mdi(0),
.Mdc()                      // MII Management Data Clock       
);     

	LoopbackFIFO lpbff(
	.clk(CLK_125M),
	.din(LoopbackFIFO_din),
	.rd_en(LoopbackFIFO_rden),
	.wr_en(LoopbackFIFO_wren),
	.dout(LoopbackFIFO_dout),
	.empty(),
	.full(),
	.almost_empty(LoopbackFIFO_empty),
	.almost_full(LoopbackFIFO_full));
	
	assign LoopbackFIFO_din = {Rx_BE,Rx_sop,Rx_eop,Rx_data};
	assign LoopbackFIFO_wren= Rx_pa;
	
		//Route packet back to transmitter
		assign Tx_data = LoopbackFIFO_dout[31:0];
		assign Tx_sop = LoopbackFIFO_dout[33];
		assign Tx_eop = LoopbackFIFO_dout[32];
		assign Tx_BE =  LoopbackFIFO_dout[35:34];
		
		assign MAC_RegSelect = OPB_CS_n;
		assign MAC_RegDin = OPB_outD[0:15];
		assign OPB_inD = {MAC_RegDout,16'h0000};
		assign MAC_RegAddr = OPB_Addr[7:0];
		assign MAC_RdnWr = OPB_RnW;

		//Initializing machine
		always@(posedge MAC_Regclk or posedge V4_rst)
		begin
		if(V4_rst)
			begin
			OPB_Rdy <= 0;
			end
		else
			begin
				OPB_Rdy <= ~OPB_CS_n;
			end
		end
		
		assign Carrier_Sense = 1;
		assign Colision_Detect = 0;

		wire one_sec_pulse_long;
		
		assign one_sec_pulse_long = (one_sec>0 && one_sec<256)?1:0;
		
		always@(posedge MAC_Sysclk or posedge V4_rst)
		if(V4_rst)
		begin
		one_sec <=0;
		one_sec_pulse <= 0;
		Rx_rd <= 0;		 		
		Tx_wr <= 0;
		LoopbackFIFO_rden <= 0;
		end
		else
		begin
			if(one_sec == 125000000) one_sec <= 1; else one_sec <= one_sec+1;
			if(one_sec == 125000000) one_sec_pulse <= 1; else one_sec_pulse <= 0;			
			if(one_sec_pulse)
				begin
				rx_rate <= 0;
				rx_rate_reg <= rx_rate;
				end
			else
				begin
				if(Rx_sop) rx_rate <= rx_rate+1;				
				end
			//start to read whenever data is available;
			Rx_rd <= Rx_ra & (~LoopbackFIFO_full);
			LoopbackFIFO_rden <= Tx_wa & (~LoopbackFIFO_empty);
			Tx_wr <= LoopbackFIFO_rden;
		end
		
			//Microblaze 
	uBlaze microBlaze
  ( .uBlaze_Int(one_sec_pulse_long),
	 .fpga_0_RS232_req_to_send_pin(),
    .fpga_0_RS232_RX_pin(V4_Uart_Rx),
    .fpga_0_RS232_TX_pin(V4_Uart_Tx),
    .sys_clk_pin(CLK_66M),
    .sys_rst_pin(uB_rst),
    .PRH_Clk_pin(CLK_66M),
    .PRH_Rst_pin(V4_rst),
    .PRH_CS_n_pin(OPB_CS_n),
    .PRH_Addr_pin(OPB_Addr),
    .PRH_ADS_pin(OPB_ADS),
    .PRH_BE_pin(OPB_BE),
    .PRH_RNW_pin(OPB_RnW),
    .PRH_Rd_n_pin(OPB_Rd_n),
    .PRH_Wr_n_pin(OPB_Wr_n),
    .PRH_Burst_pin(OPB_Burst),
    .PRH_Rdy_pin(OPB_Rdy),
    .PRH_Data_I_pin(OPB_inD),
    .PRH_Data_O_pin(OPB_outD),
    .PRH_Data_T_pin());

 	//Monitoring
	ila i_ila
    (
      .control(ila_control),
      .clk(CLK_125M),
      .data(ila_data_bus),
      .trig0(ila_trig0),
      .trig1(ila_trig1),
      .trig2(ila_trig2)
    );
	 
	

	assign ila_data_bus[31:0] =  {0,gEMAC_Speed,MAC_Monitoring};
	assign ila_data_bus[47:32] = {GMII_TxEN,GMII_TxER,GMII_TxD};
	assign ila_data_bus[63:48] = {0,LoopbackFIFO_empty,LoopbackFIFO_full,Tx_wr,Tx_wa,Rx_ra,Rx_pa,Rx_rd};
	assign ila_trig0 = Rx_rd;
	assign ila_trig1 = Tx_wr;
	assign ila_trig2 = LoopbackFIFO_full;
	
	icon i_icon
    (
      .control0(ila_control)      
    );

endmodule

module icon 
  (
      control0
  );
  output [35:0] control0;
endmodule

module ila
  (
    control,
    clk,
    data,
    trig0,
    trig1,
    trig2
  );
  input [35:0] control;
  input clk;
  input [63:0] data;
  input [0:0] trig0;
  input [0:0] trig1;
  input [0:0] trig2;
endmodule
