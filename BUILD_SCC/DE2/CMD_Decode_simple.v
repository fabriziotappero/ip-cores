
module CMD_Decode(	//	USB JTAG
					iRXD_DATA,oTXD_DATA,iRXD_Ready,iTXD_Done,oTXD_Start,
					//	AI
					oAI_DATA,iAI_DATA,oAI_Start,iAI_Done,oCOLOR,
					//	Control
					iCLK,iRST_n,oAI_RSTn,
					//Debug
					d_cmd
					);
//	USB JTAG
input [7:0] iRXD_DATA;
input iRXD_Ready,iTXD_Done;
output [7:0] oTXD_DATA;
output oTXD_Start;
//	AI
input	[63:0]	iAI_DATA;
output	[63:0]	oAI_DATA;
output reg oAI_Start;
input iAI_Done;
output [7:0] oCOLOR;
//	Control
input iCLK,iRST_n;
output oAI_RSTn =AI_RSTn;
//Debug
output [16:0] d_cmd ;
//	Internal Register
reg [63:0] CMD_Tmp;
reg [71:0] AI_RESULT;
reg [71:0] AI_RESULT_next;
reg [2:0] mAI_ST;
reg [2:0] mAI_ST_next;

reg [63:0] AI_INPUT;
reg [63:0] AI_INPUT_next;
reg [16:0] AI_INPUT_MOVE;
reg [16:0] AI_INPUT_MOVE_next;
//	USB JTAG TXD Output
reg oSR_TXD_Start;
reg [7:0] oSR_TXD_DATA;

//
reg AI_RSTn;
reg [16:0] move_count_me,move_count_you; //maximum no. of moves= 361
reg [16:0] move_count_me_next; //maximum no. of moves= 361
wire [16:0] move_count=(move_count_me+move_count_you) >> 2;

reg [7:0] 	CMD;

reg TXD_Start;
reg TXD_Start_next;
reg rst_count;
assign oTXD_Start =TXD_Start;
assign d_cmd=AI_INPUT_MOVE;
assign oCOLOR = CMD;

