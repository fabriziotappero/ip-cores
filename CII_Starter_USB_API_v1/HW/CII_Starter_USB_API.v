//Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.


module CII_Starter_USB_API
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_24,						//	24 MHz
		CLOCK_27,						//	27 MHz
		CLOCK_50,						//	50 MHz
		EXT_CLOCK,						//	External Clock
		////////////////////	Push Button		////////////////////
		KEY,							//	Pushbutton[3:0]
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[9:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0,							//	Seven Segment Digit 0
		HEX1,							//	Seven Segment Digit 1
		HEX2,							//	Seven Segment Digit 2
		HEX3,							//	Seven Segment Digit 3
		////////////////////////	LED		////////////////////////
		LEDG,							//	LED Green[7:0]
		LEDR,							//	LED Red[9:0]
		////////////////////////	UART	////////////////////////
		UART_TXD,						//	UART Transmitter
		UART_RXD,						//	UART Receiver
		/////////////////////	SDRAM Interface		////////////////
		DRAM_DQ,						//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 12 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA_0,						//	SDRAM Bank Address 0
		DRAM_BA_1,						//	SDRAM Bank Address 0
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		////////////////////	Flash Interface		////////////////
		FL_DQ,							//	FLASH Data bus 8 Bits
		FL_ADDR,						//	FLASH Address bus 22 Bits
		FL_WE_N,						//	FLASH Write Enable
		FL_RST_N,						//	FLASH Reset
		FL_OE_N,						//	FLASH Output Enable
		FL_CE_N,						//	FLASH Chip Enable
		////////////////////	SRAM Interface		////////////////
		SRAM_DQ,						//	SRAM Data bus 16 Bits
		SRAM_ADDR,						//	SRAM Address bus 18 Bits
		SRAM_UB_N,						//	SRAM High-byte Data Mask 
		SRAM_LB_N,						//	SRAM Low-byte Data Mask 
		SRAM_WE_N,						//	SRAM Write Enable
		SRAM_CE_N,						//	SRAM Chip Enable
		SRAM_OE_N,						//	SRAM Output Enable
		////////////////////	SD_Card Interface	////////////////
		SD_DAT,							//	SD Card Data
		SD_DAT3,						//	SD Card Data 3
		SD_CMD,							//	SD Card Command Signal
		SD_CLK,							//	SD Card Clock
		////////////////////	USB JTAG link	////////////////////
		TDI,  							// CPLD -> FPGA (data in)
		TCK,  							// CPLD -> FPGA (clk)
		TCS,  							// CPLD -> FPGA (CS)
	    TDO,  							// FPGA -> CPLD (data out)
		////////////////////	I2C		////////////////////////////
		I2C_SDAT,						//	I2C Data
		I2C_SCLK,						//	I2C Clock
		////////////////////	PS2		////////////////////////////
		PS2_DAT,						//	PS2 Data
		PS2_CLK,						//	PS2 Clock
		////////////////////	VGA		////////////////////////////
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_R,   						//	VGA Red[3:0]
		VGA_G,	 						//	VGA Green[3:0]
		VGA_B,  						//	VGA Blue[3:0]
		////////////////	Audio CODEC		////////////////////////
		AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		AUD_ADCDAT,						//	Audio CODEC ADC Data
		AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		AUD_DACDAT,						//	Audio CODEC DAC Data
		AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		AUD_XCK,						//	Audio CODEC Chip Clock
		////////////////////	GPIO	////////////////////////////
		GPIO_0,							//	GPIO Connection 0
		GPIO_1							//	GPIO Connection 1
	);

