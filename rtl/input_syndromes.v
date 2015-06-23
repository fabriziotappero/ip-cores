/* This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
   
   Email : semiconductors@varkongroup.com
   Tel   : 1-732-447-8611
   
*/



//// input stage of reed-solomon decoder and syndromes calculation
//// inputs will be buffered on pipelining rams and it will be used 
////to calcultes syndromes for each block
module input_syndromes 
(
input clk, // clk planned to be 56 mega
input reset, // asynchorounus active high reset 
// chip enable active high flag should be active for one clock with every input
input CE,  
input [7:0] input_byte, // input byte
input [7:0] R_Add, // read address to read from inputs pipeling memories
/// input read enable to the input pipeling memories (1 for mem0, and 0 for mem1 )
input RE, 

/// syndromes 16 elements
/// active high flag will be active for one clock when Syndromes values are ready
output reg S_Ready,  
output reg [7:0] s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,
output [7:0] Read_byte  /// output byte from input pipelinig memories
);



reg WE;
reg [7:0] input_byte0;
reg [7:0] W_Add;
wire [7:0] out_byte_0,out_byte_1;





assign Read_byte = (RE)? out_byte_0:out_byte_1;
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
/////// input pipelining memories
DP_RAM #(.num_words(205),.address_width(8),.data_width(8)) 
mem_in_0 

(
.clk(clk),
.we(WE),
.re(RE),
.address_read(R_Add),
.address_write(W_Add),
.data_in(input_byte0),
.data_out(out_byte_0)
);

DP_RAM  #(.num_words(205),.address_width(8),.data_width(8)) 
mem_in_1
(
.clk(clk),
.we(!WE),
.re(!RE),
.address_read(R_Add),
.address_write(W_Add),
.data_in(input_byte0),
.data_out(out_byte_1)
);






//////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
////// input handling

reg CE0,CE1;
reg [7:0] Address_GF_ascending;
wire [7:0] out_GF_ascending;


always@(posedge clk or posedge reset)
begin
	if (reset)
		begin
			WE<=1;  /// use mem0 first
			W_Add<=204;
			input_byte0<=0;
			CE0<=0;
			CE1<=0;
			Address_GF_ascending<=0;
		end
	else
		begin
			
			
			//  two delay lines to input CE
			CE0<=CE;
			CE1<=CE0;  // now can read from memory
			
			if(CE)
				begin
		// one delay line for input as address of memory changes after one clock from CE
					input_byte0<=input_byte; 
					Address_GF_ascending<=input_byte;
					
		// does not need to add one like matlab as memory index from 0 to 255	not from 1:256
					if (W_Add == 0)
						begin
							WE <= ~WE;
							W_Add <=203;
						end
					else
						W_Add<=W_Add-1;
				end
		end
end		








