//`include "versatile_mem_ctrl_defines.v"
`ifdef SDR
`timescale 1ns/1ns
`define MODULE sdr16
module `BASE`MODULE (
`undef MODULE
    // wisbone i/f
`ifdef SDR_NO_BURST
    dat_i, adr_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o,
`else
    dat_i, adr_i, sel_i, bte_i, we_i, cyc_i, stb_i, dat_o, ack_o,
`endif
    // SDR SDRAM
    ba, a, cmd, cke, cs_n, dqm, dq_i, dq_o, dq_oe,
    // system
    clk, rst);

    // external data bus size
    parameter dat_size = `SDR_SDRAM_DATA_WIDTH;
    
    // memory geometry parameters
    parameter ba_size  = `SDR_BA_SIZE;   
    parameter row_size = `SDR_ROW_SIZE;
    parameter col_size = `SDR_COL_SIZE;
    parameter cl = `SDR_INIT_CL;
    // memory timing parameters
    parameter tRFC = `SDR_TRFC;
    parameter tRP  = `SDR_TRP;
    parameter tRCD = `SDR_TRCD;
    parameter tMRD = `SDR_TMRD;
   
    // LMR
    // [12:10] reserved
    // [9]     WB, write burst; 0 - programmed burst length, 1 - single location
    // [8:7]   OP Mode, 2'b00
    // [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
    // [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
    // [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
    parameter init_wb = `SDR_INIT_WB;
    parameter init_cl = `SDR_INIT_CL;
    parameter init_bt = `SDR_INIT_BT;
    parameter init_bl = `SDR_INIT_BL;
	
    input [31:0] dat_i;
    input [ba_size+col_size+row_size:1] adr_i;
    input [3:0] sel_i;
`ifndef SDR_NO_BURST
    input [1:0] bte_i;
`endif
    input we_i, cyc_i, stb_i;
    output [31:0] dat_o;
    output ack_o;

    output [ba_size-1:0]    ba;
    output reg [12:0]   a;
    output reg [2:0]    cmd; // {ras,cas,we}
    output cke, cs_n;
    output reg [1:0]    dqm;
    output [dat_size-1:0]       dq_o;
    output reg          dq_oe;
    input  [dat_size-1:0]       dq_i;

    input clk, rst;

    wire [ba_size-1:0] 	bank;
    wire [row_size-1:0] row;
    wire [col_size-1:0] col;
    wire [12:0]         col_a10_fix;
`ifdef SDR_BEAT16
    parameter col_reg_width = 5;
    reg [4:0]		col_reg;
`else
`ifdef SDR_BEAT8
    parameter col_reg_width = 4;
    reg [3:0]		col_reg;
`else
`ifdef SDR_BEAT4
    parameter col_reg_width = 3;
    reg [2:0]		col_reg;
`endif
`endif
`endif
    wire [0:31] 	shreg; 
    wire		count0;
    wire 		stall; // active if write burst need data
    wire 		ref_cnt_zero;
    reg                 refresh_req; 

    wire ack_rd, rd_ack_emptyflag;
    wire ack_wr;

    // to keep track of open rows per bank
    reg [row_size-1:0] 	open_row[0:3];
    reg [0:3] 		open_ba;
    reg 		current_bank_closed, current_row_open;  

`ifndef SDR_RFR_WRAP_VALUE
    parameter rfr_length = 10;
    parameter rfr_wrap_value = 1010;
`else
    parameter rfr_length = `SDR_RFR_LENGTH;
    parameter rfr_wrap_value = `SDR_RFR_WRAP_VALUE;	
