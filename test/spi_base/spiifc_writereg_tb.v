`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:08:12 02/15/2012
// Design Name:   spiifc
// Module Name:   C:/workspace/robobees/hbp/fpga/spitest/pcores/spi_v1_00_a/hdl/verilog/spiifc_tb2.v
// Project Name:  spi
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: spiifc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module spiifc_writereg_tb;

	// Inputs
	reg Reset;
  reg SysClk;
  
	reg SPI_CLK;
	reg SPI_MOSI;
	reg SPI_SS;
	reg [7:0] txMemData;
  reg [31:0] regReadData_wreg;
    
	// Outputs
	wire SPI_MISO;
	wire [11:0] txMemAddr;
	wire [11:0] rcMemAddr;
	wire [7:0] rcMemData;
	wire rcMemWE;
  wire [7:0] debug_out;
  wire [3:0] regAddr;

  wire [31:0] regWriteData;
  wire        regWE;

  // Register bank
  reg [31:0] regbank [0:15];

	// Instantiate the Unit Under Test (UUT)
	spiifc uut (
		.Reset(Reset), 
    .SysClk(SysClk),
		.SPI_CLK(SPI_CLK), 
		.SPI_MISO(SPI_MISO), 
		.SPI_MOSI(SPI_MOSI), 
		.SPI_SS(SPI_SS), 
		.txMemAddr(txMemAddr), 
		.txMemData(txMemData), 
		.rcMemAddr(rcMemAddr), 
		.rcMemData(rcMemData), 
		.rcMemWE(rcMemWE),
    .regAddr(regAddr),
    .regReadData(regReadData_wreg),
    .regWriteData(regWriteData),
    .regWriteEn(regWE),
    .debug_out(debug_out)
	);

  task recvByte;
    input   [7:0] rcByte;
    integer       rcBitIndex;
    begin
      $display("%g - spiifc receiving byte '0x%h'", $time, rcByte);     
      for (rcBitIndex = 0; rcBitIndex < 8; rcBitIndex = rcBitIndex + 1) begin
        SPI_MOSI = rcByte[7 - rcBitIndex];
        #100;
      end
    end
  endtask

  always begin
    #20 SysClk = ~SysClk;
  end

  // Register bank
  always @(*) begin                 // Read reg
    regReadData_wreg <= regbank[regAddr];
  end
  always @(posedge SysClk) begin    // Write reg
    if (regWE) begin
      regbank[regAddr] <= regWriteData;
    end
  end

  reg SPI_CLK_en;
  initial begin
    #310
    SPI_CLK_en = 1;
  end
  always begin
    #10
    if (SPI_CLK_en) begin
      #40 SPI_CLK = ~SPI_CLK;
    end
  end

  integer fdRcBytes;
  integer fdTxBytes;
  integer dummy;
  integer currRcByte;
  integer rcBytesNotEmpty;
  reg [8*10:1] rcBytesStr;
  
	initial begin
		// Initialize Inputs
		Reset = 0;
    SysClk = 0;
    
		SPI_CLK = 0;
    SPI_CLK_en = 0;
		SPI_MOSI = 0;
		SPI_SS = 1;
		txMemData = 0;

		// Wait 100 ns for global reset to finish
		#100;
    Reset = 1;
    
    #100;
    Reset = 0;
    
    #100;
      
		// Add stimulus here
    SPI_SS = 0;
    // For each byte, transmit its bits
    fdRcBytes = $fopen("rc-bytes-writereg.txt", "r");
    rcBytesNotEmpty = 1;
    while (rcBytesNotEmpty) begin
      rcBytesNotEmpty = $fgets(rcBytesStr, fdRcBytes);
      if (rcBytesNotEmpty) begin
        dummy = $sscanf(rcBytesStr, "%x", currRcByte);
        recvByte(currRcByte);
      end
    end
    
    // Wrap it up.
    SPI_SS = 1;
    #1000;
    
    $finish;
	end
endmodule

