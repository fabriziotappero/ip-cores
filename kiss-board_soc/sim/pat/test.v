
`timescale 1ps/1ps

//`define UART_REG_RB	`UART_ADDR_WIDTH'd0	// receiver buffer
//`define UART_REG_TR  `UART_ADDR_WIDTH'd0	// transmitter
//`define UART_REG_IE	`UART_ADDR_WIDTH'd1	// Interrupt enable
//`define UART_REG_II  `UART_ADDR_WIDTH'd2	// Interrupt identification
//`define UART_REG_FC  `UART_ADDR_WIDTH'd2	// FIFO control
//`define UART_REG_LC	`UART_ADDR_WIDTH'd3	// Line Control
//`define UART_REG_MC	`UART_ADDR_WIDTH'd4	// Modem control
//`define UART_REG_LS  `UART_ADDR_WIDTH'd5	// Line status
//`define UART_REG_MS  `UART_ADDR_WIDTH'd6	// Modem status
//`define UART_REG_SR  `UART_ADDR_WIDTH'd7	// Scratch register
//`define UART_REG_DL1	`UART_ADDR_WIDTH'd0	// Divisor latch bytes (1-2)
//`define UART_REG_DL2	`UART_ADDR_WIDTH'd1

module test ();

`include "./inc/test.inc.v"

	defparam sim_cycle_max = 600000;

	//defparam i_flash.LoadFileName = "../sw/boot_flash/boot_flash.noic.nodc.or32.hex";
	//defparam i_flash.LoadFileName = "../sw/boot_flash/boot_flash.ic.nodc.or32.hex";
	//defparam i_flash.LoadFileName = "../sw/boot_flash/boot_flash.noic.dc.or32.hex";
	defparam i_flash.LoadFileName = "../sw/boot_flash/boot_flash.ic.dc.or32.hex";

	defparam i_flash.SaveFileName = "./rom/flash.out";
	
	initial begin
// reset
		task_idle(32'd10);
		task_reset;
		task_idle(32'd2500);

		task_idle(32'd6400);
		
//		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0400_0000,4'b1111,32'hxxxxxxxx);
//		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0400_0000,4'b1111,32'hxxxxxxxx);
//		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0400_0000,4'b1111,32'hxxxxxxxx);
//		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0400_0000,4'b1111,32'hxxxxxxxx);

		i_tessera_top.i_tessera_core.i_tessera_tic.task_wr_ext(1'b0,32'h0300_0000,4'b1111,32'h12345678);
		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0300_0000,4'b1111,32'hxxxxxxxx);
		i_tessera_top.i_tessera_core.i_tessera_tic.task_wr_ext(1'b0,32'h0300_0000,4'b1111,32'h12345678);
		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0300_0000,4'b1111,32'hxxxxxxxx);
		i_tessera_top.i_tessera_core.i_tessera_tic.task_wr_ext(1'b0,32'h0300_0000,4'b1111,32'h12345678);
		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0300_0000,4'b1111,32'hxxxxxxxx);
		i_tessera_top.i_tessera_core.i_tessera_tic.task_wr_ext(1'b0,32'h0300_0000,4'b1111,32'h12345678);
		i_tessera_top.i_tessera_core.i_tessera_tic.task_rd_ext(1'b0,32'h0300_0000,4'b1111,32'hxxxxxxxx);

// uart
	// wait uart init(for sim)
		@(posedge t_uart_rts_n);	// inactive
		@(negedge t_uart_rts_n);	// active

	// ready
		task_idle(1024*20);
		task_uart_dsr_n(1'b1);
		task_idle(1024*20);
		task_uart_dsr_n(1'b0);
		@(negedge t_uart_dtr_n); // wait dtr
	// write
		task_uart_data(8'h00); @(posedge t_uart_txd); // write command
		task_uart_data(8'h00); @(posedge t_uart_txd); 
		task_uart_data(8'h00); @(posedge t_uart_txd); 
		task_uart_data(8'h01); @(posedge t_uart_txd); 
		task_uart_data(8'h02); @(posedge t_uart_txd); // parameter1
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'hff); @(posedge t_uart_txd); // parameter2
		task_uart_data(8'hff); @(posedge t_uart_txd);
		task_uart_data(8'hff); @(posedge t_uart_txd);
		task_uart_data(8'hff); @(posedge t_uart_txd);

		`include "../sw/boot_uart/boot_uart.or32.uart.v"
		
	// ready
		task_idle(1024*20);
		task_uart_dsr_n(1'b1);
		task_idle(1024*20);
		task_uart_dsr_n(1'b0);
		@(negedge t_uart_dtr_n); // wait dtr
	// boot
		task_uart_data(8'h00); @(posedge t_uart_txd); // write command
		task_uart_data(8'h00); @(posedge t_uart_txd); 
		task_uart_data(8'h00); @(posedge t_uart_txd); 
		task_uart_data(8'h03); @(posedge t_uart_txd); 
		task_uart_data(8'h02); @(posedge t_uart_txd); // parameter1
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd); // parameter2
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);

	// ready
		task_idle(1024*20);
		task_uart_dsr_n(1'b1);
		task_idle(1024*20);
		task_uart_dsr_n(1'b0);
		@(negedge t_uart_dtr_n);	// wait dtr
	// read
		task_uart_data(8'h00); @(posedge t_uart_txd); // read command
		task_uart_data(8'h00); @(posedge t_uart_txd); 
		task_uart_data(8'h00); @(posedge t_uart_txd); 
		task_uart_data(8'h02); @(posedge t_uart_txd); 
		task_uart_data(8'h02); @(posedge t_uart_txd); // parameter1
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd); // parameter2
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h00); @(posedge t_uart_txd);
		task_uart_data(8'h01); @(posedge t_uart_txd);

		task_uart_data(8'h00); @(posedge t_uart_txd); // request

	end

endmodule