///////////// instant of GF_matrix_ascending_binary Rom/////////////
GF_matrix_ascending_binary rom_instant
(
.clk(clk),
.re(1'b1),
.address_read(Address_GF_ascending),
.data_out(out_GF_ascending)
);


/////////////////////////////////////////////////////
////////////////////////////////////////////////////
////// x_power generation

reg [7:0] x_power_0;

reg [8:0] x1;
reg [7:0] x_power_1;

reg [8:0] x2;
reg [7:0] x_power_2;

reg [8:0] x3;
reg [7:0] x_power_3;

reg [8:0] x4;
reg [7:0] x_power_4;

reg [8:0] x5;
reg [7:0] x_power_5;

reg [8:0] x6;
reg [7:0] x_power_6;

reg [8:0] x7;
reg [7:0] x_power_7;

reg [8:0] x8;
reg [7:0] x_power_8;


reg [8:0] x9;
reg [7:0] x_power_9;

reg [8:0] x10;
reg [7:0] x_power_10;

reg [8:0] x11;
reg [7:0] x_power_11;

reg [8:0] x12;
reg [7:0] x_power_12;

reg [8:0] x13;
reg [7:0] x_power_13;

reg [8:0] x14;
reg [7:0] x_power_14;

reg [8:0] x15;
reg [7:0] x_power_15;
always@(posedge clk or posedge reset)
begin
	if (reset)
		begin
			x_power_0<=0;
							
			x1<=0;
			x_power_1<=0;
			x2<=0;
			x_power_2<=0;
			x3<=0;
			x_power_3<=0;
			x4<=0;
			x_power_4<=0;
			x5<=0;
			x_power_5<=0;
			x6<=0;
			x_power_6<=0;
			x7<=0;
			x_power_7<=0;
			x8<=0;
			x_power_8<=0;
			x9<=0;
			x_power_9<=0;
			x10<=0;
			x_power_10<=0;
			x11<=0;
			x_power_11<=0;
			x12<=0;
			x_power_12<=0;
			x13<=0;
			x_power_13<=0;
			x14<=0;
			x_power_14<=0;
			x15<=0;
			x_power_15<=0;
		end
	else
		begin
			if (CE)
				begin
					if (x_power_0 == 0)
						begin
							x_power_0<=203;							
							x1<=151;
							x2<=99;
							x3<=47;
							x4<=250;
							x5<=198;							
							x6<=146;							
							x7<=94;							
							x8<=42;							
							x9<=245;						
							x10<=193;						
							x11<=141;							
							x12<=89;							
							x13<=37;							
							x14<=240;							
							x15<=188;
						end
					else
						begin 
							x_power_0<= x_power_0 - 1;
							x1<=x_power_1 - 2;
							x2<=x_power_2 - 3;
							x3<=x_power_3 - 4;
							x4<=x_power_4 - 5;
							x5<=x_power_5 - 6;
							x6<=x_power_6 - 7;
							x7<=x_power_7 - 8;
							x8<=x_power_8 - 9;
							x9<=x_power_9 - 10;
							x10<=x_power_10 - 11;
							x11<=x_power_11 - 12;
							x12<=x_power_12 - 13;
							x13<=x_power_13 - 14;
							x14<=x_power_14 - 15;
							x15<=x_power_15 - 16;
						end
					
				end
				
				x_power_1<= x1[7:0] - x1[8];
				x_power_2<= x2[7:0] - x2[8];
				x_power_3<= x3[7:0] - x3[8];
				x_power_4<= x4[7:0] - x4[8];
				x_power_5<= x5[7:0] - x5[8];
				x_power_6<= x6[7:0] - x6[8];
				x_power_7<= x7[7:0] - x7[8];
				x_power_8<= x8[7:0] - x8[8];
				x_power_9<= x9[7:0] - x9[8];
				x_power_10<= x10[7:0] - x10[8];
				x_power_11<= x11[7:0] - x11[8];
				x_power_12<= x12[7:0] - x12[8];
				x_power_13<= x13[7:0] - x13[8];
				x_power_14<= x14[7:0] - x14[8];
				x_power_15<= x15[7:0] - x15[8];
		end
end
//// these wires to replace every FF with 00
wire [7:0] x_power0,x_power1,x_power2,x_power3,x_power4,x_power5,x_power6,x_power7;
wire [7:0] x_power8,x_power9,x_power10,x_power11,x_power12,x_power13,x_power14,x_power15;

assign x_power0 = x_power_0;
assign x_power1 = x_power_1;
assign x_power2 = (&x_power_2)? 8'h00:x_power_2;
assign x_power3 = x_power_3;
assign x_power4 = (&x_power_4)? 8'h00:x_power_4;
assign x_power5 = (&x_power_5)? 8'h00:x_power_5;
assign x_power6 = x_power_6;
assign x_power7 = x_power_7;
assign x_power8 = (&x_power_8)? 8'h00:x_power_8;
assign x_power9 = (&x_power_9)? 8'h00:x_power_9;
assign x_power10 = x_power_10;
assign x_power11 = (&x_power_11)? 8'h00:x_power_11;
assign x_power12 = x_power_12;
assign x_power13 = x_power_13;
assign x_power14 = (&x_power_14)? 8'h00:x_power_14;
assign x_power15 = x_power_15;
//////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


//////////////// two instants of syndromes calculation unit ///////////////

reg CE_GF_mult_add;
reg [7:0] ip1_0,ip2_0;
reg [7:0] ip1_1,ip2_1;
reg [2:0] count_in;
wire S_Ready_0;
wire [7:0] s_unit0,s_unit1;

GF_mult_add_syndromes    unit0
(
.clk(clk),
.reset(reset),
.CE(CE_GF_mult_add),
.ip1(ip1_0),
.ip2(ip2_0),  
.count_in(count_in), 
/// active high flag will be active for one clock when S of the RS_block is ready 
.S_Ready(S_Ready_0),  
 /// decimal format output syndromes value
.S(s_unit0)  
);



GF_mult_add_syndromes    unit1
(
.clk(clk),
.reset(reset),
.CE(CE_GF_mult_add),
.ip1(ip1_1),
.ip2(ip2_1),
.count_in(count_in),  
.S_Ready(), 
 /// decimal format output syndromes value
.S(s_unit1)  
);


/////////////////// control inputs to two syndromes units//////////

always@(posedge clk or posedge reset)
begin
	if (reset)
		begin
			CE_GF_mult_add<=0;
			count_in<=7;
			ip1_0<=0;ip2_0<=0;
			ip1_1<=0;ip2_1<=0;
		end
	else
		begin
			if(CE1)
				begin
					CE_GF_mult_add<=1;
					count_in<=0;
					ip1_0<=out_GF_ascending; 
					ip1_1<=out_GF_ascending; 
				end	
			if (&count_in  &&  !CE1)
			        begin
					count_in <= 3'd7;
					CE_GF_mult_add<=0;
				end 
			else		
				count_in <= count_in+1;
				
			case(count_in)
			0:
				begin	
					ip2_0<=x_power2;
					ip2_1<=x_power3;
				end
			
			1:
				begin	
					ip2_0<=x_power4;
					ip2_1<=x_power5;
				end
			
			2:
				begin	
					ip2_0<=x_power6;
					ip2_1<=x_power7;
				end
			
			3:
				begin	
					ip2_0<=x_power8;
					ip2_1<=x_power9;
				end
			
			4:
				begin	
					ip2_0<=x_power10;
					ip2_1<=x_power11;
				end
			
			5:
				begin	
					ip2_0<=x_power12;
					ip2_1<=x_power13;
				end
			
			6:
				begin	
					ip2_0<=x_power14;
					ip2_1<=x_power15;
				end
			default:
				begin	
					ip2_0<=x_power0;
					ip2_1<=x_power1;
				end	
			endcase	
		end
end


/////////////////// control output 16 syndromes values/////////////

reg [2:0] cnt8;

always@(posedge clk or posedge reset)
begin
	if (reset)
		begin
			cnt8<=7;
			S_Ready<=0;
			s0<=0;s1<=0;s2<=0;s3<=0;s4<=0;s5<=0;s6<=0;s7<=0;
			s8<=0;s9<=0;s10<=0;s11<=0;s12<=0;s13<=0;s14<=0;s15<=0;
		end
	else
		begin
			if(S_Ready_0)
				begin
					cnt8<=0;
				end
			
			if (&cnt8  &&  !S_Ready_0)
			        begin
					cnt8 <= 3'd7;
				end
			else
				cnt8<=cnt8+1;
				
				
			case (cnt8)
				0:begin s2<=s_unit0; s3<=s_unit1; end
				1:begin s4<=s_unit0; s5<=s_unit1; end
				2:begin s6<=s_unit0; s7<=s_unit1; end
				3:begin s8<=s_unit0; s9<=s_unit1; end
				4:begin s10<=s_unit0; s11<=s_unit1; end
				5:begin s12<=s_unit0; s13<=s_unit1; end
				6:begin s14<=s_unit0; s15<=s_unit1;   S_Ready<=1; end
				default:begin  s0<=s_unit0; s1<=s_unit1; end
			endcase			
				
			if (S_Ready)
				S_Ready<=0;
		end
end

endmodule
