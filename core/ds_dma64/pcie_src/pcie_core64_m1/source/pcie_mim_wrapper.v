
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
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
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : pcie_mim_wrapper.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

module pcie_mim_wrapper #(
   parameter TL_TX_SIZE = 4096,
   parameter TXWRITEPIPE = 0,
   parameter TXREADADDRPIPE = 0,
   parameter TXREADDATAPIPE = 0,

   parameter TL_RX_SIZE = 4096, 
   parameter RXWRITEPIPE = 0,
   parameter RXREADADDRPIPE = 0,
   parameter RXREADDATAPIPE = 0,

   parameter TLRAMREADLATENCY = 3,
   parameter TLRAMWRITELATENCY = 0,

   parameter RETRYRAMSIZE = 9,
   parameter RETRYRAMREADLATENCY = 3, 
   parameter RETRYRAMWRITELATENCY = 0,
   parameter RETRYWRITEPIPE = 0,
   parameter RETRYREADADDRPIPE = 0,
   parameter RETRYREADDATAPIPE = 0
)

(
   input    [63:0]   mim_rx_bwdata, // Write data for TL RX buffers,  
   output   [63:0]   mim_rx_brdata, // Read data for TL RX buffers,  
   input    [12:0]   mim_rx_bwadd, // Write Address for TL RX Buffers,
   input    [12:0]   mim_rx_bradd, // Read Address for TL RX Buffers,
   input             mim_rx_bwen,  // Write Enable for TL RX Buffers,
   input             mim_rx_bren, // Read enable for TL RX Buffers,
   input             mim_rx_bwclk,// Write clock for TL RX Buffers,
   input             mim_rx_brclk,// Read clock for TL RX Buffers,

   input    [63:0]   mim_tx_bwdata, // Write data for TL TX buffers,  
   output   [63:0]   mim_tx_brdata, // Read data for TL TX buffers,  
   input    [12:0]   mim_tx_bwadd, // Write Address for TL TX Buffers,
   input    [12:0]   mim_tx_bradd, // Read Address for TL TX Buffers,
   input             mim_tx_bwen,  // Write Enable for TL TX Buffers,
   input             mim_tx_bren, // Read enable for TL TX Buffers,
   input             mim_tx_bwclk,// Write clock for TL TX Buffers,
   input             mim_tx_brclk,// Read clock for TL TX Buffers,

   input    [63:0]   mim_dll_bwdata, // Write data for DLL Retry buffers,  
   output   [63:0]   mim_dll_brdata, // Read data for DLL Retry buffers,  
   input    [11:0]   mim_dll_bwadd, // Write Address for DLL Retry Buffers,
   input    [11:0]   mim_dll_bradd, // Read Address for DLL Retry Buffers,
   input             mim_dll_bwen,  // Write Enable for DLL Retry Buffers,
   input             mim_dll_bren, // Read enable for DLL Retry Buffers,
   input             mim_dll_bclk // Read/Write Clock for DLL Retry Buffers

);



  


// retry bram quanties are always in powers of 2.
// the code which is passed from the top level module is based on the following alogrithm
// log2(size in bytes) -3. we have to reverse the alogrithm.
// the size in bytes can be expressed as power of 2
// the exponent for the user entered size can be obtained by adding 3 to the value passed by top level
   parameter NUM_RETRY_BRAMS = 2**(RETRYRAMSIZE + 3 - 12);
   parameter BRAM_SIZE = 4096;
   // the above value is based on the fact that all BRAMs are 32Kb = 4096 bytes in size.
   // this is the default. If the building block BRAM size changes, this needs to be modified

   // Note: function will never return a value of 0
// modified this to remove the function and fix a max limit of 32 BRAMS
//   parameter NUM_TL_TX_BRAMS = get_num_bram_pwr2(TL_TX_SIZE, BRAM_SIZE);
//   parameter NUM_TL_RX_BRAMS = get_num_bram_pwr2(TL_RX_SIZE, BRAM_SIZE);
  parameter NUM_TL_TX_BRAMS = (TL_TX_SIZE > 16*BRAM_SIZE) ? 32 : 
                              (TL_TX_SIZE > 8*BRAM_SIZE) ? 16 : 
                              (TL_TX_SIZE > 4*BRAM_SIZE) ? 8:
                              (TL_TX_SIZE > 2*BRAM_SIZE) ? 4: 
                              (TL_TX_SIZE > BRAM_SIZE) ? 2:1; 
  parameter NUM_TL_RX_BRAMS = (TL_RX_SIZE > 16*BRAM_SIZE) ? 32 : 
                              (TL_RX_SIZE > 8*BRAM_SIZE) ? 16 : 
                              (TL_RX_SIZE > 4*BRAM_SIZE) ? 8:
                              (TL_RX_SIZE > 2*BRAM_SIZE) ? 4: 
                              (TL_RX_SIZE > BRAM_SIZE) ? 2:1; 
   
   wire  [63:0]   bram_retry_dangle_douta;
   wire  [63:0]   bram_tl_tx_dangle_douta;
   wire  [63:0]   bram_tl_rx_dangle_douta;
