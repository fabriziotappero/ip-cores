/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module pic(
    input               clk,
    input               rst_n,
    
    //master pic
    input               master_address,
    input               master_read,
    output reg  [7:0]   master_readdata,
    input               master_write,
    input       [7:0]   master_writedata,
    
    //slave pic
    input               slave_address,
    input               slave_read,
    output reg  [7:0]   slave_readdata,
    input               slave_write,
    input       [7:0]   slave_writedata,
    
    //interrupt input
    input       [15:0]  interrupt_input,
    
    //interrupt output
    output reg          interrupt_do,
    output reg  [7:0]   interrupt_vector,
    input               interrupt_done
);

//------------------------------------------------------------------------------

reg slave_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) slave_read_last <= 1'b0; else if(slave_read_last) slave_read_last <= 1'b0; else slave_read_last <= slave_read; end 
wire slave_read_valid = slave_read && slave_read_last == 1'b0;

reg master_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) master_read_last <= 1'b0; else if(master_read_last) master_read_last <= 1'b0; else master_read_last <= master_read; end 
wire master_read_valid = master_read && master_read_last == 1'b0;

//------------------------------------------------------------------------------

reg [15:0] interrupt_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   interrupt_last <= 16'd0;
    else                interrupt_last <= interrupt_input;
end

//------------------------------------------------------------------------------

