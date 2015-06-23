//==================================================================
// File:    d_Driver_RamBuffer.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module ADCDataBuffer(
    CLK_64MHZ, MASTER_RST,
    CLK180_64MHZ,
    TIME_BASE,
    RAM_ADDR, RAM_DATA, RAM_CLK,
    ADC_DATA, ADC_CLK,
    TRIG_ADDR,
    VGA_WRITE_DONE,
    TRIGGER_LEVEL,
    sm_trig
    );
    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter ss_wait_for_trig  = 2'b00;
parameter ss_fill_mem_half  = 2'b01;
parameter ss_write_buffer   = 2'b11;
parameter ss_invalid        = 2'b10;
parameter P_trigger_level   = 8'h80;


    
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input        CLK_64MHZ;
input        CLK180_64MHZ;
input        MASTER_RST;         // Global Asyncronous Reset
input[5:0]   TIME_BASE;          // The selected V/Div
input[10:0]  RAM_ADDR;
output[7:0]  RAM_DATA;
input        RAM_CLK;
input[7:0]   ADC_DATA;
output       ADC_CLK;
output[10:0] TRIG_ADDR;
input        VGA_WRITE_DONE;
input[8:0]   TRIGGER_LEVEL;

output[1:0] sm_trig;


//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_64MHZ, MASTER_RST, CLK180_64MHZ;
wire[5:0]  TIME_BASE;
wire[10:0] RAM_ADDR;
wire[7:0]  RAM_DATA;
wire       RAM_CLK;
wire[7:0]  ADC_DATA;
wire       ADC_CLK;
reg[10:0]  TRIG_ADDR;
wire       VGA_WRITE_DONE;
wire[8:0]  TRIGGER_LEVEL;

//----------------------//
// VARIABLES            //
//----------------------//



//==================================================================//
// 'SUB-ROUTINES'                                                   //
//==================================================================//
//------------------------------------------------------------------//
// Instanstiate the ADC                                             //
//------------------------------------------------------------------//
wire[7:0] DATA_FROM_ADC;
Driver_ADC ADC(
    .CLK_64MHZ(CLK_64MHZ),
    .MASTER_RST(MASTER_RST),
    .TIME_BASE(TIME_BASE),
    .ADC_CLK(ADC_CLK),
    .ADC_DATA(ADC_DATA),
    .DATA_OUT(DATA_FROM_ADC)
    );

//------------------------------------------------------------------//
// Initialize the RAMs WE WILL NEED MORE!                           //
//   RAM is structured as follows:                                  //
//     Dual-Access RAM                                              //
//     18kBits -> 2048Bytes + 1Parity/Byte                          //
//     Access A: 8bit + 1parity (ADC_Write)                         //
//     Access B: 8bit + 1parity (Read)                              //
//------------------------------------------------------------------//
reg[10:0] ADDRA;	
wire VCC, GND;
assign VCC = 1'b1;
assign GND = 1'b0;

RAMB16_S9_S9 ADC_QuasiFifo_Buffer(
    .DOA(),                 .DOB(RAM_DATA),
    .DOPA(),                .DOPB(),
    .ADDRA(ADDRA),          .ADDRB(RAM_ADDR),
    .CLKA(CLK180_64MHZ),    .CLKB(RAM_CLK),
    .DIA(DATA_FROM_ADC),    .DIB(8'b0),
    .DIPA(GND),             .DIPB(GND),
    .ENA(VCC),              .ENB(VCC),
    .WEA(VCC),              .WEB(GND),
    .SSRA(GND),             .SSRB(GND)
    );

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

reg[1:0] sm_trig;
reg trigger_detected;
reg[9:0] cnt_1024bytes;
reg mem_half_full;

/* THE RAM WRITING TRIGGERING STATE MACHINE */
always @ (posedge CLK_64MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        sm_trig <= ss_wait_for_trig;
    else if(sm_trig == ss_wait_for_trig && trigger_detected == 1'b1)
        sm_trig <= ss_fill_mem_half;
    else if(sm_trig == ss_fill_mem_half && mem_half_full == 1'b1)
        sm_trig <= ss_write_buffer;
    else if(sm_trig == ss_write_buffer && /*trigger_detected == 1'b0 &&*/ VGA_WRITE_DONE == 1'b1)
        sm_trig <= ss_wait_for_trig;
    else if(sm_trig == ss_invalid)
        sm_trig <= ss_wait_for_trig;
    else
        sm_trig <= sm_trig;
end


/* THIS PART DEALS WITH THE ADDRESS OF THE ADC BUFFER   */
/* Write in a Circular Buffer soft of way               */
always @ (posedge ADC_CLK or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ADDRA <= 11'b0;
    end else if(sm_trig == ss_wait_for_trig || sm_trig == ss_fill_mem_half)
        ADDRA <= ADDRA + 1;
    else
        ADDRA <= ADDRA;
//        ADDRA <= ADDRA + 1;
end

/* LATCHING THE TRIGGER  */
always @ (ADC_DATA) begin
    if(ADC_DATA >= TRIGGER_LEVEL)
        trigger_detected = 1'b1;
    else
        trigger_detected = 1'b0;
end

/* GATHERING 1024 MORE BYTES OF MEMORY */
always @ (posedge ADC_CLK or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        cnt_1024bytes <= 10'b0;
    else if(sm_trig == ss_fill_mem_half)
        cnt_1024bytes <= cnt_1024bytes + 1;
    else
        cnt_1024bytes <= 10'b0;
//        cnt_1024bytes <= cnt_1024bytes;
end

always @ (cnt_1024bytes) begin
    if(cnt_1024bytes == 10'h3FF)
        mem_half_full = 1'b1;
    else
        mem_half_full = 1'b0;
end

/* STORING THE TRIGGER ADDRESS */
always @ (posedge trigger_detected or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        TRIG_ADDR <= 11'd0;
    else
        TRIG_ADDR <= ADDRA;
end



















endmodule
