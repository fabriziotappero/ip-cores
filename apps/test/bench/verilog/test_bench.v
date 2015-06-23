`include "timescale.v"
`include "pci_testbench_defines.v"

`define TIME $display("Time %t", $time) 
`define ERROR(TEXT) $display("*E, %s", TEXT)
`define INVALID_DATA(FROM) $display("*E, Data read from %s not as expected!", FROM)
`define VALUES(EXPECTED,ACTUAL) $display("Expected %h, Actual %h", EXPECTED, ACTUAL)

module test_bench
(
);


reg clk,
    rst ;

assign glbl.GSR = rst ;
         
wire wbm_cyc_o,
     wbm_stb_o,
     wbm_cab_o,
     wbm_we_o ;

wire [31:0] wbm_adr_o ;
wire [3:0]  wbm_sel_o ;

wire [31:0] wbm_dat_o,
            wbm_dat_i ;

wire wbm_ack_i,
     wbm_rty_i,
     wbm_err_i ;
         
wire wbs_cyc_i,
     wbs_stb_i,
     wbs_cab_i,
     wbs_we_i ;

wire [31:0] wbs_adr_i ;
wire [3:0]  wbs_sel_i ;

wire [31:0] wbs_dat_i,
            wbs_dat_o ;

wire wbs_ack_o,
     wbs_rty_o,
     wbs_err_o ;

reg pci_clk,
    pci_irdy_reg,
    pci_irdy_en_reg,
    pci_trdy_reg ;

reg [31:0] pci_ad_reg ;

test i_test
(
    .clk_i      (clk),
    .rst_i      (rst),
    
    .pci_clk_i  (pci_clk),
           
    .wbm_cyc_o  (wbm_cyc_o),
    .wbm_stb_o  (wbm_stb_o),
    .wbm_cab_o  (wbm_cab_o),
    .wbm_we_o   (wbm_we_o ),
    .wbm_adr_o  (wbm_adr_o),
    .wbm_sel_o  (wbm_sel_o),
    .wbm_dat_o  (wbm_dat_o),
    .wbm_dat_i  (wbm_dat_i),
    .wbm_ack_i  (wbm_ack_i),
    .wbm_rty_i  (wbm_rty_i),
    .wbm_err_i  (wbm_err_i),
           
    .wbs_cyc_i  (wbs_cyc_i),
    .wbs_stb_i  (wbs_stb_i),
    .wbs_cab_i  (wbs_cab_i),
    .wbs_we_i   (wbs_we_i ),
    .wbs_adr_i  (wbs_adr_i),
    .wbs_sel_i  (wbs_sel_i),
    .wbs_dat_i  (wbs_dat_i),
    .wbs_dat_o  (wbs_dat_o),
    .wbs_ack_o  (wbs_ack_o),
    .wbs_rty_o  (wbs_rty_o),
    .wbs_err_o  (wbs_err_o),
    
    .pci_irdy_reg_i    (pci_irdy_reg),
    .pci_irdy_en_reg_i (pci_irdy_en_reg),
    .pci_trdy_reg_i    (pci_trdy_reg),
    .pci_ad_reg_i      (pci_ad_reg)
);

