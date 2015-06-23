//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_wb_if.v                                                 ////
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
// Revision 1.7  2003/10/03 10:16:52  primozs
// support for configurable devider added
//
// Revision 1.6  2003/05/28 16:27:09  simons
// Change the address width.
//
// Revision 1.5  2002/04/09 13:24:11  mihad
// Added mouse interface and everything for its handling, cleaned up some unused code
//
// Revision 1.4  2002/02/20 16:35:43  mihad
// Little/big endian changes continued
//
// Revision 1.3  2002/02/20 15:20:10  mihad
// Little/big endian changes incorporated
//
// Revision 1.2  2002/02/18 18:07:55  mihad
// One bug fixed
//
// Revision 1.1.1.1  2002/02/18 16:16:56  mihad
// Initial project import - working
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ps2_wb_if
(
    wb_clk_i,
    wb_rst_i,
    wb_cyc_i,
    wb_stb_i,
    wb_we_i,
    wb_sel_i,
    wb_adr_i,
    wb_dat_i,
    wb_dat_o,
    wb_ack_o,

    wb_int_o,

    tx_kbd_write_ack_i,
    tx_kbd_data_o,
    tx_kbd_write_o,
    rx_scancode_i,
    rx_kbd_data_ready_i,
    rx_kbd_read_o,
    translate_o,
    ps2_kbd_clk_i,
    devide_reg_o,
    inhibit_kbd_if_o
    `ifdef PS2_AUX
    ,
    wb_intb_o,

    rx_aux_data_i,
    rx_aux_data_ready_i,
    rx_aux_read_o,
    tx_aux_data_o,
    tx_aux_write_o,
    tx_aux_write_ack_i,
    ps2_aux_clk_i,
    inhibit_aux_if_o
`endif
) ;

input wb_clk_i,
      wb_rst_i,
      wb_cyc_i,
      wb_stb_i,
      wb_we_i ;

input [3:0]  wb_sel_i ;

input [3:0]  wb_adr_i ;

input [31:0]  wb_dat_i ;

output [31:0] wb_dat_o ;

output wb_ack_o ;

reg wb_ack_o ;

output wb_int_o ;
reg    wb_int_o ;

input tx_kbd_write_ack_i ;

input [7:0] rx_scancode_i ;
input       rx_kbd_data_ready_i ;
output      rx_kbd_read_o ;

output      tx_kbd_write_o ;
output [7:0] tx_kbd_data_o ;

output translate_o ;
input  ps2_kbd_clk_i ;

output inhibit_kbd_if_o ;

reg [7:0] input_buffer,
          output_buffer ;

output [15:0] devide_reg_o;
reg    [15:0] devide_reg;
assign        devide_reg_o = devide_reg;


reg [15:0] wb_dat_i_sampled ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_dat_i_sampled <= #1 0 ;
    else if ( wb_cyc_i && wb_stb_i && wb_we_i )
        wb_dat_i_sampled <= #1 wb_dat_i[31:16] ;
end

