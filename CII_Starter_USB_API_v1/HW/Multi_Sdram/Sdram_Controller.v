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

module Sdram_Controller(
		//	HOST
        REF_CLK,
        RESET_N,
        ADDR,
		WR,
		RD,
		LENGTH,
		ACT,
		DONE,
        DATAIN,
        DATAOUT,
		IN_REQ,
		OUT_VALID,
        DM,
		//	SDRAM
        SA,
        BA,
        CS_N,
        CKE,
        RAS_N,
        CAS_N,
        WE_N,
        DQ,
        DQM,
		SDR_CLK
        );


`include        "Sdram_Params.h"
input                           REF_CLK;                //System Clock
input                           RESET_N;                //System Reset
input   [`ASIZE-1:0]            ADDR;                   //Address for controller requests
input							WR;						//Write Request
input							RD;						//Read Request
input	[7:0]					LENGTH;					//Request Data length
output							ACT;					//SDRAM ACT
output 							DONE;					//Write/Read Done
input   [`DSIZE-1:0]            DATAIN;                 //Data input
output  [`DSIZE-1:0]            DATAOUT;                //Data output
input   [`DSIZE/8-1:0]          DM;                     //Data mask input
output  [11:0]                  SA;                     //SDRAM address output
output  [1:0]                   BA;                     //SDRAM bank address
output  [1:0]                   CS_N;                   //SDRAM Chip Selects
output                          CKE;                    //SDRAM clock enable
output                          RAS_N;                  //SDRAM Row address Strobe
output                          CAS_N;                  //SDRAM Column address Strobe
output                          WE_N;                   //SDRAM write enable
inout   [`DSIZE-1:0]            DQ;                     //SDRAM data bus
output  [`DSIZE/8-1:0]          DQM;                    //SDRAM data mask lines
output							OUT_VALID;				//Output data valid
output							IN_REQ;					//Input	data request
output							SDR_CLK;				//SDRAM Clock

reg  	[`DSIZE/8-1:0]          DQM;                    //SDRAM data mask lines
reg     [11:0]                  SA;                     //SDRAM address output
reg     [1:0]                   BA;                     //SDRAM bank address
reg     [1:0]                   CS_N;                   //SDRAM Chip Selects
reg                             CKE;                    //SDRAM clock enable
reg                             RAS_N;                  //SDRAM Row address Strobe
reg                             CAS_N;                  //SDRAM Column address Strobe
reg                             WE_N;                   //SDRAM write enable
reg								OUT_VALID;				//Output data valid
reg								IN_REQ;					//Input	data request			
reg 	[8:0] 					ST;
reg		[1:0] 					CMD;
reg 							DONE;					//Write/Read Done
reg								Pre_RD;
reg								Pre_WR;
reg								PM_STOP;
reg								PM_DONE;
reg								Read;
reg								Write;
reg								Pre_DONE;
reg								mDONE;					 //SDRAM Internal Done

reg     [`DSIZE-1:0]            DATAOUT;                 //Data output
reg     [`DSIZE-1:0]            mDATAOUT;                 //Data output
wire    [`DSIZE-1:0]            DQOUT;
wire  	[`DSIZE/8-1:0]          IDQM;                    //SDRAM data mask lines

wire    [11:0]                  ISA;                     //SDRAM address output
wire    [1:0]                   IBA;                     //SDRAM bank address
wire    [1:0]                   ICS_N;                   //SDRAM Chip Selects
wire                            ICKE;                    //SDRAM clock enable
wire                            IRAS_N;                  //SDRAM Row address Strobe
wire                            ICAS_N;                  //SDRAM Column address Strobe
wire                            IWE_N;                   //SDRAM write enable
wire                          	CMDACK;                 //Controller command acknowledgement

