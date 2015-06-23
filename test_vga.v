

module	VGA_Pattern	(	//	Read Out Side
						oRed,
						oGreen,
						oBlue,
						iVGA_X,
						iVGA_Y,
						iVGA_CLK,
						//	Control Signals
						iRST_n,
						
						iColor_SW,
						endFrame,
						dbg_val	);

parameter R_SZ= 64;
						
						//	Read Out Side
output	reg	[9:0]	oRed;
output	reg	[9:0]	oGreen;
output	reg	[9:0]	oBlue;
input	[11:0]		iVGA_X;
input	[11:0]		iVGA_Y;
input				iVGA_CLK;
//	Control Signals
input				iRST_n;
input	[9:0]			iColor_SW;
input				endFrame;

output wire [63:0] dbg_val;
wire [63:0] dbg_val_i;

parameter ENABLE_HEAVIES= 1;

reg [15:0] chrono;
reg endFrame2;
reg endFrame3;

wire [3:0] x;
wire [3:0] y;


wire [7:0] rv_a_2;
wire [7:0] gv_a_2;
wire [7:0] bv_a_2;


Test_Sorting_Stack #( 15, R_SZ   ) high_end_2( .clk( iVGA_CLK ), .rst( ~iRST_n ), 
								.iX_video( iVGA_X ), .iY_video( iVGA_Y ),
								.oR_video( rv_a_2 ), .oG_video( gv_a_2 ), .oB_video( bv_a_2 ),
								.tumblers( iColor_SW ), .endFrame(endFrame3),
								.dbg_val(_)
							);


								
wire [7:0] mp_test_out;

assign dbg_val= iColor_SW[7] ? dbg_val_i:chrono;	

always@(posedge iVGA_CLK or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		oRed	<=	0;
		oGreen	<=	0;
		oBlue	<=	0;
		chrono <= 0;
	end
	else
	begin
		if ( endFrame2==0 && endFrame==1 )
		begin
			chrono<= chrono +1;
			endFrame3<= 1;
		end
		else
		begin
			endFrame3<= 0;
		end
		endFrame2<= endFrame;
		
		
		begin
//			oBlue		<=	iVGA_X[4] ? -1: iVGA_X;
//			oGreen	<=	iVGA_X[5] ? -1: iVGA_X;
//			oRed		<=	iVGA_X[6] ? -1: iVGA_Y;
			oBlue		<=	bv_a_2;
			oGreen	<=	gv_a_2;
			oRed		<=	rv_a_2;
		end
	end
end

endmodule



module Test_Sorting_Stack ( clk, rst, 
								iX_video, iY_video,
								oR_video, oG_video, oB_video,
								tumblers, endFrame, dbg_val	);

parameter HBIT= 15;
parameter R_SZ= 64;

input clk;
input rst;

input signed [11:0] iX_video;
input signed [11:0] iY_video;
output reg [7:0] oR_video;
output reg [7:0] oG_video;
output reg [7:0] oB_video;
input	[9:0]			tumblers;
input endFrame;
output wire [63:0] dbg_val= count;

reg [HBIT*3+2:0]generator;
reg [HBIT*3+2:0]prev_generator;
reg prev_btn;

wire cell_rst= ( iX_video==1 && iY_video==1);
wire cell_clk= ( iX_video==1 );

reg err_unsorted;
reg err_checksum;
reg err_disagreement;

wire [HBIT:0] data_in= generator;
wire [HBIT:0] _data_out;
wire [HBIT:0] _d_out_3;

reg [HBIT:0] last_data;
reg [31:0]   stack_sum;
reg [15:0]   stack_pos_count;
reg [31:0]   old_sum;

//	tumblers[4] ? increasing order : decreasing order
  wire [HBIT:0] _data_in= tumblers[4] ? -1-data_in : data_in;	
  Sorting_Tree #(HBIT,R_SZ) ctree ( clk, ~cell_clk, is_input, _data_in, _d_out_3	);
  wire [HBIT:0] d_out_3 = tumblers[4] ? -1-_d_out_3  : _d_out_3;	
  Sorting_Stack #(HBIT,R_SZ) cstack ( clk, ~cell_clk, is_input, _data_in, _data_out	);
  wire [HBIT:0] data_out= tumblers[4] ? -1-_data_out : _data_out;	

reg [11:0]count; 
wire is_input= !cell_rst && count<R_SZ;
wire is_enable=!cell_rst && count<R_SZ*2;

always@( posedge clk or posedge rst )
begin
	if ( rst )
	begin
		generator<= 32'h12345678;
		prev_generator <= 32'h12345678;
		err_unsorted<= 0;
		err_checksum<= 0;
		err_disagreement<= 0;
		last_data<= -1;
		stack_sum<= 0;
		stack_pos_count<=0;
	end
	else
	if ( cell_rst )
	begin
		count<= 0;
		stack_pos_count<= 0;
		if ( count )
		begin
			err_checksum<= ( tumblers[0] &err_checksum ) | ( stack_sum !=0 );
			stack_sum<= 0;
			old_sum<= stack_sum;
		end
		prev_btn <= tumblers[2];
		if ( tumblers[1] && !( tumblers[2] && ~prev_btn ) )
		begin
			generator <= prev_generator;
		end
		else
		begin
			prev_generator <= generator;
		end
	end
	else
	begin

		if ( cell_clk )
		begin
			if ( is_input )
			begin
				last_data <= -1;
				stack_sum <= stack_sum + data_in;
				stack_pos_count<= stack_pos_count+ (data_in==0 ? 0:1);
			end
			else if ( is_enable )
			begin
				stack_sum <= stack_sum - data_out;
				last_data<= data_out;
				stack_pos_count<= stack_pos_count- (data_out==0 ? 0:1);
				err_unsorted<=      ( tumblers[0] & err_unsorted)     | 
													( tumblers[4] && ( last_data > data_out ))|
													( ~tumblers[4] && ( last_data < data_out ));
				err_disagreement<=  ( tumblers[0] & err_disagreement) | ( data_out != d_out_3 );
			end
			generator<= generator*11 + ( generator >> 16 );
			count<= count +1;
		end
		
//		oR_video<= (is_input ? data_in[HBIT:HBIT-9] : data_out[HBIT:HBIT-9]) > iX_video && !err_unsorted ? -1:0;
//		oG_video<= stack_sum[HBIT:HBIT-9] > iX_video ? -1:0;
		oR_video<= (is_input ? show_data_in : show_d_out_3 ) > iX_video ? -1:(8'h0-err_unsorted);
		oG_video<= (is_input ? show_data_in : show_data_out) > iX_video ? -1:(8'h0-err_checksum);
		oB_video<= (is_input ?            0 : show_data_out) > iX_video ? -1:(8'h0-err_disagreement);
	end
end

wire [9:0] show_data_in = tumblers[3] ? data_in [9:0] : data_in [HBIT:HBIT-9];
wire [9:0] show_data_out= tumblers[3] ? data_out[9:0] : data_out[HBIT:HBIT-9];
wire [9:0] show_d_out_3 = tumblers[3] ? d_out_3 [9:0] : d_out_3 [HBIT:HBIT-9];

endmodule



