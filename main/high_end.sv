


module Cell_life ( clk, cell_rst, 	in_mm, in_m0, in_mp, 
										in_0m,        in_0p, 
										in_pm, in_p0, in_pp, init, 
																	state );

input clk;
input cell_rst;

input in_mm;
input in_m0;
input in_mp;
input in_0m;
input in_0p;
input in_pm;
input in_p0;
input in_pp;
input init;

output reg state;


always@(posedge clk )
begin
	if ( cell_rst )
	begin
		state<= init;
	end
	else
	begin
		state <= (state | 	(  in_mm+ in_m0+ in_mp+ 
										in_0m+        in_0p+ 
										in_pm+ in_p0+ in_pp ))==3;
	end
end
endmodule




module VGA_HighEnd ( clk, rst, 
								iX_video, iY_video,
								oR_video, oG_video, oB_video,
								tumblers, endFrame, dbg_val	);

parameter RES_X_H= 1240;
parameter RES_Y_H= 1024;
parameter XY_STEP_H= 7;
parameter RES_X_L= 640;
parameter RES_Y_L= 480;
parameter XY_STEP_L= 8;

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

wire [31:0] V_out2;

wire high_res= 1;

reg [31:0] count;
reg [31:0] count_py;


parameter R_SZ= 27;
parameter R_SZp= R_SZ +1;

wire  cell_out[R_SZ:0][R_SZ:0];

wire  cell_in_mm[R_SZ:0][R_SZ:0];
wire  cell_in_m0[R_SZ:0][R_SZ:0];
wire  cell_in_mp[R_SZ:0][R_SZ:0];

wire  cell_in_0m[R_SZ:0][R_SZ:0];
wire  cell_in_0p[R_SZ:0][R_SZ:0];

wire  cell_in_pm[R_SZ:0][R_SZ:0];
wire  cell_in_p0[R_SZ:0][R_SZ:0];
wire  cell_in_pp[R_SZ:0][R_SZ:0];

wire  ribbon_init[R_SZ:0][R_SZ:0]; 
//wire [R_SZ:0] token_in;
//wire [R_SZ:0] token_out; 
wire cell_rst= (iY_video==1);
wire cell_clk= (iX_video==1 && iY_video %R_SZp==1);

Cell_life ribbon[R_SZ:0][R_SZ:0] ( cell_clk, cell_rst, cell_in_mm, cell_in_m0, cell_in_mp, 
																		cell_in_0m,        		cell_in_0p, 
																cell_in_pm, cell_in_p0, cell_in_pp, ribbon_init, cell_out );

generate
  genvar i,j;
  for (i=0; i<=R_SZ; i=i+1) 
  begin : block_name01
	  for (j=0; j<=R_SZ; j=j+1) 
	  begin : block_name02
			if ( i==R_SZp/2 && j>=8 && j<24 )
				assign ribbon_init[i][j]= 1;
			else if ( i==R_SZp/2 && j>=3 && j<24 )
				assign ribbon_init[i][j]= tumblers[j-3];
			else
				assign ribbon_init[i][j]= 0;
	  end
  end
  
  for (i=0; i<=R_SZ; i=i+1) 
  begin : block_name1
	  for (j=0; j<R_SZ; j=j+1) 
	  begin : block_name2
		 assign cell_in_m0[i][j+1]= cell_out[i][j];
		 assign cell_in_0m[j+1][i]= cell_out[j][i];
		 assign cell_in_p0[i][j]= cell_out[i][j+1];
		 assign cell_in_0p[j][i]= cell_out[j+1][i];
	  end
	  assign cell_in_m0[i][0]= 0;
	  assign cell_in_mm[i][0]= 0;
	  assign cell_in_0m[0][i]= 0;
	  assign cell_in_p0[i][R_SZ]= 0;
	  assign cell_in_0p[R_SZ][i]= 0;
  end
  
  for (i=0; i<R_SZ; i=i+1) 
  begin : block21
	  for (j=0; j<R_SZ; j=j+1) 
	  begin : block22
		 assign cell_in_mm[i+1][j+1]= cell_out[i][j];
		 assign cell_in_mp[i][j+1]= cell_out[i+1][j];
		 assign cell_in_pm[i+1][j]= cell_out[i][j+1];
		 assign cell_in_pp[i][j]= cell_out[i+1][j+1];
	  end
  end
  
