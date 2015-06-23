/*
    Clock Domain Crossing micro FIFO
    Copyright (C) 2010  Alexandr Litjagin (aka AlexRayne) AlexRaynePE196@lavabit.com
                                                          AlexRaynePE196@hotbox.ru

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/*
    cdc_ufifo generate an minimalist fifo. it can be 4 cells minimum.
    by default used implementation without ram only standart cells used
    , and it can be selected if need. most slowest stage is the output multiplexor.
    shadowed outputs - provide an registes after multiplexer to remove data unsynchronized 
    changes from outputs when skiped some cycles.

    parameters:
        shadowed - "FALSE|TRUE" is buffered output or not
        realization - "RAM|REGS" - style of buffer implemented
            ="RAM" - default implementation of ram
            ="REGS" (default) - force use registers set for buffer
*/
module cdc_ufifo( d, in_clk, denable, reset
                    , q, q_clk, qenable, ready
                    );

parameter lpm_width = 8;
parameter lpm_depth = 2;
parameter shadowed = "FALSE";
parameter realization = "REGS";

`include "StdUtils.vh"

`define lpm_size (lpm_depth*2)
`define ptr_size clog2(`lpm_size)

input in_clk, denable, q_clk, qenable, reset;
input [lpm_width-1:0] d;
output logic [lpm_width-1:0] q;
output ready;

typedef logic [lpm_width-1:0] data_wire;
typedef logic [`ptr_size-1:0] buf_ptr;

data_wire bufer[0:`lpm_size-1];
buf_ptr rd_node_ptr;
buf_ptr rd_next_ptr;
buf_ptr wr_node_ptr;
buf_ptr wr_next_ptr;

buf_ptr rd_node_grey;
buf_ptr rd_next_grey;
buf_ptr wr_node_grey;
buf_ptr wr_next_grey;

assign rd_node_ptr = rd_node_grey;
assign rd_next_ptr = rd_next_grey;
assign wr_node_ptr = wr_node_grey;
assign wr_next_ptr = wr_next_grey;

logic wr_enable;
logic rd_enable;

graycntr WrSwitch(.clk(in_clk), .inc(wr_enable), .rst_n(~reset), .gray(wr_node_grey), .gnext(wr_next_grey));
    defparam WrSwitch.lpm_width = `ptr_size;
graycntr RdSwitch(.clk(q_clk), .inc(rd_enable), .rst_n(~reset), .gray(rd_node_grey), .gnext(rd_next_grey));
    defparam RdSwitch.lpm_width = `ptr_size;

buf_ptr rd_cdc_grey;
buf_ptr wr_cdc_grey;

delay_pulse_ff cdc_stamp_wr(.clock(q_clk), .d(wr_node_grey), .q(wr_cdc_grey), .enable(1'b1), .clrn(~reset));
    defparam cdc_stamp_wr.delay = 1;//lpm_depth;
    defparam cdc_stamp_wr.lpm_width = $bits(wr_node_grey);

delay_pulse_ff cdc_stamp_rd(.clock(in_clk), .d(rd_node_grey), .q(rd_cdc_grey), .enable(1'b1), .clrn(~reset));
    defparam cdc_stamp_rd.delay = 1;//(lpm_depth /2);
    defparam cdc_stamp_rd.lpm_width = $bits(rd_node_grey);


logic data_avail;
logic data_free;
assign data_avail = (wr_cdc_grey != rd_node_grey);
assign data_free = (rd_cdc_grey != wr_next_grey);
assign wr_enable = denable & data_free;
assign rd_enable = data_avail;

wire [lpm_width-1:0] selQ;

genvar i;
generate
    if (realization == "REGS") 
    for (i = 0; i < `lpm_size; i++) begin : buffer_node
        wire WrCellSel = (wr_node_ptr == i);
        prim_dffe buf_data( .clk(in_clk), .d(d), .ena( wr_enable & WrCellSel ), .q( bufer[i] ), .clrn(~reset), .prn(1'b1) );
            defparam buf_data.lpm_width = lpm_width;
        assign selQ = (rd_node_ptr == i)? bufer[i] : {lpm_width{1'bz}};
    end
    else begin
        always @(posedge in_clk) begin : bufer_latch
            if (wr_enable)
                bufer[wr_node_ptr] <= d;
        end

        assign selQ = bufer[rd_node_ptr];
    end
endgenerate


assign ready = rd_enable;

generate if (shadowed == "TRUE") begin
        always @(posedge q_clk) if (rd_enable) q <= selQ;
    end
    else
        assign q = selQ;
endgenerate


endmodule
