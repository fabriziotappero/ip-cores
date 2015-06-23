/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module model_fifo(
    input                       clk,
    input                       rst_n,
    input                       sclr,
    
    input                       rdreq,
    input                       wrreq,
    input       [width-1:0]     data,
    
    output                      empty,
    output reg                  full,
    output      [width-1:0]     q,
    output reg  [widthu-1:0]    usedw
);

parameter width     = 2;
parameter widthu    = 2;

reg [width-1:0] mem [(2**widthu)-1:0];

reg [widthu-1:0] rd_index = 0;
reg [widthu-1:0] wr_index = 0;

assign q    = mem[rd_index];
assign empty= usedw == 0 && ~(full);

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rd_index <= 0;
    else if(sclr)               rd_index <= 0;
    else if(rdreq && ~(empty))  rd_index <= rd_index + { {widthu-1{1'b0}}, 1'b1 };
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       wr_index <= 0;
    else if(sclr)                           wr_index <= 0;
    else if(wrreq && (~(full) || rdreq))    wr_index <= wr_index + { {widthu-1{1'b0}}, 1'b1 };
end

always @(posedge clk) begin
    if(wrreq && (~(full) || rdreq)) mem[wr_index] <= data;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               full <= 1'b0;
    else if(sclr)                                                   full <= 1'b0;
    else if(rdreq && ~(wrreq) && full)                              full <= 1'b0;
    else if(~(rdreq) && wrreq && ~(full) && usedw == (2**widthu)-1) full <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       usedw <= 0;
    else if(sclr)                           usedw <= 0;
    else if(rdreq && ~(wrreq) && ~(empty))  usedw <= usedw - { {widthu-1{1'b0}}, 1'b1 };
    else if(~(rdreq) && wrreq && ~(full))   usedw <= usedw + { {widthu-1{1'b0}}, 1'b1 };
    else if(rdreq && wrreq && empty)        usedw <= { {widthu-1{1'b0}}, 1'b1 };
end

endmodule