WB_MASTER_BEHAVIORAL wishbone_master
(
    .CLK_I(clk),
    .RST_I(rst),
    .TAG_I(`WB_TAG_WIDTH'h0),
    .TAG_O(),
    .ACK_I(wbs_ack_o),
    .ADR_O(wbs_adr_i),
    .CYC_O(wbs_cyc_i),
    .DAT_I(wbs_dat_o),
    .DAT_O(wbs_dat_i),
    .ERR_I(1'b0),
    .RTY_I(1'b0),
    .SEL_O(wbs_sel_i),
    .STB_O(wbs_stb_i),
    .WE_O (wbs_we_i),
    .CAB_O(wbs_cab_i)
);

WB_SLAVE_BEHAVIORAL wishbone_slave
(
    .CLK_I              (clk),
    .RST_I              (rst),
    .ACK_O              (wbm_ack_i),
    .ADR_I              (wbm_adr_o),
    .CYC_I              (wbm_cyc_o),
    .DAT_O              (wbm_dat_i),
    .DAT_I              (wbm_dat_o),
    .ERR_O              (),
    .RTY_O              (),
    .SEL_I              (wbm_sel_o),
    .STB_I              (wbm_stb_o),
    .WE_I               (wbm_we_o),
    .CAB_I              (wbm_cab_o)
);

integer wbs_mon_log_file_desc, wbm_mon_log_file_desc ;

WB_BUS_MON wbs_wb_mon(
                    .CLK_I(clk),
                    .RST_I(rst),
                    .ACK_I(wbs_ack_o),
                    .ADDR_O(wbs_adr_i),
                    .CYC_O(wbs_cyc_i),
                    .DAT_I(wbs_dat_o),
                    .DAT_O(wbs_dat_i),
                    .ERR_I(1'b0),
                    .RTY_I(1'b0),
                    .SEL_O(wbs_sel_i),
                    .STB_O(wbs_stb_i),
                    .WE_O (wbs_we_i),
                    .TAG_I( `WB_TAG_WIDTH'h0 ),
                    .TAG_O(),
                    .CAB_O(wbs_cab_i),
                    .log_file_desc ( wbs_mon_log_file_desc )
                  ) ;

WB_BUS_MON wbm_wb_mon(
                    .CLK_I(clk),
                    .RST_I(rst),
                    .ACK_I(wbm_ack_i),
                    .ADDR_O(wbm_adr_o),
                    .CYC_O(wbm_cyc_o),
                    .DAT_I(wbm_dat_i),
                    .DAT_O(wbm_dat_o),
                    .ERR_I(1'b0),
                    .RTY_I(1'b0),
                    .SEL_O(wbm_sel_o),
                    .STB_O(wbm_stb_o),
                    .WE_O (wbm_we_o),
                    .TAG_I( `WB_TAG_WIDTH'h0 ),
                    .TAG_O(),
                    .CAB_O(wbm_cab_o),
                    .log_file_desc ( wbm_mon_log_file_desc )
                  ) ;


// clock generation
always
    #(10) clk = ~clk ;

always
    #15 pci_clk = ~pci_clk ;

integer wb_master_waits ;
initial
begin
    wbs_mon_log_file_desc = $fopen("../log/wbs_mon.log") ;
    wbm_mon_log_file_desc = $fopen("../log/wbm_mon.log") ;
    clk = 1'b1 ;
    rst = 1'b1 ;

    pci_clk         = 1'b1 ;
    pci_irdy_reg    = 1'b1 ;
    pci_irdy_en_reg = 1'b1 ;
    pci_trdy_reg    = 1'b1 ;
    pci_ad_reg      = 0 ;

    wb_master_waits = 0 ;

    repeat(10)
        @(posedge clk) ;

    rst <= 1'b0 ;

    run_tests ;
    
    $stop ;
end

task run_tests ;
begin
/*    
    wbs_fill_with_singles(0) ;
    wbs_check_data_with_singles(0) ;

    wbs_fill_with_singles(1) ;
    wbs_check_data_with_bursts(1, 1024) ;

    wbs_fill_with_bursts(0, 2) ;
    wbs_check_data_with_singles(0) ;

    wbs_fill_with_bursts(1, 4) ;
    wbs_check_data_with_bursts(1, 2) ;

    wbs_fill_with_singles(2) ;
    wbs_check_data_with_bursts(2, 16) ;

    wbs_fill_with_bursts(3, 64) ;
    wbs_check_data_with_bursts(3, 128) ;

    test_master_writes ;
    test_master_reads ;
  
    test_slave_error_detection ;

    test_master_transaction_counts ;
*/
    test_master_data_errors ;
end
endtask

task wbs_fill_with_singles ;
    input [3:0] pattern_select ;
    integer i ;
    reg [31:0] current_data ;
    reg [31:0] current_address ;
begin
    current_address = 0 ;

    current_data = get_first_data(pattern_select) ;

    for (i = 0 ; i < 1024 ; i = i + 1)
    begin
        wb_master_single_write(current_address, current_data) ;
        current_data = get_next_data (pattern_select, current_data) ;
        current_address = current_address + 4 ;
    end
end
endtask

task wbs_fill_with_bursts ;
    input [3:0]  pattern_select ;
    input [31:0] burst_sizes ;

    integer i ;
    reg [31:0] current_data ;
    reg [31:0] current_address ;

    reg `WRITE_STIM_TYPE   write_data ;
begin
    current_address = 0 ;

    write_data = 0 ;

    write_data`WRITE_SEL = 4'hF ;

    current_data = get_first_data (pattern_select) ;

    for (i = 0 ; i < 1024 ; i = i + 1)
    begin

        write_data`WRITE_ADDRESS = current_address ;
        write_data`WRITE_DATA    = current_data ;
        
        wishbone_master.blk_write_data[i % burst_sizes] = write_data ;

        if ((i % burst_sizes) == (burst_sizes - 1))
            wb_master_burst_write(burst_sizes) ;

        current_address = current_address + 4 ;
        current_data = get_next_data(pattern_select, current_data) ;
    end
end
endtask

task wbs_check_data_with_singles ;
    input [3:0] pattern_select ;

    integer i ;
    reg [31:0] current_data ;
    reg [31:0] current_address ;
begin
    current_address = 0 ;

    current_data = get_first_data(pattern_select) ;

    for (i = 0 ; i < 1024 ; i = i + 1)
    begin

        wb_master_single_read(current_address, current_data) ;
        current_address = current_address + 4 ;
        current_data    = get_next_data(pattern_select, current_data) ;
    end
end
endtask

task wb_master_single_write ;
    input [31:0] adr_i ;
    input [31:0] data_i ;
    
    reg `WRITE_STIM_TYPE   write_data ;
    reg `WRITE_RETURN_TYPE write_status ;
    reg `WB_TRANSFER_FLAGS write_flags ;
begin
    write_flags = 0 ;
    write_flags`INIT_WAITS   = wb_master_waits ;
    write_flags`SUBSEQ_WAITS = wb_master_waits ;

    write_data  = 0 ;

    write_data`WRITE_DATA    = data_i ;
    write_data`WRITE_ADDRESS = adr_i ;
    write_data`WRITE_SEL     = 4'hF ;

    wishbone_master.wb_single_write( write_data, write_flags, write_status ) ;

    if (write_status`CYC_ACTUAL_TRANSFER !== 1)
    begin
        `TIME ;
        `ERROR("Single writes must always be succesfull") ;
        $stop ;
    end
end
endtask // wb_master_single_write

task wb_master_burst_write ;
    input [31:0] size_i ;
    
    reg `WRITE_RETURN_TYPE write_status ;
    reg `WB_TRANSFER_FLAGS write_flags ;

    integer i ;
begin
    write_flags = 0 ;
    write_flags`WB_TRANSFER_SIZE = size_i ;
    write_flags`WB_TRANSFER_CAB  = 1'b1 ;

    write_flags`INIT_WAITS   = wb_master_waits ;
    write_flags`SUBSEQ_WAITS = wb_master_waits ;

    wishbone_master.wb_block_write( write_flags, write_status ) ;

    if (write_status`CYC_ACTUAL_TRANSFER !== size_i)
    begin
        `TIME ;
        `ERROR("Burst writes must always be succesfull") ;
        $stop ;
    end
end
endtask // wb_master_single_write

task wb_master_single_read ;
    input [31:0] adr_i ;
    input [31:0] data_i ;
    
    reg `READ_STIM_TYPE   read_data ;
    reg `READ_RETURN_TYPE read_status ;
    reg `WB_TRANSFER_FLAGS read_flags ;
begin
    read_flags = 0 ;
    read_data  = 0 ;

    read_data`READ_ADDRESS = adr_i ;
    read_data`READ_SEL     = 4'hF ;

    read_flags`INIT_WAITS   = wb_master_waits ;
    read_flags`SUBSEQ_WAITS = wb_master_waits ;

    wishbone_master.wb_single_read( read_data, read_flags, read_status ) ;

    if (read_status`CYC_ACTUAL_TRANSFER !== 1)
    begin
        `TIME ;
        `ERROR("Single reads must always be succesfull") ;
        $stop ;
    end

    if (read_status`READ_DATA !== data_i)
    begin
        `TIME ;
        `INVALID_DATA("Test module") ;
        `VALUES(data_i, read_status`READ_DATA) ;
        $stop ;
    end
end
endtask // wb_master_single_read

task wb_master_burst_read ;
    input [31:0] size_i ;
    
    reg `READ_RETURN_TYPE read_status ;
    reg `WB_TRANSFER_FLAGS read_flags ;
begin
    read_flags = 0 ;

    read_flags`WB_TRANSFER_SIZE = size_i ;
    read_flags`WB_TRANSFER_CAB  = 1'b1 ;

    read_flags`INIT_WAITS   = wb_master_waits ;
    read_flags`SUBSEQ_WAITS = wb_master_waits ;

    wishbone_master.wb_block_read( read_flags, read_status ) ;

    if (read_status`CYC_ACTUAL_TRANSFER !== size_i)
    begin
        `TIME ;
        `ERROR("Burst reads must always be succesfull") ;
        $stop ;
    end

end
endtask // wb_master_burst_read

task wbs_check_data_with_bursts ;
    input [3:0]  pattern_select ;
    input [31:0] burst_sizes ;

    integer i ;
    reg [31:0] current_data ;
    reg [31:0] current_address ;

    reg `READ_RETURN_TYPE read_status ;
    reg `READ_STIM_TYPE   read_data ;

    integer j ;
begin
    current_address = 0 ;

    read_data          = 0 ;
    read_data`READ_SEL = 4'hF ;

    current_data = get_first_data(pattern_select) ;

    for (i = 0 ; i < 1024 ; i = i + 1)
    begin
        read_data`READ_ADDRESS = current_address ;
        wishbone_master.blk_read_data_in[i % burst_sizes] = read_data ;
        
        if ((i % burst_sizes) == (burst_sizes - 1))
        begin
            wb_master_burst_read(burst_sizes) ;
            for (j = 0 ; j <= (i % burst_sizes) ; j = j + 1)
            begin
                read_status = wishbone_master.blk_read_data_out[j] ;
                if (read_status`READ_DATA !== current_data)
                begin
                    `TIME ;
                    `INVALID_DATA("Test module") ;
                    `VALUES(current_data, read_status`READ_DATA) ;
                    $stop ;
                end
                
                current_data = get_next_data(pattern_select, current_data) ;
            end
        end
        
        current_address = current_address + 4 ;
    end
end
endtask

task test_slave_error_detection ;
    integer i ;
    integer current_test_size ;
    reg [10:0] offset_for_dat_err ;
    reg [10:0] offset_for_adr_err ;

    reg `WRITE_STIM_TYPE   write_data ;
    reg `WRITE_RETURN_TYPE write_status ;
    reg `WB_TRANSFER_FLAGS write_flags ;

    reg [31:0] current_start_address ;
    reg [31:0] current_start_data ;

    reg [31:0] current_address ;
    reg [31:0] current_data ;

    reg [9:0]  current_data_error_offset ;
    reg [9:0]  current_address_error_offset ;
begin

    write_flags = 0 ;
    write_flags`INIT_WAITS   = wb_master_waits ;
    write_flags`SUBSEQ_WAITS = wb_master_waits ;

    write_data  = 0 ;

    write_data`WRITE_SEL     = 4'hF ;

    for (current_test_size = 1 ; current_test_size <= 1024 ; current_test_size = current_test_size * 'd2)
    begin

        // select random address
        current_start_address       = $random ;
        // set the right offset in the 4KB space
        current_start_address[11:0] = ('d1024 - current_test_size) * 4 ;
        // set 13th bit to 0 to select internal rams not registers!
        current_start_address[12]   = 1'b0 ;

        current_start_data = $random ;

        current_data    = current_start_data ;
        current_address = current_start_address ;

        for (i = 0 ; i < current_test_size ; i = i + 1)
        begin
            write_data`WRITE_DATA    = current_data ;
            write_data`WRITE_ADDRESS = current_address ;
            wishbone_master.blk_write_data[i] = write_data ;

            current_data    = {current_data[30:0], current_data[31]} ;
            current_address = current_address + 4 ;
        end

        // put in the last write out of sequence
        write_data`WRITE_ADDRESS = current_start_address ;
        write_data`WRITE_DATA    = current_start_data ;
        wishbone_master.blk_write_data[i] = write_data ;

        write_flags`WB_TRANSFER_SIZE = current_test_size + 1;

        configure_slave_registers
        (
            current_start_address,      // start_adr
            current_start_data,         // start_dat
            current_test_size[10:0],    // test_size
            1'b1,                       // clear_burst_cnt
            1'b1                        // clear_errors
        ) ;

        wishbone_master.wb_block_write(write_flags, write_status) ;
        if (write_status`CYC_ACTUAL_TRANSFER !== current_test_size + 1)
        begin
            `TIME ;
            `ERROR("Block writes must always be succesfull") ;
            $stop ;
        end

        // now test for errors - non should be detected
        check_slave_errors
        (
            1'b0,   // expect_adr_err
            1'b0    // expect_dat_err
        ) ;

        // repeat same thing with one single data sequence error
        current_data_error_offset    = current_test_size - 1 ;
        write_data   = wishbone_master.blk_write_data[current_data_error_offset] ;
        current_data = write_data`WRITE_DATA ;

        // change the value in the data sequence
        current_data                                              = {current_data[0], current_data[31:1]} ;
        write_data`WRITE_DATA                                     = current_data ;
        wishbone_master.blk_write_data[current_data_error_offset] = write_data ;

        configure_slave_registers
        (
            current_start_address,      // start_adr
            current_start_data,         // start_dat
            current_test_size[10:0],    // test_size
            1'b0,                       // clear_burst_cnt
            1'b0                        // clear_errors
        ) ;

        write_flags`WB_TRANSFER_SIZE = current_test_size ;

        wishbone_master.wb_block_write(write_flags, write_status) ;
        if (write_status`CYC_ACTUAL_TRANSFER !== current_test_size)
        begin
            `TIME ;
            `ERROR("Block writes must always be succesfull") ;
            $stop ;
        end

        // now test for errors - data error should be detected
        check_slave_errors
        (
            1'b0,   // expect_adr_err
            1'b1    // expect_dat_err
        ) ;

        // repair the data
        current_data = {current_data[30:0], current_data[31]} ;
        write_data`WRITE_DATA = current_data ;
        wishbone_master.blk_write_data[current_data_error_offset] = write_data ;

        // repeat same thing with one single address sequence error
        current_address_error_offset = 0 ;
        write_data = wishbone_master.blk_write_data[current_address_error_offset] ;
        current_address = write_data`WRITE_ADDRESS ;
        current_address[11:2] = current_address[11:2] - 1'b1 ;
        write_data`WRITE_ADDRESS = current_address ;
        wishbone_master.blk_write_data[current_address_error_offset] = write_data ;

        configure_slave_registers
        (
            current_start_address,      // start_adr
            current_start_data,         // start_dat
            current_test_size[10:0],    // test_size
            1'b0,                       // clear_burst_cnt
            1'b1                        // clear_errors
        ) ;

        wishbone_master.wb_block_write(write_flags, write_status) ;
        if (write_status`CYC_ACTUAL_TRANSFER !== current_test_size)
        begin
            `TIME ;
            `ERROR("Block writes must always be succesfull") ;
            $stop ;
        end

        // now test for errors - address error should be detected
        check_slave_errors
        (
            1'b1,   // expect_adr_err
            1'b0    // expect_dat_err
        ) ;

        // repair the address
        current_address[11:2] = current_address[11:2] + 1'b1 ;
        write_data`WRITE_ADDRESS = current_address ;
        wishbone_master.blk_write_data[current_address_error_offset] = write_data ;        

        
        // repeat same thing with both errors

        current_data_error_offset    = 0 ;
        current_address_error_offset = current_test_size - 1;

        write_data = wishbone_master.blk_write_data[current_address_error_offset] ;
        current_address = write_data`WRITE_ADDRESS ;
        current_address[11:2] = current_address[11:2] + 1'b1 ;
        write_data`WRITE_ADDRESS = current_address ;
        wishbone_master.blk_write_data[current_address_error_offset] = write_data ;

        write_data   = wishbone_master.blk_write_data[current_data_error_offset] ;
        current_data = write_data`WRITE_DATA ;

        // change the value in the data sequence
        current_data                                              = {current_data[30:0], current_data[31]} ;
        write_data`WRITE_DATA                                     = current_data ;
        wishbone_master.blk_write_data[current_data_error_offset] = write_data ;

        configure_slave_registers
        (
            current_start_address,      // start_adr
            current_start_data,         // start_dat
            current_test_size[10:0],    // test_size
            1'b0,                       // clear_burst_cnt
            1'b1                        // clear_errors
        ) ;

        wishbone_master.wb_block_write(write_flags, write_status) ;
        if (write_status`CYC_ACTUAL_TRANSFER !== current_test_size)
        begin
            `TIME ;
            `ERROR("Block writes must always be succesfull") ;
            $stop ;
        end

        // now test for errors - address error should be detected
        check_slave_errors
        (
            1'b1,   // expect_adr_err
            1'b1    // expect_dat_err
        ) ;

        // now do test without errors and check if error statuses remain set
        write_data = wishbone_master.blk_write_data[current_address_error_offset] ;
        current_address = write_data`WRITE_ADDRESS ;
        current_address[11:2] = current_address[11:2] - 1'b1 ;
        write_data`WRITE_ADDRESS = current_address ;
        wishbone_master.blk_write_data[current_address_error_offset] = write_data ;

        write_data   = wishbone_master.blk_write_data[current_data_error_offset] ;
        current_data = write_data`WRITE_DATA ;

        // change the value in the data sequence
        current_data                                              = {current_data[0], current_data[31:1]} ;
        write_data`WRITE_DATA                                     = current_data ;
        wishbone_master.blk_write_data[current_data_error_offset] = write_data ;

        configure_slave_registers
        (
            current_start_address,      // start_adr
            current_start_data,         // start_dat
            current_test_size[10:0],    // test_size
            1'b0,                       // clear_burst_cnt
            1'b0                        // clear_errors
        ) ;

        wishbone_master.wb_block_write(write_flags, write_status) ;
        if (write_status`CYC_ACTUAL_TRANSFER !== current_test_size)
        begin
            `TIME ;
            `ERROR("Block writes must always be succesfull") ;
            $stop ;
        end

        // now test for errors - address error should be detected
        check_slave_errors
        (
            1'b1,   // expect_adr_err
            1'b1    // expect_dat_err
        ) ;


    end
end
endtask // test_slave_error_detection

task test_master_transaction_counts ;
    integer i ;
    reg     ok_wb ;
    reg [2:0] wait_cycles ;
    integer num_of_transactions ;
    reg [31:0] current_address ;
begin
    wait_cycles = 0 ;
    for (i = 1 ; i <= 4096 ; i = i * 2)
    begin
        if (i <= 1024)
            num_of_transactions = 1 ;
        
        if (i == 2048)
            num_of_transactions = 2 ;

        if (i == 4096)
            num_of_transactions = 4 ;

        configure_master_registers 
        (
            i / num_of_transactions,    //transaction_size
            1,                          //opcode
            0,                          //base_address
            1,                          //clear_transaction_counts
            0,                          //initiate_test
            0,                          //test size
            0                           //start_dat
        );

        current_address = 0 ;
        fork
        begin
            wishbone_slave.cycle_response({1'b0, 1'b0, 1'b0}, wait_cycles, 0) ;
            fork
            begin
                activate_master(num_of_transactions) ;
                wishbone_slave.cycle_response({1'b1, 1'b0, 1'b0}, wait_cycles, 0) ;
            end
                repeat (num_of_transactions)
                begin
                    wb_transaction_progress_monitor
                    (
                        current_address,            // address
                        1'b1,                       // write
                        i / num_of_transactions,    // num_of_transfers
                        1'b1,                       // check_transfers
                        ok_wb                       // ok
                    ) ;

                    if (ok_wb !== 1'b1)
                    begin
                        `TIME ;
                        `ERROR("Transaction progress monitor detected invalid transaction!") ;
                        $stop ;
                    end
                    current_address = current_address + 4096 ;
                end
            join
        end
        begin
            @(posedge clk) ;
            while(~wbm_cyc_o | ~wbm_stb_o | ~wbm_ack_i)
                @(posedge clk) ;

            repeat(2)
                @(posedge pci_clk) ;

            pci_irdy_reg    <= 1'b1 ;
            pci_irdy_en_reg <= 1'b1 ;
            pci_trdy_reg    <= 1'b0 ;

            repeat(i)
            begin
                repeat (wait_cycles)
                begin
                    @(posedge pci_clk) ;
                    pci_irdy_reg <= 1'b1 ;
                end

                @(posedge pci_clk) ;
                pci_irdy_reg    <= 1'b0 ;
                pci_irdy_en_reg <= 1'b1 ;
                pci_trdy_reg    <= 1'b0 ;
            end
            
            @(posedge pci_clk) ;
            pci_irdy_reg <= 1'b1 ;
        end
        join

        // check numbers of transactions recorded
        wb_master_single_read(32'hFFFF_F024, i) ;
        wb_master_single_read(32'h0000_1028, i) ;

        wait_cycles = wait_cycles + 1 ;
    end
end
endtask // test_master_transaction_counts

task test_master_data_errors ;
    integer i ;
    integer current_error_offset ;
    integer num_of_transfers ;
    reg [31:0] tmp ;
begin
    for (i = 1 ; i <= 4096 ; i = i * 2)
    begin
        pci_ad_reg = get_first_data(3) ;
        configure_master_registers
        (
            0,          //transaction_size
            1,          //opcode
            0,          //base_address
            1,          //clear_transaction_counts
            1,          //initiate_test
            i,          //test size
            pci_ad_reg  //start_dat
        );

        @(posedge pci_clk) ;
        pci_irdy_reg    <= 1'b0 ;
        pci_irdy_en_reg <= 1'b1 ;
        pci_trdy_reg    <= 1'b0 ;

        repeat(i)
        begin
            @(posedge pci_clk)
                pci_ad_reg <= get_next_data(3, pci_ad_reg) ;
        end

        pci_irdy_reg    <= 1'b0 ;
        pci_irdy_en_reg <= 1'b1 ;
        pci_trdy_reg    <= 1'b1 ;

        @(posedge pci_clk) ;

        // check for errors detected during the test
        check_master_errors(0) ;

        // now create an error during the simulated transfers - at first, second, one before last and last transfers
        current_error_offset = 1 ;
        while (current_error_offset <= i)
        begin

            
            num_of_transfers = 0 ;
            pci_ad_reg = get_first_data(2) ;
            configure_master_registers
            (
                0,          //transaction_size
                1,          //opcode
                0,          //base_address
                1,          //clear_transaction_counts
                1,          //initiate_test
                i,          //test size
                pci_ad_reg  //start_dat
            );

            @(posedge pci_clk) ;

            if ((num_of_transfers + 1) == current_error_offset)
            begin
                tmp = pci_ad_reg ;
                pci_ad_reg <= ~pci_ad_reg ;
            end

            pci_irdy_reg    <= 1'b0 ;
            pci_irdy_en_reg <= 1'b1 ;
            pci_trdy_reg    <= 1'b0 ;

            repeat(i)
            begin
                @(posedge pci_clk)
                begin
                    num_of_transfers = num_of_transfers + 1 ;
                    if (num_of_transfers == current_error_offset)
                    begin
                        pci_ad_reg <= get_next_data(2, tmp) ;
                    end
                    else if ((num_of_transfers + 1) == current_error_offset)
                    begin
                        tmp = pci_ad_reg ;
                        pci_ad_reg <= ~pci_ad_reg ;
                    end
                    else
                    begin
                        pci_ad_reg <= get_next_data(2, pci_ad_reg) ;
                    end
                end
            end

            pci_irdy_reg    <= 1'b0 ;
            pci_irdy_en_reg <= 1'b1 ;
            pci_trdy_reg    <= 1'b1 ;

            @(posedge pci_clk) ;

            // check for errors detected during the test
            check_master_errors(1) ;

            current_error_offset = current_error_offset * 2 ;
        end
    end
end
endtask // test_master_data_errors

function [31:0] get_next_data ;
    input [3:0]  pattern_select ;
    input [31:0] current_data ;
    
    reg [31:0] new_value ;
begin
    case (pattern_select)
        4'h0:
        begin
            new_value = current_data + 4 ;
        end
        4'h1:
        begin
            new_value = ~((~current_data) + 4) ;
        end
        4'h2, 4'h3:
        begin
            new_value = {current_data[30:0], current_data[31]} ;
        end
        4'h4:
        begin
            new_value     = current_data ;
            new_value[0]  = current_data[21] ^ current_data[5] ;
            new_value     = {new_value[30:0], new_value[31]} ;
        end
        default:
        begin
            new_value = 0 ;
        end
    endcase

    get_next_data = new_value ;
end
endfunction // get_next_data

function [31:0] get_first_data ;
    input [3:0] pattern_select ;
    reg [31:0] value ;
begin
    case (pattern_select)
        4'h0:
        begin
            value = 0 ;
        end
        4'h1:
        begin
            value = 32'hFFFF_FFFF ;
        end
        4'h2:
        begin
            value = 32'h0000_0001 ;
        end
        4'h3:
        begin
            value = 32'hFFFF_FFFE ;
        end
        4'h4:
        begin
            value = 32'hFFFF_FFFF ;
        end
        default:
        begin
            value = 0 ;
        end
    endcase

    get_first_data = value ;
end
endfunction // get_first_data

task test_master_writes ;
    integer i ;
    integer j ;
    reg [31:0] current_address ;
    reg ok_wb ;
    reg [3:0] pattern ;
    reg [3:0] wait_states ;
begin

    pattern = 0 ;
    wait_states = 0 ;

    wb_master_waits = 0 ;

    for (j = 1 ; j <= 1024 ; j = j * 2)
    begin

        current_address = j * 4 ;

        // configure registers to enable master writes
        configure_master_registers(j, 1, current_address, 1'b0, 1'b0, 0, 0) ;
    
        // fill block rams with patterns
        wbs_fill_with_bursts(pattern, j) ;
    
        // deactivate slave
        wishbone_slave.cycle_response(0, 0, 0) ;
    
        fork
        begin
            // activate_master
            activate_master('d1024 / j) ;
        
            // enable slave
            wishbone_slave.cycle_response({1'b1, 1'b0, 1'b0}, wait_states, 0) ;
        end
        begin
            for (i = 0 ; i < ('d1024 / j) ; i = i + 1) 
            begin
                wb_transaction_progress_monitor
                (
                    current_address,    // address
                    1'b1,               // write
                    j,                  // num_of_transfers
                    1'b1,               // check_transfers
                    ok_wb               // ok
                ) ;
        
                if (ok_wb !== 1'b1)
                begin
                    `TIME ;
                    `ERROR("Transaction progress monitor detected invalid transaction!") ;
                    $stop ;
                end
                current_address = current_address + (j * 4) ;
            end
        end
        join
    
        // check the data
        current_address = get_first_data(pattern) ;
        for (i = 0 ; i < j ; i = i + 1)
        begin
            current_address = get_next_data(pattern, current_address) ;
        end

        for (i = 0 ; i < 1024 ; i = i + 1)
        begin
            if ((i + j) == 1024)
                current_address = get_first_data(pattern) ;

            if (wishbone_slave.wb_memory[i + j] !== current_address)
            begin
                `TIME ;
                `ERROR("Test Master written wrong data value to the slave") ;
                `VALUES(current_address, wishbone_slave.wb_memory[i]) ;
                $stop ;
            end
    
            current_address = get_next_data(pattern, current_address) ;
        end

        pattern = pattern + 1 ;
        if (pattern > 4)
            pattern = 0 ;

        wait_states = wait_states + 1 ;
        wb_master_waits = wb_master_waits + 1 ;
    end
    
    wb_master_waits = 0 ;
end
endtask // test_master_writes

task test_master_reads ;
    integer i ;
    integer j ;
    reg [31:0] current_address ;
    reg ok_wb ;
    reg [3:0] pattern ;
    reg [3:0] wait_states ;
begin

    pattern = 0 ;
    wait_states = 0 ;
    
    wb_master_waits = 0 ;

    for (j = 1 ; j <= 1024 ; j = j * 2)
    begin

        current_address = j * 4 ;

        // configure registers to enable master reads
        configure_master_registers(j, 0, current_address, 1'b0, 1'b0, 0, 0) ;
    
        current_address = get_first_data(pattern) ;
        for (i = 0 ; i < j ; i = i + 1)
        begin
            current_address = get_next_data(pattern, current_address) ;
        end

        // fill slave memory with patterns
        for (i = j ; i < (1024 + j) ; i = i + 1)
        begin
            if (i == 1024)
                current_address = get_first_data(pattern) ;

            wishbone_slave.wb_memory[i] = current_address ;
            current_address = get_next_data(pattern, current_address) ;
        end

        // deactivate slave
        wishbone_slave.cycle_response(0, 0, 0) ;
    
        current_address = j * 4 ;

        fork
        begin
            // activate_master
            activate_master('d1024 / j) ;
        
            // enable slave
            wishbone_slave.cycle_response({1'b1, 1'b0, 1'b0}, wait_states, 0) ;
        end
        begin
            for (i = 0 ; i < ('d1024 / j) ; i = i + 1) 
            begin
                wb_transaction_progress_monitor
                (
                    current_address,    // address
                    1'b0,               // write
                    j,                  // num_of_transfers
                    1'b1,               // check_transfers
                    ok_wb               // ok
                ) ;
        
                if (ok_wb !== 1'b1)
                begin
                    `TIME ;
                    `ERROR("Transaction progress monitor detected invalid transaction!") ;
                    $stop ;
                end
                current_address = current_address + (j * 4) ;
            end
        end
        join
    
        // check the data
        wbs_check_data_with_bursts(pattern, j) ;

        pattern = pattern + 1 ;
        if (pattern > 4)
            pattern = 0 ;

        wait_states = wait_states + 1 ;
        wb_master_waits = wb_master_waits + 1 ;
    end

    wb_master_waits = 0 ;
end
endtask // test_master_reads

task configure_master_registers ;
    input [10:0] transaction_size ;
    input        opcode ;
    input [31:0] base_address ;
    input        clear_transaction_counts ;
    input        initiate_test ;
    input [20:0] test_size ;
    input [31:0] start_dat ;
begin
    // write transaction size
    wb_master_single_write(32'h0000_1000, {21'h1FFF_FF, transaction_size}) ;
    wb_master_single_read (32'hFFFF_F000, {21'h0000_00, transaction_size}) ;
    
    // write opcode
    wb_master_single_write(32'h0000_1008, {31'h7FFF_FFFF, opcode}) ;
    wb_master_single_read (32'hFFFF_F008, {31'h0000_0000, opcode}) ;

    // write base address
    wb_master_single_write(32'h0000_100C, base_address) ;
    wb_master_single_read (32'hFFFF_F00C, {base_address[31:2], 2'b00}) ;

    // if clear of wb and pci transaction counters is requested clear them
    if (clear_transaction_counts)
    begin
        wb_master_single_write(32'hFFFF_F024, 32'hFFFF_FFFF) ;
        repeat(3)
            @(posedge pci_clk) ;

        wb_master_single_read(32'h0000_1024, 32'h0) ;
        wb_master_single_read(32'h0000_1028, 32'h0) ;
    end

    if (initiate_test)
    begin
        wb_master_single_write(32'hFFFF_F030, start_dat) ;
        wb_master_single_read(32'h0000_1030, start_dat) ;

        wb_master_single_write(32'hFFFF_F02C, {11'h0, test_size}) ;
        wb_master_single_read(32'h0000_102C, {11'h0, test_size}) ;

        repeat(2)
            @(posedge pci_clk) ;

        repeat(2)
            @(posedge clk) ;

        // check the write - it should not be succesfull, since test is not done yet
        wb_master_single_write(32'hFFFF_F02C, 0) ;

        wb_master_single_read(32'h0000_102C, {11'h0, test_size}) ;

        // all reported errors should be cleared by now!
        wb_master_single_read(32'h0000_1034, 32'h0) ;
    end
end
endtask // configure_master_registers

task configure_slave_registers ;
    input [31:0] start_adr ;
    input [31:0] start_dat ;
    input [10:0] test_size ;
    input        clear_burst_cnt ;
    input        clear_errors ;
begin
    if (clear_burst_cnt)
    begin
        wb_master_single_write(32'h0000_1010, 32'hFFFF_FFFF) ;
        wb_master_single_read (32'hFFFF_F010, 32'h0) ;
    end

    if (clear_errors)
    begin
        wb_master_single_write(32'h0000_1020, 32'hFFFF_FFFF) ;
        wb_master_single_read (32'hFFFF_F020, 32'h0        ) ;
    end


    wb_master_single_write(32'h0000_1018, start_adr) ;
    wb_master_single_read (32'hFFFF_F018, start_adr) ;

    wb_master_single_write(32'h0000_101C, start_dat) ;
    wb_master_single_read (32'hFFFF_F01C, start_dat) ;

    wb_master_single_write(32'h0000_1014, {21'h1F_FFFF, test_size}) ;
    wb_master_single_read (32'hFFFF_F014, {21'h0, test_size}) ;
    
end
endtask // configure_slave_registers

task check_slave_errors ;
    input expect_adr_err ;
    input expect_dat_err ;
begin
    wb_master_single_read (32'hFFFF_F020, {30'h0, expect_adr_err, expect_dat_err}) ;
end
endtask // check_slave_errors

task check_master_errors ;
    input expect_dat_err ;
begin
    wb_master_single_read(32'h0000_1034, {31'h0, expect_dat_err}) ;
end
endtask // check_master_errors

task activate_master ;
    input [10:0] num_of_transactions ;
begin
    wb_master_single_write(32'h0000_1004, {21'h1FFF_FF, num_of_transactions}) ;
    wb_master_single_read (32'hFFFF_F004, {21'h0000_00, num_of_transactions}) ;
end
endtask // activate_master

reg wbm_cyc_o_previous ;

always@(posedge clk)
    wbm_cyc_o_previous <= wbm_cyc_o ;

task wb_transaction_progress_monitor ;
    input [31:0] address ;
    input        write ;
    input [31:0] num_of_transfers ;
    input check_transfers ;
    output ok ;
    reg in_use ;
    integer deadlock_counter ;
    integer transfer_counter ;
    integer deadlock_max_val ;
    reg [2:0] slave_termination ;
    reg       cab_asserted ;
begin:main
    if ( in_use === 1 )
    begin
        $display("wb_transaction_progress_monitor task re-entered! Time %t ", $time) ;
        ok = 0 ;
        disable main ;
    end

    // number of cycles on WB bus for maximum transaction length
    deadlock_max_val = 50 ;

    in_use       = 1 ;
    ok           = 1 ;
    cab_asserted = 0 ;

    fork
    begin:wait_start
        deadlock_counter = 0 ;
        @(posedge clk) ;
        while ( (wbm_cyc_o !== 0 && wbm_cyc_o_previous !== 0) && (deadlock_counter < deadlock_max_val) )
        begin
        	if ((!wbm_stb_o) || (!wbm_ack_i))
            	deadlock_counter = deadlock_counter + 1 ;
            else
            	deadlock_counter = 0;
            @(posedge clk) ;
        end
        if ( wbm_cyc_o !== 0 && wbm_cyc_o_previous !== 0)
        begin
            $display("wb_transaction_progress_monitor task waited for 50 cycles for previous transaction to complete! Time %t ", $time) ;
            in_use = 0 ;
            ok     = 0 ;
            disable main ;
        end

        deadlock_counter = 0 ;
        while ( (wbm_cyc_o !== 1) && (deadlock_counter < deadlock_max_val) )
        begin
            deadlock_counter = deadlock_counter + 1 ;
            @(posedge clk) ;
        end

        if ( wbm_cyc_o !== 1 )
        begin
            $display("wb_transaction_progress_monitor task waited for 50 cycles for transaction to start! Time %t ", $time) ;
            in_use = 0 ;
            ok     = 0 ;
            disable main ;
        end
    end //wait_start
    begin:addr_monitor
        @(posedge clk) ;
        while ( wbm_cyc_o !== 0 && wbm_cyc_o_previous !== 0)
            @(posedge clk) ;

        while( wbm_cyc_o !== 1 )
            @(posedge clk) ;

        while (wbm_stb_o !== 1 )
            @(posedge clk) ;

        if ( wbm_we_o !== write )
        begin
            $display("wb_transaction_progress_monitor detected unexpected transaction on WB bus! Time %t ", $time) ;
            if ( write !== 1 )
                $display("Expected read transaction, wbm_we_o signal value %b ", wbm_we_o) ;
            else
                $display("Expected write transaction, wbm_we_o signal value %b ", wbm_we_o) ;
        end

        if ( wbm_adr_o !== address )
        begin
            $display("wb_transaction_progress_monitor detected unexpected address on WB bus! Time %t ", $time) ;
            $display("Expected address = %h, detected address = %h ", address, wbm_adr_o) ;
            ok = 0 ;
        end
    end
    begin:transfer_checker
        transfer_counter = 0 ;
        @(posedge clk) ;
        while ( wbm_cyc_o !== 0 && wbm_cyc_o_previous !== 0)
            @(posedge clk) ;

        while( wbm_cyc_o !== 1 )
            @(posedge clk) ;

        while( (wbm_cyc_o === 1) && (transfer_counter <= 1024) )
        begin

            if (!cab_asserted)
                cab_asserted = (wbm_cab_o !== 1'b0) ;

            if (wbm_stb_o === 1)
            begin
                slave_termination = {wbm_ack_i, wbm_err_i, wbm_rty_i} ;
                if (wbm_ack_i)
                    transfer_counter = transfer_counter + 1 ;
            end
            @(posedge clk) ;
        end

        if (cab_asserted)
        begin
            // cab was sampled asserted
            // if number of transfers was less than 2 - check for extraordinary terminations
            if (transfer_counter < 2)
            begin
                // if cycle was terminated because of no response, error or retry, than it is OK to have CAB_O asserted while transfering 0 or 1 data.
                // any other cases are wrong
                case (slave_termination)
                3'b000:begin end
                3'b001:begin end
                3'b010:begin end
                default:begin
                            ok = 0 ;
                            $display("Time %t", $time) ;
                            $display("WB_MASTER asserted CAB_O for single transfer") ;
                        end
                endcase
            end
        end
        else
        begin
            // if cab is not asserted, then WB_MASTER should not read more than one data.
            if (transfer_counter > 1)
            begin
                ok = 0 ;
                $display("Time %t", $time) ;
                $display("WB_MASTER didn't assert CAB_O for consecutive block transfer") ;
            end
        end

        if ( check_transfers === 1 )
        begin
            if ( transfer_counter !== num_of_transfers )
            begin
                $display("wb_transaction_progress_monitor detected unexpected transaction! Time %t ", $time) ;
                $display("Expected transfers in transaction = %d, actual transfers = %d ", num_of_transfers, transfer_counter) ;
                ok = 0 ;
            end
        end
    end //transfer_checker
    join

    in_use = 0 ;
end
endtask // wb_transaction_progress_monitor

endmodule // test_bench