////////////////////////	Clock Input	 	////////////////////////
input	[1:0]	CLOCK_24;				//	24 MHz
input	[1:0]	CLOCK_27;				//	27 MHz
input			CLOCK_50;				//	50 MHz
input			EXT_CLOCK;				//	External Clock
////////////////////////	Push Button		////////////////////////
input	[3:0]	KEY;					//	Pushbutton[3:0]
////////////////////////	DPDT Switch		////////////////////////
input	[9:0]	SW;						//	Toggle Switch[9:0]
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0;					//	Seven Segment Digit 0
output	[6:0]	HEX1;					//	Seven Segment Digit 1
output	[6:0]	HEX2;					//	Seven Segment Digit 2
output	[6:0]	HEX3;					//	Seven Segment Digit 3
////////////////////////////	LED		////////////////////////////
output	[7:0]	LEDG;					//	LED Green[7:0]
output	[9:0]	LEDR;					//	LED Red[9:0]
////////////////////////////	UART	////////////////////////////
output			UART_TXD;				//	UART Transmitter
input			UART_RXD;				//	UART Receiver
///////////////////////		SDRAM Interface	////////////////////////
inout	[15:0]	DRAM_DQ;				//	SDRAM Data bus 16 Bits
output	[11:0]	DRAM_ADDR;				//	SDRAM Address bus 12 Bits
output			DRAM_LDQM;				//	SDRAM Low-byte Data Mask 
output			DRAM_UDQM;				//	SDRAM High-byte Data Mask
output			DRAM_WE_N;				//	SDRAM Write Enable
output			DRAM_CAS_N;				//	SDRAM Column Address Strobe
output			DRAM_RAS_N;				//	SDRAM Row Address Strobe
output			DRAM_CS_N;				//	SDRAM Chip Select
output			DRAM_BA_0;				//	SDRAM Bank Address 0
output			DRAM_BA_1;				//	SDRAM Bank Address 0
output			DRAM_CLK;				//	SDRAM Clock
output			DRAM_CKE;				//	SDRAM Clock Enable
////////////////////////	Flash Interface	////////////////////////
inout	[7:0]	FL_DQ;					//	FLASH Data bus 8 Bits
output	[21:0]	FL_ADDR;				//	FLASH Address bus 22 Bits
output			FL_WE_N;				//	FLASH Write Enable
output			FL_RST_N;				//	FLASH Reset
output			FL_OE_N;				//	FLASH Output Enable
output			FL_CE_N;				//	FLASH Chip Enable
////////////////////////	SRAM Interface	////////////////////////
inout	[15:0]	SRAM_DQ;				//	SRAM Data bus 16 Bits
output	[17:0]	SRAM_ADDR;				//	SRAM Address bus 18 Bits
output			SRAM_UB_N;				//	SRAM High-byte Data Mask 
output			SRAM_LB_N;				//	SRAM Low-byte Data Mask 
output			SRAM_WE_N;				//	SRAM Write Enable
output			SRAM_CE_N;				//	SRAM Chip Enable
output			SRAM_OE_N;				//	SRAM Output Enable
////////////////////	SD Card Interface	////////////////////////
inout			SD_DAT;					//	SD Card Data
inout			SD_DAT3;				//	SD Card Data 3
inout			SD_CMD;					//	SD Card Command Signal
output			SD_CLK;					//	SD Card Clock
////////////////////////	I2C		////////////////////////////////
inout			I2C_SDAT;				//	I2C Data
output			I2C_SCLK;				//	I2C Clock
////////////////////////	PS2		////////////////////////////////
input		 	PS2_DAT;				//	PS2 Data
input			PS2_CLK;				//	PS2 Clock
////////////////////	USB JTAG link	////////////////////////////
input  			TDI;					// CPLD -> FPGA (data in)
input  			TCK;					// CPLD -> FPGA (clk)
input  			TCS;					// CPLD -> FPGA (CS)
output 			TDO;					// FPGA -> CPLD (data out)
////////////////////////	VGA			////////////////////////////
output			VGA_HS;					//	VGA H_SYNC
output			VGA_VS;					//	VGA V_SYNC
output	[3:0]	VGA_R;   				//	VGA Red[3:0]
output	[3:0]	VGA_G;	 				//	VGA Green[3:0]
output	[3:0]	VGA_B;   				//	VGA Blue[3:0]
////////////////////	Audio CODEC		////////////////////////////
output			AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
input			AUD_ADCDAT;				//	Audio CODEC ADC Data
output			AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
output			AUD_DACDAT;				//	Audio CODEC DAC Data
inout			AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
output			AUD_XCK;				//	Audio CODEC Chip Clock
////////////////////////	GPIO	////////////////////////////////
inout	[35:0]	GPIO_0;					//	GPIO Connection 0
inout	[35:0]	GPIO_1;					//	GPIO Connection 1
////////////////////////////////////////////////////////////////////

