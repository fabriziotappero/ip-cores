//**********************************************************************************************
// Watchdog Timer Peripheral for the AVR Core
// Version 1.1
// Modified 08.01.2007
// Designed by Ruslan Lepetenok
// std_library was added
//**********************************************************************************************

`timescale 1 ns / 1 ns


module wdt_mod(
   ireset,
   cp2,
   adr,
   dbus_in,
   dbus_out,
   iore,
   iowe,
   out_en,
   runmod,
   wdt_irqack,
   wdri,
   wdt_irq,
   wdtmout,
   wdtcnt
);

parameter WDTCR_Address = 6'h21; // Watchdog Timer Control Register

   // Clock and Reset
   input         ireset;
   input         cp2;
   // AVR Control
   input [5:0]   adr;
   input [7:0]   dbus_in;
   output [7:0]  dbus_out;
   input         iore;
   input         iowe;
   output        out_en;
   // Watchdog timer 
   input         runmod;
   input         wdt_irqack;
   input         wdri;
   
   output        wdt_irq;
   output        wdtmout;
   output [27:0] wdtcnt;
   
   reg [7:0]     WDTCR;
   `define WDIE WDTCR[7]
   `define WDIRQ WDTCR[6]
   `define WDTOE WDTCR[5]
   `define WDE WDTCR[4]
   `define WDP WDTCR[3:0]
   
   reg [27:0]    CntReg;
   reg           WDTOvf;
   
   reg [1:0]     WDTOEDelCnt;
   
   // WDT disable sequence
   reg           WDTDisSeq_St;
   
   
   always @(negedge ireset or posedge cp2)
   begin: Counter
      if (ireset == 1'b0)		//Reset
         CntReg <= {28{1'b0}};
      else 		// Clock
      begin
         if (wdri == 1'b1)
            CntReg <= {28{1'b0}};
         else if (runmod == 1'b1)
            CntReg <= CntReg + 1;
      end
   end
   
   		// Combinatorial process
   always @(CntReg or WDTCR)
   begin: WDTPrescalerSelect
      WDTOvf = 1'b0;
      case (`WDP)
         4'b0000 :
            if (CntReg == 28'b0000000000000011111111111111)		// 16K
               WDTOvf = 1'b1;
         4'b0001 :
            if (CntReg == 28'b0000000000000111111111111111)		// 32K
               WDTOvf = 1'b1;
         4'b0010 :
            if (CntReg == 28'b0000000000001111111111111111)		// 64K
               WDTOvf = 1'b1;
         4'b0011 :
            if (CntReg == 28'b0000000000011111111111111111)		// 128K
               WDTOvf = 1'b1;
         4'b0100 :
            if (CntReg == 28'b0000000000111111111111111111)		// 256K
               WDTOvf = 1'b1;
         4'b0101 :
            if (CntReg == 28'b0000000001111111111111111111)		// 512K
               WDTOvf = 1'b1;
         4'b0110 :
            if (CntReg == 28'b0000000011111111111111111111)		// 1024K
               WDTOvf = 1'b1;
         4'b0111 :
            if (CntReg == 28'b0000000111111111111111111111)		// 2048K
               WDTOvf = 1'b1;
         4'b1000 :
            if (CntReg == 28'b0000001111111111111111111111)		// 4096K
               WDTOvf = 1'b1;
         4'b1001 :
            if (CntReg == 28'b0000011111111111111111111111)		// 8192K
               WDTOvf = 1'b1;
         4'b1010 :
            if (CntReg == 28'b0000111111111111111111111111)		// 16384K
               WDTOvf = 1'b1;
         4'b1011 :
            if (CntReg == 28'b0001111111111111111111111111)		// 32768K
               WDTOvf = 1'b1;
         4'b1100 :
            if (CntReg == 28'b0011111111111111111111111111)		// 65536K
               WDTOvf = 1'b1;
         4'b1101 :
            if (CntReg == 28'b0111111111111111111111111111)		// 131072K
               WDTOvf = 1'b1;
         4'b1110 :
            if (CntReg == 28'b1111111111111111111111111111)		// 262144K
               WDTOvf = 1'b1;
         default :
            WDTOvf = 1'b0;
      endcase
      
   end
   
   
   always @(negedge ireset or posedge cp2)
   begin: ControlSM
      if (ireset == 1'b0)		//Reset
      begin
         WDTCR <= {8{1'b0}};
         WDTOEDelCnt <= {2{1'b0}};
         WDTDisSeq_St <= 1'b0;
      end
      else 		// Clock
      begin
         
         if (adr == WDTCR_Address & iowe == 1'b1)		// Write to WDTCR
         begin
            `WDP <= dbus_in[3:0];
            `WDIE <= dbus_in[7];
         end
         
         case (`WDE)
            1'b0 :
               if (adr == WDTCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b1)		// Write one to WDE
                  `WDE <= 1'b1;
            1'b1 :
               if (WDTDisSeq_St == 1'b1 & adr == WDTCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b0)
                  `WDE <= 1'b0;
            default :
               ;
         endcase
         
         case (`WDTOE)
            1'b0 :
               if (adr == WDTCR_Address & iowe == 1'b1 & dbus_in[5] == 1'b1)		// Write one to WDTOE
                  `WDTOE <= 1'b1;
            1'b1 :
               if (WDTOEDelCnt == 2'b11 & (~(adr == WDTCR_Address & iowe == 1'b1 & dbus_in[5] == 1'b1)))		// Clear WDTOE after 4 cycles
                  `WDTOE <= 1'b0;
            default :
               ;
         endcase
         
         case (`WDIRQ)
            1'b0 :
               if (WDTOvf == 1'b1 & runmod == 1'b1)		// Set IRQ flag
                  `WDIRQ <= 1'b1;
            1'b1 :
               if (wdt_irqack == 1'b1 | (adr == WDTCR_Address & iowe == 1'b1 & dbus_in[6] == 1'b1))		// Clear IRQ flag	 
                  `WDIRQ <= 1'b0;
            default :
               ;
         endcase
         
         // Delay counter
         if (adr == WDTCR_Address & iowe == 1'b1 & dbus_in[5] == 1'b1)		// Write one to WDTOE
            WDTOEDelCnt <= {2{1'b0}};
         else
            WDTOEDelCnt <= WDTOEDelCnt + 1;
         
         case (WDTDisSeq_St)
            1'b0 :
               if (adr == WDTCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b1 & dbus_in[5] == 1'b1)		// Start disable sequence
                  WDTDisSeq_St <= 1'b1;
            1'b1 :
               if (WDTOEDelCnt == 2'b11 & (~(adr == WDTCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b1 & dbus_in[5] == 1'b1)))		// End disable sequence
                  WDTDisSeq_St <= 1'b0;
            default :
               ;
         endcase
      end
      
   end
   
   assign wdtmout = WDTOvf & `WDE;
   
   // -------------------------------------------------------------------------------------------
   // Bus interface
   // -------------------------------------------------------------------------------------------
   assign out_en = (adr == WDTCR_Address & iore == 1'b1) ? 1'b1 : 
                   1'b0;
   assign dbus_out = WDTCR;
   // -------------------------------------------------------------------------------------------
   // End of bus interface
   // -------------------------------------------------------------------------------------------
   
   assign wdt_irq = `WDIRQ & `WDIE;
   assign wdtcnt = CntReg;
   
endmodule
