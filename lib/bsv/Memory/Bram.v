module Bram
(
    CLK,
    RST_N,
    CLK_GATE,
    readEnable,
    readAddr,
    readReady,
    readReqEmpty,
    readReqEmptyReady,
    readData,
    readDataEnable,
    readDataReady,
    readRespEmpty,
    readRespEmptyReady,
    writeEnable,
    writeAddr,
    writeData,
    writeReady,
    writeEmpty,
    writeEmptyReady
);
    parameter dataSize = 32;
    parameter addrSize = 9;
    parameter numRows = 512;
    parameter resetVal = 0;

    input CLK, RST_N, CLK_GATE;
    input  readEnable;
    input  [addrSize-1:0] readAddr;
    output readReady;
    output readReqEmpty;
    output readReqEmptyReady;
    output [dataSize-1:0] readData;
    input  readDataEnable;
    output readDataReady;
    output readRespEmpty;
    output readRespEmptyReady;
    input  writeEnable;
    input  [addrSize-1:0] writeAddr;
    input  [dataSize-1:0] writeData;
    output writeReady;
    output writeEmpty;
    output writeEmptyReady;

    reg [dataSize-1:0] readData;

    reg [dataSize-1:0] ram [numRows-1:0];

    assign readReady = 1;
    assign readDataReady = 1;
    assign writeReady = 1;

    assign readReqEmpty = 1;
    assign readReqEmptyReady = 1;
    assign readRespEmpty = 1;
    assign readRespEmptyReady = 1;
    assign writeEmpty = 1;
    assign writeEmptyReady = 1;

    always@(posedge CLK)
    begin
        if(!RST_N)
        begin: reset
            // synthesis translate_off
            integer i;
            for(i = 0; i < numRows; i=i+1)
                ram[i] <= resetVal;
            // synthesis translate_on
            readData <= resetVal;
        end
        else
            readData <= ram[readAddr];
    end

    always@(posedge CLK)
    begin
        if(writeEnable)
            ram[writeAddr] <= writeData;
    end
endmodule