//	USB JTAG
wire [7:0] mRXD_DATA,mTXD_DATA;
wire mRXD_Ready,mTXD_Done,mTXD_Start;
wire mTCK;
//	FLASH
wire [21:0] mFL_ADDR;
wire [7:0] mFL2RS_DATA,mRS2FL_DATA;
wire [2:0] mFL_CMD;
wire mFL_Ready,mFL_Start;
//	SDRAM
wire [21:0] mSD_ADDR;
wire [15:0] mSD2RS_DATA,mRS2SD_DATA;
wire mSD_WR,mSD_RD,mSD_Done;
//	SRAM
wire [17:0]	mSR_ADDR;
wire [15:0]	mSR2RS_DATA,mRS2SR_DATA;
wire		mSR_OE,mSR_WE;
//	SEG7
wire [31:0] mSEG7_DIG;
//	LCD
wire [7:0]	mLCD_DATA;
wire		mLCD_RS;
wire		mLCD_Start;
wire		mLCD_Done;
//	PS2
wire [7:0] PS2_ASCII;
wire PS2_Error,PS2_Ready;
//	VGA
wire [9:0] mVGA_R;
wire [9:0] mVGA_G;
wire [9:0] mVGA_B;
wire [9:0] mOSD_R;
wire [9:0] mOSD_G;
wire [9:0] mOSD_B;
wire [9:0] mVIN_R;
wire [9:0] mVIN_G;
wire [9:0] mVIN_B;
wire [9:0] oVGA_R;
wire [9:0] oVGA_G;
wire [9:0] oVGA_B;
wire [9:0] mVGA_X;
wire [9:0] mVGA_Y;
wire [19:0]	mVGA_ADDR;
wire [9:0]	mCursor_X;
wire [9:0]	mCursor_Y;
wire [9:0]	mCursor_R;
wire [9:0]	mCursor_G;
wire [9:0]	mCursor_B;
wire [1:0]	mOSD_CUR_EN;
//	Async Port Select
wire [2:0] mSDR_Select;
wire [2:0] mFL_Select;
wire [2:0] mSR_Select;
//	FLASH Async Port
wire [21:0] mFL_AS_ADDR_1;
wire [21:0] mFL_AS_ADDR_2;
wire [21:0] mFL_AS_ADDR_3;
wire [7:0]	mFL_AS_DATA_1;
wire [7:0]	mFL_AS_DATA_2;
wire [7:0]	mFL_AS_DATA_3;
//	SDRAM Async Port
wire [15:0] mSDR_AS_DATAOUT_1;
wire [15:0] mSDR_AS_DATAOUT_2;
wire [15:0] mSDR_AS_DATAOUT_3;
wire [21:0] mSDR_AS_ADDR_1	= 0;
wire [21:0] mSDR_AS_ADDR_2	= 0;
wire [21:0] mSDR_AS_ADDR_3	= 0;
wire [15:0] mSDR_AS_DATAIN_1= 0;
wire [15:0] mSDR_AS_DATAIN_2= 0;
wire [15:0] mSDR_AS_DATAIN_3= 0;
wire 		mSDR_AS_WR_n_1	= 0;
wire 		mSDR_AS_WR_n_2	= 0;
wire 		mSDR_AS_WR_n_3	= 0;
//	SRAM Async Port
wire [15:0]	mSRAM_VGA_DATA;

wire		VGA_CTRL_CLK;
wire		AUD_CTRL_CLK;
wire		DLY_RST;

//	All inout port turn to tri-state
assign	SD_DAT		=	1'bz;
assign	GPIO_0		=	36'hzzzzzzzzz;
assign	GPIO_1		=	36'hzzzzzzzzz;
//	VGA Data Reorder
assign	mVIN_R		=	mVGA_ADDR[0]	?	mSRAM_VGA_DATA[15:8]<<2	:	mSRAM_VGA_DATA[7:0]<<2	;	
assign	mVIN_G		=	mVGA_ADDR[0]	?	mSRAM_VGA_DATA[15:8]<<2	:	mSRAM_VGA_DATA[7:0]<<2	;	
assign	mVIN_B		=	mVGA_ADDR[0]	?	mSRAM_VGA_DATA[15:8]<<2	:	mSRAM_VGA_DATA[7:0]<<2	;	
//	VGA Data Source Select
assign	mVGA_R		=	~mOSD_CUR_EN[1]	?	mOSD_R	:	mVIN_R;
assign	mVGA_G		=	~mOSD_CUR_EN[1]	?	mOSD_G	:	mVIN_G;
assign	mVGA_B		=	~mOSD_CUR_EN[1]	?	mOSD_B	:	mVIN_B;
//	VGA Data 10-bit to 4-bit
assign	VGA_R		=	oVGA_R[9:6];
assign	VGA_G		=	oVGA_G[9:6];
assign	VGA_B		=	oVGA_B[9:6];
//	Audio
assign	AUD_ADCLRCK	=	AUD_DACLRCK;
assign	AUD_XCK		=	AUD_CTRL_CLK;

