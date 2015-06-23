// rtl program for i2c_gpio.v

`define		P0_P9_OP	4'b1010 //0x0A
//`define		P0_P3_OP	4'b1011 //0x0B
`define		P0_P3_OP	4'b0111 //0x07
`define		P4_P7_OP	4'b1110 //0xE0
//`define		P8_P9_OP	4'b1101 //0x0D

module i2c_gpio(clk, cs, sr_in, sda_out, sr_out, gpio); 

   input clk,cs;
   input sr_in;
   output sda_out;
   output sr_out;
   output [7:0] gpio;

   reg [7:0] 	sr;   
   reg [7:0] 	addrreg;
   reg 		sda_out;
   reg 		sr_out ;
   reg [7:0] 	gpio;
   reg [7:0] 	ram;
   wire [3:0] 	addr;
   wire [3:0] 	data;	

   assign addr = sr[3:0];
   assign data = sr[7:4];
   always@(posedge clk)
     begin
	if (cs == 1'b0)
	  begin 
             sr_out <= sr[7]; 
	     sr[7:1] <= sr[6:0];
	     sr[0] <= sr_in;
	  end 		
	begin
	   if (addr[0] == 1'b0)               // low bit zero - start bit
	     begin
		if(addr[3:0] == 4'h0E)         // 0xD is the address of the slave
		  begin
	             sda_out = 1'b1;          // high bit for Acknowledge to master
		     if(addr[3]== 1'b1)       // high bit for write
		       begin
			  case (addr[3:0])    // data[3:0] for data write
//			    `P0_P9_OP : gpio[7:4] <= {sr[0], sr[1], sr[2], sr[3], sr[4], sr[5], sr[6], sr[7]};
			    `P0_P3_OP : gpio[3:0] <= {data[0], data[1], data[2], data[3]};
			    `P4_P7_OP : gpio[3:0] <= {data[3], data[2], data[1], data[0]};
//			    `P8_P9_OP : gpio[9:8] <= {sr[0], sr[0]};
//			    default   : gpio[7:0] <= {sr[0], sr[0], sr[0], sr[0],
//						      sr[0], sr[0], sr[0], sr[0]};
			  endcase
			  sda_out = 1'b1;     // high bit for Acknowledge master
		       end
		     else
		       begin
			  sda_out = 1'bz;
		       end
		  end
	     end
	end
     end
endmodule