wire [7:0] sla_readdata_prepared =
    (sla_polled)?                                               { sla_current_irq, 4'd0, sla_irq_value } :
    (slave_address == 1'b0 && sla_read_reg_select == 1'b0)?     sla_irr :
    (slave_address == 1'b0 && sla_read_reg_select == 1'b1)?     sla_isr :
                                                                sla_imr;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   slave_readdata <= 8'd0;
    else                slave_readdata <= sla_readdata_prepared;
end

wire [7:0] mas_readdata_prepared =
    (mas_polled)?                                               { mas_current_irq, 4'd0, mas_irq_value } :
    (master_address == 1'b0 && mas_read_reg_select == 1'b0)?    mas_irr :
    (master_address == 1'b0 && mas_read_reg_select == 1'b1)?    mas_isr :
                                                                mas_imr;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   master_readdata <= 8'd0;
    else                master_readdata <= mas_readdata_prepared;
end

//------------------------------------------------------------------------------

wire sla_init_icw1 = slave_write && slave_address == 1'b0 && slave_writedata[4] == 1'b1;
wire sla_init_icw2 = slave_write && slave_address == 1'b1 && sla_in_init && sla_init_byte_expected == 3'd2;
wire sla_init_icw3 = slave_write && slave_address == 1'b1 && sla_in_init && sla_init_byte_expected == 3'd3;
wire sla_init_icw4 = slave_write && slave_address == 1'b1 && sla_in_init && sla_init_byte_expected == 3'd4;

wire sla_ocw1 = sla_in_init == 1'b0 && slave_write && slave_address == 1'b1;
wire sla_ocw2 = slave_write && slave_address == 1'b0 && slave_writedata[4:3] == 2'b00;
wire sla_ocw3 = slave_write && slave_address == 1'b0 && slave_writedata[4:3] == 2'b01;

reg sla_polled;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       sla_polled <= 1'b0;
    else if(sla_polled && slave_read_valid) sla_polled <= 1'b0;
    else if(sla_ocw3)                       sla_polled <= slave_writedata[2];
end

reg sla_read_reg_select;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       sla_read_reg_select <= 1'b0;
    else if(sla_init_icw1)                                                  sla_read_reg_select <= 1'b0;
    else if(sla_ocw3 && slave_writedata[2] == 1'b0 && slave_writedata[1])   sla_read_reg_select <= slave_writedata[0];
end

reg sla_special_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       sla_special_mask <= 1'd0;
    else if(sla_init_icw1)                                                  sla_special_mask <= 1'd0;
    else if(sla_ocw3 && slave_writedata[2] == 1'b0 && slave_writedata[6])   sla_special_mask <= slave_writedata[5];
end

reg sla_in_init;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   sla_in_init <= 1'b0;
    else if(sla_init_icw1)                              sla_in_init <= 1'b1;
    else if(sla_init_icw3 && ~(sla_init_requires_4))    sla_in_init <= 1'b0;
    else if(sla_init_icw4)                              sla_in_init <= 1'b0;
end

reg sla_init_requires_4;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sla_init_requires_4 <= 1'b0;
    else if(sla_init_icw1)  sla_init_requires_4 <= slave_writedata[0];
end

reg sla_ltim;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sla_ltim <= 1'b0;
    else if(sla_init_icw1)  sla_ltim <= slave_writedata[3];
end

reg [2:0] sla_init_byte_expected;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               sla_init_byte_expected <= 3'd0;
    else if(sla_init_icw1)                          sla_init_byte_expected <= 3'd2;
    else if(sla_init_icw2)                          sla_init_byte_expected <= 3'd3;
    else if(sla_init_icw3 && sla_init_requires_4)   sla_init_byte_expected <= 3'd4;
end

reg [2:0] sla_lowest_priority;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                           sla_lowest_priority <= 3'd7;
    else if(sla_init_icw1)                                                      sla_lowest_priority <= 3'd7;
    else if(sla_ocw2 && slave_writedata == 8'hA0)                               sla_lowest_priority <= sla_lowest_priority + 3'd1;  //rotate on non-specific EOI
    else if(sla_ocw2 && { slave_writedata[7:3], 3'b000 } == 8'hC0)              sla_lowest_priority <= slave_writedata[2:0];        //set priority
    else if(sla_ocw2 && { slave_writedata[7:3], 3'b000 } == 8'hE0)              sla_lowest_priority <= slave_writedata[2:0];        //rotate on specific EOI
    else if(sla_acknowledge_not_spurious && sla_auto_eoi && sla_rotate_on_aeoi) sla_lowest_priority <= sla_lowest_priority + 3'd1;  //rotate on AEOI
end

reg [7:0] sla_imr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           sla_imr <= 8'hFF;
    else if(sla_init_icw1)      sla_imr <= 8'h00;
    else if(sla_ocw1)           sla_imr <= slave_writedata;
end

wire [7:0] sla_edge_detect = {
    interrupt_input[15] == 1'b1 && interrupt_last[15] == 1'b0,
    interrupt_input[14] == 1'b1 && interrupt_last[14] == 1'b0,
    interrupt_input[13] == 1'b1 && interrupt_last[13] == 1'b0,
    interrupt_input[12] == 1'b1 && interrupt_last[12] == 1'b0,
    interrupt_input[11] == 1'b1 && interrupt_last[11] == 1'b0,
    interrupt_input[10] == 1'b1 && interrupt_last[10] == 1'b0,
    interrupt_input[9]  == 1'b1 && interrupt_last[9] == 1'b0,
    interrupt_input[8]  == 1'b1 && interrupt_last[8] == 1'b0
};

reg [7:0] sla_irr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       sla_irr <= 8'h00;
    else if(sla_init_icw1)                  sla_irr <= 8'h00;
    else if(sla_acknowledge_not_spurious)   sla_irr <= (sla_irr & interrupt_input[15:8] & ~(interrupt_vector_bits)) | ((~(sla_ltim))? sla_edge_detect : interrupt_input[15:8]);
    else                                    sla_irr <= (sla_irr & interrupt_input[15:8])                            | ((~(sla_ltim))? sla_edge_detect : interrupt_input[15:8]);
end

wire [7:0] sla_writedata_mask =
    (slave_writedata[2:0] == 3'd0)?     8'b00000001 :
    (slave_writedata[2:0] == 3'd1)?     8'b00000010 :
    (slave_writedata[2:0] == 3'd2)?     8'b00000100 :
    (slave_writedata[2:0] == 3'd3)?     8'b00001000 :
    (slave_writedata[2:0] == 3'd4)?     8'b00010000 :
    (slave_writedata[2:0] == 3'd5)?     8'b00100000 :
    (slave_writedata[2:0] == 3'd6)?     8'b01000000 :
                                        8'b10000000;

wire sla_isr_clear = 
    (sla_polled && slave_read_valid) || //polling
    (sla_ocw2 && (slave_writedata == 8'h20 || slave_writedata == 8'hA0)); //non-specific EOI or rotate on non-specific EOF
                                        
reg [7:0] sla_isr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               sla_isr <= 8'h00;
    else if(sla_init_icw1)                                          sla_isr <= 8'h00;
    else if(sla_ocw2 && { slave_writedata[7:3], 3'b000 } == 8'h60)  sla_isr <= sla_isr & ~(sla_writedata_mask);                     //clear on specific EOI
    else if(sla_ocw2 && { slave_writedata[7:3], 3'b000 } == 8'hE0)  sla_isr <= sla_isr & ~(sla_writedata_mask);                     //clear on rotate on specific EOI
    else if(sla_isr_clear)                                          sla_isr <= sla_isr & ~(sla_selected_shifted_isr_first_bits);    //clear on polling or non-specific EOI (with or without rotate)
    else if(sla_acknowledge_not_spurious && ~(sla_auto_eoi))        sla_isr <= sla_isr | interrupt_vector_bits;                     //set
end

reg [4:0] sla_interrupt_offset;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sla_interrupt_offset <= 5'h0E;
    else if(sla_init_icw2)  sla_interrupt_offset <= slave_writedata[7:3];
end

reg sla_auto_eoi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       sla_auto_eoi <= 1'b0;
    else if(sla_init_icw1)  sla_auto_eoi <= 1'b0;
    else if(sla_init_icw4)  sla_auto_eoi <= slave_writedata[1];
end

reg sla_rotate_on_aeoi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   sla_rotate_on_aeoi <= 1'b0;
    else if(sla_init_icw1)                              sla_rotate_on_aeoi <= 1'b0;
    else if(sla_ocw2 && slave_writedata[6:0] == 7'd0)   sla_rotate_on_aeoi <= slave_writedata[7];
end

wire [7:0] sla_selected_prepare = sla_irr & ~(sla_imr) & ~(sla_isr);

wire [7:0] sla_selected_shifted =
    (sla_lowest_priority == 3'd7)?      sla_selected_prepare :
    (sla_lowest_priority == 3'd0)?      { sla_selected_prepare[0],   sla_selected_prepare[7:1] } :
    (sla_lowest_priority == 3'd1)?      { sla_selected_prepare[1:0], sla_selected_prepare[7:2] } :
    (sla_lowest_priority == 3'd2)?      { sla_selected_prepare[2:0], sla_selected_prepare[7:3] } :
    (sla_lowest_priority == 3'd3)?      { sla_selected_prepare[3:0], sla_selected_prepare[7:4] } :
    (sla_lowest_priority == 3'd4)?      { sla_selected_prepare[4:0], sla_selected_prepare[7:5] } :
    (sla_lowest_priority == 3'd5)?      { sla_selected_prepare[5:0], sla_selected_prepare[7:6] } :
                                        { sla_selected_prepare[6:0], sla_selected_prepare[7] };
    
wire [7:0] sla_selected_shifted_isr =
    (sla_lowest_priority == 3'd7)?      sla_isr :
    (sla_lowest_priority == 3'd0)?      { sla_isr[0],   sla_isr[7:1] } :
    (sla_lowest_priority == 3'd1)?      { sla_isr[1:0], sla_isr[7:2] } :
    (sla_lowest_priority == 3'd2)?      { sla_isr[2:0], sla_isr[7:3] } :
    (sla_lowest_priority == 3'd3)?      { sla_isr[3:0], sla_isr[7:4] } :
    (sla_lowest_priority == 3'd4)?      { sla_isr[4:0], sla_isr[7:5] } :
    (sla_lowest_priority == 3'd5)?      { sla_isr[5:0], sla_isr[7:6] } :
                                        { sla_isr[6:0], sla_isr[7] };

wire [2:0] sla_selected_shifted_isr_first =
    (sla_selected_shifted_isr[0])?  3'd0 :
    (sla_selected_shifted_isr[1])?  3'd1 :
    (sla_selected_shifted_isr[2])?  3'd2 :
    (sla_selected_shifted_isr[3])?  3'd3 :
    (sla_selected_shifted_isr[4])?  3'd4 :
    (sla_selected_shifted_isr[5])?  3'd5 :
    (sla_selected_shifted_isr[6])?  3'd6 :
                                    3'd7;
    
wire [2:0] sla_selected_shifted_isr_first_norm = sla_lowest_priority + sla_selected_shifted_isr_first + 3'd1;

wire [7:0] sla_selected_shifted_isr_first_bits =
    (sla_selected_shifted_isr_first_norm == 3'd0)?  8'b00000001 :
    (sla_selected_shifted_isr_first_norm == 3'd1)?  8'b00000010 :
    (sla_selected_shifted_isr_first_norm == 3'd2)?  8'b00000100 :
    (sla_selected_shifted_isr_first_norm == 3'd3)?  8'b00001000 :
    (sla_selected_shifted_isr_first_norm == 3'd4)?  8'b00010000 :
    (sla_selected_shifted_isr_first_norm == 3'd5)?  8'b00100000 :
    (sla_selected_shifted_isr_first_norm == 3'd6)?  8'b01000000 :
                                                    8'b10000000;
                                    
wire [2:0] sla_selected_index =
    (sla_selected_shifted[0])?      3'd0 :
    (sla_selected_shifted[1])?      3'd1 :
    (sla_selected_shifted[2])?      3'd2 :
    (sla_selected_shifted[3])?      3'd3 :
    (sla_selected_shifted[4])?      3'd4 :
    (sla_selected_shifted[5])?      3'd5 :
    (sla_selected_shifted[6])?      3'd6 :
                                    3'd7;

wire sla_irq = sla_selected_prepare != 8'd0 && (sla_special_mask || sla_selected_index < sla_selected_shifted_isr_first);

wire [2:0] sla_irq_value = (sla_irq)? sla_lowest_priority + sla_selected_index + 3'd1 : 3'd7;

reg sla_current_irq;    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           sla_current_irq <= 1'b0;
    else if(sla_init_icw1)      sla_current_irq <= 1'b0;
    else if(sla_acknowledge)    sla_current_irq <= 1'b0;
    else if(sla_irq)            sla_current_irq <= 1'b1;
end

reg sla_current_irq_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   sla_current_irq_last <= 1'b0;
    else                sla_current_irq_last <= sla_current_irq;
end

wire sla_acknowledge_not_spurious = (sla_polled && slave_read_valid) || (mas_sla_active && interrupt_done && ~(sla_spurious));
wire sla_acknowledge              = (sla_polled && slave_read_valid) || (mas_sla_active && interrupt_done);

wire sla_spurious_start = sla_current_irq && ~(interrupt_done) && ~(sla_irq);

reg sla_spurious;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       sla_spurious <= 1'd0;
    else if(sla_init_icw1)                  sla_spurious <= 1'b0;
    else if(sla_spurious_start)             sla_spurious <= 1'b1;
    else if(sla_acknowledge || sla_irq)     sla_spurious <= 1'b0;
end

//------------------------------------------------------------------------------

wire mas_init_icw1 = master_write && master_address == 1'b0 && master_writedata[4] == 1'b1;
wire mas_init_icw2 = master_write && master_address == 1'b1 && mas_in_init && mas_init_byte_expected == 3'd2;
wire mas_init_icw3 = master_write && master_address == 1'b1 && mas_in_init && mas_init_byte_expected == 3'd3;
wire mas_init_icw4 = master_write && master_address == 1'b1 && mas_in_init && mas_init_byte_expected == 3'd4;

wire mas_ocw1 = mas_in_init == 1'b0 && master_write && master_address == 1'b1;
wire mas_ocw2 = master_write && master_address == 1'b0 && master_writedata[4:3] == 2'b00;
wire mas_ocw3 = master_write && master_address == 1'b0 && master_writedata[4:3] == 2'b01;

reg mas_polled;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           mas_polled <= 1'b0;
    else if(mas_polled && master_read_valid)    mas_polled <= 1'b0;
    else if(mas_ocw3)                           mas_polled <= master_writedata[2];
end

reg mas_read_reg_select;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       mas_read_reg_select <= 1'b0;
    else if(mas_init_icw1)                                                  mas_read_reg_select <= 1'b0;
    else if(mas_ocw3 && master_writedata[2] == 1'b0 && master_writedata[1]) mas_read_reg_select <= master_writedata[0];
end

reg mas_special_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       mas_special_mask <= 1'd0;
    else if(mas_init_icw1)                                                  mas_special_mask <= 1'd0;
    else if(mas_ocw3 && master_writedata[2] == 1'b0 && master_writedata[6]) mas_special_mask <= master_writedata[5];
end

reg mas_in_init;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   mas_in_init <= 1'b0;
    else if(mas_init_icw1)                              mas_in_init <= 1'b1;
    else if(mas_init_icw3 && ~(mas_init_requires_4))    mas_in_init <= 1'b0;
    else if(mas_init_icw4)                              mas_in_init <= 1'b0;
end

reg mas_init_requires_4;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mas_init_requires_4 <= 1'b0;
    else if(mas_init_icw1) mas_init_requires_4 <= master_writedata[0];
end

reg mas_ltim;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)      	mas_ltim <= 1'b0;
    else if(mas_init_icw1) 	mas_ltim <= master_writedata[3];
end

reg [2:0] mas_init_byte_expected;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               mas_init_byte_expected <= 3'd0;
    else if(mas_init_icw1)                          mas_init_byte_expected <= 3'd2;
    else if(mas_init_icw2)                          mas_init_byte_expected <= 3'd3;
    else if(mas_init_icw3 && mas_init_requires_4)   mas_init_byte_expected <= 3'd4;
end

reg [2:0] mas_lowest_priority;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                               mas_lowest_priority <= 3'd7;
    else if(mas_init_icw1)                                                          mas_lowest_priority <= 3'd7;
    else if(mas_ocw2 && master_writedata == 8'hA0)                                  mas_lowest_priority <= mas_lowest_priority + 3'd1;  //rotate on non-specific EOI
    else if(mas_ocw2 && { master_writedata[7:3], 3'b000 } == 8'hC0)                 mas_lowest_priority <= master_writedata[2:0];       //set priority
    else if(mas_ocw2 && { master_writedata[7:3], 3'b000 } == 8'hE0)                 mas_lowest_priority <= master_writedata[2:0];       //rotate on specific EOI
    else if(mas_acknowledge_not_spurious && mas_auto_eoi && mas_rotate_on_aeoi)     mas_lowest_priority <= mas_lowest_priority + 3'd1;  //rotate on AEOI
end

reg [7:0] mas_imr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           mas_imr <= 8'hFF;
    else if(mas_init_icw1)      mas_imr <= 8'h00;
    else if(mas_ocw1)           mas_imr <= master_writedata;
end

wire [7:0] mas_interrupt_input = { interrupt_input[7:3], sla_current_irq, interrupt_input[1:0] };

wire [7:0] mas_edge_detect = {
    interrupt_input[7] == 1'b1    && interrupt_last[7] == 1'b0,
    interrupt_input[6] == 1'b1    && interrupt_last[6] == 1'b0,
    interrupt_input[5] == 1'b1    && interrupt_last[5] == 1'b0,
    interrupt_input[4] == 1'b1    && interrupt_last[4] == 1'b0,
    interrupt_input[3] == 1'b1    && interrupt_last[3] == 1'b0,
    sla_current_irq == 1'b1       && sla_current_irq_last == 1'b0,
    interrupt_input[1] == 1'b1    && interrupt_last[1] == 1'b0,
    interrupt_input[0] == 1'b1    && interrupt_last[0] == 1'b0
};

reg [7:0] mas_irr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       mas_irr <= 8'h00;
    else if(mas_init_icw1)                  mas_irr <= 8'h00;
    else if(mas_acknowledge_not_spurious)   mas_irr <= (mas_irr & mas_interrupt_input & ~(mas_interrupt_vector_bits)) | ((~(mas_ltim))? mas_edge_detect : mas_interrupt_input);
    else                                    mas_irr <= (mas_irr & mas_interrupt_input)                                | ((~(mas_ltim))? mas_edge_detect : mas_interrupt_input);
end

wire [7:0] mas_writedata_mask =
    (master_writedata[2:0] == 3'd0)?    8'b00000001 :
    (master_writedata[2:0] == 3'd1)?    8'b00000010 :
    (master_writedata[2:0] == 3'd2)?    8'b00000100 :
    (master_writedata[2:0] == 3'd3)?    8'b00001000 :
    (master_writedata[2:0] == 3'd4)?    8'b00010000 :
    (master_writedata[2:0] == 3'd5)?    8'b00100000 :
    (master_writedata[2:0] == 3'd6)?    8'b01000000 :
                                        8'b10000000;

wire mas_isr_clear = 
    (mas_polled && master_read_valid) || //polling
    (mas_ocw2 && (master_writedata == 8'h20 || master_writedata == 8'hA0)); //non-specific EOI or rotate on non-specific EOF
                                        
reg [7:0] mas_isr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   mas_isr <= 8'h00;
    else if(mas_init_icw1)                                              mas_isr <= 8'h00;
    else if(mas_ocw2 && { master_writedata[7:3], 3'b000 } == 8'h60)     mas_isr <= mas_isr & ~(mas_writedata_mask);                     //clear on specific EOI
    else if(mas_ocw2 && { master_writedata[7:3], 3'b000 } == 8'hE0)     mas_isr <= mas_isr & ~(mas_writedata_mask);                     //clear on rotate on specific EOI
    else if(mas_isr_clear)                                              mas_isr <= mas_isr & ~(mas_selected_shifted_isr_first_bits);    //clear on polling or non-specific EOI (with or without rotate)
    else if(mas_acknowledge_not_spurious && ~(mas_auto_eoi))            mas_isr <= mas_isr | mas_interrupt_vector_bits;                 //set
end

reg [4:0] mas_interrupt_offset;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mas_interrupt_offset <= 5'd1;
    else if(mas_init_icw2)  mas_interrupt_offset <= master_writedata[7:3];
end

reg mas_auto_eoi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mas_auto_eoi <= 1'b0;
    else if(mas_init_icw1)  mas_auto_eoi <= 1'b0;
    else if(mas_init_icw4)  mas_auto_eoi <= master_writedata[1];
end

reg mas_rotate_on_aeoi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   mas_rotate_on_aeoi <= 1'b0;
    else if(mas_init_icw1)                              mas_rotate_on_aeoi <= 1'b0;
    else if(mas_ocw2 && master_writedata[6:0] == 7'd0)  mas_rotate_on_aeoi <= master_writedata[7];
end

wire [7:0] mas_selected_prepare = mas_irr & ~(mas_imr) & ~(mas_isr);

wire [7:0] mas_selected_shifted =
    (mas_lowest_priority == 3'd7)?      mas_selected_prepare :
    (mas_lowest_priority == 3'd0)?      { mas_selected_prepare[0],   mas_selected_prepare[7:1] } :
    (mas_lowest_priority == 3'd1)?      { mas_selected_prepare[1:0], mas_selected_prepare[7:2] } :
    (mas_lowest_priority == 3'd2)?      { mas_selected_prepare[2:0], mas_selected_prepare[7:3] } :
    (mas_lowest_priority == 3'd3)?      { mas_selected_prepare[3:0], mas_selected_prepare[7:4] } :
    (mas_lowest_priority == 3'd4)?      { mas_selected_prepare[4:0], mas_selected_prepare[7:5] } :
    (mas_lowest_priority == 3'd5)?      { mas_selected_prepare[5:0], mas_selected_prepare[7:6] } :
                                        { mas_selected_prepare[6:0], mas_selected_prepare[7] };
    
wire [7:0] mas_selected_shifted_isr =
    (mas_lowest_priority == 3'd7)?      mas_isr :
    (mas_lowest_priority == 3'd0)?      { mas_isr[0],   mas_isr[7:1] } :
    (mas_lowest_priority == 3'd1)?      { mas_isr[1:0], mas_isr[7:2] } :
    (mas_lowest_priority == 3'd2)?      { mas_isr[2:0], mas_isr[7:3] } :
    (mas_lowest_priority == 3'd3)?      { mas_isr[3:0], mas_isr[7:4] } :
    (mas_lowest_priority == 3'd4)?      { mas_isr[4:0], mas_isr[7:5] } :
    (mas_lowest_priority == 3'd5)?      { mas_isr[5:0], mas_isr[7:6] } :
                                        { mas_isr[6:0], mas_isr[7] };

wire [2:0] mas_selected_shifted_isr_first =
    (mas_selected_shifted_isr[0])?  3'd0 :
    (mas_selected_shifted_isr[1])?  3'd1 :
    (mas_selected_shifted_isr[2])?  3'd2 :
    (mas_selected_shifted_isr[3])?  3'd3 :
    (mas_selected_shifted_isr[4])?  3'd4 :
    (mas_selected_shifted_isr[5])?  3'd5 :
    (mas_selected_shifted_isr[6])?  3'd6 :
                                    3'd7;
    
wire [2:0] mas_selected_shifted_isr_first_norm = mas_lowest_priority + mas_selected_shifted_isr_first + 3'd1;

wire [7:0] mas_selected_shifted_isr_first_bits =
    (mas_selected_shifted_isr_first_norm == 3'd0)?  8'b00000001 :
    (mas_selected_shifted_isr_first_norm == 3'd1)?  8'b00000010 :
    (mas_selected_shifted_isr_first_norm == 3'd2)?  8'b00000100 :
    (mas_selected_shifted_isr_first_norm == 3'd3)?  8'b00001000 :
    (mas_selected_shifted_isr_first_norm == 3'd4)?  8'b00010000 :
    (mas_selected_shifted_isr_first_norm == 3'd5)?  8'b00100000 :
    (mas_selected_shifted_isr_first_norm == 3'd6)?  8'b01000000 :
                                                    8'b10000000;

wire [2:0] mas_selected_index =
    (mas_selected_shifted[0])?      3'd0 :
    (mas_selected_shifted[1])?      3'd1 :
    (mas_selected_shifted[2])?      3'd2 :
    (mas_selected_shifted[3])?      3'd3 :
    (mas_selected_shifted[4])?      3'd4 :
    (mas_selected_shifted[5])?      3'd5 :
    (mas_selected_shifted[6])?      3'd6 :
                                    3'd7;

wire mas_irq = mas_selected_prepare != 8'd0 && (mas_special_mask || mas_selected_index < mas_selected_shifted_isr_first);

wire [2:0] mas_irq_value = (mas_irq)? mas_lowest_priority + mas_selected_index + 3'd1 : 3'd7;

reg mas_current_irq;    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           mas_current_irq <= 1'b0;
    else if(mas_init_icw1)      mas_current_irq <= 1'b0;
    else if(mas_acknowledge)    mas_current_irq <= 1'b0;
    else if(mas_irq)            mas_current_irq <= 1'b1;
end

wire mas_acknowledge_not_spurious = (mas_polled && master_read_valid) || (interrupt_done && ~(mas_spurious));
wire mas_acknowledge              = (mas_polled && master_read_valid) || interrupt_done;

wire mas_spurious_start = mas_current_irq && ~(interrupt_done) && ~(mas_irq);

reg mas_spurious;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       mas_spurious <= 1'd0;
    else if(mas_init_icw1)                  mas_spurious <= 1'b0;
    else if(mas_spurious_start)             mas_spurious <= 1'b1;
    else if(mas_acknowledge || mas_irq)     mas_spurious <= 1'b0;
end

reg mas_sla_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               mas_sla_active <= 1'b0;
    else if(mas_init_icw1)                                          mas_sla_active <= 1'b0;
    else if(mas_acknowledge)                                        mas_sla_active <= 1'b0;
    else if((mas_irq || mas_current_irq) && mas_irq_value != 3'd2)  mas_sla_active <= 1'b0;
    else if((mas_irq || mas_current_irq) && mas_irq_value == 3'd2)  mas_sla_active <= 1'b1;
end

//------------------------------------------------------------------------------

wire [7:0] mas_interrupt_vector_bits = (mas_sla_active)? 8'b00000100 : interrupt_vector_bits;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           interrupt_do <= 1'b0;
    else if(mas_init_icw1)      interrupt_do <= 1'b0;
    else if(mas_acknowledge)    interrupt_do <= 1'b0;
    else if(mas_irq)            interrupt_do <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               interrupt_vector <= 8'd0;
    else if(mas_init_icw1)                                          interrupt_vector <= 8'd0;
    else if((mas_irq || mas_current_irq) && mas_irq_value != 3'd2)  interrupt_vector <= { mas_interrupt_offset, mas_irq_value };
    else if((mas_irq || mas_current_irq) && mas_irq_value == 3'd2)  interrupt_vector <= { sla_interrupt_offset, sla_irq_value };
end

wire [7:0] interrupt_vector_bits =
    (interrupt_vector[2:0] == 3'd0)?    8'b00000001 :
    (interrupt_vector[2:0] == 3'd1)?    8'b00000010 :
    (interrupt_vector[2:0] == 3'd2)?    8'b00000100 :
    (interrupt_vector[2:0] == 3'd3)?    8'b00001000 :
    (interrupt_vector[2:0] == 3'd4)?    8'b00010000 :
    (interrupt_vector[2:0] == 3'd5)?    8'b00100000 :
    (interrupt_vector[2:0] == 3'd6)?    8'b01000000 :
                                        8'b10000000;

//------------------------------------------------------------------------------
    
// synthesis translate_off
wire _unused_ok = &{ 1'b0, interrupt_last[15:1], sla_selected_shifted[7],
                           sla_selected_shifted_isr[7], mas_interrupt_input[0],
                           mas_selected_shifted[7], mas_selected_shifted_isr[7], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
