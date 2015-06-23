`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:26:15 08/11/2008 
// Design Name: 
// Module Name:    Data_buffer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//DEFINES
`define DEL 1
`define FIFO_DEPTH 5
`define FIFO_HALF 3
`define FIFO_BITS 3
`define FIFO_WIDTH 8


module Data_buffer(CLK, reset_n, data_in, read_n, write_n, data_out, full, empty, half);
//INPUTS
    input CLK;
    input reset_n;//active low reset
    input [`FIFO_WIDTH-1:0] data_in;//data input to FIFO
    input read_n;//Read FIFO
    input write_n;//Write FIFO
//OUTPUTS	 
    output [`FIFO_WIDTH-1:0] data_out;//FIFO output DATA
    output full;//FIFO is Full
    output empty;//FIFO is empty
    output half;//FIFO is half full or more
//SIGNAL DECLARATIONS
	 wire CLK;
	 wire reset_n;
	 wire [`FIFO_WIDTH-1:0] data_in;
	 wire read_n;
	 wire write_n;
	 reg [`FIFO_WIDTH-1:0] data_out;
	 wire full;
	 wire empty;
	 wire half;
	 reg [`FIFO_WIDTH-1:0] fifo_mem[0:`FIFO_DEPTH-1];//The fifo memory
	 reg [`FIFO_BITS-1:0] counter;//FIFO read pointer points to the location in the FIFO to read form next
	 reg [`FIFO_BITS-1:0] rd_pointer;
	 reg [`FIFO_BITS-1:0] wr_pointer;
//ASSIGN STATEMENTS
assign #`DEL full = (counter == `FIFO_DEPTH) ? 1'b1 : 1'b0;
assign #`DEL empty = (counter == 0) ? 1'b1 : 1'b0;
assign #`DEL half = (counter >= `FIFO_HALF) ? 1'b1 : 1'b0;
//look at the edges of reset_n
always @(reset_n)begin
		if(~reset_n)begin
			//RESET the FIFO pointer
			#`DEL;
			assign rd_pointer = `FIFO_BITS'b0;
			assign wr_pointer = `FIFO_BITS'b0;
			assign counter = `FIFO_BITS'b0;
		end
		else begin
			#`DEL;
			deassign rd_pointer;
			deassign wr_pointer;
			deassign counter;
		end
end
//Look at the rising edge of the clock
always @(posedge CLK) begin
			if(~read_n)begin
			//check for FIFO underflow
				if(counter == 0)begin
					$display("\n ERROR at time %0t:",$time);
					$display("FIFO Underflow\n");
					$stop;
				end
			//if there is a simultaneous read and write, there is no change to the counter
				if(write_n)begin
					//decrement the FIFO counter
					counter <= #`DEL counter-1;
				end
					//output the data
					data_out <= #`DEL fifo_mem[rd_pointer];
			
					//increment the read pointer
					//Check if the read pointer has gone beyond the depth of the FIFO, if so set it back to the beginning of the FIFO
				if(rd_pointer == `FIFO_DEPTH-1)
					rd_pointer <= #`DEL `FIFO_BITS'b0;
				else
					rd_pointer <= #`DEL rd_pointer + 1;	
			end
			if(~write_n)begin
				//check for the FIFO overflow
				if(counter >= `FIFO_DEPTH)begin
					$display("\nERROR at time %0t:", $time);
					$display("FIFO Overflow\n");
					$stop;
				end
				//	if there is a simultaneous read and write, there is no change to the counter
				if(read_n) begin
				//increment the FIFO counter
				counter <= #`DEL counter + 1;
				end
				//store the data
				fifo_mem[wr_pointer] <= #`DEL data_in;
				//increment the write pointer
				//check if the write pointer has gone beyond the depth of the FIFO, if so set it back to the beginning of the FIFO
				if(wr_pointer == `FIFO_DEPTH-1)
					wr_pointer <= #`DEL `FIFO_BITS'b0;
				else
					wr_pointer <= wr_pointer + 1;
			end		
		end		
endmodule

