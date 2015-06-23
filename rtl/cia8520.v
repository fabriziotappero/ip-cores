/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*! \file
 * \brief Commodore 8520 Complex Interface Adapter implementation.
 */

/*! \brief \copybrief cia8520.v
*/
module cia8520(
    //% \name Clock and reset
    //% @{
    input CLK_I,
    input reset_n,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input CYC_I,
    input STB_I,
    input WE_I,
    input [3:0] ADR_I,
    input [7:0] DAT_I,
    output reg ACK_O,
    output reg [7:0] DAT_O,
    //% @}
    
    //% \name Internal OCS ports
    //% @{
    input pulse_709379_hz,
    //% @}
    
    //% \name 8520 synchronous interface
    //% @{
    output [7:0] pa_o,
    output [7:0] pb_o,
    input [7:0] pa_i,
    input [7:0] pb_i,
    
    input flag_n,
    output reg pc_n,
    input tod,
    output irq_n,
    
    input sp_i,
    output reg sp_o,
    input cnt_i,
    output reg cnt_o
    //% @}
);

reg [7:0] pa_o_reg;
assign pa_o = (ddra & pa_o_reg) | (~ddra & pa_i);
reg [7:0] pb_o_reg;
assign pb_o = (ddrb & pb_o_reg) | (~ddrb & pb_i);

assign irq_n = ~icr_data[5];

reg last_cnt_i;

// 0 = input, 1 = output
reg [7:0] ddra;
reg [7:0] ddrb;

reg [15:0] timera_latch;
reg [15:0] timerb_latch;
reg [5:0] cra;
reg [6:0] crb;
reg [23:0] tod_counter;
reg [23:0] tod_latch;
reg tod_write_stop;
reg tod_read_latch;
reg [23:0] tod_alarm;

reg serial_irq;
reg [7:0] serial_latch;
reg serial_latched;
reg [7:0] serial_shift;
reg [4:0] serial_counter;

reg [5:0] icr_mask;
reg [5:0] icr_data;

wire icr_data_read;
assign icr_data_read = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd13) ? 1'b1 : 1'b0;

// from datasheet:
// write high && one-shot && stopped(?) ----> timer <= latch; initiate counting regardless start; start <= 1'b1(?)
// write high && stopped ----> timer <= latch;
// write high && running ----> latch

// Timer A
reg [15:0] timera;
reg underflowa;

wire timera_force_load;
assign timera_force_load = 
    (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd14 && DAT_I[4] == 1'b1 && ACK_O == 1'b1) ? 1'b1 : 1'b0;

wire timera_loadhigh_when_stopped;
assign timera_loadhigh_when_stopped = 
    (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd5 && cra[0] == 1'b0 && ACK_O == 1'b1) ? 1'b1 : 1'b0;

