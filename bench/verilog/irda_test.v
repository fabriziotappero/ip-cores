`include "irda_defines.v"
`include "uart_defines.v"

module irda_test;

reg				clk;
reg				wb_rst_i;
reg	[3:0]		wb_addr_i;
reg	[31:0]	wb_dat_i;
wire	[31:0]	wb_dat_o;
reg				wb_we_i;
reg				wb_stb_i;
reg				wb_cyc_i;
reg				dma_ack_t;
reg				dma_ack_r;
reg				rx_i;

reg	[3:0]		wb1_addr_i;
reg	[31:0]	wb1_dat_i;
wire	[31:0]	wb1_dat_o;
reg				wb1_we_i;
reg				wb1_stb_i;
reg				wb1_cyc_i;
reg				dma1_ack_t;
reg				dma1_ack_r;
irda_top top(clk, wb_rst_i, wb_addr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i, 
	wb_ack_o, int_o, dma_req_t, dma_ack_t, dma_req_r, dma_ack_r,
	tx_o, rx_i);

irda_top toprx(clk, wb_rst_i, wb1_addr_i, wb1_dat_i, wb1_dat_o, wb1_we_i, wb1_stb_i, wb1_cyc_i,
					wb1_ack_o, int1_o, dma1_req_o, dma1_ack_t, dma1_req_r, dma1_ack_r,
	tx1_o, rx1_i);

assign 			rx1_i = tx_o; // connect the cores

// SIMULATES A WISHBONE IRDA_MASTER CONTROLLER CYCLE
task cycle;    // transmitter
input				we;
input	[3:0]		addr;
input	[31:0]	dat;		
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
input	[31:0]	dat;		
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


/// MIR TEST TASK
task test_mir_tx;

// MAIN TEST ROUTINE
begin
	//	$monitor(">> %d, %b", $time, top.mir_tx_o);
	#1		wb_rst_i = 1;
	#10	wb_rst_i = 0;
	wb_stb_i = 0;
	wb_cyc_i = 0;
	wb_we_i = 0;
	cycle(1, `IRDA_MASTER, 32'b00011011);
	cycle(1, `IRDA_F_CDR, 32'd200000);
	cycle(1, `IRDA_F_FCR, 32'b10000011);
	//			cycle(1, `IRDA_F_LCR, 32'b00);
	//			cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
	//	$display("%m, %t, Sending %b", $time, 32'hA7F1F5CC);
	cycle(1, `IRDA_F_LCR, 32'b10); // set count outgoing data mode
	cycle(1, `IRDA_F_OFDLR, 16'd64); //bytes to send
	
	cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
		cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
		cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
		cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
	#300;
	wait (top.mir_tx.state == 0);
	cycle(1, `IRDA_F_OFDLR, 16'd4); //bytes to send
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
	#300;
	wait (top.mir_tx.state == 0);
	#200;
//	$finish;
end // initial begin
endtask // test_mir_tx


/// FIR TX TEST TASK
task test_fir_tx;

begin
	//	$monitor(">> %d, %b", $time, top.mir_tx_o);
	#1		wb_rst_i = 1;
	#10	wb_rst_i = 0;
	wb_stb_i = 0;
	wb_cyc_i = 0;
	wb_we_i = 0;
	cycle(1, `IRDA_MASTER, 32'b00001011);
	cycle(1, `IRDA_F_CDR, 32'd200000);
	cycle(1, `IRDA_F_FCR, 32'b10000011);
	//			cycle(1, `IRDA_F_LCR, 32'b00);
	//			cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
	//	$display("%m, %t, Sending %b", $time, 32'hA7F1F5CC);
	cycle(1, `IRDA_F_LCR, 32'b10); // set count outgoing data mode
/* -----\/----- EXCLUDED -----\/-----
	cycle(1, `IRDA_F_OFDLR, 16'd64); //bytes to send
	
	cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
		cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
		cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
		cycle(1, `IRDA_TRANSMITTER, 32'h44332211);
	cycle(1, `IRDA_TRANSMITTER, 32'h88776655);
	cycle(1, `IRDA_TRANSMITTER, 32'hB1B2B3B4);
	cycle(1, `IRDA_TRANSMITTER, 32'hA7F1F5CC);
	#300;
	wait (top.fir_tx.state == 0);
 -----/\----- EXCLUDED -----/\----- */
	cycle(1, `IRDA_F_OFDLR, 16'd2); //bytes to send
	cycle(1, `IRDA_TRANSMITTER, 32'h0000A41B);
	#300;
	wait (top.fir_tx.state == 0);
	#200;
end // initial begin
endtask // test_fir_tx

task test_fir_rx;
begin
	#10	wb1_stb_i = 0;
	wb1_cyc_i = 0;
	wb1_we_i = 0;
	cycle1(1, `IRDA_MASTER, 32'b00001001);
	cycle1(1, `IRDA_F_CDR, 32'd200000);
	cycle1(1, `IRDA_F_FCR, 32'b10000011);
	cycle1(1, `IRDA_F_LCR, 32'b00);
end
endtask // test_fir_rx


task test_mir_rx;
begin
	#10	wb1_stb_i = 0;
	wb1_cyc_i = 0;
	wb1_we_i = 0;
	cycle1(1, `IRDA_MASTER, 32'b00011001);
	cycle1(1, `IRDA_F_CDR, 32'd200000);
	cycle1(1, `IRDA_F_FCR, 32'b10000011);
	cycle1(1, `IRDA_F_LCR, 32'b00);
end

endtask

//// SIR TEST TASK

task test_sir_tx;
// MAIN TEST ROUTINE for transmitter
begin
	#1		wb_rst_i = 1;
	#10	wb_rst_i = 0;
	wb_stb_i = 0;
	wb_cyc_i = 0;
	wb_we_i = 0;
	cycle(1, `IRDA_MASTER, 32'b00011011); //MIR (fast) mode
	cycle(1, `IRDA_F_CDR, 32'd200000);
	cycle(1, `IRDA_MASTER, 32'b00000011); //SIR mode
	//write to lcr. set bit 7
	//wb_cyc_ir = 1;
	cycle(1, `UART_REG_LC, 8'b10011011);
	// set dl to divide by 3
	cycle(1, `UART_REG_DL1, 8'd2);
	@(posedge clk);
	@(posedge clk);
	// restore normal registers
	cycle(1, `UART_REG_LC, 8'b00011011);
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
	cycle1(1, `IRDA_MASTER, 32'b00011011); //MIR (fast) mode
	cycle1(1, `IRDA_F_CDR, 32'd200000);
	cycle1(1, `IRDA_MASTER, 32'b00000001); //SIR mode
	cycle1(1, `UART_REG_LC, 8'b10011011);
	// set dl to divide by 3
	cycle1(1, `UART_REG_DL1, 8'd2);
	@(posedge clk);
	@(posedge clk);
	// restore normal registers
	cycle1(1, `UART_REG_LC, 8'b00011011);
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
//	$dumpfile("irda.vcd");
//	$dumpvars;
//	$dumpon;
//	#150000 $finish;
	forever #20000 $display("%m, Reached time %t", $time);
end
endmodule
