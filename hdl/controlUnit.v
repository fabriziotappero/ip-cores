////////////////////////////////////////////////////////////////////////////////////////////////
////                                                              							////
////                                                              							////
////  	This file is part of the project                 									////
////	"instruction_list_pipelined_processor_with_peripherals"								////
////                                                              							////
////  http://opencores.org/project,instruction_list_pipelined_processor_with_peripherals	////
////                                                              							////
////                                                              							////
//// 				 Author:                                                  				////
////      			- Mahesh Sukhdeo Palve													////
////																						////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////																						////
//// 											                 							////
////                                                              							////
//// 					This source file may be used and distributed without         		////
//// 					restriction provided that this copyright statement is not    		////
//// 					removed from the file and that any derivative work contains  		////
//// 					the original copyright notice and the associated disclaimer. 		////
////                                                              							////
//// 					This source file is free software; you can redistribute it   		////
//// 					and/or modify it under the terms of the GNU Lesser General   		////
//// 					Public License as published by the Free Software Foundation; 		////
////					either version 2.1 of the License, or (at your option) any   		////
//// 					later version.                                               		////
////                                                             							////
//// 					This source is distributed in the hope that it will be       		////
//// 					useful, but WITHOUT ANY WARRANTY; without even the implied   		////
//// 					warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      		////
//// 					PURPOSE.  See the GNU Lesser General Public License for more 		////
//// 					details.                                                     		////
////                                                              							////
//// 					You should have received a copy of the GNU Lesser General    		////
//// 					Public License along with this source; if not, download it   		////
//// 					from http://www.opencores.org/lgpl.shtml                     		////
////                                                              							////
////////////////////////////////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "defines.v"


module controlUnit (clk, reset, instOpCode,
							iomemCode,
							accMuxSel, accEn, op2MuxSel, aluEn, aluOpcode,
							bitRamEn, bitRamRw, byteRamEn, byteRamRw,
							outputRw
							
							`ifdef timerAndCounter_peripheral
								, entypeEn, tcAccRead, tcResetEn, tcPresetEn
							`endif
							
							`ifdef UART_peripheral
								, uartRead, uartWrite
							`endif
														
							);
							
	
	input clk, reset;
	input [`instOpCodeLen-1:0] instOpCode;
//	input acc0;
	input [1:0] iomemCode;
	
//	output branch;
	output [`accMuxSelLen-1:0]	accMuxSel;
	output accEn;
	output [`op2MuxSelLen-1:0]	op2MuxSel;
	output aluEn;
	output [`aluOpcodeLen-1:0] aluOpcode;
	output bitRamEn, bitRamRw, byteRamEn, byteRamRw;
	output outputRw;
	
	`ifdef timerAndCounter_peripheral
	output entypeEn, tcAccRead, tcResetEn, tcPresetEn;
	`endif
	
	`ifdef UART_peripheral
	output uartRead, uartWrite;
	`endif
							