//  begin : block_name1
//  end
endgenerate

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
		count= 0;
	end
	else
	begin
		if ( iX_video==1 && iY_video==1 )
		begin
			count<= count +1;
		end
		else if ( iX_video==1 )
		begin
			count_py<= count_py +1;
		end
		
		oR_video= {8{cell_out[ iX_video ][ iY_video % (R_SZ+1) ]}};
		oG_video= {8{cell_out[ iX_video ][ iY_video % (R_SZ+1) ]}};
		oB_video= {8{cell_out[ iX_video ][ iY_video % (R_SZ+1) ]}};
	end
end
endmodule









module Cell_110 ( clk, rst, in_m, in_p, out_0, broad );

input clk;
input rst;

input in_m;
input in_p;

output out_0= state;

input broad;

//input token_in;
//output reg token_out;
reg state;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
		state<= broad;
	end
	else
	begin
		case( { in_m, state, in_p })
			3'd0: state <= 0;
			3'd1: state <= 0;
			3'd2: state <= 1;
			3'd3: state <= 1;
			3'd4: state <= 1;
			3'd5: state <= 1;
			3'd6: state <= 1;
			3'd7: state <= 0;
		endcase
	end
end
endmodule




module VGA_HighEnd_2 ( clk, rst, 
								iX_video, iY_video,
								oR_video, oG_video, oB_video,
								tumblers, endFrame, dbg_val	);

parameter RES_X_H= 1240;
parameter RES_Y_H= 1024;
parameter XY_STEP_H= 7;
parameter RES_X_L= 640;
parameter RES_Y_L= 480;
parameter XY_STEP_L= 8;

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

wire [31:0] V_out2;

wire high_res= 1;

reg [31:0] count;
reg [31:0] count_py;


wire signed [11:0] x;
wire signed [11:0] y;
assign x= (iX_video- (high_res ? RES_X_H/2 :RES_X_L/2 ));
assign y= (iY_video- (high_res ? RES_Y_H/2 :RES_Y_L/2 ));

parameter R_SZ= 1280;

wire [R_SZ:0] cell_out;
wire [R_SZ:0] cell_in_m;
wire [R_SZ:0] cell_in_p;
wire [R_SZ:0] ribbon_init; 
//wire [R_SZ:0] token_in;
//wire [R_SZ:0] token_out; 
wire cell_rst= (iY_video==1);
wire cell_clk= (iX_video==1);

Cell_110 ribbon[R_SZ:0] ( cell_clk, cell_rst, cell_in_m, cell_in_p, cell_out, ribbon_init );

assign ribbon_init[99:0] =0;
assign ribbon_init[125:100] =count[31:6];
assign ribbon_init[R_SZ:126] =0;
//
//assign ribbon_init[99:0] =0;
//assign ribbon_init[125:100] =count[31:6];
//assign ribbon_init[R_SZ:126] =0;

generate
  genvar i;
  for (i=0; i<R_SZ; i=i+1) 
  begin : block_name
	 assign cell_in_m[i+1]= cell_out[i];
	 assign cell_in_p[i]= cell_out[i+1];
  end
//  begin : block_name1
  assign cell_in_m[0]= 0;
  assign cell_in_p[R_SZ]= 0;
//  end
endgenerate

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
		count= 0;
	end
	else
	begin
		if ( iX_video==1 && iY_video==1 )
		begin
			count<= count +1;
		end
		else if ( iX_video==1 )
		begin
			count_py<= count_py +1;
		end
		
		oR_video= {8{cell_out[ iX_video ]}};
		oG_video= {8{cell_out[ iX_video ]}};
		oB_video= {8{cell_out[ iX_video ]}};
	end
end
endmodule




