`include "irda_defines.v"
`include "uart_for_irda_defines.v"

module irda_test;

reg				clk;
reg				wb_rst_i;
reg	[3:0]		wb_addr_i;
reg	[7:0]	wb_dat_i;
wire	[7:0]	wb_dat_o;
reg				wb_we_i;
reg				wb_stb_i;
reg				wb_cyc_i;
reg				dma_ack_t;
reg				dma_ack_r;
reg				rx_i;

reg	[3:0]		wb1_addr_i;
reg	[7:0]	wb1_dat_i;
wire	[7:0]	wb1_dat_o;
reg				wb1_we_i;
reg				wb1_stb_i;
reg				wb1_cyc_i;
reg				dma1_ack_t;
reg				dma1_ack_r;
irda_top_sir_only top(clk, wb_rst_i, wb_addr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i, 
	wb_ack_o, int_o, 
	tx_o, rx_i);

irda_top_sir_only toprx(clk, wb_rst_i, wb1_addr_i, wb1_dat_i, wb1_dat_o, wb1_we_i, wb1_stb_i, wb1_cyc_i,
					wb1_ack_o, int1_o,
	tx1_o, rx1_i);

assign 			rx1_i = tx_o; // connect the cores

// SIMULATES A WISHBONE IRDA_MASTER CONTROLLER CYCLE
task cycle;    // transmitter
input				we;
input	[3:0]		addr;
input	[7:0]	dat;		
begin
	@(posedge clk)
	wb_addr_i <= #1 addr;
	wb_we_i <= #1 we;
	wb_dat_i <= #1 dat;
	wb_stb_i <= #1 1;
	wb_cyc_i <= #1 1;
	@(posedge clk);
	while(~wb_ack_o)	@(posedge clk);
	#1;
	wb_we_i <= #1 0;
	wb_stb_i<= #1 0;
	wb_cyc_i<= #1 0;
end
endtask // cycle

task cycle1;    // transmitter
input				we;
input	[3:0]		addr;
input	[7:0]	dat;		
begin
	@(posedge clk)
	wb1_addr_i <= #1 addr;
	wb1_we_i <= #1 we;
	wb1_dat_i <= #1 dat;
	wb1_stb_i <= #1 1;
	wb1_cyc_i <= #1 1;
	@(posedge clk);
	while(~wb1_ack_o)	@(posedge clk);
	#1;
	wb1_we_i <= #1 0;
	wb1_stb_i<= #1 0;
	wb1_cyc_i<= #1 0;
end
endtask // cycle1

initial
	clk = 0;

always
	#5 clk = ~clk;

//always
//	@(posedge top.mir_tx.mir_txbit_enable) $display($time, "  > %b", top.mir_tx.mir_tx_o);


//// SIR TEST TASK

task test_sir_tx;
// MAIN TEST ROUTINE for transmitter
begin
	#1		wb_rst_i = 1;
	#10	wb_rst_i = 0;
	wb_stb_i = 0;
	wb_cyc_i = 0;
	wb_we_i = 0;
	cycle(1, `IRDA_MASTER, 8'b00000011); //SIR mode
	//write to lcr. set bit 7
	//wb_cyc_ir = 1;
	cycle(1, `UART_REG_LC, 8'b10011011);
	// set dl to divide by 3
	cycle(1, `UART_REG_DL1, 8'd20);
	@(posedge clk);
	@(posedge clk);
	// restore normal registers
	cycle(1, `UART_REG_LC, 8'b00011011);
	#100;
	$display("%m : %t : sending : %b", $time, 8'b01101011);
	cycle(1, 0, 8'b01101011);
	@(posedge clk);
	@(posedge clk);
	$display("%m : %t : sending : %b", $time, 8'b01000101);
	cycle(1, 0, 8'b01000101);
	#100;
	wait (top.uart.regs.tstate==0 && top.uart.regs.transmitter.tf_count==0);
end
endtask // test_sir_tx


// for the rx irda
task test_sir_rx;
begin
	#10	wb1_stb_i = 0;
	wb1_cyc_i = 0;
	wb1_we_i = 0;
	cycle1(1, `IRDA_MASTER, 8'b00000001); //SIR mode
	cycle1(1, `UART_REG_LC, 8'b10011011);
	// set dl to divide by 3
	cycle1(1, `UART_REG_DL1, 8'd20);
	@(posedge clk);
	@(posedge clk);
	// restore normal registers
	cycle1(1, `UART_REG_LC, 8'b00011011);
	#100;
	wait(toprx.uart.regs.receiver.rf_count == 2);
	cycle1(0, 0, 0);
	$display("%m : %t : Data out: %b", $time, wb1_dat_o);
	@(posedge clk);
	cycle1(0, 0, 0);
	$display("%m : %t : Data out: %b", $time, wb1_dat_o);
	$display("%m : Finish");
	$finish;
	
end
endtask // test_sir_rx

// Transmitter
initial
  test_sir_tx;

// Receiver
initial
  test_sir_rx;
  
initial
begin
    $monitor($time,top.wb_adr_i);
	forever #20000 $display("%m, Reached time %t", $time);
end
endmodule