`ifdef PS2_AUX
output wb_intb_o ;
reg    wb_intb_o ;

input  [7:0]    rx_aux_data_i ;
input           rx_aux_data_ready_i ;
output          rx_aux_read_o ;
output [7:0]    tx_aux_data_o ;
output          tx_aux_write_o ;
input           tx_aux_write_ack_i ;
input           ps2_aux_clk_i ;
output          inhibit_aux_if_o ;
reg             inhibit_aux_if_o ;
reg             aux_output_buffer_full ;
reg             aux_input_buffer_full ;
reg             interrupt2 ;
reg             enable2    ;
assign          tx_aux_data_o  = output_buffer ;
assign          tx_aux_write_o = aux_output_buffer_full ;
`else
wire aux_input_buffer_full  = 1'b0 ;
wire aux_output_buffer_full = 1'b0 ;
wire interrupt2             = 1'b0 ;
wire enable2                = 1'b1 ;
`endif

assign tx_kbd_data_o = output_buffer ;

reg input_buffer_full,   // receive buffer
    output_buffer_full ; // transmit buffer

assign tx_kbd_write_o = output_buffer_full ;

wire system_flag ;
wire a2                       = 1'b0 ;
wire kbd_inhibit              = ps2_kbd_clk_i ;
wire timeout                  = 1'b0 ;
wire perr                     = 1'b0 ;

wire [7:0] status_byte = {perr, timeout, aux_input_buffer_full, kbd_inhibit, a2, system_flag, output_buffer_full || aux_output_buffer_full, input_buffer_full} ;

reg  read_input_buffer_reg ;
wire read_input_buffer = wb_cyc_i && wb_stb_i && wb_sel_i[3] && !wb_ack_o && !read_input_buffer_reg && !wb_we_i && (wb_adr_i[3:0] == 4'h0) ;

reg  write_output_buffer_reg ;
wire write_output_buffer  = wb_cyc_i && wb_stb_i && wb_sel_i[3] && !wb_ack_o && !write_output_buffer_reg && wb_we_i  && (wb_adr_i[3:0] == 4'h0) ;

reg  read_status_register_reg ;
wire read_status_register = wb_cyc_i && wb_stb_i && wb_sel_i[3] && !wb_ack_o && !read_status_register_reg && !wb_we_i && (wb_adr_i[3:0] == 4'h4) ;

reg  send_command_reg ;
wire send_command = wb_cyc_i && wb_stb_i && wb_sel_i[3] && !wb_ack_o && !send_command_reg && wb_we_i  && (wb_adr_i[3:0] == 4'h4) ;

reg  write_devide_reg0 ;
wire write_devide0 = wb_cyc_i && wb_stb_i && wb_sel_i[2] && !wb_ack_o && !write_devide_reg0 && wb_we_i  && (wb_adr_i[3:0] == 4'h8) ;

//reg  read_devide_reg ;
wire read_devide = wb_cyc_i && wb_stb_i &&  ( wb_sel_i[2]|| wb_sel_i [3] ) && !wb_we_i  && (wb_adr_i[3:0] == 4'h8) ;

reg  write_devide_reg1 ;
wire write_devide1 = wb_cyc_i && wb_stb_i && wb_sel_i[3] && !wb_ack_o && !write_devide_reg1 && wb_we_i  && (wb_adr_i[3:0] == 4'h8) ;


reg  translate_o,
     enable1,
     system,
     interrupt1 ;

reg inhibit_kbd_if_o ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        inhibit_kbd_if_o <= #1 1'b0 ;
    else if ( ps2_kbd_clk_i && rx_kbd_data_ready_i && !enable1)
        inhibit_kbd_if_o <= #1 1'b1 ;
    else if ( !rx_kbd_data_ready_i || enable1 )
        inhibit_kbd_if_o <= #1 1'b0 ;

end

`ifdef PS2_AUX
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        inhibit_aux_if_o <= #1 1'b1 ;
    else if ( ps2_aux_clk_i && rx_aux_data_ready_i && !enable2 )
        inhibit_aux_if_o <= #1 1'b1 ;
    else if ( !rx_aux_data_ready_i || enable2 )
        inhibit_aux_if_o <= #1 1'b0 ;

