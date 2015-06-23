//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Kermin Fleming, kfleming@mit.edu 
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//


/***
 * 
 * This module implements a parametric verilog sized fifo.  This particular
 * sized fifo will synthesize on to Xilinx block rams.  The fifo is parametric 
 * in terms of both data width and the number of data stored in the fifo.  
 * the interface is gaurded.  The fifo is not loopy.
 * The methods supported by the FIFO are clear, dequeue, enqueue, notFull,
 * and notEmpty
 * 
 ***/


module BRAMFIFOF(CLK, RST_N,
            D_IN, CLR, DEQ,
            ENQ, D_OUT, FULL_N, EMPTY_N);

   // synopsys template   
   parameter                   log_data_count = 0;
   parameter                   data_count = 1;
   parameter                   data_width = 1;
   
   input                       CLK;
   input                       RST_N;   

   input [data_width - 1 : 0]  D_IN;
   input                       CLR;
   input                       DEQ;
   input                       ENQ;  
  
   output [data_width - 1 : 0] D_OUT;
   output                      FULL_N;
   output                      EMPTY_N;



   reg [data_width - 1 : 0]    arr[0:data_count]; /*synthesis syn_ramstyle = "block_ram"*/

   reg                          skid_flag;   
   reg [log_data_count + 2 : 0] fifo_data_count;
   reg [log_data_count + 2 : 0] read_ptr;
   reg [log_data_count + 2 : 0] read_ptr_current;
   reg [log_data_count + 2 : 0] write_ptr;   
   reg [data_width - 1 : 0]    skid_buffer; // this is a fast output buffer
   reg [data_width - 1 : 0]    RAM_OUT;
   
      
   assign D_OUT = (skid_flag)?skid_buffer:RAM_OUT;

   assign FULL_N = !(fifo_data_count == data_count);
   assign EMPTY_N = !(fifo_data_count == 0);
   
   integer x;

   always@(*)
     begin
       if(DEQ)
         begin
           read_ptr_current = (read_ptr  == data_count)?0:(read_ptr + 1); 
         end
       else 
         begin
           read_ptr_current = read_ptr;
         end 
     end

 

   always@(posedge CLK)
     begin
       if (!RST_N)
         begin  //Make simulation behavior consistent with Xilinx synthesis
           // synopsys translate_off
           for (x = 0; x < data_count + 1; x = x + 1)
           begin
             arr[x] <= 0;
           end
           // synopsys translate_on
           fifo_data_count <= 0;
           skid_buffer <= 0;
           skid_flag <= 0;
           read_ptr <= 0;
           write_ptr <= 0;
           //$display("Params: data_count: %d, log_data_count: %d, data_width: %d", data_count, log_data_count, data_width);
         end
       else
         begin
           // assign output buffer
           skid_buffer <= D_IN;
           
           if(CLR) 
             begin 
               skid_flag <= 0;
             end 
           else if(ENQ && ((fifo_data_count == 0) || ((fifo_data_count == 1) && DEQ)))
             begin
               //$display("Enque to output buffer");
               skid_flag <= 1;
             end
           else 
             begin
               skid_flag <= 0;               
             end
          
           // write_ptr
            if(CLR)
              begin
                write_ptr <= 0;
              end
            else if(ENQ)
              begin
                //$display("Enque to BRAM[%d]: %d", write_ptr,D_IN);
                write_ptr <= (write_ptr  == data_count)?0:(write_ptr + 1);
              end 
            else 
              begin
                write_ptr <= write_ptr;
              end
              
           //read_ptr
            if(CLR)
              begin
                read_ptr <= 0;
              end         
            else if(DEQ)
              begin
                //$display("Advancing read ptr");
                read_ptr <= (read_ptr  == data_count)?0:(read_ptr + 1);   
              end  
            else 
              begin
                read_ptr <= read_ptr;
              end
             
           // assign fifo data_count
           if(CLR)
             begin
               fifo_data_count <= 0;
             end          
           else if(ENQ && DEQ)
             begin
               fifo_data_count <= fifo_data_count;
             end 
           else if(ENQ)
             begin
               fifo_data_count <= fifo_data_count + 1;
             end
           else if(DEQ)
             begin
               fifo_data_count <= fifo_data_count - 1;
             end    
           else 
             begin
               fifo_data_count <= fifo_data_count;
             end 
           if(ENQ)
             begin
               arr[write_ptr] <= D_IN;
             end
           RAM_OUT <= arr[read_ptr_current];
 
         end
     end // always@ (posedge CLK)

endmodule