//==================================================================//
// File:    d_MouseDriver.v                                         //
// Version: 0.0.0.1                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Apr 28, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Apr 28, 2005   Under Development                 //
//                                                                  //
//==================================================================//

module Driver_mouse(
    CLK_50MHZ, MASTER_RST,
    PS2C, PS2D,
    XCOORD, YCOORD,
    L_BUTTON, R_BUTTON, M_BUTTON
    );
    
//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter ss_CLK_LOW_100US    = 4'b0000;
parameter ss_DATA_LOW         = 4'b0001;
parameter ss_SET_BIT_0        = 4'b0011;
parameter ss_SET_BIT_1        = 4'b0010;
parameter ss_SET_BIT_2        = 4'b0110;
parameter ss_SET_BIT_3        = 4'b0111;
parameter ss_SET_BIT_4        = 4'b0101;
parameter ss_SET_BIT_5        = 4'b0100;
parameter ss_SET_BIT_6        = 4'b1100;
parameter ss_SET_BIT_7        = 4'b1101;
parameter ss_SET_BIT_PARITY   = 4'b1111;
parameter ss_SET_BIT_STOP     = 4'b1110;
parameter ss_WAIT_BIT_ACK     = 4'b1010;
parameter ss_GET_MOVEMENT     = 4'b1000;

parameter P_Lbut_index  = 1;
parameter P_Mbut_index  = 2;
parameter P_Rbut_index  = 3;

    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS               //
//----------------------//
input CLK_50MHZ;            // System wide clock
input MASTER_RST;           // System wide reset
inout PS2C;                 // PS2 clock
inout PS2D;                 // PS2 data

//----------------------//
// OUTPUTS              //
//----------------------//
output[11:0] XCOORD;        // X coordinate of the cursor
output[11:0] YCOORD;        // Y coordinate of the cursor
output L_BUTTON, R_BUTTON, M_BUTTON;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ, MASTER_RST;
wire PS2C, PS2D;
reg[11:0] XCOORD;
reg[11:0] YCOORD;
reg L_BUTTON, R_BUTTON, M_BUTTON;

//----------------------//
// REGISTERS            //
//----------------------//
reg[12:0] Counter_timer;
reg[5:0]  Counter_bits;
reg[3:0]  sm_ps2mouse; 
reg[32:0] data_in_buf;




//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

//------------------------------------------------------------------//
// INTERMEDIATE VALUES                                              //
//------------------------------------------------------------------//
reg[7:0]  Counter_PS2C;
reg       CLK_ps2c_debounced;