end
`endif

assign system_flag = system ;

wire [7:0] command_byte = {1'b0, translate_o, enable2, enable1, 1'b0, system, interrupt2, interrupt1} ;

reg [7:0] current_command ;
reg [7:0] current_command_output ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
    begin
        send_command_reg         <= #1 1'b0 ;
        read_input_buffer_reg    <= #1 1'b0 ;
        write_output_buffer_reg  <= #1 1'b0 ;
        read_status_register_reg <= #1 1'b0 ;
        write_devide_reg0        <= #1 1'b0 ;
        //read_devide_reg          <= #1 1'b0 ;
        write_devide_reg1        <= #1 1'b0 ;
   end
    else
    begin
        send_command_reg         <= #1 send_command ;
        read_input_buffer_reg    <= #1 read_input_buffer ;
        write_output_buffer_reg  <= #1 write_output_buffer ;
        read_status_register_reg <= #1 read_status_register ;
        write_devide_reg0        <= #1 write_devide0 ;
        //read_devide_reg          <= #1 read_devide ;
        write_devide_reg1        <= #1 write_devide1 ;
    end
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        current_command <= #1 8'h0 ;
    else if ( send_command_reg )
        current_command <= #1 wb_dat_i_sampled[15:8] ;
end

reg current_command_valid,
    current_command_returns_value,
    current_command_gets_parameter,
    current_command_gets_null_terminated_string ;

reg write_output_buffer_reg_previous ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        write_output_buffer_reg_previous <= #1 1'b0 ;
    else
        write_output_buffer_reg_previous <= #1 write_output_buffer_reg ;
end

wire invalidate_current_command =
     current_command_valid &&
     (( current_command_returns_value && read_input_buffer_reg && input_buffer_full) ||
      ( current_command_gets_parameter && write_output_buffer_reg_previous ) ||
      ( current_command_gets_null_terminated_string && write_output_buffer_reg_previous && (output_buffer == 8'h00) ) ||
      ( !current_command_returns_value && !current_command_gets_parameter && !current_command_gets_null_terminated_string )
     ) ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        current_command_valid <= #1 1'b0 ;
    else if ( invalidate_current_command )
        current_command_valid <= #1 1'b0 ;
    else if ( send_command_reg )
        current_command_valid <= #1 1'b1 ;

end

reg write_command_byte ;
reg current_command_output_valid ;
always@(
    current_command or
    command_byte or
    write_output_buffer_reg_previous or
    current_command_valid or
    output_buffer
)
begin
    current_command_returns_value               = 1'b0 ;
    current_command_gets_parameter              = 1'b0 ;
    current_command_gets_null_terminated_string = 1'b0 ;
    current_command_output                      = 8'h00 ;
    write_command_byte                          = 1'b0 ;
    current_command_output_valid                = 1'b0 ;
    case(current_command)
        8'h20:begin
                  current_command_returns_value  = 1'b1 ;
                  current_command_output         = command_byte ;
                  current_command_output_valid   = 1'b1 ;
              end
        8'h60:begin
                  current_command_gets_parameter = 1'b1 ;
                  write_command_byte             = write_output_buffer_reg_previous && current_command_valid ;
              end
        8'hA1:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h00 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hA4:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'hF1 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hA5:begin
                  current_command_gets_null_terminated_string = 1'b1 ;
              end
        8'hA6:begin
              end
        8'hA7:begin
              end
        8'hA8:begin
              end
        8'hA9:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output_valid  = 1'b1 ;
                  `ifdef PS2_AUX
                  current_command_output        = 8'h00 ;  // interface OK
                  `else
                  current_command_output        = 8'h02 ; // clock line stuck high
                  `endif
              end
        8'hAA:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h55 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hAB:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h00 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hAD:begin
              end
        8'hAE:begin
              end
        8'hAF:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h00 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hC0:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'hFF ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hC1:begin
              end
        8'hC2:begin
              end
        8'hD0:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h01 ; // only system reset bit is 1
                  current_command_output_valid  = 1'b1 ;
              end
        8'hD1:begin
                  current_command_gets_parameter = 1'b1 ;
              end
        8'hD2:begin
                  current_command_returns_value   = 1'b1 ;
                  current_command_gets_parameter  = 1'b1 ;
                  current_command_output          = output_buffer ;
                  current_command_output_valid    = write_output_buffer_reg_previous ;
              end
        8'hD3:begin
                  current_command_gets_parameter = 1'b1 ;
                  `ifdef PS2_AUX
                  current_command_returns_value  = 1'b1 ;
                  current_command_output         = output_buffer ;
                  current_command_output_valid   = write_output_buffer_reg_previous ;
                  `endif
              end
        8'hD4:begin
                  current_command_gets_parameter = 1'b1 ;
              end
        8'hE0:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'hFF ;
                  current_command_output_valid  = 1'b1 ;
              end
    endcase
