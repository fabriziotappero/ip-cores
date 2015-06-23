//
// atactrl.v -- parallel ATA controller
//


`define ADDR_ALTERNATE_STATUS	4'b0110
`define ADDR_DEVICE_CONTROL	4'b0110
`define ADDR_DEVICE_ADDRESS	4'b0111
`define ADDR_DATA		4'b1000
`define ADDR_ERROR		4'b1001
`define ADDR_FEATURES		4'b1001
`define ADDR_SECTOR_COUNT	4'b1010
`define ADDR_LBA0		4'b1011
`define ADDR_LBA1		4'b1100
`define ADDR_LBA2		4'b1101
`define ADDR_LBA3_DRV		4'b1110
`define ADDR_STATUS		4'b1111
`define ADDR_COMMAND		4'b1111


module ata_ctrl (
	input clk, reset,

	input bus_en, bus_wr,
	input [19:2] bus_addr,
	input [31:0] bus_din,
	output [31:0] bus_dout,
	output bus_wait,
	output bus_irq,

	inout [15:0] ata_d,
	output [2:0] ata_a,
	output ata_cs0_n, ata_cs1_n,
	output ata_dior_n, ata_diow_n,
	input ata_intrq,
	input ata_dmarq,
	output ata_dmack_n,
	input ata_iordy
);

// --- ATA IRQ line debouncing
reg debounced_ata_intrq, prev_ata_intrq;
reg [3:0] ata_intrq_debounce_counter;

// --- disk buffer

// interface to the bus
wire buffer_bus_wait;
wire [31:0] buffer_bus_dout;

// interface to the state machine
wire buffer_ata_write;
wire [11:1] buffer_ata_addr;
wire [15:0] buffer_ata_din;
wire [15:0] buffer_ata_dout;
wire buffer_bus_addressed;
wire buffer_bus_write;
reg buffer_bus_second_cycle;

ata_buffer buffer1 (
    .clk (clk),
    .bus_write (buffer_bus_write),
    .bus_addr (bus_addr [11:2]),
    .bus_din (bus_din),
    .bus_dout (buffer_bus_dout),
    .ata_write (buffer_ata_write),
    .ata_addr (buffer_ata_addr),
    .ata_din (buffer_ata_din),
    .ata_dout (buffer_ata_dout)
);

assign buffer_bus_addressed = bus_addr [19];
assign buffer_bus_wait = bus_en & !buffer_bus_second_cycle;
assign buffer_bus_write = bus_en & bus_wr &
    buffer_bus_addressed & !buffer_bus_second_cycle;

// --- control registers

// interface to the bus
wire control_bus_wait;
wire [31:0] control_bus_dout;

// interface to the state machine
reg [31:0] capacity;
reg [27:0] requestedSectorAddress;
reg [3:0] requestedSectorCount;
wire commandUnlocked;
reg enableInterrupts, requestedWrite, errorOutput;
reg operationFinished, diskInitialized;
wire control_bus_addressed;

assign control_bus_addressed = !bus_addr[19];
assign control_bus_wait = 0;
assign control_bus_dout =
	(bus_addr [3:2] == 2'b00) ? {ata_dmarq, 25'd0,
		diskInitialized, operationFinished,
		errorOutput, requestedWrite,
		enableInterrupts, 1'b0} :
	(bus_addr [3:2] == 2'b01) ? { 28'd0, requestedSectorCount } :
	(bus_addr [3:2] == 2'b10) ? { 4'd0, requestedSectorAddress } :
	capacity;

// --- ATA IO component

reg io_en, io_write;
wire io_wait;
reg [3:0] io_addr;
reg [15:0] io_data_out;
wire [15:0] io_data_in;

assign ata_dmack_n = 1'b1;
ata_io io (
	.clk(clk),
	.reset(reset),
	.bus_en(io_en),
	.bus_wr(io_write),
	.bus_addr(io_addr),
	.bus_din(io_data_out),
	.bus_dout(io_data_in),
	.bus_wait(io_wait),
	.ata_d(ata_d),
	.ata_a(ata_a),
	.ata_cs0_n(ata_cs0_n),
	.ata_cs1_n(ata_cs1_n),
	.ata_dior_n(ata_dior_n),
	.ata_diow_n(ata_diow_n),
	.ata_iordy(ata_iordy)
);

// --- bus interface

assign bus_dout = bus_addr [19] ? buffer_bus_dout : control_bus_dout;
assign bus_wait = bus_addr [19] ? buffer_bus_wait : control_bus_wait;
assign bus_irq = enableInterrupts & operationFinished;

// --- state machine

reg [4:0] state;
reg [7:0] aux_counter;
reg [2:0] sector_counter;
/*
    STARTUP DEBUG LOGGING
reg [15:0] debugTimer;
*/

wire startBit;
assign commandUnlocked = (state == 5'd8);
assign startBit = bus_en & bus_wr &
    (!bus_addr [19]) & (bus_addr [3:2] == 2'b00) &
    bus_din [0];

assign buffer_ata_write = (state == 5'd16) & (!io_wait);
assign buffer_ata_addr = {sector_counter, aux_counter [7:0]};
assign buffer_ata_din = io_data_in;

always @(posedge clk) begin
    if (reset) begin

        prev_ata_intrq <= 1'b0;
        debounced_ata_intrq <= 1'b0;
        ata_intrq_debounce_counter <= 4'b0;

        buffer_bus_second_cycle <= 1'b0;

    	capacity <= 32'd0;
    	requestedSectorAddress <= 32'd0;
    	requestedSectorCount <= 4'b0000;
	
    	enableInterrupts <= 1'b0;
    	requestedWrite <= 1'b0;
    	errorOutput <= 1'b0;
    	operationFinished <= 1'b0;
    	diskInitialized <= 1'b0;

    	io_en <= 1'b0;
    	io_write <= 1'b0;
    	io_addr <= 32'd0;
    	io_data_out <= 16'd0;

    	state <= 5'd0;
    	aux_counter <= 8'd0;
        sector_counter <= 3'd0;

/*
    STARTUP DEBUG LOGGING
        debugTimer <= 16'd0;
*/

    end else begin

        if (ata_intrq == prev_ata_intrq) begin
            if (ata_intrq_debounce_counter == 4'd0) begin
                debounced_ata_intrq <= ata_intrq;
            end else begin
                ata_intrq_debounce_counter <= ata_intrq_debounce_counter - 1;
            end
        end else begin
            ata_intrq_debounce_counter <= 4'd10;
        end
        prev_ata_intrq <= ata_intrq;

/*
    STARTUP DEBUG LOGGING
        debugTimer <= debugTimer + 1;
*/

        if (bus_en)
            buffer_bus_second_cycle <= !buffer_bus_second_cycle;
        else
            buffer_bus_second_cycle <= 1'b0;

    	if (bus_en & bus_wr & control_bus_addressed) begin
    		if (bus_addr [3:2] == 2'b00) begin
			    operationFinished <= bus_din [4];
    			if (commandUnlocked)
				    requestedWrite <= bus_din [2];
			    enableInterrupts <= bus_din [1];
		    end
		    else if (bus_addr [3:2] == 2'b01 & commandUnlocked) begin
    			requestedSectorCount <= bus_din [3:0];
		    end
		    else if (bus_addr [3:2] == 2'b10 & commandUnlocked) begin
    			requestedSectorAddress <= bus_din [27:0];
		    end
	    end

    	if (!io_wait) begin
/*
    STARTUP DEBUG LOGGING
            buffer_ata_write <= 1;
            if (buffer_ata_addr < 2000)
                buffer_ata_addr <= buffer_ata_addr + 2;
            buffer_ata_din <= io_data_in;
*/
            case (state)
	
    		// startup sequence: ask for access to command regs
		    // and drive
		    5'd0: begin
    			io_en <= 1'b1;
			    io_write <= 1'b0;
			    io_addr <= `ADDR_ALTERNATE_STATUS;
                state <= 5'd1;
		    end
		
    		// startup sequence: wait for command regs and
		    // drive, or select drive 0 if ready
		    5'd1: begin
    			if (io_data_in [7:6] == 2'b01) begin
				    // ready, so select drive 0
				    io_write <= 1'b1;
				    io_addr <= `ADDR_LBA3_DRV;
				    io_data_out <= 8'b11100000;
				    state <= 5'd2;
			    end else begin
    				// busy, so keep asking
			    end
    		end
		
		    // startup sequence: send "identify drive" command
		    5'd2: begin
    			io_write <= 1'b1;
			    io_addr <= `ADDR_COMMAND;
			    io_data_out <= 16'h00ec;
			    state <= 5'd3;
		    end
		
            // wait for the ATA to send an IRQ, then read the status register
		    5'd3: begin
                if (debounced_ata_intrq) begin
                    io_en <= 1'b1;
                    io_write <= 1'b0;
                    io_addr <= `ADDR_STATUS;
    			    aux_counter <= 8'd60;
                    state <= 5'd4;
                end else begin
                    io_en <= 1'b0;
                    io_write <= 1'b0;
                end
		    end


		    // skip 60 words from the data buffer, then read
		    // the high 16 bits of the capacity
            5'd4: begin
       			io_write <= 1'b0;
			    io_addr <= `ADDR_DATA;
			    if (aux_counter == 0) state <= 5'd5;
			    else aux_counter <= aux_counter - 1;
            end
		
    		// store the high 16 bits of the capacity just
		    // read and read the low 16 bits
		    5'd5: begin
    			io_write <= 1'b0;
			    io_addr <= `ADDR_DATA;
			    capacity [15:0] <= io_data_in;
			    state <= 5'd6;
		    end
		
    		// store the low 16 bits of the capacity,
            // then read another 194 words to finish the
            // "identify drive" buffer
		    5'd6: begin
			    capacity [31:16] <= io_data_in;
			    state <= 5'd7;
    			io_write <= 1'b0;
			    io_addr <= `ADDR_DATA;
                aux_counter <= 8'd193; // one is read now
		    end
		
            // skip another 193 words from the buffer
		    5'd7: begin
                if (aux_counter == 0) begin
                    io_en <= 1'b0;
                    io_write <= 1'b0;
                    state <= 5'd8;
                    diskInitialized <= 1'b1;
		        end else begin
                    aux_counter <= aux_counter - 1;
                end
            end

    //----------------------------------------------------------

            // ready and waiting for commands. Only on this
            // state is write access from the on-chip bus
            // allowed. When a request arrives, write the
            // drive/head/lba3 register and goto state 9.
            5'd8: begin
                if (startBit) begin
                    state <= 5'd19;
                    io_en <= 1'b1;
                    io_write <= 1'b0;
                    io_addr <= `ADDR_STATUS;
                end else begin
                    io_en <= 1'b0;
                end
            end

            5'd19: begin
              if (io_data_in[7] == 0) begin
                    state <= 5'd9;
                    io_en <= 1'b1;
                    io_write <= 1'b1;
                    io_addr <= `ADDR_LBA3_DRV;
                    io_data_out <=
                        { 8'd0, 4'b1110, requestedSectorAddress [27:24] };
                    sector_counter <= 3'd0;
              end else begin
                // read status again
              end
            end

            // next, write the lba2 register
            5'd9: begin
                io_addr <= `ADDR_LBA2;
                io_data_out <= { 8'd0, requestedSectorAddress [23:16] };
                state <= 5'd10;
            end

            // next, write the lba1 register
            5'd10: begin
                io_addr <= `ADDR_LBA1;
                io_data_out <= { 8'd0, requestedSectorAddress [15:8] };
                state <= 5'd11;
            end

            // next, write the lba0 register
            5'd11: begin
                io_addr <= `ADDR_LBA0;
                io_data_out <= { 8'd0, requestedSectorAddress [7:0] };
                state <= 5'd12;
            end

            // next, write the sector count register
            5'd12: begin
                io_addr <= `ADDR_SECTOR_COUNT;
                io_data_out <= { 8'd0, 4'd0, requestedSectorCount };
                state <= 5'd13;
            end

            // finally, write the command register
            5'd13: begin
                io_addr <= `ADDR_COMMAND;
                io_data_out <= requestedWrite ? 16'h30 : 16'h20;
                state <= 5'd14;
            end

            // now branch whether reading or writing.
            // for reading, wait for IRQ, then read status
            // for writing, wait for DRQ and simultaneously
            // fetch the first word from the buffer
            5'd14: begin
                if (requestedWrite) begin
                    io_en <= 1'b1;
                    io_write <= 1'b0;
                    io_addr <= `ADDR_STATUS;
                    state <= 5'd17;
                    aux_counter <= 8'd0;
                end else begin
                    if (debounced_ata_intrq) begin
                        io_en <= 1'b1;
                        io_write <= 1'b0;
                        io_addr <= `ADDR_STATUS;
                        state <= 5'd15;
                    end else begin
                        io_en <= 1'b0;
                    end
                end
            end

            // read 256 words of data
            5'd15: begin
                io_en <= 1'b1;
                io_write <= 1'b0;
                io_addr <= `ADDR_DATA;
                aux_counter <= 8'd0;
                state <= 5'd16;
            end

            // sample data in, and read next if needed. Data sampling is
            // done directly by the blockRAM, and the necessary wiring is
            // defined above.
            5'd16: begin
                if (aux_counter == 8'd255) begin
                    if (requestedSectorCount == 4'b0001) begin
                        io_en <= 1'b0;
                        state <= 5'd8;
                        errorOutput <= 1'b0;
                        operationFinished <= 1'b1;
                    end else begin
                        if (debounced_ata_intrq) begin
                            requestedSectorCount <= requestedSectorCount - 1;
                            sector_counter <= sector_counter + 1;
                            io_en <= 1'b1;
                            io_write <= 1'b0;
                            io_addr <= `ADDR_STATUS;
                            state <= 5'd15;
                        end else begin
                            io_en <= 1'b0;
                            // last word of finished sector is sampled
                            // repeatedly here (harmless)
                        end
                    end
                end else begin
                    aux_counter <= aux_counter + 1;
                end
            end

            // if DRQ is not yet set, wait for it. Otherwise send the
            // first data word to the ATA and fetch the next one
            5'd17: begin
                if (io_data_in[7] == 0 && io_data_in[3] == 1) begin
                    io_en <= 1'b1;
                    io_write <= 1'b1;
                    io_addr <= `ADDR_DATA;
                    io_data_out <= buffer_ata_dout;
                    aux_counter <= aux_counter + 1;
                    state <= 5'd18;
                end else begin
                    // read status again
                end
            end

            // write words to the buffer until finished. Note that since
            // an ATA transfer cycle takes at least two clock cycles, the
            // buffer is always read to buffer_ata_dout before that register
            // is used. After the transfer is finished, wait for IRQ, then
            // read the status register and select the correct next state
            // depending on whether more sectors must follow.
            5'd18: begin
                // loop until done. All addressing is done automatically.
                if (aux_counter == 8'd0) begin
                    if (debounced_ata_intrq) begin
                        io_en <= 1'b1;
                        io_write <= 1'b0;
                        io_addr <= `ADDR_STATUS;
                        if (requestedSectorCount == 4'b0001) begin
                            state <= 5'd8;
                            errorOutput <= 1'b0;
                            operationFinished <= 1'b1;
                        end else begin
                            requestedSectorCount <= requestedSectorCount - 1;
                            sector_counter <= sector_counter + 1;
                            state <= 5'd17; 
                        end
                    end else begin
                        io_en <= 1'b0;
                    end
                end else begin
                    io_data_out <= buffer_ata_dout;
                    aux_counter <= aux_counter + 1;
                end
            end

    	    endcase
        end else begin
/*
    STARTUP DEBUG LOGGING
            buffer_ata_write <= 0;
*/
        end
    end
end

endmodule
