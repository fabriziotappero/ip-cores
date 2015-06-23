//**********************************************************************************************
// Reset generator for the AVR Core
// Version 0.9
// Modified 05.01.2007
// Designed by Ruslan Lepetenok
//**********************************************************************************************

`timescale 1 ns / 1 ns

module rst_gen(
   cp2,
   nrst,
   npwrrst,
   wdovf,
   jtagrst,
   nrst_cp2,
   nrst_clksw
);
   
   parameter  rst_high = 0;
   
   // Clock inputs
   input      cp2;
   // Reset inputs
   input      nrst;
   input      npwrrst;
   input      wdovf;
   input      jtagrst;
   // Reset outputs
   output     nrst_cp2;
   output     nrst_clksw;
   
   reg        cp2RstA;
   reg        cp2RstB;
   reg        cp2RstC;
   
   reg        nrst_ResyncA;
   reg        nrst_ResyncB;
   
   wire       ClrRstDFF;
   reg        ClrRstDFF_Tmp;
   
   reg        RstDelayA;
   reg        RstDelayB;
   
   wire       nrst_cnv;
   
   generate
      if (!rst_high)
      begin : act_l_rst
         assign nrst_cnv = nrst;
      end
      else // (rst_high != 0)
      begin : act_h_rst
         assign nrst_cnv = (~nrst);
      end
   endgenerate
   
   
   always @(posedge cp2)
   begin: nrst_Resync_DFFs
      		// Clock
      begin
         nrst_ResyncA <= nrst_cnv;
         nrst_ResyncB <= nrst_ResyncA;
      end
   end
   
   
   always @(posedge cp2)
   begin: ResetDFF
      		// Clock
      begin
         if (wdovf == 1'b1 | jtagrst == 1'b1 | nrst_ResyncB == 1'b0 | npwrrst == 1'b0)
            ClrRstDFF_Tmp <= 1'b0;		// Reset
         else
            ClrRstDFF_Tmp <= 1'b1;		// Normal state
      end
   end
   
   assign ClrRstDFF = ClrRstDFF_Tmp;		// !!!TBD!!! GLOBAL primitive may be used !!!
   
   // Low speed clock domain reset
   
   always @(negedge ClrRstDFF or posedge cp2)
   begin: Reset_cp2_DFFs
      if (!ClrRstDFF)		// Reset
      begin
         cp2RstA <= 1'b0;
         cp2RstB <= 1'b0;
         cp2RstC <= 1'b0;
      end
      else 		// Clock
      begin
         // cp2RstA <= cp64mRstB;
         cp2RstA <= RstDelayB;
         cp2RstB <= cp2RstA;
         cp2RstC <= cp2RstB;
      end
   end
   
   // Reset delay line
   
   always @(negedge ClrRstDFF or posedge cp2)
   begin: Reset_Delay_DFFs
      if (!ClrRstDFF)		// Reset
      begin
         RstDelayA <= 1'b0;
         RstDelayB <= 1'b0;
      end
      else 		// Clock
      begin
         RstDelayA <= 1'b1;
         RstDelayB <= RstDelayA;
      end
   end
   
   // Reset signal for cp2 clock domain
   assign nrst_cp2 = cp2RstC;
   
   // Separate reset for clock enable module
   assign nrst_clksw = RstDelayB;
   
endmodule // rst_gen
