`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/

//---------------------------------------------------------------------------
module THEIA
(

input wire                    CLK_I,	//Input clock
input wire                    RST_I,	//Input reset
//Theia Interfaces
input wire                    MST_I,	//Master signal, THEIA enters configuration mode
                                       //when this gets asserted (see documentation)
//Wish Bone Interface
input wire [`WB_WIDTH-1:0]    DAT_I,	//Input data bus  (Wishbone)
input wire                    ACK_I,	//Input ack
output wire                   ACK_O,	//Output ack
input wire [`WB_WIDTH-1:0]    ADR_I,	//Input address
input wire                    WE_I,    //Input write enable
input wire                    STB_I,	//Strobe signal, see wishbone documentation
input wire                    CYC_I,   //Bus cycle signal, see wishbone documentation
input wire [1:0]              TGA_I,   //Input address tag, see THEAI documentation
input wire [`MAX_CORES-1:0]  	SEL_I,	//The WishBone Master uses this signal to configure a specific core (TBD, not sure is needed)
input wire [`MAX_CORES-1:0]   RENDREN_I,

input wire [`MAX_CORE_BITS-1:0]      OMBSEL_I,  //Output memory bank select
input wire [`WB_WIDTH-1:0]           OMADR_I,  //Output adress (relative to current bank)
output wire [`WB_WIDTH-1:0]          OMEM_O,	 //Output data bus (Wishbone)

input wire [`WB_WIDTH-1:0]           TMDAT_I,
input wire [`WB_WIDTH-1:0]           TMADR_I,
input wire                           TMWE_I,
input wire [`MAX_TMEM_BANKS-1:0]     TMSEL_I,
//Control Register
input wire [15:0]		         CREG_I,
output wire                   HDL_O,
input wire                    STDONE_I,
input wire                    HDA_I,
input wire                    HDLACK_I,
output wire                   RCOMMIT_O,
output wire                   DONE_O

);




wire [`MAX_TMEM_BANKS-1:0] wTMemWriteEnable;
SELECT_1_TO_N # ( `MAX_TMEM_BANKS, `MAX_TMEM_BANKS ) TMWE_SEL
			(
			.Sel(TMSEL_I),
			.En(TMWE_I),
			.O(wTMemWriteEnable)
			);


wire [`MAX_CORES-1:0] wDone;
wire [`MAX_CORES-1:0] wBusGranted,wBusRequest;
//wire [`WB_WIDTH-1:0]  wDAT_O[`MAX_CORES-1:0];
//wire [`WB_WIDTH-1:0]  wADR_O[`MAX_CORES-1:0];
//wire [1:0] wTGA_O[`MAX_CORES-1:0];
wire [`MAX_CORE_BITS-1:0] wBusSelect;


//wire [`MAX_CORES-1:0] wSTB_O;
//wire [`MAX_CORES-1:0] wWE_O;
wire [`MAX_CORES-1:0]wACK_O;


wire wOMem_WE[`MAX_CORES-1:0];
wire [`WB_WIDTH-1:0] wOMEM_Address[`MAX_CORES-1:0];
wire [`WB_WIDTH-1:0] wOMEM_Dat[`MAX_CORES-1:0];

wire [`MAX_CORES-1:0]   wSTB_I;
wire [`MAX_CORES-1:0]   wMST_I;
wire [`MAX_CORES-1:0]   wACK_I;
wire [`MAX_CORES-1:0]   wCYC_I;
wire [1:0]              wTGA_I[`MAX_CORES-1:0];



wire [`WB_WIDTH-1:0]  wTMEM_Data; 
wire [`WB_WIDTH-1:0]  wTMEM_Address[`MAX_CORES-1:0]; 
wire [`WB_WIDTH-1:0]  wTMEM_ReadAddr;
wire [`MAX_CORES-1:0] wTMEM_Resquest;
wire [`MAX_CORES-1:0] wTMEM_Granted;



//CROSS-BAR cables



wire [`WB_WIDTH-1:0]     wCrossBarDataRow[`MAX_TMEM_BANKS-1:0];			//Horizontal grid Buses comming from each bank 
wire [`WB_WIDTH-1:0]     wCrossBarDataCollumn[`MAX_CORES-1:0];          //Vertical grid buses comming from each core.
wire [`WB_WIDTH-1:0]     wTMemReadAdr[`MAX_CORES-1:0];					   //Horizontal grid Buses comming from each core (virtual addr).
wire [`WB_WIDTH-1:0]     wCrossBarAdressCollumn[`MAX_CORES-1:0];			//Vertical grid buses comming from each core. (physical addr).
wire [`WB_WIDTH-1:0]     wCrossBarAddressRow[`MAX_TMEM_BANKS-1:0];		//Horizontal grid Buses comming from each bank.

wire 						    wCORE_2_TMEM__Req[`MAX_CORES-1:0];
wire [`MAX_TMEM_BANKS -1:0]    wBankReadRequest[`MAX_CORES-1:0];    


