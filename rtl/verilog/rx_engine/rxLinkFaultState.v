//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME:  rxLinkFaultState                               ////
////                                                              ////
//// DESCRIPTION: State machine for Link Fault Signalling.        ////
////                                                              ////
////                                                              ////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/                ////
////                                                              ////
//// AUTHOR(S):                                                   ////
//// Zheng Cao                                                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.            ////
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
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2006/05/31 05:59:42  fisher5090
// first version
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxLinkFaultState(rxclk, reset, local_fault, remote_fault, link_fault);
    input rxclk;
    input reset;
    input local_fault;
    input remote_fault;
    output[1:0] link_fault;
 
    parameter TP =1;
    parameter IDLE = 0, LinkFaultDetect = 1, NewFaultType = 2, GetFault = 3; 

    //------------------------------------------------
    // Link	Fault Signalling Statemachine
    //------------------------------------------------
    wire  fault_type;
    wire  get_one_fault;
    wire  no_new_type;

    reg[2:0] linkstate, linkstate_next;
    reg[5:0] col_cnt;
    reg      seq_cnt;
    reg[1:0] seq_type;
    reg[1:0] last_seq_type;
    reg[1:0] link_fault;
    reg      reset_col_cnt;
    wire     seq_cnt_3;
    wire     col_cnt_64;

    assign fault_type = {local_fault, remote_fault};
    assign get_one_fault = local_fault | remote_fault;
    assign no_new_type = (seq_type == last_seq_type);
    assign col_cnt_64 = & col_cnt;
 
    always@(posedge rxclk or posedge reset)begin
         if (reset) begin
           seq_type <=#TP 0;
           seq_cnt <=#TP 0;
           last_seq_type <=#TP 0;
           reset_col_cnt<= #TP 1;
           link_fault <=#TP 2'b00;
           linkstate<= #TP IDLE;
         end
         else begin	 
           seq_type <= #TP fault_type;	
           last_seq_type <=#TP seq_type;
           case (linkstate)
               IDLE: begin
                   linkstate <=#TP IDLE;
                   reset_col_cnt <= #TP 1;
                   seq_cnt <= #TP 0;
                   link_fault <= #TP 2'b00;	
                   if (get_one_fault)
                      linkstate<=#TP LinkFaultDetect;
               end
 
               LinkFaultDetect: begin
                   linkstate <=#TP LinkFaultDetect;
                   reset_col_cnt <=#TP 1;
                   if (get_one_fault & no_new_type) begin
                     if (seq_cnt) begin 
                        linkstate <=#TP IDLE;
                        link_fault <=#TP seq_type;  //final fault indeed(equals to GetFault status)
                     end
                     else
                        seq_cnt <=#TP seq_cnt + 1;
                   end
                   else if(~get_one_fault) begin
                        reset_col_cnt <=#TP 0; 
                        if (col_cnt_64)
                           linkstate <=#TP IDLE;
                   end
                   else if(get_one_fault & ~no_new_type)
                        linkstate <=#TP NewFaultType;
                   end

                NewFaultType: begin
                    seq_cnt <=#TP 0;  
                    linkstate <=#TP LinkFaultDetect;
                    reset_col_cnt<=#TP 1;
                end

//              GetFault: begin
//                  linkstate <=#TP IDLE;
//                  reset_col_cnt <=#TP 1;
//                  link_fault <=#TP seq_type;
//                  if (get_one_fault & no_new_type) 
//                    link_fault <=#TP seq_type;	
//                  else if (~get_one_fault)	begin
//                    reset_col_cnt<=#TP 0;
//                    if(col_cnt_128)
//                      linkstate <=#TP IDLE;
//                  end
//                  else if (get_one_fault &	~no_new_type)
//                    linkstate <=#TP NewFaultType;
//              end
           endcase
       end
    end

    always@(posedge rxclk or posedge reset) begin
          if (reset) 
            col_cnt <=#TP 0;
          else if (reset_col_cnt) 
            col_cnt <=#TP 0;
          else
            col_cnt <=#TP col_cnt + 1;
    end

endmodule
