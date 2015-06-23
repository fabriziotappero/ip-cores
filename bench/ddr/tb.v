/****************************************************************************************
*
*    File Name:  tb.v
*
* Dependencies:  ddr2.v, ddr2_parameters.vh
*
*  Description:  Micron SDRAM DDR2 (Double Data Rate 2) test bench
*
*         Note: -Set simulator resolution to "ps" accuracy
*               -Set Debug = 0 to disable $display messages
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
****************************************************************************************/

// DO NOT CHANGE THE TIMESCALE

`timescale 1ps / 1ps

module tb;

`include "ddr2_parameters.vh"

    // ports
    reg                         ck;
    wire                        ck_n = ~ck;
    reg                         cke;
    reg                         cs_n;
    reg                         ras_n;
    reg                         cas_n;
    reg                         we_n;
    reg           [BA_BITS-1:0] ba;
    reg         [ADDR_BITS-1:0] a;
    wire          [DM_BITS-1:0] dm;
    wire          [DQ_BITS-1:0] dq;
    wire         [DQS_BITS-1:0] dqs;
    wire         [DQS_BITS-1:0] dqs_n;
    wire         [DQS_BITS-1:0] rdqs_n;
    reg                         odt;

    // mode registers
    reg         [ADDR_BITS-1:0] mode_reg0;                                 //Mode Register
    reg         [ADDR_BITS-1:0] mode_reg1;                                 //Extended Mode Register
    wire                  [2:0] cl       = mode_reg0[6:4];                 //CAS Latency
    wire                        bo       = mode_reg0[3];                   //Burst Order
    wire                  [7:0] bl       = (1<<mode_reg0[2:0]);            //Burst Length
    wire                        rdqs_en  = mode_reg1[11];                  //RDQS Enable
    wire                        dqs_n_en = ~mode_reg1[10];                 //dqs# Enable
    wire                  [2:0] al       = mode_reg1[5:3];                 //Additive Latency
    wire                  [3:0] rl       = al + cl;                        //Read Latency
    wire                  [3:0] wl       = al + cl-1'b1;                   //Write Latency
    
    // dq transmit
    reg                         dq_en;
    reg           [DM_BITS-1:0] dm_out;
    reg           [DQ_BITS-1:0] dq_out;
    reg                         dqs_en;
    reg          [DQS_BITS-1:0] dqs_out;
    assign                      dm       = dq_en ? dm_out : {DM_BITS{1'bz}};
    assign                      dq       = dq_en ? dq_out : {DQ_BITS{1'bz}};
    assign                      dqs      = dqs_en ? dqs_out : {DQS_BITS{1'bz}};
    assign                      dqs_n    = (dqs_en & dqs_n_en) ? ~dqs_out : {DQS_BITS{1'bz}};

    // dq receive
    reg           [DM_BITS-1:0] dm_fifo [2*(AL_MAX+CL_MAX)+BL_MAX:0];
    reg           [DQ_BITS-1:0] dq_fifo [2*(AL_MAX+CL_MAX)+BL_MAX:0];
    wire          [DQ_BITS-1:0] q0, q1, q2, q3;
    reg                   [1:0] burst_cntr;
    assign                      rdqs_n   = {DQS_BITS{1'bz}};

    // timing definition in tCK units
    real                        tck;
    wire                 [11:0] taa      = ceil(CL_TIME/tck);
    wire                 [11:0] tanpd    = TANPD;
    wire                 [11:0] taond    = TAOND;
    wire                 [11:0] taofd    = ceil(TAOFD);
    wire                 [11:0] taxpd    = TAXPD;
    wire                 [11:0] tccd     = TCCD;
    wire                 [11:0] tcke     = TCKE;
    wire                 [11:0] tdllk    = TDLLK;
    wire                 [11:0] tfaw     = ceil(TFAW/tck);
    wire                 [11:0] tmod     = ceil(TMOD/tck);
    wire                 [11:0] tmrd     = TMRD;
    wire                 [11:0] tras     = ceil(TRAS_MIN/tck);
    wire                 [11:0] trc      = TRC;
    wire                 [11:0] trcd     = ceil(TRCD/tck);
    wire                 [11:0] trfc     = ceil(TRFC_MIN/tck);
    wire                 [11:0] trp      = ceil(TRP/tck);
    wire                 [11:0] trrd     = ceil(TRRD/tck);
    wire                 [11:0] trtp     = ceil(TRTP/tck);
    wire                 [11:0] twr      = ceil(TWR/tck);
    wire                 [11:0] twtr     = ceil(TWTR/tck);
    wire                 [11:0] txard    = TXARD;
    wire                 [11:0] txards   = TXARDS;
    wire                 [11:0] txp      = TXP;
    wire                 [11:0] txsnr    = ceil(TXSNR/tck);
    wire                 [11:0] txsrd    = TXSRD;

    initial begin
        $timeformat (-9, 1, " ns", 1);
`ifdef period
        tck <= `period; 
`else
        tck <= TCK_MIN;
`endif
        ck <= 1'b1;
    end

    // component instantiation
    ddr2 sdramddr2 (
        ck, 
        ck_n, 
        cke, 
        cs_n, 
        ras_n, 
        cas_n, 
        we_n, 
        dm, 
        ba, 
        a, 
        dq, 
        dqs,
        dqs_n,
        rdqs_n,
        odt
    );

    // clock generator
    always @(posedge ck) begin
      ck <= #(tck/2) 1'b0;
      ck <= #(tck) 1'b1;
    end

    function integer ceil;
        input number;
        real number;
        if (number > $rtoi(number))
            ceil = $rtoi(number) + 1;
        else
            ceil = number;
    endfunction

    function integer max;
        input arg1;
        input arg2;
        integer arg1;
        integer arg2;
        if (arg1 > arg2)
            max = arg1;
        else
            max = arg2;
    endfunction

    task power_up;
        begin
            cke    <= 1'b0;
            odt    <= 1'b0;
            repeat(10) @(negedge ck);
            cke    <= 1'b1;
            nop (400000/tck+1);
        end
    endtask

    task load_mode;
        input   [BA_BITS-1:0] bank;
        input [ADDR_BITS-1:0] addr;
        begin
            case (bank)
                0: mode_reg0 = addr;
                1: mode_reg1 = addr;
            endcase
            cke   <= 1'b1;
            cs_n  <= 1'b0;
            ras_n <= 1'b0;
            cas_n <= 1'b0;
            we_n  <= 1'b0;
            ba    <= bank;
            a     <= addr;
            @(negedge ck);
        end
    endtask

    task refresh;
        begin
            cke   <= 1'b1;
            cs_n  <= 1'b0;
            ras_n <= 1'b0;
            cas_n <= 1'b0;
            we_n  <= 1'b1;
            @(negedge ck);
        end
    endtask
     
    task precharge;
        input [BA_BITS-1:0] bank;
        input               ap; //precharge all
        begin
            cke   <= 1'b1;
            cs_n  <= 1'b0;
            ras_n <= 1'b0;
            cas_n <= 1'b1;
            we_n  <= 1'b0;
            ba    <= bank;
            a     <= (ap<<10);
            @(negedge ck);
        end
    endtask
     
    task activate;
        input   [BA_BITS-1:0] bank;
        input  [ROW_BITS-1:0] row;
        begin
            cke   <= 1'b1;
            cs_n  <= 1'b0;
            ras_n <= 1'b0;
            cas_n <= 1'b1;
            we_n  <= 1'b1;
            ba    <= bank;
            a     <=  row;
            @(negedge ck);
        end
    endtask

    //write task supports burst lengths <= 8
    task write;
        input   [BA_BITS-1:0] bank;
        input  [COL_BITS-1:0] col;
        input                 ap; //Auto Precharge
        input [8*DM_BITS-1:0] dm;
        input [8*DQ_BITS-1:0] dq;
        reg   [ADDR_BITS-1:0] atemp [1:0];
        integer i;
        begin
            cke   <= 1'b1;
            cs_n  <= 1'b0;
            ras_n <= 1'b1;
            cas_n <= 1'b0;
            we_n  <= 1'b0;
            ba    <= bank;
            atemp[0] = col & 10'h3ff;   //addr[ 9: 0] = COL[ 9: 0]
            atemp[1] = (col>>10)<<11;   //addr[ N:11] = COL[ N:10]
            a     <= atemp[0] | atemp[1] | (ap<<10);
            for (i=0; i<=bl; i=i+1) begin

                dqs_en <= #(wl*tck + i*tck/2) 1'b1;
                if (i%2 == 0) begin
                    dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b0}};
                end else begin
                    dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b1}};
                end

                dq_en  <= #(wl*tck + i*tck/2 + tck/4) 1'b1;
                dm_out <= #(wl*tck + i*tck/2 + tck/4) dm>>i*DM_BITS;
                dq_out <= #(wl*tck + i*tck/2 + tck/4) dq>>i*DQ_BITS;
            end
            dqs_en <= #(wl*tck + bl*tck/2 + tck/2) 1'b0;
            dq_en  <= #(wl*tck + bl*tck/2 + tck/4) 1'b0;
            @(negedge ck);  
        end
    endtask

    // read without data verification
    task read;
        input    [BA_BITS-1:0] bank;
        input   [COL_BITS-1:0] col;
        input                  ap; //Auto Precharge
        reg    [ADDR_BITS-1:0] atemp [1:0];
        begin
            cke   <= 1'b1;
            cs_n  <= 1'b0;
            ras_n <= 1'b1;
            cas_n <= 1'b0;
            we_n  <= 1'b1;
            ba    <= bank;
            atemp[0] = col & 10'h3ff;   //addr[ 9: 0] = COL[ 9: 0]
            atemp[1] = (col>>10)<<11;   //addr[ N:11] = COL[ N:10]
            a     <= atemp[0] | atemp[1] | (ap<<10);
            @(negedge ck);
        end
    endtask

    task nop;
        input [31:0] count;
        begin
            cke   <= 1'b1;
            cs_n  <= 1'b0;
            ras_n <= 1'b1;
            cas_n <= 1'b1;
            we_n  <= 1'b1;
            repeat(count) @(negedge ck);
        end
    endtask

    task deselect;
        input [31:0] count;
        begin
            cke   <= 1'b1;
            cs_n  <= 1'b1;
            ras_n <= 1'b1;
            cas_n <= 1'b1;
            we_n  <= 1'b1;
            repeat(count) @(negedge ck);
        end
    endtask

    task power_down;
        input [31:0] count;
        begin
            cke   <= 1'b0;
            cs_n  <= 1'b1;
            ras_n <= 1'b1;
            cas_n <= 1'b1;
            we_n  <= 1'b1;
            repeat(count) @(negedge ck);
        end
    endtask

    task self_refresh;
        input [31:0] count;
        begin
            cke   <= 1'b0;
            cs_n  <= 1'b0;
            ras_n <= 1'b0;
            cas_n <= 1'b0;
            we_n  <= 1'b1;
            cs_n  <= #(tck) 1'b1;
            ras_n <= #(tck) 1'b1;
            cas_n <= #(tck) 1'b1;
            we_n  <= #(tck) 1'b1;
            repeat(count) @(negedge ck);
        end
    endtask

    // read with data verification
    task read_verify;
        input   [BA_BITS-1:0] bank;
        input  [COL_BITS-1:0] col;
        input                 ap; //Auto Precharge
        input [8*DM_BITS-1:0] dm; //Expected Data Mask
        input [8*DQ_BITS-1:0] dq; //Expected Data
        integer i;
        begin
            read (bank, col, ap);
            for (i=0; i<bl; i=i+1) begin
                dm_fifo[2*rl + i] = dm >> (i*DM_BITS);
                dq_fifo[2*rl + i] = dq >> (i*DQ_BITS);
            end
        end
    endtask

    // receiver(s) for data_verify process
    dqrx dqrx[DQS_BITS-1:0] (dqs, dq, q0, q1, q2, q3);

    // perform data verification as a result of read_verify task call
    always @(ck) begin:data_verify
        integer i;
        integer j;
        reg [DQ_BITS-1:0] bit_mask;
        reg [DM_BITS-1:0] dm_temp;
        reg [DQ_BITS-1:0] dq_temp;
        
        for (i = !ck; (i < 2/(2.0 - !ck)); i=i+1) begin
            if (dm_fifo[i] === {DM_BITS{1'bx}}) begin
                burst_cntr = 0;
            end else begin

                dm_temp = dm_fifo[i];
                for (j=0; j<DQ_BITS; j=j+1) begin
                    bit_mask[j] = !dm_temp[j/8];
                end

                case (burst_cntr)
                    0: dq_temp =  q0;
                    1: dq_temp =  q1;
                    2: dq_temp =  q2;
                    3: dq_temp =  q3;
                endcase
                //if ( ((dq_temp & bit_mask) === (dq_fifo[i] & bit_mask)))
                //    $display ("%m at time %t: INFO: Successful read data compare.  Expected = %h, Actual = %h, Mask = %h, i = %d", $time, dq_fifo[i], dq_temp, bit_mask, burst_cntr);
                if ((dq_temp & bit_mask) !== (dq_fifo[i] & bit_mask))
                    $display ("%m at time %t: ERROR: Read data miscompare.  Expected = %h, Actual = %h, Mask = %h, i = %d", $time, dq_fifo[i], dq_temp, bit_mask, burst_cntr);

                burst_cntr = burst_cntr + 1;
            end
        end

        if (ck) begin
            if (dm_fifo[2] === {DM_BITS{1'bx}}) begin
                dqrx[0%DQS_BITS].ptr <= 0; // v2k syntax
                dqrx[1%DQS_BITS].ptr <= 0; // v2k syntax
                dqrx[2%DQS_BITS].ptr <= 0; // v2k syntax
                dqrx[3%DQS_BITS].ptr <= 0; // v2k syntax
            end
        end else begin
            for (i=0; i<=(2*(AL_MAX+CL_MAX)+BL_MAX); i=i+1) begin
                dm_fifo[i] = dm_fifo[i+2];
                dq_fifo[i] = dq_fifo[i+2];
            end
        end
    end

    // End-of-test triggered in 'subtest.vh'
    task test_done;
        begin
            $display ("%m at time %t: INFO: Simulation is Complete", $time);
            $stop(0);
        end
    endtask

    // Test included from external file
    `include "subtest.vh"

endmodule

module dqrx (
    dqs, dq, q0, q1, q2, q3
);

    `include "ddr2_parameters.vh"

    input  dqs;
    input  [DQ_BITS/DQS_BITS-1:0] dq;
    output [DQ_BITS/DQS_BITS-1:0] q0;
    output [DQ_BITS/DQS_BITS-1:0] q1;
    output [DQ_BITS/DQS_BITS-1:0] q2;
    output [DQ_BITS/DQS_BITS-1:0] q3;

    reg [DQ_BITS/DQS_BITS-1:0] q [3:0];

    assign q0  = q[0];
    assign q1  = q[1];
    assign q2  = q[2];
    assign q3  = q[3];

    reg [1:0] ptr;
    reg dqs_q;

    always @(dqs) begin
        if (dqs ^ dqs_q) begin
            #(TDQSQ + 1);
            q[ptr] <= dq;
            ptr <= (ptr + 1)%4;
        end
        dqs_q <= dqs;
    end
    
endmodule