wire timera_tick;
assign timera_tick =
    (cra[0] == 1'b1 &&
        ( 
            (cra[4] == 1'b0 && pulse_709379_hz == 1'b1) ||
            (cra[4] == 1'b1 && last_cnt_i == 1'b0 && cnt_i == 1'b1)
        )
    ) ? 1'b1 : 1'b0;

// Timer B
reg [15:0] timerb;
reg underflowb;

wire timerb_force_load;
assign timerb_force_load = 
    (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd15 && DAT_I[4] == 1'b1 && ACK_O == 1'b1) ? 1'b1 : 1'b0;

wire timerb_loadhigh_when_stopped;
assign timerb_loadhigh_when_stopped = 
    (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd7 && crb[0] == 1'b0 && ACK_O == 1'b1) ? 1'b1 : 1'b0;

wire timerb_tick;
assign timerb_tick = 
    (crb[0] == 1'b1 &&
        (
            (crb[5:4] == 2'b00 && pulse_709379_hz == 1'b1) ||
            (crb[5:4] == 2'b01 && last_cnt_i == 1'b0 && cnt_i == 1'b1) ||
            (crb[5:4] == 2'b10 && underflowa == 1'b1) ||
            (crb[5:4] == 2'b11 && underflowa == 1'b1 && cnt_i == 1'b1)             
        ) 
    ) ? 1'b1 : 1'b0;

wire alarm;
assign alarm = (tod_counter == tod_alarm);

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        ACK_O <= 1'b0;
        DAT_O <= 8'd0;
        
        pa_o_reg <= 8'd0;
        pb_o_reg <= 8'd0;
        ddra <= 8'd0;
        ddrb <= 8'd0;
        
        timera <= 16'd0;
        underflowa <= 1'b0;
        timerb <= 16'd0;
        underflowb <= 1'b0;
        
        timera_latch <= 16'hFFFF;
        timerb_latch <= 16'hFFFF;
        cra <= 6'd0;
        crb <= 7'd0;
        
        tod_counter <= 24'd0;
        tod_latch <= 24'd0;
        tod_write_stop <= 1'b1;
        tod_read_latch <= 1'b0;
        tod_alarm <= 24'd0;
        
        pc_n <= 1'b1;
        
        sp_o <= 1'b1;
        cnt_o <= 1'b1;
        serial_irq <= 1'b0;
        serial_latch <= 8'd0;
        serial_latched <= 1'b0;
        serial_shift <= 8'd0;
        serial_counter <= 5'd0;
        
        icr_mask <= 6'd0;
        icr_data <= 6'd0;
    end
    else begin
        last_cnt_i <= cnt_i;
    
        if(ACK_O == 1'b1)                           ACK_O <= 1'b0;
        else if(CYC_I == 1'b1 && STB_I == 1'b1)     ACK_O <= 1'b1;
        
        if(tod == 1'b1 && tod_write_stop == 1'b0) tod_counter <= tod_counter + 24'd1;
        
        if(pc_n == 1'b0) pc_n <= 1'b1;
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && ADR_I == 4'd1 && ACK_O == 1'b1) pc_n <= 1'b0;
        
        // interrupt data
        if(underflowa == 1'b1)  icr_data[0] <= 1'b1;        else if(icr_data_read == 1'b1) icr_data[0] <= 1'b0;
        if(underflowb == 1'b1)  icr_data[1] <= 1'b1;        else if(icr_data_read == 1'b1) icr_data[1] <= 1'b0;
        if(alarm == 1'b1)       icr_data[2] <= 1'b1;        else if(icr_data_read == 1'b1) icr_data[2] <= 1'b0;
        if(serial_irq == 1'b1)  icr_data[3] <= 1'b1;        else if(icr_data_read == 1'b1) icr_data[3] <= 1'b0;
        if(flag_n == 1'b0)      icr_data[4] <= 1'b1;        else if(icr_data_read == 1'b1) icr_data[4] <= 1'b0;
        
        if( (underflowa == 1'b1     && icr_mask[0] == 1'b1) ||
            (underflowb == 1'b1     && icr_mask[1] == 1'b1) ||
            (alarm == 1'b1          && icr_mask[2] == 1'b1) ||
            (serial_irq == 1'b1     && icr_mask[3] == 1'b1) ||
            (flag_n == 1'b0         && icr_mask[4] == 1'b1)
        ) begin
            icr_data[5] <= 1'b1;
        end
        else if(icr_data_read == 1'b1) icr_data[5] <= 1'b0;
        
        
        //******** SERIAL
        if(serial_irq == 1'b1) serial_irq <= 1'b0;
        
        // serial output
        if(cra[5] == 1'b1) begin
            if(serial_counter == 5'd0 && serial_latched == 1'b1) begin
                serial_shift <= serial_latch;
                serial_counter <= 5'd1;
                serial_latched <= 1'b0;
            end
            else if(serial_counter > 5'd0 && serial_counter[0] == 1'b1 && underflowa == 1'b1) begin
                 serial_counter <= serial_counter + 5'd1;
                 cnt_o <= 1'b0;
                 sp_o <= serial_shift[7];
                 serial_shift <= { serial_shift[6:0], 1'b0 };
            end
            else if(serial_counter > 5'd0 && serial_counter[0] == 1'b0 && underflowa == 1'b1) begin
                 cnt_o <= 1'b1;
                 if(serial_counter == 5'd16) begin
                    if(serial_latched == 1'b0) begin
                        serial_irq <= 1'b1;
                        serial_counter <= 5'd0;
                    end
                    else begin
                        serial_shift <= serial_latch;
                        serial_counter <= 5'd1;
                        serial_latched <= 1'b0;
                    end
                 end
                 else serial_counter <= serial_counter + 5'd1;
            end
        end
        // serial input
        else begin
            if(last_cnt_i == 1'b0 && cnt_i == 1'b1) begin
                serial_shift <= { serial_shift[6:0], sp_i };
                
                if(serial_counter == 5'd7) begin
                    serial_counter <= 5'd0;
                    serial_latch <= { serial_shift[6:0], sp_i };
                    serial_irq <= 1'b1;
                    serial_counter <= 5'd0;
                end
                else serial_counter <= serial_counter + 5'd1;
            end
        end
        
        // Timer A
        // PBON==on, OUTMODE==toggle, START==on
        if(cra[1] == 1'b1 && cra[2] == 1'b1 && cra[0] == 1'b1) pb_o_reg[6] <= 1'b1;
        // PBON==on, OUTMODE==pulse
        else if(cra[1] == 1'b1 && cra[2] == 1'b0) pb_o_reg[6] <= underflowa;
        
        // START==on, RUNMODE==single-shot, underflowa
        if(cra[0] == 1'b1 && cra[3] == 1'b1 && underflowa == 1'b1) cra[0] <= 1'b0;
        
        if(underflowa == 1'b1) underflowa <= 1'b0;
        
        if(timera_force_load == 1'b1 || timera_loadhigh_when_stopped == 1'b1) timera <= timera_latch;
        else if(timera_tick == 1'b1 && timera == 16'd1) begin
            timera <= timera_latch;
            underflowa <= 1'b1;
        end
        else if(timera_tick == 1'b1) timera <= timera - 16'd1;
        
        
        // Timer B
        // PBON==on, OUTMODE==toggle, START==on
        if(crb[1] == 1'b1 && crb[2] == 1'b1 && crb[0] == 1'b1) pb_o_reg[7] <= 1'b1;
        // PBON==on, OUTMODE==pulse
        else if(crb[1] == 1'b1 && crb[2] == 1'b0) pb_o_reg[7] <= underflowb;
        
        // START==on, RUNMODE==single-shot, underflowa
        if(crb[0] == 1'b1 && crb[3] == 1'b1 && underflowb == 1'b1) crb[0] <= 1'b0;
        
        if(underflowb == 1'b1) underflowb <= 1'b0;
        
        if(timerb_force_load == 1'b1 || timerb_loadhigh_when_stopped == 1'b1) timerb <= timerb_latch;
        else if(timerb_tick == 1'b1 && timerb == 16'd1) begin
            timerb <= timerb_latch;
            underflowb <= 1'b1;
        end
        else if(timerb_tick == 1'b1) timerb <= timerb - 16'd1;
        
        // Port Register A write
        if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd0)         pa_o_reg <= DAT_I;
        // Port Register A read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd0)    DAT_O <= (ddra & pa_o_reg) | (~ddra & pa_i);
        // Port Register B write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd1) begin
            if(cra[1] == 1'b0 && crb[1] == 1'b0)        pb_o_reg <= DAT_I;
            else if(cra[1] == 1'b1 && crb[1] == 1'b0)   {pb_o_reg[7],pb_o_reg[5:0]} <= {DAT_I[7],DAT_I[5:0]};
            else if(cra[1] == 1'b0 && crb[1] == 1'b1)   pb_o_reg[6:0]               <= DAT_I[6:0];
            else if(cra[1] == 1'b1 && crb[1] == 1'b1)   pb_o_reg[5:0]               <= DAT_I[5:0];
        end
        // Port Register B read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd1)    DAT_O <= (ddrb & pb_o_reg) | (~ddrb & pb_i);
        // Data Direction Register A write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd2)    ddra <= DAT_I;
        // Data Direction Register A read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd2)    DAT_O <= ddra;
        // Data Direction Register B write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd3)    ddrb <= DAT_I;
        // Data Direction Register B read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd3)    DAT_O <= ddrb;
        
        // Timer A Low byte write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd4)    timera_latch[7:0] <= DAT_I;
        // Timer A Low byte read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd4)    DAT_O <= timera[7:0];
        // Timer A High byte write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd5) begin
            timera_latch[15:8] <= DAT_I;
            // START==off, RUNMODE==single-shot
            if(cra[0] == 1'b0 && cra[3] == 1'b1) cra[0] <= 1'b1;
        end
        // Timer A High byte read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd5)    DAT_O <= timera[15:8];
        
        // Timer B Low byte write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd6)    timerb_latch[7:0] <= DAT_I;
        // Timer B Low byte read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd6)    DAT_O <= timerb[7:0];
        // Timer B High byte write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd7) begin
            timerb_latch[15:8] <= DAT_I;
            // START==off, RUNMODE==single-shot
            if(crb[0] == 1'b0 && crb[3] == 1'b1) crb[0] <= 1'b1;
        end
        // Timer B High byte read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd7)    DAT_O <= timerb[15:8];
        
        // TOD/ALARM low byte write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd8) begin
            if(crb[6] == 1'b0) begin
                tod_counter[7:0] <= DAT_I;
                tod_write_stop <= 1'b0;
            end
            else tod_alarm[7:0] <= DAT_I;
        end
        // TOD low byte read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd8) begin
            if(tod_read_latch == 1'b0) DAT_O <= tod_counter[7:0];
            else begin
                DAT_O <= tod_latch[7:0];
                tod_read_latch <= 1'b0;
            end
        end
        // TOD/ALARM mid byte write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd9) begin
            if(crb[6] == 1'b0) begin
                tod_counter[15:8] <= DAT_I;
            end
            else tod_alarm[15:8] <= DAT_I;
        end
        // TOD mid byte read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd9) begin
            if(tod_read_latch == 1'b0) DAT_O <= tod_counter[15:8];
            else DAT_O <= tod_latch[15:8];
        end
        // TOD/ALARM high byte write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd10) begin
            if(crb[6] == 1'b0) begin
                tod_counter[23:16] <= DAT_I;
                tod_write_stop <= 1'b1;
            end
            else tod_alarm[23:16] <= DAT_I;
        end
        // TOD high byte read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd10) begin
            DAT_O <= tod_counter[23:16];
            tod_latch <= tod_counter;
            tod_read_latch <= 1'b1;
        end
        // empty register write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd11) begin
        end
        // empty register read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd11)   DAT_O <= 8'd0;
        // Serial Data Register write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd12) begin
            serial_latch <= DAT_I;
            serial_latched <= 1'b1;
        end
        // Serial Data Register read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd12)    DAT_O <= serial_latch;
        // Interrupt Control Register write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd13) begin
            if(DAT_I[7] == 1'b1)  icr_mask <= icr_mask | DAT_I[5:0];
            else                  icr_mask <= icr_mask & (~DAT_I[5:0]);
        end
        // Interrupt Control Register read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd13)   DAT_O <= { icr_data[5], 2'b0, icr_data[4:0] };
         
        // Control Register A write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd14) begin
            cra <= { DAT_I[6:5], DAT_I[3:0] };
            
            if(cra[5] != DAT_I[6]) begin
                serial_latched <= 1'b0;
                serial_counter <= 5'd0;
                
                cnt_o <= 1'b1;
                sp_o <= (DAT_I[6] == 1'b0) ? 1'b1 : 1'b0;
            end
        end
        // Control Register A read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd14)   DAT_O <= { 1'b0, cra[5:4], 1'b0, cra[3:0] };
        // Control Register B write
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ADR_I == 4'd15)   crb <= { DAT_I[7:5], DAT_I[3:0] };
        // Control Register B read
        else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ADR_I == 4'd15)   DAT_O <= { crb[6:4], 1'b0, crb[3:0] };
    end
end

endmodule

