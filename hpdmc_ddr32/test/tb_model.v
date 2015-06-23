/****************************************************************************************
*
*    File Name:  tb.v
*      Version:  5.7
*        Model:  BUS Functional
*
* Dependencies:  ddr.v, ddr_parameters.v
*
*  Description:  Micron SDRAM DDR (Double Data Rate) test bench
*
*         Note:  - Set simulator resolution to "ps" accuracy
*                - Set Debug = 0 to disable $display messages
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
*                Copyright 2003 Micron Technology, Inc. All rights reserved.
*
* Rev  Author Date        Changes
* --------------------------------------------------------------------------------
* 2.1  SPH    03/19/2002  - Second Release
*                         - Fix tWR and several incompatability
*                           between different simulators
* 3.0  TFK    02/18/2003  - Added tDSS and tDSH timing checks.
*                         - Added tDQSH and tDQSL timing checks.
* 3.1  CAH    05/28/2003  - update all models to release version 3.1
*                           (no changes to this model)
* 3.2  JMK    06/16/2003  - updated all DDR400 models to support CAS Latency 3
* 3.3  JMK    09/11/2003  - Added initialization sequence checks.
* 4.0  JMK    12/01/2003  - Grouped parameters into "ddr_parameters.v"
*                         - Fixed tWTR check
* 4.1  JMK    01/14/2001  - Grouped specify parameters by speed grade
*                         - Fixed mem_sizes parameter
* 4.2  JMK    03/19/2004  - Fixed pulse width checking on Dqs
* 4.3  JMK    04/27/2004  - Changed BL wire size in tb module
*                         - Changed Dq_buf size to [15:0]
* 5.0  JMK    06/16/2004  - Added read to write checking.
*                         - Added read with precharge truncation to write checking.
*                         - Added associative memory array to reduce memory consumption.
*                         - Added checking for required DQS edges during write.
* 5.1  JMK    08/16/2004  - Fixed checking for required DQS edges during write.
*                         - Fixed wdqs_valid window.
* 5.2  JMK    09/24/2004  - Read or Write without activate will be ignored.
* 5.3  JMK    10/27/2004  - Added tMRD checking during Auto Refresh and Activate.
*                         - Added tRFC checking during Load Mode and Precharge.
* 5.4  JMK    12/13/2004  - The model will not respond to illegal command sequences.
* 5.5  SPH    01/13/2005  - The model will issue a halt on illegal command sequences.
*      JMK    02/11/2005  - Changed the display format for numbers to hex.
* 5.6  JMK    04/22/2005  - Fixed Write with auto precharge calculation.
* 5.7  JMK    08/05/2005  - Changed conditions for read with precharge truncation error.
*                         - Renamed parameters file with .vh extension.
* 5.8  BAS    12/26/2006  - Added parameters for T46A part - 256Mb
*                         - Added x32 functionality
* 6.0  BAS    05/31/2007  - Added read_verify command
****************************************************************************************/

`timescale 1ns / 1ps

module tb;

`include "ddr_parameters.vh"

    reg                         clk         ;
    reg                         clk_n       ;
    reg                         cke         ;
    reg                         cs_n        ;
    reg                         ras_n       ;
    reg                         cas_n       ;
    reg                         we_n        ;
    reg       [BA_BITS - 1 : 0] ba          ;
    reg     [ADDR_BITS - 1 : 0] a           ;
    reg                         dq_en       ;
    reg       [DM_BITS - 1 : 0] dm_out      ;
    reg       [DQ_BITS - 1 : 0] dq_out      ;
    reg         [DM_BITS-1 : 0] dm_fifo [0 : 13];
    reg         [DQ_BITS-1 : 0] dq_fifo [0 : 13];
    reg         [DQ_BITS-1 : 0] dq_in_pos   ;
    reg         [DQ_BITS-1 : 0] dq_in_neg   ;
    reg                         dqs_en      ;
    reg      [DQS_BITS - 1 : 0] dqs_out     ;

    reg                [12 : 0] mode_reg    ;                   //Mode Register
    reg                [12 : 0] ext_mode_reg;                   //Extended Mode Register

    wire                        BO       = mode_reg[3];         //Burst Order
    wire                [7 : 0] BL       = (1<<mode_reg[2:0]);  //Burst Length
