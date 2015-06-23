/*
 * Simply RISC M1 Memory Management Unit
 *
 * This block converts Harvard architecture requests to access the
 * small internal prefetch buffer, and just in case the external
 * Wishbone bus.
 * Memory size is 256 word * 4 byte = 1024 byte,
 * so 10 address bits are required => [9:0]
 * and being the lower 2 bits unused the offset in memory is [9:2].
 */

module m1_mmu (

    // System
    input sys_clock_i,                            // System Clock
    input sys_reset_i,                            // System Reset

    // Instruction Memory
    input imem_read_i,                            // I$ Read
    input[31:0] imem_addr_i,                      // I$ Address
    output imem_done_o,                           // I$ Done
    output[31:0] imem_data_o,                     // I$ Data

    // Data Memory
    input dmem_read_i,                            // D$ Read
    input dmem_write_i,                           // D$ Write
    input[31:0] dmem_addr_i,                      // D$ Address
    input[31:0] dmem_data_i,                      // D$ Write Data
    input[3:0] dmem_sel_i,                        // D$ Byte selector
    output dmem_done_o,                           // D$ Done
    output[31:0] dmem_data_o,                     // D$ Read Data

    // Wishbone Master interface
    output wb_cyc_o,                              // Cycle Start
    output wb_stb_o,                              // Strobe Request
    output wb_we_o,                               // Write Enable
    output[31:0] wb_adr_o,                        // Address Bus
    output[31:0] wb_dat_o,                        // Data Out
    output[3:0] wb_sel_o,                         // Byte Select
    input wb_ack_i,                               // Ack
    input[31:0] wb_dat_i                          // Data In

  );

  /*
   * Registers
   */

  // Prefetch buffer
  reg[31:0] MEM[255:0];

  // Initialize memory content
  initial begin
`include "m1_mmu_initial.vh"
  end

  /*
   * Wires
   */

  // See if there are pending requests
  wire access_pending_imem = imem_read_i;
  wire access_pending_dmem = 0;
  wire access_pending_ext = (dmem_read_i || dmem_write_i);

  // Default grant for memories
  assign imem_done_o = access_pending_imem;
  assign dmem_done_o = access_pending_dmem || (access_pending_ext && wb_ack_i);

  // Set Wishbone outputs
  assign wb_cyc_o = access_pending_ext;
  assign wb_stb_o = access_pending_ext;
  assign wb_we_o = access_pending_ext && dmem_write_i;
  assign wb_sel_o = dmem_sel_i;
  assign wb_adr_o = dmem_addr_i;
  assign wb_dat_o = dmem_data_i;

  // Return read data
  assign imem_data_o = MEM[imem_addr_i[9:2]];
  assign dmem_data_o = wb_dat_i;

endmodule
