//Jun.30.2004 blez bgtz bug fix
//Jul.7.2004 int bug fix
//Jul.11.2004 bgezQ,bltzQ
//Apr.2.2005 Change Port Address, change uart interface port
//Apr.3.2005 bgtz bug fix
`include "define.h"
`ifdef RTL_SIMULATION
module yacc(clock,Async_Reset,MemoryWData,MWriteFF,data_port_address,
	   RXD,TXD);
	input clock;
	input Async_Reset;
	output [31:0] MemoryWData;
	output [15:0] data_port_address;




	output MWriteFF;
	input RXD;
	output TXD;
`else

module yacc(clock,Async_Reset,	   RXD,TXD);
	input clock;
	input Async_Reset;
	input RXD;
	output TXD;

`endif

	wire [31:0] MOUT,IRD1;
	
	wire RegWriteD2;
	wire [1:0] A_Right_SELD1;
	wire [1:0] RF_inputD2;
	wire M_signD1,M_signD2;
	wire [1:0] M_access_modeD1,M_access_modeD2;
	wire [3:0] ALU_FuncD2;
	wire [1:0] Shift_FuncD2;
	wire [25:0] IMMD2,IMMD1;
	wire [4:0] source_addrD2,target_addrD2;
	wire [4:0] source_addrD1,target_addrD1,Shift_amountD2;
	wire [4:0] RF_input_addr;
	wire [2:0] PC_commandD1;
	wire [7:0] uread_port;
	wire takenD2;//
	
`ifdef RAM4K
	wire [11:0] DAddress;//
	wire [11:0] PC;
	reg [11:0] int_address;//interim
	reg [11:0] PCD1,PCD2;
	reg [15:0] IRD2;
	reg [11:0] DAddrD;
	wire [11:0] PCCDD;
`else	
	wire [25:0] PC;
	wire [25:0] DAddress;//
	reg [25:0] int_address;//interim
	reg [25:0] PCD1,PCD2;
	reg [25:0] IRD2;
	reg [25:0] DAddrD;
	wire [25:0] PCCDD;
