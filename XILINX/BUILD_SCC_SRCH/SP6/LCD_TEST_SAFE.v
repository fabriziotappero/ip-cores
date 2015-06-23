module	LCD_TEST (	//	Host Side
					iCLK,iRST_N,msg_in,
					//	LCD Side
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS	);
//	Host Side
input			iCLK,iRST_N;
input 	[2:0]		msg_in;
//	LCD Side
output	[7:0]	LCD_DATA;
output			LCD_RW,LCD_EN,LCD_RS;
//	Internal Wires/Registers
reg	[5:0]	LUT_INDEX;
reg[5:0]	LUT_INDEX_NEXT;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST,mLCD_nxt_ST;
reg	[17:0]	mDLY;
reg	[17:0]	mDLY_NEXT;
reg			mLCD_Start;
reg			mLCD_Start_NEXT;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
reg [2:0] msg_in_int;
wire		mLCD_Done;

parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE1+32+1;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		mLCD_ST<=4;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
		msg_in_int  <=  0;
	end
	else
	begin
		mLCD_ST<=mLCD_nxt_ST;
		LUT_INDEX<=LUT_INDEX_NEXT;
		mDLY<=mDLY_NEXT;
		mLCD_Start<=mLCD_Start_NEXT;
		msg_in_int<=msg_in;
		mLCD_DATA	<=	LUT_DATA[7:0];
		mLCD_RS		<=	LUT_DATA[8];
	end
end


