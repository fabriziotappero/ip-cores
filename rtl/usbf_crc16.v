//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: 16-bit CRC used by USB data packets
//-----------------------------------------------------------------
module usbf_crc16
(
    input    [15:0]    crc_in,
    input    [7:0]     din,
    output   [15:0]    crc_out
);

//-----------------------------------------------------------------
// Logic
//-----------------------------------------------------------------
assign crc_out[15] =    din[0] ^ din[1] ^ din[2] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^ din[7] ^ 
                        crc_in[7] ^ crc_in[6] ^ crc_in[5] ^ crc_in[4] ^ crc_in[3] ^ crc_in[2] ^ crc_in[1] ^ crc_in[0];
assign crc_out[14] =    din[0] ^ din[1] ^ din[2] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^
                        crc_in[6] ^ crc_in[5] ^ crc_in[4] ^ crc_in[3] ^ crc_in[2] ^ crc_in[1] ^ crc_in[0];
assign crc_out[13] =    din[6] ^ din[7] ^ 
                        crc_in[7] ^ crc_in[6];
assign crc_out[12] =    din[5] ^ din[6] ^ 
                        crc_in[6] ^ crc_in[5];
assign crc_out[11] =    din[4] ^ din[5] ^ 
                        crc_in[5] ^ crc_in[4];
assign crc_out[10] =    din[3] ^ din[4] ^ 
                        crc_in[4] ^ crc_in[3];
assign crc_out[9] =     din[2] ^ din[3] ^ 
                        crc_in[3] ^ crc_in[2];
assign crc_out[8] =     din[1] ^ din[2] ^ 
                        crc_in[2] ^ crc_in[1];
assign crc_out[7] =     din[0] ^ din[1] ^ 
                        crc_in[15] ^ crc_in[1] ^ crc_in[0];
assign crc_out[6] =     din[0] ^ 
                        crc_in[14] ^ crc_in[0];
assign crc_out[5] =     crc_in[13];
assign crc_out[4] =     crc_in[12];
assign crc_out[3] =     crc_in[11];
assign crc_out[2] =     crc_in[10];
assign crc_out[1] =     crc_in[9];
assign crc_out[0] =     din[0] ^ din[1] ^ din[2] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^ din[7] ^
                        crc_in[8] ^ crc_in[7] ^ crc_in[6] ^ crc_in[5] ^ crc_in[4] ^ crc_in[3] ^ crc_in[2] ^ crc_in[1] ^ crc_in[0];

endmodule