end

reg cyc_i_previous ;
reg stb_i_previous ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
    begin
        cyc_i_previous <= #1 1'b0 ;
        stb_i_previous <= #1 1'b0 ;
    end
    else if ( wb_ack_o )
    begin
        cyc_i_previous <= #1 1'b0 ;
        stb_i_previous <= #1 1'b0 ;
    end
    else
    begin
        cyc_i_previous <= #1 wb_cyc_i ;
        stb_i_previous <= #1 wb_stb_i ;
    end

end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_ack_o <= #1 1'b0 ;
    else if ( wb_ack_o )
        wb_ack_o <= #1 1'b0 ;
    else
        wb_ack_o <= #1 cyc_i_previous && stb_i_previous ;
end

reg [31:0] wb_dat_o ;
wire wb_read = read_input_buffer_reg || read_status_register_reg || read_devide ;

wire [15:0] output_data = read_status_register_reg ? {2{status_byte}} : read_devide ? devide_reg : {2{input_buffer}} ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_dat_o <= #1 32'h0 ;
    else if ( wb_read )
        wb_dat_o <= #1 {2{output_data}} ;
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        output_buffer_full <= #1 1'b0 ;
    else if ( output_buffer_full && tx_kbd_write_ack_i || enable1)
        output_buffer_full <= #1 1'b0 ;
    else
        output_buffer_full <= #1 write_output_buffer_reg && (!current_command_valid || (!current_command_gets_parameter && !current_command_gets_null_terminated_string)) ;
end