//always@(mLCD_ST or msg_in or msg_in_int or LUT_INDEX or LUT_DATA or msg_in_int)
always@(*)
	begin
			case(mLCD_ST)
			0:	begin
					mLCD_Start_NEXT	<=	1;
					mDLY_NEXT	<=	mDLY;
					if(msg_in_int!=msg_in)
						begin
							LUT_INDEX_NEXT<=0;
						end
					else begin
							LUT_INDEX_NEXT<=LUT_INDEX;
						 end	
							
					if( LUT_INDEX<LUT_SIZE)
						mLCD_nxt_ST		<=	1;
					else
						mLCD_nxt_ST		<=	0;
				end
			1:	begin
					mDLY_NEXT	<=	mDLY;
					LUT_INDEX_NEXT<=LUT_INDEX;
					if(mLCD_Done)
					begin
						mLCD_Start_NEXT	<=	0;
						mLCD_nxt_ST		<=	2;					
					end
					else begin
						mLCD_Start_NEXT	<=	mLCD_Start;
						mLCD_nxt_ST		<=	1;		
					end

				end
			2:	begin
					mLCD_Start_NEXT	<=	mLCD_Start;
					LUT_INDEX_NEXT<=LUT_INDEX;
					if(mDLY<18'h3FFFE)
					begin
						mDLY_NEXT	<=	mDLY+1;
						mLCD_nxt_ST	<=	2;
					end
					else
					begin
						mDLY_NEXT	<=	0;
						mLCD_nxt_ST	<=	3;
					end
				end
			3:	begin
					mLCD_Start_NEXT	<=	mLCD_Start;
					mDLY_NEXT	<=	mDLY;
					LUT_INDEX_NEXT	<=	LUT_INDEX+1;
					mLCD_nxt_ST	<=	0;
				end
			4:	begin
					mLCD_Start_NEXT	<=	0;
					LUT_INDEX_NEXT	<=	0;
					mLCD_nxt_ST	<=	0;
					mDLY_NEXT	<=	0;

				end
			default: begin
				end
			endcase
	end

always
begin
case(msg_in_int)
3'b000:
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h142;	//	Banc-d-Test SAFE
	LCD_LINE1+1:	LUT_DATA	<=	9'h161;
	LCD_LINE1+2:	LUT_DATA	<=	9'h16E;
	LCD_LINE1+3:	LUT_DATA	<=	9'h163;
	LCD_LINE1+4:	LUT_DATA	<=	9'h12D;
	LCD_LINE1+5:	LUT_DATA	<=	9'h164;
	LCD_LINE1+6:	LUT_DATA	<=	9'h12D;
	LCD_LINE1+7:	LUT_DATA	<=	9'h154;
	LCD_LINE1+8:	LUT_DATA	<=	9'h165;
	LCD_LINE1+9:	LUT_DATA	<=	9'h173;
	LCD_LINE1+10:	LUT_DATA	<=	9'h174;
	LCD_LINE1+11:	LUT_DATA	<=	9'h120;
	LCD_LINE1+12:	LUT_DATA	<=	9'h153;
	LCD_LINE1+13:	LUT_DATA	<=	9'h141;
	LCD_LINE1+14:	LUT_DATA	<=	9'h146;
	LCD_LINE1+15:	LUT_DATA	<=	9'h145;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	//	Line 2
	LCD_LINE2+0:	LUT_DATA	<=	9'h142;	//	Bienvenue A Bord
	LCD_LINE2+1:	LUT_DATA	<=	9'h169;
	LCD_LINE2+2:	LUT_DATA	<=	9'h165;
	LCD_LINE2+3:	LUT_DATA	<=	9'h16E;
	LCD_LINE2+4:	LUT_DATA	<=	9'h176;
	LCD_LINE2+5:	LUT_DATA	<=	9'h165;
	LCD_LINE2+6:	LUT_DATA	<=	9'h16E;
	LCD_LINE2+7:	LUT_DATA	<=	9'h175;
	LCD_LINE2+8:	LUT_DATA	<=	9'h165;
	LCD_LINE2+9:	LUT_DATA	<=	9'h120;
	LCD_LINE2+10:	LUT_DATA	<=	9'h141;
	LCD_LINE2+11:	LUT_DATA	<=	9'h120;
	LCD_LINE2+12:	LUT_DATA	<=	9'h142;
	LCD_LINE2+13:	LUT_DATA	<=	9'h16F;
	LCD_LINE2+14:	LUT_DATA	<=	9'h172;
	LCD_LINE2+15:	LUT_DATA	<=	9'h164;
	default:		LUT_DATA	<=  9'h120;
	endcase

3'b001:
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	STATE: INIT
	LCD_LINE1+1:	LUT_DATA	<=	9'h154;
	LCD_LINE1+2:	LUT_DATA	<=	9'h141;
	LCD_LINE1+3:	LUT_DATA	<=	9'h154;
	LCD_LINE1+4:	LUT_DATA	<=	9'h145;
	LCD_LINE1+5:	LUT_DATA	<=	9'h13A;
	LCD_LINE1+6:	LUT_DATA	<=	9'h120;
	LCD_LINE1+7:	LUT_DATA	<=	9'h149;
	LCD_LINE1+8:	LUT_DATA	<=	9'h14E;
	LCD_LINE1+9:	LUT_DATA	<=	9'h149;
	LCD_LINE1+10:	LUT_DATA	<=	9'h154;
	LCD_LINE1+11:	LUT_DATA	<=	9'h120;
	LCD_LINE1+12:	LUT_DATA	<=	9'h120;
	LCD_LINE1+13:	LUT_DATA	<=	9'h120;
	LCD_LINE1+14:	LUT_DATA	<=	9'h120;
	LCD_LINE1+15:	LUT_DATA	<=	9'h120;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	default:		LUT_DATA	<=  9'h120;
	endcase
3'b010:
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	STATE: CONFIG
	LCD_LINE1+1:	LUT_DATA	<=	9'h154;
	LCD_LINE1+2:	LUT_DATA	<=	9'h141;
	LCD_LINE1+3:	LUT_DATA	<=	9'h154;
	LCD_LINE1+4:	LUT_DATA	<=	9'h145;
	LCD_LINE1+5:	LUT_DATA	<=	9'h13A;
	LCD_LINE1+6:	LUT_DATA	<=	9'h120;
	LCD_LINE1+7:	LUT_DATA	<=	9'h143;
	LCD_LINE1+8:	LUT_DATA	<=	9'h14F;
	LCD_LINE1+9:	LUT_DATA	<=	9'h14E;
	LCD_LINE1+10:	LUT_DATA	<=	9'h146;
	LCD_LINE1+11:	LUT_DATA	<=	9'h149;
	LCD_LINE1+12:	LUT_DATA	<=	9'h147;
	LCD_LINE1+13:	LUT_DATA	<=	9'h120;
	LCD_LINE1+14:	LUT_DATA	<=	9'h120;
	LCD_LINE1+15:	LUT_DATA	<=	9'h120;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	default:		LUT_DATA	<=  9'h120;
	endcase
3'b011:
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h153;	// STATE: RUNNING
	LCD_LINE1+1:	LUT_DATA	<=	9'h154;
	LCD_LINE1+2:	LUT_DATA	<=	9'h141;
	LCD_LINE1+3:	LUT_DATA	<=	9'h154;
	LCD_LINE1+4:	LUT_DATA	<=	9'h145;
	LCD_LINE1+5:	LUT_DATA	<=	9'h13A;
	LCD_LINE1+6:	LUT_DATA	<=	9'h120;
	LCD_LINE1+7:	LUT_DATA	<=	9'h152;
	LCD_LINE1+8:	LUT_DATA	<=	9'h155;
	LCD_LINE1+9:	LUT_DATA	<=	9'h14E;
	LCD_LINE1+10:	LUT_DATA	<=	9'h14E;
	LCD_LINE1+11:	LUT_DATA	<=	9'h149;
	LCD_LINE1+12:	LUT_DATA	<=	9'h14E;
	LCD_LINE1+13:	LUT_DATA	<=	9'h147;
	LCD_LINE1+14:	LUT_DATA	<=	9'h120;
	LCD_LINE1+15:	LUT_DATA	<=	9'h120;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	default:		LUT_DATA	<=  9'h120;
	endcase
3'b111:
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h153;	// STATE: CONNECTING
	LCD_LINE1+1:	LUT_DATA	<=	9'h154;
	LCD_LINE1+2:	LUT_DATA	<=	9'h141;
	LCD_LINE1+3:	LUT_DATA	<=	9'h154;
	LCD_LINE1+4:	LUT_DATA	<=	9'h145;
	LCD_LINE1+5:	LUT_DATA	<=	9'h13A;
	LCD_LINE1+6:	LUT_DATA	<=	9'h120;
	LCD_LINE1+7:	LUT_DATA	<=	9'h143;
	LCD_LINE1+8:	LUT_DATA	<=	9'h14F;
	LCD_LINE1+9:	LUT_DATA	<=	9'h14E;
	LCD_LINE1+10:	LUT_DATA	<=	9'h14E;
	LCD_LINE1+11:	LUT_DATA	<=	9'h145;
	LCD_LINE1+12:	LUT_DATA	<=	9'h143;
	LCD_LINE1+13:	LUT_DATA	<=	9'h154;
	LCD_LINE1+14:	LUT_DATA	<=	9'h149;
	LCD_LINE1+15:	LUT_DATA	<=	9'h14E;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	default:		LUT_DATA	<=  9'h120;
	endcase
default:
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h153;	//	STATE: ERROR
	LCD_LINE1+1:	LUT_DATA	<=	9'h154;
	LCD_LINE1+2:	LUT_DATA	<=	9'h141;
	LCD_LINE1+3:	LUT_DATA	<=	9'h154;
	LCD_LINE1+4:	LUT_DATA	<=	9'h145;
	LCD_LINE1+5:	LUT_DATA	<=	9'h13A;
	LCD_LINE1+6:	LUT_DATA	<=	9'h120;
	LCD_LINE1+7:	LUT_DATA	<=	9'h145;
	LCD_LINE1+8:	LUT_DATA	<=	9'h152;
	LCD_LINE1+9:	LUT_DATA	<=	9'h152;
	LCD_LINE1+10:	LUT_DATA	<=	9'h14F;
	LCD_LINE1+11:	LUT_DATA	<=	9'h152;
	LCD_LINE1+12:	LUT_DATA	<=	9'h120;
	LCD_LINE1+13:	LUT_DATA	<=	9'h120;
	LCD_LINE1+14:	LUT_DATA	<=	9'h120;
	LCD_LINE1+15:	LUT_DATA	<=	9'h120;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
//	//	Line 2
	default:		LUT_DATA	<=  9'h120;
	endcase


endcase


end

LCD_Controller 		u0	(	//	Host Side
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(iCLK),
							.iRST_N(iRST_N),
							//	LCD Interface
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule
