`timescale 1ns/1ns
module testHarness(	);


// -----------------------------------
// Local Wires
// -----------------------------------
wire uart_srx;
wire uart_stx;
reg rst_n;
wire jtag_tdi;
wire jtag_tdo;
wire jtag_tck;
reg clk;
reg baudClk;
wire jtag_tms;
wire jtag_trst;
wire [11:0] mc_addr;
wire [1:0] mc_ba;
wire [31:0] mc_dq;
wire [3:0] mc_dqm;
wire mc_we_;
wire mc_cas_;
wire mc_ras_;
wire mc_cke_;
wire sdram_cs;
wire sdram_clk;

initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0, i_cyc_or12_mini_top);
  //$dumpvars(0, u_uart_rx);
end

// -----------------------------------
// Instance of Module: cyc_or12_mini_top
// -----------------------------------
cyc_or12_mini_top i_cyc_or12_mini_top(
		.clk(clk),

	//
	// UART signals
	//
		.uart_stx(uart_stx),
		.uart_srx(uart_srx),

	//
	// JTAG signals
	//
		.jtag_tdi(jtag_tdi),
		.jtag_tms(jtag_tms),
		.jtag_tck(jtag_tck),
		.jtag_trst(jtag_trst),
		.jtag_tdo(jtag_tdo),

	//
	// SDRAM
	//
		.mc_addr(mc_addr),
		.mc_ba(mc_ba),
		.mc_dq(mc_dq),
		.mc_dqm(mc_dqm),
		.mc_we_(mc_we_),
		.mc_cas_(mc_cas_),
		.mc_ras_(mc_ras_),
		.mc_cke_(mc_cke_),
		.sdram_cs(sdram_cs),
		.sdram_clk(sdram_clk)
	);

mt48lc2m32b2 u_mt48lc2m32b2 (
  .Dq(mc_dq), 
  .Addr(mc_addr[10:0]), 
  .Ba(mc_ba), 
  .Clk(sdram_clk), 
  .Cke(mc_cke_), 
  .Cs_n(sdram_cs), 
  .Ras_n(mc_ras_), 
  .Cas_n(mc_cas_), 
  .We_n(mc_we_), 
  .Dqm(mc_dqm)
);

assign jtag_tms = 1'b0;
assign jtag_tdi = 1'b0;
assign jtag_tck = 1'b0;
assign jtag_trst = 1'b1;

uart_rx u_uart_rx (
  .reset(~rst_n),
  .rxclk(baudClk),
  .rx_in(uart_stx)
);

//--------------- reset ---------------
initial begin
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  rst_n <= 1'b0;
  @(posedge clk);
  rst_n <= 1'b1;
  @(posedge clk);
end
 
// ******************************  Clock section  ******************************
`define CLK_50MHZ_HALF_PERIOD 10
always begin
  #`CLK_50MHZ_HALF_PERIOD clk <= 1'b0;
  #`CLK_50MHZ_HALF_PERIOD clk <= 1'b1;
end

// generate 16 * baud clock
// baud clock = 115200 * 16
// Actual baud clock is slower because we are not using the PLL
// to generate the 30MHz Wish bone clock. Instead the Wishbone clock is 25MHz
// So baud clock = 115200 * 16 * (25/30)
`define CLK_BAUD_HALF_PERIOD 322
always begin
  #`CLK_BAUD_HALF_PERIOD baudClk <= 1'b0;
  #`CLK_BAUD_HALF_PERIOD baudClk <= 1'b1;
end



endmodule