// Debounce the PS2C line.
//  The mouse is generally not outputting a nice rising clock edge.
//  To eliminate the false edge detection, make sure it is high/low
//  for at least 256 counts (5.12us off 50MHz) before triggering the CLK.
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        Counter_PS2C <= 8'b0;
    end else begin
        if(PS2C == 1'b1) begin
            if(Counter_PS2C == 8'hFF)
                Counter_PS2C <= Counter_PS2C;
            else
                Counter_PS2C <= Counter_PS2C + 1;
        end else begin
            if(Counter_PS2C == 8'b0)
                Counter_PS2C <= Counter_PS2C;
            else
                Counter_PS2C <= Counter_PS2C - 1;
        end
    end
end

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        CLK_ps2c_debounced <= 1'b0;
    else if(Counter_PS2C == 8'b0)
        CLK_ps2c_debounced <= 1'b0;
    else if(Counter_PS2C == 8'hFF)
        CLK_ps2c_debounced <= 1'b1;
    else
        CLK_ps2c_debounced <= CLK_ps2c_debounced;
end


//------------------------------------------------------------------//
// INTERPRETING MOVEMENTS                                           //
//------------------------------------------------------------------//
reg[7:0] xcoord_buf;
reg[7:0] ycoord_buf;

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        xcoord_buf <= 8'b0;
    end else if(data_in_buf[5] == 1'b0) begin
        xcoord_buf <= data_in_buf[19:12];
    end else begin
        xcoord_buf <= ((~(data_in_buf[19:12]))+1);
    end
end

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ycoord_buf <= 8'b0;
    end else if(data_in_buf[6] == 1'b0) begin
        ycoord_buf <= data_in_buf[30:23];
    end else begin
        ycoord_buf <= ((~(data_in_buf[30:23]))+1);
    end
end


always @ (posedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        XCOORD <= 12'd320;
    end else if(Counter_bits == 6'd32 && (data_in_buf[7] == 1'b0)) begin
        if(data_in_buf[5] == 1'b1) begin    // NEGITIVE
            if(XCOORD <= xcoord_buf)
                XCOORD <= 12'b0;
            else
                XCOORD <= XCOORD - xcoord_buf;
        end else begin  // POSITIVE
            if((XCOORD + xcoord_buf) >= 12'd639)
                XCOORD <= 12'd639;
            else
                XCOORD <= XCOORD + xcoord_buf;
        end
    end else begin
        XCOORD <= XCOORD;
    end
end

always @ (posedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        YCOORD <= 12'd199;
    end else if(Counter_bits == 6'd32 && (data_in_buf[8] == 1'b0)) begin
        if(data_in_buf[6] == 1'b0) begin
            if( (YCOORD < 12'd401) && ((YCOORD + ycoord_buf) >= 12'd401) )
                YCOORD <= 12'd400;
            else if( ((YCOORD >= 12'd441) /*&& (YCOORD <= 12'd520)*/) && ((YCOORD + ycoord_buf) > 12'd520) )
                YCOORD <= (YCOORD + ycoord_buf) - 12'd521;
            else
                YCOORD <= YCOORD + ycoord_buf;
        end else begin
            if( /*(YCOORD < 12'd401) &&*/ (YCOORD < ycoord_buf) )
                YCOORD <= 12'd521 - ycoord_buf;
            else if( (YCOORD >= 12'd441) && ((YCOORD-12'd441) < ycoord_buf) )
                YCOORD <= 12'd441;
            else
                YCOORD <= YCOORD - ycoord_buf;
        end
    end else begin
        YCOORD <= YCOORD;
    end
end

//------------------------------------------------------------------//
// INTERPRETING BUTTONS                                             //
//------------------------------------------------------------------//
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        L_BUTTON <= 1'b0;
        M_BUTTON <= 1'b0;
        R_BUTTON <= 1'b0;
    end else if(Counter_bits == 6'd32) begin
        L_BUTTON <= data_in_buf[P_Lbut_index];
        M_BUTTON <= data_in_buf[P_Mbut_index];
        R_BUTTON <= data_in_buf[P_Rbut_index];
    end else begin
        L_BUTTON <= L_BUTTON;
        M_BUTTON <= M_BUTTON;
        R_BUTTON <= R_BUTTON;
    end
end
        
        


//------------------------------------------------------------------//
// SENDING DATA                                                     //
//------------------------------------------------------------------//
reg PS2C_out, PS2D_out;

assign PS2C = PS2C_out;
assign PS2D = PS2D_out;
              

always @ (Counter_timer or MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        PS2C_out = 1'bZ;
    end else if((Counter_timer <= 13'd5500) && (MASTER_RST == 1'b0))
        PS2C_out = 1'b0;
    else
        PS2C_out = 1'bZ;
end

always @ (sm_ps2mouse or Counter_timer or MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        PS2D_out = 1'bZ;
    end else if(Counter_timer >= 13'd5000 && sm_ps2mouse == ss_DATA_LOW) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_0) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_1) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_2) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_3) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_4) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_5) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_6) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_7) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_PARITY) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_STOP) begin
        PS2D_out = 1'b1;
    end else begin
        PS2D_out = 1'bZ;
    end
end

//------------------------------------------------------------------//
// RECIEVING DATA                                                   //
//------------------------------------------------------------------//
always @ (negedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        data_in_buf <= 33'b0;
    end else if(sm_ps2mouse == ss_GET_MOVEMENT) begin
        data_in_buf <= data_in_buf >> 1;
        data_in_buf[32] <= PS2D;
    end else
        data_in_buf <= data_in_buf;
end



//------------------------------------------------------------------//
// COUNTERS FOR STATE MACHINE                                       //
//------------------------------------------------------------------//
// COUNTER: timer
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        Counter_timer <= 13'b0;
    else if(Counter_timer == 13'd6000)
        Counter_timer <= Counter_timer;
    else
        Counter_timer <= Counter_timer + 1;
end

// COUNTER: rec_data_bit_cnt
always @ (negedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        Counter_bits <= 6'd22;
    end else if(sm_ps2mouse == ss_GET_MOVEMENT) begin
        if(Counter_bits == 6'd32)
            Counter_bits <= 6'd0;
        else
            Counter_bits <= Counter_bits + 1;
    end else begin
        Counter_bits <= Counter_bits;
    end
end


//------------------------------------------------------------------//
// MOUSE STATE MACHINE                                              //
//------------------------------------------------------------------//
always @ (negedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
            sm_ps2mouse <= ss_DATA_LOW;
    end else if(sm_ps2mouse == ss_DATA_LOW) begin
            sm_ps2mouse <= ss_SET_BIT_0;
    end else if(sm_ps2mouse == ss_SET_BIT_0) begin
            sm_ps2mouse <= ss_SET_BIT_1;
    end else if(sm_ps2mouse == ss_SET_BIT_1) begin
            sm_ps2mouse <= ss_SET_BIT_2;
    end else if(sm_ps2mouse == ss_SET_BIT_2) begin
            sm_ps2mouse <= ss_SET_BIT_3;
    end else if(sm_ps2mouse == ss_SET_BIT_3) begin
            sm_ps2mouse <= ss_SET_BIT_4;
    end else if(sm_ps2mouse == ss_SET_BIT_4) begin
            sm_ps2mouse <= ss_SET_BIT_5;
    end else if(sm_ps2mouse == ss_SET_BIT_5) begin
            sm_ps2mouse <= ss_SET_BIT_6;
    end else if(sm_ps2mouse == ss_SET_BIT_6) begin
            sm_ps2mouse <= ss_SET_BIT_7;
    end else if(sm_ps2mouse == ss_SET_BIT_7) begin
            sm_ps2mouse <= ss_SET_BIT_PARITY;
    end else if(sm_ps2mouse == ss_SET_BIT_PARITY) begin
            sm_ps2mouse <= ss_SET_BIT_STOP;
    end else if(sm_ps2mouse == ss_SET_BIT_STOP) begin
            sm_ps2mouse <= ss_WAIT_BIT_ACK;
    end else if(sm_ps2mouse == ss_WAIT_BIT_ACK) begin
            sm_ps2mouse <= ss_GET_MOVEMENT;
    end else if(sm_ps2mouse == ss_GET_MOVEMENT) begin
            sm_ps2mouse <= sm_ps2mouse;
    end else begin
        sm_ps2mouse <= ss_DATA_LOW;
    end
end

















endmodule

