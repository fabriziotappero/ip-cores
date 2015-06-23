//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "wb_bus_mon.v"                                    ////
////                                                              ////
////  This file is part of the "PCI bridge" project               ////
////  http://www.opencores.org/cores/pci/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - mihad@opencores.org                                   ////
////      - Miha Dolenc                                           ////
////                                                              ////
////  All additional information is avaliable in the README.pdf   ////
////  file.                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Miha Dolenc, mihad@opencores.org          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2002/10/09 13:16:51  tadejm
// Just back-up; not completed testbench and some testcases are not
// wotking properly yet.
//
// Revision 1.2  2002/09/13 12:29:14  mohor
// Headers changed.
//
// Revision 1.1  2002/09/13 11:57:20  mohor
// New testbench. Thanks to Tadej M - "The Spammer".
//
// Revision 1.1  2002/02/01 13:39:43  mihad
// Initial testbench import. Still under development
//
// Revision 1.1  2001/08/06 18:12:58  mihad
// Pocasi delamo kompletno zadevo
//
//

`include "timescale.v"
`include "wb_model_defines.v"
// WISHBONE bus monitor module - it connects to WISHBONE master signals and
// monitors for any illegal combinations appearing on the bus.
module WB_BUS_MON(
                    CLK_I,
                    RST_I,
	            ACK_I,
                    ADDR_O,
                    CYC_O,
                    DAT_I,
                    DAT_O,
                    ERR_I,
                    RTY_I,
                    SEL_O,
                    STB_O,
                    WE_O,
                    TAG_I,
                    TAG_O,
                    CAB_O,
                    check_CTI,
                    log_file_desc
                  ) ;

input                           CLK_I  ;
input                           RST_I  ;
input                           ACK_I  ;
input   [(`WB_ADDR_WIDTH-1):0]  ADDR_O ;
input                           CYC_O  ;
input   [(`WB_DATA_WIDTH-1):0]  DAT_I  ;
input   [(`WB_DATA_WIDTH-1):0]  DAT_O  ;
input                           ERR_I  ;
input                           RTY_I  ;
input   [(`WB_SEL_WIDTH-1):0]   SEL_O  ;
input                           STB_O  ;
input                           WE_O   ;
input   [(`WB_TAG_WIDTH-1):0] TAG_I  ;
input   [(`WB_TAG_WIDTH-1):0] TAG_O  ;
input                           CAB_O  ;
input                           check_CTI ;
input [31:0] log_file_desc ;

