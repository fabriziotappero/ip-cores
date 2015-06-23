
module ps2_soc(
    input                   CLOCK_50,
    
    inout                   PS2_CLK,
    inout                   PS2_DAT,
    
    inout                   PS2_CLK2,
    inout                   PS2_DAT2
);

wire clk_30;
wire reset_n;

pll pll_inst(
    .inclk0         (CLOCK_50),
    .c0             (clk_30),
    .locked         (reset_n)
);

wire ps2_export_interrupt_keyb;
wire ps2_export_interrupt_mouse;
wire ps2_export_output_a20_enable;
wire ps2_export_output_reset_n;

soc u0 (
    .clk_clk                      (clk_30),                      //        clk.clk
    .reset_reset_n                (reset_n),                //      reset.reset_n
    .ps2_export_interrupt_keyb    (ps2_export_interrupt_keyb),    // ps2_export.interrupt_keyb
    .ps2_export_interrupt_mouse   (ps2_export_interrupt_mouse),   //           .interrupt_mouse
    .ps2_export_output_a20_enable (ps2_export_output_a20_enable), //           .output_a20_enable
    .ps2_export_output_reset_n    (ps2_export_output_reset_n),    //           .output_reset_n
    .ps2_export_ps2_kbclk         (PS2_CLK),         //           .ps2_kbclk
    .ps2_export_ps2_kbdat         (PS2_DAT),         //           .ps2_kbdat
    .ps2_export_ps2_mouseclk      (PS2_CLK2),      //           .ps2_mouseclk
    .ps2_export_ps2_mousedat      (PS2_DAT2),      //           .ps2_mousedat
    .pio_0_external_export        ({ 4'd0, ps2_export_output_reset_n, ps2_export_output_a20_enable, ps2_export_interrupt_mouse, ps2_export_interrupt_keyb })         // pio_0_external.export
);
  
endmodule
