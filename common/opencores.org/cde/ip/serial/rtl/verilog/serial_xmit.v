module 
cde_serial_xmit
#(parameter   WIDTH=8,   // Number of data bits
  parameter   SIZE=4     // binary size of shift_cnt, must be able to hold  WIDTH + 4 states       
 )  


(
input  wire              clk,
input  wire              reset,
input  wire              edge_enable,                 // one pulse per bit time for data rate timing
input  wire              parity_enable,               // 0 = no parity bit sent, 1= parity bit sent
input  wire              parity_type,                 // 0= odd,1=even
input  wire              parity_force,                // force parity_type
input  wire              load,                        // start transmiting data
input  wire              start_value,                 // value out at start bit time
input  wire              stop_value,                  // value out for stop bit also used for break
input  wire [WIDTH-1:0]  data,                        // data byte

output  reg              buffer_empty,                // ready for next byte
output  reg              ser_out                      // to pad_ring
                         );
   
reg [SIZE-1:0] 	         shift_cnt;
reg [WIDTH-1:0] 	 shift_buffer;
reg 	  	         parity_calc;
reg                      delayed_edge_enable;


//
//   shift_cnt controls the serial bit out
//  
//   0           Start bit  
//   1-> WIDTH   Data bit lsb first
//   WIDTH+1     Parity bit if enabled
//   2^SIZE-1    Last stop bit and idle
 
always@(posedge clk)
  if(reset || buffer_empty)                                        shift_cnt   <= {SIZE{1'b1}};
  else
  if(!edge_enable)                                                 shift_cnt   <= shift_cnt;
  else
  if(( shift_cnt ==  {SIZE{1'b1}}  ) &&  ! buffer_empty )          shift_cnt   <= {SIZE{1'b0}};
  else
  if ( shift_cnt == WIDTH)               
    case(parity_enable)        
      (1'b0):                                                      shift_cnt   <= {SIZE{1'b1}};
      (1'b1):                                                      shift_cnt   <= shift_cnt + 1'b1;
    endcase // case ({two_stop_enable,parity_enable})
  else
  if ( shift_cnt == (WIDTH+1))                                     shift_cnt   <= {SIZE{1'b1}};
  else                                                             shift_cnt   <= shift_cnt + 1'b1;

//
//    
//   Clear buffer_empty upon load pulse
//   set it back at the start of the final stop pulse
//   if load happens BEFORE the next edge_enable then data transfer will have no pauses 
//   logic ensures that having load happen on a edge_enable will work
//   
   
always@(posedge clk)
   if(reset)                                                       delayed_edge_enable <= 1'b0;
   else                                                            delayed_edge_enable <= edge_enable && ! load;

   
always@(posedge clk)
if(reset)                                                          buffer_empty <= 1'b1;
else
if(load)                                                           buffer_empty <= 1'b0;
else
if((shift_cnt == {SIZE{1'b1}}) && delayed_edge_enable)    
                                                                   buffer_empty <= 1'b1;
else                                                               buffer_empty <= buffer_empty;





//
//
//   load shift_buffer during start_bit
//   shift down every bit
//   
//   
always@(posedge clk)
  if(reset)                                                        shift_buffer <= {WIDTH{1'b0}};
  else
  if(load)                                                         shift_buffer <= data;
  else
  if(!edge_enable)                                                 shift_buffer <= shift_buffer;
  else
  if(shift_cnt == {SIZE{1'b1}})                                    shift_buffer <= shift_buffer;
  else
  if(shift_cnt == {SIZE{1'b0}})                                    shift_buffer <= shift_buffer;
  else                                                             shift_buffer <= {1'b0,shift_buffer[WIDTH-1:1]};






//
//
//   calculate parity on the fly
//   seed reg with 0 for odd and 1 for even
//   force reg to 0 or 1 if needed  
//   
always@(posedge clk)
  if(reset)                                                        parity_calc <= 1'b0;
  else
  if(!edge_enable)                                                 parity_calc <= parity_calc;
  else
  if(parity_force || (shift_cnt == {SIZE{1'b0}}))                  parity_calc <= parity_type;
  else                                                             parity_calc <= parity_calc ^ shift_buffer[0];


//   send start_bit,data,parity and stop  based on shift_cnt
   

   always@(posedge clk)
     if(reset)                                                     ser_out <= stop_value;
     else
     if( shift_cnt == {SIZE{1'b0}} )                               ser_out <= start_value;
     else
     if( shift_cnt == {SIZE{1'b1}} )                               ser_out <= stop_value;
     else
     if( shift_cnt == ({SIZE{1'b1}}+1'b1) )                        ser_out <= stop_value;
     else
     if( shift_cnt == (WIDTH+1) )                                  ser_out <= parity_calc;
     else                                                          ser_out <= shift_buffer[0];
                
   
endmodule



