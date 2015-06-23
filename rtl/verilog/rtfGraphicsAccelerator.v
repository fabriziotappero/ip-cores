`define NULL		8'd0
`define DRAW_PIXEL	8'd1
`define DRAW_LINE	8'd2
`define LINETO		8'd3
`define RECTANGLE	8'd4
`define RECTANGLE2	8'd5
`define RECTANGLE3	8'd6
`define RECTANGLE4	8'd7

module rtfGraphicsAccelerator (
rst_i,
clk_i,

s_cyc_i,
s_stb_i,
s_we_i,
s_ack_o,
s_sel_i,
s_adr_i,
s_dat_i,
s_dat_o,

m_cyc_o,
m_stb_o,
m_we_o,
m_ack_i,
m_sel_o,
m_adr_o,
m_dat_i,
m_dat_o
);
parameter PPL = 16'd416;		// pixels per line
parameter IDLE = 8'd0;
parameter DRAWPIXEL = 8'd1;
parameter DL_SETPIXEL = 8'd2;
parameter DL_CALCE2 = 8'd3;
parameter DL_TEST = 8'd4;
parameter DL_TEST2 = 8'd5;

input rst_i;
input clk_i;

input s_cyc_i;
input s_stb_i;
output s_ack_o;
input s_we_i;
input [1:0] s_sel_i;
input [31:0] s_adr_i;
input [15:0] s_dat_i;
output [15:0] s_dat_o;

output m_cyc_o;
reg m_cyc_o;
output m_stb_o;
reg m_stb_o;
output m_we_o;
reg m_we_o;
input m_ack_i;
output [1:0] m_sel_o;
reg [1:0] m_sel_o;
output [31:0] m_adr_o;
reg [31:0] m_adr_o;
input [15:0] m_dat_i;
output [15:0] m_dat_o;
reg [15:0] m_dat_o;

reg [7:0] cmd;
reg ps;						// pen select
reg [7:0] PenColor8;
reg [7:0] FillColor8;
reg [31:0] PenColor;
reg [31:0] FillColor;
reg [15:0] x0,y0,x1,y1;
reg [15:0] x0a,y0a,x1a,y1a;

reg [15:0] cx,cy;			// graphics cursor position
wire [31:0] ma = 32'h020000 + cy * PPL + cx;
reg signed [15:0] dx,dy;
reg signed [15:0] sx,sy;
reg signed [15:0] err;
wire signed [15:0] e2 = err << 1;
reg [7:0] state;

