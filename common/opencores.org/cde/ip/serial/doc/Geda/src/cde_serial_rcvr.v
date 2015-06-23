module 
cde_serial_rcvr
#(parameter   WIDTH=8,           // Number of data bits
  parameter   SIZE=4,             // binary size of shift_cnt, must be able to hold  WIDTH + 4 states
  parameter   BREAK=0,             // 1 enables break_detect
  parameter   STOP_VALUE=1             // stop bit level
  //        
 )(
input  wire               clk,
input  wire               reset,
input  wire               edge_enable,                 // one pulse per bit time for 16 x data rate timing
input  wire               parity_enable,               // 0 = no parity bit sent, 1= parity bit sent
input  wire               parity_type,                 // 0= odd,1=even
input  wire               parity_force,                // 1=force to parity_type
input  wire               ser_in,                      // from pad_ring
output  reg   [WIDTH-1:0] shift_buffer,
output  reg               stop_cnt,
output  reg               last_cnt,
output  reg               parity_calc,
output  reg               parity_samp,
output  reg               frame_err,
output  reg               break_detect

);  

reg           [SIZE-1:0]  shift_cnt;




   
//
//   shift_cnt controls the serial bit out
//  
//   0           Start bit  
//   1-> WIDTH   Data bit lsb first
//   WIDTH+1     Parity bit if enabled
//   2^SIZE-1    Last stop bit and idle
 
always@(posedge clk)
  if( break_detect)                                 
    begin
    shift_cnt       <= {SIZE{1'b1}};
    last_cnt        <= 1'b0;
    end
  else
  if(!edge_enable)
    begin    
    shift_cnt       <= shift_cnt;
    last_cnt        <= 1'b0;       
    end
  else
  if(( shift_cnt ==  {SIZE{1'b1}}))      
   begin    
    shift_cnt       <= {SIZE{1'b0}};
    last_cnt        <= 1'b0;      
   end
  else
  if ( shift_cnt == WIDTH)               
    case( parity_enable )        
      (1'b0):                 
        begin
        shift_cnt   <= {SIZE{1'b1}};
        last_cnt    <= 1'b1;
        end
      
      (1'b1):
        begin                      
        shift_cnt   <= shift_cnt + 1'b1;
        last_cnt    <= 1'b0;
        end 
   endcase // case (parity_enable)
  else
  if ( shift_cnt == (WIDTH+1))
     begin      
     shift_cnt      <= {SIZE{1'b1}};
     last_cnt       <= 1'b1;
     end
  else  
     begin             
     shift_cnt      <= shift_cnt + 1'b1;
     last_cnt       <= 1'b0;
     end
//
//
//   load shift_buffer during start_bit
//   shift down every bit
//   
//   
always@(posedge clk)
  if(reset)                                                        shift_buffer <= {WIDTH{1'b0}};
  else
  if(!edge_enable)                                                 shift_buffer <= shift_buffer;
  else
  if(shift_cnt == {SIZE{1'b1}})                                    shift_buffer <= {WIDTH{1'b0}};
  else
  if(shift_cnt <= WIDTH-1 )                                        shift_buffer <= {ser_in,shift_buffer[WIDTH-1:1]};
  else                                                             shift_buffer <= shift_buffer;
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
  if(parity_force || (shift_cnt == {SIZE{1'b1}}))                  parity_calc <= parity_type;
  else
  if(shift_cnt <= WIDTH-1 )                                        parity_calc <= parity_calc ^ ser_in;
  else                                                             parity_calc <= parity_calc;
//   
//   sample parity bit and hold it until next start bit
//   
always@(posedge clk)
  if(reset)                                                        parity_samp <= 1'b0;
  else
  if(!edge_enable)                                                 parity_samp <= parity_samp;
  else
  if(shift_cnt == {SIZE{1'b1}})                                    parity_samp <= 1'b0;
  else
  if(shift_cnt == WIDTH  )                                         parity_samp <= ser_in;
  else                                                             parity_samp <= parity_samp;
//   
//   check for stop bit error
//   
always@(posedge clk)
  if(reset)                                                        frame_err <= 1'b0;
  else
  if(!edge_enable)                                                 frame_err <= frame_err;
  else
  if(shift_cnt == {SIZE{1'b1}})                                    frame_err <= 1'b0;
  else
    begin
    case( parity_enable )        
      (1'b0):                 
        begin
        if(shift_cnt == WIDTH    )                                       frame_err <= ser_in ^ STOP_VALUE;
        else                                                             frame_err <= frame_err;
        end
      
      (1'b1):
        begin                      
        if(shift_cnt == WIDTH+1  )                                       frame_err <= ser_in ^ STOP_VALUE;
        else                                                             frame_err <= frame_err;
        end 
    endcase // case (parity_enable)
    end   



    


   



//   
//   create break_detect
//   
always@(posedge clk)
  if(reset)                                                        break_detect  <= 1'b1;
  else
  if(BREAK)
    begin
    if(!break_detect)                                              break_detect  <= last_cnt && (ser_in ^ STOP_VALUE);
    else                                                           break_detect  <= (ser_in ^ STOP_VALUE);
    end
  else
    begin
                                                                   break_detect  <= 1'b0;
    end

   


   
always@(*)
  if(  shift_cnt ==  {SIZE{1'b1}})                                 stop_cnt   = 1'b1;
  else                                                             stop_cnt   = 1'b0;


endmodule



