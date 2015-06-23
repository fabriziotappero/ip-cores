//////////////////////////////////////////////////////////////////
//                                                              //
//  Top Level testbench                                         //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Instantiates the system, ddr3 memory model and tb_uart      //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

`include "global_timescale.vh"
`include "system_config_defines.vh"
`include "global_defines.vh"


module tb();

`include "debug_functions.vh"
`include "system_functions.vh"
`include "memory_configuration.vh"

reg                     sysrst;
`ifdef XILINX_VIRTEX6_FPGA  
reg                     clk_533mhz;
`endif
reg                     clk_200mhz;
reg                     clk_25mhz;
reg [31:0]              clk_count = 'd0;

integer                 log_file;

`ifdef AMBER_LOAD_MAIN_MEM
integer                 main_mem_file;
reg     [31:0]          main_mem_file_address;
reg     [31:0]          main_mem_file_data;
reg     [127:0]         main_mem_file_data_128;
integer                 main_mem_line_count;
reg     [22:0]          mm_ddr3_addr;
`endif

integer                 boot_mem_file;
reg     [31:0]          boot_mem_file_address;
reg     [31:0]          boot_mem_file_data;
reg     [127:0]         boot_mem_file_data_128;
integer                 boot_mem_line_count;
integer                 fgets_return;
reg     [120*8-1:0]     line;
reg     [120*8-1:0]     aligned_line;
integer                 timeout = 0;

wire [12:0]             ddr3_addr;
wire [2:0]              ddr3_ba;  
wire                    ddr3_ck_p;  
wire                    ddr3_ck_n;
wire [15:0]             ddr3_dq;   
wire [1:0]              ddr3_dqs_p;  
wire [1:0]              ddr3_dqs_n;
wire [1:0]              ddr3_dm;
wire                    ddr3_ras_n; 
wire                    ddr3_cas_n; 
wire                    ddr3_we_n;  
wire                    ddr3_cke; 
wire                    ddr3_odt;
wire                    ddr3_reset_n; 

                 
`ifdef XILINX_SPARTAN6_FPGA  
wire                    mcb3_rzq;      
wire                    mcb3_zio;      
`endif

tri1                    md;         // bi-directional phy config data
wire                    mdc;        // phy config clock

wire                    uart0_cts;
wire                    uart0_rx;
wire                    uart0_rts;
wire                    uart0_tx;

wire [3:0]              eth_mtxd;
wire                    eth_mtxdv; 
wire                    eth_mtxerr;
wire [3:0]              eth_mrxd;
wire                    eth_mrxdv;

reg  [7*8-1:0]          core_str;


