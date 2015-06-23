/*
 * Simply RISC S1 Testbench
 *
 * (C) 2007 Simply RISC LLP
 * AUTHOR: Fabrizio Fazzino <fabrizio.fazzino@srisc.com>
 *
 * LICENSE:
 * This is a Free Hardware Design; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 * The above named program is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * DESCRIPTION:
 * This is the testbench for the functional verification of the
 * S1 Core: it makes and instance of the S1 module to make it
 * possible to access one or more memory harnesses.
 */

`include "s1_defs.h"

module testbench ();

  /*
   * Wires
   */

  // Interrupt Requests
  wire[63:0] sys_irq;

  // Wishbone Master inputs / Wishbone Slave ouputs
  wire wb_ack;                                 // Ack
  wire[(`WB_DATA_WIDTH-1):0] wb_datain;        // Data In

  // Wishbone Master outputs / Wishbone Slave inputs
  wire wb_cycle;                               // Cycle Start
  wire wb_strobe;                              // Strobe Request
  wire wb_we_o;                                // Write Enable
  wire[`WB_ADDR_WIDTH-1:0] wb_addr;            // Address Bus
  wire[`WB_DATA_WIDTH-1:0] wb_dataout;         // Data Out
  wire[`WB_DATA_WIDTH/8-1:0] wb_sel;           // Select Output

  // Separate Cycle, Strobe and Ack wires for ROM and RAM memory harnesses
  wire wb_cycle_ram;
  wire wb_cycle_rom;
  wire wb_strobe_ram;
  wire wb_strobe_rom;
  wire wb_ack_ram;
  wire wb_ack_rom;

  // Decode the address and select the proper memory bank

  assign wb_cycle_rom  = ( (wb_addr[39:12]==28'hFFF0000) ? wb_cycle : 0 );
  assign wb_strobe_rom = ( (wb_addr[39:12]==28'hFFF0000) ? wb_strobe : 0 );

  assign wb_cycle_ram  = ( (wb_addr[39:16]==24'h000004) ? wb_cycle : 0 );
  assign wb_strobe_ram = ( (wb_addr[39:16]==24'h000004) ? wb_strobe : 0 );

  assign wb_ack = wb_ack_ram | wb_ack_rom;

  /*
   * Registers
   */

  // System signals
  reg sys_clock;
  reg sys_reset;

  /*
   * Behavior
   */

  always #1 sys_clock = ~sys_clock;
  assign sys_irq = 64'b0;

  initial begin

    // Display start message
    $display("INFO: TBENCH: Starting Simply RISC S1 Core simulation...");

    // Create VCD trace file
    $dumpfile("trace.vcd");
    $dumpvars();

    // Run the simulation
    sys_clock <= 1'b1;
    sys_reset <= 1'b1;
    #1000
    sys_reset <= 1'b0;
    #49000
    $display("INFO: TBENCH: Completed Simply RISC S1 Core simulation!");
    $finish;

  end

  /*
   * Module instances
   */

  // Simply RISC S1 Core
  s1_top s1_top_0 (

    // System inputs
    .sys_clock_i(sys_clock),
    .sys_reset_i(sys_reset),
    .sys_irq_i(sys_irq),

    // Wishbone Master inputs
    .wbm_ack_i(wb_ack),
    .wbm_data_i(wb_datain),

    // Wishbone Master outputs
    .wbm_cycle_o(wb_cycle),
    .wbm_strobe_o(wb_strobe),
    .wbm_we_o(wb_we),
    .wbm_addr_o(wb_addr),
    .wbm_data_o(wb_dataout),
    .wbm_sel_o(wb_sel)

  );
   
  // Wishbone memory harness used as ROM
  mem_harness rom_harness (

    // System inputs
    .sys_clock_i(sys_clock),
    .sys_reset_i(sys_reset),

    // Wishbone Slave inputs
    .wbs_addr_i(wb_addr),
    .wbs_data_i(wb_dataout),
    .wbs_cycle_i(wb_cycle_rom),
    .wbs_strobe_i(wb_strobe_rom),
    .wbs_sel_i(wb_sel),
    .wbs_we_i(wb_we),

    // Wishbone Slave outputs
    .wbs_data_o(wb_datain),
    .wbs_ack_o(wb_ack_rom)

  );

  // Wishbone memory harness used as RAM
  mem_harness ram_harness (

    // System inputs
    .sys_clock_i(sys_clock),
    .sys_reset_i(sys_reset),

    // Wishbone Slave inputs
    .wbs_addr_i(wb_addr),
    .wbs_data_i(wb_dataout),
    .wbs_cycle_i(wb_cycle_ram),
    .wbs_strobe_i(wb_strobe_ram),
    .wbs_sel_i(wb_sel),
    .wbs_we_i(wb_we),

    // Wishbone Slave outputs
    .wbs_data_o(wb_datain),
    .wbs_ack_o(wb_ack_ram)

  );

  /*
   * Parameters for memory harnesses
   */

  // ROM has Physical Address range [0xFFF0000000:0xFFF0000FFF]
  // so size is 4 KByte and requires 12 address bits
  // 3 of which are ignored being a 64-bit memory => addr_bits=9
  // (it was section RED_SEC in the official OpenSPARC-T1 testbench)
  defparam rom_harness.addr_bits = 9;
  defparam rom_harness.memfilename = "rom_harness.hex";
  defparam rom_harness.memdefaultcontent = 64'h0100000001000000;

  // RAM has Physical Address range [0x0000040000:0x000004FFFF]
  // so size is 64 KByte and requires 16 address bits
  // 3 of which are ignored being a 64-bit memory => addr_bits=13
  // (it was section RED_EXT_SEC in the official OpenSPARC-T1 testbench)
  defparam ram_harness.addr_bits = 13;
  defparam ram_harness.memfilename = "ram_harness.hex";
  defparam ram_harness.memdefaultcontent = 64'h0100000001000000;
   
endmodule
