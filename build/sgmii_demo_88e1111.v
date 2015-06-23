/*
Copyright Â© 2012 JeffLieu-lieumychuong@gmail.com

	This file is part of SGMII-IP-Core.
    SGMII-IP-Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SGMII-IP-Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SGMII-IP-Core.  If not, see <http://www.gnu.org/licenses/>.

File		:	sgmii_demo.v
Description	:	This file implements top-level file to test SGMII core

Remarks		:

Revision	:
	Date	Author	Description

*/

module sgmii_demo_88e1111(
	input 	i_Clkin,
	input 	i_ARst_L,
	output 	o_SGMIITx,
	input 	i_SGMIIRx,
	output 	o_LedANDone,
	output 	o_LedSpeed1000Mbps,
	output 	o_LedLinkUp,
	output 	o_LedHeartBeat,
	
	output  o_Mdc,
	inout 	io_Mdio,
	output 	o_PhyRst_L,
	
	input 	[7:0] i8_TxD,
	input 	i_TxEN,
	input 	i_TxER,
	output 	[7:0] o8_RxD,
	output 	o_RxDV,
	output 	o_RxER,
	output 	o_GMIIClk,
	output 	o_MIIClk,
	output 	o_Col,
	output 	o_Crs);
	
	
	wire w_ARst_L;
	//Bus Interface
	wire w_Cyc,w_Stb,w_WEn,w_Ack;
	wire w_SgmiiAck,w_MdioAck;
	wire [31:0] w32_RdData,w32_WrData;
	wire [31:0] w32_RdDataSgmii,w32_RdDataMdio;
	wire [7:0] w8_Addr;
	wire [1:0] w2_SGMIISpeed;
	wire w_Duplex;
	wire w_LinkUp,w_ANDone;
	wire [1:0] w2_CS;
	wire w_SysRst_L;
	reg r_SysRstD1_L,r_SysRstD2_L;
	
	wire [31:0] w32_RxMacD,w32_TxMacD;
	wire w_RxMacRa,w_RxMacRd,w_RxMacPa,w_RxMacSop,w_RxMacEop;
	wire w_TxMacWa,w_TxMacWr,w_TxMacPa,w_TxMacSop,w_TxMacEop;
	wire [1:0] w2_RxMacBE,w2_TxMacBE;
	wire [7:0] w8_TxD,w8_RxD;
	wire w_TxEn,w_TxEr,w_RxDv,w_RxEr;
	reg r_TxEn,r_TxEr;
	reg [7:0] r8_TxD;
	wire [15:0] w16_PktLength;
	reg [31:0] r32_PacketLengthCntr;
	reg r_ReadPktLength;
	reg r_ReadPkt;
	reg [31:0] r32_PktCntr;
	
	mPshBtnDbnce u0Dbncer(.i_Clk(i_Clkin),.i_PshBtn(i_ARst_L),.o_Dbnced(w_ARst_L));
	
	//SGMII Core
	mSGMII u0SGMII
	(
	//Tranceiver Interface
	.i_SerRx			(i_SGMIIRx),
	.o_SerTx			(o_SGMIITx),
	.i_CalClk			(1'b0),
	.i_RefClk125M		(i_Clkin),
	.i_ARstHardware_L	(r_SysRstD2_L),

	//Local BUS interface
	//Wishbonebus, single transaction mode (non-pipeline slave)
	.i_Cyc			(w_Cyc&w2_CS[0]),
	.i_Stb			(w_Stb&w2_CS[0]),
	.i_WEn			(w_WEn&w2_CS[0]),
	.i32_WrData		(w32_WrData),
	.iv_Addr		(w8_Addr),
	.o32_RdData		(w32_RdDataSgmii),
	.o_Ack			(w_SgmiiAck),
	
	.i_Mdc		(1'b0),
	.io_Mdio	(),
	
	.o_Linkup	(w_LinkUp),
	.o_ANDone	(w_ANDone),
	//This is used in Phy-Side SGMII 
	.i_PhyLink		(1'b0),
	.i_PhyDuplex	(1'b0),
	.i2_PhySpeed	(2'b0),	
	
	
	.o2_SGMIISpeed	(w2_SGMIISpeed),
	.o_SGMIIDuplex	(w_Duplex),
	
	//GMII Interface
	.o_TxClk	(w_TxClk	),
	.o_RxClk	(w_RxClk	),
	.i8_TxD		(w8_TxD		),
	.i_TxEN		(w_TxEn		),
	.i_TxER		(w_TxEr		),	
	.o8_RxD		(w8_RxD		),
	.o_RxDV		(w_RxDv		),
	.o_RxER		(w_RxEr		),
	.o_GMIIClk	(w_GMIIClk	),
	.o_MIIClk	(o_MIIClk	),	
	.o_Col		(o_Col		),
	.o_Crs		(o_Crs		));
	
	//Initializer
	mWishboneMaster88E1111	u0WishboneMaster(
			.ov_CSel(w2_CS),
			.o_Cyc(w_Cyc),
			.o_Stb(w_Stb),
			.o_WEn(w_WEn),
			.i_Ack(w_Ack),
			.o32_WrData(w32_WrData),
			.i32_RdData(w32_RdData),
			.ov_Addr(w8_Addr),			
			.i_Clk(w_GMIIClk),
			.i_ARst_L(r_SysRstD2_L));
	
	assign w_Ack = (w2_CS[0]&w_SgmiiAck)|(w2_CS[1]&w_MdioAck);
	assign w32_RdData = (w2_CS==2'b01)?w32_RdDataSgmii:((w2_CS==2'b10)?w32_RdDataMdio:32'h0);
						
	
	mMdioMstr u0MdioMstr(
	.i_Clk		(w_GMIIClk	),
	.i_ARst_L	(r_SysRstD2_L),
	//Wishbone interface
	.i_Cyc		(w_Cyc&w2_CS[1]),
	.i_Stb		(w_Stb&w2_CS[1]),
	.i_WEn		(w_WEn&w2_CS[1]),
	.o_Ack		(w_MdioAck),
	.i2_Addr	(w8_Addr[1:0]),
	.i32_WrData	(w32_WrData),
	.o32_RdData	(w32_RdDataMdio),
	
	//MDIO Interface
	.o_Mdc		(o_Mdc),
	.io_Mdio	(io_Mdio));

	assign o_LedANDone = ~w_ANDone;
	assign o_LedLinkUp = ~w_LinkUp;
	assign o_LedSpeed1000Mbps = (w2_SGMIISpeed==2'b10)?1'b0:1'b1;
	
	//PowerOnPhyReset
	reg [24:0] r25_PhyRstCntr;
	always@(posedge i_Clkin or negedge w_ARst_L) 
	if(~w_ARst_L)
		r25_PhyRstCntr<=20'h0;
	else if(~w_SysRst_L)
		r25_PhyRstCntr<=r25_PhyRstCntr+20'h1;
	assign o_PhyRst_L = r25_PhyRstCntr[24]?1'bz:1'b0;
	assign w_SysRst_L = (&r25_PhyRstCntr);
	
	
	always@(posedge w_GMIIClk)
		begin 
			r_SysRstD1_L <= w_SysRst_L;
			r_SysRstD2_L <= r_SysRstD1_L;
		end
		
	//////////////////////////////////////////////////
	//Open core MAC
	//////////////////////////////////////////////////
	
		
	MAC_top OpenCoreMac(
    //system signals
	.Reset  		( ~w_SysRst_L),
	
	.Clk_user       (w_TxClk),
	.Clk_reg        (w_GMIIClk),

	.Speed			(),
	.GMII_Tx_clk	(w_TxClk),
	.GMII_Rx_clk	(w_RxClk),
	
    //user interface 
	.Rx_mac_ra		(w_RxMacRa),
	.Rx_mac_rd		(w_RxMacRd),
	.Rx_mac_data	(w32_RxMacD),
	.Rx_mac_BE		(w2_RxMacBE),
	.Rx_mac_pa		(w_RxMacPa),
	.Rx_mac_sop		(w_RxMacSop),
	.Rx_mac_eop		(w_RxMacEop),
                //user interface 
	.Tx_mac_wa               (w_TxMacWa),
	.Tx_mac_wr               (w_TxMacWr),
	.Tx_mac_data             (w32_TxMacD),
	.Tx_mac_BE               (w2_TxMacBE),//big endian
	.Tx_mac_sop              (w_TxMacSop),
	.Tx_mac_eop              (w_TxMacEop),
	//pkg_lgth fifo         ()
	.Pkg_lgth_fifo_rd        (w_PktLengthRd),
	.Pkg_lgth_fifo_ra        (w_PktLengthRa),
	.Pkg_lgth_fifo_data      (w16_PktLength),
                //Phy interface          
                //Phy interface         
	.Gtx_clk_d	(),//shifted clock
	.Gtx_clk	(),//used only in GMII mode
		
	.Rx_clk 	(o_MIIClk),
	.Tx_clk		(),//used only in MII mode
	.Tx_er		(w_TxEr),
	.Tx_en  	(w_TxEn),
	.Txd  		(w8_TxD),
	.Rx_er		(w_RxEr	),
	.Rx_dv		(w_RxDv	),
	.Rxd  		(w8_RxD	),
	.Crs  		(w_Crs	),
	.Col  		(w_Col	),
                //host interface
	.CSB    	(1'b1),
	.WRB    	(1'b1),
	.CD_in  	(0),
	.CD_out 	(),
	.CA     	(0),                

	.Monitoring	(),
                
	.Mdo	(),			// MII Management Data Output
	.MdoEn	(),			// MII Management Data Output Enable
	.Mdi	(1'b0),
	.Mdc	()			// MII Management Data Clock       

);                       
	/////////////////////////////////////////////
	//Packet Generator
	//A little state machine to push to the packet
	////////////////////////////////////////////
	reg r_Transmit;
	wire w_PktReady;
	always@(posedge w_TxClk or negedge w_SysRst_L)
	if(~w_SysRst_L)
		begin 
			r_Transmit <= 1'b0;		
		end 
	else 
		begin if(w_ANDone)
			if(w_PktReady & w_TxMacWa)
				r_Transmit <= 1'b1;
			else if(w_TxMacEop)
				r_Transmit <= 1'b0;		
		end 
		
	pkt_gen32 PacketGen(
	.clk		(w_TxClk),
	.rst		(~w_SysRst_L),
	.control	(16'h1),
	.status		(),
	.config_1	(32'hF_0200),
	.config_2	(32'h0_FFFF),
	.i32_Payload1(r32_PacketLengthCntr),
	.i32_Payload2(r32_PktCntr),
	.i32_Payload3(0),
	.i32_Payload4(0),
	.pkt_rdy	(w_PktReady),
	.pkt_dv		(w_TxMacWr),
	.pkt_sop	(w_TxMacSop),
	.pkt_eop	(w_TxMacEop),
	.pkt_data	(w32_TxMacD),
	.pkt_rd		(r_Transmit),
	.pkt_BE		(w2_TxMacBE),
	.pkt_len_rd		(),
	.pkt_len_rdy 	(),
	.pkt_len		());
	
	
		always@(posedge w_TxClk or negedge w_SysRst_L)
		if(~w_SysRst_L)
			begin 
				r32_PacketLengthCntr <= 0;
				r_ReadPkt <= 1'b0;
				r32_PktCntr <= 0;
			end
		else begin 
			if(w_PktLengthRa & (~r_ReadPkt)) 
				begin 
				r_ReadPkt <= 1'b1;
				end
			else 
				if(w_RxMacEop)
					r_ReadPkt <= 1'b0;			
			
			if(w_RxMacSop) begin
				r32_PktCntr<=r32_PktCntr+32'h1; 
				r32_PacketLengthCntr<=r32_PacketLengthCntr+{16'h0,w16_PktLength};
				end

			
			end
			
		assign w_PktLengthRd = w_RxMacSop;		
		assign w_RxMacRd = r_ReadPkt;
		
	
endmodule
