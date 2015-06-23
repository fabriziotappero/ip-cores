//---------------------------------------------------------------------------------------
// register file model as a simple memory 
//
//---------------------------------------------------------------------------------------

`include "timescale.v"

module reg_file_model
(
	// global signals 
	clock, reset,
	// internal bus to register file 
	int_address, int_wr_data, int_write,
	int_rd_data, int_read 
);
//---------------------------------------------------------------------------------------
// modules inputs and outputs 
input 			clock;			// global clock input 
input 			reset;			// global reset input 
input	[7:0]	int_address;	// address bus to register file 
input	[7:0]	int_wr_data;	// write data to register file 
input			int_write;		// write control to register file 
input			int_read;		// read control to register file 
output	[7:0]	int_rd_data;	// data read from register file 

// registered outputs
reg [7:0] int_rd_data;

// internal signal  
reg [7:0] reg_file [0:255];   // 256 of 8 bit registers 

//---------------------------------------------------------------------------------------
// internal tasks 
// clear memory 
task clear_reg_file;
reg [8:0] regfile_adr;
begin
   for (regfile_adr = 9'h00; regfile_adr < 9'h80; regfile_adr = regfile_adr + 1) 
   begin
	  reg_file[regfile_adr] = 0;
   end
end
endtask

//---------------------------------------------------------------------------------------
// module implementation 
// register file write 
always @ (posedge clock or posedge reset)
begin 
	if (reset) 
		clear_reg_file;
	else if (int_write)
		reg_file[int_address] <= int_wr_data;
end 

// register file read 
always @ (posedge clock or posedge reset)
begin 
	if (reset) 
		int_rd_data <= 8'h0;
	else if (int_read)
		int_rd_data <= reg_file[int_address];
end 

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