// XXX modification by lekernel - removed CL2.5 support which crashes free simulators
// can be rewritten to make it work, but as CL2.5 is not used by Milkymist I'm lazy :)
// was   wire                [2 : 0] CL       = (mode_reg[6:4] == 3'b110) ? 2.5 : mode_reg[6:4]; //CAS Latency
    wire                [2 : 0] CL       = mode_reg[6:4]; //CAS Latency
    wire                        dqs_n_en = ~ext_mode_reg[10];   //dqs# Enable
    wire                [2 : 0] AL       = ext_mode_reg[5:3];   //Additive Latency
    wire                [3 : 0] RL       = CL               ;   //Read Latency
    wire                [3 : 0] WL       = 1                ;   //Write Latency

    wire      [DM_BITS - 1 : 0] dm       = dq_en ? dm_out : {DM_BITS{1'bz}};
    wire      [DQ_BITS - 1 : 0] dq       = dq_en ? dq_out : {DQ_BITS{1'bz}};
    wire     [DQS_BITS - 1 : 0] dqs      = dqs_en ? dqs_out : {DQS_BITS{1'bz}};
    wire     [DQS_BITS - 1 : 0] dqs_n    = (dqs_en & dqs_n_en) ? ~dqs_out : {DQS_BITS{1'bz}};
    wire     [DQS_BITS - 1 : 0] rdqs_n   = {DM_BITS{1'bz}};

    wire               [15 : 0] dqs_in   = dqs;
    wire               [63 : 0] dq_in    = dq;

    ddr sdramddr (
        clk     , 
        clk_n   , 
        cke     , 
        cs_n    , 
        ras_n   , 
        cas_n   , 
        we_n    , 
        ba      , 
        a       , 
        dm      , 
        dq      , 
        dqs       
    );

    // timing definition in tCK units
    real    tck   ;
    integer tmrd  ;
    integer trap  ;
    integer tras  ;
	integer trc   ;
    integer trfc  ;
    integer trcd  ;
    integer trp   ;
	integer trrd  ;
	integer twr   ;

    initial begin
`ifdef period
        tck = `period ; 
`else
        tck =  tCK;
`endif
        tmrd   = ciel(tMRD/tck);
        trap   = ciel(tRAP/tck);
        tras   = ciel(tRAS/tck);
        trc    = ciel(tRC/tck);
        trfc   = ciel(tRFC/tck);
        trcd   = ciel(tRCD/tck);
        trp    = ciel(tRP/tck);
	    trrd   = ciel(tRRD/tck);
	    twr    = ciel(tWR/tck);
    end
 
    initial clk <= 1'b1;
    initial clk_n <= 1'b0;
    always @(posedge clk) begin
      clk   <= #(tck/2) 1'b0;
      clk_n <= #(tck/2) 1'b1;
      clk   <= #(tck) 1'b1;
      clk_n <= #(tck) 1'b0;
    end

    function integer ciel;
        input number;
        real number;
        if (number > $rtoi(number))
            ciel = $rtoi(number) + 1;
        else
            ciel = number;
    endfunction

    task power_up;
        begin
            cke    <=  1'b0;
            repeat(10) @(negedge clk);
            $display ("%m at time %t TB:  A 200 us delay is required before CKE can be brought high.", $time);
            @ (negedge clk) cke     =  1'b1;
            nop (400/tck+1);
        end
    endtask

    task load_mode;
        input [BA_BITS - 1 : 0] bank;
        input [ADDR_BITS - 1 : 0] addr;
        begin
            case (bank)
                0:     mode_reg = addr;
                1: ext_mode_reg = addr;
            endcase
            cke     = 1'b1;
            cs_n    = 1'b0;
            ras_n   = 1'b0;
            cas_n   = 1'b0;
            we_n    = 1'b0;
            ba      = bank;
            a       = addr;
            @(negedge clk);
        end
    endtask

    task refresh;
        begin
            cke     =  1'b1;
            cs_n    =  1'b0;
            ras_n   =  1'b0;
            cas_n   =  1'b0;
            we_n    =  1'b1;
            @(negedge clk);
        end
    endtask
     
    task burst_term;
        integer i;
        begin
            cke     = 1'b1;
            cs_n    = 1'b0;
            ras_n   = 1'b1;
            cas_n   = 1'b1;
            we_n    = 1'b0;
            @(negedge clk);
            for (i=0; i<BL; i=i+1) begin
                dm_fifo[2*RL + i] = {DM_BITS{1'bz}} ;
                dq_fifo[2*RL + i] = {DQ_BITS{1'bz}} ;
            end
        end
    endtask

    task self_refresh;
        input count;
        integer count;
        begin
            cke     =  1'b0;
            cs_n    =  1'b0;
            ras_n   =  1'b0;
            cas_n   =  1'b0;
            we_n    =  1'b1;
            repeat(count) @(negedge clk);
        end
    endtask

    task precharge;
        input       [BA_BITS - 1 : 0] bank;
        input       ap; //precharge all
        begin
            cke     = 1'b1;
            cs_n    = 1'b0;
            ras_n   = 1'b0;
            cas_n   = 1'b1;
            we_n    = 1'b0;
            ba      = bank;
            a       = (ap<<10);
            @(negedge clk);
        end
    endtask
     
    task activate;
        input [BA_BITS - 1 : 0] bank;
        input [ADDR_BITS - 1 : 0] row;
        begin
            cke     = 1'b1;
            cs_n    = 1'b0;
            ras_n   = 1'b0;
            cas_n   = 1'b1;
            we_n    = 1'b1;
            ba      =   bank;
            a    =  row;
            @(negedge clk);
        end
    endtask

    //write task supports burst lengths <= 16
    task write;
        input   [BA_BITS - 1 : 0] bank;
        input   [COL_BITS - 1 : 0] col;
        input                      ap; //Auto Precharge
        input [16*DM_BITS - 1 : 0] dm;
        input [16*DQ_BITS - 1 : 0] dq;
        reg    [ADDR_BITS - 1 : 0] atemp [1:0];
        reg      [DQ_BITS/DM_BITS - 1 : 0] dm_temp;
        integer i,j;
        begin
               cke     = 1'b1;
               cs_n    = 1'b0;
               ras_n   = 1'b1;
               cas_n   = 1'b0;
               we_n    = 1'b0;
               ba      =   bank;
               atemp[0] = col & 10'h3ff;   //ADDR[ 9: 0] = COL[ 9: 0]
               atemp[1] = (col>>10)<<11;   //ADDR[ N:11] = COL[ N:10]
               a = atemp[0] | atemp[1] | (ap<<10);
               
               for (i=0; i<=BL; i=i+1) begin
                	dqs_en <= #(WL*tck + i*tck/2) 1'b1;
                		if (i%2 === 0) begin
                    		dqs_out <= #(WL*tck + i*tck/2) {DQS_BITS{1'b0}};
                		end else begin
                   			 dqs_out <= #(WL*tck + i*tck/2) {DQS_BITS{1'b1}};
  	           end
  	              dq_en  <= #(WL*tck + i*tck/2 + tck/4) 1'b1;
                for (j=0; j<DM_BITS; j=j+1) begin
                    dm_temp = dm>>((i*DM_BITS + j)*DQ_BITS/DM_BITS);
                    dm_out[j] <= #(WL*tck + i*tck/2 + tck/4) &dm_temp;
                end
                dq_out <= #(WL*tck + i*tck/2 + tck/4) dq>>i*DQ_BITS;
                case (i)
                    15: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[16*DM_BITS-1 : 15*DM_BITS];
                    14: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[15*DM_BITS-1 : 14*DM_BITS];
                    13: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[14*DM_BITS-1 : 13*DM_BITS];
                    12: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[13*DM_BITS-1 : 12*DM_BITS];
                    11: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[12*DM_BITS-1 : 11*DM_BITS];
                    10: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[11*DM_BITS-1 : 10*DM_BITS];
                     9: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[10*DM_BITS-1 :  9*DM_BITS];
                     8: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 9*DM_BITS-1 :  8*DM_BITS];
                     7: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 8*DM_BITS-1 :  7*DM_BITS];
                     6: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 7*DM_BITS-1 :  6*DM_BITS];
                     5: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 6*DM_BITS-1 :  5*DM_BITS];
                     4: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 5*DM_BITS-1 :  4*DM_BITS];
                     3: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 4*DM_BITS-1 :  3*DM_BITS];
                     2: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 3*DM_BITS-1 :  2*DM_BITS];
                     1: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 2*DM_BITS-1 :  1*DM_BITS];
                     0: dm_out <= #(WL*tck + i*tck/2 + tck/4) dm[ 1*DM_BITS-1 :  0*DM_BITS];
                endcase
                case (i)
                    15: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[16*DQ_BITS-1 : 15*DQ_BITS];
                    14: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[15*DQ_BITS-1 : 14*DQ_BITS];
                    13: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[14*DQ_BITS-1 : 13*DQ_BITS];
                    12: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[13*DQ_BITS-1 : 12*DQ_BITS];
                    11: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[12*DQ_BITS-1 : 11*DQ_BITS];
                    10: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[11*DQ_BITS-1 : 10*DQ_BITS];
                     9: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[10*DQ_BITS-1 :  9*DQ_BITS];
                     8: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 9*DQ_BITS-1 :  8*DQ_BITS];
                     7: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 8*DQ_BITS-1 :  7*DQ_BITS];
                     6: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 7*DQ_BITS-1 :  6*DQ_BITS];
                     5: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 6*DQ_BITS-1 :  5*DQ_BITS];
                     4: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 5*DQ_BITS-1 :  4*DQ_BITS];
                     3: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 4*DQ_BITS-1 :  3*DQ_BITS];
                     2: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 3*DQ_BITS-1 :  2*DQ_BITS];
                     1: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 2*DQ_BITS-1 :  1*DQ_BITS];
                     0: dq_out <= #(WL*tck + i*tck/2 + tck/4) dq[ 1*DQ_BITS-1 :  0*DQ_BITS];
                endcase
                dq_en  <= #(WL*tck + i*tck/2 + tck/4) 1'b1;
            end
            dqs_en <= #(WL*tck + BL*tck/2 + tck/2) 1'b0;
            dq_en  <= #(WL*tck + BL*tck/2 + tck/4) 1'b0;
            @(negedge clk);  
        end
    endtask

    task read;
        input   [BA_BITS - 1 : 0]bank;
        input   [COL_BITS - 1 : 0] col;
        input                      ap; //Auto Precharge
        reg    [ADDR_BITS - 1 : 0] atemp [1:0];
        begin
            cke     = 1'b1;
            cs_n    = 1'b0;
            ras_n   = 1'b1;
            cas_n   = 1'b0;
            we_n    = 1'b1;
            ba      =   bank;
            atemp[0] = col & 10'h3ff;   //ADDR[ 9: 0] = COL[ 9: 0]
            atemp[1] = (col>>10)<<11;   //ADDR[ N:11] = COL[ N:10]
            a = atemp[0] | atemp[1] | (ap<<10);
            @(negedge clk);
        end
    endtask

    // read with data verification
    task read_verify;
        input   [BA_BITS - 1 : 0] bank;
        input   [COL_BITS - 1 : 0] col;
        input                      ap; //Auto Precharge
        input [16*DM_BITS - 1 : 0] dm; //Expected Data Mask
        input [16*DQ_BITS - 1 : 0] dq; //Expected Data
        integer i;
        reg                  [2:0] brst_col;
        begin
            read (bank, col, ap);
            for (i=0; i<BL; i=i+1) begin
                // perform burst ordering
                brst_col = col ^ i;
                if (!BO) begin
                    brst_col = col + i;
                end
                if (BL == 4) begin
                    brst_col[2] = 1'b0 ;
                end else if (BL == 2) begin
                    brst_col[2:1] = 2'b00 ;
                end
                dm_fifo[2*RL + i] = dm >> (i*DM_BITS);
                dq_fifo[2*RL + i] = dq >> (i*DQ_BITS);
            end
        end
    endtask

    task nop;
        input  count;
        integer count;
        begin
            cke     =  1'b1;
            cs_n    =  1'b0;
            ras_n   =  1'b1;
            cas_n   =  1'b1;
            we_n    =  1'b1;
            repeat(count) @(negedge clk);
        end
    endtask

    task deselect;
        input  count;
        integer count;
        begin
            cke     =  1'b1;
            cs_n    =  1'b1;
            ras_n   =  1'b1;
            cas_n   =  1'b1;
            we_n    =  1'b1;
            repeat(count) @(negedge clk);
        end
    endtask

    task power_down;
        input  count;
        integer count;
        begin
            cke     =  1'b0;
            cs_n    =  1'b1;
            ras_n   =  1'b1;
            cas_n   =  1'b1;
            we_n    =  1'b1;
            repeat(count) @(negedge clk);
        end
    endtask

    function [16*DQ_BITS - 1 : 0] sort_data;
        input [16*DQ_BITS - 1 : 0] dq;
        input [2:0] col;
        integer i;
        reg   [2:0] brst_col;
        reg   [DQ_BITS - 1 :0] burst;
        begin
            sort_data = 0;
            for (i=0; i<BL; i=i+1) begin
                // perform burst ordering
                brst_col = col ^ i;
                if (!BO) begin
                    brst_col[1:0] = col + i;
                end
                burst = dq >> (brst_col*DQ_BITS);
                sort_data = sort_data | burst<<(i*DQ_BITS);
            end
        end
    endfunction

    // receiver(s) for data_verify process
    always @(dqs_in[0]) begin #(tDQSQ); dqs_receiver(0); end
    always @(dqs_in[1]) begin #(tDQSQ); dqs_receiver(1); end
    always @(dqs_in[2]) begin #(tDQSQ); dqs_receiver(2); end
    always @(dqs_in[3]) begin #(tDQSQ); dqs_receiver(3); end
    always @(dqs_in[4]) begin #(tDQSQ); dqs_receiver(4); end
    always @(dqs_in[5]) begin #(tDQSQ); dqs_receiver(5); end
    always @(dqs_in[6]) begin #(tDQSQ); dqs_receiver(6); end
    always @(dqs_in[7]) begin #(tDQSQ); dqs_receiver(7); end

    task dqs_receiver;
    input i;
    integer i;
    begin
        if (dqs_in[i]) begin
            case (i)
                0: dq_in_pos[ 7: 0] <= dq_in[ 7: 0];
                1: dq_in_pos[15: 8] <= dq_in[15: 8];
