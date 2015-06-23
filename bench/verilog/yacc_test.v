//YACC Test Bench
//Apr.5.2005 Tak.Sugawara

`include "define.h"
`timescale 1ns/1ps

module yacc_test;
	reg clock=0;
	reg Reset=0;
	reg int_req_usr=0;
	reg RXD=1'b1;
	wire TXD;
	wire [31:0] mem_data_w;
	wire mem_write;
	wire [15:0] mem_address;
	always #10 clock=~clock;



	initial begin
	//	$dumpfile("yacc_test.vcd");
	//	$dumpvars(3,yacc_test.cpu.d1.ram,yacc_test.RXD);
		Reset=0;
		#800 Reset=1;
	end	

`ifdef RTL_SIMULATION
 yacc cpu(.clock(clock),.Async_Reset(Reset),.MemoryWData(mem_data_w),
		  .MWriteFF(mem_write),
		  .data_port_address(mem_address),.RXD(RXD),.TXD(TXD));
`else
	yacc cpu(.clock(clock),.Async_Reset(Reset),	   .RXD(RXD),.TXD(TXD));
	
`endif








	task Cprint;// String OUT until the byte 00 or xx detected with least Byte first and justified.
		integer i;
		begin :Block
			i=0;
			while (1) begin
				if (char_buffer[i*8 +:8] ===8'h00 || char_buffer[i*8 +:8]===8'hxx) begin
						disable Block;
				end	
				$write("%c",char_buffer[i*8 +:8]);
				i=i+1;  
			end
		end
	endtask

   reg [0:640*2-1] char_buffer;
   integer  counter=0;    
   always @ (posedge clock ) begin
            if ((mem_write === 1'b1)) begin 
           	   if (mem_address==`Print_Port_Address) begin
				if (mem_data_w[7:0]===8'h00) begin
					char_buffer[counter*8 +:8]=mem_data_w[7:0];
					if (char_buffer[0  +:8*7]==="$finish") begin
							$stop;				
							
					end else if (char_buffer[0  +:8*5]==="$time") begin
							$display("Current Time on Simulation=%d",$time);				
							
					end else  Cprint;//$write("%s",char_buffer);

					for (counter=0; counter< 80*2; counter=counter+1) begin
						char_buffer[counter*8 +:8]=8'h00;
					end
					counter=0;
				
				end else begin
					char_buffer[counter*8 +:8]=mem_data_w[7:0];
					counter=counter+1;
				end
		   end
       	   else if (mem_address==`Print_CAHR_Port_Address) begin
				$write("%h ",mem_data_w[7:0]);
		   end else if (mem_address==`Print_INT_Port_Address) begin
				$write("%h ",mem_data_w[15:0]);//Little Endian 
		   end else if (mem_address==`Print_LONG_Port_Address) begin
				$write("%h ",mem_data_w[31:0]);//Big Endian
		   end 
	end //if
   end //always


//uart read port
  wire [7:0] buffer_reg;
  wire int_req;
  reg sync_reset;
  integer i=0;
  localparam LF=8'h0a;	
	always @(posedge clock, negedge Reset) begin
		if (!Reset) sync_reset <=1'b1;
		else sync_reset<=1'b0;
	end
	
   

   uart_read   uart_read_port( .sync_reset(sync_reset), .clk(clock), .rxd(TXD),.buffer_reg(buffer_reg), .int_req(int_req));

	always @(posedge int_req) begin
		begin :local
		
			reg [7:0] local_mem [0:1000];
		
			
			if (i>=1000) $stop;//assert(0);

			if (buffer_reg==LF) begin :local2 //pop stack
				integer j;
				j=0;
				while( j < i) begin
					$write( "%c",local_mem[j]);
					j=j+1;
				end
				$write("     : time=%t\n",$time);
				i=0;//clear stack	
			end else begin//push stack
				
				local_mem[i]=buffer_reg;
				i=i+1;
			 end
		end
		
	end
endmodule