`endif

    // cti
    parameter [2:0] classic = 3'b000,
                    endofburst = 3'b111;

    // bte	
    parameter [1:0] linear = 2'b00,
                    beat4  = 2'b01,
                    beat8  = 2'b10,
                    beat16 = 2'b11;

    parameter [2:0] cmd_nop = 3'b111,
                    cmd_act = 3'b011,
                    cmd_rd  = 3'b101,
                    cmd_wr  = 3'b100,
                    cmd_pch = 3'b010,
                    cmd_rfr = 3'b001,
                    cmd_lmr = 3'b000;

// ctrl FSM
`define FSM_INIT 3'b000
`define FSM_IDLE 3'b001
`define FSM_RFR  3'b010
`define FSM_ADR  3'b011
`define FSM_PCH  3'b100
`define FSM_ACT  3'b101
`define FSM_RW   3'b111

    assign cke = 1'b1;
    assign cs_n = 1'b0;
	   
    reg [2:0] state, next;

    function [12:0] a10_fix;
        input [col_size-1:0] a;
        integer i;
    begin
	for (i=0;i<13;i=i+1) begin
            if (i<10)
              if (i<col_size)
                a10_fix[i] = a[i];
              else
                a10_fix[i] = 1'b0;
            else if (i==10)
              a10_fix[i] = 1'b0;
            else
              if (i<col_size)
                a10_fix[i] = a[i-1];
              else
                a10_fix[i] = 1'b0;
	end
    end
    endfunction

    assign {bank,row,col} = adr_i;

    always @ (posedge clk or posedge rst)
    if (rst)
       state <= `FSM_INIT;
    else
       state <= next;
   
    always @*
    begin
	next = state;
	case (state)
	`FSM_INIT:
            if (shreg[3+tRP+tRFC+tRFC+tMRD]) next = `FSM_IDLE;
        `FSM_IDLE:   
	    if (refresh_req) next = `FSM_RFR;
            else if (cyc_i & stb_i & rd_ack_emptyflag) next = `FSM_ADR;
        `FSM_RFR: 
            if (shreg[tRP+tRFC-2]) next = `FSM_IDLE; // take away two cycles because no cmd will be issued in idle and adr
	`FSM_ADR:
            if (current_bank_closed) next = `FSM_ACT;
	    else if (current_row_open) next = `FSM_RW;
	    else next = `FSM_PCH;
	`FSM_PCH: 
            if (shreg[tRP]) next = `FSM_ACT;
	`FSM_ACT:
            if (shreg[tRCD]) next = `FSM_RW;
	`FSM_RW:
`ifdef SDR_NO_BURST
            if (shreg[1]) next = `FSM_IDLE;
`else
            if (bte_i==linear & shreg[1]) next = `FSM_IDLE;
`ifdef SDR_BEAT4
            else if (bte_i==beat4 & shreg[7]) next = `FSM_IDLE;
`endif
`ifdef SDR_BEAT8
            else if (bte_i==beat8 & shreg[15]) next = `FSM_IDLE;
`endif
`ifdef SDR_BEAT16
            else if (bte_i==beat16 & shreg[31]) next = `FSM_IDLE;
`endif
`endif
	endcase
    end

    // active if write burst need data
    assign stall = state==`FSM_RW & next==`FSM_RW & ~stb_i & count0 & we_i;
   
    // counter
`define MODULE cnt_shreg_ce_clear 
    `VLBASE`MODULE # ( .length(32))
`undef MODULE
        cnt0 (
            .cke(!stall),
            .clear(state!=next),
            .q(shreg),
            .rst(rst),
            .clk(clk));

`define MODULE dff_ce_clear
    `VLBASE`MODULE
`undef MODULE
        dff_count0 (
            .d(!count0),
            .ce(!stall),
            .clear(state!=next),
            .q(count0),
            .rst(rst),
            .clk(clk));

    // ba, a, cmd
    // col_reg_a10 has bit [10] set to zero to disable auto precharge
`ifdef SDR_NO_BURST
    assign col_a10_fix = a10_fix(col);