// bram_common is a common single top level entity which is reused to model the three buffers
// writes are through port a and reads are through portb

// RELEASE NOTE: All BRAMs have fixed read latencies of 3 and require the output register
// to be enabled. Hence the parameter BRAM_OREG is set to 1 in all buffers
initial begin
$display("===== Number of BRAMS for RETRYRAM = %d  =====",NUM_RETRY_BRAMS);
$display("===== Number of BRAMS for TL_TXRAM = %d  =====",NUM_TL_TX_BRAMS);
$display("===== Number of BRAMS for TL_RXRAM = %d  =====",NUM_TL_RX_BRAMS);
end

bram_common #(
      .NUM_BRAMS(NUM_RETRY_BRAMS),
      .ADDR_WIDTH(12),
      .READ_LATENCY(RETRYRAMREADLATENCY),
      .WRITE_LATENCY(RETRYRAMWRITELATENCY),
      .WRITE_PIPE(RETRYWRITEPIPE),
      .READ_ADDR_PIPE(RETRYREADADDRPIPE),
      .READ_DATA_PIPE(RETRYREADDATAPIPE), 
      .BRAM_OREG(1)

      )
      bram_retry(
      .clka(mim_dll_bclk),
      .ena(mim_dll_bwen),
      .wena(mim_dll_bwen),
      .dina(mim_dll_bwdata),
      .douta(bram_retry_dangle_douta),
      .addra(mim_dll_bwadd),
      .clkb(mim_dll_bclk),
      .enb(mim_dll_bren),
      .wenb(!mim_dll_bren),
      .dinb(64'h00000000),
      .doutb(mim_dll_brdata),
      .addrb(mim_dll_bradd)
      );

bram_common #(
      .NUM_BRAMS(NUM_TL_TX_BRAMS),
      .ADDR_WIDTH(13),
      .READ_LATENCY(TLRAMREADLATENCY),
      .WRITE_LATENCY(TLRAMWRITELATENCY),
      .WRITE_PIPE(TXWRITEPIPE),
      .READ_ADDR_PIPE(TXREADADDRPIPE),
      .READ_DATA_PIPE(TXREADDATAPIPE), 
      .BRAM_OREG(1)
      )
      bram_tl_tx(
      .clka(mim_tx_bwclk),
      .ena(mim_tx_bwen),
      .wena(mim_tx_bwen),
      .dina(mim_tx_bwdata),
      .douta(bram_tl_tx_dangle_douta),
      .addra(mim_tx_bwadd),
      .clkb(mim_tx_brclk),
      .enb(mim_tx_bren),
      .wenb(!mim_tx_bren),
      .dinb(64'h00000000),
      .doutb(mim_tx_brdata),
      .addrb(mim_tx_bradd)
      );

bram_common #(
      .NUM_BRAMS(NUM_TL_RX_BRAMS),
      .ADDR_WIDTH(13),
      .READ_LATENCY(TLRAMREADLATENCY),
      .WRITE_LATENCY(TLRAMWRITELATENCY),
      .WRITE_PIPE(RXWRITEPIPE),
      .READ_ADDR_PIPE(RXREADADDRPIPE),
      .READ_DATA_PIPE(RXREADDATAPIPE), 
      .BRAM_OREG(1)
      )
      bram_tl_rx(
      .clka(mim_rx_bwclk),
      .ena(mim_rx_bwen),
      .wena(mim_rx_bwen),
      .dina(mim_rx_bwdata),
      .douta(bram_tl_rx_dangle_douta),
      .addra(mim_rx_bwadd),
      .clkb(mim_rx_brclk),
      .enb(mim_rx_bren),
      .wenb(!mim_rx_bren),
      .dinb(64'h00000000),
      .doutb(mim_rx_brdata),
      .addrb(mim_rx_bradd)
      );
     

endmodule

