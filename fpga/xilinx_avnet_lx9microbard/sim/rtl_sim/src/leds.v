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
      repeat(5) @(posedge CLK_40MHz);
      stimulus_done = 0;

      repeat(100) @(posedge CLK_40MHz);
 //     PMOD1_P8 = 1;
      repeat(500) @(posedge CLK_40MHz);
 //     PMOD1_P8 = 0;
      repeat(100) @(posedge CLK_40MHz);
 //     PMOD1_P8 = 1;
      

      repeat(500) @(posedge CLK_40MHz);
      PMOD1_P4 = 0;
      repeat(100) @(posedge CLK_40MHz);
      PMOD1_P4 = 1;
      
      repeat(500) @(posedge CLK_40MHz);



      stimulus_done = 1;
   end

