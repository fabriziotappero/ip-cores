// Module:    top
// Revision:  01
// Language:  SystemVerilog
// Engineer:  Ashot Khachatryan
// Function:  Simulation top module for DS1621 behavioral model testing in Cadence IUS8.2 environment
// Comments:  20100402 AKH: Created.
//

`timescale 1ns / 1ps

module top;

int          cycle_count;
logic        RST;
logic  [2:0] I2C;      // WP for EEPROM, SCL, SDA
wire         SCL, SDA;
real         board_temp01, board_temp06;
wire         Temper_o01, Temper_o06;
wire  [64:1] Temper_s01 = $realtobits(board_temp01);
wire  [64:1] Temper_s06 = $realtobits(board_temp06);
bit          clk1k;

  // test vars
bit          bit_status;
logic  [7:0] data, g_logic_8;
logic [15:0] g_logic_16;

task  write( logic [1:0] W_DATA );  I2C  = W_DATA;  endtask  // {WP, SCL, SDA}
task  read( output bit data );      data = SDA;     endtask

assign WP  = I2C[2];
assign SCL = I2C[1];
assign SDA = I2C[0] ? 1'bz : 1'b0;

`include "ds1621/files/eeprom_macros.sv"   // EEPROM and DS1621 macro tasks

  // Simulation recording
initial begin
    $shm_open ("out.shm");
    $shm_probe("ACMTF");
end

initial begin
    cycle_count  = 1;
    I2C          = 3'b111;
    board_temp01 = 20.0;
    board_temp06 = 20.0;
   #1
    RST          = 1;
   #100
    RST          = 0;
    $display("*****************************");
    $display("*                           *");
    $display("*    DS1621 simulation      *");
    $display("*                           *");
    $display("*****************************");

    `include "ds1621/files/tb_ds1621.sv"

   #10_000
    $finish;
end

  // EEPROM
M24LC16B  u_24LC16B(
     .WP      ( WP )
    ,.SCL     ( SCL )
    ,.SDA     ( SDA )
    ,.RESET   ( RST )   // Model from Microchip
);

  // Temperature sensors // for simulation acceleration the timing is reduced here
DS1621_b  #(1000, 1_000_000, 500, 2_000_000) u_DS1621_b_01(
     .SCL     ( SCL )
    ,.SDA     ( SDA )
    ,.A0      ( 1'b1 )
    ,.A1      ( 1'b0 )
    ,.A2      ( 1'b0 )
    ,.TOUT    ( Temper_o01 )
    ,.TEMP_R  ( Temper_s01 )
);

DS1621_b  #(1000, 1_000_000, 500, 1_800_000) u_DS1621_b_06(
     .SCL     ( SCL )
    ,.SDA     ( SDA )
    ,.A0      ( 1'b0 )
    ,.A1      ( 1'b1 )
    ,.A2      ( 1'b1 )
    ,.TOUT    ( Temper_o06 )
    ,.TEMP_R  ( Temper_s06 )
);

initial begin  clk1k = 1; forever clk1k = #(1000/2) ~clk1k;  end

clocking cb1k @( posedge clk1k );
    default input #1step output #1step;
endclocking

// Cycle counter (cb1k)
always @( cb1k ) begin // posedge clk1k
    cycle_count <= cycle_count +1;
    if( !(cycle_count % 1000) )  $display("passing %0d us", cycle_count);
end

endmodule
