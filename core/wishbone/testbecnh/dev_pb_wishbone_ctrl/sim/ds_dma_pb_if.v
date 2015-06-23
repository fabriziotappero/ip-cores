//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     ds_dma_pb_if
// Project Name:    DS_DMA
// Target Devices:  no
// Tool versions:   any with SV support
// Description: 
//
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////

interface ds_dma_pb_if # ( parameter time pt_Tclk = 10ns, parameter time pt_Tdly = 1ns )
(
    input   i_clk
);
//////////////////////////////////////////////////////////////////////////////////
    //
    // B_MASTER (OUT dir) IF
    logic               o_pb_master_stb0;   // CMD STB
    logic               o_pb_master_stb1;   // DATA STB
    logic       [ 2:0]  ov_pb_master_cmd;   // CMD
    logic       [31:0]  ov_pb_master_addr;  // ADDR
    logic       [63:0]  ov_pb_master_data;  // DATA
    //
    // PB_SLAVE (IN dir) IF:
    logic               i_pb_slave_ready;
    logic               i_pb_slave_complete;
    logic               i_pb_slave_stb0;    // WR CMD ACK STB 
    logic               i_pb_slave_stb1;    // DATA ACK STB   
    logic       [63:0]  iv_pb_slave_data;   // DATA           
    logic       [ 1:0]  iv_pb_slave_dmar;   // ...
    logic               i_pb_slave_irq;     // ...
    
//////////////////////////////////////////////////////////////////////////////////
//
// Define Clocking block:
//
default clocking cb @(posedge i_clk);
    default input #(pt_Tdly) output #(pt_Tdly);
    output o_pb_master_stb0, o_pb_master_stb1, ov_pb_master_cmd, ov_pb_master_addr, ov_pb_master_data;
    input i_pb_slave_ready, i_pb_slave_complete, i_pb_slave_stb0, i_pb_slave_stb1, iv_pb_slave_data, iv_pb_slave_dmar, i_pb_slave_irq;
endclocking
//////////////////////////////////////////////////////////////////////////////////
//
// Tasks:
//
// Init DATA_OUT
task    init;
    //
    o_pb_master_stb0    <= 0;
    o_pb_master_stb1    <= 0;
    ov_pb_master_cmd    <= 0;
    ov_pb_master_addr   <= 0;
    ov_pb_master_data   <= 0;
    //
endtask
//
task write_1_word (input [31:0] iv_addr=0, input [63:0] iv_data=0);
    //
    @cb;
    cb.o_pb_master_stb0     <= 1;
    cb.o_pb_master_stb1     <= 0;
    cb.ov_pb_master_addr    <= iv_addr;
    cb.ov_pb_master_cmd     <= 3'b0_0_1;
    @cb;
    cb.o_pb_master_stb0     <= 0;
    cb.o_pb_master_stb1     <= 1;
    cb.ov_pb_master_data    <= iv_data;
    cb.ov_pb_master_cmd     <= 3'b0_0_1;
    do 
        begin   :   PB_SLAVE_STB_0
            ##1;
            cb.o_pb_master_stb0     <= 0;
            cb.o_pb_master_stb1     <= 0;
            cb.ov_pb_master_data    <= 0;
            cb.ov_pb_master_cmd     <= 3'b0;
        end 
    while (cb.i_pb_slave_complete==0);
    //
endtask
// 
task write_512_word (input [31:0] iv_addr=0, input [63:0] iv_start_data=0, input i_rnd=0);
    //
    int i=0, rdy_counter=0;
    //
    @cb;
    cb.o_pb_master_stb0     <= 1;
    cb.o_pb_master_stb1     <= 0;
    cb.ov_pb_master_addr    <= iv_addr;
    cb.ov_pb_master_cmd     <= 3'b1_0_1;
    @cb;
    cb.o_pb_master_stb0     <= 0;
    cb.o_pb_master_stb1     <= 0;
    cb.ov_pb_master_cmd     <= 3'b1_0_1;
    @cb;
    //
    do 
        begin   :   DATA
            @cb;
            if (cb.i_pb_slave_ready==0)
                rdy_counter++;
            else
                rdy_counter=0;
            if (rdy_counter < 4)
                begin   :   DATA_OUT
                    cb.o_pb_master_stb1     <= 1;
                    cb.ov_pb_master_data    <= (i_rnd)? $urandom()/*$urandom_range()*/ : (iv_start_data+i);
                    i++;
                end
            else
                begin   :   DATA_HALT
                    cb.o_pb_master_stb1     <= 0;
                    cb.ov_pb_master_data    <= 0;
                end
        end
    while (i<512+1);
    
    cb.o_pb_master_stb0     <= 0;
    cb.o_pb_master_stb1     <= 0;
    //
endtask
//
task read_1_word(input [31:0] iv_addr, output logic [63:0] ov_data);
    //
    //
    @cb;
    cb.o_pb_master_stb0     <= 1;
    cb.o_pb_master_stb1     <= 0;
    cb.ov_pb_master_addr    <= iv_addr;
    cb.ov_pb_master_cmd     <= 3'b0_1_0;
    @cb;
    cb.o_pb_master_stb0     <= 0;
    cb.o_pb_master_stb1     <= 1;
    cb.ov_pb_master_cmd     <= 3'b0_1_0;
    //
    do 
        begin   :   PB_SLAVE_STB_0
            @cb;
            cb.o_pb_master_stb0     <= 0;
            cb.o_pb_master_stb1     <= 0;
            cb.ov_pb_master_cmd     <= 0;
        end
    while (cb.i_pb_slave_stb0==0);
    //
    do 
        begin   :   PB_SLAVE_STB_1
            @cb;
            if (cb.i_pb_slave_stb1)
                ov_data = cb.iv_pb_slave_data;
        end
    while (cb.i_pb_slave_complete==0);
    //
endtask
//
task read_512_word (input [31:0] iv_addr, output [63:0] ov_data [512]);
    //
    int i=0;
    //
    @cb;
    cb.o_pb_master_stb0     <= 1;
    cb.o_pb_master_stb1     <= 0;
    cb.ov_pb_master_addr    <= iv_addr;
    cb.ov_pb_master_cmd     <= 3'b1_1_0;
    @cb;
    cb.o_pb_master_stb0     <= 0;
    cb.o_pb_master_stb1     <= 0;
    cb.ov_pb_master_cmd     <= 3'b1_1_0;
    // 
    do
        begin   :   GET_DATA
            @cb;
            if (cb.i_pb_slave_stb1)
                begin
                    ov_data[i] <= cb.iv_pb_slave_data;
                    i++;
                end
        end
    while (cb.i_pb_slave_complete==0);
    // CLR on EXIT
    cb.o_pb_master_stb0     <= 0;
    cb.o_pb_master_stb1     <= 0;
    cb.ov_pb_master_cmd     <= 0;
    // 
endtask
//////////////////////////////////////////////////////////////////////////////////
//
// Functions:
//
// for polling "iv_pb_slave_dmar"
function automatic bit [1:0] get_pb_slave_dmar;
    return cb.iv_pb_slave_dmar;
endfunction
// for polling "i_pb_slave_irq"
function automatic bit get_pb_slave_irq;
    return cb.i_pb_slave_irq;
endfunction
//////////////////////////////////////////////////////////////////////////////////
endinterface
