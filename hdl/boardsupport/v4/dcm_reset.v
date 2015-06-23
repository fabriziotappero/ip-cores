//------------------------------------------------------------------------------
// Title      : Reset Logic for DCM 
// Project    : Virtex-4 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : dcm_reset.v
// Version    : 4.8
//-----------------------------------------------------------------------------
//
// (c) Copyright 2004-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//------------------------------------------------------------------------------
// Description:  DCM Reset Logic.
//
//               This logic creates a 200ms reset pulse required by the 
//               Virtex-4 DCM.
//
//               The resetwill fire under the following conditions:
//
//                  * When the DCM timeout counter wraps around
//                  * When the falling edge of DCM locked is detected
//
//               The timeout counter will time a > 1ms interval.  If the DCM
//               locked signal has been low for this duration then it will be
//               issued with a reset and the timer will reset.  This is
//               required for DCMs connected to Ethernet PHYs since the PHYs
//               may source discontinuous clocks under certain network
//               conditions.
//------------------------------------------------------------------------------

`timescale 1 ps/1 ps

//------------------------------------------------------------------------------
// The module declaration for the DCM Reset Logic
//------------------------------------------------------------------------------

module dcm_reset (
    ref_reset,
    ref_clk,
    dcm_locked,
    dcm_reset);

  input      ref_reset ; // Synchronous reset in ref_clk domain
   input      ref_clk;    // Reliable reference clock of known frequency (125MHz)
  input      dcm_locked; // The DCM locked signal
  output     dcm_reset;  // The reset signal which should be connected to the DCM
  


  //----------------------------------------------------------------------------
  // Signals used in this module
  //----------------------------------------------------------------------------

  // Signals required for DCM timeout reset in the reference clock domain
  wire       dcm_locked_sync;       //dcm_locked registered twice in the ref_clk 
                                    //domain.
  reg        dcm_locked_sync_reg;   //dcm_locked registered thrice in the ref_clk
                                    //domain.
  
  wire       ref_reset_sync;        //ref_reset registered twice in the ref_clk
                                    //domain

  reg [16:0] timeout;               //the timeout counter
  reg        timeout_msbit_reg;
  reg        timeout_reset;         //a reset created by a timeout condition
  reg        dcm_reset_init;        //automatic reset pulse applied to dcm on loss of lock.
  reg  [8:0] reset_counter;
  reg        reset_200ms_int;       //200ms reset pulse for the DCM


  //-----------------------
  // Reference clock domain
  //-----------------------
  // The reference clock will always be present and of frequency 125MHz.  
  // Since this clock is predictable, it is used to create the DCM timeout 
  // counter.
  // This counter will increment when the locked signal is low (not locked).
  // When the timer expires, a further reset of the DCM will be issued.

  // Synchronize ref_reset in the reference clock domain
  sync_block ref_reset_sync_inst (
    .clk            (ref_clk),
    .data_in        (ref_reset),
    .data_out       (ref_reset_sync)
  );

  // Reclock DCM locked in the reference clock domain
  sync_block dcm_locked_sync_inst (
    .clk            (ref_clk),
    .data_in        (dcm_locked),
    .data_out       (dcm_locked_sync)
  );


   // When the DCM is locked, the timeout counter is held at zero.
   // When not locked the timeout counter will increment.
   always @(posedge ref_clk)
   begin : dcm_timeout_counter
       if (timeout_reset) begin
          timeout           <= 17'b0;
          timeout_msbit_reg <= 1'b0;
       end

       else begin
          timeout_msbit_reg <= timeout[16];
          if (dcm_locked_sync & !reset_200ms_int) begin
             timeout   <= 17'b0;
          end
          else begin
             timeout   <= timeout + 1'b1;
          end
       end
   end // dcm_timeout_counter


   // A reset pulse is generated when the timeout counter wraps around.
   always @(posedge ref_clk)
   begin : dcm_timeout_reset_p
      if (ref_reset_sync) begin
         timeout_reset <= 1'b1;
      end
      else begin
        timeout_reset <= !timeout[16] & timeout_msbit_reg & !dcm_locked_sync & !reset_200ms_int;
      end
   end // dcm_timeout_reset_p


   // Create a reset to fire under the following conditions:
   // * When the DCM timeout counter wraps around
   // * When the falling edge of DCM locked is detected
   always @(posedge ref_clk)
   begin : reset_dcm_prelim
      if (timeout_reset) begin
         dcm_locked_sync_reg  <= 1'b1;
         dcm_reset_init       <= 1'b1;
      end

      else begin
         dcm_locked_sync_reg  <= dcm_locked_sync;
         dcm_reset_init       <= !dcm_locked_sync & dcm_locked_sync_reg;
      end
   end // reset_dcm_prelim;

   // generate a large counter to time ~200ms
   always @(posedge ref_clk)
   begin : dcm_reset_timer_p
      if (dcm_reset_init) begin
         reset_counter        <= 9'b110000000;
         reset_200ms_int      <= 1'b1;
      end

      else begin
         if (reset_counter == 9'b0) begin
            reset_200ms_int   <= 1'b0;
         end

         else begin
            reset_200ms_int   <= 1'b1;

            if (timeout[16] ^ timeout_msbit_reg) begin
               reset_counter  <= reset_counter - 1'b1;
            end

         end
      end
   end // dcm_reset_timer_p;

   // This is the produced reset signal for the Virtex-4 DCM
   assign dcm_reset = reset_200ms_int;

endmodule

