//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
module spi_core (

               clk,
               reset_n,
               
        // Reg Bus Interface Signal
             reg_cs,
             reg_wr,
             reg_addr,
             reg_wdata,
             reg_be,

            // Outputs
            reg_rdata,
            reg_ack,

          // line interface
               sck                ,
               so                 ,
               si                 ,
               cs_n  

           );
 
input               clk                           ;
input               reset_n                       ;          


//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
input               reg_cs                        ;
input               reg_wr                        ;
input [3:0]         reg_addr                      ;
input [31:0]        reg_wdata                     ;
input [3:0]         reg_be                        ;

// Outputs
output [31:0]       reg_rdata                     ;
output              reg_ack                       ;

//-------------------------------------------
// Line Interface
//-------------------------------------------

output              sck                           ; // clock out
output              so                            ; // serial data out
input               si                            ; // serial data in
output [3:0]        cs_n                          ; // cs_n

//------------------------------------
// Wires
//------------------------------------

wire [7:0]          byte_in                       ;
wire [7:0]          byte_out                      ;


wire  [1:0]         cfg_tgt_sel                   ;

wire                cfg_op_req                    ; // SPI operation request
wire  [1:0]         cfg_op_type                   ; // SPI operation type
wire  [1:0]         cfg_transfer_size             ; // SPI transfer size
wire  [5:0]         cfg_sck_period                ; // sck clock period
wire  [4:0]         cfg_sck_cs_period             ; // cs setup/hold period
wire  [7:0]         cfg_cs_byte                   ; // cs bit information
wire  [31:0]        cfg_datain                    ; // data for transfer
wire  [31:0]        cfg_dataout                   ; // data for received
wire                hware_op_done                 ; // operation done

spi_if  u_spi_if
          (
          . clk                         (clk                          ), 
          . reset_n                     (reset_n                      ),

           // towards ctrl i/f
          . sck_pe                      (sck_pe                       ),
          . sck_int                     (sck_int                      ),
          . cs_int_n                    (cs_int_n                     ),
          . byte_in                     (byte_in                      ),
          . load_byte                   (load_byte                    ),
          . byte_out                    (byte_out                     ),
          . shift_out                   (shift_out                    ),
          . shift_in                    (shift_in                     ),

          . cfg_tgt_sel                 (cfg_tgt_sel                  ),

          . sck                         (sck                          ),
          . so                          (so                           ),
          . si                          (si                           ),
          . cs_n                        (cs_n                         )
           );


spi_ctl  u_spi_ctrl
       ( 
          . clk                         (clk                          ),
          . reset_n                     (reset_n                      ),

          . cfg_op_req                  (cfg_op_req                   ),
          . cfg_op_type                 (cfg_op_type                  ),
          . cfg_transfer_size           (cfg_transfer_size            ),
          . cfg_sck_period              (cfg_sck_period               ),
          . cfg_sck_cs_period           (cfg_sck_cs_period            ),
          . cfg_cs_byte                 (cfg_cs_byte                  ),
          . cfg_datain                  (cfg_datain                   ),
          . cfg_dataout                 (cfg_dataout                  ),
          . op_done                     (hware_op_done                ),

          . sck_int                     (sck_int                      ),
          . cs_int_n                    (cs_int_n                     ),
          . sck_pe                      (sck_pe                       ),
          . sck_ne                      (sck_ne                       ),
          . shift_out                   (shift_out                    ),
          . shift_in                    (shift_in                     ),
          . load_byte                   (load_byte                    ),
          . byte_out                    (byte_out                     ),
          . byte_in                     (byte_in                      )
         
         );




spi_cfg u_cfg (

          . mclk                        (clk                          ),
          . reset_n                     (reset_n                      ),

        // Reg Bus Interface Signal
          . reg_cs                      (reg_cs                       ),
          . reg_wr                      (reg_wr                       ),
          . reg_addr                    (reg_addr                     ),
          . reg_wdata                   (reg_wdata                    ),
          . reg_be                      (reg_be                       ),

            // Outputs
          . reg_rdata                   (reg_rdata                    ),
          . reg_ack                     (reg_ack                      ),


           // configuration signal
          . cfg_tgt_sel                 (cfg_tgt_sel                  ),
          . cfg_op_req                  (cfg_op_req                   ), // SPI operation request
          . cfg_op_type                 (cfg_op_type                  ), // SPI operation type
          . cfg_transfer_size           (cfg_transfer_size            ), // SPI transfer size
          . cfg_sck_period              (cfg_sck_period               ), // sck clock period
          . cfg_sck_cs_period           (cfg_sck_cs_period            ), // cs setup/hold period
          . cfg_cs_byte                 (cfg_cs_byte                  ), // cs bit information
          . cfg_datain                  (cfg_datain                   ), // data for transfer
          . cfg_dataout                 (cfg_dataout                  ), // data for received
          . hware_op_done               (hware_op_done                )  // operation done

        );

endmodule
