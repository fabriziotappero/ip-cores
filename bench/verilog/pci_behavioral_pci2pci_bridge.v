//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "pci_behavioral_iack_target"                      ////
////                                                              ////
////  This file is part of the "PCI bridge" project               ////
////  http://www.opencores.org/cores/pci/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - Miha Dolenc (mihad@opencores.org)                     ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Miha Dolenc, mihad@opencores.org          ////
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
// Revision 1.2  2002/03/06 09:10:56  mihad
// Added missing include statements
//
// Revision 1.1  2002/02/01 15:07:51  mihad
// *** empty log message ***
//

`include "pci_constants.v"
`include "timescale.v"
`include "bus_commands.v"

// module is provided just as target for responding to interrupt acknowledge commands, because
// other models don't support this command
module pci_behavioral_pci2pci_bridge
(
    CLK,
    AD,
    CBE,
    RST,
    FRAME,
    IRDY,
    DEVSEL,
    TRDY,
    STOP,
    PAR,
    response,
    data_in,
    data_out,
    devsel_speed,
    wait_states,
    bus_number
);
`include "pci_blue_constants.vh"

input CLK ;

inout   [31:0]  AD ;
reg     [31:0]  AD_out ;
reg             AD_en ;

input   [3:0]   CBE ;
input           RST ;
input           FRAME ;
input           IRDY ;

output          DEVSEL ;
reg             DEVSEL ;

output          TRDY ;
reg             TRDY ;

output          STOP ;
reg             STOP ;

inout           PAR ;
reg             PAR_out ;
reg             PAR_en ;

// posible responses:
//2'b00 - Normal
//2'b01 - Disconnect With Data
//2'b10 - Retry
//2'b11 - Abort
input  [1:0] response ;

input  [31:0] data_out ;
output [31:0] data_in ;
reg    [31:0] data_in ;
input  [1:0]  devsel_speed ;
input  [3:0]  wait_states ;
input  [7:0]  bus_number ;

reg frame_prev ;
reg read0_write1 ;

reg generate_par ;
reg busy ;

assign PAR = PAR_en ? PAR_out : 1'bz ;
assign AD  = AD_en  ? AD_out  : 32'hzzzz_zzzz ;

always@(posedge CLK or negedge RST)
begin
    if ( !RST )
    begin
        frame_prev   <= #1 1'b1 ;
        AD_out       <= #1 32'hDEAD_BEAF ;
        AD_en        <= #1 1'b0 ;
        DEVSEL       <= #1 1'bz ;
        TRDY         <= #1 1'bz ;
        STOP         <= #1 1'bz ;
        PAR_out      <= #1 1'b0 ;
        PAR_en       <= #1 1'b0 ;
        busy         = 1'b0 ;
    end
    else
    begin
        frame_prev <= #`FF_DELAY FRAME ;
    end
end

always@(posedge CLK)
begin
    if ( RST )
    begin
        if ( (frame_prev === 1) && (FRAME === 0) && (CBE[3:1] === `BC_CONF_RW) && (AD[1:0] === 2'b01) && (AD[23:16] === bus_number) )
        begin
            read0_write1 = CBE[0] ;
            busy = 1'b1 ;
            do_reference ;
        end
        else
        begin
            if (!busy)
            begin
                TRDY   <= #1 1'bz ;
                STOP   <= #1 1'bz ;
                DEVSEL <= #1 1'bz ;
            end
        end
    end
end

task do_reference ;
begin
    assert_devsel ;
    insert_waits_drive_ad_on_read ;
    terminate ;
    busy <= #1 1'b0 ;
end
endtask // do reference

task assert_devsel ;
    reg [1:0] num_of_cyc;
begin:main
    if (devsel_speed == `Test_Devsel_Fast)
    begin
        num_of_cyc = 0 ;
    end

    if (devsel_speed == `Test_Devsel_Medium)
    begin
        num_of_cyc = 1 ;
    end

    if (devsel_speed == `Test_Devsel_Slow)
    begin
        num_of_cyc = 2 ;
    end
    
    if (devsel_speed == `Test_Devsel_Subtractive)
    begin
        num_of_cyc = 3 ;
    end

    repeat(num_of_cyc)
        @(posedge CLK) ;

    DEVSEL <= #1 1'b0 ;
end
endtask // assert_devsel

task insert_waits_drive_ad_on_read ;
    reg [3:0] waits_left ;
begin
    if (((devsel_speed == `Test_Devsel_Fast) && (!read0_write1)) || (response == 2'b11))
    begin
        TRDY <= #1 1'b1 ;
        STOP <= #1 1'b1 ;
        @(posedge CLK) ;
        if (wait_states > 0)
            waits_left = wait_states - 1;
    end
    else
    begin
        waits_left = wait_states ;
    end

    if (!read0_write1)
        AD_en <= #1 1'b1 ;

    while (waits_left > 0)
    begin
        TRDY <= #1 1'b1 ;
        STOP <= #1 1'b1 ;
        @(posedge CLK) ;
        waits_left = waits_left - 1 ;
    end
end
endtask // insert_waits_drive_ad_on_read

task terminate ;
begin

    if (response)
    begin
        STOP <= #1 1'b0 ;
    end
 
    if (response == 2'b11)
        DEVSEL <= #1 1'b1 ;

    if (!response[1])
    begin
        TRDY <= #1 1'b0 ;
        if (!read0_write1)
        begin
            if (!CBE[3])
                AD_out[31:24] <= #1 data_out[31:24] ;

            if (!CBE[2])
                AD_out[23:16] <= #1 data_out[23:16] ;

            if (!CBE[1])
                AD_out[15:8] <= #1 data_out[15:8] ;
            
            if (!CBE[0])
                AD_out[7:0] <= #1 data_out[7:0] ;
        end
    end

    @(posedge CLK) ;
    while (IRDY !== 0)
        @(posedge CLK) ;

    if (read0_write1)
    begin
        if (!CBE[3])
            data_in[31:24] = AD[31:24] ;
        else
            data_in[31:24] = 8'hDE ;

        if (!CBE[2])
            data_in[23:16] = AD[23:16] ;
        else
            data_in[23:16] = 8'hAD ;

        if (!CBE[1])
            data_in[15:8] = AD[15:8] ;
        else
            data_in[15:8] = 8'hBE ;
        
        if (!CBE[0])
            data_in[7:0] = AD[7:0] ;
        else
            data_in[7:0] = 8'hAF ;
    end

    TRDY <= #1 1'b1 ;
    
    while (FRAME !== 1)
    begin
        STOP <= #1 1'b0 ;
        @(posedge CLK) ;
    end

    DEVSEL <= #1 1'b1 ;
    STOP   <= #1 1'b1 ;
    AD_en  <= #1 1'b0 ;
    AD_out <= #1 32'hDEAD_BEAF ;
end
endtask // terminate ;

always@(posedge CLK)
begin
    if (RST)
    begin
        PAR_en  <= #1 AD_en ;
        PAR_out <= #1 (^AD) ^ (^CBE) ;
    end
end

endmodule