always@(posedge CLK_I)
begin
    if (RST_I !== 1'b0)
    begin
        // when reset is applied, all control signals must be low
        if (CYC_O !== 1'b0)
        begin
            message_out("CYC_O active under reset") ;
        end

        if (STB_O !== 1'b0)
        begin
            message_out("STB_O active under reset") ;
        end
        
        if (ACK_I !== 1'b0)
            message_out("ACK_I active under reset") ;

        if (ERR_I !== 1'b0)
        begin
            message_out("ERR_I active under reset") ;
        end

        if (RTY_I !== 1'b0)
        begin
            message_out("RTY_I active under reset") ;
        end

    end // reset
    else
    if (CYC_O !== 1'b1)
    begin
        // when cycle indicator is low, all control signals must be low
        if (STB_O !== 1'b0)
        begin
            message_out("STB_O active without CYC_O being active") ;
        end

        if (ACK_I !== 1'b0)
        begin
            message_out("ACK_I active without CYC_O being active") ;
        end

        if (ERR_I !== 1'b0)
        begin
            message_out("ERR_I active without CYC_O being active") ;
        end

        if (RTY_I !== 1'b0)
        begin
            message_out("RTY_I active without CYC_O being active") ;
        end

    end // ~CYC_O
end

reg [`WB_DATA_WIDTH-1:0] previous_data_o ;
reg [`WB_DATA_WIDTH-1:0] previous_data_i ;
reg [`WB_ADDR_WIDTH-1:0] previous_address ;
reg [`WB_SEL_WIDTH-1:0] previous_sel ;
reg [`WB_TAG_WIDTH-1:0] previous_tag ;
reg                     previous_stb ;
reg                     previous_ack ;
reg                     previous_err ;
reg                     previous_rty ;
reg                     previous_cyc ;
reg                     previous_we  ;

always@(posedge CLK_I or posedge RST_I)
begin
    if (RST_I)
    begin
        previous_stb        <= 1'b0 ;
        previous_ack        <= 1'b0 ;
        previous_err        <= 1'b0 ;
        previous_rty        <= 1'b0 ;
        previous_cyc        <= 1'b0 ;
        previous_tag        <= 'd0  ;
        previous_we         <= 1'b0 ;
        previous_data_o     <= 0    ;
        previous_data_i     <= 0    ;
        previous_address    <= 0    ;
        previous_sel        <= 0    ;
    end
    else
    begin
        previous_stb        <= STB_O    ;
        previous_ack        <= ACK_I    ;
        previous_err        <= ERR_I    ;
        previous_rty        <= RTY_I    ;
        previous_cyc        <= CYC_O    ;
        previous_tag        <= TAG_O    ;
        previous_we         <= WE_O     ;
        previous_data_o     <= DAT_O    ;
        previous_data_i     <= DAT_I    ;
        previous_address    <= ADDR_O   ;
        previous_sel        <= SEL_O    ;
    end
end

// cycle monitor
always@(posedge CLK_I)
begin:cycle_monitor_blk
    reg master_can_change ;
    reg slave_can_change  ;

    if ((CYC_O !== 1'b0) & (RST_I !== 1'b1)) // cycle in progress
    begin
        // check for two control signals active at same edge
        if ( (ACK_I !== 1'b0) & (RTY_I !== 1'b0) )
        begin
            message_out("ACK_I and RTY_I asserted at the same time during cycle") ;
        end

        if ( (ACK_I !== 1'b0) & (ERR_I !== 1'b0) )
        begin
            message_out("ACK_I and ERR_I asserted at the same time during cycle") ;
        end

        if ( (RTY_I !== 1'b0) & (ERR_I !== 1'b0) )
        begin
            message_out("RTY_I and ERR_I asserted at the same time during cycle") ;
        end

        if (previous_cyc === 1'b1)
        begin
            if (previous_stb === 1'b1)
            begin
                if ((previous_ack === 1'b1) | (previous_rty === 1'b1) | (previous_err === 1'b1))
                    master_can_change = 1'b1 ;
                else
                    master_can_change = 1'b0 ;
            end
            else
            begin
                master_can_change = 1'b1 ;
            end

            if ((previous_ack === 1'b1) | (previous_err === 1'b1) | (previous_rty === 1'b1))
            begin
                if (previous_stb === 1'b1)
                    slave_can_change = 1'b1 ;
                else
                    slave_can_change = 1'b0 ;
            end
            else
            begin
                slave_can_change = 1'b1 ;
            end
        end
        else
        begin
            master_can_change = 1'b1 ;
            slave_can_change  = 1'b1 ;
        end
    end
    else
    begin
        master_can_change = 1'b1 ;
        slave_can_change  = 1'b1 ;
    end

    if (master_can_change !== 1'b1)
    begin
        if (CYC_O !== previous_cyc)
        begin
            message_out("Master violated WISHBONE protocol by changing the value of CYC_O signal at inappropriate time!") ;
        end

        if (STB_O !== previous_stb)
        begin
            message_out("Master violated WISHBONE protocol by changing the value of STB_O signal at inappropriate time!") ;
        end

        if (TAG_O !== previous_tag)
        begin
            message_out("Master violated WISHBONE protocol by changing the value of TAG_O signals at inappropriate time!") ;
        end

        if (ADDR_O !== previous_address)
        begin
            message_out("Master violated WISHBONE protocol by changing the value of ADR_O signals at inappropriate time!") ;
        end

        if (SEL_O !== previous_sel)
        begin
            message_out("Master violated WISHBONE protocol by changing the value of SEL_O signals at inappropriate time!") ;
        end

        if (WE_O !== previous_we)
        begin
            message_out("Master violated WISHBONE protocol by changing the value of WE_O signal at inappropriate time!") ;
        end

        if (WE_O !== 1'b0)
        begin
            if (DAT_O !== previous_data_o)
            begin
                message_out("Master violated WISHBONE protocol by changing the value of DAT_O signals at inappropriate time!") ;
            end
        end
    end

    if (slave_can_change !== 1'b1)
    begin
        if (previous_ack !== ACK_I)
        begin
            message_out("Slave violated WISHBONE protocol by changing the value of ACK_O signal at inappropriate time!") ;
        end

        if (previous_rty !== RTY_I)
        begin
            message_out("Slave violated WISHBONE protocol by changing the value of RTY_O signal at inappropriate time!") ;
        end

        if (previous_err !== ERR_I)
        begin
            message_out("Slave violated WISHBONE protocol by changing the value of ERR_O signal at inappropriate time!") ;
        end

        if (previous_data_i !== DAT_I)
        begin
            message_out("Slave violated WISHBONE protocol by changing the value of DAT_O signals at inappropriate time!") ;
        end
    end
end // cycle monitor

// CAB_O monitor - CAB_O musn't change during one cycle
reg [1:0] first_cab_val ;
always@(posedge CLK_I or RST_I)
begin
    if ((CYC_O === 0) || RST_I)
        first_cab_val <= 2'b00 ;
    else
    begin
        // cycle in progress - is this first clock edge in a cycle ?
        if (first_cab_val[1] === 1'b0)
            first_cab_val <= {1'b1, CAB_O} ;
        else if ( first_cab_val[0] !== CAB_O )
        begin
            $display("CAB_O value changed during cycle") ;
            $fdisplay(log_file_desc, "CAB_O value changed during cycle") ;
        end
    end
end // CAB_O monitor

// CTI_O[2:0] (TAG_O[4:2]) monitor for bursts
reg [2:0] first_cti_val ;
always@(posedge CLK_I or posedge RST_I)
begin
    if (RST_I)
        first_cti_val <= 3'b000 ;
    // logging for burst cycle
    else if ( check_CTI && ((CYC_O === 0) && (first_cti_val == 3'b011) && ~(previous_rty || previous_err)))
    begin
        message_out("Master violated WISHBONE protocol by NOT changing the CTI_O signals to '111' when end of burst!") ;
        $display("CTI_O didn't change to '111' when end of burst") ;
        $fdisplay(log_file_desc, "CTI_O didn't change to '111' when end of burst") ;
        first_cti_val <= 3'b000 ;
    end
    else if (CYC_O === 0)
        first_cti_val <= 3'b000 ;
    else
    begin
        if ((first_cti_val == 3'b000) && (TAG_O[4:2] === 3'b000) && (ACK_I || ERR_I || RTY_I))
            first_cti_val <= 3'b001 ;
        else if ((first_cti_val == 3'b000) && (TAG_O[4:2] === 3'b111) && (ACK_I || ERR_I || RTY_I))
            first_cti_val <= 3'b010 ;
        else if ((first_cti_val == 3'b000) && (TAG_O[4:2] === 3'b010) && (ACK_I || ERR_I || RTY_I))
            first_cti_val <= 3'b011 ;
        else if ((first_cti_val == 3'b011) && (TAG_O[4:2] === 3'b111) && (ACK_I || ERR_I || RTY_I))
            first_cti_val <= 3'b010 ;
        // logging for clasic cycles
        else if (check_CTI && ((first_cti_val == 3'b001) && (TAG_O[4:2] !== 3'b000)))
        begin
            message_out("Master violated WISHBONE protocol by changing the CTI_O signals during CYC_O when clasic cycle!") ;
            $display("CTI_O change during CYC_O when clasic cycle") ;
            $fdisplay(log_file_desc, "CTI_O change during CYC_O when clasic cycle") ;
        end
        // logging for end of burs cycle
        else if (check_CTI && (first_cti_val == 3'b010))
        begin
            message_out("Master violated WISHBONE protocol by changing the CTI_O signals to '111' before end of burst!") ;
            $display("CTI_O change to '111' before end of burst") ;
            $fdisplay(log_file_desc, "CTI_O change to '111' before end of burst") ;
        end
    end
end

// WE_O monitor for consecutive address bursts
reg [1:0] first_we_val ;
always@(posedge CLK_I or posedge RST_I)
begin
    if (~CYC_O || ~CAB_O || RST_I)
        first_we_val <= 2'b00 ;
    else
    if (STB_O)
    begin
        // cycle in progress - is this first clock edge in a cycle ?
        if (first_we_val[1] == 1'b0)
            first_we_val <= {1'b1, WE_O} ;
        else if ( first_we_val[0] != WE_O )
        begin
            $display("WE_O value changed during CAB cycle") ;
            $fdisplay(log_file_desc, "WE_O value changed during CAB cycle") ;
        end
    end
end // CAB_O monitor

// address monitor for consecutive address bursts
reg [`WB_ADDR_WIDTH:0] address ;
always@(posedge CLK_I or posedge RST_I)
begin
    if (~CYC_O || ~CAB_O || RST_I)
        address <= {(`WB_ADDR_WIDTH + 1){1'b0}} ;
    else
    begin
        if (STB_O && ACK_I)
        begin
            if (address[`WB_ADDR_WIDTH] == 1'b0)
            begin
                address <= (ADDR_O + `WB_SEL_WIDTH) | { 1'b1, {`WB_ADDR_WIDTH{1'b0}} } ;
            end
            else
            begin
                if ( address[(`WB_ADDR_WIDTH-1):0] != ADDR_O)
                begin
                    $display("Expected ADR_O = 0x%h, Actual = 0x%h", address[(`WB_ADDR_WIDTH-1):0], ADDR_O) ;
                    message_out("Consecutive address burst address incrementing incorrect") ;
                end
                else
                    address <= (ADDR_O + `WB_SEL_WIDTH) | { 1'b1, {`WB_ADDR_WIDTH{1'b0}} } ;
            end
        end
    end
end // address monitor

// data monitor
always@(posedge CLK_I or posedge RST_I)
begin:data_monitor_blk
    reg                       last_valid_we     ;
    reg [`WB_SEL_WIDTH - 1:0] last_valid_sel    ;

    if ((CYC_O !== 1'b0) & (RST_I !== 1'b1))
    begin
        if (STB_O !== 1'b0)
        begin
            last_valid_we   = WE_O  ;
            last_valid_sel  = SEL_O ;

            if ( (ADDR_O ^ ADDR_O) !== 0 )
            begin
                message_out("Master provided invalid ADR_O and qualified it with STB_O") ;
            end
    
            if ( (SEL_O ^ SEL_O) !== 0 )
            begin
                message_out("Master provided invalid SEL_O and qualified it with STB_O") ;
            end

            if ( WE_O )
            begin
                if (
                    ( SEL_O[0] & ((DAT_O[ 7:0 ] ^ DAT_O[ 7:0 ]) !== 0) ) |
                    ( SEL_O[1] & ((DAT_O[15:8 ] ^ DAT_O[15:8 ]) !== 0) ) |
                    ( SEL_O[2] & ((DAT_O[23:16] ^ DAT_O[23:16]) !== 0) ) |
                    ( SEL_O[3] & ((DAT_O[31:24] ^ DAT_O[31:24]) !== 0) )
                   )
                begin
                    message_out("Master provided invalid data during write and qualified it with STB_O") ;
                    $display("Byte select value: SEL_O = %b, Data bus value: DAT_O =  %h ", SEL_O, DAT_O) ;
                    $fdisplay(log_file_desc, "Byte select value: SEL_O = %b, Data bus value: DAT_O =  %h ", SEL_O, DAT_O) ;
                end    
            end

            if ((TAG_O ^ TAG_O) !== 0)
            begin
                message_out("Master provided invalid TAG_O and qualified it with STB_O!") ;
            end
        end

        if ((last_valid_we !== 1'b1) & (ACK_I !== 1'b0))
        begin
            if (
                ( SEL_O[0] & ((DAT_I[ 7:0 ] ^ DAT_I[ 7:0 ]) !== 0) ) |
                ( SEL_O[1] & ((DAT_I[15:8 ] ^ DAT_I[15:8 ]) !== 0) ) |
                ( SEL_O[2] & ((DAT_I[23:16] ^ DAT_I[23:16]) !== 0) ) |
                ( SEL_O[3] & ((DAT_I[31:24] ^ DAT_I[31:24]) !== 0) )
               )
            begin
                message_out("Slave provided invalid data during read and qualified it with ACK_I") ;
                $display("Byte select value: SEL_O = %b, Data bus value: DAT_I =  %h ", last_valid_sel, DAT_I) ;
                $fdisplay(log_file_desc, "Byte select value: SEL_O = %b, Data bus value: DAT_I =  %h ", last_valid_sel, DAT_I) ;
            end
        end
    end
    else
    begin
        last_valid_sel = {`WB_SEL_WIDTH{1'bx}} ;
        last_valid_we  = 1'bx ;
    end
end

task message_out ;
    input [7999:0] message_i ;
begin
    $display("Time: %t", $time) ;
    $display("%m, %0s", message_i) ;
    $fdisplay(log_file_desc, "Time: %t", $time) ;
    $fdisplay(log_file_desc, "%m, %0s", message_i) ;
end
endtask // display message

endmodule // BUS_MON
