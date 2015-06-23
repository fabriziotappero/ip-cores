/*
 * Interrupt Controller with Wishbone Slave Interface
 */

module wb_int_ctrl (

    // System
    input sys_clock_i,            // System Clock
    input sys_reset_i,            // System Reset

    // Interrupts
    input[31:0] sys_irqs_i,       // Input IRQs
    output sys_irq_o,             // Output IRQ

    // Wishbone slave interface
    input wb_cyc_i,
    input wb_stb_i,
    input wb_we_i,
    input[3:0] wb_sel_i,
    input[31:0] wb_adr_i,
    input[31:0] wb_dat_i,
    output wb_ack_o,
    output[31:0] wb_dat_o

  );

  assign sys_irq_o = (|sys_irqs_i);  // Unary OR reduction operator
  assign wb_ack_o = (wb_cyc_i & wb_stb_i);
  assign wb_dat_o = sys_irqs_i;

endmodule