/////////////////////////////////////////////////////////
///////		Shift Register For Command Temp	/////////////
always@(posedge iCLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
	CMD_Tmp<=0;
	CMD<=0;
	move_count_you<=0;
	AI_RSTn<=1'b0;
	end
	else
	begin
			CMD_Tmp<=CMD_Tmp;
			CMD<=CMD;
			move_count_you<=move_count_you;
			AI_RSTn<=AI_RSTn;
		if(iRXD_Ready) 
		begin
			CMD_Tmp<={CMD_Tmp[55:0],iRXD_DATA};
			

			if(iRXD_DATA !=8'h44 && iRXD_DATA!=8'h4C) 
			begin
			
			move_count_you<=move_count_you+1;//4 ascii chars == 1 move
			AI_RSTn<=1'b1;
			end
			else
			begin
			
			CMD<=iRXD_DATA;
			move_count_you<=0;
			AI_RSTn<=1'b0;
			
			end
		end
		else 
			
			AI_RSTn<=1'b1;
	end
end
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////	AI Control	/////////////////////
reg [3:0] wait_count;
reg [3:0] wait_count_next;
reg [3:0] NO_OF_MOVES;
reg [3:0] NO_OF_MOVES_next;


always@(posedge iCLK or negedge AI_RSTn)

begin
	if(!AI_RSTn)
	begin
		mAI_ST<=0;
		wait_count <=0;
		move_count_me<=0;
		AI_RESULT<=0;
		TXD_Start<=1'b0;
		NO_OF_MOVES<=0;
		AI_INPUT<=0;
		AI_INPUT_MOVE<=0;
		
	end
	else
	begin
		mAI_ST<=mAI_ST_next;
		wait_count <=wait_count_next;
		move_count_me<=move_count_me_next;
		AI_RESULT<=AI_RESULT_next;
		TXD_Start<=TXD_Start_next;
		NO_OF_MOVES<=NO_OF_MOVES_next;
		AI_INPUT<=AI_INPUT_next;
		AI_INPUT_MOVE<=AI_INPUT_MOVE_next;

	end
end 


always@*//(mAI_ST,move_count,iTXD_Done,TXD_Start,iAI_Done,iAI_DATA)
begin
	mAI_ST_next<=mAI_ST;
	wait_count_next<=wait_count;
	move_count_me_next<=move_count_me;
	AI_RESULT_next<=AI_RESULT;
	TXD_Start_next<=TXD_Start;
	NO_OF_MOVES_next<=NO_OF_MOVES;
	AI_INPUT_next <=AI_INPUT;
	AI_INPUT_MOVE_next<=AI_INPUT_MOVE;
			case(mAI_ST)
			
				
			0:	begin
					if( (CMD	== 8'h44) && (move_count ==0))
						begin
						mAI_ST_next		<=	1;
						AI_INPUT_next<=CMD_Tmp;
						AI_INPUT_MOVE_next<=move_count;
						end
					else if ( (CMD        == 8'h4C) && (move_count ==1)) 
						begin
						mAI_ST_next	<=	4;
						AI_INPUT_next<=CMD_Tmp;
						AI_INPUT_MOVE_next<=move_count;
						end
						
					else
						mAI_ST_next	<=	0;
					
		
				
				end
			1:	begin
					mAI_ST_next     <=      2;
				end
			2:	begin
					if(iAI_Done == 1'b1) 
					begin
						mAI_ST_next	<=	3;
						NO_OF_MOVES_next<=4;
						AI_RESULT_next[63:0]<=iAI_DATA; 
						
					end
					else begin
						mAI_ST_next	<=	2;
					end
						
					
				end
			3:	begin
					
					if(iTXD_Done == 1'b1 && TXD_Start ==1'b0)
					begin
						if(wait_count==NO_OF_MOVES) begin
						mAI_ST_next	<=	4;
						wait_count_next<=0;
						TXD_Start_next	<=1'b0;
						end
						else begin
						mAI_ST_next	<=	3;
						TXD_Start_next	<=1'b1;
						wait_count_next<=wait_count+1;
						AI_RESULT_next<={AI_RESULT[63:0],8'h0};
						move_count_me_next<=move_count_me+1;
						end
					end
					else
						TXD_Start_next	<=1'b0;
						
				end
			4:	begin
					//move_count % 4  == 0 means dark's turn, (move_count % 4  == 1 ) means light's turn
					if((((move_count % 4)  == 3 ) && (CMD ==8'h44))|| (((move_count % 4)  == 1 ) && (CMD ==8'h4C)))
						begin
					//if(((move_count ==1|| move_count ==5|| move_count ==9) && (CMD ==8'h4C)))
						mAI_ST_next	<=	5;
						AI_INPUT_next<=CMD_Tmp;
						AI_INPUT_MOVE_next<=move_count;
						end
					else
						mAI_ST_next	<=	4;
				
				end
			5:	begin
					mAI_ST_next     <=      6;
					AI_INPUT_next<=CMD_Tmp;
				end
			6:	begin
					if(iAI_Done == 1'b1) begin
						mAI_ST_next	<=	3;
						AI_RESULT_next[63:0]<=iAI_DATA; 
						NO_OF_MOVES_next<=8 ; 
						end
						
					else begin
						mAI_ST_next	<=	6;
						AI_RESULT_next<=0;
						NO_OF_MOVES_next<=NO_OF_MOVES;
					end
					
				end
			default:mAI_ST_next <= mAI_ST_next;
			endcase
		
	
end

assign oTXD_DATA = AI_RESULT[71:64];
assign oAI_DATA = AI_INPUT;

always@(mAI_ST)
begin
			case(mAI_ST)
			
				
			0:	begin
					
					oAI_Start	<=1'b0;
					//oAI_DATA<=0;
		
				
				end
			1:	begin
					oAI_Start	<=1'b1;
					//oAI_DATA<=CMD_Tmp[63:0];
					
					
				//end
				end
			2:	begin
					
					oAI_Start	<=1'b0;
					//oAI_DATA<=0;
				//end 
				end
			3:	begin
					oAI_Start	<=1'b0;
					//oAI_DATA<=0;
					
				//end
				end
			4:	begin
					oAI_Start	<=1'b0;
					//oAI_DATA<=CMD_Tmp[63:0];
					
					
				end
			5:	begin
					oAI_Start	<=1'b1;
					//oAI_DATA<=CMD_Tmp[63:0];
					
					
				//end
				end
			6:	begin
					oAI_Start	<=1'b0;
					//oAI_DATA<=CMD_Tmp[63:0];
					
					
				//end
				end
			default:begin
					oAI_Start	<=1'b0;
					//oAI_DATA<=CMD_Tmp[63:0];
				end
			endcase


end
endmodule
