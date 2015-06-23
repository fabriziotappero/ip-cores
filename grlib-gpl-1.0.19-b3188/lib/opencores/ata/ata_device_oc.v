/////////////////////////////////////////////////////////////////////
////                                                             ////
////  ATA (IDE) Device Model                                     ////
////  This Model Supports PIO cycles only !                      ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/ata/       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: ata_device.v,v 1.2 2002/02/25 06:07:21 rherveille Exp $
//
//  $Date: 2002/02/25 06:07:21 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ata_device.v,v $
//               Revision 1.2  2002/02/25 06:07:21  rherveille
//               Fixed data-latch bug (posedge ata_diow instead of negedge ata_diow).
//
//               Revision 1.1  2001/08/16 10:01:05  rudi
//
//               - Added Test Bench
//               - Added Synthesis scripts for Design Compiler
//               - Fixed minor bug in atahost_top
//
//
//
//
//                        

// Modified by Nils-Johan Wessman 

`timescale 1ns / 10ps

module ata_device_oc(   ata_rst_n, ata_data, ata_da, ata_cs0, ata_cs1,
         ata_dior_n, ata_diow_n, ata_iordy, ata_intrq );
input    ata_rst_n;
inout [15:0]   ata_data;
input [2:0] ata_da;
input    ata_cs0, ata_cs1;
input    ata_dior_n, ata_diow_n;
output      ata_iordy;
output      ata_intrq;

integer     mode;
integer     n;
reg      ata_iordy;
reg      iordy_enable;
reg      ata_intrq;
integer     iordy_delay;

reg   [15:0]   mem[32:0];
reg   [15:0]   dout;
reg      dout_en;
wire     ata_rst_m0, ata_rst_m1, ata_rst_m2, ata_rst_m3, ata_rst_m4;
wire  [4:0] addr;
wire     ata_dior, ata_diow;

initial
   begin
   dout_en = 0;
   mode = 0;
   iordy_enable = 0;
   iordy_delay  = 0;
   ata_iordy    = 1;
   ata_intrq    = 0;
   end

assign ata_dior = !ata_dior_n;
assign ata_diow = !ata_diow_n;

//assign ata_intrq = 0;

assign ata_data = dout_en ? dout : 16'hzzzz;

assign addr = {~ata_cs1, ~ata_cs0, ata_da};

always @(posedge ata_rst_n)
   dout_en = 0;

always @(posedge ata_dior)
   begin
   dout = mem[ addr ];
   dout_en = 1;
   ata_intrq = 1;
   end

//always @(posedge ata_dior)
always @(negedge ata_dior)
   begin
   dout_en = 0;
   ata_intrq = 0;
   end

always @(posedge ata_diow)
   begin
   mem[ addr ] = ata_data;
   end

always @(posedge ata_dior or posedge ata_diow)
   begin
   ata_iordy = 1'b0;
   #(iordy_delay);
   ata_iordy = 1'b1;
   end

task init_mem;

begin

for(n=0;n<32;n=n+1)
   mem[n] = n;
end
endtask

assign ata_rst_m0 = ata_rst_n & (mode==0);
assign ata_rst_m1 = ata_rst_n & (mode==1);
assign ata_rst_m2 = ata_rst_n & (mode==2);
assign ata_rst_m3 = ata_rst_n & (mode==3);
assign ata_rst_m4 = ata_rst_n & (mode==4);

specify
        specparam // ATA Mode 0 Timing
         M0_DioCycle = 600,         // T0
            M0_AddrSetup   = 70,       // T1
         M0_DioHigh  = 290,         // T2
         M0_WrSetup  = 60,       // T3
         M0_WrHold   = 30,       // T4
         M0_DoutSetup   = 50,       // T5
         M0_DoutHold = 5,        // T6
            M0_AddrHold = 20,       // T9

         // ATA Mode 1 Timing
         M1_DioCycle = 383,         // T0
            M1_AddrSetup   = 50,       // T1
         M1_DioHigh  = 290,         // T2
         M1_WrSetup  = 45,       // T3
         M1_WrHold   = 20,       // T4
         M1_DoutSetup   = 35,       // T5
         M1_DoutHold = 5,        // T6
            M1_AddrHold = 15,       // T9

         // ATA Mode 2 Timing
         M2_DioCycle = 330,         // T0
            M2_AddrSetup   = 30,       // T1
         M2_DioHigh  = 290,         // T2
         M2_WrSetup  = 30,       // T3
         M2_WrHold   = 15,       // T4
         M2_DoutSetup   = 20,       // T5
         M2_DoutHold = 5,        // T6
            M2_AddrHold = 10,       // T9

         // ATA Mode 3 Timing
         M3_DioCycle = 180,         // T0
            M3_AddrSetup   = 30,       // T1
         M3_DioHigh  = 80,       // T2
         M3_DioLow   = 70,       // T2i
         M3_WrSetup  = 30,       // T3
         M3_WrHold   = 10,       // T4
         M3_DoutSetup   = 20,       // T5
         M3_DoutHold = 5,        // T6
            M3_AddrHold = 10,       // T9

         // ATA Mode 4 Timing
         M4_DioCycle = 120,         // T0
            M4_AddrSetup   = 25,       // T1
         M4_DioHigh  = 70,       // T2
         M4_DioLow   = 25,       // T2i
         M4_WrSetup  = 20,       // T3
         M4_WrHold   = 10,       // T4
         M4_DoutSetup   = 20,       // T5
         M4_DoutHold = 5,        // T6
            M4_AddrHold = 10;       // T9



   /////////////////////////////////////////////////////
   // ATA Mode 0 Timing                               //
   /////////////////////////////////////////////////////

   // Output Delay Path
   if(mode==0) (ata_dior_n => ata_data) = //(01,10,0z,z1,1z,z0)
               (0,0,
               M0_DoutHold, (M0_DioHigh - M0_DoutSetup),
               M0_DoutHold, (M0_DioHigh - M0_DoutSetup) );

   // Write Data Setup/Hold Check
   $setuphold(negedge ata_diow, ata_data, M0_WrSetup, M0_WrHold, , ,ata_rst_m0 );

   // DioX Active time Check
   $width(posedge ata_dior &&& ata_rst_m0, M0_DioHigh );
   $width(posedge ata_diow &&& ata_rst_m0, M0_DioHigh );

   // DioX Min Cycle Width Check
   $period(posedge ata_dior &&& ata_rst_m0, M0_DioCycle );
   $period(posedge ata_diow &&& ata_rst_m0, M0_DioCycle );

   // Address Setup Hold Checks
        $setup(ata_da,  posedge ata_dior &&& ata_rst_m0, M0_AddrSetup);
        $setup(ata_cs0, posedge ata_dior &&& ata_rst_m0, M0_AddrSetup);
        $setup(ata_cs1, posedge ata_dior &&& ata_rst_m0, M0_AddrSetup);
        $setup(ata_da,  posedge ata_diow &&& ata_rst_m0, M0_AddrSetup);
        $setup(ata_cs0, posedge ata_diow &&& ata_rst_m0, M0_AddrSetup);
        $setup(ata_cs1, posedge ata_diow &&& ata_rst_m0, M0_AddrSetup);

        $hold(ata_da,  negedge ata_dior &&& ata_rst_m0, M0_AddrHold);
        $hold(ata_cs0, negedge ata_dior &&& ata_rst_m0, M0_AddrHold);
        $hold(ata_cs1, negedge ata_dior &&& ata_rst_m0, M0_AddrHold);
        $hold(ata_da,  negedge ata_diow &&& ata_rst_m0, M0_AddrHold);
        $hold(ata_cs0, negedge ata_diow &&& ata_rst_m0, M0_AddrHold);
        $hold(ata_cs1, negedge ata_diow &&& ata_rst_m0, M0_AddrHold);


   /////////////////////////////////////////////////////
   // ATA Mode 1 Timing                               //
   /////////////////////////////////////////////////////

   // Output Delay Path
   if(mode==1) (ata_dior_n => ata_data) = //(01,10,0z,z1,1z,z0)
               (0,0,
               M1_DoutHold, (M1_DioHigh - M1_DoutSetup),
               M1_DoutHold, (M1_DioHigh - M1_DoutSetup) );

   // Write Data Setup/Hold Check
   $setuphold(negedge ata_diow, ata_data, M1_WrSetup, M1_WrHold, , ,ata_rst_m1 );

   // DioX Active time Check
   $width(posedge ata_dior &&& ata_rst_m1, M1_DioHigh );
   $width(posedge ata_diow &&& ata_rst_m1, M1_DioHigh );

   // DioX Min Cycle Width Check
   $period(posedge ata_dior &&& ata_rst_m1, M1_DioCycle );
   $period(posedge ata_diow &&& ata_rst_m1, M1_DioCycle );

   // Address Setup Hold Checks
        $setup(ata_da,  posedge ata_dior &&& ata_rst_m1, M1_AddrSetup);
        $setup(ata_cs0, posedge ata_dior &&& ata_rst_m1, M1_AddrSetup);
        $setup(ata_cs1, posedge ata_dior &&& ata_rst_m1, M1_AddrSetup);
        $setup(ata_da,  posedge ata_diow &&& ata_rst_m1, M1_AddrSetup);
        $setup(ata_cs0, posedge ata_diow &&& ata_rst_m1, M1_AddrSetup);
        $setup(ata_cs1, posedge ata_diow &&& ata_rst_m1, M1_AddrSetup);

        $hold(ata_da,  negedge ata_dior &&& ata_rst_m1, M1_AddrHold);
        $hold(ata_cs0, negedge ata_dior &&& ata_rst_m1, M1_AddrHold);
        $hold(ata_cs1, negedge ata_dior &&& ata_rst_m1, M1_AddrHold);
        $hold(ata_da,  negedge ata_diow &&& ata_rst_m1, M1_AddrHold);
        $hold(ata_cs0, negedge ata_diow &&& ata_rst_m1, M1_AddrHold);
        $hold(ata_cs1, negedge ata_diow &&& ata_rst_m1, M1_AddrHold);


   /////////////////////////////////////////////////////
   // ATA Mode 2 Timing                               //
   /////////////////////////////////////////////////////

   // Output Delay Path
   if(mode==2) (ata_dior_n => ata_data) = //(01,10,0z,z1,1z,z0)
               (0,0,
               M2_DoutHold, (M2_DioHigh - M2_DoutSetup),
               M2_DoutHold, (M2_DioHigh - M2_DoutSetup) );

   // Write Data Setup/Hold Check
   $setuphold(negedge ata_diow, ata_data, M2_WrSetup, M2_WrHold, , ,ata_rst_m2 );

   // DioX Active time Check
   $width(posedge ata_dior &&& ata_rst_m2, M2_DioHigh );
   $width(posedge ata_diow &&& ata_rst_m2, M2_DioHigh );

   // DioX Min Cycle Width Check
   $period(posedge ata_dior &&& ata_rst_m2, M2_DioCycle );
   $period(posedge ata_diow &&& ata_rst_m2, M2_DioCycle );

   // Address Setup Hold Checks
        $setup(ata_da,  posedge ata_dior &&& ata_rst_m2, M2_AddrSetup);
        $setup(ata_cs0, posedge ata_dior &&& ata_rst_m2, M2_AddrSetup);
        $setup(ata_cs1, posedge ata_dior &&& ata_rst_m2, M2_AddrSetup);
        $setup(ata_da,  posedge ata_diow &&& ata_rst_m2, M2_AddrSetup);
        $setup(ata_cs0, posedge ata_diow &&& ata_rst_m2, M2_AddrSetup);
        $setup(ata_cs1, posedge ata_diow &&& ata_rst_m2, M2_AddrSetup);

        $hold(ata_da,  negedge ata_dior &&& ata_rst_m2, M2_AddrHold);
        $hold(ata_cs0, negedge ata_dior &&& ata_rst_m2, M2_AddrHold);
        $hold(ata_cs1, negedge ata_dior &&& ata_rst_m2, M2_AddrHold);
        $hold(ata_da,  negedge ata_diow &&& ata_rst_m2, M2_AddrHold);
        $hold(ata_cs0, negedge ata_diow &&& ata_rst_m2, M2_AddrHold);
        $hold(ata_cs1, negedge ata_diow &&& ata_rst_m2, M2_AddrHold);

   /////////////////////////////////////////////////////
   // ATA Mode 3 Timing                               //
   /////////////////////////////////////////////////////

   // Output Delay Path
   if(mode==3) (ata_dior_n => ata_data) = //(01,10,0z,z1,1z,z0)
               (0,0,
               M3_DoutHold, (M3_DioHigh - M3_DoutSetup),
               M3_DoutHold, (M3_DioHigh - M3_DoutSetup) );

   // Write Data Setup/Hold Check
   $setuphold(negedge ata_diow, ata_data, M3_WrSetup, M3_WrHold, , ,ata_rst_m3 );

   // DioX Active time Check
   $width(posedge ata_dior &&& ata_rst_m3, M3_DioHigh );
   $width(posedge ata_diow &&& ata_rst_m3, M3_DioHigh );

   $width(negedge ata_dior &&& ata_rst_m3, M3_DioLow );
   $width(negedge ata_diow &&& ata_rst_m3, M3_DioLow );

   // DioX Min Cycle Width Check
   $period(posedge ata_dior &&& ata_rst_m3, M3_DioCycle );
   $period(posedge ata_diow &&& ata_rst_m3, M3_DioCycle );

   // Address Setup Hold Checks
        $setup(ata_da,  posedge ata_dior &&& ata_rst_m3, M3_AddrSetup);
        $setup(ata_cs0, posedge ata_dior &&& ata_rst_m3, M3_AddrSetup);
        $setup(ata_cs1, posedge ata_dior &&& ata_rst_m3, M3_AddrSetup);
        $setup(ata_da,  posedge ata_diow &&& ata_rst_m3, M3_AddrSetup);
        $setup(ata_cs0, posedge ata_diow &&& ata_rst_m3, M3_AddrSetup);
        $setup(ata_cs1, posedge ata_diow &&& ata_rst_m3, M3_AddrSetup);

        $hold(ata_da,  negedge ata_dior &&& ata_rst_m3, M3_AddrHold);
        $hold(ata_cs0, negedge ata_dior &&& ata_rst_m3, M3_AddrHold);
        $hold(ata_cs1, negedge ata_dior &&& ata_rst_m3, M3_AddrHold);
        $hold(ata_da,  negedge ata_diow &&& ata_rst_m3, M3_AddrHold);
        $hold(ata_cs0, negedge ata_diow &&& ata_rst_m3, M3_AddrHold);
        $hold(ata_cs1, negedge ata_diow &&& ata_rst_m3, M3_AddrHold);


   /////////////////////////////////////////////////////
   // ATA Mode 4 Timing                               //
   /////////////////////////////////////////////////////

   // Output Delay Path
   if(mode==4) (ata_dior_n => ata_data) = //(01,10,0z,z1,1z,z0)
               (0,0,
               M4_DoutHold, (M4_DioHigh - M4_DoutSetup),
               M4_DoutHold, (M4_DioHigh - M4_DoutSetup) );

   // Write Data Setup/Hold Check
   $setuphold(negedge ata_diow, ata_data, M4_WrSetup, M4_WrHold, , ,ata_rst_m4 );

   // DioX Active time Check
   $width(posedge ata_dior &&& ata_rst_m4, M4_DioHigh );
   $width(posedge ata_diow &&& ata_rst_m4, M4_DioHigh );

   $width(negedge ata_dior &&& ata_rst_m4, M4_DioLow );
   $width(negedge ata_diow &&& ata_rst_m4, M4_DioLow );

   // DioX Min Cycle Width Check
   $period(posedge ata_dior &&& ata_rst_m4, M4_DioCycle );
   $period(posedge ata_diow &&& ata_rst_m4, M4_DioCycle );

   // Address Setup Hold Checks
        $setup(ata_da,  posedge ata_dior &&& ata_rst_m4, M4_AddrSetup);
        $setup(ata_cs0, posedge ata_dior &&& ata_rst_m4, M4_AddrSetup);
        $setup(ata_cs1, posedge ata_dior &&& ata_rst_m4, M4_AddrSetup);
        $setup(ata_da,  posedge ata_diow &&& ata_rst_m4, M4_AddrSetup);
        $setup(ata_cs0, posedge ata_diow &&& ata_rst_m4, M4_AddrSetup);
        $setup(ata_cs1, posedge ata_diow &&& ata_rst_m4, M4_AddrSetup);

        $hold(ata_da,  negedge ata_dior &&& ata_rst_m4, M4_AddrHold);
        $hold(ata_cs0, negedge ata_dior &&& ata_rst_m4, M4_AddrHold);
        $hold(ata_cs1, negedge ata_dior &&& ata_rst_m4, M4_AddrHold);
        $hold(ata_da,  negedge ata_diow &&& ata_rst_m4, M4_AddrHold);
        $hold(ata_cs0, negedge ata_diow &&& ata_rst_m4, M4_AddrHold);
        $hold(ata_cs1, negedge ata_diow &&& ata_rst_m4, M4_AddrHold);



endspecify


endmodule