//	reg branch;
	reg [`accMuxSelLen-1:0]	accMuxSel;
	reg accEn;
	reg [`op2MuxSelLen-1:0]	op2MuxSel;
	reg aluEn;
	reg [`aluOpcodeLen-1:0] aluOpcode;
	reg bitRamEn, bitRamRw, byteRamEn, byteRamRw;
	reg outputRw;
	
	`ifdef timerAndCounter_peripheral
	reg entypeEn, tcAccRead, tcResetEn, tcPresetEn;
	`endif
	
	`ifdef UART_peripheral
	reg uartRead, uartWrite;
	`endif
							
	
	reg [`cuStateLen-1:0] state;
	
	// control unit FSM states:
	
	parameter	s		= `cuStateLen'b0;
	parameter	sTc	= `cuStateLen'b1;
	parameter	sLd	= `cuStateLen'b10;
	parameter	sSt	= `cuStateLen'b11;
	parameter	sUart	= `cuStateLen'b100;
	parameter	sAlu	= `cuStateLen'b101;
	
	
	
	
	always @ (negedge clk)
	begin
	
	
		if (reset)
		begin
			state = s;
			
			accMuxSel = 0;	accEn = 0;	op2MuxSel = 0;	aluEn = 0; aluOpcode = 0;	bitRamEn = 0;
			bitRamRw = 1;	byteRamEn = 0;	byteRamRw = 1;	outputRw = 1;
			
			`ifdef timeAndCounter_peripheral
				entypeEn = 0;	tcAccRead = 0;	tcResetEn = 0;		tcPresetEn = 0;	
			`endif
			
			`ifdef UART_peripheral
				uartRead = 0;	uartWrite = 0;
			`endif
			
		end
		
		else
		begin
			
			// execution unit control signals
			
			case (state)
			
			s		:		begin
			

				case (instOpCode)
				
				`END			:	begin
				
						state = s;
						
						accMuxSel = 0;
						accEn = 0;
						op2MuxSel = 0;
						aluEn = 0; 
						aluOpcode = 0;
						bitRamEn = 0;
						bitRamRw = 1;
						byteRamEn = 0;
						byteRamRw = 1;
						outputRw = 1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 0;		tcAccRead = 0;	tcResetEn = 0;		tcPresetEn = 0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 0;		uartWrite = 0;
						`endif
						
						
				end	// end case END



				`JMP			:	begin
				
						state = s;
						
						accMuxSel = 0;
						accEn = 0;
						op2MuxSel = 0;
						aluEn = 0; 
						aluOpcode = 0;
						bitRamEn = 0;
						bitRamRw = 1;
						byteRamEn = 0;
						byteRamRw = 1;
						outputRw = 1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 0;		tcAccRead = 0;	tcResetEn = 0;		tcPresetEn = 0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 0;		uartWrite = 0;
						`endif
						
						
				end	// end case JMP



				`Ld			:	begin
				// load thr. op2 MUX and alu.... enable acc in next cycle
						state = sAlu;
						
//						accMuxSel = `accMuxSelAluOut;
						accMuxSel = 0;
						accEn = 0;
							
							case (iomemCode)
							2'b00	:	op2MuxSel = `op2MuxSelInput;
							2'b01	:	op2MuxSel = `op2MuxSelOutput;
							2'b10	:	op2MuxSel = `op2MuxSelBitRam;
							2'b11	:	op2MuxSel = `op2MuxSelByteRam;
							default:	op2MuxSel = `op2MuxSelInput;
							endcase
							aluEn = 1'b1; 
							aluOpcode = `LD_data;
							
						bitRamEn = 1'b1;
						bitRamRw = 1'b1;
						byteRamEn = 1'b1;
						byteRamRw = 1'b1;
						outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end	// end case Ld
				
				
				
				
				`Ldi			:	begin
						state = sLd;
						
							accMuxSel = `accMuxSelImmData;	// select imm data thr mux
							accEn = 1'b1;		// acc enabled
						op2MuxSel = 1'b0;							
						aluOpcode = 1'b0;
						aluEn = 1'b0; 
						bitRamEn = 1'b0;
						bitRamRw = 1'b1;
						byteRamEn = 1'b0;
						byteRamRw = 1'b1;
						outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end		// end case Ldi
				
				
				
				`ST			:	begin
						state = sSt;
						
						accMuxSel = 1'b0;
						accEn = 1'b0;
						op2MuxSel = 1'b0;							
						aluEn = 1'b0; 
						aluOpcode = 1'b0;
						
							case (iomemCode)
							2'b10	:	begin	bitRamRw = 1'b0;	byteRamRw = 1'b1;	outputRw = 1'b1; bitRamEn = 1'b1;	byteRamEn = 1'b1;	end
							2'b11	:	begin	bitRamRw = 1'b1;	byteRamRw = 1'b0;	outputRw = 1'b1; bitRamEn = 1'b1;	byteRamEn = 1'b1;	end
							2'b01	:	begin	bitRamRw = 1'b1;	byteRamRw = 1'b1;	outputRw = 1'b0; end
							default:	begin	bitRamRw = 1'b1;	byteRamRw = 1'b1;	outputRw = 1'b1;	end
							endcase
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				
				`ADD			:	begin
						state = sAlu;
						aluOpcode = `ADD_alu;
						aluEn = 1'b1; 
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				`SUB			:	begin
						state = sAlu;
						aluOpcode = `SUB_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				// MUL & DIV are not implemented
				
				
				
				`AND			:	begin
						state = sAlu;
						aluOpcode = `AND_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				
				`OR			:	begin
						state = sAlu;
						aluOpcode = `OR_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				


				`XOR			:	begin
						state = sAlu;
						aluOpcode = `XOR_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				


				`GrT			:	begin
						state = sAlu;
						aluOpcode = `GT_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				


				`GE			:	begin
						state = sAlu;
						aluOpcode = `GE_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				


				`EQ			:	begin
						state = sAlu;
						aluOpcode = `EQ_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				


				`LE			:	begin
						state = sAlu;
						aluOpcode = `LE_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				


				`LT			:	begin
						state = sAlu;
						aluOpcode = `LT_alu;
						aluEn = 1'b1;
						accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timeAndCounter_peripheral
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
						
				end
				
				
				`PRE			:	begin
						state = sTc;
						
						entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b1;	
						
						
						aluEn = 1'b0;	aluOpcode = 1'b0;		accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
					end	
						
		

				`ETY			:	begin
						state = sTc;
						
						entypeEn = 1'b1;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						
						
						aluEn = 1'b0;	aluOpcode = 1'b0;		accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
				end



				`RST			:	begin
						state = sTc;
						
						entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b1;		tcPresetEn = 1'b0;	
						
						
						aluEn = 1'b0;	aluOpcode = 1'b0;		accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
				end



				`LdTC			:	begin
						state = sTc;
						
						entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						
						accMuxSel = `accMuxSelTcLoad;		accEn = 1'b1;	// loading TC status data
						
						aluEn = 1'b0;	aluOpcode = 1'b0;		op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
				end



				`LdACC			:	begin
						state = sTc;
						
						entypeEn = 1'b0;		tcAccRead = 1'b1;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						
						accMuxSel = `accMuxSelTcAcc;		accEn = 1'b1;	// loading TC ACC data
						
						aluEn = 1'b0;	aluOpcode = 1'b0;		op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						
						`ifdef UART_peripheral
							uartRead = 1'b0;		uartWrite = 1'b0;
						`endif
						
				end




				`UARTrd			:	begin
						state = sUart;
						
						uartRead = 1'b1;		uartWrite = 1'b0;
						
						accMuxSel = `accMuxSelUartData;		accEn = 1'b1;	// loading UART data
						
						aluEn = 1'b0;	aluOpcode = 1'b0;		op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timerAndCounter_peripheral
						entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
				end



				`UARTstat			:	begin
						state = sUart;
						
						uartRead = 1'b0;		uartWrite = 1'b0;
						
						accMuxSel = `accMuxSelUartStat;		accEn = 1'b1;	// loading UART status
						
						aluEn = 1'b0;	aluOpcode = 1'b0;		op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timerAndCounter_peripheral
						entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
				end




				`UARTwr			:	begin
						state = sUart;
						
						uartRead = 1'b0;		uartWrite = 1'b1;
						
						aluEn = 1'b0;	aluEn = 1'b0;	aluOpcode = 1'b0;		accMuxSel = 1'b0;		accEn = 1'b0;	op2MuxSel = 1'b0;
						bitRamEn = 1'b0;	bitRamRw = 1'b1;	byteRamEn = 1'b0;		byteRamRw = 1'b1;		outputRw = 1'b1;
						
						`ifdef timerAndCounter_peripheral
						entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
						`endif
						
				end


				default		:	begin
				
				$write ("\n", $time, "ns unknown/unused instruction op-code encountered by control unit");
//				$stop;
				end
				endcase	// end 	case (instOpCode)
			
			
				
			end	// end case (s)
			
			
			
			sLd		:	begin
							accEn = 1'b0;
							state = s;
							end		// end case sLd
							
			sSt		:	begin
							bitRamRw = 1'b1;	byteRamRw = 1'b1; outputRw = 1'b1;
							state = s;
							end
							
			sAlu		:	begin
							aluEn = 1'b0;
							accEn = 1'b1;
							accMuxSel = `accMuxSelAluOut;
							state = s;
							end
							
			sTc		:	begin
							entypeEn = 1'b0;		tcAccRead = 1'b0;	tcResetEn = 1'b0;		tcPresetEn = 1'b0;	
							state = s;
							end

			sUart		:	begin
							uartRead = 1'b0;		uartWrite = 1'b0;
							state = s;
							end

			
			default		:	begin
			$write ("	control unit FSM in unknown state.	");
			end
			endcase	// end 	case (state)
		end	// end else part (outermost)
			
		
	
	end	// end always
	
	
endmodule