// ======================================
// Instantiate FPGA
// ======================================
system u_system (
    // Clocks and resets
    .brd_rst            ( sysrst            ),
    .brd_clk_p          ( clk_200mhz        ),
    .brd_clk_n          ( ~clk_200mhz       ),
    
    `ifdef XILINX_VIRTEX6_FPGA  
    .sys_clk_p          ( clk_533mhz        ),
    .sys_clk_n          ( ~clk_533mhz       ),
    `endif
    
    // UART 0 signals
    .o_uart0_cts        ( uart0_cts         ),
    .o_uart0_rx         ( uart0_rx          ),
    .i_uart0_rts        ( uart0_rts         ),
    .i_uart0_tx         ( uart0_tx          ),
        
    // DDR3 signals
    .ddr3_dq            ( ddr3_dq           ),
    .ddr3_addr          ( ddr3_addr         ),
    .ddr3_ba            ( ddr3_ba           ),
    .ddr3_ras_n         ( ddr3_ras_n        ),
    .ddr3_cas_n         ( ddr3_cas_n        ),
    .ddr3_we_n          ( ddr3_we_n         ),
    .ddr3_odt           ( ddr3_odt          ),
    .ddr3_reset_n       ( ddr3_reset_n      ),
    .ddr3_cke           ( ddr3_cke          ),
    .ddr3_dm            ( ddr3_dm           ),
    .ddr3_dqs_p         ( ddr3_dqs_p        ),
    .ddr3_dqs_n         ( ddr3_dqs_n        ),
    .ddr3_ck_p          ( ddr3_ck_p         ),
    .ddr3_ck_n          ( ddr3_ck_n         ),
    `ifdef XILINX_VIRTEX6_FPGA  
    .ddr3_cs_n          ( ddr3_cs_n         ),
    `endif
    `ifdef XILINX_SPARTAN6_FPGA  
    .mcb3_rzq           ( mcb3_rzq          ),
    .mcb3_zio           ( mcb3_zio          ),
    `endif

    // Ethernet MII signals
    .mtx_clk_pad_i      ( clk_25mhz         ),
    .mtxd_pad_o         ( eth_mrxd          ), 
    .mtxen_pad_o        ( eth_mrxdv         ),
    .mtxerr_pad_o       (                   ),
    .mrx_clk_pad_i      ( clk_25mhz         ),
    .mrxd_pad_i         ( eth_mtxd          ),
    .mrxdv_pad_i        ( eth_mtxdv         ),
    .mrxerr_pad_i       ( eth_mtxerr        ),
    .mcoll_pad_i        ( 1'd0              ),
    .mcrs_pad_i         ( 1'd0              ),  // Assert Carrier Sense from PHY
    .phy_reset_n        (                   ),
    
    // Ethernet Management Data signals
    .md_pad_io          ( md                ),
    .mdc_pad_o          ( mdc               ),
    
    // LEDs
    .led                (                   )
);



// ======================================
// Instantiate Ethernet Test Device
// ======================================
eth_test u_eth_test(
    .md_io              ( md                ),
    .mdc_i              ( mdc               ),
    .mtx_clk_i          ( clk_25mhz         ),
    .mtxd_o             ( eth_mtxd          ),
    .mtxdv_o            ( eth_mtxdv         ),
    .mtxerr_o           ( eth_mtxerr        ),
    .mrxd_i             ( eth_mrxd          ), 
    .mrxdv_i            ( eth_mrxdv         )
);



// ======================================
// Instantiate DDR3 Memory Model
// ======================================
`ifdef XILINX_FPGA
    ddr3_model_c3 #( 
          .DEBUG      ( 0                   )   // Set to 1 to enable debug messages
          )
    u_ddr3_model (
          .ck         ( ddr3_ck_p           ),
          .ck_n       ( ddr3_ck_n           ),
          .cke        ( ddr3_cke            ),
          `ifdef XILINX_VIRTEX6_FPGA  
          .cs_n       ( ddr3_cs_n           ),
          `else
          .cs_n       ( 1'b0                ),
          `endif
          .ras_n      ( ddr3_ras_n          ),
          .cas_n      ( ddr3_cas_n          ),
          .we_n       ( ddr3_we_n           ),
          .dm_tdqs    ( ddr3_dm             ),
          .ba         ( ddr3_ba             ),
          .addr       ( {1'd0, ddr3_addr}   ),
          .dq         ( ddr3_dq             ),
          .dqs        ( ddr3_dqs_p          ),
          .dqs_n      ( ddr3_dqs_n          ),
          .tdqs_n     (                     ),
          .odt        ( ddr3_odt            ),
          .rst_n      ( ddr3_reset_n        )
          );
`endif



// ======================================
// Instantiate Testbench UART
// ======================================
tb_uart u_tb_uart (
    .i_uart_cts_n   ( uart0_cts ),          // Clear To Send
    .i_uart_rxd     ( uart0_rx  ),
    .o_uart_rts_n   ( uart0_rts ),          // Request to Send
    .o_uart_txd     ( uart0_tx  )

);



// ======================================
// Global module for xilinx hardware simulations
// ======================================
`ifdef XILINX_FPGA
    `define GLBL
    glbl glbl();
`endif


// ======================================
// Clock and Reset
// ======================================

// 200 MHz clock
initial
    begin
    clk_200mhz = 1'd0;
    // Time unit is pico-seconds
    forever #2500 clk_200mhz = ~clk_200mhz;
    end


`ifdef XILINX_VIRTEX6_FPGA  
// 400 MHz clock
initial
    begin
    clk_533mhz = 1'd0;
    // Time unit is pico-seconds
    forever #938 clk_533mhz = ~clk_533mhz;
    end
`endif

    
// 25 MHz clock
initial
    begin
    clk_25mhz = 1'd0;
    forever #20000 clk_25mhz = ~clk_25mhz;
    end
    
initial
    begin
    sysrst = 1'd1;
    #40000
    sysrst = 1'd0;
    end


// ======================================
// Counter of system clock ticks        
// ======================================
always @ ( posedge `U_SYSTEM.sys_clk )
    clk_count <= clk_count + 1'd1;

        
    
// ======================================
// Initialize Boot Memory
// ======================================
    initial
        begin
`ifndef XILINX_FPGA
        $display("Load boot memory from %s", `BOOT_MEM_FILE);
        boot_mem_line_count   = 0;
        boot_mem_file         = $fopen(`BOOT_MEM_FILE,    "r");
        if (boot_mem_file == 0)
            begin
            `TB_ERROR_MESSAGE
            $display("ERROR: Can't open input file %s", `BOOT_MEM_FILE);
            $finish;
            end
        
        if (boot_mem_file != 0)
            begin  
            fgets_return = 1;
            while (fgets_return != 0)
                begin
                fgets_return        = $fgets(line, boot_mem_file);
                boot_mem_line_count = boot_mem_line_count + 1;
                aligned_line        = align_line(line);
                
                // if the line does not start with a comment
                if (aligned_line[120*8-1:118*8] != 16'h2f2f)
                    begin
                    // check that line doesnt start with a '@' or a blank
                    if (aligned_line[120*8-1:119*8] != 8'h40 && aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        $display("Format ERROR in input file %s, line %1d. Line must start with a @, not %08x", 
                                 `BOOT_MEM_FILE, boot_mem_line_count, aligned_line[118*8-1:117*8]);
                        `TB_ERROR_MESSAGE
                        end
                    
                    if (aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        boot_mem_file_address  =   hex_chars_to_32bits (aligned_line[119*8-1:111*8]);
                        boot_mem_file_data     =   hex_chars_to_32bits (aligned_line[110*8-1:102*8]);
                        
                        `ifdef AMBER_A25_CORE
                            boot_mem_file_data_128 = `U_BOOT_MEM.u_mem.mem[boot_mem_file_address[BOOT_MSB:4]];
                            `U_BOOT_MEM.u_mem.mem[boot_mem_file_address[BOOT_MSB:4]] = 
                                    insert_32_into_128 ( boot_mem_file_address[3:2], 
                                                         boot_mem_file_data_128, 
                                                         boot_mem_file_data );
                        `else
                            `U_BOOT_MEM.u_mem.mem[boot_mem_file_address[BOOT_MSB:2]] = boot_mem_file_data;
                        `endif
                        
                        `ifdef AMBER_LOAD_MEM_DEBUG
                            $display ("Load Boot Mem: PAddr: 0x%08x, Data 0x%08x", 
                                        boot_mem_file_address, boot_mem_file_data);
                        `endif   
                        end
                    end  
                end
                
            $display("Read in %1d lines", boot_mem_line_count);      
            end
`endif
            
        // Grab the test name from memory    
        timeout   = `AMBER_TIMEOUT   ;  
        `ifdef AMBER_A25_CORE
        core_str = "amber25";
        `else
        core_str = "amber23";
        `endif         
        $display("Core %s, log file %s, timeout %0d, test name %0s ", core_str, `AMBER_LOG_FILE, timeout, `AMBER_TEST_NAME );          
        log_file = $fopen(`AMBER_LOG_FILE, "a");                               
        end
    


// ======================================
// Initialize Main Memory
// ======================================
`ifdef AMBER_LOAD_MAIN_MEM
    initial
        begin
        $display("Load main memory from %s", `MAIN_MEM_FILE);
        `ifdef XILINX_FPGA
        // Wait for DDR3 initialization to complete
        $display("Wait for DDR3 initialization to complete before loading main memory");
        #70000000
        $display("Done waiting at %d ticks", `U_TB.clk_count);
        `endif
        main_mem_file   = $fopen(`MAIN_MEM_FILE, "r");
            
        // Read RAM File
        main_mem_line_count   = 0;
        
        if (main_mem_file == 0)
            begin
            $display("ERROR: Can't open input file %s", `MAIN_MEM_FILE);
            `TB_ERROR_MESSAGE
            end
        

        if (main_mem_file != 0)
            begin  
            fgets_return = 1;
            while (fgets_return != 0)
                begin
                fgets_return        = $fgets(line, main_mem_file);
                main_mem_line_count = main_mem_line_count + 1;
                aligned_line        = align_line(line);
                
                // if the line does not start with a comment
                if (aligned_line[120*8-1:118*8] != 16'h2f2f)
                    begin
                    // check that line doesnt start with a '@' or a blank
                    if (aligned_line[120*8-1:119*8] != 8'h40 && aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        $display("Format ERROR in input file %s, line %1d. Line must start with a @, not %08x", 
                                 `MAIN_MEM_FILE, main_mem_line_count, aligned_line[118*8-1:117*8]);
                        `TB_ERROR_MESSAGE
                        end
                    
                    if (aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        main_mem_file_address =   hex_chars_to_32bits (aligned_line[119*8-1:111*8]);
                        main_mem_file_data    =   hex_chars_to_32bits (aligned_line[110*8-1:102*8]);
                        
                        `ifdef XILINX_FPGA
                            mm_ddr3_addr = {main_mem_file_address[13:11], main_mem_file_address[26:14], main_mem_file_address[10:4]};
                        
                            main_mem_file_data_128 = tb.u_ddr3_model.memory [mm_ddr3_addr];
                            tb.u_ddr3_model.memory [mm_ddr3_addr] =
                                    insert_32_into_128 ( main_mem_file_address[3:2], 
                                                         main_mem_file_data_128, 
                                                         main_mem_file_data );
                                                
                            `ifdef AMBER_LOAD_MEM_DEBUG
                                main_mem_file_data_128 = tb.u_ddr3_model.memory [mm_ddr3_addr];
                                $display ("Load DDR3: PAddr: 0x%08x, DDR3 Addr 0x%08h, Data 0x%032x", 
                                          main_mem_file_address, mm_ddr3_addr, main_mem_file_data_128);
                            `endif   

                        `else
                            // Fast simulation model of main memory
                        
                            // U_RAM - Can either point to simple or Xilinx DDR3 model. 
                            // Set in hierarchy_defines.v
                            
                            main_mem_file_data_128 = `U_RAM [main_mem_file_address[31:4]];
                            `U_RAM [main_mem_file_address[31:4]] = 
                                insert_32_into_128 ( main_mem_file_address[3:2], 
                                                     main_mem_file_data_128, 
                                                     main_mem_file_data );

                            `ifdef AMBER_LOAD_MEM_DEBUG
                                $display ("Load RAM: PAddr: 0x%08x, Data 0x%08x", 
                                           main_mem_file_address, main_mem_file_data);
                            `endif   
                        
                        `endif
                        
                        end
                    end  
                end
                
            $display("Read in %1d lines", main_mem_line_count);      
            end
        end
`endif

    
dumpvcd u_dumpvcd();

// ======================================
// Terminate Test  
// ======================================
`ifdef AMBER_A25_CORE
    `include "a25_localparams.vh"
    `include "a25_functions.vh"
`else
    `include "a23_localparams.vh"
    `include "a23_functions.vh"
`endif

reg             testfail;
wire            test_status_set;
wire [31:0]     test_status_reg;

initial
    begin
    testfail  = 1'd0;
    end
    
assign test_status_set = `U_TEST_MODULE.test_status_set;
assign test_status_reg = `U_TEST_MODULE.test_status_reg;

always @*
        begin
        if ( test_status_set || testfail )
            begin
            if ( test_status_reg == 32'd17 && !testfail )
                begin
                display_registers;
                $display("++++++++++++++++++++");
                $write("Passed %s %0d ticks\n", `AMBER_TEST_NAME, `U_TB.clk_count);
                $display("++++++++++++++++++++");
                $fwrite(`U_TB.log_file,"Passed %s %0d ticks\n", `AMBER_TEST_NAME, `U_TB.clk_count);
                $finish;
                end
            else
                begin
                display_registers;
                if ( testfail )
                    begin
                    $display("++++++++++++++++++++");
                    $write("Failed %s\n", `AMBER_TEST_NAME);
                    $display("++++++++++++++++++++");
                    $fwrite(`U_TB.log_file,"Failed %s\n", `AMBER_TEST_NAME);
                    $finish;
                    end
                else
                    begin
                    $display("++++++++++++++++++++");
                    if (test_status_reg >= 32'h8000)
                        $write("Failed %s - with error 0x%08x\n", `AMBER_TEST_NAME, test_status_reg);
                    else
                        $write("Failed %s - with error on line %1d\n", `AMBER_TEST_NAME, test_status_reg);
                    $display("++++++++++++++++++++");
                    if (test_status_reg >= 32'h8000)
                        $fwrite(`U_TB.log_file,"Failed %s - with error 0x%08h\n", `AMBER_TEST_NAME, test_status_reg);
                    else
                        $fwrite(`U_TB.log_file,"Failed %s - with error on line %1d\n", `AMBER_TEST_NAME, test_status_reg);
                    $finish;
                    end
                end
            end
        end


// ======================================
// Timeout
// ======================================
always @ ( posedge `U_SYSTEM.sys_clk )
    if ( timeout != 0 )
        if (`U_TB.clk_count >= timeout)
            begin
            `TB_ERROR_MESSAGE
            $display("Timeout Error. Edit $AMBER_BASE/hw/tests/timeouts.txt to change the timeout");
            end
            
// ======================================
// Tasks
// ======================================
task display_registers;
begin
    $display("");
    $display("----------------------------------------------------------------------------");
    $display("Amber Core");

    case (`U_EXECUTE.status_bits_mode)
        FIRQ:    $display("         User       > FIRQ         IRQ          SVC"); 
        IRQ:     $display("         User         FIRQ       > IRQ          SVC"); 
        SVC:     $display("         User         FIRQ         IRQ        > SVC"); 
        default: $display("       > User         FIRQ         IRQ          SVC"); 
    endcase

    $display("r0       0x%08x", `U_REGISTER_BANK.r0);
    $display("r1       0x%08x", `U_REGISTER_BANK.r1);
    $display("r2       0x%08x", `U_REGISTER_BANK.r2);
    $display("r3       0x%08x", `U_REGISTER_BANK.r3);
    $display("r4       0x%08x", `U_REGISTER_BANK.r4);
    $display("r5       0x%08x", `U_REGISTER_BANK.r5);
    $display("r6       0x%08x", `U_REGISTER_BANK.r6);
    $display("r7       0x%08x", `U_REGISTER_BANK.r7);
    $display("r8       0x%08x   0x%08x ", `U_REGISTER_BANK.r8,  `U_REGISTER_BANK.r8_firq);
    $display("r9       0x%08x   0x%08x ", `U_REGISTER_BANK.r9,  `U_REGISTER_BANK.r9_firq);
    $display("r10      0x%08x   0x%08x ", `U_REGISTER_BANK.r10, `U_REGISTER_BANK.r10_firq);
    $display("r11      0x%08x   0x%08x ", `U_REGISTER_BANK.r11, `U_REGISTER_BANK.r11_firq);
    $display("r12      0x%08x   0x%08x ", `U_REGISTER_BANK.r12, `U_REGISTER_BANK.r12_firq);
    
    $display("r13      0x%08x   0x%08x   0x%08x   0x%08x", 
                                               `U_REGISTER_BANK.r13, 
                                               `U_REGISTER_BANK.r13_firq, 
                                               `U_REGISTER_BANK.r13_irq,
                                               `U_REGISTER_BANK.r13_svc);
    $display("r14 (lr) 0x%08x   0x%08x   0x%08x   0x%08x", 
                                               `U_REGISTER_BANK.r14, 
                                               `U_REGISTER_BANK.r14_firq, 
                                               `U_REGISTER_BANK.r14_irq,
                                               `U_REGISTER_BANK.r14_svc);


    $display("r15 (pc) 0x%08x", {6'd0,`U_REGISTER_BANK.r15,2'd0});
    $display("");
    $display("Status Bits: N=%d, Z=%d, C=%d, V=%d, IRQ Mask %d, FIRQ Mask %d, Mode = %s",  
       `U_EXECUTE.status_bits_flags[3],
       `U_EXECUTE.status_bits_flags[2],
       `U_EXECUTE.status_bits_flags[1],
       `U_EXECUTE.status_bits_flags[0],
       `U_EXECUTE.status_bits_irq_mask,
       `U_EXECUTE.status_bits_firq_mask,
       mode_name (`U_EXECUTE.status_bits_mode) );
    $display("----------------------------------------------------------------------------");
    $display("");       

end
endtask


// ======================================
// Functions
// ======================================
function [127:0] insert_32_into_128;
input [1:0]   pos;
input [127:0] word128;
input [31:0]  word32;
begin
     case (pos)
         2'd0: insert_32_into_128 = {word128[127:32], word32};
         2'd1: insert_32_into_128 = {word128[127:64], word32, word128[31:0]};
         2'd2: insert_32_into_128 = {word128[127:96], word32, word128[63:0]};
         2'd3: insert_32_into_128 = {word32, word128[95:0]};
     endcase
end
endfunction


endmodule

