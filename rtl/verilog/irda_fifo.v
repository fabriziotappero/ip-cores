`include "irda_defines.v"

module irda_fifo (clk, wb_rst_i, fifo_clear,
		fifo_dat_i, fifo_add, fifo_remove, 
		fifo_dat_o, fifo_overrun, fifo_underrun, fifo_count);

parameter	fifo_size		=	`IRDA_FIFO_SIZE,
				fifo_width		=	`IRDA_FIFO_WIDTH,
				fifo_pointer_w	=	`IRDA_FIFO_POINTER_W;

input							clk;
input							wb_rst_i;
input							fifo_clear; // clear does the same as reset
input	[fifo_width-1:0]	fifo_dat_i;
input							fifo_add;
input							fifo_remove;

output	[fifo_width-1:0]	fifo_dat_o;
output							fifo_overrun;
output							fifo_underrun;
output	[fifo_pointer_w:0]	fifo_count;

wire	[fifo_width-1:0]		fifo_dat_i;
wire	[fifo_width-1:0]		fifo_dat_o;
reg								fifo_overrun;
reg								fifo_underrun;
reg	[fifo_pointer_w:0]	fifo_count;

reg	[fifo_width-1:0]		fifo_mem[fifo_size-1:0];		// fifo memory
reg	[fifo_pointer_w-1:0]	add_pos;
reg	[fifo_pointer_w-1:0]	remove_pos;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		fifo_overrun	<= #1 1'b0;
		fifo_underrun	<= #1 1'b0;
		fifo_count		<= #1 0;
		add_pos			<= #1 0;
		remove_pos		<= #1 0;
		// fifo memory is not reset
	end else if (fifo_clear) begin
		fifo_overrun	<= #1 1'b0;
		fifo_underrun	<= #1 1'b0;
		fifo_count		<= #1 0;
		add_pos			<= #1 0;
		remove_pos		<= #1 0;
	end else begin
		case ({fifo_add, fifo_remove})
			2'b00:	begin
						fifo_overrun		<= #1 1'b0;
						fifo_underrun	<= #1 1'b0;
					end
			2'b01:	begin
						if (fifo_count==0)
							fifo_underrun <= #1 1'b1;
						else begin
							remove_pos  <= #1 remove_pos + 1;
							fifo_underrun    <= #1 1'b0;
							fifo_count	<= #1 fifo_count - 1;
						end
						fifo_overrun <= #1 1'b0;
					end
			2'b10:	begin	// add data
						if (fifo_count==fifo_size)
							fifo_overrun	<= #1 1'b1;
						else begin
							fifo_mem[add_pos]	<= #1 fifo_dat_i;
							add_pos				<= #1 add_pos + 1;
							fifo_overrun				<= #1 1'b0;
							fifo_count			<= #1 fifo_count + 1;
						end
						fifo_underrun <= #1 1'b0;
					end
			2'b11:	begin
						fifo_mem[add_pos] <= #1 fifo_dat_i;
						add_pos <= #1 add_pos + 1;
						remove_pos <= #1 remove_pos + 1;
						fifo_overrun		<= #1 1'b0;
						fifo_underrun	<= #1 1'b0;
					end
		endcase
	end
end

// Data out is always the current word being read.
// Remove moves to the next data entry and "removes" the value the fifo
assign	fifo_dat_o = fifo_mem[remove_pos];
	
endmodule
