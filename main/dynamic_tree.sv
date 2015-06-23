




module Dyna_Tree ( clk, glob_com, dataIn, dataOut );

parameter HBIT= 3;
parameter TREE_LEVEL= 4;
parameter IMRIGHT= 0;

input clk;
input [1:0] glob_com;

output TPort dataOut;
input  TPort dataIn;


TPort fromLeft;
TPort fromRight;

Cell_DT_Inner #( HBIT, IMRIGHT ) inner ( clk, glob_com, dataIn, fromLeft, fromRight, dataOut );

generate
if ( TREE_LEVEL >0 )
begin
	Dyna_Tree #( HBIT, TREE_LEVEL-1, 0 ) leftSubTree  ( clk, glob_com, dataOut, fromLeft );
	Dyna_Tree #( HBIT, TREE_LEVEL-1, 1 ) rightSubTree ( clk, glob_com, dataOut, fromRight );
end
else
begin
	assign fromLeft.msg =VMS_STOP;
	assign fromRight.msg=VMS_STOP;
end
endgenerate


endmodule






typedef enum bit[3:0] { 	VK_EMPTY=4'h0, 
						VK_DUMMY1,
						VK_DUMMY2,
						VK_DUMMY3,
						
						VK_DUMMY4,
						VK_TRANSIT,
						VK_APPLY,
						VK_EOF,
						
						VK_K[2]= 4'h8,
						
						VK_S[3]= 4'd12,
						VK_DUMMY5
		} VKind;

function logic [1:0] CH_NUM( logic [3:0] k );
CH_NUM = k[1:0];
endfunction		
		
typedef enum bit[3:0] { 	VMS_EMPTY=4'h0, 
						VMS_BUSY,
						VMS_READY,
						VMS_BOMB,

						VMS_READ,
						VMS_APPLY,
						VMS_STOP		//	end of tree
		} VMeta;

typedef enum bit[1:0]{ 	TO_PARENT=2'h0, 
						TO_CHILDREN,
						TO_LEFT,
						TO_RIGHT
		} VTarget;

typedef struct{
bit	[3:0] msg;
bit	[1:0] tgt;
		} TPort;

		
		
		
		
		
		
module Cell_DT_Inner ( clk, glob_com, i_fromParent, i_fromLeft, i_fromRight, message );
parameter HBIT= 7;
parameter IMRIGHT= 0;

input clk;
input [1:0] glob_com;

input  TPort i_fromParent;
input  TPort i_fromLeft;
input  TPort i_fromRight;

wire [HBIT:0] fromParent= ((IMRIGHT==0) && ( i_fromParent.tgt == TO_CHILDREN || i_fromParent.tgt == TO_LEFT )) ||
							  ((IMRIGHT==1) && ( i_fromParent.tgt == TO_CHILDREN || i_fromParent.tgt == TO_RIGHT ))
							  ? i_fromParent.msg : 4'h0;

wire [HBIT:0] fromLeft=   ( i_fromLeft.tgt == TO_PARENT  ) ? i_fromLeft.msg  : 4'h0;
wire [HBIT:0] fromRight=  ( i_fromRight.tgt == TO_PARENT ) ? i_fromRight.msg : 4'h0;

reg [HBIT:0] value;
output TPort message;
VMeta        state;
reg [3:0] step;

