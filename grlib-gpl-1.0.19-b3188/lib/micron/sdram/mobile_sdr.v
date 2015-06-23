/**************************************************************************
*
*    File Name:  model.v  
*      Version:  4.0
*         Date:  Jul 12 2006
*        Model:  BUS Functional
*    Simulator:  Model Technology
*
* Dependencies:  None
*
*        Email:  modelsupport@micron.com
*      Company:  Micron Technology, Inc.
*        Model:  Mobile SDR
*
*  Description:  Micron Mobile SDRAM Verilog model
*
*   Limitation:  - Doesn't check for 4096 cycle refresh
*
*         Note:  - Set simulator resolution to "ps" accuracy
*                - Set Debug = 0 to disable $display messages
*
*  [Disclaimer]    
*  This software code and all associated documentation, comments
*  or other information (collectively "Software") is provided 
*  "AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
*  ("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
*  INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
*  RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
*  FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
*  SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
*  THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
*  MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
*  RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
*  ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
*  OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
*  EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
*  LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
*  SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
*  OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
*  ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
*  EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*  Because some jurisdictions prohibit the exclusion or limitation
*  of liability for consequential or incidental damages, the above
*  limitation may not apply to you.
*  
*  Copyright © 2001-2006 Micron Technology, Inc. All rights reserved.
*
*
* Rev  Author          Date        Changes
* ---  --------------------------  ---------------------------------------
* 4.20 bas             10/11/2006  - Changed tRRD check to use tCK min based on CL
* 4.17 bas             10/10/2006  - fixed read problem during CL3 BL1 related to read w/autoprecharge followed by activate to the same bank causing read from incorrect row, updated parameter sheets
* 4.16 bas             09/27/2006  - fixed tRRD check for parts spec using # of clks instead of ns delay
* 4.15 bas             09/26/2006  - Wrote WRap & RDap code to use #delay due to non-freerunning clock operation, fixed tRP, fixed WRap/RDap interrupt operation
* 4.12 bas             09/08/2006  - Removed realtime array instantiations of variables for NCVerilog
* 4.11 bas             09/07/2006  - tHZ issue, read DQM issue, write/read to precharged bank error(data was still being written), tRP during WRaP issue, RP option added, part selection added
* 4.1  bas             08/23/2006  - fixed masking and tHZ timing issue
* 4.0  bh              07/12/2006  - merged MT48H16M16LF & MT48H32M16LF to create single model file for all types & densities
* 3.2  dritz           11/04/2005  - Fixed Driver Strength bits
* 3.1  dritz           09/22/2005  - Fixed dqm bits to be [1:0] and tb.v as well
* 3.0  dritz           06/28/2005  - MT48H32M16LF 
* 2.1  dritz           03/23/2005  - MT48LC8M32LF Fixed dqm mask bits and functionality
* 2.0  dritz           01/11/2005  - MT48LC8M32B2
* 1.0  NB              07/14/2004  - MT48M16LF
*
**************************************************************************/

`timescale 1ps / 1ps

module mobile_sdr (
    clk   ,
    cke   ,
    addr  ,
    ba    ,
    cs_n  ,
    ras_n ,
    cas_n ,
    we_n  ,
    dq    ,
    dqm    
    );

//------------- Include Statements -------------

//`include "mobile_sdr_parameters.vh"
/****************************************************************************************
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*  of Warranty:  information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2005 Micron Technology, Inc. All rights reserved.
*
****************************************************************************************/

    // Timing parameters based on Speed Grade and part type (Y47M) 03/07

`define sg6
                                          // SYMBOL UNITS DESCRIPTION
                                          // ------ ----- -----------
`ifdef sg6                                 //              Timing Parameters for -75 (CL = 3)
    parameter tCK              =     6000; // tCK    ps    Nominal Clock Cycle Time
    parameter tCK3_min         =     6000; // tCK    ps    Nominal Clock Cycle Time
    parameter tCK2_min         =     9600; // tCK    ps    Nominal Clock Cycle Time
    parameter tCK1_min         =        0; // tCK    ps    Nominal Clock Cycle Time
    parameter tAC3             =     5000; // tAC3   ps    Access time from CLK (pos edge) CL = 3
    parameter tAC2             =     8000; // tAC2   ps    Access time from CLK (pos edge) CL = 2
    parameter tAC1             =        0; // tAC1   ps    Parameter definition for compilation - CL = 1 illegal for sg75
    parameter tHZ3             =     5000; // tHZ3   ps    Data Out High Z time - CL = 3
    parameter tHZ2             =     8000; // tHZ2   ps    Data Out High Z time - CL = 2
    parameter tHZ1             =        0; // tHZ1   ps    Parameter definition for compilation - CL = 1 illegal for sg75
    parameter tOH              =     2500; // tOH    ps    Data Out Hold time
    parameter tMRD             =        2; // tMRD   tCK   Load Mode Register command cycle time (2 * tCK)
    parameter tRAS             =    42000; // tRAS   ps    Active to Precharge command time
    parameter tRC              =    60000; // tRC    ps    Active to Active/Auto Refresh command time
    parameter tRFC             =    97500; // tRFC   ps    Refresh to Refresh Command interval time
    parameter tRCD             =    18000; // tRCD   ps    Active to Read/Write command time
    parameter tRP              =    18000; // tRP    ps    Precharge command period
    parameter tRRD             =        2; // tRRD   tCK   Active bank a to Active bank b command time
    parameter tWRa             =     7500; // tWR    ps    Write recovery time (auto-precharge mode - must add 1 CLK)
    parameter tWRm             =    15000; // tWR    ps    Write recovery time
    parameter tCH              =     2600; // tCH    ps    Clock high level width
    parameter tCL              =     2600; // tCL    ps    Clock low level width
    parameter tXSR             =   120000; // tXSR   ps    Clock low level width
`else `ifdef sg75                          //              Timing Parameters for -8 (CL = 3)
    parameter tCK              =     7500; // tCK    ps    Nominal Clock Cycle Time
    parameter tCK3_min         =     7500; // tCK    ps    Nominal Clock Cycle Time
    parameter tCK2_min         =     9600; // tCK    ps    Nominal Clock Cycle Time
    parameter tCK1_min         =        0; // tCK    ps    Nominal Clock Cycle Time
    parameter tAC3             =     5400; // tAC3   ps    Access time from CLK (pos edge) CL = 3
    parameter tAC2             =     8000; // tAC2   ps    Access time from CLK (pos edge) CL = 2
    parameter tAC1             =        0; // tAC1   ps    Access time from CLK (pos edge) CL = 1
    parameter tHZ3             =     5400; // tHZ3   ps    Data Out High Z time - CL = 3
    parameter tHZ2             =     8000; // tHZ2   ps    Data Out High Z time - CL = 2
    parameter tHZ1             =        0; // tHZ1   ps    Data Out High Z time - CL = 1
    parameter tOH              =     2500; // tOH    ps    Data Out Hold time
    parameter tMRD             =        2; // tMRD   tCK   Load Mode Register command cycle time (2 * tCK)
    parameter tRAS             =    45000; // tRAS   ps    Active to Precharge command time
    parameter tRC              =    67500; // tRC    ps    Active to Active/Auto Refresh command time
    parameter tRFC             =    97500; // tRFC   ps    Refresh to Refresh Command interval time
    parameter tRCD             =    19200; // tRCD   ps    Active to Read/Write command time
    parameter tRP              =    19200; // tRP    ps    Precharge command period
    parameter tRRD             =        2; // tRRD   tCK   Active bank a to Active bank b command time (2 * tCK)
    parameter tWRa             =     7500; // tWR    ps    Write recovery time (auto-precharge mode - must add 1 CLK)
    parameter tWRm             =    15000; // tWR    ps    Write recovery time
    parameter tCH              =     3000; // tCH    ps    Clock high level width
    parameter tCL              =     3000; // tCL    ps    Clock low level width
    parameter tXSR             =   120000; // tXSR   ps    Clock low level width
`endif `endif 

    // Size Parameters based on Part Width

`define x16

`ifdef x32
    parameter ADDR_BITS        =      13; // Set this parameter to control how many Address bits are used
    parameter ROW_BITS         =      13; // Set this parameter to control how many Row bits are used
    parameter DQ_BITS          =      32; // Set this parameter to control how many Data bits are used
    parameter DM_BITS          =       4; // Set this parameter to control how many DM bits are used
    parameter COL_BITS         =       9; // Set this parameter to control how many Column bits are used
    parameter BA_BITS          =       2; // Bank bits
`else `ifdef x16
    parameter ADDR_BITS        =      13; // Set this parameter to control how many Address bits are used
    parameter ROW_BITS         =      13; // Set this parameter to control how many Row bits are used
    parameter DQ_BITS          =      16; // Set this parameter to control how many Data bits are used
    parameter DM_BITS          =       2; // Set this parameter to control how many DM bits are used
    parameter COL_BITS         =      10; // Set this parameter to control how many Column bits are used
    parameter BA_BITS          =       2; // Bank bits
`endif `endif

    // Other Parameters

    parameter full_mem_bits    = BA_BITS+ADDR_BITS+COL_BITS; // Set this parameter to control how many unique addresses are used
    parameter part_mem_bits    = 10;                         // For fast sim load
    parameter part_size        = 256;                        // Set this parameter to indicate part size(512Mb, 256Mb, 128Mb)




//------------- Define Statements --------------

`define BANKS      (1<<BA_BITS)
`define PAGE_SIZE  (1<<COL_BITS)

//------------- Parameters (cke, addr[10], cs_n, ras_n, cas_n, we_n) --------------
    parameter NOP              = 6'b100111 ;
    parameter ACTIVATE         = 6'b100011 ;
    parameter READ             = 6'b100101 ;
    parameter READ_AP          = 6'b110101 ;
    parameter READ_SUSPEND     = 6'b000101 ;
    parameter READ_AP_SUSPEND  = 6'b010101 ;
    parameter WRITE            = 6'b100100 ;
    parameter WRITE_AP         = 6'b110100 ;
    parameter WRITE_SUSPEND    = 6'b000100 ;
    parameter WRITE_AP_SUSPEND = 6'b010100 ;
    parameter BURST_TERMINATE  = 6'b100110 ;
    parameter POWER_DOWN_CI    = 6'b001111 ;
    parameter POWER_DOWN_NOP   = 6'b000111 ;
    parameter DEEP_POWER_DOWN  = 6'b000110 ;
    parameter PRECHARGE        = 6'b100010 ;
    parameter PRECHARGE_ALL    = 6'b110010 ;
    parameter AUTO_REFRESH     = 6'b100001 ;
    parameter SELF_REFRESH     = 6'b000001 ;
    parameter LOAD_MODE        = 6'b100000 ;
    parameter CKE_DISABLE      = 6'b011111 ;

    parameter DEBUG = 1             ;