wire cs = s_cyc_i && s_stb_i && (s_adr_i[31:8]==24'hFFDA_E0);
assign s_ack_o = cs;

always @(posedge clk_i)
if (rst_i) begin
	x0 <= 16'd0;
	y0 <= 16'd0;
	x1 <= 16'd0;
	y1 <= 16'd0;
	cx <= 16'd0;
	cy <= 16'd0;
	state <= IDLE;
end
else begin
	if (cs & s_we_i) begin
		case(s_adr_i[4:1])
		8'd0:	begin PenColor[31:16] <= s_dat_i; PenColor8[7:5] <= s_dat_i[7:5]; end
		8'd1:	begin PenColor[15: 0] <= s_dat_i; PenColor8[4:2] <= s_dat_i[15:13]; PenColor8[1:0] <= s_dat_i[7:6]; end
		8'd2:	begin FillColor[31:16] <= s_dat_i; FillColor8[7:5] <= s_dat_i[7:5]; end
		8'd3:	begin FillColor[15: 0] <= s_dat_i; FillColor8[4:2] <= s_dat_i[15:13]; FillColor8[1:0] <= s_dat_i[7:6]; end
		8'd4:	x0 <= s_dat_i;
		8'd5:	y0 <= s_dat_i;
		8'd6:	x1 <= s_dat_i;
		8'd7:	y1 <= s_dat_i;
		8'd15:	cmd <= s_dat_i;
		endcase
	end

case(state)
IDLE:
	begin
		cx <= x0;
		cy <= y0;
		dx <= x1 < x0 ? x0-x1 : x1-x0;
		dy <= y1 < y0 ? y0-y1 : y1-y0;
		sx <= x0 < x1 ? 1 : -1;
		sy <= y0 < y1 ? 1 : -1;
		err <= dx-dy;
		if (cmd==`DRAW_PIXEL) begin
			state <= DRAWPIXEL;
			cmd <= `NULL;
		end
		else if (cmd==`DRAW_LINE) begin
			state <= DL_SETPIXEL;
			cmd <= `NULL;
		end
		else if (cmd==`LINETO) begin
			x1 <= x0;
			y1 <= y0;
			x0 <= cx;
			y0 <= cy;
			cmd <= `DRAW_LINE;
		end
		else if (cmd==`RECTANGLE) begin
			x0a <= x0;
			y0a <= y0;
			x1a <= x1;
			y1a <= y1;
			y1 <= y0;
			cmd <= `RECTANGLE2;
			state <= DL_SETPIXEL;
		end
		else if (cmd==`RECTANGLE2) begin
			x0 <= x1a;
			y0 <= y0a;
			x1 <= x1a;
			y1 <= y1a;
			cmd <= `RECTANGLE3;
			state <= DL_SETPIXEL;
		end
		else if (cmd==`RECTANGLE3) begin
			y0 <= y1a;
			x0 <= x1a;
			x1 <= x0a;
			y1 <= y1a;
			cmd <= `RECTANGLE4;
			state <= DL_SETPIXEL;
		end
		else if (cmd==`RECTANGLE4) begin
			x0 <= x0a;
			y0 <= y1a;
			x1 <= x0a;
			y1 <= y0a;
			cmd <= `NULL;
			state <= DL_SETPIXEL;
		end
	end

DRAWPIXEL:
	if (!m_cyc_o) begin
		m_cyc_o <= 1'b1;
		m_stb_o <= 1'b1;
		m_we_o <= 1'b1;
		m_sel_o <= {cx[0],~cx[0]};
		m_adr_o <= ma;
		m_dat_o <= {2{PenColor8}};
	end
	else if (m_ack_i) begin
		m_cyc_o <= 1'b0;
		m_stb_o <= 1'b0;
		m_sel_o <= 2'b00;
		m_we_o <= 1'b0;
		state <= IDLE;
	end

DL_SETPIXEL:
	if (!m_cyc_o) begin
		m_cyc_o <= 1'b1;
		m_stb_o <= 1'b1;
		m_we_o <= 1'b1;
		m_sel_o <= {cx[0],~cx[0]};
		m_adr_o <= ma;
		m_dat_o <= {2{PenColor8}};
	end
	else if (m_ack_i) begin
		m_cyc_o <= 1'b0;
		m_stb_o <= 1'b0;
		m_sel_o <= 2'b00;
		m_we_o <= 1'b0;
		if (cx==x1 && cy==y1)
			state <= IDLE;
		else
			state <= DL_TEST;
	end
DL_TEST:
	begin
		err <= err - ((e2 > -dy) ? dy : 16'd0) + ((e2 < dx) ? dx : 16'd0);
		cx <= (e2 > -dy) ? cx + sx : cx;
		cy <= (e2 <  dx) ? cy + sy : cy;
		state <= DL_SETPIXEL;
	end

endcase
end

endmodule

//function line(x0, y0, x1, y1)
//   dx := abs(x1-x0)
//   dy := abs(y1-y0) 
//;   if x0 < x1 then sx := 1 else sx := -1
//;   if y0 < y1 then sy := 1 else sy := -1
//;   err := dx-dy
//; 
//;//   loop
//;     setPixel(x0,y0)
//;     if x0 = x1 and y0 = y1 exit loop
//;     e2 := 2*err
//;     if e2 > -dy then 
//;       err := err - dy
//;       x0 := x0 + sx
//;     end if
//;     if e2 <  dx then 
//;       err := err + dx
//;       y0 := y0 + sy 
//;     end if
//;   end loop
