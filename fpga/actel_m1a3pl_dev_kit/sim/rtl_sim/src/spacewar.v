/*===========================================================================*/
/*                                 DIGITAL I/O                               */
/*---------------------------------------------------------------------------*/
/* Test the Digital I/O interface.                                           */
/*===========================================================================*/

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge oscclk);
      stimulus_done = 0;

      repeat(50) @(posedge mclk);

      // Send uart synchronization frame
      dbg_uart_sync;

      // Let the CPU run
      dbg_uart_wr(CPU_CTL,  16'h0002);

      stimulus_done = 1;
   end