//----------------------------------------
// Error codes and reporting
//----------------------------------------

    parameter   ERR_MAX_REPORTED =       -1; // >0 = report errors up to ERR_MAX_REPORTED, <0 = report all errors
    parameter   ERR_MAX          =       -1; // >0 = stop the simulation after ERR_MAX has been reached, <0 = never stop the simulation
    parameter   MSGLENGTH        =      256;
    parameter   ERR_CODES        =       16; // track up to 44 different error codes
    // Enumerated error codes (0 = unused)
    parameter   ERR_MISC         =        1;
    parameter   ERR_CMD          =        2;
    parameter   ERR_STATUS       =        3;
    parameter   ERR_tMRD         =        4;
    parameter   ERR_tRAS         =        5;
    parameter   ERR_tRC          =        6;
    parameter   ERR_tRFC         =        7;
    parameter   ERR_tRCD         =        8;
    parameter   ERR_tRP          =        9;
    parameter   ERR_tRRD         =       11;
    parameter   ERR_tWR          =       12;
    parameter   ERR_tCH          =       13;
    parameter   ERR_tCL          =       14;
    parameter   ERR_tXSR         =       15;
    parameter   ERR_tCK_MIN      =       16;

    wire [ERR_CODES : 1] EXP_ERR                  ;
    reg  [ERR_CODES : 1] errcount                 ;
    reg       [8*12-1:0] err_strings [1:ERR_CODES];
    integer     ERR_MAX_INT      =  ERR_MAX;

    assign EXP_ERR     = {ERR_CODES {1'b0}}; // the model expects no errors.  Can only be changed for debug by 'force' statement in testbench.

//------------- Port Declarations --------------

    input                        clk   ;
    input                        cke   ;
    input    [ADDR_BITS - 1 : 0] addr  ;
    input    [BA_BITS - 1 : 0]   ba    ;
    input                        cs_n  ;
    input                        ras_n ;
    input                        cas_n ;
    input                        we_n  ;
    input    [DM_BITS - 1 : 0]   dqm   ;
    inout    [DQ_BITS - 1 : 0]   dq    ;

//------------- Register Declarations --------------

    reg      [8*MSGLENGTH:1]     msg                                      ;
    reg      [`BANKS - 1 :0]     active_bank                              ;
    reg   [ADDR_BITS - 1 :0]     activate_row            [`BANKS - 1 : 0] ;
    reg                          auto_refresh1_done                       ;
    reg  [ COL_BITS - 1 : 0]     burst_count                              ;
    reg   [COL_BITS - 1 : 0]     col_addr_burst_order  [`PAGE_SIZE-1 : 0] ;

    reg    [BA_BITS - 1 : 0]     bank_access_q         [`PAGE_SIZE+2 : 0] ;
    reg   [ROW_BITS - 1 : 0]     row_access_q          [`PAGE_SIZE+2 : 0] ;
    reg   [COL_BITS - 1 : 0]     column_access_q       [`PAGE_SIZE+2 : 0] ;
    reg             [ 1 : 0]     column_access_valid_q [`PAGE_SIZE+2 : 0] ;
    reg             [ 2 : 0]     cas_latency                              ;
    reg                          write_burst_mode                         ;
    reg    [BA_BITS - 1 : 0]     interrupt_bank                           ;
    reg                          burst_type                               ;

    reg      [DQ_BITS-1 : 0]     Dq_out                                   ;
    reg      [DQ_BITS-1 : 0]     Dq_out_tAC                               ;
    reg    [DQ_BITS - 1 : 0]     mdata                                    ;
    reg         [`BANKS-1:0]     ap_set                                   ;
    reg                          cke_q                                    ;
    reg    [DM_BITS - 1 : 0]     dqm_q                                    ;
    reg             [ 1 : 0]     dqm_rtw_chk                              ;
    reg                          Sys_clk                                  ;
    reg              [3 : 0]     initialization_state                     ;
    reg                          self_refresh_enter                       ;
    reg                          power_down_enter                         ;
    reg                          command_sequence_error                   ;
    reg                          read_write_in_progress                   ;

    // Memory Banks
    `ifdef FULL_MEM
        reg  [DQ_BITS - 1 : 0] mem_array  [0 : (1<<full_mem_bits)-1];
    `else
        reg   [DQ_BITS - 1 : 0] mem_array  [0 : (1<<part_mem_bits)-1];
        reg   [full_mem_bits - 1 : 0] addr_array [0 : (1<<part_mem_bits)-1];
        reg   [part_mem_bits     : 0] mem_used;
        reg   [part_mem_bits     : 0] memory_index;
        initial mem_used = 0;
    `endif

//------------- Integer Declarations --------------
    integer                      ck_cntr_initial                          ;
    integer                      ck_cntr_activate                         ;
    integer                      ck_cntr_read                             ;
    integer                      ck_cntr_read_ap                          ;
    integer                      ck_cntr_write                            ;
    integer                      ck_cntr_write_ap                         ;
    integer                      ck_cntr_burst_terminate                  ;
    integer                      ck_cntr_precharge                        ;
    integer                      ck_cntr_auto_refresh                     ;
    integer                      ck_cntr_self_refresh                     ;
    integer                      ck_cntr_power_down                       ;
    integer                      ck_cntr_clock_suspend                    ;
    integer                      ck_cntr_deep_power_down                  ;
    integer                      ck_cntr_load_mode                        ;
    integer                      ck_cntr_cke                              ;
    integer                      ck_cntr_cke_n                            ;
    integer                      ck_cntr_cke_high                         ;
    integer                      ck_cntr_bank_precharge      [`BANKS-1:0] ;
    integer                      ck_cntr_bank_activate       [`BANKS-1:0] ;
    integer                      ck_cntr_bank_write          [`BANKS-1:0] ;
    integer                      ck_cntr_bank_read           [`BANKS-1:0] ;
    integer                      ck_cntr_write_dq            [`BANKS-1:0] ;
    integer                      interrupt_write_ap_n        [`BANKS-1:0] ;
    integer                      interrupt_read_ap_n         [`BANKS-1:0] ;
    integer                      pasr                                     ;
    integer                      warnings                                 ;
    integer                      errors                                   ;
    integer                      burst_length                             ;

    integer                      i                                        ;

//------------- Time Declarations --------------

    time                         tm_initial                     ;
    time                         tm_activate                    ;
    time                         tm_read                        ;
    time                         tm_write                       ;
    time                         tm_burst_terminate             ;
    time                         tm_precharge                   ;
    time                         tm_auto_refresh                ;
    time                         tm_self_refresh                ;
    time                         tm_power_down                  ;
    time                         tm_clock_suspend               ;
    time                         tm_deep_power_down             ;
    time                         tm_load_mode                   ;
    time                         tm_bank_precharge [`BANKS-1:0] ;
    time                         tm_bank_activate  [`BANKS-1:0] ;
    time                         tm_bank_write     [`BANKS-1:0] ;
    time                         tm_bank_read      [`BANKS-1:0] ;
    time                         tm_write_dq       [`BANKS-1:0] ;
    time                         tm_cke                         ;
    time                         tm_cke_n                       ;
    time                         tm_cke_high                    ;

    time                         tm_clk_high_pulse_width        ;
    time                         tm_clk_low_pulse_width         ;
    time                         tm_clk_period                  ;
    time                         tm_clk_negedge                 ;
    time                         tm_clk_posedge                 ;


//------------- Wire Declarations --------------

    wire                         addr_10                        ;
    wire      [ 5 : 0]           command                        ;

//--------------------- Outputs -----------------------

    assign dq = Dq_out_tAC ;

//--------------------- Initialization -----------------------

    initial begin
        auto_refresh1_done = 1'b0           ;
        initialization_state = 4'h0         ;
        active_bank        = {`BANKS{1'b1}} ;
        Dq_out_tAC         = 'bz            ;

        tm_initial         = 0 ;
        tm_activate        = 0 ;
        tm_read            = 0 ;
        tm_write           = 0 ;
        tm_burst_terminate = 0 ;
        tm_precharge       = 0 ;
        tm_auto_refresh    = 0 ;
        tm_self_refresh    = 0 ;
        tm_power_down      = 0 ;
        tm_clock_suspend   = 0 ;
        tm_deep_power_down = 0 ;
        tm_load_mode       = 0 ;
        for (i=0; i<`BANKS; i=i+1) begin
            tm_bank_precharge[i] = 0 ;
            tm_bank_activate[i]  = 0 ;
            tm_bank_write[i]     = 0 ;
            tm_bank_read[i]      = 0 ;
            tm_write_dq[i]       = 0 ;
        end
        tm_cke                 = 0 ;
        tm_cke_n               = 0 ;
        tm_cke_high            = 0 ;
        tm_clk_period          = 0 ;
        tm_clk_low_pulse_width = 0 ;
        tm_clk_high_pulse_width= 0 ;
        tm_clk_negedge         = 0 ;
        tm_clk_posedge         = 0 ;
        tm_clk_low_pulse_width = 0 ;
        for (i=0; i<`BANKS; i=i+1) begin
            ap_set[i] = 1'b0 ;
        end
        ck_cntr_initial         = 100;
        ck_cntr_activate        = 100;
        ck_cntr_read            = 100;
        ck_cntr_read_ap         = 100;
        ck_cntr_write           = 100;
        ck_cntr_write_ap        = 100;
        ck_cntr_burst_terminate = 100;
        ck_cntr_precharge       = 100;
        ck_cntr_auto_refresh    = 100;
        ck_cntr_self_refresh    = 100;
        ck_cntr_power_down      = 100;
        ck_cntr_clock_suspend   = 100;
        ck_cntr_deep_power_down = 100;
        ck_cntr_load_mode       = 100;
        ck_cntr_cke             = 100;
        ck_cntr_cke_n           = 100;
        ck_cntr_cke_high        = 100;
        for (i=0; i<`BANKS; i=i+1) begin
            ck_cntr_bank_precharge[i] = 100;
            ck_cntr_bank_activate[i]  = 100;
            ck_cntr_bank_write[i]     = 100;
            ck_cntr_bank_read[i]      = 100;
            ck_cntr_write_dq[i]       = 100;
            interrupt_write_ap_n[i]   = 2;
            interrupt_read_ap_n[i]    = 1;
        end
        for (i=0; i<`PAGE_SIZE+3;i=i+1) begin
            bank_access_q[i] = 'bz ;
            row_access_q[i] = 'bz ;
            column_access_q[i] = 'bz ;
            column_access_valid_q[i] = 2'b00 ;
        end
        for (i=0; i<`PAGE_SIZE+3; i=i+1) begin
            column_access_valid_q[i] = 2'b00 ;
        end
        warnings = 0;
        errors = 0;
        for (i=1; i<=ERR_CODES; i=i+1) begin
            errcount[i] = 0;
        end
        self_refresh_enter      = 0;
        power_down_enter        = 0;
        command_sequence_error  = 0;
        read_write_in_progress  = 0;
        pasr                    = 0;
    end

//---------------------- Command Selection ----------------------

    assign addr_10 = addr[10] & ((cke_q & ~cs_n &  ras_n & ~cas_n &  we_n & ~(burst_length == `PAGE_SIZE) ) |  // Read w/ap
                                 (cke_q & ~cs_n &  ras_n & ~cas_n & ~we_n & ~(burst_length == `PAGE_SIZE) ) |  // Write w/ap
                                 (cke_q & ~cs_n & ~ras_n &  cas_n & ~we_n                                 ) ); // Precharge all

//    assign command = ({cke, addr_10, cs_n, (ras_n | cs_n), (cas_n | cs_n), (we_n | cs_n)} & {cke_q, {5{1'b1}}}) | {1'b0, {5{~cke_q}}};

    assign command = {cke, addr_10, cs_n, (ras_n | cs_n), (cas_n | cs_n), (we_n | cs_n)} ;




//---------------------- Mode Register Selection ----------------------

    task set_mode_reg;
    begin
        // Burst Length selection
        if (addr[2:0] == 3'b000) begin
            burst_length = 1 ;
        end else if (addr[2:0] == 3'b001) begin
            burst_length = 2 ;
        end else if (addr[2:0] == 3'b010) begin
            burst_length = 4 ;
        end else if (addr[2:0] == 3'b011) begin
            burst_length = 8 ;
        end else if (addr[2:0] == 3'b111) begin
            burst_length = `PAGE_SIZE ;
        end else begin
            burst_length = 0 ;
        end
        burst_type = addr[3] ;
        cas_latency = addr[6:4] ;
        write_burst_mode = addr[9] ;
    end
    endtask

    task set_ext_mode_reg;
    begin
        // PASR selection
        if (addr[2:0] == 3'b000) begin
            pasr = 0 ;
        end else if (addr[2:0] == 3'b001) begin
            pasr = 1 ;
        end else if (addr[2:0] == 3'b010) begin
            pasr = 2 ;
        end else if (addr[2:0] == 3'b101) begin
            pasr = 3 ;
        end else if (addr[2:0] == 3'b110) begin
            pasr = 4 ;
        end else begin
            pasr = 5 ;
        end
    end
    endtask

    task column_burst_order;
    begin
        burst_count = 0 ;
        for (i=0; i<burst_length; i=i+1) begin
            if (burst_length == `PAGE_SIZE) begin
                if (burst_type == 1'b0) begin
                    col_addr_burst_order[i] = addr[COL_BITS-1:0] + burst_count ;
                end else if (burst_type == 1'b1) begin
                    col_addr_burst_order[i] = {COL_BITS{1'bx}} ;
                end
            end else if (burst_length == 1) begin
                if (burst_type == 1'b0) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], addr[2:0]} ;
                end else if (burst_type == 1'b1) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], addr[2:0]} ;
                end
            end else if (burst_length == 2) begin
                if (burst_type == 1'b0) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], addr[2:1], (burst_count[0] + addr[0])} ;
                end else if (burst_type == 1'b1) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], addr[2:1], (burst_count[0] ^ addr[0])} ;
                end
            end else if (burst_length == 4) begin
                if (burst_type == 1'b0) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], addr[2], (burst_count[1:0] + addr[1:0])} ;
                end else if (burst_type == 1'b1) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], addr[2], (burst_count[1:0] ^ addr[1:0])} ;
                end
            end else if (burst_length == 8) begin
                if (burst_type == 1'b0) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], (burst_count[2:0] + addr[2:0])} ;
                end else if (burst_type == 1'b1) begin
                    col_addr_burst_order[i] = {addr[COL_BITS-1:3], (burst_count[2:0] ^ addr[2:0])} ;
                end
            end
            burst_count = burst_count + 1'b1 ;
        end
    end
    endtask

//---------------------- Memory Address Queue ----------------------


    task column_address_read_queue;
    begin
        for (i=0; i<burst_length;i=i+1) begin
            bank_access_q[cas_latency-1+i] = ba ;
            row_access_q[cas_latency-1+i] = activate_row[ba] ;
            column_access_q[cas_latency-1+i] = col_addr_burst_order[i] ;
            column_access_valid_q[cas_latency-1+i] = 2'b10 ;
        end
        if (burst_length < `PAGE_SIZE) begin
            for (i=burst_length; i< (burst_length+cas_latency-1);i=i+1) begin
                bank_access_q[cas_latency-1+i] = 'bz ;
                row_access_q[cas_latency-1+i] = 'bz ;
                column_access_q[cas_latency-1+i] = 'bz ;
                column_access_valid_q[cas_latency-1+i] = 2'b00 ;
            end
        end
    end
    endtask

    task column_address_write_queue;
    begin
        for (i=0; i<burst_length;i=i+1) begin
            bank_access_q[i] = ba ;
            row_access_q[i] = activate_row[ba] ;
            column_access_q[i] = col_addr_burst_order[i] ;
            column_access_valid_q[i] = 2'b01 ;
        end
        if (burst_length < `PAGE_SIZE) begin
            for (i=burst_length; i<(burst_length+cas_latency-1);i=i+1) begin
                bank_access_q[i] = 'bz ;
                row_access_q[i] = 'bz ;
                column_access_q[i] = 'bz ;
                column_access_valid_q[i] = 2'b00 ;
            end
        end
    end
    endtask

    task burst_term_read_queue;
    begin
        for (i=0; i<burst_length;i=i+1) begin
            bank_access_q[cas_latency-1+i]         =   'bz ;
            row_access_q[cas_latency-1+i]          =   'bz ;
            column_access_q[cas_latency-1+i]       =   'bz ;
            column_access_valid_q[cas_latency-1+i] = 2'b00 ;
        end
    end
    endtask

    task burst_term_write_queue;
    begin
        for (i=0; i<burst_length;i=i+1) begin
            bank_access_q[i]         =   'bz ;
            row_access_q[i]          =   'bz ;
            column_access_q[i]       =   'bz ;
            column_access_valid_q[i] = 2'b00 ;
        end
    end
    endtask

//---------------------- Read Data suppression ----------------------

    task read_data_suppression;
        input       [DQ_BITS - 1 : 0] data      ;
        input       [DM_BITS - 1 : 0] dqm       ;
        output      [DQ_BITS - 1 : 0] mdata     ;
    begin
        for (i=0; i<DQ_BITS; i=i+1) begin
            if (~dqm[i/8]) begin
                mdata[i] = data[i];
            end else if (dqm[i/8]) begin
                mdata[i] = 1'bz;
            end
        end
    end
    endtask

//---------------------- Mask Data ----------------------

    task mask_data;
        input       [BA_BITS - 1 : 0] bank      ;
        input     [ADDR_BITS - 1 : 0] row       ;
        input      [COL_BITS - 1 : 0] col       ;
        input       [DQ_BITS - 1 : 0] data      ;
        input       [DM_BITS - 1 : 0] dqm       ;
        output      [DQ_BITS - 1 : 0] mdata     ;
        reg         [DQ_BITS - 1 : 0] read_data ;
    begin
        read_mem({bank, row, col}, read_data);
        for (i=0; i<DQ_BITS; i=i+1) begin
            if (~dqm[i/8]) begin
                mdata[i] = data[i];
            end else if (dqm[i/8]) begin
                mdata[i] = read_data[i];
            end
        end
    end
    endtask

//---------------------- Check for active read/write command task ----------------------

    task active_read_write;
    begin
        read_write_in_progress = 1'b0 ;
        for (i=0; i<cas_latency; i=i+1) begin
            if (|column_access_valid_q[i] != 1'b0) begin
                read_write_in_progress = 1'b1 ;
            end
        end
    end
    endtask

//---------------------- Auto-Precharge tasks ----------------------

    task interrupt_auto_precharge;
        input       [BA_BITS - 1 : 0] bank ;
    begin
        if (ap_set[bank]) begin
            if (interrupt_write_ap_n[bank] < 2) begin
                if ((interrupt_write_ap_n[bank]             == 1   ) &
                    (($time - tm_bank_activate[bank]) >= tRAS)  ) begin
                    ap_set[bank] = 1'b0 ;
                    precharge_cmd_func(bank, tWRa) ;
                    interrupt_write_ap_n[bank] = 2    ;
                end else begin
                    interrupt_write_ap_n[bank]   = 1    ;
                    ck_cntr_write_dq[bank] = 0    ;
                    tm_write_dq[bank]      = $time;
                end
            end else if (interrupt_read_ap_n[bank] == 0) begin
                if (($time - tm_bank_activate[bank]) >= tRAS) begin
                    ap_set[bank] = 1'b0 ;
                    precharge_cmd_func(bank, 0) ;
                    interrupt_read_ap_n[bank] = 1 ;
                end
            end
        end
    end
    endtask

    task auto_precharge_management;
    begin
        for (i=0; i<`BANKS; i=i+1) begin
            if (ap_set[i]) begin
                if (tm_bank_write[i] > tm_bank_read[i]) begin
                    if ((ck_cntr_bank_write[i]         >= burst_length) &
                        (($time - tm_bank_activate[i]) >= tRAS        )  ) begin
                        precharge_cmd_func(i, tWRa) ;
                    end
                end else begin
                    if ((ck_cntr_bank_read[i]          >= burst_length) &
                        (($time - tm_bank_activate[i]) >= tRAS        )  ) begin
                        precharge_cmd_func(i, 0) ;
                    end
                end
            end
        end
    end
    endtask

//---------------------- DQ Management ----------------------

    task data_management;
        output  [DQ_BITS - 1 :0] Dq_out                            ;
        reg     [DQ_BITS - 1 :0] rdata_out                         ;
    begin
        if (column_access_valid_q[0] == 2'b01) begin
            mask_data ( bank_access_q[0], row_access_q[0], column_access_q[0] , dq, dqm, mdata );
            write_mem ({bank_access_q[0], row_access_q[0], column_access_q[0]}, mdata   );
            if (~(|dqm == 1'b1)) begin
                ck_cntr_write_dq[bank_access_q[0]] = 0     ;
                tm_write_dq[bank_access_q[0]]      = $time ;
            end
        end
        if (column_access_valid_q[0] == 2'b10)  begin
            read_mem ({bank_access_q[0], row_access_q[0], column_access_q[0]}, rdata_out );
            read_data_suppression(rdata_out, dqm_q, Dq_out );
        end else begin
            Dq_out = 'bz ;
        end
    end
    endtask
//--------------------- dq buffer Output -----------------------

    task Dq_buffer_output;
    begin
        if (cas_latency == 3) begin
            Dq_out_tAC <= #tAC3 Dq_out ;
        end else if (cas_latency == 2) begin
            Dq_out_tAC <= #tAC2 Dq_out ;
        end else if (cas_latency == 1) begin
            Dq_out_tAC <= #tAC1 Dq_out ;
        end
    end
    endtask

//-------------------------------- Clk Stabilization Error Check -------------------------------

    task clk_stabilization_func;
    begin
        if (clk) begin
            tm_clk_low_pulse_width  = $time - tm_clk_negedge ;
            tm_clk_period           = $time - tm_clk_posedge ;
            tm_clk_posedge          = $time                  ;
        end else if (~clk) begin
            tm_clk_high_pulse_width = $time - tm_clk_posedge ;
            tm_clk_negedge          = $time                  ;
        end
    end
    endtask

    task clk_stabilization_err_chk;
    begin
        if (cke) begin
            if (tm_clk_high_pulse_width < tCH) begin
                if (DEBUG == 1'b1) begin
                    $sformat (msg, " : tCH violation, High Pulse Width = %t", tm_clk_high_pulse_width); ERROR(ERR_tCH, msg);
                end
            end
            if (tm_clk_low_pulse_width < tCL) begin
                if (DEBUG == 1'b1) begin
                    $sformat (msg, " : tCL violation, Low Pulse Width = %t", tm_clk_low_pulse_width); ERROR(ERR_tCL, msg);
                end
            end
            if (cas_latency == 3) begin
                if (tm_clk_period < tCK3_min) begin
                    if (DEBUG == 1'b1) begin
                        $sformat (msg, " : tCK Min violation, Clock Period = %t", tm_clk_period); ERROR(ERR_tCK_MIN, msg);
                    end
                end
            end else if (cas_latency == 2) begin
                if (tm_clk_period < tCK2_min) begin
                    if (DEBUG == 1'b1) begin
                        $sformat (msg, " : tCK Min violation, Clock Period = %t", tm_clk_period); ERROR(ERR_tCK_MIN, msg);
                    end
                end
            end else if (cas_latency == 1) begin
                if (tm_clk_period < tCK1_min) begin
                    if (DEBUG == 1'b1) begin
                        $sformat (msg, " : tCK Min violation, Clock Period = %t", tm_clk_period); ERROR(ERR_tCK_MIN, msg);
                    end
                end
            end
        end
    end
    endtask

//-------------------------------- Initialization tasks -------------------------------

    task initialization_cmd_func;                        // ************************** INITIALIZATION STATES ********************************
    begin                                                // initialization_state 0 - waiting for power up and stable clock
        if (initialization_state == 4'h0) begin          // initialization_state 1 - chip powered up and stable clock applied
            if (cke & ~cke_q) begin                      // initialization_state 2 - all banks precharged
                initialization_state = 4'h1 ;            // initialization_state 3 - one auto refresh command executed
            end                                          // initialization_state 4 - two auto refresh commands executed
        end else if (initialization_state == 4'h1) begin // initialization_state 5 - load mode command executed
            if (~(|active_bank)) begin                   // initialization_state 6 - extended load mode command executed
                initialization_state = 4'h2 ;            // initialization_state 7 - both load mode and extended load mode command executed
            end                                          // initialization_state 8 - tRFC after the second auto refresh command has expired
        end else if (initialization_state == 4'h2) begin // initialization_state 9 - Initialization message printed to the screen
            if (command == AUTO_REFRESH) begin
                initialization_state = 4'h3 ;
            end
        end else if (initialization_state == 4'h3) begin
            if (command == AUTO_REFRESH) begin
                initialization_state = 4'h4 ;
            end
        end else if (initialization_state == 4'h4) begin
            if ((command == LOAD_MODE) &
                (ba      == 0        )  ) begin
                initialization_state = 4'h5 ;
            end
            if ((command == LOAD_MODE) &
                (ba      == 2        )  ) begin
                initialization_state = 4'h6 ;
            end
        end else if (initialization_state == 4'h5) begin
            if ((command == LOAD_MODE) &
                (ba      == 2        )  ) begin
                initialization_state = 4'h7 ;
            end
        end else if (initialization_state == 4'h6) begin
            if ((command == LOAD_MODE) &
                (ba      == 0        )  ) begin
                initialization_state = 4'h7 ;
            end
        end else if (initialization_state == 4'h7) begin
            if (($time - tm_auto_refresh) > tRFC) begin
                initialization_state = 4'h8 ;
            end
        end else if (initialization_state == 4'h8) begin
            initialization_state = 4'h9 ;
        end
    end
    endtask

     task initialization_err_chk;
     begin
        if ((cke & ~cke_q) &
            (initialization_state != 4'h9)) begin
            $sformat (msg, "WARNING: SDRAM requires a 100us delay prior to issuing any command other than COMMAND INHIBIT or NOP"); WARN(msg);
        end
        if (((command == ACTIVATE  ) |
             (command == ACTIVATE  ) |
             (command == READ      ) |
             (command == READ_AP   ) |
             (command == WRITE     ) |
             (command == WRITE_AP  ) ) &
            (initialization_state < 8)  ) begin
            $sformat (msg, " ERROR: Initialization incomplete"); ERROR(ERR_MISC, msg);
        end
     end
     endtask

     task initialization_cmd_display;
     begin
        if (DEBUG == 1'b1) begin
            if (initialization_state == 8) begin
                $sformat (msg, " INIT : INITIALIZATION COMPLETE"); NOTE(msg);
            end
        end
     end
     endtask

//-------------------------------- Load Mode Tasks -------------------------------

    task load_mode_cmd_func;
    begin
        if (ba == 2'b10) begin
            set_ext_mode_reg;
//            Ext_mode_reg  = addr  ;
        end else if (ba == 2'b00) begin
//            Mode_reg      = addr  ;
            set_mode_reg;
        end
        ck_cntr_load_mode = 0     ;
        tm_load_mode      = $time ;
    end
    endtask

    task load_mode_err_chk;
    begin
        if (|active_bank) begin
            if (ba == 0) begin
                $sformat (msg, " ERROR: Bank is not Precharged for Lode Mode command, Bank = %d", i); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Lode Mode command will be ignored"); NOTE(msg);
            end else if (ba == 2) begin
                $sformat (msg, " ERROR: Bank is not Precharged for Extended Lode Mode command, Bank = %d", i); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Extended Lode Mode command will be ignored"); NOTE(msg);
            end
        end else begin
            if ((addr[3]   == 1'b1  ) &
                (addr[2:0] == 3'b111) ) begin
                $sformat (msg, " ERROR: Burst Type Interleaved is illegal with Full Page Mode, Bank = %d", i); ERROR(ERR_MISC, msg);
            end
            if ($time - tm_precharge  < tRP) begin
                $sformat (msg, " ERROR: tRP violation"); ERROR(ERR_tRP, msg);
            end
            if ($time - tm_auto_refresh  < tRFC) begin
                $sformat (msg, " ERROR: tRFC violation"); ERROR(ERR_tRFC, msg);
            end
            if (ck_cntr_load_mode  < tMRD) begin
                $sformat (msg, " ERROR: tMRD violation"); ERROR(ERR_tMRD, msg);
            end
        end
    end
    endtask

    task load_mode_cmd_display;
        input [BA_BITS - 1 : 0]   bank ;
        input [ADDR_BITS - 1 : 0] address ;
    begin
        if (bank == 2'b10) begin
            $sformat (msg, " LMR  :        EXTENDED LOAD MODE REGISTER"); NOTE(msg);

            // Self Refresh Coverage
            case (address[2 : 0])
                3'b000  : $sformat (msg, " EMR  :        Self Refresh Cov = 4 banks") ;
                3'b001  : $sformat (msg, " EMR  :        Self Refresh Cov = 2 banks") ;
                3'b010  : $sformat (msg, " EMR  :        Self Refresh Cov = 1 bank")  ;
                3'b101  : $sformat (msg, " EMR  :        Self Refresh Cov = 1/2 bank");
                3'b110  : $sformat (msg, " EMR  :        Self Refresh Cov = 1/4 bank");
                default : $sformat (msg, " EMR  : Error: Self Refresh Cov = Reserved");
            endcase
            NOTE(msg);
            // Maximum Case Temp
            //case (address[4 : 3])
                //2'b11    : $sformat (msg, " EMR  : Maximum Case Temp = 85C");
                //2'b00    : $sformat (msg, " EMR  : Maximum Case Temp = 70C");
                //2'b01    : $sformat (msg, " EMR  : Maximum Case Temp = 45C");
                //2'b10    : $sformat (msg, " EMR  : Maximum Case Temp = 15C");
            //endcase
            //NOTE(msg);
            // Drive Strength
            case (address[6 : 5])
                2'b00    : $sformat (msg, " EMR  :        Drive Strength    = Full Strength")   ;
                2'b01    : $sformat (msg, " EMR  :        Drive Strength    = Half Strength")   ;
                2'b10    : $sformat (msg, " EMR  :        Drive Strength    = Quarter Strength");
                2'b11    : $sformat (msg, " EMR  :        Drive Strength    = Eighth Strength") ;
                default  : $sformat (msg, " EMR  : Error: Drive Strength    = Reserved")        ;
            endcase
            NOTE(msg);
            // Reserved
            case (address[11 : 7])
                5'b00000  : begin end //do nothing
                default   : $sformat (msg, " EMR  : Error: Ext_mode_Reg[11:7] are Reserved");
            endcase
            NOTE(msg);
            set_ext_mode_reg;
        end else if (bank == 2'b00) begin
            $sformat (msg, " LMR  :        LOAD MODE REGISTER"); NOTE(msg);

            // Burst Length
            case (address[2 : 0])
                3'b000  : $sformat (msg, " LMR  :        Burst Length     = 1")       ;
                3'b001  : $sformat (msg, " LMR  :        Burst Length     = 2")       ;
                3'b010  : $sformat (msg, " LMR  :        Burst Length     = 4")       ;
                3'b011  : $sformat (msg, " LMR  :        Burst Length     = 8")       ;
                3'b111  : $sformat (msg, " LMR  :        Burst Length     = Full")    ;
                default : $sformat (msg, " LMR  : Error: Burst Length     = Reserved");
            endcase
            NOTE(msg);
            // Burst Type
            if (address[3] === 1'b0) begin
                $sformat (msg, " LMR  :        Burst Type       = Sequential"); NOTE(msg);
            end else if (address[3] === 1'b1) begin
                $sformat (msg, " LMR  :        Burst Type       = Interleaved"); NOTE(msg);
            end else begin
                $sformat (msg, " LMR  : Error: Burst Type       = Reserved"); NOTE(msg);
            end

            // CAS Latency
            case (address[6 : 4])
                3'b001  : $sformat (msg, " LMR  :        CAS Latency      = 1")       ;
                3'b010  : $sformat (msg, " LMR  :        CAS Latency      = 2")       ;
                3'b011  : $sformat (msg, " LMR  :        CAS Latency      = 3")       ;
                default : $sformat (msg, " LMR  : Error: CAS Latency      = Reserved");
            endcase
            NOTE(msg);
            // Op Mode
            case (address[8 : 7])
                2'b00  : begin end  // do nothing
                default : $sformat (msg, " LMR  : Error: CAS Latency      = Reserved");
            endcase
            NOTE(msg);
            // Write Burst Mode
            if (address[9] === 1'b0) begin
                $sformat (msg, " LMR  :        Write Burst Mode = Programmed Burst Length"); NOTE(msg);
            end else if (address[9] === 1'b1) begin
                $sformat (msg, " LMR  :        Write Burst Mode = Single Location Access"); NOTE(msg);
            end else begin
                $sformat (msg, " LMR  : Error: Write Burst Mode = Reserved"); NOTE(msg);
            end
            // Reserved
            case (address[11 : 10])
                5'b00000  : begin end //do nothing
                default   : $sformat (msg, " LMR  : Error: Ext_mode_Reg[11:10] should be 0");
            endcase
            NOTE(msg);
            set_mode_reg;
        end
    end
    endtask

//-------------------------------- Activate Tasks -------------------------------

    task activate_cmd_func;
        input    [BA_BITS-1 : 0] bank ;
        input  [ADDR_BITS-1 : 0] address ;
    begin
        activate_row[bank]          = address  ;
        active_bank[bank]           = 1'b1  ;
        ck_cntr_activate[bank]      = 0     ;
        tm_activate[bank]           = $time ;
        ck_cntr_bank_activate[bank] = 0     ;
        tm_bank_activate[bank]      = $time ;
    end
    endtask

    task activate_err_chk;
    begin
        if (active_bank[ba] == 1'b1) begin
            $sformat (msg, " ERROR: Bank already activated -- data can be corrupted"); ERROR(ERR_CMD, msg);
            $sformat (msg, " NOTE : Activate command will be ignored :  Bank = %d", ba); NOTE(msg);
            command_sequence_error = 1;
        end else begin

`ifdef Y15W
            for (i=0; i<`BANKS; i=i+1) begin
                if (i != ba) begin
                    if (ck_cntr_bank_activate[i]  < tRRD) begin
                        $sformat (msg, " ERROR: tRRD violation :  Bank = %d", ba); ERROR(ERR_tRRD, msg);
                    end
                end
            end
`else `ifdef Y25M
            for (i=0; i<`BANKS; i=i+1) begin
                if (i != ba) begin
                    if ($time - tm_bank_activate[i]  < tRRD) begin
                        $sformat (msg, " ERROR: tRRD violation :  Bank = %d", ba); ERROR(ERR_tRRD, msg);
                    end
                end
            end
`else `ifdef Y26W
            for (i=0; i<`BANKS; i=i+1) begin
                if (i != ba) begin
                    if ($time - tm_bank_activate[i]  < tRRD) begin
                        $sformat (msg, " ERROR: tRRD violation :  Bank = %d", ba); ERROR(ERR_tRRD, msg);
                    end
                end
            end
`else
            if ((part_size == 128) |
                (part_size == 64 ) ) begin
                for (i=0; i<`BANKS; i=i+1) begin
                    if (i != ba) begin
                        if ($time - tm_bank_activate[i]  < tRRD) begin
                            $sformat (msg, " ERROR: tRRD violation :  Bank = %d", ba); ERROR(ERR_tRRD, msg);
                        end
                    end
                end
            end else begin
                for (i=0; i<`BANKS; i=i+1) begin
                    if (i != ba) begin
                        if (ck_cntr_bank_activate[i]  < tRRD) begin
                            $sformat (msg, " ERROR: tRRD violation :  Bank = %d", ba); ERROR(ERR_tRRD, msg);
                        end
                    end
                end
            end
`endif `endif `endif

            if ($time - tm_bank_activate[ba]  < tRC) begin
                $sformat (msg, " ERROR: tRC violation :  Bank = %d", ba); ERROR(ERR_tRC, msg);
            end
            if ($time - tm_bank_precharge[ba]  < tRP) begin
                $sformat (msg, " ERROR: tRP violation :  Bank = %d", ba); ERROR(ERR_tRP, msg);
            end
            if ($time - tm_auto_refresh  < tRFC) begin
                $sformat (msg, " ERROR: tRFC violation :  Bank = %d", ba); ERROR(ERR_tRFC, msg);
            end
            if (($time - tm_cke_high < tXSR) &
                (self_refresh_enter == 1   )  ) begin
                $sformat (msg, " ERROR: tXSR violation"); ERROR(ERR_tXSR, msg);
            end
            if (ck_cntr_load_mode  < tMRD) begin
                $sformat (msg, " ERROR: tMRD violation"); ERROR(ERR_tMRD, msg);
            end
            if (active_bank[ba] == 1'b1) begin
                $sformat (msg, " ERROR: Bank already activated -- data can be corrupted"); ERROR(ERR_CMD, msg);
            end
            self_refresh_enter = 0 ;
        end
    end
    endtask

    task activate_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " ACT  : ACTIVATE - Bank = %d Row = %h", ba, addr); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Precharge Tasks -------------------------------

    task precharge_cmd_func;
        input  [BA_BITS-1 : 0] bank ;
        input  integer         delay;
    begin
        if (delay > 0) begin
            active_bank[bank]              <= #delay 1'b0            ;
            ck_cntr_bank_precharge[bank]   <= #delay 0               ;
            ck_cntr_precharge              <= #delay 0               ;
            tm_bank_precharge[bank]        <= #delay ($time + delay) ;
            tm_precharge                   <= #delay ($time + delay) ;
            ap_set[bank]                   <= #delay 1'b0            ;
        end else begin
            active_bank[bank]              = 1'b0                    ;
            ck_cntr_bank_precharge[bank]   = 0                       ;
            ck_cntr_precharge              = 0                       ;
            tm_bank_precharge[bank]        = $time                   ;
            tm_precharge                   = $time                   ;
            ap_set[bank]                   = 1'b0                    ;
            // Precharge interrupt a read command to the same bank
            if (bank_access_q[0] == bank) begin
                for (i=(cas_latency-1); i<((cas_latency-1)+burst_length); i=i+1) begin
                    if (bank_access_q[i] == bank) begin
                        column_access_valid_q[i] = 2'b00 ;
                    end
                end
            end
            // Precharge interrupt a write command to the same bank
            if ((bank_access_q[0] == bank         ) &
                (column_access_valid_q[0] == 2'b01) ) begin
                for (i=0; i<burst_length; i=i+1) begin
                    if (bank_access_q[i] == bank) begin
                        column_access_valid_q[i] = 2'b00 ;
                    end
                end
            end
        end
    end
    endtask

    task precharge_err_chk;
        input  [BA_BITS-1 : 0] bank ;
    begin
        if (active_bank[bank] == 1'b1) begin
            if ($time - tm_bank_activate[bank] < tRAS) begin
                $sformat (msg, " ERROR: tRAS violation :  Bank = %d", bank); ERROR(ERR_tRAS, msg);
            end
            if ($time - tm_write_dq[bank] < tWRm) begin
                $sformat (msg, " ERROR: tWR violation :  Bank = %d", bank); ERROR(ERR_tWR, msg);
            end
            if ($time - tm_auto_refresh < tRFC) begin
                $sformat (msg, " ERROR: tRFC violation"); ERROR(ERR_tRFC, msg);
            end
            if (ck_cntr_load_mode < tMRD) begin
                $sformat (msg, " ERROR: tMRD violation"); ERROR(ERR_tMRD, msg);
            end
            if ((ap_set[bank] == 1'b1) &
                (ba == bank          )  ) begin
                $sformat (msg, " ERROR: Precharge issued to bank currently in auto precharge mode :  Bank = %d", bank); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Precharge command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1 ;
            end
            if ((column_access_valid_q[0] == 2'b01  ) &
                (ap_set[bank] == 1'b0               ) &
                (dqm != {DM_BITS{1'b1}}             ) ) begin
                $sformat (msg, " ERROR: Incorrect assertion of data masks during write to precharge, Bank = %d", bank); ERROR(ERR_MISC, msg);
            end
        end
    end
    endtask

    task precharge_cmd_display;
        input  [BA_BITS-1 : 0] bank ;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " PRE  : PRECHARGE - Bank = %d", bank); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Precharge All Tasks -------------------------------

    task precharge_all_cmd_func;
    begin
        for (i=0; i<`BANKS; i=i+1) begin
            precharge_cmd_func(i, 0);
        end
    end
    endtask

    task precharge_all_err_chk;
    begin
        for (i=0; i<`BANKS; i=i+1) begin
            precharge_err_chk(i);
        end
    end
    endtask

    task precharge_all_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, "PREALL: PRECHARGE ALL"); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Write Tasks -------------------------------

    task write_cmd_func;
    begin
        column_burst_order             ;
        column_address_write_queue     ;
        tm_write               = $time ;
        tm_bank_write[ba]      = $time ;
        ck_cntr_write          = 0     ;
        ck_cntr_bank_write[ba] = 0     ;
        // write interrupt write ap
        if ((column_access_valid_q[0] == 2'b01) &
            (bank_access_q[0]    != ba        ) &
            (|ap_set                          )  ) begin
            interrupt_write_ap_n[ba]  = 0               ;
            interrupt_bank            = bank_access_q[0];
        end
        // write interrupt read ap
        if ((column_access_valid_q[0] == 2'b10) &
            (bank_access_q[0]  != ba          ) &
            (|ap_set                          )  ) begin
            interrupt_read_ap_n[ba] = 0               ;
            interrupt_bank          = bank_access_q[0];
        end
    end
    endtask

    task write_err_chk;
    begin
        if (active_bank[ba] == 1'b0) begin
            $sformat (msg, " ERROR: Bank is not Activated for Write, Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
            $sformat (msg, " NOTE : Write command will be ignored :  Bank = %d", ba); NOTE(msg);
            command_sequence_error = 1 ;
        end else begin
            if (($time - tm_bank_activate[ba]) < tRCD) begin
                $sformat (msg, " ERROR: tRCD violation :  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_tRCD, msg);
            end
            if ((ap_set[ba] == 1'b1        ) &
                (tm_bank_write[ba] > tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Write interrupt Write with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Write command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1'b1 ;
            end
            if ((ap_set[ba] == 1'b1        ) &
                (tm_bank_write[ba] < tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Write interrupt Read with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Write command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1'b1 ;
            end
            if (((dqm_rtw_chk[0] == 1'b1        ) |
                 (dqm_rtw_chk[1] == 1'b1        ) ) &
                (ap_set[ba] == 1'b0               )  ) begin
                $sformat (msg, " ERROR: DQ contention caused by incorrect assertion of data masks during read to write, Bank = %d", ba); ERROR(ERR_MISC, msg);
            end
        end
    end
    endtask

    task write_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " WR   : WRITE - Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Read Tasks -------------------------------

    task read_cmd_func;
    begin
        column_burst_order             ;
        if (column_access_valid_q[0] == 2'b01) begin
            for (i=0; i<(burst_length+cas_latency-1); i=i+1) begin
                column_access_valid_q[i] = 2'b00 ;
            end
        end
        column_address_read_queue      ;
        tm_read               = $time  ;
        tm_bank_read[ba]      = $time  ;
        ck_cntr_read          = 0      ;
        ck_cntr_bank_read[ba] = 0      ;
        // read interrupt write ap
        if ((column_access_valid_q[0] == 2'b01) &
            (|ap_set                          )  ) begin
            interrupt_write_ap_n[ba] = 0               ;
            interrupt_bank           = bank_access_q[0];
        end
        // read interrupt read ap
        if ((column_access_valid_q[0] == 2'b10) &
            (|ap_set                          )  ) begin
            interrupt_read_ap_n[ba] = 0               ;
            interrupt_bank          = bank_access_q[0];
        end
    end
    endtask

    task read_err_chk;
    begin
        if (active_bank[ba] == 1'b0) begin
            $sformat (msg, " ERROR: Bank is not Activated for Read, Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
            $sformat (msg, " NOTE : Read command will be ignored :  Bank = %d", ba); NOTE(msg);
            command_sequence_error = 1 ;
        end else begin
            if (($time - tm_bank_activate[ba]) < tRCD) begin
                $sformat (msg, " ERROR: tRCD violation :  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_tRCD, msg);
            end
            if ((ap_set[ba] == 1'b1                  ) &
                (tm_bank_write[ba] > tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Read interrupt Write with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Read command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1 ;
            end
            if ((ap_set[ba] == 1'b1                  ) &
                (tm_bank_write[ba] < tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Read interrupt Read with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Read command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1 ;
            end
        end
    end
    endtask

    task read_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " RD   : READ - Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Write with auto-precharge Tasks -------------------------------

    task write_ap_cmd_func;
    begin
        column_burst_order             ;
        column_address_write_queue     ;
        tm_write               = $time ;
        tm_bank_write[ba]      = $time ;
        ck_cntr_write          = 0     ;
        ck_cntr_bank_write[ba] = 0     ;
        // write ap interrupt write ap
        if ((column_access_valid_q[0] == 2'b01) &
            (|ap_set                          )  ) begin
            interrupt_write_ap_n[ba] = 0               ;
            interrupt_bank           = bank_access_q[0];
        end
        // write ap interrupt read ap
        if ((column_access_valid_q[0] == 2'b10) &
            (|ap_set                          )  ) begin
            interrupt_read_ap_n[ba] = 0               ;
            interrupt_bank          = bank_access_q[0];
        end
        ap_set[ba]             = 1     ;
    end
    endtask

    task write_ap_err_chk;
    begin
        if (active_bank[ba] == 1'b0) begin
            $sformat (msg, " ERROR: Bank is not Activated for Write with autoprecharge, Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
            $sformat (msg, " NOTE : Write with autoprecharge command will be ignored :  Bank = %d", ba); NOTE(msg);
            command_sequence_error = 1'b1 ;
        end else begin
            if (($time - tm_bank_activate[ba]) < tRCD) begin
                $sformat (msg, " ERROR: tRCD violation :  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_tRCD, msg);
            end
            if ((ap_set[ba] == 1'b1        ) &
                (tm_bank_write[ba] > tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Write with autoprecharge  interrupt Write with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Write with autoprecharge command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1'b1 ;
            end
            if ((ap_set[ba] == 1'b1        ) &
                (tm_bank_write[ba] < tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Write with autoprecharge  interrupt Read with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Write with autoprecharge command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1'b1 ;
            end
            if (((dqm_rtw_chk[0] == 1'b1        ) |
                 (dqm_rtw_chk[1] == 1'b1        ) ) &
                (ap_set[ba] == 1'b0               )  ) begin
                $sformat (msg, " ERROR: DQ contention caused by incorrect assertion of data masks during read to write, Bank = %d", ba); ERROR(ERR_CMD, msg);
            end
        end
    end
    endtask

    task write_ap_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " WRAP : WRITE WITH AUTOPRECHARGE - Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Read with auto-precharge Tasks -------------------------------

    task read_ap_cmd_func;
    begin
        column_burst_order             ;
        if (column_access_valid_q[0] == 2'b01) begin
            for (i=0; i<(burst_length+cas_latency-1); i=i+1) begin
                column_access_valid_q[i] = 2'b00 ;
            end
        end
        column_address_read_queue      ;
        tm_read                = $time ;
        tm_bank_read[ba]       = $time ;
        ck_cntr_read           = 0     ;
        ck_cntr_bank_read[ba]  = 0     ;
        // read interrupt write ap
        if ((column_access_valid_q[0] == 2'b01) &
            (bank_access_q[0]    != ba        ) &
            (|ap_set                          )  ) begin
            interrupt_write_ap_n[ba] = 0               ;
            interrupt_bank           = bank_access_q[0];
        end
        // read interrupt read ap
        if ((column_access_valid_q[0] == 2'b10) &
            (bank_access_q[0]    != ba        ) &
            (|ap_set                          )  ) begin
            interrupt_read_ap_n[ba] = 0               ;
            interrupt_bank          = bank_access_q[0];
        end
        ap_set[ba]             = 1     ;
    end
    endtask

    task read_ap_err_chk;
    begin
        if (active_bank[ba] == 1'b0) begin
            $sformat (msg, " ERROR: Bank is not Activated for Read with autoprecharge, Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
            $sformat (msg, " NOTE : Read with autoprecharge command will be ignored :  Bank = %d", ba); NOTE(msg);
            command_sequence_error = 1'b1 ;
        end else begin
            if (($time - tm_bank_activate[ba]) < tRCD) begin
                $sformat (msg, " ERROR: tRCD violation :  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_tRCD, msg);
            end
            if ((ap_set[ba] == 1'b1                  ) &
                (tm_bank_write[ba] > tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Read with autoprecharge interrupt Write with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Read with autoprecharge command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1'b1 ;
            end
            if ((ap_set[ba] == 1'b1                  ) &
                (tm_bank_write[ba] < tm_bank_read[ba])  ) begin
                $sformat (msg, " ERROR: Read with autoprecharge interrupt Read with autoprecharge to the same bank:  Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); ERROR(ERR_CMD, msg);
                $sformat (msg, " NOTE : Read with autoprecharge command will be ignored :  Bank = %d", ba); NOTE(msg);
                command_sequence_error = 1'b1 ;
            end
        end
    end
    endtask

    task read_ap_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " RDAP : READ WITH AUTOPRECHARGE - Bank = %d, Row = %h, Col = %h", ba, activate_row[ba], addr); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Auto-refresh Tasks -------------------------------

    task auto_refresh_cmd_func;
    begin
        tm_auto_refresh      = $time ;
        ck_cntr_auto_refresh = 0     ;
    end
    endtask

    task auto_refresh_err_chk;
    begin
        if (|active_bank) begin
            $sformat (msg, " ERROR: Banks are not precharged for auto refresh"); ERROR(ERR_CMD, msg);
            $sformat (msg, " NOTE : Auto refresh command will be ignored :  Bank = %d", ba); NOTE(msg);
            command_sequence_error = 1'b1 ;
        end else begin
            if (($time - tm_precharge) < tRP) begin
                $sformat (msg, " ERROR: tRP violation during auto refresh"); ERROR(ERR_tRP, msg);
            end
            if (($time - tm_auto_refresh) < tRFC) begin
                $sformat (msg, " ERROR: tRFC violation during auto refresh"); ERROR(ERR_tRFC, msg);
            end
            if (ck_cntr_load_mode < tMRD) begin
                $sformat (msg, " ERROR: tMRD violation during auto refresh"); ERROR(ERR_tMRD, msg);
            end
        end
    end
    endtask

    task auto_refresh_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " AREF : AUTO REFRESH"); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Self-refresh Tasks -------------------------------

    task self_refresh_cmd_func;
    begin
        erase_mem(pasr);
        tm_self_refresh      = $time ;
        ck_cntr_self_refresh = 0     ;
        self_refresh_enter   = 1     ;
    end
    endtask

    task self_refresh_err_chk;
    begin
        if (|active_bank) begin
            $sformat (msg, " ERROR: Banks are not precharged for self refresh command"); ERROR(ERR_CMD, msg);
        end else begin
            if (($time - tm_precharge) < tRP) begin
                $sformat (msg, " ERROR: tRP violation during self refresh command"); ERROR(ERR_tRP, msg);
            end
            if (($time - tm_auto_refresh) < tRFC) begin
                $sformat (msg, " ERROR: tRFC violation during self refresh command"); ERROR(ERR_tRFC, msg);
            end
            if (ck_cntr_load_mode < tMRD) begin
                $sformat (msg, " ERROR: tMRD violation during self refresh command"); ERROR(ERR_tMRD, msg);
            end
        end
    end
    endtask

    task self_refresh_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " SREF : SELF REFRESH"); NOTE(msg);
        end
    end
    endtask

//-------------------------------- ???????????????? -------------------------------


    task clock_suspend_cmd_func;
    begin
        tm_clock_suspend      = $time ;
        ck_cntr_clock_suspend = 0     ;
    end
    endtask

    task clock_suspend_err_chk;
    begin
    end
    endtask

    task clock_suspend_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " CKSM : CLOCK SUSPEND MODE"); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Exit Power Down Tasks -------------------------------

//------------- Parameters (cke, addr[10], cs_n, ras_n, cas_n, we_n) --------------

    task exit_power_down_err_chk;
    begin
        if (cke & ~cke_q) begin
            if ((power_down_enter == 1'b1  ) |
                (self_refresh_enter == 1'b1) ) begin
                if (~( (command == NOP) | 
                       (cke & cs_n    ) ) ) begin
                    $sformat (msg, " ERROR: exit powerdown violation"); ERROR(ERR_CMD, msg);
                end
                power_down_enter = 1'b0;
            end
        end
    end
    endtask

//-------------------------------- Power Down Tasks -------------------------------

    task power_down_cmd_func;
    begin
        tm_power_down      = $time ;
        ck_cntr_power_down = 0     ;
    end
    endtask

    task power_down_err_chk;
    begin
        if (|active_bank) begin
            $sformat (msg, " ERROR: All banks need to be precharged before powerdown"); ERROR(ERR_CMD, msg);
        end else begin
            if (ck_cntr_precharge < 2) begin
                $sformat (msg, " ERROR: precharge to powerdown violation"); ERROR(ERR_MISC, msg);
            end
            if (($time - tm_auto_refresh) < tRFC) begin
                $sformat (msg, " ERROR: tRFC violation"); ERROR(ERR_tRFC, msg);
            end
            if (ck_cntr_load_mode < tMRD) begin
                $sformat (msg, " ERROR: tMRD violation"); ERROR(ERR_tMRD, msg);
            end
            power_down_enter = 1'b1 ;
        end
    end
    endtask

    task power_down_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " PREPD: PRECHARGE POWERDOWN"); NOTE(msg);
        end
    end
    endtask


//-------------------------------- Deep Power Down Tasks -------------------------------

    task deep_power_down_cmd_func;
    begin
        if (cke_q) begin
            erase_mem(0);
        end
        tm_deep_power_down      = $time ;
        ck_cntr_deep_power_down = 0     ;
    end
    endtask

    task deep_power_down_err_chk;
    begin
        if (($time - ck_cntr_precharge) < 2) begin
            $sformat (msg, " ERROR: precharge to deep power down violation"); ERROR(ERR_CMD, msg);
        end
        if (($time - tm_auto_refresh) < tRFC) begin
            $sformat (msg, " ERROR: auto refresh to deep power down violation"); ERROR(ERR_tRFC, msg);
        end
        if (ck_cntr_load_mode < tMRD) begin
            $sformat (msg, " ERROR: load mode to deep power down violation"); ERROR(ERR_tMRD, msg);
        end
    end
    endtask

    task deep_power_down_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " DPD  : DEEP POWERDOWN"); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Deep Power Down Tasks -------------------------------

    task burst_term_cmd_func;
        time tm_bank_burst_term ;
    begin
        tm_bank_burst_term = 0 ;
        for (i=0; i<`BANKS; i=i+1) begin
            if (tm_bank_read[i]  > tm_bank_burst_term) begin
                tm_bank_burst_term    = tm_bank_read[i]  ;
                burst_term_read_queue  ;
            end
            if (tm_bank_write[i] > tm_bank_burst_term) begin
                tm_bank_burst_term    = tm_bank_write[i] ;
                burst_term_write_queue ;
            end
        end
        tm_burst_terminate      = $time ;
        ck_cntr_burst_terminate = 0     ;
    end
    endtask

    task burst_term_err_chk;
    begin
    end
    endtask

    task burst_term_cmd_display;
    begin
        if (DEBUG == 1'b1) begin
            $sformat (msg, " BT   : BURST TERMINATE"); NOTE(msg);
        end
    end
    endtask

//-------------------------------- Exit Power Down (cke high) Tasks -------------------------------

    task cke_cmd_func;
    begin
        if (cke & ~cke_q) begin
            tm_cke      = $time ;
            ck_cntr_cke = 0     ;
        end
    end
    endtask

    task cke_err_chk;
    begin
        if (cke & ~cke_q) begin
            if (tm_cke_high - tm_self_refresh < tRAS) begin
                $sformat (msg, " ERROR: tRAS violation during self refresh command exit"); ERROR(ERR_tRAS, msg);
            end
        end
    end
    endtask

//---------------------- Error count ----------------------

task ERROR;
   input [7:0] errcode;
   input [MSGLENGTH*8:1] msg;
begin

    errcount[errcode] = errcount[errcode] + 1;
    errors = errors + 1;

    if ((errcount[errcode] <= ERR_MAX_REPORTED) || (ERR_MAX_REPORTED < 0))
        if ((EXP_ERR[errcode] === 1) && ((errcount[errcode] <= ERR_MAX_INT) || (ERR_MAX_INT < 0))) begin
            $display("Caught expected violation at time %t: %0s", $time, msg);
        end else begin
            $display("%m at time %t: %0s", $time, msg);
        end
    if (errcount[errcode] == ERR_MAX_REPORTED) begin
        $sformat(msg, "Reporting for %s has been disabled because ERR_MAX_REPORTED has been reached.", err_strings[errcode]);
        NOTE(msg);
    end

    //overall model maximum error limit
    if ((errcount[errcode] > ERR_MAX_INT) && (ERR_MAX_INT >= 0)) begin
        STOP;
    end
end
endtask

//-------------------------------- Display Tasks -------------------------------

    task NOTE;
       input [MSGLENGTH*8:1] msg;
    begin
      $display("%m at time %t: %0s", $time, msg);
    end
    endtask

    task WARN;
       input [MSGLENGTH*8:1] msg;
    begin
      $display("%m at time %t: %0s", $time, msg);
      warnings = warnings + 1;
    end
    endtask

//---------------------------------------------------
// TASK: Stop()
//---------------------------------------------------

    task STOP;
    begin
      $display("%m at time %t: %d warnings, %d errors", $time, warnings, errors);
      $stop(0);
    end
    endtask

//-------------------------------- Memory Storage Tasks -------------------------------

    // Erase Memory
    task erase_mem;
        input integer                 pasr ;
        reg       [part_mem_bits : 0] i;
        reg       [part_mem_bits : 0] j;
        reg       [full_mem_bits : 0] k;
        begin
`ifdef FULL_MEM
            if (pasr == 0) begin
//                for (k = 0; k > {(full_mem_bits){1'b1}}; k = k + 1) begin
//                    mem_array[k] = {DQ_BITS{1'bx}};
//                end
            end else if (pasr == 1) begin
                for (k = {(full_mem_bits){1'b1}}; k > {(full_mem_bits-1){1'b1}}; k = k - 1) begin
                    mem_array[k] = {DQ_BITS{1'bx}};
                end
            end else if (pasr == 2) begin
                for (k = {(full_mem_bits){1'b1}}; k > {(full_mem_bits-2){1'b1}}; k = k - 1) begin
                    mem_array[k] = {DQ_BITS{1'bx}};
                end
            end else if (pasr == 3) begin
                for (k = {(full_mem_bits){1'b1}}; k > {(full_mem_bits-3){1'b1}}; k = k - 1) begin
                    mem_array[k] = {DQ_BITS{1'bx}};
                end
            end else if (pasr == 4) begin
                for (k = {(full_mem_bits){1'b1}}; k > {(full_mem_bits-4){1'b1}}; k = k - 1) begin
                    mem_array[k] = {DQ_BITS{1'bx}};
                end
            end else begin
                for (k = 0; k <= {(full_mem_bits){1'b1}}; k = k + 1) begin
                    mem_array[k] = {DQ_BITS{1'bx}};
                end
                $display ("%m: At time %t ERROR: illegal PASR setting.\n  All Data will be lost.\n", $realtime);
            end
`else
            if (pasr == 0) begin
//                for (i = 0; i < mem_used; i = i + 1) begin
//                    addr_array[i] = {full_mem_bits{1'bx}};
//                    mem_array[i]  = {DQ_BITS{1'bx}};
//                end
            end else if (pasr == 1) begin
                for (i = 0; i < mem_used; i = i + 1) begin
                    if (addr_array[i][full_mem_bits - 1] != 1'b0) begin
                        addr_array[i] = {full_mem_bits{1'bx}};
                        mem_array[i]  = {DQ_BITS{1'bx}};
                    end
                end
            end else if (pasr == 2) begin
                for (i = 0; i < mem_used; i = i + 1) begin
                    if (addr_array[i][full_mem_bits - 1: full_mem_bits - 2] != {2{1'b0}}) begin
                        addr_array[i] = {full_mem_bits{1'bx}};
                        mem_array[i]  = {DQ_BITS{1'bx}};
                    end
                end
            end else if (pasr == 3) begin
                for (i = 0; i < mem_used; i = i + 1) begin
                    if (addr_array[i][full_mem_bits - 1: full_mem_bits - 3] != {3{1'b0}}) begin
                        addr_array[i] = {full_mem_bits{1'bx}};
                        mem_array[i]  = {DQ_BITS{1'bx}};
                    end
                end
            end else if (pasr == 4) begin
                for (i = 0; i < mem_used; i = i + 1) begin
                    if (addr_array[i][full_mem_bits - 1: full_mem_bits - 4] != {4{1'b0}}) begin
                        addr_array[i] = {full_mem_bits{1'bx}};
                        mem_array[i]  = {DQ_BITS{1'bx}};
                    end
                end
            end else begin
                for (i = 0; i < mem_used; i = i + 1) begin
                    addr_array[i] = {full_mem_bits{1'bx}};
                    mem_array[i]  = {DQ_BITS{1'bx}};
                end
                mem_used = 0 ;
                $display ("%m: At time %t ERROR: illegal PASR setting.\n  All Data will be lost.\n", $realtime);
            end
            for (i = 0; i < mem_used; i = i + 1) begin
                if (addr_array[i] === {full_mem_bits{1'bx}}) begin
                    for (j=i; j < mem_used; j=j+1) begin
                        addr_array[j] = addr_array[j+1];
                        mem_array[j]  = mem_array[j+1];
                    end
                    mem_used = mem_used - 1 ;
                    i = i - 1 ;
                end
            end
`endif
        end
    endtask

    // Write Memory
    task write_mem;
        input [full_mem_bits - 1 : 0] address;
        input       [DQ_BITS - 1 : 0] data;
        reg       [part_mem_bits : 0] i;
        begin
`ifdef FULL_MEM
            mem_array[address] = data;
`else
            begin : loop
                for (i = 0; i < mem_used; i = i + 1) begin
                    if (addr_array[i] === address) begin
                        disable loop;
                    end
                end
            end
            if (i === mem_used) begin
                if (i === (1<<part_mem_bits)) begin
                    $display ("%m: At time %t ERROR: Memory overflow.\n  Write to Address %d with Data %d will be lost.\n You must increase the part_mem_bits parameter or `define FULL_MEM.", $realtime, address, data);
                end else begin
                    mem_used = mem_used + 1;
                    addr_array[i] = address;
                end
            end
            mem_array[i] = data;
`endif
        end
    endtask
//test//
    // Read Memory
    task read_mem;
        input [full_mem_bits - 1 : 0] address;
        output      [DQ_BITS - 1 : 0] data;
        reg       [part_mem_bits : 0] i;
        begin
`ifdef FULL_MEM
            data = mem_array[address];
`else
            begin : loop
                for (i = 0; i < mem_used; i = i + 1) begin
                    if (addr_array[i] === address) begin
                        disable loop;
                    end
                end
            end
            if (i <= mem_used) begin
                data = mem_array[i];
            end else begin
                data = 'bx;
            end
`endif
        end
    endtask


//------------- Access Registers --------------

    task clk_access_reg;
    begin
        for (i=0; i<`PAGE_SIZE+2; i=i+1) begin
            bank_access_q[i]         = bank_access_q[i+1]         ;
            row_access_q[i]          = row_access_q[i+1]          ;
            column_access_q[i]       = column_access_q[i+1]       ;
            column_access_valid_q[i] = column_access_valid_q[i+1] ;
        end
        bank_access_q[`PAGE_SIZE+2]         = 'bz   ;
        row_access_q[`PAGE_SIZE+2]          = 'bz   ;
        column_access_q[`PAGE_SIZE+2]       = 'bz   ;
        column_access_valid_q[`PAGE_SIZE+2] = 2'b00 ;
    end
    endtask

//------------- clock counters --------------

    task clk_counters;
    begin
        if ((ck_cntr_self_refresh    + 1) > ck_cntr_self_refresh   ) begin ck_cntr_self_refresh    = ck_cntr_self_refresh    + 1 ; end
        if ((ck_cntr_power_down      + 1) > ck_cntr_power_down     ) begin ck_cntr_power_down      = ck_cntr_power_down      + 1 ; end
        if ((ck_cntr_cke             + 1) > ck_cntr_cke            ) begin ck_cntr_cke             = ck_cntr_cke             + 1 ; end
        if ((ck_cntr_cke_n           + 1) > ck_cntr_cke_n          ) begin ck_cntr_cke_n           = ck_cntr_cke_n           + 1 ; end
        if ((ck_cntr_activate        + 1) > ck_cntr_activate       ) begin ck_cntr_activate        = ck_cntr_activate        + 1 ; end
        if ((ck_cntr_read            + 1) > ck_cntr_read           ) begin ck_cntr_read            = ck_cntr_read            + 1 ; end
        if ((ck_cntr_read_ap         + 1) > ck_cntr_read_ap        ) begin ck_cntr_read_ap         = ck_cntr_read_ap         + 1 ; end
        if ((ck_cntr_write           + 1) > ck_cntr_write          ) begin ck_cntr_write           = ck_cntr_write           + 1 ; end
        if ((ck_cntr_write_ap        + 1) > ck_cntr_write_ap       ) begin ck_cntr_write_ap        = ck_cntr_write_ap        + 1 ; end
        if ((ck_cntr_burst_terminate + 1) > ck_cntr_burst_terminate) begin ck_cntr_burst_terminate = ck_cntr_burst_terminate + 1 ; end
        if ((ck_cntr_precharge       + 1) > ck_cntr_precharge      ) begin ck_cntr_precharge       = ck_cntr_precharge       + 1 ; end
        if ((ck_cntr_auto_refresh    + 1) > ck_cntr_auto_refresh   ) begin ck_cntr_auto_refresh    = ck_cntr_auto_refresh    + 1 ; end
        if ((ck_cntr_load_mode       + 1) > ck_cntr_load_mode      ) begin ck_cntr_load_mode       = ck_cntr_load_mode       + 1 ; end
        for (i=0; i<`BANKS; i=i+1) begin
            if ((ck_cntr_bank_precharge[i] + 1) > ck_cntr_bank_precharge[i]) begin ck_cntr_bank_precharge[i] = ck_cntr_bank_precharge[i] + 1 ; end
            if ((ck_cntr_bank_activate[i]  + 1) > ck_cntr_bank_activate[i] ) begin ck_cntr_bank_activate[i]  = ck_cntr_bank_activate[i]  + 1 ; end
            if ((ck_cntr_bank_write[i]     + 1) > ck_cntr_bank_write[i]    ) begin ck_cntr_bank_write[i]     = ck_cntr_bank_write[i]     + 1 ; end
            if ((ck_cntr_bank_read[i]      + 1) > ck_cntr_bank_read[i]     ) begin ck_cntr_bank_read[i]      = ck_cntr_bank_read[i]      + 1 ; end
            if ((ck_cntr_write_dq[i]       + 1) > ck_cntr_write_dq[i]      ) begin ck_cntr_write_dq[i]       = ck_cntr_write_dq[i]       + 1 ; end
        end
    end
    endtask

//------------- Clock Enable --------------

    always@(posedge cke) begin
        tm_cke_high      = $time ;
        ck_cntr_cke_high = 0     ;
    end

    always@(clk) begin
        if (clk) begin
            clk_counters               ;
            exit_power_down_err_chk    ;
            initialization_cmd_func    ;
            initialization_err_chk     ;
            initialization_cmd_display ;
        end
        clk_stabilization_func     ;
        clk_stabilization_err_chk  ;
        cke_err_chk                ;
        cke_cmd_func               ;
        if (cke_q == 1'b1) begin
            Sys_clk <= clk         ;
        end else begin
            Sys_clk <= 1'b0        ;
        end
        if (clk) begin
            cke_q = cke            ;
        end
    end

//------------- System clock --------------

    always@(posedge Sys_clk) begin
        clk_access_reg;
        active_read_write;
        interrupt_auto_precharge(interrupt_bank);
        auto_precharge_management;
        if (command == ACTIVATE        ) begin activate_err_chk            ; end
        if (command == READ            ) begin read_err_chk                ; end
        if (command == READ_AP         ) begin read_ap_err_chk             ; end
        if (command == READ_SUSPEND    ) begin read_err_chk                ; end
        if (command == READ_AP_SUSPEND ) begin read_ap_err_chk             ; end
        if (command == WRITE           ) begin write_err_chk               ; end
        if (command == WRITE_AP        ) begin write_ap_err_chk            ; end
        if (command == WRITE_SUSPEND   ) begin write_err_chk               ; end
        if (command == WRITE_AP_SUSPEND) begin write_ap_err_chk            ; end
        if (command == BURST_TERMINATE ) begin burst_term_err_chk          ; end
        if (command == AUTO_REFRESH    ) begin auto_refresh_err_chk        ; end
        if (command == PRECHARGE       ) begin precharge_err_chk(ba)       ; end
        if (command == PRECHARGE_ALL   ) begin precharge_all_err_chk       ; end
        if (command == LOAD_MODE       ) begin load_mode_err_chk           ; end
        if ((~read_write_in_progress     ) &
            (command != READ_SUSPEND     ) &
            (command != READ_AP_SUSPEND  ) &
            (command != WRITE_SUSPEND    ) &
            (command != WRITE_AP_SUSPEND )  ) begin
            if (command == SELF_REFRESH    ) begin self_refresh_err_chk    ; end
            if (command == POWER_DOWN_CI   ) begin power_down_err_chk      ; end
            if (command == POWER_DOWN_NOP  ) begin power_down_err_chk      ; end
            if (command == DEEP_POWER_DOWN ) begin deep_power_down_err_chk ; end
        end else begin
            if (command == SELF_REFRESH    ) begin clock_suspend_err_chk   ; end
            if (command == POWER_DOWN_CI   ) begin clock_suspend_err_chk   ; end
            if (command == POWER_DOWN_NOP  ) begin clock_suspend_err_chk   ; end
            if (command == DEEP_POWER_DOWN ) begin clock_suspend_err_chk   ; end
        end
        if (command_sequence_error == 0) begin
            if (command == ACTIVATE              ) begin activate_cmd_func(ba, addr) ; end
            if (command == READ                  ) begin read_cmd_func               ; end
            if (command == READ_AP               ) begin read_ap_cmd_func            ; end
            if (command == READ_SUSPEND          ) begin read_cmd_func               ; end
            if (command == READ_AP_SUSPEND       ) begin read_ap_cmd_func            ; end
            if (command == WRITE                 ) begin write_cmd_func              ; end
            if (command == WRITE_AP              ) begin write_ap_cmd_func           ; end
            if (command == WRITE_SUSPEND         ) begin write_cmd_func              ; end
            if (command == WRITE_AP_SUSPEND      ) begin write_ap_cmd_func           ; end
            if (command == BURST_TERMINATE       ) begin burst_term_cmd_func         ; end
            if (command == AUTO_REFRESH          ) begin auto_refresh_cmd_func       ; end
            if (command == PRECHARGE             ) begin precharge_cmd_func(ba, 0)   ; end
            if (command == PRECHARGE_ALL         ) begin precharge_all_cmd_func      ; end
            if (command == LOAD_MODE             ) begin load_mode_cmd_func          ; end
            if ((~read_write_in_progress     ) &
                (command != READ_SUSPEND     ) &
                (command != READ_AP_SUSPEND  ) &
                (command != WRITE_SUSPEND    ) &
                (command != WRITE_AP_SUSPEND )  ) begin
                if (command == SELF_REFRESH      ) begin self_refresh_cmd_func       ; end
                if (command == POWER_DOWN_CI     ) begin power_down_cmd_func         ; end
                if (command == POWER_DOWN_NOP    ) begin power_down_cmd_func         ; end
                if (command == DEEP_POWER_DOWN   ) begin deep_power_down_cmd_func    ; end
            end else begin
                if (command == SELF_REFRESH      ) begin clock_suspend_cmd_func      ; end
                if (command == POWER_DOWN_CI     ) begin clock_suspend_cmd_func      ; end
                if (command == POWER_DOWN_NOP    ) begin clock_suspend_cmd_func      ; end
                if (command == DEEP_POWER_DOWN   ) begin clock_suspend_cmd_func      ; end
            end

            if ((command == ACTIVATE        ) & (DEBUG == 1'b1)) begin activate_cmd_display            ; end
            if ((command == READ            ) & (DEBUG == 1'b1)) begin read_cmd_display                ; end
            if ((command == READ_AP         ) & (DEBUG == 1'b1)) begin read_ap_cmd_display             ; end
            if ((command == READ_SUSPEND    ) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display       ; end
            if ((command == READ_AP_SUSPEND ) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display       ; end
            if ((command == WRITE           ) & (DEBUG == 1'b1)) begin write_cmd_display               ; end
            if ((command == WRITE_AP        ) & (DEBUG == 1'b1)) begin write_ap_cmd_display            ; end
            if ((command == WRITE_SUSPEND   ) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display       ; end
            if ((command == WRITE_AP_SUSPEND) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display       ; end
            if ((command == BURST_TERMINATE ) & (DEBUG == 1'b1)) begin burst_term_cmd_display          ; end
            if ((command == AUTO_REFRESH    ) & (DEBUG == 1'b1)) begin auto_refresh_cmd_display        ; end
            if ((command == PRECHARGE       ) & (DEBUG == 1'b1)) begin precharge_cmd_display(ba)       ; end
            if ((command == PRECHARGE_ALL   ) & (DEBUG == 1'b1)) begin precharge_all_cmd_display       ; end
            if ((command == LOAD_MODE       ) & (DEBUG == 1'b1)) begin load_mode_cmd_display(ba, addr) ; end
            if ((~read_write_in_progress     ) &
                (command != READ_SUSPEND     ) &
                (command != READ_AP_SUSPEND  ) &
                (command != WRITE_SUSPEND    ) &
                (command != WRITE_AP_SUSPEND )  ) begin
                if ((command == SELF_REFRESH   ) & (DEBUG == 1'b1)) begin self_refresh_cmd_display    ; end
                if ((command == POWER_DOWN_CI  ) & (DEBUG == 1'b1)) begin power_down_cmd_display      ; end
                if ((command == POWER_DOWN_NOP ) & (DEBUG == 1'b1)) begin power_down_cmd_display      ; end
                if ((command == DEEP_POWER_DOWN) & (DEBUG == 1'b1)) begin deep_power_down_cmd_display ; end
            end else begin
                if ((command == SELF_REFRESH   ) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display   ; end
                if ((command == POWER_DOWN_CI  ) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display   ; end
                if ((command == POWER_DOWN_NOP ) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display   ; end
                if ((command == DEEP_POWER_DOWN) & (DEBUG == 1'b1)) begin clock_suspend_cmd_display   ; end
            end
        end
        command_sequence_error = 0 ;
        data_management(Dq_out);
        dqm_q <= dqm ;
        dqm_rtw_chk[1] <= dqm_rtw_chk[0];
        dqm_rtw_chk[0] <= (column_access_valid_q[0] == 2'b10) & (&dqm_q === 1'b0) & (Dq_out !== {DQ_BITS{1'bz}}) ;
    end

    always@(Dq_out) begin
        Dq_buffer_output ;
    end

endmodule


