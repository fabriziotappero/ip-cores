//==================================================================//
// File:    d_Driver_ADCRamBuffer.v                                 //
// Version: X                                                       //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   July 15, 2005                                                  //
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
// Ver X          July 15, 2005   Initial Development Release       //
//                                                                  //
//==================================================================//

module ADCDataBuffer(
    CLK_64MHZ, MASTER_CLK, MASTER_RST,
    TIMESCALE, TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET,
    ADC_DATA,
    CLK_ADC,
    SNAP_DATA_EXT, SNAP_ADDR_EXT, SNAP_CLK_EXT,
    TRIGGERSTYLE
    );
    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter ss_fifo_fill      = 2'b00;
parameter ss_fifo_half      = 2'b01;
parameter ss_save_snapshot  = 2'b11;
parameter ss_invalid        = 2'b10;

    
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input       CLK_64MHZ;
input       MASTER_CLK;
input       MASTER_RST;
input[3:0]  TIMESCALE;
input[10:0]  TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET;
input[8:0]  ADC_DATA;

output      CLK_ADC;

output[8:0] SNAP_DATA_EXT;
input[10:0] SNAP_ADDR_EXT;
input       SNAP_CLK_EXT;

input[1:0] TRIGGERSTYLE;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_64MHZ, MASTER_CLK, MASTER_RST;
wire[3:0]  TIMESCALE;
wire[10:0]  TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET;
wire[8:0]  ADC_DATA;
wire CLK_ADC;
wire[8:0] SNAP_DATA_EXT;
wire[10:0] SNAP_ADDR_EXT;
wire SNAP_CLK_EXT;
wire[1:0] TRIGGERSTYLE;


//----------------------//
// VARIABLES            //
//----------------------//
wire[8:0]   data_from_adc;
reg triggered;
reg[1:0]    sm_adc_ram;
reg[10:0]   fifo_addr;
reg[8:0]    data_from_adc_buffered;
reg[10:0]   trig_addr;
wire[8:0]   buf_adc_data;
reg[10:0]   snap_addr, buf_adc_addr;



//==================================================================//
// 'SUB-ROUTINES'                                                   //
//==================================================================//
//------------------------------------------------------------------//
// Instanstiate the ADC                                             //
//------------------------------------------------------------------//

Driver_ADC ADC(
    .CLK_64MHZ(CLK_64MHZ),
    .MASTER_RST(MASTER_RST),
    .TIMESCALE(TIMESCALE),
    .CLK_ADC(CLK_ADC),
    .ADC_DATA(ADC_DATA),
    .DATA_OUT(data_from_adc)
    );

//------------------------------------------------------------------//
// Initialize the RAMs WE WILL NEED MORE!                           //
//   RAM is structured as follows:                                  //
//     Dual-Access RAM                                              //
//     18kBits -> 2048Bytes + 1Parity/Byte                          //
//     Access A: 8bit + 1parity (ADC_Write)                         //
//     Access B: 8bit + 1parity (Read)                              //
//------------------------------------------------------------------//
wire VCC, GND;
assign VCC = 1'b1;
assign GND = 1'b0;

// move the following into a more organized area
wire[10:0] vert_adjustment;
assign vert_adjustment = (VERT_OFFSET);

RAMB16_S9_S9 ADC_QuasiFifo_Buffer(
    .DOA(),                     .DOB(buf_adc_data[7:0]),
    .DOPA(),                    .DOPB(buf_adc_data[8]),
    .ADDRA(fifo_addr),          .ADDRB(buf_adc_addr),
    .CLKA(CLK_ADC),             .CLKB(CLK_ADC),
    .DIA(data_from_adc[7:0]),   .DIB(8'b0),
    .DIPA(data_from_adc[8]),    .DIPB(GND),
    .ENA(VCC),                  .ENB(VCC),
    .WEA(VCC),                  .WEB(GND),
    .SSRA(GND),                 .SSRB(GND)
    );
    
RAMB16_S9_S9 ADC_Data_Snapshot(
    .DOA(),                                             .DOB(SNAP_DATA_EXT[7:0]),
    .DOPA(),                                            .DOPB(SNAP_DATA_EXT[8]),
    .ADDRA(snap_addr),                                  .ADDRB(SNAP_ADDR_EXT),
    .CLKA(CLK_ADC),                                     .CLKB(SNAP_CLK_EXT),
    .DIA(buf_adc_data[7:0]+vert_adjustment[7:0]),       .DIB(8'b0),   /* VERTICAL OFFSET */
    .DIPA(buf_adc_data[8]+vert_adjustment[8]),          .DIPB(GND),   /* VERTICAL OFFSET */
    .ENA(VCC),                                          .ENB(VCC),
    .WEA(VCC),                                          .WEB(GND),
    .SSRA(GND),                                         .SSRB(GND)
    );


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

/* STATE_MACHINE */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        sm_adc_ram <= ss_fifo_fill;
    else begin
//        if(sm_adc_ram != ss_fifo_fill || sm_adc_ram != ss_fifo_half || sm_adc_ram != ss_save_snapshot)
//            sm_adc_ram <= ss_fifo_fill;
        if(sm_adc_ram == ss_fifo_fill && triggered)
            sm_adc_ram <= ss_fifo_half;
        else if(sm_adc_ram == ss_fifo_half && (fifo_addr == (trig_addr + 11'd1023)))
            sm_adc_ram <= ss_save_snapshot;
        else if(sm_adc_ram == ss_save_snapshot && snap_addr == 11'd2047)
            sm_adc_ram <= ss_fifo_fill;
        else if(sm_adc_ram == ss_invalid)
            sm_adc_ram <= ss_fifo_fill;
        else 
            sm_adc_ram <= sm_adc_ram;
    end
end

/* FIFO ADDR */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        fifo_addr <= 11'b0;
    else if(sm_adc_ram == ss_fifo_fill || sm_adc_ram == ss_fifo_half)
        fifo_addr <= fifo_addr + 1;
    else
        fifo_addr <= fifo_addr;
end

/* TRIGGER */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        data_from_adc_buffered <= 9'b0;
    else
        data_from_adc_buffered <= data_from_adc;
end

always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        triggered <= 1'b0;
    else
        triggered <= (TRIGGERSTYLE == 2'b00) && (data_from_adc_buffered < TRIGGER_LEVEL && data_from_adc >= TRIGGER_LEVEL) || // >=
                     (TRIGGERSTYLE == 2'b01) && (data_from_adc_buffered > TRIGGER_LEVEL && data_from_adc <= TRIGGER_LEVEL);   // <=
end

always @ (posedge triggered or posedge MASTER_RST) begin
    if(MASTER_RST)
        trig_addr <= 11'b0;
    else if(sm_adc_ram == ss_fifo_fill)
        trig_addr <= fifo_addr;
    else
        trig_addr <= trig_addr;
end
        
/* SNAPSHOT */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        snap_addr <= 11'b0;
        buf_adc_addr <= 11'b0;
    end else if(sm_adc_ram == ss_save_snapshot) begin
        snap_addr <= snap_addr + 1;
        buf_adc_addr <= buf_adc_addr + 1;
    end else begin
        buf_adc_addr <= trig_addr - (HORZ_OFFSET-11'd319);        /* HORIZONTAL OFFSET */
        snap_addr <= 11'b0;
    end
end

endmodule