CLK_LOCK 			p0	(	.inclk(TCK),.outclk(mTCK)	);

Reset_Delay			d0	(	.iCLK(CLOCK_50),.oRESET(DLY_RST)	);

SEG7_LUT_4 			u0	(	HEX0,HEX1,HEX2,HEX3,mSEG7_DIG );

USB_JTAG			u1	(	//	HOST
							.iTxD_DATA(mTXD_DATA),.oTxD_Done(mTXD_Done),.iTxD_Start(mTXD_Start),
							.oRxD_DATA(mRXD_DATA),.oRxD_Ready(mRXD_Ready),.iRST_n(KEY[0]),.iCLK(CLOCK_50),
							//	JTAG
							.TDO(TDO),.TDI(TDI),.TCS(TCS),.TCK(mTCK)	);

Multi_Flash			u2	(	//	Host Side
							mFL2RS_DATA,mRS2FL_DATA,mFL_ADDR,mFL_CMD,mFL_Ready,mFL_Start,
							//	Async Side 1
							mFL_AS_DATA_1,mFL_AS_ADDR_1,
							//	Async Side 2
							mFL_AS_DATA_2,mFL_AS_ADDR_2,
							//	Async Side 3
							mFL_AS_DATA_3,mFL_AS_ADDR_3,
							//	Control Signals
							mFL_Select,CLOCK_50,KEY[0],
							//	Flash Interface
							FL_DQ,FL_ADDR,FL_WE_N,FL_CE_N,FL_OE_N,FL_RST_N);

Multi_Sdram			u3	(	//	Host Side
							mSD2RS_DATA,mRS2SD_DATA,mSD_ADDR,mSD_RD,mSD_WR,mSD_Done,
							//	Async Side 1
							mSDR_AS_DATAOUT_1,mSDR_AS_DATAIN_1,mSDR_AS_ADDR_1,mSDR_AS_WR_n_1,
							//	Async Side 2
							mSDR_AS_DATAOUT_2,mSDR_AS_DATAIN_2,mSDR_AS_ADDR_2,mSDR_AS_WR_n_2,
							//	Async Side 3
							mSDR_AS_DATAOUT_3,mSDR_AS_DATAIN_3,mSDR_AS_ADDR_3,mSDR_AS_WR_n_3,
							//	Control Signals
							mSDR_Select,CLOCK_50,KEY[0],
							//	SDRAM Interface
        					DRAM_ADDR,{DRAM_BA_1,DRAM_BA_0},DRAM_CS_N,DRAM_CKE,DRAM_RAS_N,
							DRAM_CAS_N,DRAM_WE_N,DRAM_DQ,{DRAM_UDQM,DRAM_LDQM},DRAM_CLK);

ps2_keyboard		u4	(	.clk(CLOCK_50),.reset(~KEY[0]),
							.ps2_clk_i(PS2_CLK),.ps2_data_i(PS2_DAT),
							.rx_ascii(PS2_ASCII),.rx_data_ready(PS2_Ready),
							.rx_read(PS2_Ready)	);

CMD_Decode			u5	(	//	USB JTAG
							.iRXD_DATA(mRXD_DATA),.iRXD_Ready(mRXD_Ready),
						 	.oTXD_DATA(mTXD_DATA),.oTXD_Start(mTXD_Start),.iTXD_Done(mTXD_Done),
						 	//	FLASH
							.iFL_DATA(mFL2RS_DATA),.oFL_DATA(mRS2FL_DATA),
						 	.oFL_ADDR(mFL_ADDR),.iFL_Ready(mFL_Ready),
						 	.oFL_Start(mFL_Start),.oFL_CMD(mFL_CMD),
							//	SDRAM
							.iSDR_DATA(mSD2RS_DATA),.oSDR_DATA(mRS2SD_DATA),
							.oSDR_ADDR(mSD_ADDR),.iSDR_Done(mSD_Done),
							.oSDR_WR(mSD_WR),.oSDR_RD(mSD_RD),
							//	SRAM
							.iSR_DATA(mSR2RS_DATA),.oSR_DATA(mRS2SR_DATA),
							.oSR_ADDR(mSR_ADDR),
							.oSR_WE_N(mSR_WE),.oSR_OE_N(mSR_OE),
						 	//	LED + SEG7
							.oLED_GREEN(LEDG),.oLED_RED(LEDR),
							.oSEG7_DIG(mSEG7_DIG),
							//	VGA
							.oCursor_X(mCursor_X),
							.oCursor_Y(mCursor_Y),
							.oCursor_R(mCursor_R),
							.oCursor_G(mCursor_G),
							.oCursor_B(mCursor_B),
							.oOSD_CUR_EN(mOSD_CUR_EN),	
							//	PS2
							.iPS2_ScanCode(PS2_ASCII),.iPS2_Ready(PS2_Ready),
							//	Async Port Select
							.oSDR_Select(mSDR_Select),
							.oFL_Select(mFL_Select),
							.oSR_Select(mSR_Select),
							//	Control
						 	.iCLK(CLOCK_50),.iRST_n(KEY[0])	);

