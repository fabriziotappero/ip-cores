//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_keyboard_model.v                                        ////
////                                                              ////
////  This file is part of the "ps2" project                      ////
////  http://www.opencores.org/cores/ps2/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - mihad@opencores.org                                   ////
////      - Miha Dolenc                                           ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
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
// Revision 1.2  2002/04/09 13:15:16  mihad
// Wrong acknowledge generation during receiving repaired
//
// Revision 1.1.1.1  2002/02/18 16:16:55  mihad
// Initial project import - working
//
//

`include "timescale.v"

module ps2_keyboard_model
(
    kbd_clk_io,
    kbd_data_io,
    last_char_received_o,
    char_valid_o
);

parameter [31:0] kbd_clk_period = 50000; // chould be between 33 and 50 us to generate the clock between 30 and 20 kHz

inout kbd_clk_io,
      kbd_data_io ;

output [7:0] last_char_received_o ;
reg    [7:0] last_char_received_o ;

output char_valid_o ;
reg    char_valid_o ;

reg kbd_clk,
    kbd_data ;

assign kbd_clk_io  = kbd_clk ? 1'bz : 1'b0 ;
assign kbd_data_io = kbd_data ? 1'bz : 1'b0 ;

reg receiving ;
initial
begin
    kbd_clk  = 1'b1 ;
    kbd_data = 1'b1 ;

    last_char_received_o = 0 ;
    char_valid_o         = 0 ;

    receiving = 0 ;
end

always@(kbd_data_io or kbd_clk_io)
begin
    // check if host is driving keyboard data low and doesn't drive clock
    if ( !kbd_data_io && kbd_data && kbd_clk_io)
    begin
        // wait for half of clock period
        #(kbd_clk_period/2) ;

        // state hasn't changed - host wishes to send data - go receiving
        if ( !kbd_data_io && kbd_data && kbd_clk_io)
            kbd_receive_char(last_char_received_o) ;
    end
end

task kbd_send_char ;
    input [7:0] char ;
    output      transmited_ok ;
    output      severe_error ;
    reg   [10:0] tx_reg ;
    integer i ;
begin:main
    severe_error  = 1'b0 ;
    transmited_ok = 1'b0 ;

    wait ( !receiving ) ;

    tx_reg = { 1'b1, !(^char), char, 1'b0 } ;

    fork
    begin:wait_for_idle
        wait( (kbd_clk_io === 1'b1) && (kbd_data_io === 1'b1) ) ;
    //    disable timeout ;
    end
    /*begin:timeout
        #(256 * kbd_clk_period) ;
        $display("Error! Keyboard bus did not go idle in 256 keyboard clock cycles time!") ;
        severe_error  = 1'b1 ;
        transmited_ok = 1'b0 ;
        disable main ;
    end*/
    join

    #(kbd_clk_period/2) ;
    if ( !kbd_clk_io )
    begin
        transmited_ok = 1'b0 ;
        kbd_data = 1'b1 ;
        disable main ;
    end

    i = 0 ;
    while ( i < 11 )
    begin
        kbd_data = tx_reg[i] ;

        #(kbd_clk_period/2) ;

        if ( !kbd_clk_io )
        begin
            transmited_ok = 1'b0 ;
            kbd_data = 1'b1 ;
            disable main ;
        end

        kbd_clk = 1'b0 ;

        i = i + 1 ;

        #(kbd_clk_period/2) ;
        kbd_clk = 1'b1 ;
    end

    if ( i == 11 )
        transmited_ok = 1'b1 ;
end
endtask // kbd_send_char

task kbd_receive_char;
    output [7:0] char ;
    reg          parity ;
    integer i ;
    reg          stop_clocking ;
begin:main
    i = 0 ;
    receiving = 1 ;
    stop_clocking = 1'b0 ;

    #(kbd_clk_period/2) ;

    while ( !stop_clocking )
    begin

        if ( !kbd_clk_io )
        begin
            receiving = 0 ;
            disable main ;
        end

        kbd_clk = 1'b0 ;

        #(kbd_clk_period/2) ;

        kbd_clk = 1'b1 ;

        if ( i > 0 )
        begin
            if ( i <= 8 )
                char[i - 1] = kbd_data_io ;
            else if ( i == 9 )
            begin
                parity = kbd_data_io ;
                if ( parity !== ( !(^char) ) )
                    $display("Invalid parity bit received") ;
            end
        end

        i = i + 1 ;
        #(kbd_clk_period/4) ;
        if ( i > 9 )
        begin
            if ( kbd_data_io === 1'b1 )
            begin
                kbd_data <= 1'b0 ;
                stop_clocking = 1'b1 ;
            end
        end

        #(kbd_clk_period/4) ;
    end

    kbd_clk  = 1'b0 ;

    #(kbd_clk_period/2) ;
    kbd_clk  <= 1'b1 ;
    kbd_data <= 1'b1 ;

    receiving = 0 ;

    if ( i === 10 )
    begin
        char_valid_o = !char_valid_o ;
    end
end
endtask // kbd_receive_char


time last_clk_low;
time last_clk_diference;



initial
begin
last_clk_low  =0;
last_clk_diference =0;

end

always @(negedge kbd_clk_io)
 
  begin:low_time_check
   if (kbd_clk == 1)
    begin 
    last_clk_low =$time;
    fork 
    begin
    #61000
    $display(" clock low more then 61us");
    $display("Time %t", $time) ;
    #30000
    $display("error clock low more then 90usec");
    $display("Time %t", $time) ;   
    $stop;
    end
    begin
    @(posedge kbd_clk_io);
    disable low_time_check;
    end
    join
     end
   end

      

 
always @(posedge kbd_clk_io )
  begin 
  if (last_clk_low >0 )
  begin 
  last_clk_diference = $time - last_clk_low;
  if (last_clk_diference < 60000)
  begin
  $display("error time< 60u");
  #100 $stop;
  end
  end
  end






endmodule // ps2_keyboard_model
