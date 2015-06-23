module tb_lcd;

reg clk;
reg reset;
reg [31:0] dat;
reg [6:0] addr;
reg we;
reg repaint;
wire busy;
wire [3:0] SF_D;
wire LCD_E;
wire LCD_RS;
wire LCD_RW;

initial begin
    $from_myhdl(
        clk,
        reset,
        dat,
        addr,
        we,
        repaint
    );
    $to_myhdl(
        busy,
        SF_D,
        LCD_E,
        LCD_RS,
        LCD_RW
    );
end

lcd dut(
    clk,
    reset,
    dat,
    addr,
    we,
    repaint,
    busy,
    SF_D,
    LCD_E,
    LCD_RS,
    LCD_RW
);

endmodule