wire    [`ASIZE-1:0]            saddr;
wire                            load_mode;
wire                            nop;
wire                            reada;
wire                            writea;
wire                            refresh;
wire                            precharge;
wire                            oe;
wire							ref_ack;
wire							ref_req;
wire							init_req;
wire							cm_ack;
wire                            CLK;

PLL1 sdram_pll1	(
				.inclk0(REF_CLK),
				.c0(CLK),
				.c2(SDR_CLK)
				);

control_interface control1 (
                .CLK(CLK),
                .RESET_N(RESET_N),
                .CMD(CMD),
                .ADDR(ADDR),
                .REF_ACK(ref_ack),
                .CM_ACK(cm_ack),
                .NOP(nop),
                .READA(reada),
                .WRITEA(writea),
                .REFRESH(refresh),
                .PRECHARGE(precharge),
                .LOAD_MODE(load_mode),
                .SADDR(saddr),
                .REF_REQ(ref_req),
				.INIT_REQ(init_req),
                .CMD_ACK(CMDACK)
                );

command command1(
                .CLK(CLK),
                .RESET_N(RESET_N),
                .SADDR(saddr),
                .NOP(nop),
                .READA(reada),
                .WRITEA(writea),
                .REFRESH(refresh),
				.LOAD_MODE(load_mode),
                .PRECHARGE(precharge),
                .REF_REQ(ref_req),
				.INIT_REQ(init_req),
                .REF_ACK(ref_ack),
                .CM_ACK(cm_ack),
                .OE(oe),
				.PM_STOP(PM_STOP),
				.PM_DONE(PM_DONE),
                .SA(ISA),
                .BA(IBA),
                .CS_N(ICS_N),
                .CKE(ICKE),
                .RAS_N(IRAS_N),
                .CAS_N(ICAS_N),
                .WE_N(IWE_N)
                );
                
sdr_data_path data_path1(
                .CLK(CLK),
                .RESET_N(RESET_N),
                .DATAIN(DATAIN),
                .DM(DM),
                .DQOUT(DQOUT),
                .DQM(IDQM)
                );

always @(posedge CLK)
begin
	SA      <= (ST==SC_CL+LENGTH)			?	12'h200	:	ISA;
    BA      <= IBA;
    CS_N    <= ICS_N;
    CKE     <= ICKE;
    RAS_N   <= (ST==SC_CL+LENGTH)			?	1'b0	:	IRAS_N;
    CAS_N   <= (ST==SC_CL+LENGTH)			?	1'b1	:	ICAS_N;
    WE_N    <= (ST==SC_CL+LENGTH)			?	1'b0	:	IWE_N;
	PM_STOP	<= (ST==SC_CL+LENGTH)			?	1'b1	:	1'b0;
	PM_DONE	<= (ST==SC_CL+SC_RCD+LENGTH+2)	?	1'b1	:	1'b0;
	DQM		<= ( ACT && (ST>=SC_CL) )	?	(	((ST==SC_CL+LENGTH) && Write)?	2'b11	:	2'b00	)	:	2'b11	;
	mDATAOUT<= DQ;
end

assign  DQ = oe ? DQOUT : `DSIZE'hzzzz;
assign	ACT	=	Read | Write;

always@(posedge CLK or negedge RESET_N)
begin
	if(RESET_N==0)
	begin
		CMD			<=  0;
		mDONE		<=  0;
		ST			<=  0;
		Pre_RD		<=  0;
		Pre_WR		<=  0;
		Read		<=	0;
		Write		<=	0;
		OUT_VALID	<=	0;
		IN_REQ		<=	0;
	end
	else
	begin
		Pre_RD	<=	RD;
		Pre_WR	<=	WR;
		case(ST)
		0:	begin
				if({Pre_RD,RD}==2'b01)
				begin
					Read	<=	1;
					Write	<=	0;
					CMD		<=	2'b01;
					ST		<=	1;
				end
				else if({Pre_WR,WR}==2'b01)
				begin
					Read	<=	0;
					Write	<=	1;
					CMD		<=	2'b10;
					ST		<=	1;
				end
			end
		1:	begin
				if(CMDACK==1)
				begin
					CMD<=2'b00;
					ST<=2;
				end
			end
		default:	ST<=ST+1;
		endcase
	
		if(ST==SC_CL+SC_RCD+2)
		mDONE	<=	1;
		else if(ST==SC_CL+SC_RCD+LENGTH+2)
		ST		<=	0;

		if(Read)
		begin
			if(ST==SC_CL+SC_RCD+2)
			OUT_VALID	<=	1;
			else if(ST==SC_CL+SC_RCD+LENGTH+2)
			begin
				OUT_VALID	<=	0;
				Read		<=	0;
			end
		end
		
		if(Write)
		begin
			if(ST==SC_CL-1)
			IN_REQ	<=	1;
			else if(ST==SC_CL+LENGTH-1)
			begin
				IN_REQ	<=	0;
				Write	<=	0;
			end
		end

		if(!WR && !RD)
		mDONE<=0;

	end
end

always@(posedge REF_CLK or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		DONE	<=	0;
		Pre_DONE<=	0;
		DATAOUT	<=	0;
	end
	else
	begin
		Pre_DONE	<=	mDONE;
		if({Pre_DONE,mDONE}==2'b01)
		DONE	<=	1;
		if(!WR && !RD)
		DONE	<=	0;
		if(RD)
		DATAOUT	<=	mDATAOUT;
	end
end

endmodule
