//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     ds_dma_test_check_burst_master_if
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

interface ds_dma_test_check_burst_master_if # ( parameter time pt_Tdly = 1ns )
(
    input   i_clk
);
//////////////////////////////////////////////////////////////////////////////////
    //
    // WB IF
    logic   [11:0]  ov_wbs_burst_addr;
    logic   [63:0]  ov_wbs_burst_data;
    logic   [ 7:0]  ov_wbs_burst_sel;
    logic           o_wbs_burst_we;
    logic           o_wbs_burst_cyc;
    logic           o_wbs_burst_stb;
    logic   [ 2:0]  ov_wbs_burst_cti;
    logic   [ 1:0]  ov_wbs_burst_bte;
    
    logic           i_wbs_burst_ack;
    logic           i_wbs_burst_err;
    logic           i_wbs_burst_rty;
    
//////////////////////////////////////////////////////////////////////////////////
//
// Define Clocking block:
//
default clocking cb @(posedge i_clk);
    default input #(pt_Tdly) output #(pt_Tdly);
    output ov_wbs_burst_addr, ov_wbs_burst_data, ov_wbs_burst_sel, o_wbs_burst_we, o_wbs_burst_cyc, o_wbs_burst_stb, ov_wbs_burst_cti, ov_wbs_burst_bte;
    input i_wbs_burst_ack, i_wbs_burst_err, i_wbs_burst_rty;
endclocking
//////////////////////////////////////////////////////////////////////////////////
//
// Tasks:
//
// Init DATA_OUT
task    init;
    //
    ov_wbs_burst_addr   <= 0;
    ov_wbs_burst_data   <= 0;
    ov_wbs_burst_sel    <= 0;
    o_wbs_burst_we      <= 0;
    o_wbs_burst_cyc     <= 0;
    o_wbs_burst_stb     <= 0;
    ov_wbs_burst_cti    <= 0;
    ov_wbs_burst_bte    <= 0;
    //
endtask
//
task write_512_word (input [63:0] iv_start_data=0, input i_rnd=0);
    //
    int i=0, stb_counter=0;
    //
    @cb;
    cb.ov_wbs_burst_addr    <= 0;
    cb.ov_wbs_burst_sel     <= 0;
    cb.o_wbs_burst_we       <= 0; // CLR
    cb.o_wbs_burst_cyc      <= 0;
    cb.o_wbs_burst_stb      <= 0;
    cb.ov_wbs_burst_cti     <= 0;
    ov_wbs_burst_bte        <= 0;
    ov_wbs_burst_data       <= 0;
    @cb;
    cb.ov_wbs_burst_sel     <= '1;
    cb.o_wbs_burst_we       <= 1; // WR
    cb.o_wbs_burst_cyc      <= 1;
    cb.o_wbs_burst_stb      <= 1;
    cb.ov_wbs_burst_cti     <= 3'b001;
    ov_wbs_burst_bte        <= 2'b01;
    //
    i=0;
    stb_counter=0;
    cb.ov_wbs_burst_data    <= (i_rnd)? $urandom() : (iv_start_data+i);
    // 
    do
        begin   :   WR_DATA
            
            @cb;
            if (cb.i_wbs_burst_ack)
                begin   :   DATA_PUT
                    // 
                    cb.ov_wbs_burst_data    <= (i_rnd)? $urandom() : (iv_start_data+i+1);
                    i++;
                    // 
                    if (i==511) // EndOfBurst
                        cb.ov_wbs_burst_cti     <= 3'b111;
                end
            /**/
            if (stb_counter==15) // ==> Master DELAY in Transfer POINT
                begin   :   MASTER_DLY
                    cb.o_wbs_burst_stb      <= 0;
                    @cb;
                    @cb;
                    cb.o_wbs_burst_stb      <= 1;
                end
            stb_counter++;/**/
        end
    while (i<512/*+1*/);
    // CLR on EXIT
    cb.ov_wbs_burst_sel     <= 0;
    cb.o_wbs_burst_we       <= 0; // CLR
    cb.o_wbs_burst_cyc      <= 0;
    cb.o_wbs_burst_stb      <= 0;
    cb.ov_wbs_burst_cti     <= 0;
    ov_wbs_burst_bte        <= 0;
    ov_wbs_burst_data       <= 0;
    // 
endtask
//////////////////////////////////////////////////////////////////////////////////
//
// Functions:
//

//////////////////////////////////////////////////////////////////////////////////
endinterface
