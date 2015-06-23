/*
	Verilog Sample code for Spartan3 Starter Kit 

	1.VGA
	  RIGHT SIDE color bar
	  line 1 : fixed message "PS2 Code Scanner By T.Satoh"
	  line 2 to 29 : PS/2 code & UART monitor area

	2.PS/2 receive
	  receive only,do not supported transmit
	  display receive data to VGA monitor with HEXA code.

	3.7segment LED
	  display second counter to low 2 digit
	  display UART receive code to high 2 digit
	  show second timming to DOT
	  show button0,1,2 to DOT

	4.switch / LED
	  echo switch level to LED

	5.button
	  button3 = reset switch
	  button2 = clear scan code display
	  button1 = no function
	  button0 = no function

	6.RS232C
	  receive only,do not support transmit
	  TX pin is LOOPBACK from RX pin.
	  Receive 38400bps,8bit,no-parity,1stop

	7.SRAM
	  do not used

	8.ROM data from configration ROM
	  do not used

*/
module s3_vsmpl(
  tx,rx,switch,button,led,
  led7seg , led7com,
  ram_addr , ram_we,ram_oe,
  ram_a_data,ram_a_ce,ram_a_lb,ram_a_ub,
  ram_b_data,ram_b_ce,ram_b_lb,ram_b_ub,
  din,cclk,reset_prom,
  clk,
// PS2
   PS2_CLK,PS2_DATA
// VGA
  ,VGA_R,VGA_G,VGA_B,VGA_HS,VGA_VS
);

/****************************************************************************
  I/O PIN description
****************************************************************************/

// PS2 keyboard / mouse
input PS2_CLK;
input PS2_DATA;

// VGA monitor
output VGA_R,VGA_G,VGA_B;
output VGA_HS,VGA_VS;

// RS232C serial port
output tx;
input rx;

// switch & button
input [7:0] switch;
input [3:0] button;

// static LED
output [7:0] led;

// 7segment LED
output [7:0] led7seg;
output [3:0] led7com;

// SRAM
output [17:0] ram_addr;
output ram_we , ram_oe;
inout [15:0] ram_a_data;
output ram_a_ce;
output ram_a_lb;
output ram_a_ub;
inout [15:0] ram_b_data;
output ram_b_ce;
output ram_b_lb;
output ram_b_ub;

// CFG ROM
inout din;
output cclk;
output reset_prom;

// 50MHz clock
input clk;

//Hard Top

  assign led7seg=0;
  assign led7com=0;

	assign VGA_R=0,VGA_G=0,VGA_B=0;
   assign VGA_HS=0,VGA_VS=0;


/****************************************************************************
  reset signal
****************************************************************************/
wire user_reset = button[3];

/****************************************************************************
  basic clock generator
****************************************************************************/
wire clk50M = clk;
reg r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16;
always @(negedge clk50M )  begin//power on reset
		r1<=user_reset;
		r2<=r1;
		r3<=r2;
		r4<=r3;
		r5<=r4;
		r6<=r5;
		r7<=r6;
		r8<=r7;
		r9<=r8;
	  r10<=r9;
		r11<=r10;
		r12<=r11;
		r13<=r12;
		r14<=r13;
		r15<=r14;
		r16<=r15;
end
// divider
reg [1:0] clk25M;

always @(posedge clk50M )
	   if (r1)  clk25M<=0;
	   else  clk25M <= clk25M+1;



 yacc cpu(.clock(clk25M[0]),//25MHz
					.Async_Reset(!r16),
			    .RXD(rx),
					.TXD(tx));
	
				 
/****************************************************************************
  unused I/O
****************************************************************************/

// RS232C serial port , LOOP back
//assign tx = rx;

assign led = switch;

// SRAM
assign ram_addr = 0;
assign ram_we = 0;
assign ram_oe = 1'b1;

assign ram_a_data = 16'hffff;
assign ram_a_ce = 1'b1;
assign ram_a_lb = 1'b1;
assign ram_a_ub = 1'b1;
assign ram_b_data = 16'hffff;
assign ram_b_ce = 1'b1;
assign ram_b_lb = 1'b1;
assign ram_b_ub = 1'b1;

// CFG ROM
assign cclk = din;
assign reset_prom = din;

endmodule
