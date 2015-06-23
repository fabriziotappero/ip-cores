//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Ramdon_gen.v                                                ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/projects.cgi/web/ethernet_tri_mode/////
////                                                              ////
////  Author(s):                                                  ////
////      - Jon Gao (gaojon@yahoo.com)                            ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors                                   ////
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
// Revision 1.2  2005/12/16 06:44:19  Administrator
// replaced tab with space.
// passed 9.6k length frame test.
//
// Revision 1.1.1.1  2005/12/13 01:51:45  Administrator
// no message
//                                           

module Ramdon_gen( 
Reset           ,
Clk             ,
Init            ,
RetryCnt        ,
Random_time_meet
);
input           Reset           ;
input           Clk             ;
input           Init            ;
input   [3:0]   RetryCnt        ;
output          Random_time_meet;   

//******************************************************************************
//internal signals                                                              
//******************************************************************************
reg [9:0]       Random_sequence ;
reg [9:0]       Ramdom          ;
reg [9:0]       Ramdom_counter  ;
reg [7:0]       Slot_time_counter; //256*2=512bit=1 slot time
reg             Random_time_meet;

//******************************************************************************
always @ (posedge Clk or posedge Reset)
    if (Reset)
        Random_sequence     <=0;
    else
        Random_sequence     <={Random_sequence[8:0],~(Random_sequence[2]^Random_sequence[9])};
        
always @ (RetryCnt or Random_sequence)
    case (RetryCnt)
        4'h0    :   Ramdom={9'b0,Random_sequence[0]};
        4'h1    :   Ramdom={8'b0,Random_sequence[1:0]};     
        4'h2    :   Ramdom={7'b0,Random_sequence[2:0]};
        4'h3    :   Ramdom={6'b0,Random_sequence[3:0]};
        4'h4    :   Ramdom={5'b0,Random_sequence[4:0]};
        4'h5    :   Ramdom={4'b0,Random_sequence[5:0]};
        4'h6    :   Ramdom={3'b0,Random_sequence[6:0]};
        4'h7    :   Ramdom={2'b0,Random_sequence[7:0]};
        4'h8    :   Ramdom={1'b0,Random_sequence[8:0]};
        4'h9    :   Ramdom={     Random_sequence[9:0]};  
        default :   Ramdom={     Random_sequence[9:0]};
    endcase

always @ (posedge Clk or posedge Reset)
    if (Reset)
        Slot_time_counter       <=0;
    else if(Init)
        Slot_time_counter       <=0;
    else if(!Random_time_meet)
        Slot_time_counter       <=Slot_time_counter+1;
    
always @ (posedge Clk or posedge Reset)
    if (Reset)
        Ramdom_counter      <=0;
    else if (Init)
        Ramdom_counter      <=Ramdom;
    else if (Ramdom_counter!=0&&Slot_time_counter==255)
        Ramdom_counter      <=Ramdom_counter -1 ;
        
always @ (posedge Clk or posedge Reset)
    if (Reset)
        Random_time_meet    <=1;
    else if (Init)
        Random_time_meet    <=0;
    else if (Ramdom_counter==0)
        Random_time_meet    <=1;
        
endmodule