`endif

	wire [31:0] memory_indata;//
	wire memory_sign;
	wire [1:0] memory_access_mode;

	wire [31:0] ea_reg_out;
	wire [31:0] regfile_indata,regfile_indata_temp;//
	wire reg_compare;
	wire beqQ,bneQ,blezQ,bgtzQ;
	wire [25:0] IMM;
	wire clear_int;
	wire jumpQ,branchQQ;
	wire [31:0] memory_wdata;
	wire [31:0] alu_source,alu_target;
	wire [1:0] RRegSelD1;
	wire A_Left_SELD1;
	wire [1:0] mul_alu_selD2;
	wire [3:0] mul_div_funcD2;
//registers
	reg sync_reset;
	wire [31:0] forward_source_reg,forward_target_reg;
//	reg [31:0] MOUT_ff;
	reg takenD3;
	reg int_req;
	

	reg beqQQ,bneQQ,blezQQ,bgtzQQ;
	reg bgezQQ,bltzQQ;
	reg MWriteFF;
	wire MWriteD2,MWriteD1;
	reg [31:0] MemoryWData;
	wire NOP_Signal;
	
	wire [7:0] control_state;
	wire [15:0] data_port_address=DAddrD;
	wire [3:0] mult_func;
	wire pause_out;
	wire Shift_Amount_selD2;
	wire source_zero;//Jun.30.2004
	wire int_req_uport;
	wire uart_write_req;
	wire uart_write_done,uart_write_busy;
	wire int_stateD1;
	wire bgezQ,bltzQ;

decoder d1(.clock(clock),.sync_reset(sync_reset),.MWriteD1(MWriteD1),
	    .RegWriteD2(RegWriteD2),.A_Right_SELD1(A_Right_SELD1),.RF_inputD2(RF_inputD2),
	    .RF_input_addr(RF_input_addr),.M_signD1( M_signD1),.M_signD2(M_signD2),
	    .M_access_modeD1(M_access_modeD1),.M_access_modeD2(M_access_modeD2),
	    .ALU_FuncD2(ALU_FuncD2),.Shift_FuncD2(Shift_FuncD2),
	    .source_addrD1(source_addrD1),.target_addrD1(target_addrD1),.IMMD2(IMMD2),
	    .source_addrD2(source_addrD2),.target_addrD2(target_addrD2),
	    .Shift_amountD2(Shift_amountD2),.PC_commandD1(PC_commandD1),.IMMD1(IMMD1),.IRD1(IRD1),.takenD3(takenD3),.takenD2(takenD2),.beqQ(beqQ),.bneQ(bneQ),.blezQ(blezQ),.bgtzQ(bgtzQ),
	    .DAddress(DAddress),.PC(PC),.memory_indata(memory_indata),.MOUT(MOUT),.IMM(IMM),
	    .branchQQ(branchQQ),.jumpQ(jumpQ),.int_req(int_req),.clear_int(clear_int),
	    .int_address(int_address),.A_Left_SELD1(A_Left_SELD1),.RRegSelD1(RRegSelD1),
	    .MWriteD2(MWriteD2),.NOP_Signal(NOP_Signal),.mul_alu_selD2(mul_alu_selD2),
	    .mul_div_funcD2(mul_div_funcD2),.pause_out(pause_out),.control_state(control_state),
	    .Shift_Amount_selD2(Shift_Amount_selD2),
	    .uread_port(uread_port),.int_stateD1(int_stateD1),.bgezQ(bgezQ),.bltzQ(bltzQ),.write_busy(uart_write_busy));



pc_module pc1(.clock(clock),.sync_reset(sync_reset),.pc_commandD1(PC_commandD1),.PCC(PC),
	       .imm(IMM),.ea_reg_source(alu_source),.takenD2(takenD2),.takenD3(takenD3),
	       .branchQQ(branchQQ),.jumpQ(jumpQ),.NOP_Signal(NOP_Signal),
		 .control_state(control_state),.IMMD1(IMMD1),.PCCDD(PCCDD));



Pipelined_RegFile pipe(.clock(clock),.sync_reset(sync_reset),
	.dest_addrD2(RF_input_addr),.source_addr(IMM[25:21]),.target_addr(IMM[20:16]),
	.wren(RegWriteD2),.memory_wdata(memory_wdata),
      .A_Right_SELD1(A_Right_SELD1),.A_Left_SELD1(A_Left_SELD1),.PCD1(PCD1),
	.IMMD1(IMMD1[15:0]),.ALU_FuncD2(ALU_FuncD2),.Shift_FuncD2(Shift_FuncD2),
	.Shift_amountD2(Shift_amountD2),.RRegSelD1(RRegSelD1),.MOUT(MOUT),
	.RF_inputD2(RF_inputD2),.alu_source(alu_source),.alu_target(alu_target),
	.MWriteD2(MWriteD2),.MWriteD1(MWriteD1),.mul_alu_selD2(mul_alu_selD2),
	.mul_div_funcD2(mul_div_funcD2),.pause_out(pause_out),
	.Shift_Amount_selD2(Shift_Amount_selD2),.int_stateD1(int_stateD1),.PCCDD(PCCDD));

//sync_reset
	always @(posedge clock , negedge Async_Reset) begin
		if (!Async_Reset) sync_reset <=1'b1;
		else  sync_reset <=!Async_Reset;
	end


//PCD1,PCD2
	always @(posedge clock) begin
	//	if (sync_reset) PCD1<=26'h000_0000;
	/*	else*/	PCD1 <=PC+4;
	end

	always @(posedge clock) begin
		PCD2 <=PCD1;
	end

//
	always @(posedge clock) begin
	IRD2 <=IRD1;
	end
	
	always @(posedge clock) begin
		if (sync_reset) MWriteFF<=1'b0;
		else	MWriteFF <=MWriteD2;
	end

	assign memory_access_mode=M_access_modeD1;
	assign memory_sign=M_signD1;
	
	assign DAddress=alu_source[25:0]+{ {6{IRD2[15]}},IRD2[15:0]};

//
	always @(posedge clock) begin
	DAddrD <=DAddress;
	end
//
always @(posedge clock) begin
	MemoryWData <=memory_wdata;
	end

	assign memory_indata=memory_wdata;


     

	assign reg_compare=( alu_source==alu_target);
	


	always @(posedge clock) begin
	   if (!NOP_Signal) begin//Jun.29.2004
			      beqQQ<=beqQ;
                        bneQQ<=bneQ;
                        bgtzQQ<=bgtzQ;
                        blezQQ<=blezQ;
			      bgezQQ<=bgezQ;//Jul.11.2004
                        bltzQQ<=bltzQ;//Jul.11.2004
		end
	end

	always @( beqQQ ,bneQQ,bgtzQQ,blezQQ,bgezQQ,bltzQQ,reg_compare,alu_source) begin//Jul.11.2004
		takenD3=	( beqQQ   && reg_compare) ||
              			( bneQQ   && !reg_compare) ||
               			( bgtzQQ  && !alu_source[31] && !reg_compare) || //Apr.3.2005 bug fix $s >0 Jun.30.2004
              			( blezQQ  && (alu_source[31]  || reg_compare )) ||
				      ( bgezQQ  && (!alu_source[31] || reg_compare )) || //Jul.11.2004 
				      ( bltzQQ  && (alu_source[31]  )); //Jul.11.2004//$s <0=Jun.30.2004
	end
	 




	uart_read  uread( .sync_reset(sync_reset),.clk(clock), .rxd(RXD),
	.buffer_reg(uread_port),.int_req(int_req_uport));

	uart_write uwite( .sync_reset(sync_reset), .clk(clock), .txd(TXD),.data_in(MemoryWData[7:0]) ,
	.write_request(uart_write_req),.write_done(uart_write_done),.write_busy(uart_write_busy));

`ifdef RAM4K
	assign uart_write_req= DAddrD[11:0]==12'hfff && MWriteFF;//`UART_WRITE_PORT_ADDRESS ;
	always @ (posedge clock) begin
		if (sync_reset) int_address<=0;
		else if (DAddrD[11:0]==12'h0ff8 & MWriteFF) int_address<=MemoryWData;
	end
`endif

`ifdef RAM16K
	assign uart_write_req= DAddrD==`UART_PORT_ADDRESS && MWriteFF  ;//`UART_WRITE_PORT_ADDRESS ;
      always @ (posedge clock) begin
		if (sync_reset) int_address<=0;
		else if (DAddrD==`INTERUPPT_ADDRESS & MWriteFF) int_address<=MemoryWData;
	end
`endif

`ifdef RAM32K
	assign uart_write_req= DAddrD[15:0]==16'h07fff && MWriteFF ;//`UART_WRITE_PORT_ADDRESS ;
     always @ (posedge clock) begin
		if (sync_reset) int_address<=0;
		else if (DAddrD==16'h7ff8 & MWriteFF) int_address<=MemoryWData;
	end
`endif

//state machine
//latch with one shot pulse 
//clear by clear_int
	always @(posedge clock) begin
		if (sync_reset) int_req <=1'b0;
		else if (clear_int) int_req <=1'b0;// assume one shot(1clk) pulse
		else if ( int_req_uport) int_req<=1'b1;//			
	end

endmodule