`else
    assign col_a10_fix = a10_fix({col[col_size-1:col_reg_width],col_reg});
`endif

    // outputs dependent on state vector
    always @ (*)
        begin
   	    {a,cmd} = {13'd0,cmd_nop};
            dqm = 2'b11;
            dq_oe = 1'b0;
            case (state)
            `FSM_INIT:
                if (shreg[3]) begin
                    {a,cmd} = {13'b0010000000000, cmd_pch};
                end else if (shreg[3+tRP] | shreg[3+tRP+tRFC])
                    {a,cmd} = {13'd0, cmd_rfr};
                else if (shreg[3+tRP+tRFC+tRFC])
                    {a,cmd} = {3'b000,init_wb,2'b00,init_cl,init_bt,init_bl,cmd_lmr};
            `FSM_RFR:
        	if (shreg[0])
                    {a,cmd} = {13'b0010000000000, cmd_pch};
        	else if (shreg[tRP])
                    {a,cmd} = {13'd0, cmd_rfr};
	    `FSM_PCH:
        	if (shreg[0])
                    {a,cmd} = {13'd0,cmd_pch};
            `FSM_ACT:
                if (shreg[0])
                    {a[row_size-1:0],cmd} = {row,cmd_act};
            `FSM_RW:
                begin
                    if (we_i & !count0)
                        cmd = cmd_wr;
                    else if (!count0)
                        cmd = cmd_rd;
                    else
                        cmd = cmd_nop;
                    if (we_i & !count0)
                        dqm = ~sel_i[3:2];
                    else if (we_i & count0)
                        dqm = ~sel_i[1:0];
                    else
                        dqm = 2'b00;
                    if (we_i)
                        dq_oe = 1'b1;
                    if (~stall)
                        a = col_a10_fix;
                end
            endcase
        end

    assign ba = bank;
    
    // precharge individual bank A10=0
    // precharge all bank A10=1
    genvar i;
    generate
    for (i=0;i<2<<ba_size-1;i=i+1) begin
    
        always @ (posedge clk or posedge rst)
        if (rst)
            {open_ba[i],open_row[i]} <= {1'b0,{row_size{1'b0}}};
        else
            if (cmd==cmd_pch & (a[10] | bank==i))
                open_ba[i] <= 1'b0;
            else if (cmd==cmd_act & bank==i)
                {open_ba[i],open_row[i]} <= {1'b1,row};

    end
    endgenerate

`ifndef SDR_NO_BURST    
    always @ (posedge clk or posedge rst)
	if (rst)
           col_reg <= {col_reg_width{1'b0}};
        else
            case (state)
	    `FSM_IDLE:
	       col_reg <= col[col_reg_width-1:0];
            `FSM_RW:
               if (~stall)
                  case (bte_i)
`ifdef SDR_BEAT4
                        beat4:  col_reg[2:0] <= col_reg[2:0] + 3'd1;
`endif
`ifdef SDR_BEAT8    
                        beat8:  col_reg[3:0] <= col_reg[3:0] + 4'd1;
`endif
`ifdef SDR_BEAT16   
                        beat16: col_reg[4:0] <= col_reg[4:0] + 5'd1;
`endif
                  endcase
            endcase
`endif

    // bank and row open ?
    always @ (posedge clk or posedge rst)
    if (rst)
       {current_bank_closed, current_row_open} <= {1'b1, 1'b0};
    else
       {current_bank_closed, current_row_open} <= {!(open_ba[bank]), open_row[bank]==row};

    // refresh counter
`define MODULE cnt_lfsr_zq  
    `VLBASE`MODULE # ( .length(rfr_length), .wrap_value (rfr_wrap_value)) ref_counter0( .zq(ref_cnt_zero), .rst(rst), .clk(clk));
`undef MODULE

    always @ (posedge clk or posedge rst)
    if (rst)
    	refresh_req <= 1'b0;
    else
    	if (ref_cnt_zero)
            refresh_req <= 1'b1;
       	else if (state==`FSM_RFR)
            refresh_req <= 1'b0;

    assign dat_o[15:0] = dq_i;
`define MODULE dff    
    `VLBASE`MODULE # ( .width(16)) wb_dat_dff ( .d(dat_o[15:0]), .q(dat_o[31:16]), .clk(clk), .rst(rst));
`undef MODULE

    assign ack_wr = (state==`FSM_RW & count0 & we_i);

`define MODULE delay_emptyflag  
    `VLBASE`MODULE # ( .depth(cl+2)) delay0 ( .d(state==`FSM_RW & count0 & !we_i), .q(ack_rd), .emptyflag(rd_ack_emptyflag), .clk(clk), .rst(rst));
`undef MODULE

    assign ack_o = ack_rd | ack_wr;

    assign dq_o = (!count0) ? dat_i[31:16] : dat_i[15:0];

endmodule
`endif