`ifdef PS2_AUX
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        aux_output_buffer_full <= #1 1'b0 ;
    else if ( aux_output_buffer_full && tx_aux_write_ack_i || enable2)
        aux_output_buffer_full <= #1 1'b0 ;
    else
        aux_output_buffer_full <= #1 write_output_buffer_reg && current_command_valid && (current_command == 8'hD4) ;
end
`endif

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        output_buffer <= #1 8'h00 ;
    else if ( write_output_buffer_reg )
        output_buffer <= #1 wb_dat_i_sampled[15:8];
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        devide_reg <= #1 8'h00 ;
    else 
      begin
      if ( write_devide_reg0 )
        devide_reg[7:0] <= #1 wb_dat_i_sampled[7:0] ;
      if ( write_devide_reg1 )
        devide_reg[15:8] <= #1 wb_dat_i_sampled[15:8] ;
      end
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
    begin
        translate_o <= #1 1'b0 ;
        system      <= #1 1'b0 ;
        interrupt1  <= #1 1'b0 ;
        `ifdef PS2_AUX
        interrupt2  <= #1 1'b0 ;
        `endif
    end
    else if ( write_command_byte )
    begin
        translate_o <= #1 output_buffer[6] ;
        system      <= #1 output_buffer[2] ;
        interrupt1  <= #1 output_buffer[0] ;
        `ifdef PS2_AUX
        interrupt2  <= #1 output_buffer[1] ;
        `endif
    end
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        enable1 <= #1 1'b1 ;
    else if ( current_command_valid && (current_command == 8'hAE) )
        enable1 <= #1 1'b0 ;
    else if ( current_command_valid && (current_command == 8'hAD) )
        enable1 <= #1 1'b1 ;
    else if ( write_command_byte )
        enable1 <= #1 output_buffer[4] ;

end

`ifdef PS2_AUX
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        enable2 <= #1 1'b1 ;
    else if ( current_command_valid && (current_command == 8'hA8) )
        enable2 <= #1 1'b0 ;
    else if ( current_command_valid && (current_command == 8'hA7) )
        enable2 <= #1 1'b1 ;
    else if ( write_command_byte )
        enable2 <= #1 output_buffer[5] ;

end
`endif

wire write_input_buffer_from_command = current_command_valid && current_command_returns_value && current_command_output_valid ;
wire write_input_buffer_from_kbd     = !input_buffer_full && rx_kbd_data_ready_i && !enable1 && !current_command_valid ;

`ifdef PS2_AUX
wire write_input_buffer_from_aux     = !input_buffer_full && rx_aux_data_ready_i && !enable2 && !current_command_valid && !write_input_buffer_from_kbd ;
`endif

wire load_input_buffer_value =
    write_input_buffer_from_command
    ||
    write_input_buffer_from_kbd
    `ifdef PS2_AUX
    ||
    write_input_buffer_from_aux
    `endif
    ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        input_buffer_full <= #1 1'b0 ;
    else if ( read_input_buffer_reg )
        input_buffer_full <= #1 1'b0 ;
    else if ( load_input_buffer_value )
        input_buffer_full <= #1 1'b1 ;
end

`ifdef PS2_AUX
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        aux_input_buffer_full <= #1 1'b0 ;
    else if ( read_input_buffer_reg )
        aux_input_buffer_full <= #1 1'b0 ;
    else if ( write_input_buffer_from_aux || (write_input_buffer_from_command && (current_command == 8'hD3)) )
        aux_input_buffer_full <= #1 1'b1 ;
end
`endif

reg input_buffer_filled_from_command ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        input_buffer_filled_from_command <= #1 1'b0 ;
    else if ( read_input_buffer_reg )
        input_buffer_filled_from_command <= #1 1'b0 ;
    else if ( write_input_buffer_from_command )
        input_buffer_filled_from_command <= #1 1'b1 ;
end

`ifdef PS2_AUX
reg [7:0] value_to_load_in_input_buffer ;
always@
(
    write_input_buffer_from_command
    or
    current_command_output
    or
    rx_scancode_i
    or
    write_input_buffer_from_kbd
    or
    rx_aux_data_i
)
begin
    case ({write_input_buffer_from_command, write_input_buffer_from_kbd})
        2'b10,
        2'b11   :   value_to_load_in_input_buffer = current_command_output ;
        2'b01   :   value_to_load_in_input_buffer = rx_scancode_i ;
        2'b00   :   value_to_load_in_input_buffer = rx_aux_data_i ;
    endcase
end

`else
wire [7:0] value_to_load_in_input_buffer = write_input_buffer_from_command ? current_command_output : rx_scancode_i ;
`endif

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        input_buffer <= #1 8'h00 ;
    else if ( load_input_buffer_value )
        input_buffer <= #1 value_to_load_in_input_buffer ;
end

assign rx_kbd_read_o = rx_kbd_data_ready_i &&
                       ( enable1
                         ||
                         ( read_input_buffer_reg
                           &&
                           input_buffer_full
                           &&
                           !input_buffer_filled_from_command
                           `ifdef PS2_AUX
                           &&
                           !aux_input_buffer_full
                           `endif
                          )
                        );

`ifdef PS2_AUX
assign rx_aux_read_o = rx_aux_data_ready_i &&
                       ( enable2 ||
                         ( read_input_buffer_reg
                           &&
                           input_buffer_full
                           &&
                           aux_input_buffer_full
                           &&
                           !input_buffer_filled_from_command
                          )
                        );
`endif

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_int_o <= #1 1'b0 ;
    else if ( read_input_buffer_reg || enable1 || !interrupt1)
        wb_int_o <= #1 1'b0 ;
    else
        wb_int_o <= #1 input_buffer_full
                       `ifdef PS2_AUX
                       &&
                       !aux_input_buffer_full
                       `endif
                       ;
end

`ifdef PS2_AUX
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_intb_o <= #1 1'b0 ;
    else if ( read_input_buffer_reg || enable2 || !interrupt2)
        wb_intb_o <= #1 1'b0 ;
    else
        wb_intb_o <= #1 input_buffer_full
                       &&
                       aux_input_buffer_full
                       ;
end
`endif

endmodule // ps2_wb_if