Multi_Sram			u6	(	//	Host Side
							.oHS_DATA(mSR2RS_DATA),.iHS_DATA(mRS2SR_DATA),.iHS_ADDR(mSR_ADDR),
							.iHS_WE_N(mSR_WE),.iHS_OE_N(mSR_OE),
							//	Async Side 1
							.oAS1_DATA(mSRAM_VGA_DATA),.iAS1_ADDR(mVGA_ADDR[19:1]),
							.iAS1_WE_N(1'b1),.iAS1_OE_N(1'b0),
							//	Control Signals
							.iSelect(mSR_Select),.iRST_n(KEY[0]),
							//	SRAM
							.SRAM_DQ(SRAM_DQ),
							.SRAM_ADDR(SRAM_ADDR),
							.SRAM_UB_N(SRAM_UB_N),
							.SRAM_LB_N(SRAM_LB_N),
							.SRAM_WE_N(SRAM_WE_N),
							.SRAM_CE_N(SRAM_CE_N),
							.SRAM_OE_N(SRAM_OE_N)	);

VGA_Audio_PLL 		p1	(	.areset(~DLY_RST),.inclk0(CLOCK_27[0]),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK)	);

VGA_Controller		u8	(	//	Host Side
							.iCursor_RGB_EN({mOSD_CUR_EN[0],3'h7}),
							.iCursor_X(mCursor_X),
							.iCursor_Y(mCursor_Y),
							.iCursor_R(mCursor_R),
							.iCursor_G(mCursor_G),
							.iCursor_B(mCursor_B),							
							.oAddress(mVGA_ADDR),
							.oCoord_X(mVGA_X),
							.oCoord_Y(mVGA_Y),
							.iRed(mVGA_R),
							.iGreen(mVGA_G),
							.iBlue(mVGA_B),
							//	VGA Side
							.oVGA_R(oVGA_R),
							.oVGA_G(oVGA_G),
							.oVGA_B(oVGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST)	);

VGA_OSD_RAM			u9	(	//	Read Out Side
							.oRed(mOSD_R),
							.oGreen(mOSD_G),
							.oBlue(mOSD_B),
							.iVGA_ADDR(mVGA_ADDR),
							.iVGA_X(mVGA_X),
							.iVGA_Y(mVGA_Y),
							.iVGA_CLK(VGA_CTRL_CLK),
							//	CLUT
							.iON_R(1023),
							.iON_G(1023),
							.iON_B(1023),
							.iOFF_R(0),
							.iOFF_G(0),
							.iOFF_B(512),
							//	Control Signals
							.iRST_N(KEY[0])	);

I2C_AV_Config 		u10	(	//	Host Side
							.iCLK(CLOCK_50),
							.iRST_N(KEY[0]),
							//	I2C Side
							.I2C_SCLK(I2C_SCLK),
							.I2C_SDAT(I2C_SDAT)	);

AUDIO_DAC 			u11	(	//	Memory Side
							.oFLASH_ADDR(mFL_AS_ADDR_1),
							.iFLASH_DATA(mFL_AS_DATA_1),
							//	Audio Side
							.oAUD_BCK(AUD_BCLK),
							.oAUD_DATA(AUD_DACDAT),
							.oAUD_LRCK(AUD_DACLRCK),
							//	Control Signals
							.iSrc_Select(SW[1:0]),
				            .iCLK_18_4(AUD_CTRL_CLK),
							.iRST_N(DLY_RST)	);

endmodule