wire [`MAX_CORES-1:0]         wBankReadGranted[`MAX_TMEM_BANKS-1:0];    
wire                           wTMEM_2_Core__Grant[`MAX_CORES-1:0];

wire[`MAX_CORE_BITS-1:0] wCurrentCoreSelected[`MAX_TMEM_BANKS-1:0];
wire[`WIDTH-1:0]                wCoreBankSelect[`MAX_CORES-1:0];
wire [`MAX_CORES-1:0] wHDL_O;


wire [`MAX_CORES-1:0] wHostDataLatched;
wire [`MAX_CORES-1:0] wRCOMMIT_O;
wire [`MAX_CORES-1:0] wRCommited;


assign RCOMMIT_O = wRCommited[0] & wRCommited[1] & wRCommited[2] & wRCommited[3];
assign HDL_O = wHostDataLatched[0] &  wHostDataLatched[1] &  wHostDataLatched[2] &  wHostDataLatched[3];
assign DONE_O = wDone[0] & wDone[1] & wDone[2] & wDone[3];



//----------------------------------------------------------------	

	Module_BusArbitrer ARB1
	(
	.Clock( CLK_I ),
	.Reset( RST_I ),
	.iRequest( wBusRequest ),
	.oGrant(   wBusGranted ),
	.oBusSelect( wBusSelect )
	
	);
//----------------------------------------------------------------

  wire  wMaskedACK_O;
  assign wMaskedACK_O = (SEL_I & wACK_O) ? 1'b1 : 1'b0;
  assign ACK_O =  ( MST_I ) ? wMaskedACK_O  : wACK_O[ wBusSelect];	
   	

 wire [`WB_WIDTH-1:0] wDataOut[`MAX_CORES-1:0];
 assign OMEM_O = wDataOut[ OMBSEL_I ];
  
  genvar i;
  generate
	for (i = 0; i < `MAX_CORES; i = i +1)
	begin : CORE
		assign wMST_I[i] = (SEL_I[i]) ? MST_I : 0;
		assign wSTB_I[i] = (SEL_I[i]) ? STB_I : 0;
		assign wCYC_I[i] = (SEL_I[i]) ? CYC_I : 0;
		assign wTGA_I[i] = (SEL_I[i]) ? TGA_I : 0;

		
		THEIACORE CTHEIA 
		(
		.CLK_I( CLK_I ), 
		.RST_I( RST_I ),
		.RENDREN_I( RENDREN_I[i] ),
		
		//Slave signals
		.ADR_I( ADR_I ),		
		.WE_I(  WE_I  ),
		.STB_I(  wSTB_I[i] ),
		.ACK_I( ACK_I ),
		.CYC_I( wCYC_I[i] ),
		.MST_I( wMST_I[i] ),
		.TGA_I( wTGA_I[i] ),
		.CREG_I( CREG_I ),
		
		//Master Signals
		.ACK_O( 	wACK_O[i] ),
		.CYC_O(  wBusRequest[i] ),
		.GNT_I( 	wBusGranted[i] ),
		`ifdef DEBUG
		.iDebug_CoreID( i ),
		`endif
		
		.OMEM_WE_O( wOMem_WE[i] ),
		.OMEM_ADR_O( wOMEM_Address[i] ),
		.OMEM_DAT_O( wOMEM_Dat[i] ),
		
		.TMEM_DAT_I( wCrossBarDataCollumn[i]    ), 
		.TMEM_ADR_O( wTMemReadAdr[i]  ),
		.TMEM_CYC_O( wCORE_2_TMEM__Req[i]       ),
		.TMEM_GNT_I( wTMEM_2_Core__Grant[i]     ),
		
		.HDA_I(     HDA_I ),                            //Host data available
		.HDL_O( wHDL_O[i] ),                            //Host data Latched
		.HDLACK_I( ~HDL_O ),                          //Host data Latched ACK
		.STDONE_I( STDONE_I ),
		.RCOMMIT_O( wRCOMMIT_O[i] ),
		
		
		//Other
		.DAT_I( DAT_I ),
		.DONE_O( wDone[i] )

	);
	
	UPCOUNTER_POSEDGE # (1) UP_RCOMMIT
	(
	.Clock(  CLK_I ),
	.Reset( RST_I | HDLACK_I ),	
	.Initial( 1'b0 ),
	.Enable( wRCOMMIT_O[i] ),
	.Q(wRCommited[i])
	);
	
	UPCOUNTER_POSEDGE # (1) UP_GREADY
	(
	.Clock(  CLK_I ),
	.Reset( RST_I | HDLACK_I ),	
	.Initial( 1'b0 ),
	.Enable( wHDL_O[i] ),
	.Q(wHostDataLatched[i])
	);

	RAM_SINGLE_READ_PORT # ( `WB_WIDTH, `WB_WIDTH, 250000 ) OMEM //500000 ) OMEM 
(
	.Clock(         CLK_I                ),
	.iWriteEnable(  wOMem_WE[i]          ),
	.iWriteAddress( wOMEM_Address[i]     ),
	.iDataIn(       wOMEM_Dat[i]         ),
	.iReadAddress0( OMADR_I              ),
	.oDataOut0(     wDataOut[i]          )
	
);


//If there are "n" banks, memory location "X" would reside in bank number X mod n.
//X mod 2^n == X & (2^n - 1)
assign wCoreBankSelect[i] = (wTMemReadAdr[i] & (`MAX_TMEM_BANKS-1));

//Each core has 1 bank request slot
//Each slot has MAX_TMEM_BANKS bits. Only 1 bit can
//be 1 at any given point in time. All bits zero means,
//we are not requesting to read from any memory bank.
SELECT_1_TO_N # ( `WIDTH, `MAX_CORES ) READDRQ
			(
			.Sel(wCoreBankSelect[ i]),
			.En(wCORE_2_TMEM__Req[i]),
			.O(wBankReadRequest[i])
			);

//The address coming from the core is  virtual adress, meaning it assumes linear
//address space, however, since memory is interleaved in a n-way memory we transform
//virtual adress into physical adress (relative to the bank) like this
//fadr = vadr / n = vadr >> log2(n)

assign wCrossBarAdressCollumn[i] = (wTMemReadAdr[i] >> `MAX_CORE_BITS);

//Connect the granted signal to Arbiter of the Bank we want to read from	
assign wTMEM_2_Core__Grant[i] = wBankReadGranted[wCoreBankSelect[i]][i];

//Connect the request signal to Arbiter of the Bank we want to read from	
//assign wBankReadRequest[wCoreBankSelect[i]][i] = wCORE_2_TMEM__Req[i];

	end
  endgenerate
  
  
////////////// CROSS-BAR INTERCONECTION//////////////////////////

genvar Core,Bank;
generate
for (Bank = 0; Bank < `MAX_TMEM_BANKS; Bank = Bank + 1)
begin : BANK

	//The memory bank itself
RAM_SINGLE_READ_PORT	 # ( `WB_WIDTH, `WB_WIDTH, 50000 ) TMEM 
	(
	.Clock(         CLK_I                			),
	.iWriteEnable(  wTMemWriteEnable[Bank]       ),
	.iWriteAddress( TMADR_I                      ),
	.iDataIn(       TMDAT_I                      ),
	.iReadAddress0( wCrossBarAddressRow[Bank]    ),	//Connect to the Row of the grid
	.oDataOut0(     wCrossBarDataRow[Bank]   		)  //Connect to the Row of the grid
	
	);
	
	//Arbiter will Round-Robin Cores attempting to read from the same Bank
	//at a given point in time
wire [`MAX_CORES-1:0]         wBankReadGrantedDelay[`MAX_TMEM_BANKS-1:0]; 
	Module_BusArbitrer ARB_TMEM
	(
	.Clock( CLK_I ),
	.Reset( RST_I ), 
	.iRequest( {wBankReadRequest[3][Bank],wBankReadRequest[2][Bank],wBankReadRequest[1][Bank],wBankReadRequest[0][Bank]}),
	.oGrant(   wBankReadGrantedDelay[Bank]  ),  //The bit of the core granted to read from this Bank
	.oBusSelect( wCurrentCoreSelected[Bank] )			//The index of the core granted to read from this Bank
	
	);
	
	FFD_POSEDGE_SYNCRONOUS_RESET # ( `MAX_CORES ) FFD_GNT
(
	.Clock(CLK_I),
	.Reset(RST_I),
	.Enable( 1'b1 ),
	.D(wBankReadGrantedDelay[Bank]),
	.Q(wBankReadGranted[Bank])
);

	
	//Create the Cross-Bar interconnection grid now, rows are coonected to the memory banks,
	//while collumns are connected to the cores, 2 or more cores can not read from the same
	//bank at any given point in time
	for (Core = 0; Core < `MAX_CORES; Core = Core + 1)
	begin: CORE_CONNECT
		//Connect the Data Collum of this core to the Data Row of current bank, only if the Core is looking for data stored in this bank
		assign wCrossBarDataCollumn[ Core ] = ( wCoreBankSelect[ Core ] == Bank ) ? wCrossBarDataRow[ Bank ] : `WB_WIDTH'bz;	
		//Connect the Address Row of this Bank to the Address Column of the core, only if the Arbiter selected this core for reading
		assign wCrossBarAddressRow[ Bank ] = ( wCurrentCoreSelected[ Bank ] == Core ) ? wCrossBarAdressCollumn[Core]: `WB_WIDTH'bz;
	
	end	
	
end
endgenerate

////////////// CROSS-BAR INTERCONECTION//////////////////////////
//----------------------------------------------------------------

endmodule
//---------------------------------------------------------------------------
