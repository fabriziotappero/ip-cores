/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Encoder Core - Verilog                                ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

/* This FIFO is used for the ff_checker module.  */

`timescale 1ns / 100ps

module sync_fifo_ff (clk, rst, read_req, write_data, write_enable, rollover_write,
read_data, fifo_empty, rdata_valid);
input	clk;
input	rst;
input	read_req;
input [90:0] write_data;
input write_enable;
input rollover_write;
output [90:0]   read_data;  
output  fifo_empty; 
output	rdata_valid;
   
reg [4:0] read_ptr;
reg [4:0] write_ptr;
reg [90:0] mem [0:15];
reg [90:0] read_data;
reg rdata_valid;
wire [3:0] write_addr = write_ptr[3:0];
wire [3:0] read_addr = read_ptr[3:0];	
wire read_enable = read_req && (~fifo_empty);
assign fifo_empty = (read_ptr == write_ptr);


always @(posedge clk)
  begin
   if (rst)
      write_ptr <= {(5){1'b0}};
   else if (write_enable & !rollover_write)
      write_ptr <= write_ptr + {{4{1'b0}},1'b1};
   else if (write_enable & rollover_write)
      write_ptr <= write_ptr + 5'b00010;
   // A rollover_write means that there have been a total of 4 FF's
   // that have been detected in the bitstream.  So an extra set of 32
   // bits will be put into the bitstream (due to the 4 extra 00's added
   // after the 4 FF's), and the input data will have to 
   // be delayed by 1 clock cycle as it makes its way into the output
   // bitstream.  So the write_ptr is incremented by 2 for a rollover, giving
   // the output the extra clock cycle it needs to write the 
   // extra 32 bits to the bitstream.  The output
   // will read the dummy data from the FIFO, but won't do anything with it,
   // it will be putting the extra set of 32 bits into the bitstream on that
   // clock cycle.
  end

always @(posedge clk)
begin
   if (rst)
      rdata_valid <= 1'b0;
   else if (read_enable)
      rdata_valid <= 1'b1;
   else
   	  rdata_valid <= 1'b0;  
end
  
always @(posedge clk)
 begin
   if (rst)
      read_ptr <= {(5){1'b0}};
   else if (read_enable)
      read_ptr <= read_ptr + {{4{1'b0}},1'b1};
end

// Mem write
always @(posedge clk)
  begin
   if (write_enable)
     mem[write_addr] <= write_data;
  end
// Mem Read
always @(posedge clk)
  begin
   if (read_enable)
      read_data <= mem[read_addr];
  end
  
endmodule
