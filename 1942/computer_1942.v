/*
	1942 simple board setup in order to test SQMUSIC.
	
	Requirements:
		  TV80, Z80 Verilog module
		 	Dump of Z80 ROM from 1942 board

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

module computer_1942
#(parameter dump_regs=0) // set to 1 to dump sqmusic registers
(
  input clk,
	input sound_clk,
	input reset_n,
	input int_n,
	output [3:0] ay0_a,
	output [3:0] ay0_b,
	output [3:0] ay0_c,	
	output [3:0] ay1_a,
	output [3:0] ay1_b,
	output [3:0] ay1_c,
	output bus_error
);
  reg wait_n, nmi_n, busrq_n;
  
  wire [7:0]cpu_in, cpu_out;
  wire [15:0]adr;
  wire m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n;
  wire bus_error;

//	wire [15:0] amp0_y, amp1_y;

  wire [7:0]ram_out, rom_out, latch_out;
  wire rom_enable = adr<16'h4000 ? 1:0;
  wire ram_enable = adr>=16'h4000 && adr<16'h4800 ? 1:0;
  wire latch_enable = adr==16'h6000 ? 1 : 0;
  wire ay_0_enable = adr==16'h8000 || adr==16'h8001 ? 1:0;
  wire ay_1_enable = adr==16'hC000 || adr==16'hC001 ? 1:0;  
  assign bus_error = ~ram_enable & ~rom_enable & ~latch_enable &
    ~ay_0_enable & ~ay_1_enable;
  assign cpu_in=ram_out | rom_out | latch_out;
/*
	always @(negedge rd_n)
		if( !rd_n	&& adr==8'h38 ) 
			$display("IRQ processing started @ %t us",$time/1e6);
*/   
  initial begin
    nmi_n=1;
    wait_n=1;
  end

  tv80n cpu( //outputs
  .m1_n(m1_n), .mreq_n(mreq_n), .iorq_n(iorq_n), .rd_n(rd_n), .wr_n(wr_n), 
  .rfsh_n(rfsh_n), .halt_n(halt_n), .busak_n(busak_n), .A(adr), .do(cpu_out), 
  // Inputs
  .reset_n(reset_n), .clk(clk), .wait_n(wait_n), 
  .int_n(int_n), .nmi_n(nmi_n), .busrq_n(busrq_n), .di(cpu_in) );

  RAM ram(.adr(adr[10:0]), .din(cpu_out), .dout(ram_out), .enable( ram_enable ),
    .clk(clk), .wr_n(wr_n), .rd_n(rd_n) );
  ROM rom(.adr(adr[13:0]), .data(rom_out), .enable(rom_enable),
   .rd_n(rd_n), .clk(clk));
  SOUND_LATCH sound_latch( .dout(latch_out), .enable(latch_enable),
    .clk(clk), .rd_n(rd_n) );

//	fake_ay ay_0( .adr(adr[0]), .din(din), .clk(clk), .wr_n(~ay_0_enable|wr_n) );

	AY_3_8910_capcom #(dump_regs,0) ay_0( .reset_n(reset_n), .clk(clk), .sound_clk(sound_clk),
		.din(cpu_out), .adr(adr[0]), .wr_n(wr_n), .cs_n(~ay_0_enable),
		.A(ay0_a), .B(ay0_b), .C(ay0_c) );
	AY_3_8910_capcom #(dump_regs,1) ay_1( .reset_n(reset_n), .clk(clk), .sound_clk(sound_clk),
		.din(cpu_out), .adr(adr[0]), .wr_n(wr_n), .cs_n(~ay_1_enable),
		.A(ay1_a), .B(ay1_b), .C(ay1_c) );
endmodule

//////////////////////////////////////////////////////////
// this module is used to check the communication of the
// Z80 with the AY-3-8910
// only used for debugging
module fake_ay(
	input adr,
  input [7:0] din,
  input clk,
  input wr_n );
	
	reg [7:0] contents[1:0];
	wire sample = clk & ~wr_n;
	
	always @(posedge sample) begin
//		if( contents[adr] != din ) begin
		$display("%t -> %d = %d", $realtime/1e6, adr, din );
		if( !adr && din>15 ) $display("AY WARNING");
		contents[adr] = din;
	end
	
endmodule
	
//////////////////////////////////////////////////////////
module RAM(
  input [10:0] adr,
  input [7:0] din,
  output reg [7:0] dout,  
  input enable,
  input clk,
  input rd_n,
  input wr_n );

reg [7:0] contents[2047:0];
wire sample = clk & (~rd_n | ~wr_n );

initial dout=0;
  
always @(posedge sample) begin
  if( !enable )
    dout=0;
  else begin 
    if( !wr_n ) contents[adr]=din;
    if( !rd_n ) dout=contents[adr];
  end
end
endmodule

//////////////////////////////////////////////////////////
module ROM( 
  input  [13:0] adr, 
  output reg [7:0] data,
  input enable,
  input rd_n,
  input clk );

reg [7:0] contents[16383:0];

wire sample = clk & ~rd_n;

initial begin
  $readmemh("../rom/sr-01.c11.hex", contents ); // this is the hex dump of the ROM
  data=0;
end

always @( posedge sample ) begin
  if ( !enable )
    data=0;
  else
    data=contents[ adr ];
end
endmodule

//////////////////////////////////////////////////////////
module SOUND_LATCH(
  output reg [7:0] dout,  
  input enable,
  input clk,
  input rd_n );

wire sample = clk & ~rd_n;
reg [7:0]data;

initial begin
	dout=0;
	data=0;
	#100e6 data=8'h12; // enter the song/sound code here
end
  
always @(posedge sample) begin
  if( !enable )
		dout=0;
  else begin 
    if( !rd_n ) begin
			// $display("Audio latch read @ %t us", $realtime/1e6 );
//			if( data != 0 ) 
//			  $display("Audio latch read (%X) @ %t us", data, $realtime/1e6 );
			dout=data;
		end
  end
end
endmodule
