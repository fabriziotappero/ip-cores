

module Ibniz_adapter ( clk, rst, 
								iX_video, iY_video,
//								T_in, X_in, Y_in, 
//								V_out,
								oR_video, oG_video, oB_video,
								tumblers, endFrame, dbg_val	);

parameter RES_X_H= 1240;
parameter RES_Y_H= 1024;
parameter XY_STEP_H= 7;
parameter RES_X_L= 640;
parameter RES_Y_L= 480;
parameter XY_STEP_L= 8;

parameter ENABLE_HEAVIES= 1;
parameter SCENE_COMPILED= -1;//by default all compiled, change if short on LE's

input clk;
input rst;

input signed [11:0] iX_video;
input signed [11:0] iY_video;
output reg [7:0] oR_video;
output reg [7:0] oG_video;
output reg [7:0] oB_video;
input	[9:0]			tumblers;
input endFrame;
output wire [63:0] dbg_val;

wire signed [31:0] T_in;
wire signed [31:0] X_in;
wire signed [31:0] Y_in;

wire [31:0] V_out2;

wire high_res= 1;

reg [15:0] count;

assign T_in[15:0]=0;
assign T_in[31:16]=count;

wire signed [11:0] x;
wire signed [11:0] y;
assign x= (iX_video- (high_res ? RES_X_H/2 :RES_X_L/2 ));
assign y= (iY_video- (high_res ? RES_Y_H/2 :RES_Y_L/2 ));

assign X_in= x<<<(high_res ? XY_STEP_H :XY_STEP_L );
assign Y_in= y<<<(high_res ? XY_STEP_H :XY_STEP_L );

wire [31:0] V_out [0:7];


assign V_out2 = SCENE_COMPILED>=0 ? V_out[SCENE_COMPILED] : 
					tumblers[0] ? 
					(tumblers[1] ? 
						(tumblers[2] ? V_out[7] : V_out[3]) : 
						(tumblers[2] ? V_out[5] : V_out[1]) ) :
					((tumblers[1]&&ENABLE_HEAVIES==1) ? 
						( tumblers[2] ? V_out[6] : V_out[2]) : 
						(tumblers[2] ? V_out[4] : V_out[0]) );
Ibniz_generator1 ig0( clk, rst, tumblers[2:0]==0 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[0] );
Ibniz_generator4 ig1( clk, rst, tumblers[2:0]==1 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[1] );
Ibniz_generator2 ig2( clk, rst, tumblers[2:0]==2 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[2] );
Ibniz_generator3 ig3( clk, rst, tumblers[2:0]==3 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[3] );
Ibniz_generator6 ig4( clk, rst, tumblers[2:0]==4 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[4] );
Ibniz_generator5 ig5( clk, rst, tumblers[2:0]==5 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[5] );
Ibniz_generator7 ig6( clk, rst, tumblers[2:0]==6 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[6] );
Ibniz_generator0 ig7( clk, rst, tumblers[2:0]==7 || SCENE_COMPILED>=0, T_in, X_in, Y_in, V_out[7] );

wire signed [15:0] bright= V_out2[15:8];
wire signed [7:0] hue2= V_out2[23:16];
wire signed [7:0] hue1= V_out2[31:24];
wire signed [15:0] C= bright;// -16;
wire signed [15:0] D= (hue1^8'h80) -128;
wire signed [15:0] E= (hue2^8'h80) -128;
wire signed [11:0] B_video= (( 298*C + 409*E + 128) >>> 8);
wire signed [11:0] G_video= (( 298*C - 100*D - 208*E + 128) >>> 8);
wire signed [11:0] R_video= (( 298*C + 516*D + 128) >>> 8);

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
		count= 0;
	end
	else
	begin
		if ( endFrame )
			count<= count +1;
		//	Y'UV ->RGB
		oR_video= R_video<0 ? 0 : ( R_video>255 ? 255 : R_video);
		oG_video= G_video<0 ? 0 : ( G_video>255 ? 255 : G_video);
		oB_video= B_video<0 ? 0 : ( B_video>255 ? 255 : B_video);
	end
end
endmodule