always@(posedge clk )
begin
	case( glob_com )
	0:								//	working mode
	begin
		case( state )
		VMS_EMPTY:					//	sleeping
		begin
			if ( !value )	
			begin	//	writing left
				value <=  fromParent;//==VK_APPLY || fromParent==VK_EMPTY || fromParent==VK_K0 ? fromParent : VK_DUMMY5;		//	write self
				if ( fromParent && CH_NUM( fromParent )==0 )
				begin
					message.msg <= fromParent;
					message.tgt <= TO_PARENT;
					state       <= VMS_READY;
				end
			end
			else if ( CH_NUM( value )!=0 && fromLeft==0 )
			begin								//	write left
				message.msg <= fromParent;
				message.tgt <= TO_LEFT;
			end
			else if ( CH_NUM( value )==2 && fromRight==0 )
			begin								//	begin writing right
				message.msg <= fromParent;
				message.tgt <= TO_RIGHT;
			end
			else
			begin
				message.msg <= VMS_BUSY;
				message.tgt <= TO_PARENT;
				state       <= VMS_BUSY;
			end
		end
		
		VMS_BUSY:	
		begin
			if ( fromLeft && ( CH_NUM( value )==1 || fromRight ) )
			begin
				if ( value != VK_APPLY )
				begin
					message.msg <= value;
					state       <= VMS_READY;
				end
				else
				begin
					case (step)
					0:
					begin
						message.msg <= VMS_READ;
						message.tgt <= TO_RIGHT;
						step <= 1;
					end
					1:
					begin
						message.msg <= VMS_APPLY;
						message.tgt <= TO_LEFT;
						step <= 2;
					end
					2:
					begin
						if ( fromRight == VK_EOF )
						begin
							step <= 3;
							message.msg <= VK_EMPTY;
						end
						else
						begin
							message.tgt <= TO_LEFT;
							message.msg <= fromRight;
						end
					end
					3:
					begin
						value       <= VK_TRANSIT;
						state       <= VMS_BUSY;
						message.msg <= VMS_BOMB;	
						message.tgt <= TO_RIGHT;
						step <= 0;
					end
					endcase
				end
			end
		end
		
		VMS_READ:	
		begin
			if ( message.msg == VK_EOF )
			begin
				message.msg <= value;		//	end read 2
				state       <= VMS_READY;
				step <= 0;
			end
			else if ( step==0 && fromLeft != VK_EOF )
			begin
				message.msg <= fromLeft;		//	transfer left
				message.tgt <= TO_PARENT;
			end
			else if ( CH_NUM( value )==1 )
			begin
				message.tgt <= TO_PARENT;
				message.msg <= VK_EOF;		//	end read 1.2
			end
			else if ( step==0 )
			begin
				message.msg <= VMS_READ;		//	command right
				message.tgt <= TO_RIGHT;
				step <= 1;
			end
			else if ( fromRight != VK_EOF )
			begin
				message.msg <= fromRight;		//	transfer right
				message.tgt <= TO_PARENT;
			end
			else 
			begin
				message.msg <= VK_EOF;		//	end read 1.3
			end
		

		end
		
		VMS_READY:	
		begin
			case( fromParent )
			VMS_BOMB:						//	clear
			begin
				message.msg <= VMS_BOMB;	
				message.tgt <= TO_CHILDREN;
				state    	<= VMS_EMPTY;
				value    	<= VK_EMPTY;
			end
			VMS_READ:						//	read self
			begin
				if ( CH_NUM( value )==0 )
				begin									//	begin 1
					message.msg <= VK_EOF;		//	end read 1.1
				end
				else 
				begin									//	begin 2
					message.msg <= VMS_READ;	//	command left
					message.tgt <= TO_LEFT;
				end
				if ( value != VK_TRANSIT || step==1 )
				begin
					state       <= VMS_READ;
					step 			<= 0;
				end
				else
					step <= 1;
			end
			VMS_APPLY:						//	apply string from parent to itself
			begin
				if ( CH_NUM( value )!=0 )
				begin
					message.msg <= VMS_APPLY;	
					message.tgt <= TO_CHILDREN;
				end
				begin
					case( value )
					VK_K0,
					VK_S0,
					VK_S1:
					begin								      //	add argument
						value[1:0] <= value[1:0] +1;	//	K0 -> K1, S0 -> S1, S1 -> S2
						state      <= VMS_EMPTY;		//	WRITE
					end
					VK_K1:							//	K main
					begin
						value       <= VK_TRANSIT;
						state       <= VMS_READY;
						message.msg <= VMS_BOMB;	
						message.tgt <= TO_RIGHT;
					end
					VK_S2:							//	S main
					begin
						state       <= VMS_APPLY;
					end
					endcase
				end
			end
			default:
			if ( value == VK_TRANSIT )
			begin
				message.msg <= fromLeft;
				message.tgt <= TO_PARENT;
			end
			else
			begin
				message.msg <= value;	
				message.tgt <= TO_PARENT;
			end
			endcase
		end
		
		VMS_APPLY:	
		if ( fromParent != VK_EOF )
		begin
			message.msg <= fromParent;	//	Sxyz -> `(_`_xz) (_`_yz)		
			message.tgt <= TO_CHILDREN;
		end
		else
		begin
			message.msg <= VK_EMPTY;	
			state       <= VMS_BUSY;
			value			<= VK_APPLY;	//	Sxyz -> _`_ (`xz) (`yz)	
		end
		endcase
	end
	default:								//	reset mode	
	begin
		state    <= VMS_EMPTY;
		value    <= VK_EMPTY;
		message.msg  <= VMS_EMPTY;
		step 		<= 0;
	end
	endcase
end

endmodule



