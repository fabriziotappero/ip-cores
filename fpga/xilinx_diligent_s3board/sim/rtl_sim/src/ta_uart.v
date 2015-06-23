/*===========================================================================*/
/*                                 DIGITAL I/O                               */
/*---------------------------------------------------------------------------*/
/* Test the Digital I/O interface.                                           */
/*===========================================================================*/

`define VERY_LONG_TIMEOUT

// Data rate
parameter UART_FREQ   = 115200;
integer   UART_PERIOD = 1000000000/UART_FREQ;


reg [7:0] rxbuf;
integer   rxcnt;

task uart_rx;
      begin
	 @(negedge UART_TXD);  
	 rxbuf = 0;      
	 #(UART_PERIOD*3/2);
	 for (rxcnt = 0; rxcnt < 8; rxcnt = rxcnt + 1)
	   begin
	      rxbuf = {UART_TXD, rxbuf[7:1]};
	      #(UART_PERIOD);
	   end
	 $write("%s", rxbuf);
	 $fflush();
      end
endtask

task uart_tx;
      input [7:0] txbuf;

      reg [9:0] txbuf_full;
      integer   txcnt;
      begin
	 UART_RXD = 1'b1;
	 txbuf_full = {1'b1, txbuf, 1'b0};
         #(UART_PERIOD);
	 for (txcnt = 0; txcnt < 10; txcnt = txcnt + 1)
	   begin
	      UART_RXD   =  txbuf_full[txcnt];
              #(UART_PERIOD);
	   end
      end
endtask

initial forever uart_rx;


initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge CLK_50MHz);
      stimulus_done = 0;

      UART_RXD = 1'b1;

      // Select GPIOs (for software uart)
      SW1 = 1'b0;
      SW0 = 1'b1;

      // Wait for welcome message to be received
      repeat(125000) @(posedge mclk);

      // Send something
      uart_tx("B");
      repeat(3000) @(posedge mclk);
      uart_tx("o");
      repeat(3000) @(posedge mclk);
      uart_tx("n");
      repeat(3000) @(posedge mclk);
      uart_tx("j");
      repeat(3000) @(posedge mclk);
      uart_tx("o");
      repeat(3000) @(posedge mclk);
      uart_tx("u");
      repeat(3000) @(posedge mclk);
      uart_tx("r");
      repeat(3000) @(posedge mclk);
      uart_tx(" ");
      repeat(3000) @(posedge mclk);
      uart_tx(":");
      repeat(3000) @(posedge mclk);
      uart_tx("-");
      repeat(3000) @(posedge mclk);
      uart_tx(")");
      repeat(3000) @(posedge mclk);
      uart_tx("\n");
      repeat(3000) @(posedge mclk);

      stimulus_done = 1;
      repeat(10) @(posedge mclk);
      $display("\n");
      $finish();

   end