/*                2: dq_in_pos[23:16] <= dq_in[23:16];
                3: dq_in_pos[31:24] <= dq_in[31:24];
                4: dq_in_pos[39:32] <= dq_in[39:32];
                5: dq_in_pos[47:40] <= dq_in[47:40];
                6: dq_in_pos[55:48] <= dq_in[55:48];
                7: dq_in_pos[63:56] <= dq_in[63:56];*/
            endcase
        end else if (!dqs_in[i]) begin
            case (i)
                0: dq_in_neg[ 7: 0] <= dq_in[ 7: 0];
                1: dq_in_neg[15: 8] <= dq_in[15: 8];
/*                2: dq_in_neg[23:16] <= dq_in[23:16];
                3: dq_in_neg[31:24] <= dq_in[31:24];
                4: dq_in_pos[39:32] <= dq_in[39:32];
                5: dq_in_pos[47:40] <= dq_in[47:40];
                6: dq_in_pos[55:48] <= dq_in[55:48];
                7: dq_in_pos[63:56] <= dq_in[63:56];*/
            endcase
        end
    end
    endtask

     
    // perform data verification as a result of read_verify task call
    always @(clk) begin : data_verify
        integer i;
        reg [DM_BITS-1 : 0] data_mask;
        reg [8*DM_BITS-1 : 0] bit_mask;
        
        for (i=0; i<=14; i=i+1) begin
            dm_fifo[i] = dm_fifo[i+1];
            dq_fifo[i] = dq_fifo[i+1];
        end
        dm_fifo[13] = 'bz;
        dq_fifo[13] = 'bz;
//        dm_fifo[30] = 0;
//        dq_fifo[30] = 0;
        data_mask = dm_fifo[0];

        data_mask = dm_fifo[0];
       for (i=0; i<DM_BITS; i=i+1) begin
            bit_mask = {bit_mask, {8{~data_mask[i]}}};
       end
        if (clk) begin
            if ((dq_in_neg & bit_mask) != (dq_fifo[0] & bit_mask))
                $display ("%m at time %t: ERROR: Read data miscompare: Expected = %h, Actual = %h, Mask = %h", $time, dq_fifo[0], dq_in_neg, bit_mask);
        end else begin
            if ((dq_in_pos & bit_mask) != (dq_fifo[0] & bit_mask))
                $display ("%m at time %t: ERROR: Read data miscompare: Expected = %h, Actual = %h, Mask = %h", $time, dq_fifo[0], dq_in_pos, bit_mask);
        end
    end
 


    reg test_done;
	initial test_done = 0;

    // End-of-test triggered in 'subtest.vh'
    always @(test_done) begin : all_done
		if (test_done == 1) begin
      #5000
			$display ("Simulation is Complete");
			$stop(0);
			$finish;
		end
	end

	// Test included from external file
    `include "subtest.vh"
   
endmodule
