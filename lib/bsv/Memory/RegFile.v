module RegFile
(
    CLK,
    RST_N,
    CLK_GATE,
    readReady,
    readAddr,
    readData,
    writeReady,
    writeEnable,
    writeAddr,
    writeData,
    writeEmptyReady,
    writeEmpty
);
    parameter dataSize = 32;
    parameter addrSize = 5;
    parameter numRows = 32;
    parameter resetVal = 0;

    input CLK, RST_N, CLK_GATE;
    output readReady;
    input  [addrSize-1:0] readAddr;
    output [dataSize-1:0] readData;
    output writeReady;
    input  writeEnable;
    input  [addrSize-1:0] writeAddr;
    input  [dataSize-1:0] writeData;
    output writeEmptyReady;
    output writeEmpty;

    reg [dataSize-1:0] ram [numRows-1:0];

    assign readReady = 1;
    assign writeReady = 1;
    assign writeEmptyReady = 1;
    assign writeEmpty = 1;

    always@(posedge CLK)
    begin
        if(writeEnable)
            ram[writeAddr] <= writeData;
    end

    assign readData = ram[readAddr];
endmodule
