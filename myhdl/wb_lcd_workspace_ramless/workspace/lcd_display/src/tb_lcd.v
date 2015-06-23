module tb_lcd;

reg clk;
reg reset;
reg [31:0] dat;
reg [6:0] addr;
reg we;
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
        we
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
    busy,
    SF_D,
    LCD_E,
    LCD_RS,
    LCD_RW
);

endmodule
