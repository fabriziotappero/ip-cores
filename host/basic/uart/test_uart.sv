// Test UART module

// 5 MHz for a functional simulation (no delay timings)
`timescale 100 ns/ 100 ns

module test_uart;

logic uart_tx;
bit clk;
logic reset = 1;
logic [7:0] Address = 0;
reg [7:0] Data_wr;
wire [7:0] Data_rd;
logic IORQ = 0, RD = 0, WR = 0;

initial begin
    repeat (2) @(posedge clk);
    reset <= 0;

    // Write a byte
    Address <= 8'd8;
    Data_wr[7:0] <= 8'h34;
    IORQ <= 1;
    WR <= 1;
    repeat (2) @(posedge clk);
    Data_wr[7:0] <= 8'hz;
    IORQ <= 0;
    WR <= 0;

    repeat (6) @(posedge clk);

    // Check for busy
    Address <= 8'd10;
    IORQ <= 1;
    RD <= 1;
    repeat (2) @(posedge clk);
    $display("%s", Data_rd[7:0]);
    IORQ <= 0;
    RD <= 0;

    repeat (30) @(posedge clk);

    // Check for busy (now that it's not)
    Address <= 8'd10;
    IORQ <= 1;
    RD <= 1;
    repeat (2) @(posedge clk);
    $display("%s", Data_rd[7:0]);
    IORQ <= 0;
    RD <= 0;

    repeat (10) @(posedge clk);
    #1 $display("End of test");
    #1 $stop();
end

initial forever #1 clk = ~clk;

assign Data_rd = Data_wr;

// Instantiate UART module
defparam uart_io.uart_core_.BAUD = 50000000/2;
uart_io uart_io( .*, .Data(Data_rd) );

endmodule
