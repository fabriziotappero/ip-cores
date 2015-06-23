`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       Universidad Pontificia Bolivariana
// Engineer:      Fabio Andres Guzman Figueroa
// 
// Create Date:    19:48:58 05/14/2012 
// Design Name: 
// Module Name:    control_unit 
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
module control_unit(
    input clk,
    input rst,
    input [15:0] instruction,
    input z,
    input c,
    output reg [7:0] port_addr,
    output reg write_e,
    output reg read_e,
    output reg insel,
    output reg we,
    output reg [2:0] raa,
    output reg [2:0] rab,
    output reg [2:0] wa,
    output reg [2:0] opalu,
    output reg [2:0] sh,
    output reg selpc,
    output reg ldpc,
    output reg ldflag,
    output reg [10:0] naddress,
    output reg selk,
    output reg [7:0] KTE,
	 input [10:0] stack_addr,
	 output reg wr_en, rd_en,
	 output reg [7:0] imm,
	 output reg selimm
    );


parameter fetch=	5'd0;
parameter decode=	5'd1;

parameter ldi=		5'd2;
parameter ldm=		5'd3;
parameter stm=		5'd4;
parameter cmp=		5'd5;
parameter add=		5'd6;
parameter sub=		5'd7;
parameter andi=	5'd8;
parameter oor=		5'd9;
parameter xori=	5'd10;
parameter jmp=		5'd11;
parameter jpz=		5'd12;
parameter jnz=		5'd13;
parameter jpc=		5'd14;
parameter jnc=		5'd15;
parameter csr=		5'd16;
parameter ret=		5'd17;

parameter adi=		5'd18;
parameter csz=		5'd19;
parameter cnz=		5'd20;
parameter csc=		5'd21;
parameter cnc=		5'd22;
parameter sl0=		5'd23;
parameter sl1=		5'd24;
parameter sr0=		5'd25;
parameter sr1=		5'd26;
parameter rrl=		5'd27;
parameter rrr=		5'd28;
parameter noti=	5'd29;

parameter nop=		5'd30;

wire [4:0] opcode;
reg [4:0] state;

assign opcode=instruction[15:11];

always@(posedge clk or posedge rst)
	if (rst)
		state<=decode;
	else
		case (state)
			fetch: state<=decode;
			
			decode: case (opcode)
							2: 	state<=ldi;
							3:		state<=ldm;
							4:		state<=stm; 
							5:		state<=cmp;
							6:		state<=add;
							7:		state<=sub;
							8:		state<=andi;
							9:		state<=oor;
							10:	state<=xori;
							11:	state<=jmp;
							12:	state<=jpz;
							13:	state<=jnz;
							14:	state<=jpc;
							15:	state<=jnc;
							16:	state<=csr;
							17:	state<=ret;
							18:	state<=adi;
							19:	state<=csz;
							20:	state<=cnz;
							21:	state<=csc;
							22:	state<=cnc;
							23:	state<=sl0;
							24:	state<=sl1;
							25:	state<=sr0;
							26:	state<=sr1;
							27:	state<=rrl;
							28:	state<=rrr;
							29:	state<=noti;
							default:	state<=nop;
						endcase
			
			ldi:	state<=fetch;
					
			ldm:	state<=fetch;
					
			stm:	state<=fetch;
					
			cmp:	state<=fetch;
					
			add:	state<=fetch;
					
			sub:	state<=fetch;
					
			andi:	state<=fetch;
					
			oor:	state<=fetch;
					
			xori:	state<=fetch;
							
			jmp:	state<=fetch;
						
			jpz: 	state<=fetch;
			
			jnz: 	state<=fetch;
			
			jpc: 	state<=fetch;
			
			jnc: 	state<=fetch;
			
			csr: 	state<=fetch;
			
			ret: 	state<=fetch;
			
			adi:	state<=fetch;
			
			csz:	state<=fetch;
			
			cnz:	state<=fetch;
			
			csc:	state<=fetch;
			
			cnc:	state<=fetch;
			
			sl0:	state<=fetch;
			
			sl1:	state<=fetch;
			
			sr0:	state<=fetch;
			
			sr1:	state<=fetch;
			
			rrl:	state<=fetch;
			
			rrr:	state<=fetch;
			
			noti:	state<=fetch;
						
			nop: 	state<=fetch;
			endcase
	


always@(*)
	begin
		port_addr<=0;
		write_e<=0;
		read_e<=0;
		insel<=0;
		we<=0;
		raa<=0;
		rab<=0;
		wa<=0;
		opalu<=4;
		sh<=4;
		selpc<=0;
		ldpc<=1;
		ldflag<=0;
		naddress<=0;
		selk<=0;
		KTE<=0;
		wr_en<=0;
		rd_en<=0;
		imm<=0;
		selimm<=0;
		
		case (state)
			fetch: ldpc<=0;
					
			decode:  begin
							ldpc<=0;
							if (opcode==stm)
								begin
									raa<=instruction[10:8];
									port_addr<=instruction[7:0];
								end
							else if (opcode==ldm)
								begin
									wa<=instruction[10:8];
									port_addr<=instruction[7:0];
								end
							else if (opcode==ret)
								begin
									rd_en<=1;
								end
						end
				
			ldi:	begin
						selk<=1;
						KTE<=instruction[7:0];
						we<=1;
						wa<=instruction[10:8];
					end
					
			ldm:	begin
						wa<=instruction[10:8];
						we<=1;
						read_e<=1;
						port_addr<=instruction[7:0];
					end
					
			stm:	begin
						raa<=instruction[10:8];
						write_e<=1;
						port_addr<=instruction[7:0];
					end
					
			cmp:	begin
						ldflag<=1;
						raa<=instruction[10:8];
						rab<=instruction[7:5];
						opalu<=6;
					end
					
			add:	begin
						raa<=instruction[10:8];
						rab<=instruction[7:5];
						wa<=instruction[10:8];
						insel<=1;
						opalu<=5;
						we<=1;
					end
					
			sub:	begin
						raa<=instruction[10:8];
						rab<=instruction[7:5];
						wa<=instruction[10:8];
						insel<=1;
						opalu<=6;
						we<=1;
					end
					
			andi:	begin
						raa<=instruction[10:8];
						rab<=instruction[7:5];
						wa<=instruction[10:8];
						insel<=1;
						opalu<=1;
						we<=1;
					end
					
			oor:	begin
						raa<=instruction[10:8];
						rab<=instruction[7:5];
						wa<=instruction[10:8];
						insel<=1;
						opalu<=3;
						we<=1;
					end
					
			xori:	begin
						raa<=instruction[10:8];
						rab<=instruction[7:5];
						wa<=instruction[10:8];
						insel<=1;
						opalu<=2;
						we<=1;
					end
					
			jmp:	begin
						naddress<=instruction[10:0];
						selpc<=1;
						ldpc<=1;
					end
					
			jpz:		if (z)
						begin
							naddress<=instruction[10:0];
							selpc<=1;
							ldpc<=1;
						end
										
			jnz:		if (!z)
							begin
								naddress<=instruction[10:0];
								selpc<=1;
								ldpc<=1;
							end
						
					
			jpc:	if (c)
							begin
								naddress<=instruction[10:0];
								selpc<=1;
								ldpc<=1;
							end
						
					
			jnc:	if (!c)
							begin
								naddress<=instruction[10:0];
								selpc<=1;
								ldpc<=1;
							end
							
			csr:	begin
						naddress<=instruction[10:0];
						selpc<=1;
						ldpc<=1;
						wr_en<=1;
					end
					
			ret:	begin
						naddress<=stack_addr;
						selpc<=1;
						ldpc<=1;
					end
					
			adi:	begin
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						imm<=instruction[7:0];
						selimm<=1;
						insel<=1;
						opalu<=5;
						we<=1;
					end	
					
			csz:	if (z)
						begin
							naddress<=instruction[10:0];
							selpc<=1;
							ldpc<=1;
							wr_en<=1;
						end
						
			cnz:	if (!z)
						begin
							naddress<=instruction[10:0];
							selpc<=1;
							ldpc<=1;
							wr_en<=1;
						end
						
			csc:	if (c)
						begin
							naddress<=instruction[10:0];
							selpc<=1;
							ldpc<=1;
							wr_en<=1;
						end
						
			cnc:	if (!c)
						begin
							naddress<=instruction[10:0];
							selpc<=1;
							ldpc<=1;
							wr_en<=1;
						end
			
			sl0:	begin	
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						insel<=1;
						sh<=0;
						we<=1;
					end
					
			sl1:	begin	
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						insel<=1;
						sh<=5;
						we<=1;
					end
					
			sr0:	begin	
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						insel<=1;
						sh<=2;
						we<=1;
					end
					
			sr1:	begin	
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						insel<=1;
						sh<=6;
						we<=1;
					end	

			rrl:	begin	
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						insel<=1;
						sh<=1;
						we<=1;
					end						
					
			rrr:	begin	
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						insel<=1;
						sh<=3;
						we<=1;
					end
					
			noti:	begin
						raa<=instruction[10:8];
						wa<=instruction[10:8];
						insel<=1;
						opalu<=0;
						we<=1;
					end

			nop:	opalu<=4;
						
		endcase
	end
			

endmodule
