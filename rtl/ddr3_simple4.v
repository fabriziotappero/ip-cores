/* 
*DDR3 Simple Synthesizable Memory BFM
*2010-2011 sclai <laikos@yahoo.com>
*
*This library is free software; you can redistribute it and/or modify it 
* under the terms of the GNU Lesser General Public License as published by 
* the Free Software Foundation; either version 2.1 of the License, 
* or (at your option) any later version.
* 
* This library is distributed in the hope that it will be useful, but 
* WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
* USA
*
*
*  Simple implementation of DDR3 Memory
*  will only reponse to write and read request
*  parameter
*  count start from t0,t2,t2...
*  ck _|-|_|-|_|-|_|-|_
* 
*  cs#---|___|---------
*
*        |   |    |
*        t0  t1  t2 ....
*
*
*/

`timescale 1ps / 1ps

module ddr3_simple4#(
parameter MEM_DQ_WIDTH 		=8,
parameter MEM_BA_WIDTH 		=3,
parameter MEM_ROW_WIDTH 	=13,
parameter MEM_COL_WIDTH		=13,
parameter AL		=3,
parameter CWL		=5, //CWL
parameter CL		=5  //CL=6 -> pass
)(
input wire [MEM_ROW_WIDTH-1:0]	a,
input wire [ MEM_BA_WIDTH-1:0]	ba,
input wire			ck,
input wire 			ck_n,
input wire 			cke,
input wire			cs_n,
input wire			dm,     
input wire			ras_n,   
input wire			cas_n,   
input wire			we_n,    
input wire			reset_n, 
inout wire [MEM_DQ_WIDTH-1:0]	dq,      
inout wire			dqs,     
inout wire			dqs_n,   
input wire			odt      
);

//convert actual CL and CWL parameter to 
localparam  MEM_CWL=CWL+AL;
localparam  MEM_CL =CL+AL;

//definitions
localparam	OPCODE_PRECHARGE = 4'b0010;
localparam	OPCODE_ACTIVATE  = 4'b0011;
localparam	OPCODE_WRITE 	 = 4'b0100;
localparam	OPCODE_READ 	 = 4'b0101;
localparam	OPCODE_MRS 	 = 4'b0000;
localparam	OPCODE_REFRESH 	 = 4'b0001;
localparam	OPCODE_DES 	 = 4'b1000;
localparam	OPCODE_ZQC 	 = 4'b0110;
localparam	OPCODE_NOP 	 = 4'b0111;

//mode registers
reg [31:0] mr0;
reg [31:0] mr2;
reg [31:0] mr3;


wire [35:0] write_add;
wire [35:0] read_add;
wire [3:0]  write_cmd;
wire [3:0]  read_cmd;
(* keep *)wire [(MEM_DQ_WIDTH*2)-1:0] read_data;

reg [ 2:0] last_bank;
reg [15:0] last_row;
reg [3:0] last_write_cmd;
reg [3:0] last_read_cmd;
reg [35:0] last_write_add;
reg [35:0] last_read_add;

reg        write_address12;
reg        read_address12;

//bank tracker
reg [MEM_ROW_WIDTH-1:0]opened_row[(2**MEM_BA_WIDTH)-1:0]; 
//row  tracker

wire [MEM_DQ_WIDTH-1:0]  dq_out;
reg  [MEM_DQ_WIDTH-1:0]  dq_in0;

(* keep *) wire [MEM_DQ_WIDTH-1:0] data_hi; 
(* keep *) wire [MEM_DQ_WIDTH-1:0] data_lo;
(* keep *) wire			  data_hi_dm; 
(* keep *) wire 		  data_lo_dm;
//IDDR
my_iddrx8 iddrx8_inst(
	.clk(ck),
	.io(dq),
	.d0(data_lo),
	.d1(data_hi)
);

my_iddrx8 iddrx8_dm_inst(
	.clk(ck),
	.io(dm),
	.d0(data_lo_dm),
	.d1(data_hi_dm)
);

//ODDR
my_oddrx8 oddrx8_inst(
.clk(ck),
.d0(read_data[ MEM_DQ_WIDTH-1:0              ]),
.d1(read_data[(MEM_DQ_WIDTH*2)-1:MEM_DQ_WIDTH]),
.io(dq_out)
);

//double data rate
always @(posedge ck )
begin
if(reset_n==1'b0)
	begin	
		last_bank     <=4'h0;
		last_row      <=16'h0000;
	end
else
begin
	case({cs_n,ras_n,cas_n,we_n})
	/*
	OPCODE_PRECHARGE	:begin
					$display("t=%d,PRECHARGE",vip_clk);
				end
	*/
	OPCODE_ACTIVATE  	:begin								
					opened_row [ba] <={{(16-MEM_ROW_WIDTH){1'b0}},a[MEM_ROW_WIDTH-1:0]};
				end
	/*						
	OPCODE_DES		:begin
					$display("t=%d,DES",vip_clk);
				end
	OPCODE_MRS  		:begin
					$display("t=%d,MRS",vip_clk);
				end
	OPCODE_NOP  		:begin
					//$display("t=%d,NOP",vip_clk);
				end
	*/
	OPCODE_READ  		:begin							
					last_read_add 	<={ba,opened_row[ba],{{(16-MEM_COL_WIDTH){1'b0}},a[MEM_COL_WIDTH-1:0]}};								
					last_read_cmd 	<=OPCODE_READ;
				end
	OPCODE_WRITE  		:begin
					last_write_add  <={ba,opened_row[ba],{{(16-MEM_COL_WIDTH){1'b0}},a[MEM_COL_WIDTH-1:0]}};
					last_write_cmd  <=OPCODE_WRITE;
				end
							/*
	OPCODE_ZQC		:begin
				$display("t=%d,ZQC",vip_clk);
					end*/
		default:begin
				last_read_cmd 	<=OPCODE_NOP;
				last_write_cmd <=OPCODE_NOP;
			end
	endcase
end // end reset	
end // end always@(*)



//cmd
//read
ddr3_sr4 #(
.PIPE_LEN(MEM_CL)
)ddr3_read_cmd_sr(
	.clk(ck),
	.shift_in(last_read_cmd),
	.shift_out(read_cmd)
);
//bank, row, col
ddr3_sr36 #(
.PIPE_LEN(MEM_CL+1)
)ddr3_read_add_sr(
	.clk(ck),
	.shift_in(last_read_add),
	.shift_out(read_add)
);

//cmd
//write
ddr3_sr4#(
.PIPE_LEN(MEM_CWL)
)ddr3_write_cmd_sr(
	.clk(ck),
	.shift_in(last_write_cmd),
	.shift_out(write_cmd)
);

//bank, row, col
ddr3_sr36#(
.PIPE_LEN(MEM_CWL+1) //have to be a cycle late to wait for IDDR latency
) ddr3_write_add_sr(
	.clk(ck),
	.shift_in(last_write_add),
	.shift_out(write_add)
);


//write fsm
localparam WR_D0	=4'd0;
localparam WR_D1	=4'd1;
localparam WR_D2	=4'd2;
localparam WR_D3	=4'd3;
localparam WR_IDLE	=4'd5;
reg [3:0] write_state;
reg 		 mem_we;
reg [2:0] write_col;
always@(posedge ck)
begin
	if(reset_n==1'b0)
		begin
			write_state<=WR_IDLE;
			mem_we<=1'b0;
			write_col<=0;
		end
	else
		begin
		case(write_state)
			WR_IDLE:begin
			write_col<=0;
			if(write_cmd==OPCODE_WRITE)
				begin				
					write_state<=WR_D0;
					mem_we<=1'b1;
				end
			else
				begin
					write_state<=WR_IDLE;	
					mem_we<=1'b0;				
				end
			end
			WR_D0:begin
				write_address12<=write_add[12];
				write_state<=WR_D1;
				write_col<=write_col+1'b1;
				$display("%m: at time %t\tWRITE BANK[%x]\tROW[%x]\tCOL[%x]\tWR D0: %x-%x",$time,write_add[34:32],write_add[31:16],write_add[15:0],data_hi,data_lo);
			end
			WR_D1:begin				
				if(write_address12==1'b1)
					begin
						write_state<=WR_D2;
						write_col<=write_col+1'b1;
					end
				else if (write_cmd==OPCODE_WRITE)
					begin
						write_state<=WR_D0;
						write_col<=0;
					end
				else
					begin
						write_state<=WR_IDLE;
						mem_we<=1'b0;
					end
				$display("%m: at time %t\tWRITE BANK[%x]\tROW[%x]\tCOL[%x]\tWR D1: %x-%x",$time,write_add[34:32],write_add[31:16],write_add[15:0],data_hi,data_lo);				
			end
			WR_D2:begin				
				write_state<=WR_D3;
				write_col<=write_col+1'b1;	
				$display("%m: at time %t\tWRITE BANK[%x]\tROW[%x]\tCOL[%x]\tWR D2: %x-%x",$time,write_add[34:32],write_add[31:16],write_add[15:0],data_hi,data_lo);			
			end
			WR_D3:begin
				$display("%m: at time %t\tWRITE BANK[%x]\tROW[%x]\tCOL[%x]\tWR D3: %x-%x",$time,write_add[34:32],write_add[31:16],write_add[15:0],data_hi,data_lo);
				
				//write_col<=write_col+1'b1;	
				if (write_cmd==OPCODE_WRITE)
					begin
						write_state<=WR_D0;
						write_col<=0;
					end
				else
					begin
						write_state<=WR_IDLE;
						mem_we<=1'b0;
					end
			end
		endcase
		end //endif
end


//read fsm
localparam RD_D0	=4'd0;
localparam RD_D1	=4'd1;
localparam RD_D2	=4'd2;
localparam RD_D3  	=4'd3;
localparam RD_IDLE	=4'd5;

reg [3:0] read_state;
reg [2:0] read_col;
reg		 send_dq;
reg		 send_dqs0;
reg		 send_dqs1;

always@(posedge ck)
begin
	if(reset_n==1'b0)
		begin
			read_state<=RD_IDLE;
			read_col	 <=0;
			send_dq	 <=0;	
		end
	else
		begin
			case(read_state)
			RD_IDLE:begin
			read_col<=0;
			send_dq<=0;
			if(read_cmd==OPCODE_READ)
				begin				
					read_state<=RD_D0;																
				end
			else
				begin
					read_state<=RD_IDLE;					
				end
			end
			RD_D0:begin
				read_address12<=read_add[12];
				read_state<=RD_D1;
				read_col<=read_col+1'b1;
				send_dq	 <=1'b1;
				$display("%m: at time %t\tREAD BANK[%x]\tROW[%x]\tCOL[%x]\tRD D0",$time,read_add[34:32],read_add[31:16],read_add[15:0]);
			end
			RD_D1:begin			
				if(read_address12==1'b1)
					begin
						read_state<=RD_D2;
						read_col<=read_col+1'b1;
					end
				else if (read_cmd==OPCODE_READ)
					begin
						read_state<=RD_D0;
						read_col<=0;
						send_dq	 <=1'b1;
					end
				else
					begin
						read_state<=RD_IDLE;
						//send_dq	 <=1'b0;
					end
				$display("%m: at time %t\tREAD BANK[%x]\tROW[%x]\tCOL[%x]\tRD D1",$time,read_add[34:32],read_add[31:16],read_add[15:0]);
			end
			RD_D2:begin				
				read_state<=RD_D3;
				read_col<=read_col+1'b1;
				send_dq	 <=1'b1;				
				$display("%m: at time %t\tREAD BANK[%x]\tROW[%x]\tCOL[%x]\tRD D2",$time,read_add[34:32],read_add[31:16],read_add[15:0]);
			end
			RD_D3:begin
				//write_col<=write_col+1'b1;	
				if (read_cmd==OPCODE_READ)
					begin
						read_state<=RD_D0;
						read_col<=0;
						send_dq	 <=1'b1;
					end
				else
					begin
						read_state<=RD_IDLE;
						read_col<=0;
						//send_dq	 <=1'b0;
					end
					$display("%m: at time %t\tREAD BANK[%x]\tROW[%x]\tCOL[%x]\tRD D3",$time,read_add[34:32],read_add[31:16],read_add[15:0]);
			end
			endcase
		end
		
end //end always

//dqs fsm
always @(posedge ck_n)
begin
if(reset_n==1'b0)
	begin
		send_dqs1<=0;
		send_dqs0<=0;
	end
else
	begin
		if(read_cmd==OPCODE_READ) 
			begin
				send_dqs1<=1'b1;
			end
		else
			begin
				send_dqs1<=1'b0;
			end
	end
send_dqs0<=send_dqs1;
end//end always

//ram here
dport_ram  #(
	.DATA_WIDTH(MEM_DQ_WIDTH), //data_hi,data_lo
	.ADDR_WIDTH(36)
)dport_ram_hi(
	.clk			(ck),
	.di			(data_hi),
	.read_addr	(read_add+read_col), 
	.write_addr (write_add+write_col),
	.we			(mem_we & data_hi_dm), 
	.do			(read_data[15:8])
);

dport_ram  #(
	.DATA_WIDTH(MEM_DQ_WIDTH), //data_hi,data_lo
	.ADDR_WIDTH(36)
)dport_ram_lo(
	.clk			(ck),
	.di			(data_lo),
	.read_addr	(read_add+read_col), 
	.write_addr (write_add+write_col),
	.we			(mem_we & data_lo_dm), 
	.do			(read_data[7:0])
);
assign dqs  =((send_dqs0==1'b1) || (send_dq==1'b1))?ck:1'bz;
assign dqs_n=((send_dqs0==1'b1) || (send_dq==1'b1))?ck_n:1'bz;
assign dq   = (send_dq==1'b1)?dq_out:8'hZZ;

/* utility functions to display information
*/

initial begin
        $timeformat (-9, 1, " ns", 1);
      end
      
always @(posedge ck )
begin
	case({cs_n,ras_n,cas_n,we_n})

	OPCODE_PRECHARGE	:begin
					$display("%m: at time %t PRECHARGE ",$time);
				end
	
	OPCODE_ACTIVATE  	:begin
					$display("%m: at time %t ACTIVATE - BANK[%x]\tROW[%x]",$time,ba,a);
				end
						
	OPCODE_DES		:begin
					$display("%m: at time %t DES ",$time);
				end
	OPCODE_MRS  	:begin
							$display("%m: at time %t MRS - MR[%d]",$time,ba[1:0]);
							case(ba[1:0])
								2'b00:begin //MR0
									case(a[1:0]) // burst length
										2'b00:$display("%m\tBL = BL8 \(Fixed\)");
										2'b01:$display("%m\tBL = BC4/BL8 OTF");
										2'b10:$display("%m\tBL = BC4 (Fixed)");
										2'b11:$display("%m\tBL = Reserved");
									endcase	
									
									case({a[6:4],a[2]}) //CAS Latency
										4'b0000:$display("%m\tCL = Reserved");	
										4'b0010:$display("%m\tCL = 5");	
										4'b0100:$display("%m\tCL = 6");	
										4'b0110:$display("%m\tCL = 7");	
										4'b1000:$display("%m\tCL = 8");	
										4'b1010:$display("%m\tCL = 9");	
										4'b1100:$display("%m\tCL = 10");	
										4'b1111:$display("%m\tCL = 11(Optional for DD3-1600)");	
										4'b0001:$display("%m\tCL = 12");
										4'b0011:$display("%m\tCL = 13");	
										4'b0101:$display("%m\tCL = 14");	
										4'b0111:$display("%m\tCL = Reserved for 15");	
										4'b1001:$display("%m\tCL = Reserved for 16");	
										4'b1011:$display("%m\tCL = Reserved");	
										4'b1101:$display("%m\tCL = Reserved");	
										4'b1111:$display("%m\tCL = Reserved");											
									endcase
									
									case(a[11:9]) //Write Recover
										3'b000:$display("%m\tWR = 16^2(256 cycles)");
										3'b001:$display("%m\tWR =  5^2( 25 cycles)");										
										3'b010:$display("%m\tWR =  6^2( 36 cycles)");
										3'b011:$display("%m\tWR =  7^2( 49 cycles)");
										3'b100:$display("%m\tWR =  8^2( 64 cycles)");
										3'b101:$display("%m\tWR = 10^2(100 cycles)");
										3'b110:$display("%m\tWR = 12^2(144 cycles)");
										3'b111:$display("%m\tWR = 14^2(196 cycles)");
									endcase
								end//end MR0
								2'b01:begin //MR1
									case(a[0]) //DLL Enable
										1'b0:$display("%m\tDLL = Enabled");
										1'b1:$display("%m\tDLL = Disabled");
									endcase 
									case({a[5],a[1]}) //Output driver impedence
										2'b00:$display("%m\tOutput Driver = RQZ/6(RQZ=240 Ohm)");
										2'b01:$display("%m\tOutput Driver = RQZ/7(RQZ=240 Ohm)");
										2'b10:$display("%m\tOutput Driver = Reserved");
										2'b11:$display("%m\tOutput Driver = Reserved");
									endcase
									case({a[9],a[6],a[2]})
										3'b000:$display("%m\tRTT Nom = RTT Nom Disabled");
										3'b001:$display("%m\tRTT Nom = RZQ/4(RZQ=240 Ohm)");
										3'b010:$display("%m\tRTT Nom = RZQ/2(RZQ=240 Ohm)");
										3'b011:$display("%m\tRTT Nom = RZQ/6(RZQ=240 Ohm)");
										3'b100:$display("%m\tRTT Nom = RZQ/12(RZQ=240 Ohm)");
										3'b101:$display("%m\tRTT Nom = RZQ/8(RZQ=240 Ohm)");
										3'b110:$display("%m\tRTT Nom = Reserved");
										3'b111:$display("%m\tRTT Nom = Reserved");																		
									endcase
									case(a[4:3]) //Additive Latency
										2'b00:$display("%m\tAL = 0(Disabled)");
										2'b01:$display("%m\tAL = CL-1");
										2'b10:$display("%m\tAL = CL-2");
										2'b11:$display("%m\tAL = Reserved");
									endcase
								end//end MR1
								2'b10:begin //MR2
									case(a[5:3])
										3'b000:$display("%m\tCWL = 5");
										3'b001:$display("%m\tCWL = 6");
										3'b010:$display("%m\tCWL = 7");
										3'b011:$display("%m\tCWL = 8");
										3'b100:$display("%m\tCWL = 9");
										3'b101:$display("%m\tCWL = 10");
										3'b110:$display("%m\tCWL = 11");
										3'b111:$display("%m\tCWL = 12");
									endcase
									case(a[10:9])
									2'b00:$display("%m\tDynamic ODT Off");
									2'b00:$display("%m\tRTT WR = RZQ/4(RQZ=240 Ohm)");
									2'b00:$display("%m\tRTT WR = RZQ/2(RQZ=240 Ohm)");
									2'b00:$display("%m\tRTT WR = Reserved");
									endcase
								end//end MR2
								2'b11:begin //MR3
								end//end MR3
							endcase //end which MRS
						
					
						end //end MRS
	/*OPCODE_NOP  		:begin
					/$display("%m: at time %t WRITE ",$time);
				end
	*/
	/*
	OPCODE_READ  		:begin
					$display("%m: at time %t READ - BANK[%x]\tROW[%x]\tCOL[%x]",$time,ba,last_row,a);
				end
	OPCODE_WRITE  		:begin
					$display("%m: at time %t WRITE - BANK[%x]\tROW[%x],\tCOL[%x]",$time,ba,last_row,a);
				end
	*/						
	OPCODE_ZQC		:begin
					$display("%m: at time %t ZQC ",$time);
				end
	endcase

end // end always@(*)
/* end utility*/

endmodule
