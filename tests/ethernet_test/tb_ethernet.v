`timescale 10ns / 1ns

module tb_ocs_floppy();

reg clk_50;

ethernet ethernet_inst(
    .clk_50(clk_50),
    .reset_ext_n(1'b1),
    
    .enet_clk_25(),
    .enet_reset_n(),
    .enet_cs_n(),
    
    .enet_irq(1'b0),
    
    .enet_ior_n(),
    .enet_iow_n(),
    .enet_cmd(),

    .enet_data(),
    
    .key(1'b0),
    .leds()
);

initial begin
    clk_50 = 1'b0;
    forever #5 clk_50 = ~clk_50;
end

initial begin
    $dumpfile("tb_ethernet.vcd");
    $dumpvars(0);
    $dumpon();
    
    #10000
    
    $finish();
end

endmodule

